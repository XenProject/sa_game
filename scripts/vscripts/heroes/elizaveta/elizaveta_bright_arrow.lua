elizaveta_bright_arrow = clas({})
LinkLuaModifier( "modifier_elizaveta_bright_arrow", "heroes/elizaveta/modifier_elizaveta_bright_arrow", LUA_MODIFIER_MOTION_NONE )

function elizaveta_bright_arrow:GetIntrinsicModifierName()
	return "modifier_elizaveta_bright_arrow"
end

function elizaveta_bright_arrow:OnSpellStart()
	local info = {
			EffectName = "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
			Ability = self,
			iMoveSpeed = 950,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}

	ProjectileManager:CreateTrackingProjectile( info )
	--EmitSoundOn( "Hero_VengefulSpirit.MagicMissile", self:GetCaster() )
end

function vengefulspirit_magic_missile_lua:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) and ( not hTarget:IsMagicImmune() ) then
		--EmitSoundOn( "Hero_VengefulSpirit.MagicMissileImpact", hTarget )
		local damage = self:GetSpecialValueFor("damage_base")+(self:GetCaster():FindModifierByName("modifier_elizaveta_bright_arrow"):GetStackCount()*self:GetSpecialValueFor("damage_per_stack"))

		local damageTable = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = magic_missile_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage(damageTable)
	end

	return true
end