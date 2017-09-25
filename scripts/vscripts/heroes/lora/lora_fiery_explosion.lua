lora_fiery_explosion = class({})
LinkLuaModifier( "modifier_lora_fiery_explosion", "heroes/lora/modifier_lora_fiery_explosion", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lora_fiery_explosion_debuff", "heroes/lora/modifier_lora_fiery_explosion_debuff", LUA_MODIFIER_MOTION_NONE )

function lora_fiery_explosion:GetIntrinsicModifierName()
	return "modifier_lora_fiery_explosion"
end

function lora_fiery_explosion:GetCastRange()
	local int_multiplier_prt = self:GetSpecialValueFor( "int_multiplier_prt" )
	return (int_multiplier_prt / 100.0) * self:GetCaster():GetMana()
end

function lora_fiery_explosion:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local mana = caster:GetMana()
		local int_multiplier_prt = self:GetSpecialValueFor( "int_multiplier_prt" )
		local maxRadius = (int_multiplier_prt / 100.0) * mana

		enemyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(),
					nil, maxRadius,
		    		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL,
		        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		 
		-- Make the found units move to (0, 0, 0)
		for _,unit in pairs(enemyUnits) do
		   --print( CalcDistanceBetweenEntityOBB(self:GetParent(), unit) )
		   local damage_prt = 1 - ( CalcDistanceBetweenEntityOBB(caster, unit) / maxRadius )
		   local damageTable = {
				victim = unit,
				attacker = caster,
				damage = maxRadius * damage_prt,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self
			}
			ApplyDamage( damageTable )
		end
		EmitSoundOn("Hero_Antimage.ManaVoid", caster )

		local degree = 5
		local info =
		{
			EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
			Ability = self,
			vSpawnOrigin = caster:GetAbsOrigin(),
			vVelocity = 0,
			fDistance = maxRadius,
			fStartRadius = 175,
			fEndRadius = 175,
			bHasFrontalCone = true,
			bReplaceExisting = false
		}
		for i=0,360/degree-1 do
			info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,degree*i,0), caster:GetForwardVector()) * maxRadius/0.2
			ProjectileManager:CreateLinearProjectile( info )
		end		

		caster:SetMana(0)
	end
end