if not SpecArena then
    _G.SpecArena = class({})
end

_G.GAME_ROUND = 1 -- номер текущего раунда
_G.MAX_ROUNDS = 10 -- номер конечного раунда
_G.ROUND_UNITS = 36 -- кол-во юнитов на 1 раунде
_G.UNITS_LEFT = 0
_G.READY_PLAYERS = 0

_G.STATE_PRE_ROUND_TIME = 1
_G.STATE_PRE_DUEL_TIME = 2
_G.STATE_ROUND_WAVE = 3
_G.STATE_ROUND_MEGABOSS = 4
_G.STATE_ROUND_FINALBOSS = 5
_G.STATE_DUEL_TIME = 6

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

	_G.All_PLAYERS = {}

	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
    	if PlayerResource:IsValidPlayerID(playerID) then
    		table.insert(All_PLAYERS, PlayerResource:GetPlayer(playerID) )
    	end
    end

	CustomGameEventManager:RegisterListener("timer_end", Dynamic_Wrap(SpecArena, "SpawnWaveUnits") )

	self.State = STATE_PRE_ROUND_TIME
	StartTimer(15,self.State,GAME_ROUND)
end

function SpecArena:SpawnWaveUnits()
	SpecArena.State = STATE_ROUND_WAVE
	for i=1, ROUND_UNITS do
		if i%3 == 0 then 
	  		local unit = CreateUnitByName( "wave_unit_" .. GAME_ROUND, SPAWN_3 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	  	elseif	i%2 == 0 then
	  		local unit = CreateUnitByName( "wave_unit_" .. GAME_ROUND, SPAWN_2 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	  	else
	  		local unit = CreateUnitByName( "wave_unit_" .. GAME_ROUND, SPAWN_1 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	  	end
	end

	SpecArena:TeleportHeroes(ARENA_MID)
	UNITS_LEFT = ROUND_UNITS
end

function SpecArena:WaveEnd()
	self:ChangeState(STATE_PRE_ROUND_TIME)
	self:TeleportHeroes(SHOP_MID)

	StartTimer(30,self.State,GAME_ROUND)
end

function SpecArena:TeleportHeroes( point )
	for _,hero in pairs(ALL_HEROES) do
		if hero:IsAlive() then
			hero:Heal(hero:GetMaxHealth(), nil)
		else
			hero:RespawnUnit()
		end
		hero:SetAbsOrigin(point)
		FindClearSpaceForUnit(hero, point, false)
		hero:Stop()
		PlayerResource:SetCameraTarget(hero:GetPlayerID(), hero )
		SendToConsole("dota_camera_center")
		PlayerResource:SetCameraTarget(hero:GetPlayerID(), nil )
	end
end

function SpecArena:CheckReadyPlayers()
	if READY_PLAYERS == PlayerResource:GetPlayerCount() and self.State == STATE_PRE_ROUND_TIME then
		SetTimeLeft(3)
	end
end

function SpecArena:ChangeState( state )
	if state == STATE_PRE_ROUND_TIME then
		self.State = state
		READY_PLAYERS = 0
		GAME_ROUND = GAME_ROUND + 1
		for _,player in pairs(All_PLAYERS) do
			player.bFirstVote = nil
		end
	end
end

function SpecArena:Distance( v1, v2 )
	return math.sqrt( math.pow( (v1.x-v2.x), 2) + math.pow( (v1.y-v2.y), 2) )
end