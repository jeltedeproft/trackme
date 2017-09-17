--[[Author: Pizzalol
	Date: 02.01.2015.
	Triggers on death and grants bonus gold to the caster and friendly heroes around the target]]
function Track( keys )
	local caster = keys.caster
	local target = keys.target
	local targetLocation = target:GetAbsOrigin() 
	local ability = keys.ability

	-- Remove the track aura from the target
	-- NOTE: Trying to do this in KV is not possible it seems
	target:RemoveModifierByName("modifier_track_aura_datadriven") 
end