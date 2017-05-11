modifier_sara_space_dissection = class({})

function modifier_sara_space_dissection:IsHidden()
	return true
end

function modifier_sara_space_dissection:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

if IsServer() then
	function modifier_sara_space_dissection:OnAttackLanded(keys)
		local parent = self:GetParent()
		if keys.attacker == parent and parent.GetEnergy then
			local ability = self:GetAbility()
			local unit = keys.target
			if PreformAbilityPrecastActions(parent, ability) then
				local pfx = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_sara/space_dissection.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
				ParticleManager:SetParticleControlEnt(pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 5, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true)
				unit:EmitSound("Hero_Centaur.DoubleEdge")
				if (unit:IsConsideredHero() or unit:IsBoss()) and not unit:IsIllusion() then
					local energy = parent:GetEnergy()
					local cost = parent:GetMaxEnergy() * ability:GetSpecialValueFor("energy_pct") * 0.01
					if energy >= cost then
						local duration = ability:GetSpecialValueFor("disarmor_duration")
						local modifier = unit:AddNewModifier(parent, ability, "modifier_sara_space_dissection_armor_reduction", {duration = duration})
						local stacks = math.round(cost * ability:GetSpecialValueFor("energy_to_disarmor_pct") * 0.01)
						modifier:SetStackCount(modifier:GetStackCount() + stacks)
						if not parent:HasScepter() then
							Timers:CreateTimer(duration, function()
								if modifier and not modifier:IsNull() then
									modifier:SetStackCount(modifier:GetStackCount() - stacks)
								end
							end)
						end
						parent:ModifyEnergy(cost)
					end
				elseif unit:IsRealCreep() then
					unit.SpaceDissectionMultiplier = ability:GetSpecialValueFor(parent:HasScepter() and "creep_energy_multiplier_scepter" or "creep_energy_multiplier")
					if not parent:HasScepter() then
						unit:SetDeathXP(0)
						unit:SetMinimumGoldBounty(0)
						unit:SetMaximumGoldBounty(0)
					end
					unit:Kill(ability, parent)
				end
			end
		end
	end
end

modifier_sara_space_dissection_armor_reduction = class({})

function modifier_sara_space_dissection_armor_reduction:IsPurgable()
	return false
end

function modifier_sara_space_dissection_armor_reduction:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_sara_space_dissection_armor_reduction:GetModifierPhysicalArmorBonus()
	return -self:GetStackCount()
end