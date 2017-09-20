modifier_lora_fire_shield = class({})

function modifier_lora_fire_shield:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")

	self:SetDuration( self.duration, true )
	self:StartIntervalThink( 1.0 )
end

function modifier_lora_fire_shield:OnIntervalThink( )
	if IsServer() then
		enemyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self:GetParent():GetAbsOrigin(),
				nil, self.radius,
	    		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		for _,unit in pairs(enemyUnits) do
		   local damageTable = {
				victim = unit,
				attacker = self:GetCaster(),
				damage = self.damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self:GetAbility()
			}
			ApplyDamage( damageTable )
		end
		self:GetParent():Heal( self.damage, self:GetCaster() )

		self.damage = self.damage * 2
	end
end