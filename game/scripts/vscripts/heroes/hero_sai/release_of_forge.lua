LinkLuaModifier("modifier_sai_release_of_forge", "heroes/hero_sai/release_of_forge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sai_release_of_forge_mass_debuff", "heroes/hero_sai/release_of_forge.lua", LUA_MODIFIER_MOTION_NONE)

sai_release_of_forge = class({})

if IsServer() then
	function sai_release_of_forge:OnSpellStart()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_sai_release_of_forge", {duration = self:GetSpecialValueFor("duration")})
		caster:SetHealth(1)
	end
end


modifier_sai_release_of_forge = class({
	IsPurgable            = function() return false end,
	IsHidden              = function() return true end,
	GetEffectName         = function() return "particles/econ/items/invoker/glorious_inspiration/invoker_forge_spirit_ambient_esl_fire.vpcf" end,

	GetModifierAttackRangeBonus = function() return 99700 end,
	GetDisableHealing     = function() return 1 end,
	GetModifierModelScale = function() return 3 end,
	GetMinHealth          = function() return 1 end,

	IsAura                = function() return true end,
	GetAuraRadius         = function() return 99999 end,
})

function modifier_sai_release_of_forge:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_sai_release_of_forge:GetModifierModelChange()
	return "models/items/invoker/forge_spirit/sempiternal_revelations_forged_spirits/sempiternal_revelations_forged_spirits.vmdl"
end

function modifier_sai_release_of_forge:GetModifierAura()
	return "modifier_sai_release_of_forge_mass_debuff"
end

function modifier_sai_release_of_forge:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_sai_release_of_forge:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_sai_release_of_forge:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

if IsServer() then
	function modifier_sai_release_of_forge:OnDestroy()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		parent.RespawnTimeModifieSaiReleaseOfForge = ability:GetSpecialValueFor("bonus_respawn_time_pct")
		parent:TrueKill(ability, self:GetCaster())
	end
end


modifier_sai_release_of_forge_mass_debuff = class({
	IsPurgable = function() return false end,
})

function modifier_sai_release_of_forge_mass_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
	}
end

function modifier_sai_release_of_forge_mass_debuff:GetBonusVisionPercentage()
	return self:GetAbility():GetSpecialValueFor("aura_vision_pct")
end

function modifier_sai_release_of_forge_mass_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("aura_movement_speed_pct")
end

function modifier_sai_release_of_forge_mass_debuff:GetModifierPercentageCasttime()
	return self:GetAbility():GetSpecialValueFor("aura_cast_time_pct")
end

function modifier_sai_release_of_forge_mass_debuff:GetModifierTurnRate_Percentage()
	return self:GetAbility():GetSpecialValueFor("aura_turn_rate_pct")
end
