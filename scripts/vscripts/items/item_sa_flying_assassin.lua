function HealOnDeath( event )
	local deathUnit = event.unit
	local attacker = event.attacker
	if deathUnit ~= attacker and attacker ==  event.caster then
		local healAmount = deathUnit:GetMaxHealth()*( event.ability:GetSpecialValueFor("heal_prt")/100.0 )
		attacker:Heal( healAmount, attacker )
		PopupHealing( attacker, healAmount )
	end
end