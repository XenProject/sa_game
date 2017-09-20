modifier_garp_instant_hit = class ({})

function modifier_garp_instant_hit:IsHidden()
    return true
end

function modifier_garp_instant_hit:OnCreated( kv )
	self.chance = self:GetAbility():GetSpecialValueFor( "chance" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.agi_multiplier_prt = self:GetAbility():GetSpecialValueFor( "agi_multiplier_prt" )
	self.vamp_prt = self:GetAbility():GetSpecialValueFor( "vamp_prt" )
end

function modifier_garp_instant_hit:OnRefresh( kv )
	self.chance = self:GetAbility():GetSpecialValueFor( "chance" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.agi_multiplier_prt = self:GetAbility():GetSpecialValueFor( "agi_multiplier_prt" )
	self.vamp_prt = self:GetAbility():GetSpecialValueFor( "vamp_prt" )
end

function modifier_garp_instant_hit:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_garp_instant_hit:OnAttackLanded( params )
	if IsServer() and RollPercentage(self.chance) then
		if params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then
			if self:GetParent():PassivesDisabled() then
				return 0
			end

			local target = params.target
			if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
				local cleaveDamage = ( self.agi_multiplier_prt / 100.0 ) * self:GetParent():GetAgility() + self.damage
				ApplyDamage( { victim = target, attacker = self:GetParent(), damage = cleaveDamage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self:GetAbility()} )
				DoCleaveAttack( self:GetParent(), target, self:GetAbility(), cleaveDamage, self.radius, 100, self.radius, "particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf" )
				self:GetParent():Heal( cleaveDamage * (self.vamp_prt/100.0), self:GetParent())
			end
		end
	end
	
	return 0
end