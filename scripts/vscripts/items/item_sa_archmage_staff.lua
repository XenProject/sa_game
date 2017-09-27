function Spawn( event )
	local caster = event.caster
	local playerID = caster:GetPlayerID()
	local ability = event.ability
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local damage = ability:GetSpecialValueFor("damage")

    local origin = caster:GetAbsOrigin()
    local target_point = event.target_points[1]

    local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_ursa/ursa_earthshock_soil1.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControl(nFXIndex, 0, target_point)

	Timers:CreateTimer( 0.3, function()
		nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_ursa/ursa_earthshock_rocks.vpcf", PATTACH_ABSORIGIN, caster ) 
	    ParticleManager:SetParticleControl(nFXIndex, 0, target_point)
	    nFXIndex = ParticleManager:CreateParticle( "particles/items/item_sa_archmage_staff/stone_explosion.vpcf", PATTACH_ABSORIGIN, caster ) 
	    ParticleManager:SetParticleControl(nFXIndex, 0, target_point)

		local unit = CreateUnitByName("rock_golem", target_point, true, caster, caster, caster:GetTeam())
	    unit:SetControllableByPlayer(playerID, false)
	    unit:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})
		ResolveNPCPositions(unit:GetAbsOrigin(),65)

		unit:EmitSound("Hero_EarthSpirit.RollingBoulder.Target")
		ability:ApplyDataDrivenModifier( unit, unit, "golem_disable", {duration = 0.8})
		StartAnimation(unit, {duration=0.8, activity=ACT_DOTA_CAST_ABILITY_3, rate=2.0})

		Timers:CreateTimer( 0.8, function()
			nFXIndex = ParticleManager:CreateParticle( "particles/items/item_sa_archmage_staff/dust_hit_ring.vpcf", PATTACH_ABSORIGIN, caster ) 
	    	ParticleManager:SetParticleControl(nFXIndex, 0, target_point)
	    	ParticleManager:SetParticleControl(nFXIndex, 1, Vector( radius,0,0 ))
	    	unit:EmitSound("Visage_Familar.StoneForm.Cast")

	    	local enemyUnits = FindUnitsInRadius( caster:GetTeamNumber(), unit:GetAbsOrigin(),
				nil, radius,
	    		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	    	for _,enemy in pairs(enemyUnits) do
	    		enemy:AddNewModifier(caster, nil, "modifier_stunned", {duration = stun_duration})
	    		local damageTable = {
	    			victim = enemy,
	    			attacker = caster,
	    			damage = damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = ability
	    		}
	    		ApplyDamage(damageTable)
	    	end
		end )
	end )    
end