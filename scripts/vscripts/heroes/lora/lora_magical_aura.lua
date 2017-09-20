function ManaThreshold( event )
	local target = event.target
	local threshold = event.caster:GetMaxMana() / event.ability:GetSpecialValueFor("mana_threshold_prt")
	if target:GetMana() < threshold then
		target:SetMana( threshold )
	end
end