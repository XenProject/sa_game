-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[BAREBONES] Performing pre-load precache")

  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
  --PrecacheResource("particle_folder", "particles/test_particle", context)

  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models
  --PrecacheResource("model_folder", "particles/heroes/antimage", context)
  --PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  --PrecacheModel("models/heroes/viper/viper.vmdl", context)

  -- Sounds can precached here like anything else

  -- Entire items can be precached by name
  -- Abilities can also be precached in this way despite the name

  -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  --PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  --PrecacheUnitByNameSync("npc_dota_hero_enigma", context)

  --PrecacheItemByNameSync("item_drum", context)
  PrecacheItemByNameSync("item_sa_forest_staff", context)
  PrecacheItemByNameSync("item_sa_shaman_staff", context)
  PrecacheItemByNameSync("item_sa_archmage_staff", context)
  PrecacheItemByNameSync("item_sa_blade_of_lightning", context)
  for i=1,MAX_ROUNDS do
    PrecacheUnitByNameSync("wave_unit_"..i, context)
    PrecacheUnitByNameSync("wave_unit_"..i.."_killer", context)
    PrecacheUnitByNameSync("wave_unit_"..i.."_boss", context)
  end
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:_InitGameMode()
end