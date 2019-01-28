

customcallbacks = {}
function createcustomcallback(string)
  customcallbacks[string] = {}
  
  callback = function(...)
    for _,v in ipairs(customcallbacks[string]) do
      v(...)
    end
  end
  return callback
end
function registercustomcallback(string, func)
  table.insert(customcallbacks[string], func)
end


player_skill_trees = {}

local _missingicon = Sprite.load("missing_icon","res/missing.png", 1,11,11)

function min(a, b) if(a < b) then return a else return b end end
function max(a, b) if(a > b) then return a else return b end end
function abs(a) if(a < 0) then return -a end return a end
function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end
function removeColorFormatting(string)
  local color_keys = {"&r&","&g&","&b&","&y&","&or&","&bl&","&lt&","&dk&","&w&","&p&","&!&"}
  local str = string
  for _,color in ipairs(color_keys) do
    str = str:gsub(color, "")
  end
  return str
end

require("bin")
require("skill")
require("skilltree")

require("skill_effect")
require("commando_skills")

registercallback("onPlayerInit", function(player)
  local player_id = player:get("id")
  local commando_skill_tree = CommandoSkillTree(player_id)
  
  player_skill_trees[player_id] = commando_skill_tree
  commando_skill_tree:addPoints(10)
  --player:set("skilltree", skilltree)
  
  local survivor = player:getSurvivor()
end)

registercallback("onPlayerLevelUp", function(player)
  player_skill_trees[player:get("id")]:addPoint()
end)