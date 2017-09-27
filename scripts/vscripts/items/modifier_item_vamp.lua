modifier_item_vamp = class({})

function modifier_item_vamp:IsHidden()
	return true
end

function modifier_item_vamp:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_item_vamp:OnCreated(keys)
	--print(keys.vamp_prt)
	self.vamp_prt = keys.vamp_prt
end

function modifier_item_vamp:OnAttackLanded(keys)
	--PrintTable(keys)
	if keys.attacker == self:GetParent() then
		--print(self.vamp_prt)
		local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_OVERHEAD_FOLLOW, keys.attacker )
		PopupHealing( keys.attacker, keys.damage * (self.vamp_prt/100.0) )
		keys.attacker:Heal( keys.damage * (self.vamp_prt/100.0), keys.attacker )
	end
	return 0
end