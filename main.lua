
player_skill_trees = {}

local _missingicon = Sprite.load("missing_icon","res/missing.png", 1,11,11)

require("bin")
require("skill")
require("skilltree")

require("skill_effect")
require("commando_skills")

registercallback("onPlayerInit", function(player)
  local skilltree = SkillTree:new()
  
  local skill_1 = Skill:new("fun skill", "increase fun by |0|, and decrease enemy fun by |1|.", {{"10%%", "20%%", "30%%"}, {"15%%", "35%%", "90%%"}}, 3, "skill", TestSkillEffect.new(), {{0},{1},{2},{3}})
  local skill_2 = Skill:new("test2", "test desc 2 |0|, and more info here |1|.", {{"10%%", "20%%", "30%%"}, {"15%%", "35%%", "90%%"}}, 3, nil)
  local skill_3 = Skill:new("test3", "test desc 3 |0|, and more info here |1|.", {{"10%%", "20%%", "30%%"}, {"15%%", "35%%", "90%%"}}, 3, nil)
  local skill_4 = Skill:new("test4", "test desc 4 |0|, and more info here |1|.", {{"10%%", "20%%", "30%%"}, {"15%%", "35%%", "90%%"}}, 3, nil)
  local skill_5 = Skill:new("test5", "test desc 5 |0|, and more info here |1|.", {{"10%%", "20%%", "30%%"}, {"15%%", "35%%", "90%%"}}, 3, nil)
  local skill_6 = Skill:new("test6", "test desc 6 |0|, and more info here |1|.", {{"10%%", "20%%", "30%%"}, {"15%%", "35%%", "90%%"}}, 3, nil)
  
  skill_1:addChildren(skill_3, skill_4)
  skill_2:addChildren(skill_4, skill_5)
  skill_5:addChildren(skill_6)
  
  skilltree:addSkill(skill_1, 0.5, 0)
  skilltree:addSkill(skill_2, 1.5, 0)
  skilltree:addSkill(skill_3, 0, 1)
  skilltree:addSkill(skill_4, 1, 1)
  skilltree:addSkill(skill_5, 2, 1)
  skilltree:addSkill(skill_6, 1.5, 2)
  skilltree:refresh()
  player_skill_trees[player:get("id")] = skilltree
  skilltree:addPoints(10)
  --player:set("skilltree", skilltree)
  
  local survivor = player:getSurvivor()
end)

registercallback("onPlayerLevelUp", function(player)
  player_skill_trees[player:get("id")]:addPoint()
end)