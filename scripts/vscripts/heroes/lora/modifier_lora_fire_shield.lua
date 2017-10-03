modifier_lora_fire_shield = class({})

function modifier_lora_fire_shield:OnCreated()
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.duration = self:GetAbility():GetSpecialValueFor("duration")

		self:SetDuration( self.duration, true )
		self:StartIntervalThink( 1.0 )
		local nFXIndex = ParticleManager:CreateParticle( "particles/heroes/lora/lora_fire_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl(nFXIndex, 1, Vector(70,70,0))
		ParticleManager:SetParticleControlEnt(nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle( nFXIndex, false, false, -1, false, false )
		EmitSoundOn("Hero_Phoenix.FireSpirits.Loop", self:GetParent())
	end
end

function modifier_lora_fire_shield:OnDestroy( )
	if IsServer() then
		print("END\n")
		self:GetParent():StopSound("Hero_Phoenix.FireSpirits.Loop")
	end
end

function modifier_lora_fire_shield:OnIntervalThink( )
	if IsServer() then
		local enemyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self:GetParent():GetAbsOrigin(),
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