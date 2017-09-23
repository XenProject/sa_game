if not SpecArena then
    SpecArena = {}
end

GAME_ROUND = 0 -- номер текущего раунда
MAX_ROUNDS = 2 -- номер конечного раунда
ROUND_UNITS = 20 -- кол-во юнитов на 1 раунде

function SpecArena:Init()
	_G.ALL_HEROES = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0),
				nil, FIND_UNITS_EVERYWHERE,
	    		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	_G.ARENA_MID = Entities:FindByName(nil, "arena_mid"):GetAbsOrigin()
	_G.SHOP_MID = Entities:FindByName(nil, "shop_mid"):GetAbsOrigin()
	_G.SPAWN_1 = Entities:FindByName(nil, "spawn_1"):GetAbsOrigin()

	Timers:CreateTimer(15, function() 
		self:SpawnWaveUnits()
		return nil 
	end)
end

function SpecArena:SpawnWaveUnits()
	GAME_ROUND = GAME_ROUND + 1
	--Say(nil,"Wave № ".. GAME_ROUND, false)
	for i=1, ROUND_UNITS do
	  local unit = CreateUnitByName( "wave_unit_" .. GAME_ROUND, SPAWN_1 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	  --unit:SetInitialGoalEntity( waypoint )
	end
	for _,hero in pairs(ALL_HEROES) do
		hero:SetAbsOrigin(ARENA_MID)
		FindClearSpaceForUnit(hero, ARENA_MID, false)
	end
	return nil
end