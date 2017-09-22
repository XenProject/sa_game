modifier_elizaveta_bright_arrow = class({})

function modifier_elizaveta_bright_arrow:IsHidden()
	if self:GetStackCount() > 0 then
		return false
	else
		return true
	end
end