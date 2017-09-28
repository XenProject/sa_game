lora_fire_shield = class({})
LinkLuaModifier( "modifier_lora_fire_shield", "heroes/lora/modifier_lora_fire_shield", LUA_MODIFIER_MOTION_NONE )

function lora_fire_shield:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	target:AddNewModifier(caster, self, "modifier_lora_fire_shield", nil)
	caster:EmitSound("Hero_EmberSpirit.FireRemnant.Cast")
end