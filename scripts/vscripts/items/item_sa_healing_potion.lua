item_sa_healing_potion = class({})

function item_sa_healing_potion:CastFilterResult()
	if self:GetCaster():GetHealthPercent() == 100 then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end

function item_sa_healing_potion:GetCustomCastError()
	return "sa_hud_error_healing_elixir_full_hp"
end

function item_sa_healing_potion:OnSpellStart()
	self:GetCaster():Heal(self:GetSpecialValueFor("heal_amount"), self)

	local particle = ParticleManager:CreateParticle("particles/items_fx/healing_flask.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	Timers:CreateTimer(1, function()
		ParticleManager:DestroyParticle(particle,false)
		ParticleManager:ReleaseParticleIndex(particle)
	end)
	
	self:SetCurrentCharges(self:GetCurrentCharges()-1)
	if self:GetCurrentCharges() == 0 then
		self:RemoveSelf()
	end
end