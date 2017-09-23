if not SpecArena then
    SpecArena = {}
end

GAME_ROUND = 0 -- номер текущего раунда
MAX_ROUNDS = 2 -- номер конечного раунда
ROUND_UNITS = 20 -- кол-во юнитов на 1 раунде
UNITS_LEFT = 0

function SpecArena:Init()
	_G.ALL_HEROES = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0),
				nil, FIND_UNITS_EVERYWHERE,
	    		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	_G.ARENA_MID = Entities:FindByName(nil, "arena_mid"):GetAbsOrigin()
	_G.SHOP_MID = Entities:FindByName(nil, "shop_mid"):GetAbsOrigin()
	_G.SPAWN_1 = Entities:FindByName(nil, "spawn_1"):GetAbsOrigin()
	_G.SPAWN_2 = Entities:FindByName(nil, "spawn_2"):GetAbsOrigin()
	_G.SPAWN_3 = Entities:FindByName(nil, "spawn_3"):GetAbsOrigin()

	self:SpawnWaveUnits(15)
end

function SpecArena:SpawnWaveUnits(delay)
	Timers:CreateTimer(delay, function() 
		GAME_ROUND = GAME_ROUND + 1
		for i=1, ROUND_UNITS do
			if i%3 == 0 then 
		  		local unit = CreateUnitByName( "wave_unit_" .. GAME_ROUND, SPAWN_3 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		  	elseif	i%2 == 0 then
		  		local unit = CreateUnitByName( "wave_unit_" .. GAME_ROUND, SPAWN_2 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		  	else
		  		local unit = CreateUnitByName( "wave_unit_" .. GAME_ROUND, SPAWN_1 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		  	end
		end
		self:TeleportHeroes(ARENA_MID)
		UNITS_LEFT = ROUND_UNITS
	end)
end

function SpecArena:WaveEnd()
	self:TeleportHeroes(SHOP_MID)
	self:SpawnWaveUnits(30)
end

function SpecArena:TeleportHeroes( point )
	for _,hero in pairs(ALL_HEROES) do
		hero:Heal(hero:GetMaxHealth(), nil)
		hero:SetAbsOrigin(point)
		FindClearSpaceForUnit(hero, point, false)
		hero:Stop()
		PlayerResource:SetCameraTarget(hero:GetPlayerID(), hero )
		SendToConsole("dota_camera_center")
		PlayerResource:SetCameraTarget(hero:GetPlayerID(), nil )
	end
end