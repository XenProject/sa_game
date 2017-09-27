vasya_rescue = class({})

function vasya_rescue:OnSpellStart()
	local caster = self:GetCaster()
	local target_type = self:GetAbilityTargetType()
	local healAmount = (self:GetSpecialValueFor("max_health_prt") / 100) * caster:GetMaxHealth()

	local friendlyHeroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
				nil, FIND_UNITS_EVERYWHERE,
	    		DOTA_UNIT_TARGET_TEAM_FRIENDLY, target_type,
	        	DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

	caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast")

	for _,hero in pairs(friendlyHeroes) do
		if hero ~= caster then
			local nFXIndex = ParticleManager:CreateParticle( "particles/heroes/vasya/vasya_rescue.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
			hero:Heal(healAmount, caster)
			PopupHealing(hero, healAmount)
		end
	end
end