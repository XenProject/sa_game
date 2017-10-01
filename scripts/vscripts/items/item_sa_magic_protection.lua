function ManaRecovery(event)
	local caster = event.caster
	local ability = event.ability
	local mana_min = ability:GetSpecialValueFor("mana_min")
	local mana_prt = ability:GetSpecialValueFor("mana_prt")
	local mana_recovery = caster:GetMaxMana() * (mana_prt / 100.0)
	if mana_recovery > mana_min then
		caster:GiveMana(mana_recovery)
	else
		caster:GiveMana(mana_min)
	end
end