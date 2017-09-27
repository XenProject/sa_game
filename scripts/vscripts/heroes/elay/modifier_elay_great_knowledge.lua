modifier_elay_great_knowledge = class({})

function modifier_elay_great_knowledge:OnCreated( kv )
	self.int_bonus = self:GetAbility():GetSpecialValueFor( "int_bonus" )
	if IsServer() then
		self.pseudo = PseudoRandom:New(self:GetAbility():GetSpecialValueFor("chance")*0.01)
		self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()
	end
end

function modifier_elay_great_knowledge:OnRefresh( kv )
	self.int_bonus = self:GetAbility():GetSpecialValueFor( "int_bonus" )
	if IsServer() then
		self.pseudo = PseudoRandom:New(self:GetAbility():GetSpecialValueFor("chance")*0.01)
		self:GetParent():CalculateStatBonus()
	end
end

function modifier_elay_great_knowledge:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}

	return funcs
end

function modifier_elay_great_knowledge:GetModifierBonusStats_Intellect( params )
	return self:GetStackCount() * self.int_bonus
end