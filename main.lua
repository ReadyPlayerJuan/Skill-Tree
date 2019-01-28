
--apply critical damage attribute to all damagers
registercallback("onFire", function(damager)
  if damager:get("team") == "player" and damager:get("critical") == 1 then
    local player = Object.findInstance(damager:get("parent"))
    damager:set("damage", damager:get("damage") * player:get("critical_damage") / 2)
  end
end)

require("util")
require("bin")
require("skill")
require("skilltree")

require("skill_effect")
require("commando_skills")

skill_trees = {}
skill_trees["Commando"] = CommandoSkillTree

player_skill_trees = {}

registercallback("onPlayerInit", function(player)
  player:set("critical_damage", 2) --crit multiplier, default 2 = 200%
  
  local player_id = player:get("id")
  local survivor_name = player:getSurvivor():getName()
  local skill_tree_func = skill_trees[survivor_name]
  
  if skill_tree_func ~= nil then
    local skill_tree = skill_tree_func(player_id)
    
    player_skill_trees[player_id] = skill_tree
    skill_tree:addPoints(10)
  end
end)

registercallback("onGameEnd", function()
  for id,skill_tree in pairs(player_skill_trees) do
    skill_tree:destroy()
    skill_tree = nil
  end
  player_skill_trees = {}
  resetSkillCallbacks()
end)

registercallback("onPlayerLevelUp", function(player)
  player_skill_trees[player:get("id")]:addPoint()
end)