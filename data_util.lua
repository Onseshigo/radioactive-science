local tech_has_prerequisite = function(tech_name, prerequisite)
  local tech = data.raw["technology"][tech_name]
  if not tech then return end

  for _, tech_prerequisite in ipairs(tech.prerequisites) do
    if prerequisite == tech_prerequisite then return true end
  end
  return false
end

local add_tech_prerequisite = function (tech_name, add_prerequisite)
  local tech = data.raw["technology"][tech_name]
  if not tech then return end

  local add_prerequisites = nil  
  if type(add_prerequisite) == "string" then
    add_prerequisites = {add_prerequisite}
    tech.prerequisites = tech.prerequisites or {}
    table.insert(tech.prerequisites, add_prerequisite)
  elseif type(add_prerequisite) == "table" then
    add_prerequisites = add_prerequisite
  end
  if not add_prerequisites then return end

  for _, prerequisite in ipairs(add_prerequisites) do
    if not tech_has_prerequisite(tech_name, prerequisite) then
      table.insert(tech.prerequisites, prerequisite)
    end
  end
end

local add_tech_effect = function (tech_name, add_effect, params)
  local tech = data.raw["technology"][tech_name]
  if not tech then return end

  local add_effects = nil
  if type(add_effect) == "table" then
    if add_effect[1] then
      add_effects = add_effect
    else
      add_effects = {add_effect}
    end
  end
  if not add_effects then return end

  for _, add_effect in ipairs(add_effects) do
    tech.effects = tech.effects or {}
    table.insert(tech.effects, add_effect)
  end

  -- exclusive removes the added effects from all other techs in the tech tree
  if params and params.exclusive then
    for _1, add_effect in ipairs(add_effects) do
      for _2, tech in pairs(data.raw["technology"]) do
        if not tech.effects then goto continue end
        for i=#tech.effects,1,-1 do -- iterate down so remove only moves indices we've already seen
          local effect = tech.effects
          local matches = true
          for effect_key, effect_value in pairs(effect) do
            if add_effect[effect_key] ~= effect_value then
              matches = false
            end
          end
          if matches then
            table.remove(tech.effects, i)
          end
        end
        ::continue::
      end
    end
  end
end

local tech_has_unit_ingredient = function (tech_name, ingredient)
  local tech = data.raw["technology"][tech_name]
  if not tech then return end
  if not (tech.unit and tech.unit.ingredients) then return end

  for _, tech_ingredient in ipairs(tech.unit.ingredients) do
    if ingredient == tech_ingredient[1] then return true end
  end
  return false
end

local add_tech_unit_ingredient = function (tech_name, add_ingredient)
  local tech = data.raw["technology"][tech_name]
  if not tech then return end
  if not (tech.unit and tech.unit.ingredients) then return end 

  local add_ingredients = nil
  if type(add_ingredient) == "string" then
    add_ingredients = {add_ingredient}
  elseif type(add_ingredient) == "table" then
    add_ingredients = add_ingredient
  end
  if not add_ingredients then return end

  for _, add_ingredient in ipairs(add_ingredients) do
    if not tech_has_unit_ingredient(add_ingredient) then
      table.insert(tech.unit.ingredients, {add_ingredient, 1})
    end
  end
end

local remove_tech_prerequisite = function (tech_name, remove_prerequisite)
  local tech = data.raw["technology"][tech_name]
  if not tech then return end

  local remove_prerequisites = nil  
  if type(remove_prerequisite) == "string" then
    remove_prerequisites = {remove_prerequisite}
    table.insert(tech.prerequisites, remove_prerequisite)
  elseif type(remove_prerequisite) == "table" then
    remove_prerequisites = remove_prerequisite
  end
  if not remove_prerequisites then return end

  for _, remove_prerequisite in ipairs(remove_prerequisites) do
    for i=#tech.prerequisites,1,-1 do
      local prerequisite = tech.prerequisites[i]
      if prerequisite == remove_prerequisite then
        table.remove(tech.prerequisites, i)
      end
    end
  end
end

local remove_tech_effect = function (tech_name, remove_effect)
  local tech = data.raw["technology"][tech_name]
  if not tech then return end

  local remove_effects = nil
  if type(remove_effect) == "table" then
    if remove_effect[1] then
      remove_effects = remove_effect
    else
      remove_effects = {remove_effect}
    end
  end
  if not remove_effects then return end

  for _1, remove_effect in ipairs(remove_effects) do
    for i=#tech.effects,1,-1 do -- iterate down so remove only moves indices we've already seen
      local effect = tech.effects[i]
      local matches = false
      for effect_key, effect_value in pairs(effect) do
        if effect_key ~= "type" and remove_effect[effect_key] == effect_value then
          matches = true
        end
      end
      if matches then
        table.remove(tech.effects, i)
      end
    end
  end
end

local remove_tech_unit_ingredient = function (tech_name, remove_ingredient)
  local tech = data.raw["technology"][tech_name]
  if not tech then return end
  if not (tech.unit and tech.unit.ingredients) then return end 

  local remove_ingredients = nil
  if type(remove_ingredient) == "string" then
    remove_ingredients = {remove_ingredient}
  elseif type(remove_ingredient) == "table" then
    remove_ingredients = remove_ingredient
  end
  if not remove_ingredients then return end

  for _, remove_ingredient in ipairs(remove_ingredients) do
    for i=#tech.unit.ingredients,1,-1 do
      local ingredient = tech.unit.ingredients[i]
      if ingredient[1] == remove_ingredient then
        table.remove(tech.unit.ingredients, i)
      end
    end
  end
end

local remove_effect = function (effect_name)
  for _1, tech in pairs(data.raw["technology"]) do
    if tech.effects then
      for _2, effect in pairs(tech.effects) do
        if effect.recipe == effect_name then
          table.remove(tech.effects, _2)
        end
      end
    end
  end
end

local remove_unit_by_name = function (tech_name, unit_name)
  local tech = data.raw["technology"][tech_name]
  if not tech or not tech.unit or not tech.unit.ingredients then return end
  for _, ingredient in pairs(tech.unit.ingredients) do
    if ingredient[1] == unit_name then table.remove(tech.unit.ingredients, _) end
  end
end

local remove_effect_by_name = function (tech_name, effect_name)
  local tech = data.raw["technology"][tech_name]
  if not tech then return end
  for _, effect in pairs(tech.effects) do
    if effect.recipe == effect_name then
      table.remove(tech.effects, _)
    end
  end
end

local get_dependent_technologies = function (tech_name)
  local dependents = {}
  for _1, tech in pairs(data.raw["technology"]) do
    if tech.prerequisites then
      for _2, prerequisite in pairs(tech.prerequisites) do
        if prerequisite == tech_name then
          table.insert(dependents, tech)
        end
      end
    end
  end
  return dependents
end

local remove_technology = function (tech_name)
  if not data.raw["technology"][tech_name] then return end
  local prerequisites = data.raw["technology"][tech_name].prerequisites
  local dependents = get_dependent_technologies(tech_name)
  for _1, dependent in pairs(dependents) do
    for _2, dependent_prerequisite in pairs(dependent.prerequisites) do
      if dependent_prerequisite == tech_name then
        -- remove this tech from the dependent's list of prerequisites
        table.remove(dependent.prerequisites, _2)
        for _3, prerequisite in pairs(prerequisites) do
          -- insert all of this tech's prerequisites as prerequisites for the dependent technology
          table.insert(dependent.prerequisites, prerequisite)
          -- dedupliciate prerequisites
          local dependent_prerequisites = {}
          for _, dedup_dependent_prerequisite in pairs(dependent.prerequisites) do
            dependent_prerequisites[dedup_dependent_prerequisite] = true
          end
          local deduped_dependent_prerequisites = {}
          for deduped_dependent_prerequisite, _ in pairs(dependent_prerequisites) do
            table.insert(deduped_dependent_prerequisites, deduped_dependent_prerequisite)
          end
          dependent.prerequisites = deduped_dependent_prerequisites
        end
      end
    end
  end

  data.raw["technology"][tech_name] = nil
end

local remove_item = function (item_name, forced)
  for category_name, category in pairs(data.raw) do
    if data.raw[category_name][item_name] then
      if not forced then
        -- don't completely remove, instead just disable to have better compatibility with other mods
        data.raw[category_name][item_name].enabled = false
        data.raw[category_name][item_name].hidden = true
        data.raw[category_name][item_name].hidden_in_factoriopedia = true
      else
        data.raw[category_name][item_name] = nil
      end
      -- either way we don't want to unlock it w/ research
      remove_effect(item_name)
    end
  end
end


local remove_items_by_subgroup = function (subgroup)
  for _, item in pairs(data.raw["item"]) do
    if item.subgroup == subgroup then
      remove_item(item.name)
    end
  end
end

local remove_items_by_property = function (props, forced)
  for category_name, category in pairs(data.raw) do
    for item_name, item in pairs(data.raw[category_name]) do
      local matches = true
      for prop_name, prop_value in pairs(props) do
        if data.raw[category_name][item_name][prop_name] ~= prop_value then
          matches = false
        end
      end
      if matches then
        if not forced then
          -- don't completely remove, instead just disable to have better compatibility with other mods
          data.raw[category_name][item_name].enabled = false
          data.raw[category_name][item_name].hidden = true
          data.raw[category_name][item_name].hidden_in_factoriopedia = true
        else
          data.raw[category_name][item_name] = nil
        end
      end
    end
  end
end

local remove_item_from_autoplace_tile_restrictions = function (item_name)
  for _1, plant in pairs(data.raw["plant"]) do
    for _2, tile in pairs(plant.autoplace.tile_restriction) do
      if tile == item_name then
        table.remove(plant.autoplace.tile_restriction, _2)
      end
    end
  end
end

return {
  add_tech_prerequisite = add_tech_prerequisite,
  add_tech_effect = add_tech_effect,
  add_tech_unit_ingredient = add_tech_unit_ingredient,
  remove_tech_prerequisite = remove_tech_prerequisite,
  remove_tech_effect = remove_tech_effect,
  remove_tech_unit_ingredient = remove_tech_unit_ingredient,
  remove_effect = remove_effect,
  remove_effect_by_name = remove_effect_by_name,
  remove_unit_by_name = remove_unit_by_name,
  remove_technology = remove_technology,
  remove_item = remove_item,
  remove_items_by_subgroup = remove_items_by_subgroup,
  remove_items_by_property = remove_items_by_property,
  remove_item_from_autoplace_tile_restrictions = remove_item_from_autoplace_tile_restrictions,
}