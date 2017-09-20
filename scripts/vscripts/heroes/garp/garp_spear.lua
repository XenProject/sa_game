garp_spear = class({})
LinkLuaModifier( "modifier_stun", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_garp_bleeding", "heroes/garp/modifier_garp_bleeding", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function garp_spear:OnSpellStart()
	local info = {
			EffectName = "particles/econ/items/phantom_lancer/phantom_lancer_immortal_ti6/phantom_lancer_immortal_ti6_spiritlance.vpcf",
			Ability = self,
			iMoveSpeed = 900,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}
	ProjectileManager:CreateTrackingProjectile( info )
	--EmitSoundOn( "Hero_VengefulSpirit.MagicMissile", self:GetCaster() )
end

--------------------------------------------------------------------------------

function garp_spear:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) and ( not hTarget:IsMagicImmune() ) then
		--EmitSoundOn( "Hero_VengefulSpirit.MagicMissileImpact", hTarget )
		local duration_stun = self:GetSpecialValueFor( "duration_stun" )
		local totalDamage = self:GetCaster():GetAgility()*self:GetSpecialValueFor("agi_multiplier") + self:GetSpecialValueFor("damage")

		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = totalDamage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			ability = self
		}
		ApplyDamage( damage )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_stun", { duration = duration_stun } )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_garp_bleeding", nil)
	end

	return true
end