function BarbedArmorReturn( event )
	local caster = event.caster
	local attacker = event.attacker
	local ability = event.ability 
	local damageType = ability:GetAbilityDamageType()
	local return_damage = ( ability:GetSpecialValueFor( "return_prt" ) / 100.0 ) * event.dealedDamage

	-- Damage
	if attacker:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({ victim = attacker, attacker = caster, damage = return_damage, damage_type = damageType })
		--print("done "..return_damage)
	end
end

function ProtectiveGear( keys )
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
	        EffectName = "particles/heroes/ti_15/protective_gear.vpcf",
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

	caster:EmitSoundParams("Hero_Rattletrap.Battery_Assault_Launch", 200.0, 200.0, 1.0)
    projectile_id = ProjectileManager:CreateLinearProjectile( projectileTable )
	end
end

function Suicide( event )
	--print("SDOHNI")
	event.caster:StopSound("Hero_TI_15.Self_Destruction.Cast")
	event.caster:EmitSound("Hero_TI_15.Self_Destruction.End")
	event.caster:Kill(event.ability, event.caster)
end

function SelfDestructionSound( event )
	event.caster:EmitSound("Hero_TI_15.Self_Destruction.Cast")
end

function StopSound( event )
	event.caster:StopSound("Hero_TI_15.Self_Destruction.Cast")
end