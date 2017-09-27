function DebugPrint(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    print(...)
  end
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    PrintTable(...)
  end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end




--[[Author: Noya
  Date: 09.08.2015.
  Hides all dem hats
]]
function HideWearables( unit )
  unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(unit.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( unit )

  for i,v in pairs(unit.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
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

function SetCameraToPosForPlayer(playerID,vector)
  local camera_guy = CreateUnitByName("npc_dummy_unit", vector, false, nil, nil, DOTA_TEAM_GOODGUYS)
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