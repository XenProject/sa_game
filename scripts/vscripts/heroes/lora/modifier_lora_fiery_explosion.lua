modifier_lora_fiery_explosion = class({})

function modifier_lora_fiery_explosion:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_lora_fiery_explosion:IsAura()
	return true
end

function modifier_lora_fiery_explosion:GetModifierAura()
	return "modifier_lora_fiery_explosion_debuff"
end

function modifier_lora_fiery_explosion:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_lora_fiery_explosion:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_lora_fiery_explosion:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

--------------------------------------------------------------------------------

function modifier_lora_fiery_explosion:GetAuraRadius()
	return (self.int_multiplier_prt / 100.0) * self:GetParent():GetIntellect()
end

function modifier_lora_fiery_explosion:OnCreated( kv )
	self.int_multiplier_prt = self:GetAbility():GetSpecialValueFor( "int_multiplier_prt" )
end

function modifier_lora_fiery_explosion:OnRefresh( kv )
	self.int_multiplier_prt = self:GetAbility():GetSpecialValueFor( "int_multiplier_prt" )
end

--[[function modifier_lora_fiery_explosion:OnIntervalThink()
	if IsServer() then
		local int = self:GetParent():GetIntellect()
		local maxRadius = (self.int_multiplier_prt / 100.0) * int

		enemyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self:GetParent():GetAbsOrigin(),
					nil, maxRadius,
		    		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL,
		        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		 
		-- Make the found units move to (0, 0, 0)
		for _,unit in pairs(enemyUnits) do
		   --print( CalcDistanceBetweenEntityOBB(self:GetParent(), unit) )
		   local damage_prt = 1 - ( CalcDistanceBetweenEntityOBB(self:GetParent(), unit) / maxRadius )
		   local damageTable = {
				victim = unit,
				attacker = self:GetCaster(),
				damage = maxRadius * damage_prt,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self:GetAbility()
			}
			ApplyDamage( damageTable )
		end
	end
end]]