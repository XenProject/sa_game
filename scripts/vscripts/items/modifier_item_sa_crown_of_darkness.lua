modifier_item_sa_crown_of_darkness = class({})

function modifier_item_sa_crown_of_darkness:GetAttributes() 
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_item_sa_crown_of_darkness:IsHidden()
	return true 
end

function modifier_item_sa_crown_of_darkness:IsPurgable()
	return false
end

function modifier_item_sa_crown_of_darkness:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}
	return funcs
end

function modifier_item_sa_crown_of_darkness:OnCreated(kv)
	self.blockDamage = self:GetAbility():GetSpecialValueFor("damage_blocked")
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor") 
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbility():GetSpecialValueFor("bonus_mana")
	
	if IsServer() then
		self.pseudo = PseudoRandom:New(self:GetAbility():GetSpecialValueFor("chance")*0.01)
	end
end

function modifier_item_sa_crown_of_darkness:GetModifierPhysical_ConstantBlock(params)
	if not params.inflictor and params.record ~= 11200 and self.pseudo:Trigger() then
		--print(self.blockDamage)
		return self.blockDamage 
	end
end

function modifier_item_sa_crown_of_darkness:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_item_sa_crown_of_darkness:GetModifierHealthBonus()
	return self.bonus_health
end

function modifier_item_sa_crown_of_darkness:GetModifierManaBonus()
	return self.bonus_mana
end