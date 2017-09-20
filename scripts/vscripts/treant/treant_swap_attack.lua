function RangeAttack( event )
	local hero = EntIndexToHScript(event.caster_entindex)
	hero:SetRangedProjectileName("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_base_attack.vpcf");
	hero:SetAttackCapability(2);
end

function MeleeAttack( event )
	local hero = EntIndexToHScript(event.caster_entindex)
	hero:SetAttackCapability(1);
end