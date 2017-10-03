if IsClient() then return end

require('spec_arena/sa_gamemode')

function Spawn( entityKeyValues )
	ABILITY_necrolyte_reapers_scythe = thisEntity:FindAbilityByName("necrolyte_reapers_scythe")
	ABILITY_necrolyte_reapers_scythe:SetLevel(3)

	thisEntity:SetContextThink( "Boss_5", Boss_5 , 0.5)
end

function Boss_5()
	if not thisEntity:IsAlive() or thisEntity:IsIllusion() then
		return nil
	end

	if GameRules:IsGamePaused() then
		return 1
	end

	if ABILITY_necrolyte_reapers_scythe:IsFullyCastable() and SpecArena:GetHeroCount(false) > 1 then
		local enemyUnits = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(),
				nil, 700,
	    		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in pairs(enemyUnits) do
			if enemy:GetHealthPercent() < 45 then
				--print("CAST!!!!")
				thisEntity:CastAbilityOnTarget(enemy, ABILITY_necrolyte_reapers_scythe, -1)
				return 3.0
			end
		end
	end
	return 0.5
end