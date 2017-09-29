if not Lightning then
	Lightning = class({})
	Lightning.bounces = 1
end

function Lightning( event )
	local maxBounces = event.ability:GetSpecialValueFor("maxBounces")
	if Lightning.bounces < maxBounces then
		local caster  = event.caster
		local target = event.target
		local ability = event.ability

		local targets = FindUnitsInRadius(caster:GetTeamNumber(), target,
				nil, 400,
	    		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		local info = {
			EffectName = "particles/items_fx/chain_lightning.vpcf",
			Ability = ability,
			iMoveSpeed = 1000,
			Source = target,
			Target = targets[1],
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}
		ProjectileManager:CreateTrackingProjectile( info )

		local damageTable = {
			victim = targets[1],
			attacker = caster,
			damage = ability:GetSpecialValueFor("lightning_damage") ,
			damage_type = DAMAGE_TYPE_PURE,
			ability = ability
		}
		ApplyDamage(damageTable)
		Lightning.bounces = Lightning.bounces + 1
	else
		Lightning.bounces = 1
	end
end