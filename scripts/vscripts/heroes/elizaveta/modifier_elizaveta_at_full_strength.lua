modifier_elizaveta_at_full_strength = class({})

function modifier_elizaveta_at_full_strength:IsHidden()
	return true
end

function modifier_elizaveta_at_full_strength:DeclareFunctions()
	local funcs = {
		--MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL
	}
 
	return funcs
end

function modifier_elizaveta_at_full_strength:OnAttackLanded( event )

end

function modifier_elizaveta_at_full_strength:GetModifierProcAttack_BonusDamage_Magical(event)
	local caster = self:GetCaster()
	local damage = self:GetAbility():GetSpecialValueFor("damage_per_stack") * caster:GetHealthPercent()
	caster:Heal(damage, caster)
	PopupHealing(caster, damage)
	PopupIntTome(event.target, damage)
	return damage
end