modifier_garp_agression = class ({})

function modifier_garp_agression:IsHidden()
    return true
end

function modifier_garp_agression:OnCreated( kv )
	self.mod_agi = 0
	self.agi_multiplier = self:GetAbility():GetSpecialValueFor( "agi_multiplier" )
	self.agi_bonus = self:GetAbility():GetSpecialValueFor( "agi_bonus" )

	if IsServer() then	
		self:StartIntervalThink(0.1)
	end
end

function modifier_garp_agression:OnIntervalThink()
	if IsServer() then
		self:CalculateModAgi()
	end
end

function modifier_garp_agression:OnRefresh( kv )
	if IsServer() then
		if self.agi_bonus ~= self:GetAbility():GetSpecialValueFor( "agi_bonus" ) then
			self:GetParent():ModifyAgility( -self.agi_bonus )
		end
		self.agi_bonus = self:GetAbility():GetSpecialValueFor( "agi_bonus" )
		self:GetParent():ModifyAgility( self.agi_bonus )

		self.agi_multiplier = self:GetAbility():GetSpecialValueFor( "agi_multiplier" )
	end
end

function modifier_garp_agression:CalculateModAgi()
	self:GetParent():ModifyAgility( -self.mod_agi )
	self.mod_agi = (100 - self:GetParent():GetHealthPercent() ) * self.agi_multiplier
	self:GetParent():ModifyAgility( self.mod_agi )
end