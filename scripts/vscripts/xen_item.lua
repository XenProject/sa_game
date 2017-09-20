xen_item = class ({})
LinkLuaModifier( "modifier_xen_item", "modifier_xen_item.lua", LUA_MODIFIER_MOTION_NONE )

function xen_item:GetIntrinsicModifierName()
    return "modifier_xen_item"
end