modifier_item_sa_wooden_shield = class({})

function modifier_item_sa_wooden_shield:GetAttributes() 
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_item_sa_wooden_shield:IsHidden()
	return true 
end

function modifier_item_sa_wooden_shield:IsPurgable()
	return false
end

function modifier_item_sa_wooden_shield:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}
	return funcs
end

function modifier_item_sa_wooden_shield:OnCreated(kv)
	self.blockDamage = self:GetAbility():GetSpecialValueFor("damage_blocked")
	
	if IsServer() then
		self.pseudo = PseudoRandom:New(self:GetAbility():GetSpecialValueFor("chance")*0.01)
	end
end

function modifier_item_sa_wooden_shield:GetModifierPhysical_ConstantBlock(params)
	if not params.inflictor and params.record ~= 11200 and self.pseudo:Trigger() then 
		return self.blockDamage 
	end
end