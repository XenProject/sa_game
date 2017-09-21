modifier_lora_fiery_explosion_debuff = class({})

function modifier_lora_fiery_explosion_debuff:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_lora_fiery_explosion_debuff:OnCreated( kv )
	self.int_multiplier_prt = self:GetAbility():GetSpecialValueFor( "int_multiplier_prt" )
	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/radiance_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	--ParticleManager:SetParticleControlForward(nFXIndex, 0, (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized() )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
	if IsServer() then
		self:StartIntervalThink( 1.0 )
		self:OnIntervalThink()
	end
end

--------------------------------------------------------------------------------

function modifier_lora_fiery_explosion_debuff:OnRefresh( kv )
	self.int_multiplier_prt = self:GetAbility():GetSpecialValueFor( "int_multiplier_prt" )
end

function modifier_lora_fiery_explosion_debuff:OnIntervalThink()
	if IsServer() then
		local int = self:GetCaster():GetIntellect()
		local maxRadius = (self.int_multiplier_prt / 100.0) * int

		--local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/radiance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		--ParticleManager:SetParticleControl(nFXIndex, 0, self:GetCaster():GetAbsOrigin())
		--self:AddParticle( nFXIndex, false, false, -1, false, false )

		local damage_prt = 1 - ( CalcDistanceBetweenEntityOBB(self:GetCaster(), self:GetParent()) / maxRadius )
		local damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = maxRadius * damage_prt,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
		}
		ApplyDamage( damageTable )
	end
end