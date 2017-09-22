vasya_clear_sky = class({})

function vasya_clear_sky:GetAOERadius()
	return self:GetSpecialValueFor("max_radius")/2.0
end

function vasya_clear_sky:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local radius = RandomInt(0, self:GetSpecialValueFor("max_radius"))
	local damage = self:GetSpecialValueFor("damage")

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( nFXIndex, 0, point )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( radius, 1, 1 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	local enemyUnits = FindUnitsInRadius(caster:GetTeamNumber(), point,
				nil, radius,
	    		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local friendlyUnits = FindUnitsInRadius(caster:GetTeamNumber(), point,
				nil, radius,
	    		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for _,enemy in pairs(enemyUnits) do
		local damageTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}
		ApplyDamage(damageTable)
	end
	for _,unit in pairs(friendlyUnits) do
		unit:Heal(damage, caster)
		PopupHealing(unit, damage)
	end 
end