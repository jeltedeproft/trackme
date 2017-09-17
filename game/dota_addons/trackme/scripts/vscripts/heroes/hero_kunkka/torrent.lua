--[[
	Author: kritth
	Date: 9.1.2015.
	Bubbles seen only to ally as pre-effect
]]
function torrent_bubble_allies( keys )
	local caster = keys.caster
	
	local allHeroes = HeroList:GetAllHeroes()
	local delay = keys.ability:GetLevelSpecialValueFor( "delay", keys.ability:GetLevel() - 1 )
	local particleName = "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf"
	local target = keys.target_points[1]
	
	for k, v in pairs( allHeroes ) do
		if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
			local fxIndex = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, v, PlayerResource:GetPlayer( v:GetPlayerID() ) )
			ParticleManager:SetParticleControl( fxIndex, 0, target )
			
			EmitSoundOnClient( "Ability.pre.Torrent", PlayerResource:GetPlayer( v:GetPlayerID() ) )
			
			-- Destroy particle after delay
			Timers:CreateTimer( delay, function()
					ParticleManager:DestroyParticle( fxIndex, false )
					return nil
				end
			)
		end
	end
end

--[[
	Author: kritth
	Date: 9.1.2015.
	Emit sound at location
]]
function torrent_emit_sound( keys )
	local dummy = CreateUnitByName( "npc_dummy_unit", keys.target_points[1], false, keys.caster, keys.caster, keys.caster:GetTeamNumber() )
	EmitSoundOn( "Ability.Torrent", dummy )
	dummy:ForceKill( true )
end

--[[
	Author: kritth, Pizzalol
	Date: February 24, 2016
	Provides obstructed vision of the area
]]
function torrent_vision( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "vision_duration", ability:GetLevel() - 1 )
	
	AddFOWViewer(caster:GetTeamNumber(),target,radius,duration,true)
end

function applydamage( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local amount = keys.Damage
	local typeOfDamage = keys.Type

	print("hey")
	print("caster = " .. caster:GetName())
	print("amount = " .. amount)
	print("type = " .. typeOfDamage)
	print("target = " .. target:GetName())

	    ApplyDamage({
	    	victim=target, 
	    	attacker=caster, 
	    	damage=amount, 
	    	damage_type=DAMAGE_TYPE_MAGICAL, 
	    	damage_flags=DOTA_DAMAGE_FLAG_NONE, 
	    	ability=ability
	    	});
end