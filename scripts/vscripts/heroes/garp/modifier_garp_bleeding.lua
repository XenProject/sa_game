modifier_garp_bleeding = class({})

function modifier_garp_bleeding:IsDebuff()
    return true
end

function modifier_garp_bleeding:DeclareFunctions()
	local funcs =
	{
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_garp_bleeding:OnCreated( kv )
	if IsServer() then
		self.agi_multiplier_prt = self:GetAbility():GetSpecialValueFor("agi_multiplier_prt")
		self.chance_stop = self:GetAbility():GetSpecialValueFor("chance_stop")
		self.radius_burst = self:GetAbility():GetSpecialValueFor("radius_burst")
		self.damage_burst = self:GetAbility():GetSpecialValueFor("damage_burst")

		self.damagePerTick = (self.agi_multiplier_prt/100.0) * self:GetCaster():GetAgility()

		self:StartIntervalThink( 1.0 )
		self:OnIntervalThink()
	end
end

function modifier_garp_bleeding:OnIntervalThink()
	if IsServer() then
		local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.damagePerTick,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			ability = self:GetAbility()
		}
		ApplyDamage( damage )

		local particle = ParticleManager:CreateParticle( "particles/heroes/garp/garp_spear_bleeding.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())

		if RollPercentage(self.chance_stop) then
			self:GetParent():RemoveModifierByName( self:GetName() )
		end
	end
end

function modifier_garp_bleeding:OnDeath( params )
	if params.unit == self:GetParent() then
		local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl(particle, 1, Vector(250,0,0))
		
		particle = ParticleManager:CreateParticle( "particles/heroes/garp/garp_spear_burst.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl(particle, 1, Vector(250,0,0))

		EmitSoundOn("Ability.SandKing_CausticFinale", params.unit)

		local enemyUnits = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(),
				nil, self.radius_burst,
	    		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	 
		-- Make the found units move to (0, 0, 0)
		for _,unit in pairs(enemyUnits) do
		   unit:AddNewModifier(self:GetCaster(), self:GetAbility(), self:GetName(), nil)
		   local damage = {
				victim = unit,
				attacker = self:GetCaster(),
				damage = self.damage_burst,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self:GetAbility()
			}
			ApplyDamage( damage )
		end
	end
end