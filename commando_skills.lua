
require("ability_listener")
require("skill_effect")

--[[
  ideas:
    suppressive fire lasts longer
    suppressive fire lasts until you release key
    FMJ does bonus damage point blank
    bonus damage at low health
    half attackspeed, z always crits
]]

function CommandoSkillTree(player_id)
  addSurvivorAbilityData("Commando", {
    {}, --z ability
    {CALLBACK_HIT, {CHECK_DAMAGE, function(damage) local a = ((damage * 11) / 6) + 0.5 if damage % 2 == 0 then a = a + 0.5 end return a end, 0.0},
                   {CHECK_ATTRIBUTE, "knockback", 6--[[expected]], 0.0--[[error]]}}, --x ability
    {}, --c ability
    {}, --v ability
  })
  
  local skilltree = SkillTree:new()
  
  local skill_test = Skill:new("Crit Healing (title wip)",
      "Critical hits heal for &y&|0|&!& of missing health.",
      {{"2%%", "3.5%%", "5%%"}}, 3,
      nil, HealOnCritSkillEffect:new(player_id, false, true), {{0},{0.02},{0.035},{0.05}}, 
      0.5, 0)
  
  local skill_health = Skill:new("Bonus Health",
      "increases max health by &y&|0|.&!&",
      {{"50", "100", "150", "200", "250"}}, 5,
      "health", FlatHealthSkillEffect.new(), {{0},{50},{100},{150},{200},{250}}, 
      1.5, 0)
  
  local skill_damage_x = Skill:new("More Metal Jackets",
      "increases &or&Full Metal Jacket&!& damage by &y&|0|.&!&",
      {{"1.5x", "2.0x", "2.5x"}}, 3,
      "skill", ProjectileDamageSkillEffect:new(player_id, 2), {{0},{.5},{1},{1.5}}, 
      0, 1)
  
  local skill_roll_speed = Skill:new("Rounder Knees",
      "Increases move speed while rolling by &y&|0|.&!&",
      {{"1.5x", "2.0x"}}, 2,
      nil, MoveSpeedDuringAbilitySkillEffect:new(player_id, 3), {{0},{0.5},{1}},
      1, 1)
  
  local skill_roll_cd = Skill:new("Acrobatics",
      "On kill, refunds &y&|0|&!& of &or&Tactical Dive&!&'s remaining cooldown.",
      {{"25%%", "50%%", "100%%"}}, 3,
      nil, AbilityResetOnKillSkillEffect:new(player_id, 3), {{0},{0.25},{0.5},{1.0}}, 2, 1)
  
  local skill_6 = Skill:new("test6",
      "test desc 6 |0|, and more info here |1|.",
      {{"10%%", "20%%", "30%%"}, {"15%%", "35%%", "90%%"}}, 3,
      nil, nil, nil, 1.5, 2)
  
  --skill_test:addChildren(skill_roll_speed)
  --skill_health:addChildren(skill_roll_speed, skill_5)
  --skill_5:addChildren(skill_6)
  
  skilltree:addSkill(skill_test)
  skilltree:addSkill(skill_health)
  skilltree:addSkill(skill_damage_x)
  skilltree:addSkill(skill_roll_speed)
  skilltree:addSkill(skill_roll_cd)
  skilltree:addSkill(skill_6)
  skilltree:refresh()
  
  return skilltree
end