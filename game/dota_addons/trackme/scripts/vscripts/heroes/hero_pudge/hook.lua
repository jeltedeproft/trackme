--[[ 	Authors: Pizzalol and D2imba
		Date: 10.07.2015				]]

function HookCast( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_cast_check = keys.modifier_cast_check

	-- Parameters
	local base_range = ability:GetLevelSpecialValueFor("base_range", ability_level)
	local cast_distance = ( target - caster:GetAbsOrigin() ):Length2D()
	caster.stop_hook_cast = nil

	-- Calculate actual cast range
	local hook_range = base_range

	-- Check if the target point is inside range, if not, stop casting and move closer
	if cast_distance > hook_range then

		-- Start moving
		caster:MoveToPosition(target)
		Timers:CreateTimer(0.1, function()

			-- Update distance and range
			cast_distance = ( target - caster:GetAbsOrigin() ):Length2D()
			hook_range = base_range

			-- If it's not a legal cast situation and no other order was given, keep moving
			if cast_distance > hook_range and not caster.stop_hook_cast then
				return 0.1
			-- If another order was given, stop tracking the cast distance
			elseif caster.stop_hook_cast then
				caster:RemoveModifierByName(modifier_cast_check)
				caster.stop_hook_cast = nil

			-- If all conditions are met, cast Hook again
			else
				caster:CastAbilityOnPosition(target, ability, caster:GetPlayerID())
			end
		end)
		
		return nil		
	end
end

function HookCastCheck( keys )
	
	local caster = keys.caster
	caster.stop_hook_cast = true
	
end

function MeatHook( keys )
	
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local caster_pos = caster:GetAbsOrigin()

	-- If another hook is already out, refund mana cost and do nothing
	if caster.hook_launched then
		caster:GiveMana(ability:GetManaCost(ability_level))
		ability:EndCooldown()
		
		return nil
	end

	-- Set the global hook_launched variable
	caster.hook_launched = true

	-- Sound, particle and modifier keys
	local sound_extend = keys.sound_extend
	local sound_hit = keys.sound_hit
	local sound_scepter_hit = keys.sound_scepter_hit
	local sound_retract = keys.sound_retract
	local sound_retract_stop = keys.sound_retract_stop
	local particle_hook = keys.particle_hook
	local particle_hit = keys.particle_hit
	local particle_hit_scepter = keys.particle_hit_scepter
	local modifier_caster = keys.modifier_caster
	local modifier_target_enemy = keys.modifier_target_enemy
	local modifier_target_ally = keys.modifier_target_ally
	local modifier_dummy = keys.modifier_dummy

	
	-- Parameters
	local base_speed = ability:GetLevelSpecialValueFor("base_speed", ability_level)
	local hook_width = ability:GetLevelSpecialValueFor("hook_width", ability_level)
	local base_range = ability:GetLevelSpecialValueFor("base_range", ability_level)
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", ability_level)
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level)
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability_level)
	local damage_scepter = ability:GetLevelSpecialValueFor("damage_scepter", ability_level)
	local caster_loc = caster:GetAbsOrigin()
	local start_loc = caster_loc + caster:GetForwardVector() * hook_width

	local hook_direction2 = (RotatePosition(caster_pos, QAngle(0, 45, 0), caster_pos + caster:GetForwardVector()) - caster_pos):Normalized()
	local hook_direction3 = (RotatePosition(caster_pos, QAngle(0, -45, 0), caster_pos + caster:GetForwardVector()) - caster_pos):Normalized()
	local hook_direction4 = (RotatePosition(caster_pos, QAngle(0, 90, 0), caster_pos + caster:GetForwardVector()) - caster_pos):Normalized()
	local hook_direction5 = (RotatePosition(caster_pos, QAngle(0, -90, 0), caster_pos + caster:GetForwardVector()) - caster_pos):Normalized()
	local hook_direction6 = (RotatePosition(caster_pos, QAngle(0,135, 0), caster_pos + caster:GetForwardVector()) - caster_pos):Normalized()

	-- Calculate range, speed, and damage

	local hook_speed = base_speed
	local hook_speed2 = base_speed
	local hook_speed3 = base_speed
	local hook_speed4 = base_speed
	local hook_speed5 = base_speed
	local hook_speed6 = base_speed
	local hook_range = base_range
	local hook_damage = base_damage

	-- Stun the caster for the hook duration
	--ability:ApplyDataDrivenModifier(caster, caster, modifier_caster, {})

	-- Play Hook launch sound
	caster:EmitSound(sound_extend)

	-- Create and set up the Hook dummy unit
	local hook_dummy = CreateUnitByName("npc_dummy_blank", start_loc, false, caster, caster, caster:GetTeam())
	hook_dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, hook_dummy, modifier_dummy, {})
	hook_dummy:SetForwardVector(caster:GetForwardVector())

	-- Make the hook always visible to both teams
	caster:MakeVisibleToTeam(DOTA_TEAM_GOODGUYS, hook_range / hook_speed)
	caster:MakeVisibleToTeam(DOTA_TEAM_BADGUYS, hook_range / hook_speed)
	
	-- Attach the Hook particle
	local hook_pfx = ParticleManager:CreateParticle(particle_hook, PATTACH_RENDERORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleAlwaysSimulate(hook_pfx)
	ParticleManager:SetParticleControlEnt(hook_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", caster_loc, true)
	ParticleManager:SetParticleControl(hook_pfx, 1, start_loc)
	ParticleManager:SetParticleControl(hook_pfx, 2, Vector(hook_speed, hook_range, hook_width) )
	ParticleManager:SetParticleControlEnt(hook_pfx, 6, hook_dummy, 5, "attach_hitloc", start_loc, false)
	ParticleManager:SetParticleControlEnt(hook_pfx, 7, caster, PATTACH_CUSTOMORIGIN, nil, caster_loc, true)

	-- Remove the caster's hook
	local weapon_hook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
	if weapon_hook ~= nil then
		weapon_hook:AddEffects( EF_NODRAW )
	end

	-- Initialize Hook variables
	local hook_loc = start_loc
	local tick_rate = 0.03
	hook_speed = hook_speed * tick_rate

	local travel_distance = (hook_loc - caster_loc):Length2D()
	local hook_step = caster:GetForwardVector() * hook_speed

	local target_hit = false
	local target

	-- Main Hook loop
	Timers:CreateTimer(tick_rate, function()

		-- Check for valid units in the area
		local units = FindUnitsInRadius(caster:GetTeamNumber(), hook_loc, nil, hook_width, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
		for _,unit in pairs(units) do
			if unit ~= caster and unit ~= hook_dummy and not unit:IsAncient() then
				target_hit = true
				target = unit
				break
			end
		end

		-- If a valid target was hit, start dragging them
		if target_hit then

			-- Apply stun/root modifier, and damage if the target is an enemy
			if caster:GetTeam() == target:GetTeam() then
				ability:ApplyDataDrivenModifier(caster, target, modifier_target_ally, {})
			else
				ability:ApplyDataDrivenModifier(caster, target, modifier_target_enemy, {})
				ApplyDamage({attacker = caster, victim = target, ability = ability, damage = hook_damage, damage_type = DAMAGE_TYPE_PURE})
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, hook_damage, nil)
			end

			-- Play the hit sound and particle
			target:EmitSound(sound_hit)
			local hook_pfx = ParticleManager:CreateParticle(particle_hit, PATTACH_ABSORIGIN_FOLLOW, target)

			-- Grant vision on the hook hit area
			ability:CreateVisibilityNode(hook_loc, vision_radius, vision_duration)
		end

		-- If no target was hit and the maximum range is not reached, move the hook and keep going
		if not target_hit and travel_distance < hook_range then

			-- Move the hook
			hook_dummy:SetAbsOrigin(hook_loc + hook_step)

			-- Recalculate position and distance
			hook_loc = hook_dummy:GetAbsOrigin()
			travel_distance = (hook_loc - caster_loc):Length2D()
			return tick_rate
		end

		-- If we are here, this means the hook has to start reeling back; prepare return variables
		local direction = ( caster_loc - hook_loc )

		-- Stop the extending sound and start playing the return sound
		caster:StopSound(sound_extend)
		caster:EmitSound(sound_retract)

		-- Remove the caster's self-stun
		caster:RemoveModifierByName(modifier_caster)

		-- Play sound reaction according to which target was hit
		if target_hit and target:IsRealHero() and target:GetTeam() ~= caster:GetTeam() then
			caster:EmitSound("pudge_pud_ability_hook_0"..RandomInt(1,9))
		elseif target_hit and target:IsRealHero() and target:GetTeam() == caster:GetTeam() then
			caster:EmitSound("pudge_pud_ability_hook_miss_01")
		elseif target_hit then
			caster:EmitSound("pudge_pud_ability_hook_miss_0"..RandomInt(2,6))
		else
			caster:EmitSound("pudge_pud_ability_hook_miss_0"..RandomInt(8,9))
		end

		-- Hook reeling loop
		Timers:CreateTimer(tick_rate, function()

			-- Recalculate position variables
			caster_loc = caster:GetAbsOrigin()
			hook_loc = hook_dummy:GetAbsOrigin()
			direction = ( caster_loc - hook_loc )
			hook_step = direction:Normalized() * hook_speed
			
			-- If the target is close enough, finalize the hook return
			if direction:Length2D() < hook_speed then

				-- Stop moving the target
				if target_hit then
					local final_loc = caster_loc + caster:GetForwardVector() * 100
					FindClearSpaceForUnit(target, final_loc, false)

					-- Remove the target's modifiers
					target:RemoveModifierByName(modifier_target_ally)
					target:RemoveModifierByName(modifier_target_enemy)
				end

				-- Destroy the hook dummy and particles
				hook_dummy:Destroy()
				ParticleManager:DestroyParticle(hook_pfx, false)

				-- Stop playing the reeling sound
				caster:StopSound(sound_retract)
				caster:EmitSound(sound_retract_stop)

				-- Give back the caster's hook
				if weapon_hook ~= nil then
					weapon_hook:RemoveEffects( EF_NODRAW )
				end

				-- Clear global variables
				caster.hook_launched = nil

			-- If this is not the final step, keep reeling the hook in
			else

				-- Move the hook and an eventual target
				hook_dummy:SetAbsOrigin(hook_loc + hook_step)

				if target_hit then
					target:SetAbsOrigin(hook_loc + hook_step)
					target:SetForwardVector(direction:Normalized())
					ability:CreateVisibilityNode(hook_loc, vision_radius, 0.5)
				end
				
				return tick_rate
			end
		end)
	end)
end