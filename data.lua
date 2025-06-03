local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")

data:extend {
  {
    type = "tool",
    name = "radioactive-science-pack",
    localised_description = {"item-description.science-pack"},
    icon = "__radioactive-science__/graphics/icons/radioactive-science-pack.png",
    subgroup = "science-pack",
    color_hint = { text = "G" },
    order = "h1",
    inventory_move_sound = item_sounds.science_inventory_move,
    pick_sound = item_sounds.science_inventory_pickup,
    drop_sound = item_sounds.science_inventory_move,
    stack_size = 200,
    default_import_location = "nauvis",
    weight = 1*kg,
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    factoriopedia_durability_description_key = "description.factoriopedia-science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    spoil_ticks = 1 * hour,
    spoil_result = "uranium-238",
    random_tint_color = item_tints.bluish_science
  },
  {
    type = "recipe",
    name = "radioactive-science-pack",
    icon = "__radioactive-science__/graphics/icons/radioactive-science-pack.png",
    category = "centrifuging",
    subgroup = "science-pack",
    surface_conditions = {
      {
        property = "pressure",
        min = 1000,
        max = 1000,
      }
    },
    enabled = false,
    ingredients =
    {
      {type = "item", name = "uranium-235", amount = 1},
      {type = "item", name = "rail", amount = 10},
      {type = "item", name = "rocket-fuel", amount = 1},
    },
    energy_required = 1,
    results =
    {
      {type = "item", name = "radioactive-science-pack", amount = 1}
    },
    allow_productivity = true,
  },
  {
    type = "technology",
    name = "radioactive-science-pack",
    icon = "__radioactive-science__/graphics/technology/radioactive-science-pack.png",
    icon_size = 256,
    essential = false,
    effects =
    {
      { type = "unlock-recipe", recipe = "radioactive-science-pack" },
      { type = "unlock-recipe", recipe = "kovarex-enrichment-process" },
    },
    prerequisites = {"uranium-processing", "rocket-fuel", "railway"},
    research_trigger = {
      type = "craft-item",
      item = "uranium-235",
    }
  },
}