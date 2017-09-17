
--[[ sawblade_trap_trigger.lua ]]
local triggerActive = true
local isSawbladeReady = true
local triggerCounter = 0
local triggerHeroList = {}

function OnStartTouch(trigger)
	--print( "Sawblade TRIGGER" )
	triggerCounter = triggerCounter + 1
  	local triggerName = thisEntity:GetName()
	local team = trigger.activator:GetTeam()
	local level = trigger.activator:GetLevel()
	local heroIndex = trigger.activator:GetEntityIndex()
	local heroHandle = EntIndexToHScript(heroIndex)
	table.insert( triggerHeroList, heroHandle )
	if not triggerActive then
		--print( "Sawblade SKIP" )
		return
	end
	triggerActive = false
	thisEntity:SetContextThink( "ResetTrapModel", function() ResetTrapModel() end, 17 )

	EnableSawblade( triggerName, heroHandle )

	local button = triggerName .. "_button"
	local buttonFx = triggerName .. "_buttonFX"
	DoEntFire( button, "SetAnimation", "ancient_trigger001_down", 0, self, self )
	DoEntFire( button, "SetAnimation", "ancient_trigger001_down_idle", .35, self, self )
	DoEntFire( button, "SetAnimation", "ancient_trigger001_up", 17, self, self )
	DoEntFire( button, "SetAnimation", "ancient_trigger001_idle", 17.5, self, self )
	--DoEntFire( buttonFx, "Start", "", 0, self, self )
	--DoEntFire( buttonFx, "Stop", "", 2, self, self )
end

function EnableSawblade( triggerName, heroHandle )
	if isSawbladeReady == true then
		--print("Enabling Sawblade")
		isSawbladeReady = false
		--EmitGlobalSound("Hero_Shredder.Chakram")
		EmitGlobalSound("tutorial_rockslide")
		local sawbladeTracktrain = triggerName .. "_tracktrain"
		local sawbladeMover = Entities:FindByName( nil, sawbladeTracktrain )
		--[[Creating particles in script
		local sawbladeEffects = ParticleManager:CreateParticle( "particles/traps/sawblade/sawblade_trap_stay.vpcf", PATTACH_ABSORIGIN_FOLLOW, sawbladeMover )
		ParticleManager:SetParticleControlEnt( sawbladeEffects, 0, sawbladeMover, PATTACH_ABSORIGIN_FOLLOW, nil, sawbladeMover:GetAbsOrigin(), true )
		sawbladeMover:Attribute_SetIntValue( "effectsID", sawbladeEffects )
		]]
		DoEntFire( triggerName .. "_shake", "StartShake", "", 0, self, self )
		DoEntFire( triggerName .. "_tracktrain", "SetSpeed", "500", 0, self, self )
		DoEntFire( triggerName .. "_particle", "Start", "", 0, self, self )
		DoEntFire( triggerName .. "_trigger", "Enable", "", 0, self, self )

		DoEntFire( triggerName .. "_tracktrain_top", "SetSpeed", "200", 0, self, self )
		DoEntFire( triggerName .. "_particle_top", "Start", "", 0, self, self )
		DoEntFire( triggerName .. "_trigger_top", "Enable", "", 0, self, self )

		DoEntFire( triggerName .. "_tracktrain_bot", "SetSpeed", "300", 0, self, self )
		DoEntFire( triggerName .. "_particle_bot", "Start", "", 0, self, self )
		DoEntFire( triggerName .. "_trigger_bot", "Enable", "", 0, self, self )

		local trapName = triggerName .. "_npc"
		local npc = Entities:FindByName( nil, trapName )
		npc.KillerToCredit = triggerHeroList[1]
		npc:SetContextThink( "DisableTrap", function() return DisableSawblade( triggerName, heroHandle, sawbladeMover ) end, 8 )
	end
	return -1
end

function DisableSawblade( triggerName, heroHandle, sawbladeMover )
	--print( "Disabling Sawblade" )
	local sawbladeTrigger = triggerName .. "_trigger"
	--local sawbladeParticle = sawbladeMover:Attribute_GetIntValue( "effectsID", -1 )
	--ParticleManager:DestroyParticle( sawbladeParticle, true )
	DoEntFire( triggerName .. "_shake", "StopShake", "", 0, self, self )
	DoEntFire( triggerName .. "_particle", "StopPlayEndCap", "", 0, self, self )
	DoEntFire( triggerName .. "_trigger", "Disable", "", 0, self, self )

	DoEntFire( triggerName .. "_particle_top", "StopPlayEndCap", "", 0, self, self )
	DoEntFire( triggerName .. "_trigger_top", "Disable", "", 0, self, self )

	DoEntFire( triggerName .. "_particle_bot", "StopPlayEndCap", "", 0, self, self )
	DoEntFire( triggerName .. "_trigger_bot", "Disable", "", 0, self, self )
	isSawbladeReady = true
	if triggerCounter > 0 then
		--print("Reactivate the trap")
		local trapName = triggerName .. "_npc"
		local npc = Entities:FindByName( nil, trapName )
		npc.KillerToCredit = triggerHeroList[1]
		npc:SetContextThink( "EnableTrap", function() return EnableSawblade( triggerName ) end, 0 )
		return 0
	end
end

function OnEndTouch(trigger)
	local heroIndex = trigger.activator:GetEntityIndex()
	local heroHandle = EntIndexToHScript(heroIndex)
	triggerCounter = triggerCounter - 1
	for i,v in ipairs( triggerHeroList ) do
		if v == heroHandle then
			table.remove( triggerHeroList, i )
		end
	end
	--print("Trap Button Trigger Exited")
end

function ResetTrapModel()
	--print( "Sawblade RESET" )
	triggerActive = true
end
