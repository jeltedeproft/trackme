--[[ events.lua ]]

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function COverthrowGameMode:OnEntityHurt(keys)
  --DebugPrint("[BAREBONES] Entity Hurt")
  --DebugPrintTable(keys)

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
    local entCause = EntIndexToHScript(keys.entindex_attacker)
    local entVictim = EntIndexToHScript(keys.entindex_killed)

    -- The ability/item used to damage, or nil if not damaged by an item/ability
    local damagingAbility = nil

    if keys.entindex_inflictor ~= nil then
      damagingAbility = EntIndexToHScript( keys.entindex_inflictor )
    end

    if entVictim:HasModifier("modifier_track_aura_datadriven") and damagingAbility ~= nil then
    	entVictim:RemoveModifierByName("modifier_track_aura_datadriven")
    	self.superBounty:CastAbilityOnTarget(entCause, self.globaltrack2, 0)

    	--if this hero was close to victory and slowed down, speed him up again
    	if entVictim.bclosetovictory == true then
    		entVictim.bclosetovictory = nil
    		entVictim:SetBaseMoveSpeed(600)
    	end
    end
  end
end


---------------------------------------------------------------------------
-- Event: Game state change handler
---------------------------------------------------------------------------
function COverthrowGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	--print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );

		self._fPreGameStartTime = GameRules:GetGameTime()
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "OnGameRulesStateChange: Game In Progress" )
		self.countdownEnabled = true
		CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
		DoEntFire( "center_experience_ring_particles", "Start", "0", 0, self, self  )
		Notifications:TopToAll({text="Scoring has not yet started, please use this time to buy items", duration=10.0})
	end
end

--------------------------------------------------------------------------------
-- Event: OnNPCSpawned
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit:IsRealHero() and spawnedUnit.bFirstSpawned == nil then

		--set camera
		local player = spawnedUnit:GetPlayerOwner()
		local playerId = player:GetPlayerID()
		GameRules:GetGameModeEntity():SetCameraDistanceOverride(1434)

		--gold
		PlayerResource:SetGold(playerId, 20000, false)

		--abiltiies
		spawnedUnit:SetAbilityPoints(0)
		--remove
		local abilityCount = spawnedUnit:GetAbilityCount()
		for i=0, abilityCount , 1 do
		    local hAbil = spawnedUnit:GetAbilityByIndex(i)
		    if hAbil ~= nil  and hAbil:GetAbilityName()~= "attribute_bonus" then 
		        spawnedUnit:RemoveAbility(hAbil:GetAbilityName())
		    end
		end

		--add
		spawnedUnit:AddAbility("magnataur_shockwave")
		spawnedUnit:AddAbility("imba_mirana_arrow" )
		spawnedUnit:AddAbility("puck_phase_shift_datadriven")
		spawnedUnit:AddAbility("imba_pudge_meat_hook")
		spawnedUnit:AddAbility("deflect")
		spawnedUnit:AddAbility("torrent_datadriven")

		local abilityCount2 = spawnedUnit:GetAbilityCount()
		for i=0, abilityCount2 , 1 do
		    local hAbil2 = spawnedUnit:GetAbilityByIndex(i)
		    if hAbil2 ~= nil  and hAbil2:GetAbilityName()~= "attribute_bonus" then
		        hAbil2:SetLevel(hAbil2:GetMaxLevel())
		    end
		end

		--mana
		spawnedUnit:SetMana(1000)
		spawnedUnit:SetBaseManaRegen(1000) 
		spawnedUnit:SetMaxHealth(10000)
		spawnedUnit:SetBaseStrength(1000)
		spawnedUnit:SetBaseMaxHealth(10000)
		spawnedUnit:SetBaseHealthRegen(1000)
		
		--equalize movement speed
		spawnedUnit:SetBaseMoveSpeed(600)

		--give blink and force
		local itemForce = CreateItem("item_force_staff", spawnedUnit, spawnedUnit)
		local itemBlink = CreateItem("item_blink", spawnedUnit, spawnedUnit)
		spawnedUnit:AddItem(itemForce)
		spawnedUnit:AddItem(itemBlink)

		if self.firstTrack ~= nil then
			self.firstTrack:RemoveModifierByName("modifier_track_aura_datadriven")	
		end

		self.firstTrack = spawnedUnit

		self.superBounty:CastAbilityOnTarget(self.firstTrack, self.globaltrack2, 0)

		-- Destroys the last hit effects
		local deathEffects = spawnedUnit:Attribute_GetIntValue( "effectsID", -1 )
		if deathEffects ~= -1 then
			ParticleManager:DestroyParticle( deathEffects, true )
			spawnedUnit:DeleteAttribute( "effectsID" )
		end

		table.insert(self.allheroes,spawnedUnit)
		spawnedUnit.bFirstSpawned = true

		--aply speed break
		spawnedUnit:AddNewModifier(spawnedUnit, 
			spawnedUnit:GetAbilityByIndex(0),
			 "modifier_imba_speed_limit_break", 
			 {duration = 1000})

	end
end

--------------------------------------------------------------------------------
-- Event: BountyRunePickupFilter
--------------------------------------------------------------------------------
function COverthrowGameMode:BountyRunePickupFilter( filterTable )
      filterTable["xp_bounty"] = 2*filterTable["xp_bounty"]
      filterTable["gold_bounty"] = 2*filterTable["gold_bounty"]
      return true
end

---------------------------------------------------------------------------
-- Event: OnTeamKillCredit, see if anyone won
---------------------------------------------------------------------------
function COverthrowGameMode:OnTeamKillCredit( event )
--	print( "OnKillCredit" )
--	DeepPrint( event )
end

---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function COverthrowGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	local hero = EntIndexToHScript( event.entindex_attacker )
	local heroTeam = hero:GetTeam()
	local extraTime = 0
	if killedUnit:IsRealHero() then
		self.allSpawned = true
		--print("Hero has been killed")
		--Add extra time if killed by Necro Ult
		if hero:IsRealHero() == true then
			if event.entindex_inflictor ~= nil then
				local inflictor_index = event.entindex_inflictor
				if inflictor_index ~= nil then
					local ability = EntIndexToHScript( event.entindex_inflictor )
					if ability ~= nil then
						if ability:GetAbilityName() ~= nil then
							if ability:GetAbilityName() == "necrolyte_reapers_scythe" then
								print("Killed by Necro Ult")
								extraTime = 20
							end
						end
					end
				end
			end
		end
		if hero:IsRealHero() and heroTeam ~= killedTeam then
			--print("Granting killer xp")
			if killedUnit:GetTeam() == self.leadingTeam and self.isGameTied == false then
				local memberID = hero:GetPlayerID()
				PlayerResource:ModifyGold( memberID, 500, true, 0 )
				hero:AddExperience( 100, 0, false, false )
				local name = hero:GetClassname()
				local victim = killedUnit:GetClassname()
				local kill_alert =
					{
						hero_id = hero:GetClassname()
					}
				CustomGameEventManager:Send_ServerToAllClients( "kill_alert", kill_alert )
			else
				hero:AddExperience( 50, 0, false, false )
			end
		end
		--Granting XP to all heroes who assisted
		local allHeroes = HeroList:GetAllHeroes()
		for _,attacker in pairs( allHeroes ) do
			--print(killedUnit:GetNumAttackers())
			for i = 0, killedUnit:GetNumAttackers() - 1 do
				if attacker == killedUnit:GetAttacker( i ) then
					--print("Granting assist xp")
					attacker:AddExperience( 25, 0, false, false )
				end
			end
		end
		if killedUnit:GetRespawnTime() > 10 then
			--print("Hero has long respawn time")
			if killedUnit:IsReincarnating() == true then
				--print("Set time for Wraith King respawn disabled")
				return nil
			else
				COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
			end
		else
			COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
		end
	end
end

function COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
	--print("Setting time for respawn")
	if killedTeam == self.leadingTeam and self.isGameTied == false then
		killedUnit:SetTimeUntilRespawn( 20 + extraTime )
	else
		killedUnit:SetTimeUntilRespawn( 10 + extraTime )
	end
end


--------------------------------------------------------------------------------
-- Event: OnItemPickUp
--------------------------------------------------------------------------------
function COverthrowGameMode:OnItemPickUp( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	r = 300
	--r = RandomInt(200, 400)
	if event.itemname == "item_bag_of_gold" then
		--print("Bag of gold picked up")
		PlayerResource:ModifyGold( owner:GetPlayerID(), r, true, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, r, nil )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	elseif event.itemname == "item_treasure_chest" then
		--print("Special Item Picked Up")
		DoEntFire( "item_spawn_particle_" .. self.itemSpawnIndex, "Stop", "0", 0, self, self )
		COverthrowGameMode:SpecialItemAdd( event )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	end
end


--------------------------------------------------------------------------------
-- Event: OnNpcGoalReached
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNpcGoalReached( event )
	local npc = EntIndexToHScript( event.npc_entindex )
	if npc:GetUnitName() == "npc_dota_treasure_courier" then
		COverthrowGameMode:TreasureDrop( npc )
	end
end
