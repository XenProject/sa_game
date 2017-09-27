if not SpecArena then
    SpecArena = class({})
end

_G.STATE_PRE_ROUND_TIME = 1
_G.STATE_PRE_DUEL_TIME = 2
_G.STATE_ROUND_WAVE = 3
_G.STATE_ROUND_MEGABOSS = 4
_G.STATE_ROUND_FINALBOSS = 5
_G.STATE_DUEL_TIME = 6

function SpecArena:Init()
	self.allHeroes = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0),
				nil, FIND_UNITS_EVERYWHERE,
	    		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,
	        	DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	_G.ARENA_MID = Entities:FindByName(nil, "arena_mid"):GetAbsOrigin()
	_G.SHOP_MID = Entities:FindByName(nil, "shop_mid"):GetAbsOrigin()
	_G.SPAWN_1 = Entities:FindByName(nil, "spawn_1"):GetAbsOrigin()
	_G.SPAWN_2 = Entities:FindByName(nil, "spawn_2"):GetAbsOrigin()
	_G.SPAWN_3 = Entities:FindByName(nil, "spawn_3"):GetAbsOrigin()

	self.allPlayers = {}

	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
    	if PlayerResource:IsValidPlayerID(playerID) then
    		table.insert(self.allPlayers, PlayerResource:GetPlayer(playerID) )
    	end
    end

    self.State = STATE_PRE_ROUND_TIME
    self.currentGameRound = 1
    self.roundCreeps = 36
    self.roundKillers = 12
    self.unitsLeft = 0
    self.readyPlayers = 0

	CustomGameEventManager:RegisterListener("timer_end", Dynamic_Wrap(SpecArena, "SpawnWaveUnits") )

	StartTimer(20,self.State, self.currentGameRound)
end

function SpecArena:SpawnWaveUnits()
	SpecArena.State = STATE_ROUND_WAVE
	SpecArena.unitsLeft = SpecArena.roundCreeps + SpecArena.roundKillers + 1--Кол-во оставшихся юнитов = кол-во обычных + кол-во убийц + босс волны
	for i=1, SpecArena.roundCreeps do
		if i%3 == 0 then 
	  		local unit = CreateUnitByName( "wave_unit_" .. SpecArena.currentGameRound, SPAWN_3 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	  	elseif	i%2 == 0 then
	  		local unit = CreateUnitByName( "wave_unit_" .. SpecArena.currentGameRound, SPAWN_2 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	  	else
	  		local unit = CreateUnitByName( "wave_unit_" .. SpecArena.currentGameRound, SPAWN_1 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	  	end
	end

	Timers:CreateTimer( 5, function()
		for i=1, SpecArena.roundKillers do
			if i%3 == 0 then 
		  		local unit = CreateUnitByName( "wave_unit_" .. SpecArena.currentGameRound .. "_killer", SPAWN_3 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		  	elseif	i%2 == 0 then
		  		local unit = CreateUnitByName( "wave_unit_" .. SpecArena.currentGameRound .. "_killer", SPAWN_2 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		  	else
		  		local unit = CreateUnitByName( "wave_unit_" .. SpecArena.currentGameRound .. "_killer", SPAWN_1 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		  	end
		end
	end )

	Timers:CreateTimer( 8, function()
		local i = RandomInt(1, 3)
		if i == 1 then local unit = CreateUnitByName( "wave_unit_" .. SpecArena.currentGameRound .. "_boss", SPAWN_1 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) end
		if i == 2 then local unit = CreateUnitByName( "wave_unit_" .. SpecArena.currentGameRound .. "_boss", SPAWN_2 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) end
		if i == 3 then local unit = CreateUnitByName( "wave_unit_" .. SpecArena.currentGameRound .. "_boss", SPAWN_3 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) end
	end )

	SpecArena:TeleportHeroes(ARENA_MID)
end

function SpecArena:WaveEnd()
	Timers:CreateTimer( 2.0, function()
		self:ChangeState(STATE_PRE_ROUND_TIME)
		self:TeleportHeroes(SHOP_MID)
		StartTimer(30,self.State,self.currentGameRound)
	end )
end

function SpecArena:TeleportHeroes( point )
	for _,hero in pairs(self.allHeroes) do
		if hero:IsAlive() then
			hero:Heal(hero:GetMaxHealth(), nil)
			hero:SetMana( hero:GetMaxMana() )
		else
			hero:RespawnUnit()
		end
		ResetCooldownAbilities( hero )

		hero:SetAbsOrigin(point)
		FindClearSpaceForUnit(hero, point, false)
		hero:Stop()
		
		SetCameraToPosForPlayer(hero:GetPlayerID(), hero:GetAbsOrigin() )
	end
end

function SpecArena:CheckReadyPlayers()
	if self.readyPlayers == PlayerResource:GetPlayerCount() and self.State == STATE_PRE_ROUND_TIME then
		SetTimeLeft(3)
	end
end

function SpecArena:ChangeState( state )
	self.State = state
	if state == STATE_PRE_ROUND_TIME then
		self.readyPlayers = 0
		self.currentGameRound = self.currentGameRound + 1
		for _,player in pairs(self.allPlayers) do
			player.bFirstVote = nil
		end
	end
end

function SpecArena:Distance( v1, v2 )
	return math.sqrt( math.pow( (v1.x-v2.x), 2) + math.pow( (v1.y-v2.y), 2) )
end