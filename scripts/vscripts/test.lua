function Test(keys)
	print("PROC!!!!")
	print(keys.qwer)
end

function Test1()
	print("Attacked")
end

function Test2()
	print("TakenDamage")
end

function Ti15( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.attacker:GetAbsOrigin()
	local forwardVec = (target_point - caster_location):Normalized()

	-- If the caster has the helix modifier then do not trigger the counter helix
	-- as its considered to be on cooldown
	if target == caster then
		ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, modifier, {})
		local projectileTable =
	    {
	        EffectName = "particles/cog_test.vpcf",
	        Ability = ability,
	        vSpawnOrigin = caster_location,
	        vVelocity = Vector( forwardVec.x * 600, forwardVec.y * 600, 0 ),
	        fDistance = 500,
	        fStartRadius = 70,
	        fEndRadius = 70,
	        Source = caster,
	        bHasFrontalCone = false,
	        bReplaceExisting = false,
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	        iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	    }

    projectile_id = ProjectileManager:CreateLinearProjectile( projectileTable )
	end
end

function Ti15New( keys )
	local caster = keys.caster
    local caster_location = caster:GetAbsOrigin()
    local ability = keys.ability
    local target_point = keys.target_points[1]
    local forwardVec = (target_point - caster_location):Normalized()

    local projectileTable =
    {
        EffectName = "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf",
        Ability = ability,
        vSpawnOrigin = caster_location,
        vVelocity = Vector( forwardVec.x * 600, forwardVec.y * 600, 0 ),
        fDistance = 500,
        fStartRadius = 70,
        fEndRadius = 70,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
    }

    projectile_id = ProjectileManager:CreateLinearProjectile( projectileTable )
end