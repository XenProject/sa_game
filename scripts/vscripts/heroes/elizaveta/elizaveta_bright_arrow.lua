elizaveta_bright_arrow = class({})
LinkLuaModifier( "modifier_elizaveta_bright_arrow", "heroes/elizaveta/modifier_elizaveta_bright_arrow", LUA_MODIFIER_MOTION_NONE )

function elizaveta_bright_arrow:GetIntrinsicModifierName()
	return "modifier_elizaveta_bright_arrow"
end

function elizaveta_bright_arrow:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function elizaveta_bright_arrow:OnSpellStart()
	local info = {
			EffectName = "particles/heroes/elizaveta/elizaveta_bright_arrow.vpcf",
			Ability = self,
			iMoveSpeed = 950,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}

	ProjectileManager:CreateTrackingProjectile( info )
	--EmitSoundOn( "Hero_VengefulSpirit.MagicMissile", self:GetCaster() )
end

function elizaveta_bright_arrow:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) and ( not hTarget:IsMagicImmune() ) then
		local modifier = self:GetCaster():FindModifierByName("modifier_elizaveta_bright_arrow")
		local radius = self:GetSpecialValueFor("radius")

		--EmitSoundOn( "Hero_VengefulSpirit.MagicMissileImpact", hTarget )

		local damageTable = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self:GetSpecialValueFor("damage_base")+(modifier:GetStackCount()*self:GetSpecialValueFor("damage_per_stack")),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage(damageTable)
		if not hTarget:IsAlive() then
			enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), hTarget:GetAbsOrigin(),
				nil, radius,
	    		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			for _,enemy in pairs(enemies) do
				damageTable.victim = enemy
				damageTable.damage = self:GetSpecialValueFor("expl_damage_base")+(modifier:GetStackCount()*self:GetSpecialValueFor("expl_damage_per_stack"))
				ApplyDamage( damageTable )
			end
			modifier:IncrementStackCount()
		end
	end

	return true
end