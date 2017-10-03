garp_spear = class({})
LinkLuaModifier( "modifier_stun", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_garp_bleeding", "heroes/garp/modifier_garp_bleeding", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function garp_spear:GetAOERadius()
	return self:GetSpecialValueFor( "radius_burst" )
end


function garp_spear:OnSpellStart()
	StartAnimation(self:GetCaster(), {duration=0.5, activity=ACT_DOTA_CAST_GHOST_SHIP, rate=1.0})
	local info = {
			EffectName = "particles/heroes/garp/garp_spear.vpcf",
			Ability = self,
			iMoveSpeed = 1000,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}
	ProjectileManager:CreateTrackingProjectile( info )
	EmitSoundOn( "Hero_PhantomLancer.PreAttack", self:GetCaster() )
end

--------------------------------------------------------------------------------

function garp_spear:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
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
			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_stun", { duration = duration_stun } )
			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_garp_bleeding", nil)
			ApplyDamage( damage )

			EmitSoundOn( "Hero_PhantomLancer.Attack", hTarget )
		end
	end
	return true
end