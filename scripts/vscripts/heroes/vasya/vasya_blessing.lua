function VasyaBlessing( keys )
	if keys.target:GetHealthPercent() == 100 then
		keys.target:RemoveModifierByName(keys.modifier)
	end
end