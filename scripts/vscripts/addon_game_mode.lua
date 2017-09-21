-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require( 'timers' )
require( 'spec_arena' )

GAME_ROUND = 0 -- номер текущего раунда
MAX_ROUNDS = 5 -- номер конечного раунда
ROUND_UNITS = 2 -- кол-во юнитов на 1 раунде

function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[Spec_arena] Performing pre-load precache")

  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_base_attack.vpcf", context)
  PrecacheResource("particle_folder", "particles/test_particle", context)

  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models
  PrecacheResource("model_folder", "particles/heroes/antimage", context)
  PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  PrecacheModel("models/heroes/viper/viper.vmdl", context)
  --PrecacheModel("models/props_gameplay/treasure_chest001.vmdl", context)
  --PrecacheModel("models/props_debris/merchant_debris_chest001.vmdl", context)
  --PrecacheModel("models/props_debris/merchant_debris_chest002.vmdl", context)

  -- Sounds can precached here like anything else
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)

  -- Entire items can be precached by name
  -- Abilities can also be precached in this way despite the name
  PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("item_example_item", context)
  PrecacheItemByNameSync("xen_item", context)

  -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  PrecacheUnitByNameSync("npc_dota_hero_enigma", context)
  PrecacheUnitByNameSync("example_unit_1", context)
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:_InitGameMode()
end

function GameMode:OnGameInProgress() -- Функция начнет выполняться, когда начнется матч( на часах будет 00:00 ).
      local point = Entities:FindByName( nil, "spawn1"):GetAbsOrigin() -- Записываем в переменную 'point' координаты нашего спавнера 'spawn1'
      -- local waypoint = Entities:FindByName( nil, "way1") -- Записываем в переменную 'waypoint' координаты первого бокса way1
      local return_time = 10 -- Записываем в переменную значение '10'
      Timers:CreateTimer(15, function()  -- Создаем таймер, который запустится через 15 секунд после начала матча и запустит следующую функцию
       GAME_ROUND = GAME_ROUND + 1 -- Значение GAME_ROUND увеличивается на 1
       if GAME_ROUND == MAX_ROUNDS -- Если GAME_ROUND равно MAX_ROUNDS, переменная return_time получит нулевое значение
            return_time = nil
         end
         Say(nil,"Wave №" .. GAME_ROUND, false) -- Выводим в чат сообщение 'Wave №', в конце к которому добавится значение GAME_ROUND.
         for i=1, ROUND_UNITS do -- Произведет нижние действия столько раз, сколько указано в ROUND_UNITS. То есть в нашем случае создаст 2 юнита.
              local unit = CreateUnitByName( "example_unit_" .. GAME_ROUND, point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_GOODGUYS ) --[[ Создаем юнита 'example_unit_', в конце к названию добавится 1,2,3,4 или 5, в зависимости от раунда, и в итоге получатся наши example_unit_1, example_unit_2 и т.д. Юнит появится в векторе point + RandomVector (RandomFloat( 0, 200 ) ) - point - наша переменная, а рандомный вектор добавляется для того, чтобы мобы не появлялись в одной точке и не застревали. Мобы будут за силы света. ]]
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'
         end   
          return return_time -- Возвращаем таймеру время, через которое он должен снова сработать. Когда пройдет последний раунд таймер получит значение 'nil' и выключится.
      end)
end