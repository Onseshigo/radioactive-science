local data_util = require("__radioactive-science__/data_util.lua")

--[[Centrifuges/centrifuging requires Nauvis atmosphere to make it into its own unique surface.]]
data.raw["assembling-machine"]["centrifuge"].surface_conditions = {
  {
    property = "pressure",
    min = 1000,
    max = 1000,
  },
}
for _1, recipe in pairs(data.raw["recipe"]) do
  if recipe.category == "centrifuging" then
    recipe.surface_conditions = {
      {
        property = "pressure",
        min = 1000,
        max = 1000,
      },
    }
  end
end

-- remove kovarex enrichment tech since the  recipe is unlocked by radioactive science
data_util.remove_technology("kovarex-enrichment-process")

--[[
Nuclear techs now are locked behind the radioactive science pack.
Modify prerequisites and science pack costs to put Nauvis-related techs costing/depending on radioactive science pack.
]]
-- uranium ammo
data_util.remove_tech_unit_ingredient("uranium-ammo", "utility-science-pack")
data_util.add_tech_unit_ingredient("uranium-ammo", "radioactive-science-pack")
local uranium_ammo = data.raw["technology"]["uranium-ammo"]
uranium_ammo.prerequisites = {"radioactive-science-pack", "military-science-pack"}
uranium_ammo.unit.count = 500
uranium_ammo.unit.time = 60
-- radioactive science pack needs an infinite research so give it to physical projectile damage/speed
-- it can depend on uranium-ammo instead of utility-science-pack
data_util.remove_tech_unit_ingredient("physical-projectile-damage-6", "utility-science-pack")
data_util.remove_tech_unit_ingredient("physical-projectile-damage-7", "utility-science-pack")
data_util.remove_tech_unit_ingredient("weapon-shooting-speed-6", "utility-science-pack")
data_util.add_tech_unit_ingredient("physical-projectile-damage-6", "radioactive-science-pack")
data_util.add_tech_unit_ingredient("physical-projectile-damage-7", "radioactive-science-pack")
data_util.add_tech_unit_ingredient("weapon-shooting-speed-6", "radioactive-science-pack")
data_util.remove_tech_prerequisite("physical-projectile-damage-6", "utility-science-pack")
data_util.remove_tech_prerequisite("weapon-shooting-speed-6", "utility-science-pack")
data_util.add_tech_prerequisite("physical-projectile-damage-6", "uranium-ammo")
data_util.add_tech_prerequisite("weapon-shooting-speed-6", "uranium-ammo")
-- nuclear-power
data_util.add_tech_unit_ingredient("nuclear-power", "radioactive-science-pack")
local nuclear_power = data.raw["technology"]["nuclear-power"]
nuclear_power.prerequisites = {"radioactive-science-pack"}
-- nuclear fuel reprocessing
data_util.remove_tech_unit_ingredient("nuclear-fuel-reprocessing", "production-science-pack")
data_util.add_tech_unit_ingredient("nuclear-fuel-reprocessing", "radioactive-science-pack")
local nuclear_fuel_reprocessing = data.raw["technology"]["nuclear-fuel-reprocessing"]
nuclear_fuel_reprocessing.prerequisites = {"nuclear-power"}
-- atomic bomb
data_util.remove_tech_unit_ingredient("atomic-bomb", "utility-science-pack")
data_util.remove_tech_unit_ingredient("atomic-bomb", "space-science-pack")
data_util.add_tech_unit_ingredient("atomic-bomb", "radioactive-science-pack")
data.raw["technology"]["atomic-bomb"].prerequisites = {"radioactive-science-pack", "military-science-pack", "explosives", "processing-unit"}
-- efficiency module 3 goes from agricultural-science to radioactive-science so now there is one tier 3 module per planet
data_util.remove_tech_unit_ingredient("efficiency-module-3", "agricultural-science-pack")
data_util.add_tech_unit_ingredient("efficiency-module-3", "radioactive-science-pack")
data.raw["technology"]["efficiency-module-3"].prerequisites = {"radioactive-science-pack", "efficiency-module-2"}
-- biolabs
data_util.add_tech_unit_ingredient("biolab", "radioactive-science-pack")
data_util.add_tech_prerequisite("biolab", "radioactive-science-pack")
-- captive biter spawner
data_util.add_tech_unit_ingredient("captive-biter-spawner", "radioactive-science-pack")
data_util.add_tech_prerequisite("captive-biter-spawner", "radioactive-science-pack")
-- portable fission reactor
data_util.add_tech_unit_ingredient("fission-reactor-equipment", "radioactive-science-pack")
-- portable fusion reactor
data_util.add_tech_unit_ingredient("fusion-reactor-equipment", "radioactive-science-pack")
-- spidertron
data_util.add_tech_unit_ingredient("spidertron", "radioactive-science-pack")

--[[Enable radioactive science in labs - do this in data-updates to catch all labs added in data.]]
for _, lab in pairs(data.raw["lab"]) do
  table.insert(lab.inputs, "radioactive-science-pack")
end