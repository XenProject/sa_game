elay_energy_ball = class({})

function elay_energy_ball:OnSpellStart()
	self.jump_counter = 0
	self.ms = 1000

	local info = {
			EffectName = "particles/heroes/elay/elay_energy_ball.vpcf",
			Ability = self,
			iMoveSpeed = self.ms,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}
	ProjectileManager:CreateTrackingProjectile( info )
	--EmitSoundOn( "Hero_VengefulSpirit.MagicMissile", self:GetCaster() )
end

function elay_energy_ball:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) and ( not hTarget:IsMagicImmune() ) then
		--EmitSoundOn( "Hero_VengefulSpirit.MagicMissileImpact", hTarget )
		local damage = self:GetSpecialValueFor("damage")
		local jumps = self:GetSpecialValueFor("bounce_count") + self:GetCaster():GetAbilityByIndex(3):GetSpecialValueFor("bonus_bounces")
		local damageInt = (self:GetCaster():GetAbilityByIndex(2):GetSpecialValueFor("int_multiplier_prt") / 100.0) * self:GetCaster():GetIntellect()

		local damageTable = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = damage * 2 + damageInt,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}
		ApplyDamage( damageTable )
		targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, hTarget:GetAbsOrigin(),
				nil, self:GetSpecialValueFor("radius"),
	    		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		self:CheckUpgrade1()

		if not self.jump_counter then
			self.jump_counter = 0
		end

		if self.jump_counter <= jumps then

			local target_to_jump = nil
			for _,target in pairs(targets) do
				if target ~= hTarget then
					local damageTableAoE = {
						victim = target,
						attacker = self:GetCaster(),
						damage = damage + damageInt,
						damage_type = DAMAGE_TYPE_MAGICAL,
						ability = self
					}
					ApplyDamage( damageTableAoE )
					if not target_to_jump then
						target_to_jump = target
					end
				end
			end

			if target_to_jump then
				--print("Bounce number "..self.jump_counter)
				-- Create the next projectile
				local info = {
					Target = target_to_jump,
					Source = hTarget,
					Ability = self,
					EffectName = "particles/heroes/elay/elay_energy_ball.vpcf",
					iMoveSpeed = self.ms,
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
				}
				ProjectileManager:CreateTrackingProjectile( info )

				-- Add one to the jump counter for this bounce
				self.jump_counter = self.jump_counter + 1
			else
				--print("Can't find a target, End Chain")
				self.jump_counter = nil
			end
		end
	end

	return true
end

function elay_energy_ball:CheckUpgrade1()
	local ability2 = self:GetCaster():GetAbilityByIndex(1);
	local ability2_modifier = self:GetCaster():FindModifierByName( ability2:GetIntrinsicModifierName() )

	if RollPercentage( ability2:GetSpecialValueFor("chance")) then
		ability2_modifier:SetStackCount( ability2_modifier:GetStackCount() + 1 )
		ability2_modifier:ForceRefresh()
	end
end