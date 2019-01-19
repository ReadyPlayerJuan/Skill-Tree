
function CommandoSkillTree()
  local skilltree = SkillTree:new()
  
  local skill_test = Skill:new("fun skill",
      "increase fun by |0|, and decrease enemy fun by |1|.",
      {{"10%%", "20%%", "30%%"}, {"15%%", "35%%", "90%%"}}, 3,
      nil, TestSkillEffect.new(), {{0},{1},{2},{3}})
  
  local skill_health = Skill:new("bonus health",
      "increases max health by |0|.",
      {{"50", "100", "150", "200", "250"}}, 5,
      "health", FlatHealthSkillEffect.new(), {{0},{50},{100},{150},{200},{250}})
  
  local skill_damage_x = Skill:new("x damage", "increase x damage by |0|%%.", {{"50%%", "100%%", "150%%"}}, 3, "skill", ProjectileDamageSkillEffect:new("commando", 2), {{0},{.5},{1},{1.5}})
  local skill_4 = Skill:new("test4", "test desc 4 |0|, and more info here |1|.", {{"10%%", "20%%", "30%%"}, {"15%%", "35%%", "90%%"}}, 3, nil)
  local skill_5 = Skill:new("test5", "test desc 5 |0|, and more info here |1|.", {{"10%%", "20%%", "30%%"}, {"15%%", "35%%", "90%%"}}, 3, nil)
  local skill_6 = Skill:new("test6", "test desc 6 |0|, and more info here |1|.", {{"10%%", "20%%", "30%%"}, {"15%%", "35%%", "90%%"}}, 3, nil)
  
  skill_test:addChildren(skill_4)
  skill_health:addChildren(skill_4, skill_5)
  skill_5:addChildren(skill_6)
  
  skilltree:addSkill(skill_test, 0.5, 0)
  skilltree:addSkill(skill_health, 1.5, 0)
  skilltree:addSkill(skill_damage_x, 0, 1)
  skilltree:addSkill(skill_4, 1, 1)
  skilltree:addSkill(skill_5, 2, 1)
  skilltree:addSkill(skill_6, 1.5, 2)
  skilltree:refresh()
  
  return skilltree
end