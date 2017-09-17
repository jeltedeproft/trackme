function LaunchArrow( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target = keys.target_points[1]
	local particle_name = keys.particle

	-- Parameters
	local arrow_direction = caster:GetForwardVector()
	local arrow_direction2 = (RotatePosition(target, QAngle(0, 45, 0), target + arrow_direction) - target):Normalized()
	local arrow_direction3 = (RotatePosition(target, QAngle(0, -45, 0), target + arrow_direction) - target):Normalized()
	local sound_arrow = keys.sound_arrow
	local arrow_speed = ability:GetLevelSpecialValueFor("arrow_speed", ability_level)
	local arrow_width = ability:GetLevelSpecialValueFor("arrow_width", ability_level)
	local arrow_max_stunrange = ability:GetLevelSpecialValueFor("arrow_max_stunrange", ability_level)
	local arrow_min_stun = ability:GetLevelSpecialValueFor("arrow_min_stun", ability_level)
	local arrow_max_stun = ability:GetLevelSpecialValueFor("arrow_max_stun", ability_level)
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", ability_level)
	local arrow_bonus_damage = ability:GetLevelSpecialValueFor("arrow_bonus_damage", ability_level)
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability_level)
	local vision_radius = ability:GetLevelSpecialValueFor("arrow_vision", ability_level)
	local enemy_units

	-- Memorizes the cast location to calculate the distance traveled later
	local arrow_location = caster:GetAbsOrigin() + (5 *  arrow_direction)
	local arrow_location2 = caster:GetAbsOrigin() + (5 *  arrow_direction2)
	local arrow_location3 = caster:GetAbsOrigin() + (5 *  arrow_direction3)

	-- Spawn the arrow unit and move it forward
	ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		EffectName			= particle_name,
		vSpawnOrigin		= arrow_location,
		fDistance			= 2000,
		fStartRadius		= arrow_width,
		fEndRadius			= arrow_width,
		Source				= caster,
		bHasFrontalCone		= true,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_CUSTOM + DOTA_UNIT_TARGET_BASIC,
		--	fExpireTime			= ,
		bDeleteOnHit		= true,
		vVelocity			= arrow_direction * arrow_speed,
		bProvidesVision		= true,
		iVisionRadius		= vision_radius	,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	} )

	ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		EffectName			= particle_name,
		vSpawnOrigin		= arrow_location2,
		fDistance			= 2000,
		fStartRadius		= arrow_width,
		fEndRadius			= arrow_width,
		Source				= caster,
		bHasFrontalCone		= true,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_CUSTOM + DOTA_UNIT_TARGET_BASIC,
		--	fExpireTime			= ,
		bDeleteOnHit		= true,
		vVelocity			= arrow_direction2 * arrow_speed,
		bProvidesVision		= true,
		iVisionRadius		= vision_radius	,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	} )

	ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		EffectName			= particle_name,
		vSpawnOrigin		= arrow_location3,
		fDistance			= 2000,
		fStartRadius		= arrow_width,
		fEndRadius			= arrow_width,
		Source				= caster,
		bHasFrontalCone		= true,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_CUSTOM + DOTA_UNIT_TARGET_BASIC,
		--	fExpireTime			= ,
		bDeleteOnHit		= true,
		vVelocity			= arrow_direction3 * arrow_speed,
		bProvidesVision		= true,
		iVisionRadius		= vision_radius	,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	} )
end

function StunRange( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target = keys.target_points[1]
	local particle_name = keys.particle
end
