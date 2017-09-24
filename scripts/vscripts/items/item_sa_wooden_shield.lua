item_sa_wooden_shield = class({})
LinkLuaModifier("modifier_item_sa_wooden_shield", "items/modifier_item_sa_wooden_shield", LUA_MODIFIER_MOTION_NONE)

function item_sa_wooden_shield:GetIntrinsicModifierName() 
	return "modifier_item_sa_wooden_shield"
end