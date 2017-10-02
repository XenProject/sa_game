modifier_vasya_regeneration = class({})

function modifier_vasya_regeneration:IsHidden()
	return true
end

function modifier_vasya_regeneration:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage") 
	self.attacks = 0
end

function modifier_vasya_regeneration:OnRefresh()
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_vasya_regeneration:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_vasya_regeneration:OnTakeDamage( event )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if event.unit == caster and event.attacker ~= caster and ability:IsCooldownReady() then
		self.attacks = self.attacks + 1
		if self.attacks == 5 then
			self.attacks = 0
			local damageTable = {
				victim = event.attacker,
				attacker = caster,
				damage = self.damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = ability
			}

			local particleName = "particles/heroes/vasya/vasya_regeneration.vpcf"	
			local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, event.attacker )

			ParticleManager:SetParticleControlEnt(particle, 0, event.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", event.attacker:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", event.attacker:GetAbsOrigin(), true)

			-- Show the particle target-> caster	
			local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )

			ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", event.attacker:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle, 1, event.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", event.attacker:GetAbsOrigin(), true)

			ApplyDamage(damageTable)
			caster:Heal(self.damage, caster)
			PopupHealing(caster, self.damage)
			ability:StartCooldown( ability:GetCooldown( ability:GetLevel() ) )
		end
	end
end