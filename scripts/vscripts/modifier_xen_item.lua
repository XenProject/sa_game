modifier_xen_item = class({})

function modifier_xen_item:IsHidden()
    return true
end

function modifier_xen_item:OnCreated( kv )
	if IsServer() then
		self:GetParent():ModifyAgility(20.0)
	end
end

function modifier_xen_item:OnDestroy( kv )
	if IsServer() then
		self:GetParent():ModifyAgility(-20.0)
	end
end