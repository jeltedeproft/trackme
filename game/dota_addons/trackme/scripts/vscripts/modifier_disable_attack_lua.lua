modifier_disable_attack_lua = class({})

--------------------------------------------------------------------------------

function modifier_disable_attack_lua:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_disable_attack_lua:CheckState()
	local state = {
	[MODIFIER_STATE_DISARMED] = true,
	[MODIFIER_STATE_HEXED] = true,
	[MODIFIER_STATE_MUTED] = true,
	[MODIFIER_STATE_EVADE_DISABLED] = true,
	[MODIFIER_STATE_BLOCK_DISABLED] = true,
	[MODIFIER_STATE_SILENCED] = true
	}

	return state
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
