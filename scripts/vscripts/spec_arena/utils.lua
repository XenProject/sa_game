function SpecArena:CheckReadyPlayers()
	if self.readyPlayers == PlayerResource:GetPlayerCount() and self.State == STATE_PRE_ROUND_TIME then
		SetTimeLeft(3)
		Timers:RemoveTimer("StartRoundTimer")
		Timers:CreateTimer( 3.0, function()
			self:SpawnWaveUnits()
		end)
	end
end

function SpecArena:HideHero(hero)

	hero.prorogueUnhide = false
	hero.prorogueHide = false

	if hero.hidden then 
		--print(hero:GetName().." already hidden")
		return 
	end
	
	if self.State >= STATE_ROUND_WAVE then
		if hero:IsAlive() then --отложим хайд героя, если сейчас идет раунд и герой жив
			hero.prorogueHide = true
		end
	end

	if not hero.prorogueHide then
		hero:Interrupt()
		hero:AddNoDraw()
		hero:AddNewModifier(hero, nil, "modifier_hide", nil)
		hero:SetAbsOrigin(Vector(-4000,-3500,0))
		hero.hidden = 1
	end
end

function SpecArena:UnhideHero(hero)

	hero.prorogueUnhide = false
	hero.prorogueHide = false

	if not hero.hidden then 
		--print(hero:GetName().." not hidden")
		return 
	end

	if self.State >= STATE_ROUND_WAVE then --во время раунда не возвращаем героя
		--print(hero:GetName().." prorogue unhide")
		hero.prorogueUnhide = true

		if self.State == STATE_ROUND_WAVE then 
			for _,unit in pairs(self.allHeroes) do 
				if unit:IsAlive() and not unit.hidden then 
					SetCameraToPosForPlayer(hero:GetPlayerID(),unit:GetAbsOrigin())
					break 
				end 
			end 
		else 
			--SetCameraToPosForPlayer(hero:GetPlayerID(),ARENA_CENTER_COORD)
		end
	end

	if not hero.prorogueUnhide then
		--print(hero:GetName().." unhidden")
		if not hero:IsAlive() then
			hero:RespawnHero(false, false, false)
		end
		hero:RemoveModifierByName("modifier_hide_lua")
		FindClearSpaceForUnit_IgnoreNeverMove(hero, Vector(0,1500,168), false)
		ResolveNPCPositions(hero:GetAbsOrigin(), 64)
		hero:RemoveNoDraw()
		hero.hidden = nil

		SetCameraToPosForPlayer(hero:GetPlayerID(),hero:GetAbsOrigin())

	end
end

function SpecArena:GetHeroCount(bOnlyAlive)
	local count = 0
	for _,hero in pairs(self.allHeroes) do
		if not hero.hidden and (not bOnlyAlive or hero:IsAlive() or hero:IsReincarnating()) then  
			count = count + 1
		end
	end
	return count
end

function GetItemInInventory(unit,itemName)
  for i = 0, 5 do
    local item = unit:GetItemInSlot(i) 
    if item then
      if item:GetName() == itemName then
        return item 
      end
    end
  end
  return nil
end

function ResetCooldownAbilities( hero )--without ultimate  !!!!!! ONLY 4 abilities
  for i=0, 3 do
    local ability = hero:GetAbilityByIndex(i)
    if ability:GetAbilityType() ~= 1 then -- DOTA_ABILITY_TYPE_ULTIMATE = 1
      ability:EndCooldown()
    end
  end
end

function DoWithAllHeroes(whatDo)
  if type(whatDo) ~= "function" then
    print("DoWithAllHeroes:not func")
    return
  end
  for i = 1, #SpecArena.allHeroes do
    if not SpecArena.allHeroes[i].hidden then
      whatDo(SpecArena.allHeroes[i])
    end
  end
end

function RespawnAllHeroes() 
	DoWithAllHeroes(function(hero)
		if not hero:IsAlive() then
			hero:RespawnHero(false,false,false)
			FindClearSpaceForUnit_IgnoreNeverMove(hero, Vector(0,1500,168)+RandomVector(RandomFloat(0, 200)), false)
		end
	end)
end

function SetCameraToPosForPlayer(playerID,vector)
  local camera_guy = CreateUnitByName("camera", vector, false, nil, nil, DOTA_TEAM_GOODGUYS)
  Timers:CreateTimer(1,function() camera_guy:RemoveSelf() end)
  
  if playerID == -1 then --для всех игроков
    DoWithAllHeroes(function(hero)
      PlayerResource:SetCameraTarget(hero:GetPlayerID(),camera_guy)
    end)
    Timers:CreateTimer(0.1,function()
      DoWithAllHeroes(function(hero)
        PlayerResource:SetCameraTarget(hero:GetPlayerID(),nil)
      end)
    end)
  else --для одного игрока
    PlayerResource:SetCameraTarget(playerID,camera_guy)
    Timers:CreateTimer(0.1,function()
      PlayerResource:SetCameraTarget(playerID,nil)
    end)
  end  
end