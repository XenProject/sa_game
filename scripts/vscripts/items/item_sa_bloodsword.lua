function BloodSword( event )
	local caster = event.caster
	local ability = event.ability
	local health_prt = ability:GetSpecialValueFor("health_prt")
	local health_min = ability:GetSpecialValueFor("health_min")
	local heal_amount = caster:GetMaxHealth() * (health_prt/100.0)
	if heal_amount > health_min then
		caster:Heal( heal_amount, caster )
		PopupHealing( caster, heal_amount )
	else
		caster:Heal( health_min, caster )
		PopupHealing( caster, health_min )
	end
end