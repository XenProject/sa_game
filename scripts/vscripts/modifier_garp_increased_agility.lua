modifier_garp_increased_agility = class ({})

function modifier_garp_increased_agility:IsHidden()
    return true
end

function modifier_garp_increased_agility:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS
	}
	return funcs
end

function modifier_garp_increased_agility:OnCreated( kv )
	self.agi_bonus_prt = self:GetAbility():GetSpecialValueFor( "agi_bonus_prt" )
	if IsServer() then
		self:GetParent():CalculateStatBonus()
	end
end

function modifier_garp_increased_agility:OnRefresh( kv )
	self.agi_bonus_prt = self:GetAbility():GetSpecialValueFor( "agi_bonus_prt" )
	if IsServer() then
		self:GetParent():CalculateStatBonus()
	end
end

function modifier_garp_increased_agility:GetModifierBonusStats_Agility( params )
	return (self.agi_bonus_prt/100.0) * self:GetParent():GetBaseAgility()
end