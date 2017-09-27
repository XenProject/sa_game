function Blink( event )
	local caster = event.caster
	local ability = event.ability

	caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	local nFXIndex = ParticleManager:CreateParticle( "particles/econ/events/fall_major_2016/blink_dagger_start_fm06.vpcf", PATTACH_ABSORIGIN, caster )
	
	local origin_point = caster:GetAbsOrigin()
	local target_point = event.target_points[1]
	local difference_vector = target_point - origin_point
	
	if difference_vector:Length2D() > event.maxRange then  --Clamp the target point to the BlinkRangeClamp range in the same direction.
		target_point = origin_point + (target_point - origin_point):Normalized() * event.maxRange
	end
	
	caster:SetAbsOrigin(target_point)
	FindClearSpaceForUnit(caster, target_point, false)

	nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/enchantress/enchantress_lodestar/ench_death_lodestar_flower.vpcf", PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl(nFXIndex, 0, caster:GetAbsOrigin())

	local enemyUnits = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
				nil, event.radius,
	    		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for _,enemy in pairs(enemyUnits) do
		ability:ApplyDataDrivenModifier(caster, enemy, "modifier_sa_forest_boots_root", nil)
	end
end