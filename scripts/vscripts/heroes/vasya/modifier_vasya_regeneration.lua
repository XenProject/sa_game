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
	self.attacks = self.attacks + 1
	if self.attacks == 5 then
		self.attacks = 0
		local damageTable = {
			victim = event.attacker,
			attacker = caster,
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
		}
		ApplyDamage(damageTable)
		caster:Heal(self.damage, caster)
		PopupHealing(caster, self.damage)
	end
end