if not SpecArena then
    _G.SpecArena = class({})
end

_G.STATE_PRE_GAME = 0
_G.STATE_PRE_ROUND_TIME = 1
_G.STATE_PRE_DUEL_TIME = 2
_G.STATE_ROUND_WAVE = 3
_G.STATE_ROUND_MEGABOSS = 4
_G.STATE_ROUND_FINALBOSS = 5
_G.STATE_DUEL_TIME = 6

require('spec_arena/utils')

LinkLuaModifier( "modifier_hide", LUA_MODIFIER_MOTION_NONE )

XP_PER_LEVEL_TABLE = {}
XP_PER_LEVEL_TABLE[1] = 0
for i=2,MAX_LEVEL do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1] + i * 100
end

function SpecArena:Init()
	_G.ARENA_MID = Entities:FindByName(nil, "arena_mid"):GetAbsOrigin()
	_G.SHOP_MID = Entities:FindByName(nil, "shop_mid"):GetAbsOrigin()
	_G.SPAWN_1 = Entities:FindByName(nil, "spawn_1"):GetAbsOrigin()
	_G.SPAWN_2 = Entities:FindByName(nil, "spawn_2"):GetAbsOrigin()
	_G.SPAWN_3 = Entities:FindByName(nil, "spawn_3"):GetAbsOrigin()
	trigger_shop = Entities:FindByClassname(nil, "trigger_shop")

	self.State = STATE_PRE_GAME

	local GameMode = GameRules:GetGameModeEntity()
	GameMode:SetSelectionGoldPenaltyEnabled(false)
	GameMode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
	GameMode:SetUseCustomHeroLevels(true)

	GameMode:SetExecuteOrderFilter(Dynamic_Wrap(SpecArena, "OrderFilter"), self)

	self.allHeroes = {}
	self.allPlayers = {}
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
    	if PlayerResource:IsValidPlayerID(playerID) then
    		table.insert(self.allPlayers, PlayerResource:GetPlayer(playerID) )
    	end
    end

    self.currentGameRound = 0
    self.unitsLeft = 0
    self.readyPlayers = 0
    self.preRoundTime = 40

    self.roundCreeps = {24,34,44,54,64}
    self.roundKillers = self.roundCreeps[#self.allPlayers]/2

    self.nGoldPerWave = {8,8,8,8,8,16,16,16,16,16,32,32,32,32,32,32,32,32,32}
    self.allEnemies = self.roundCreeps[#self.allPlayers] + self.roundKillers + 1--Кол-во оставшихся юнитов = кол-во обычных + кол-во убийц + босс волны
end

function SpecArena:PrepareNextRound()
	self.State = STATE_PRE_ROUND_TIME
	self.currentGameRound = self.currentGameRound + 1

	self.readyPlayers = 0
	for _,player in pairs(self.allPlayers) do
		player.bFirstVote = nil
	end

	StartTimer(self.preRoundTime,self.State,self.currentGameRound)
	Timers:CreateTimer("StartRoundTimer",
        {
            endTime = self.preRoundTime, 
            callback = function() self:SpawnWaveUnits() end
        }
    )

	for _,hero in pairs(self.allHeroes) do
        if hero:GetPlayerOwner() == nil then
            self:HideHero(hero)
        elseif hero.hidden then
            self:UnhideHero(hero)
        end
    end
end

function SpecArena:SpawnWaveUnits()
	self.State = STATE_ROUND_WAVE
	self.unitsLeft = self.allEnemies
	for i=1, self.roundCreeps[#self.allPlayers] do
		if i%3 == 0 then 
	  		local unit = CreateUnitByName( "wave_unit_" .. self.currentGameRound, SPAWN_3 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	  	elseif	i%2 == 0 then
	  		local unit = CreateUnitByName( "wave_unit_" .. self.currentGameRound, SPAWN_2 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	  	else
	  		local unit = CreateUnitByName( "wave_unit_" .. self.currentGameRound, SPAWN_1 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
	  	end
	end

	Timers:CreateTimer( 10, function()
		for i=1, self.roundKillers do
			if i%3 == 0 then 
		  		local unit = CreateUnitByName( "wave_unit_" .. self.currentGameRound .. "_killer", SPAWN_3 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		  	elseif	i%2 == 0 then
		  		local unit = CreateUnitByName( "wave_unit_" .. self.currentGameRound .. "_killer", SPAWN_2 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		  	else
		  		local unit = CreateUnitByName( "wave_unit_" .. self.currentGameRound .. "_killer", SPAWN_1 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
		  	end
		end
	end )

	Timers:CreateTimer( 13, function()
		local i = RandomInt(1, 3)
		if i == 1 then local unit = CreateUnitByName( "wave_unit_" .. self.currentGameRound .. "_boss", SPAWN_1 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) end
		if i == 2 then local unit = CreateUnitByName( "wave_unit_" .. self.currentGameRound .. "_boss", SPAWN_2 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) end
		if i == 3 then local unit = CreateUnitByName( "wave_unit_" .. self.currentGameRound .. "_boss", SPAWN_3 + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) end
	end )

	self:TeleportHeroes(ARENA_MID)
end

function SpecArena:WaveEnd()
	self:GiveRoundBounty()
	Timers:CreateTimer( 2.0, function()
		self:TeleportHeroes( SHOP_MID )
		self:PrepareNextRound()
	end )
end

function SpecArena:TeleportHeroes( point )
	DoWithAllHeroes( function(hero)
		if hero:IsAlive() then
			hero:Heal(hero:GetMaxHealth(), nil)
			hero:SetMana( hero:GetMaxMana() )
		else
			hero:RespawnUnit()
		end
		ResetCooldownAbilities(hero)
		hero:SetAbsOrigin(point)
		FindClearSpaceForUnit(hero, point, false)
		hero:Stop()
	
		SetCameraToPosForPlayer(hero:GetPlayerID(), hero:GetAbsOrigin() )
	end )
end

function SpecArena:OrderFilter(filterTable)
	--PrintTable(filterTable)
	if filterTable.order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
        if SpecArena.State ~= STATE_PRE_GAME and SpecArena.State ~= STATE_PRE_ROUND_TIME and SpecArena.State ~= STATE_PRE_DUEL_TIME then
            local hero = PlayerResource:GetSelectedHeroEntity(filterTable.issuer_player_id_const)
            --if hero:GetNumItemsInStash() == 6 then
                return false
            --end
        end
    end

    if filterTable.order_type == DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH then
        if SpecArena.State ~= STATE_PRE_ROUND_TIME and SpecArena.State ~= STATE_PRE_DUEL_TIME then
            return false
        end
    end

    return true
end

function SpecArena:ExperienceDistribute( killedUnit )
	local nHeroesAlive = SpecArena:GetHeroCount(true)
    local xp = --[[killedUnit:GetDeathXP()/nHeroesAlive +]] 3 * (self.currentGameRound + 1)
    DoWithAllHeroes(function(hero)
        if hero:IsAlive() then
            hero:AddExperience(xp,DOTA_ModifyXP_Unspecified,false,true)
            --print(hero:GetCurrentXP())
        end
    end)
end

function SpecArena:GiveRoundBounty()
	local heroCount = SpecArena:GetHeroCount(false)
    goldBounty = self.allEnemies / heroCount * self.nGoldPerWave[self.currentGameRound]
    DoWithAllHeroes(function(hero)
    	hero:ModifyGold(goldBounty, false, DOTA_ModifyGold_Unspecified)
    end)
end