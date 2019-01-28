
require("ability_listener")
require("skill_effect")

--[[
  ideas:
    suppressive fire lasts longer
    suppressive fire lasts until you release key
    bonus damage at low health
    half attackspeed, z always crits
]]

function CommandoSkillTree(player_id)
  addSurvivorAbilityData("Commando", {
    {CALLBACK_FIRE, {CHECK_DAMAGE, function(damage) return math.ceil(damage/2) end, 0.0},
                    {CHECK_ATTRIBUTE, "stun", --[[expected:]]0, --[[error:]]0.0}}, --z ability
                  
    {CALLBACK_HIT,  {CHECK_DAMAGE, function(damage) local a = ((damage * 11) / 6) + 0.5 if damage % 2 == 0 then a = a + 0.5 end return a end, 0.0},
                    {CHECK_ATTRIBUTE, "knockback", --[[expected:]]6, --[[error:]]0.0}}, --x ability
                  
    {}, --c ability
    
    {CALLBACK_HIT,  {CHECK_DAMAGE, function(damage) return math.ceil(damage/2) end, 0.0},
                    {CHECK_ATTRIBUTE, "stun", --[[expected:]]0.5, --[[error:]]0.0}}, --v ability
  })
  
  local skilltree = SkillTree:new()
  
  local skill_test = Skill:new("Crit Healing (title wip)",
      "Critical hits heal for &y&|0|&!& of missing health.",
      {{"2%%", "3.5%%", "5%%"}}, 3,
      nil, {HealOnCritSkillEffect:new(player_id, false, true)}, {{{0},{0.02},{0.035},{0.05}}}, 
      0.5, 0)
  
  local skill_health = Skill:new("Bonus Health",
      "increases max health by &y&|0|.&!&",
      {{"50", "100", "150", "200", "250"}}, 5,
      "health", {FlatHealthSkillEffect:new(player_id)}, {{{0},{50},{100},{150},{200},{250}}}, 
      1.5, 0)
  
  local skill_damage_fmj = Skill:new("More Metal Jackets",
      "increases &or&Full Metal Jacket&!& damage by &y&|0|.&!&",
      {{"1.25x", "1.5x", "1.75x", "2.0x"}}, 4,
      "skill", {AbilityDamageSkillEffect:new(player_id, 2)}, {{{0},{.25},{.5},{.75},{1}}}, 
      0, 1)
  
  local skill_roll_speed = Skill:new("Rounder Knees",
      "Increases move speed while in &or&Tactical Dive&!& by &y&|0|.&!&",
      {{"1.3x", "1.6x"}}, 2,
      nil, {MoveSpeedDuringAbilitySkillEffect:new(player_id, 3)}, {{{0},{0.3},{0.6}}},
      1, 1)
  
  local skill_roll_cd = Skill:new("Acrobatics",
      "On kill, refunds &y&|0|&!& of &or&Tactical Dive's&!& remaining cooldown,\nbut the base cooldown is &y&|1|&!& longer.",
      {{"25%%", "50%%", "100%%"}, {"1.5x", "2.0x", "3.0x"}}, 3,
      nil, {AbilityResetOnKillSkillEffect:new(player_id, 3), AbilityCooldownSkillEffect:new(player_id, 3)}, {{{0},{0.25},{0.5},{1.0}}, {{0},{0.5},{1.0},{2.0}}}, 2, 1)
  
  local skill_point_blank_fmj = Skill:new("Point Blank",
      "&or&Full Metal Jacket&!& always crits at very close range.",
      {}, 1,
      nil, {PointBlankFMJSkillEffect:new(player_id, 2)}, {{{0},{20}}}, 1.5, 2)
  
  local skill_attack_speed_for_crit = Skill:new("Steady Aim",
      "Attack speed is permanently cut by &y&|0|,&!& but &or&Double Tap&!& and\n&or&Suppressive Fire&!& always crit.",
      {{"40%%"}}, 1,
      nil, {AttackSpeedForCritsSkillEffect:new(player_id, 1, 4)}, {{{0},{-0.4}}}, 1, 3)
    
  
  --skill_test:addChildren(skill_roll_speed)
  --skill_health:addChildren(skill_roll_speed, skill_5)
  --skill_5:addChildren(skill_6)
  
  skilltree:addSkill(skill_test)
  skilltree:addSkill(skill_health)
  skilltree:addSkill(skill_damage_fmj)
  skilltree:addSkill(skill_roll_speed)
  skilltree:addSkill(skill_roll_cd)
  skilltree:addSkill(skill_point_blank_fmj)
  skilltree:addSkill(skill_attack_speed_for_crit)
  skilltree:refresh()
  
  return skilltree
end


--
--        COMMANDO SPECIFIC SKILL EFFECTS
--

--full metal jacket will always crit at close range
PointBlankFMJSkillEffect = SkillEffect:new(true)
function PointBlankFMJSkillEffect:new(player_id, skill_index, subclass)
  local t = setmetatable({}, { __index = PointBlankFMJSkillEffect })
  
  t.values = {0}
  t.active = false
  t.player_id = player_id
  t.skill_index = skill_index or 0

  if(not subclass) then t:initEffect() end
  return t
end
function PointBlankFMJSkillEffect:initEffect()
  registercustomcallback("onAbilityDamager", function(player, skill_index, damager)
    if self.active and skill_index == self.skill_index and player:get("id") == self.player_id then
      if damager:get("critical") == 0 then
        --dont modify if it was already a crit
        damager:set("FMJ_start_x", player.x)
      end
    end
  end)
  registercallback("onHit", function(damager, hit, x, y)
    if damager:get("FMJ_start_x") ~= nil then
      local dist = math.abs(damager:get("FMJ_start_x") - x)
      Cyclone.terminal.write(dist)
      if dist < self.values[1] then
        if damager:get("critical") == 0 then
          damager:set("critical", 1)
          damager:set("damage", damager:get("damage") * 2)
          damager:set("damage_fake", damager:get("damage_fake") * 2)
        end
      else
        if damager:get("critical") == 1 then
          damager:set("critical", 0)
          damager:set("damage", damager:get("damage") / 2)
          damager:set("damage_fake", damager:get("damage_fake") / 2)
        end
      end
    end
  end)
end
function PointBlankFMJSkillEffect:setValues(values)
  self.values = values
  self.active = (self.values[1] > 0)
end


--
AttackSpeedForCritsSkillEffect = SkillEffect:new(true)
function AttackSpeedForCritsSkillEffect:new(player_id, skill_index, skill_index_2, subclass)
  local t = setmetatable({}, { __index = AttackSpeedForCritsSkillEffect })
  
  t.values = {0}
  t.active = false
  t.player_id = player_id
  t.skill_index = skill_index or 0
  t.skill_index_2 = skill_index_2 or 0
  
  t.prev_attack_speed = 0

  if(not subclass) then t:initEffect() end
  return t
end
function AttackSpeedForCritsSkillEffect:initEffect()
  registercallback("onStep", function()
    if self.active then
      local player = Object.findInstance(self.player_id)
      local new_attack_speed = player:get("attack_speed")
      if new_attack_speed ~= self.prev_attack_speed then
        new_attack_speed = self.prev_attack_speed + ((new_attack_speed - self.prev_attack_speed) * (1 + self.values[1]))
        self.prev_attack_speed = new_attack_speed
        player:set("attack_speed", new_attack_speed)
      end
    end
  end)
  --[[registercallback("preHit", function(damager)
    if damager:get("parent") == self.player_id then
      local player = Object.findInstance(self.player_id)
      --Cyclone.terminal.write("dmg  "..player:get("damage").." "..damager:get("damage"))
      --Cyclone.terminal.write("stun  "..damager:get("stun"))
    end
  end)]]
  registercustomcallback("onAbilityDamager", function(player, skill_index, damager)
    if self.active and (skill_index == self.skill_index or skill_index == self.skill_index_2) and player:get("id") == self.player_id then
      if damager:get("critical") == 0 then
        damager:set("critical", 1)
        damager:set("damage", damager:get("damage") * 2)
        damager:set("damage_fake", damager:get("damage_fake") * 2)
      end
    end
  end)
end
function AttackSpeedForCritsSkillEffect:setValues(values)
  if values[1] ~= self.values[1] then
    local player = Object.findInstance(self.player_id)
    local new_attack_speed = player:get("attack_speed") * ((1 + values[1]) / (1 + self.values[1]))
    player:set("attack_speed", new_attack_speed)
    self.prev_attack_speed = new_attack_speed
    
    self.values = values
    self.active = (self.values[1] ~= 0)
  end
end