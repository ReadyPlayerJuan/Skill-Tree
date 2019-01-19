
player_skill_trees = {}

local _missingicon = Sprite.load("missing_icon","res/missing.png", 1,11,11)

require("bin")
require("skill")
require("skilltree")

require("skill_effect")
require("commando_skills")

function min(a, b) if(a < b) then return a else return b end end
function max(a, b) if(a > b) then return a else return b end end
function table.clone(a) return {table.unpack(org)} end

registercallback("onPlayerInit", function(player)
  local commando_skill_tree = CommandoSkillTree()
  
  player_skill_trees[player:get("id")] = commando_skill_tree
  commando_skill_tree:addPoints(10)
  --player:set("skilltree", skilltree)
  
  local survivor = player:getSurvivor()
end)

registercallback("onPlayerLevelUp", function(player)
  player_skill_trees[player:get("id")]:addPoint()
end)