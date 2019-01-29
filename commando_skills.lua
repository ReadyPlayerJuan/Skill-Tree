
require("ability_listener")
require("skill_effect")

--[[
  ideas:
    suppressive fire lasts longer
    suppressive fire lasts until you release key
    bonus attack speed at low health
    suppressive fire is faster
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
  
  local sk_crit_healing = Skill:new("Lifelink",
      "Critical hits heal for &y&|0|&!& of missing health.",
      {{"2%%", "3.5%%", "5%%"}}, 3,
      nil, {HealOnCritSkillEffect:new(player_id, false, true)},
      {{{0},{0.02},{0.035},{0.05}}}, 
      1.5, 1)
  
  local sk_crit_damage = Skill:new("Lethal Precision",
      "Critical hits deal &y&|0|&!& extra damage. (&y&|1|&!& damage total)",
      {{"12.5%%", "25%%", "37.5%%", "50%%"}, {"215.5%%", "225%%", "237.5%%", "250%%"}}, 4,
      nil, {CritDamageSkillEffect:new(player_id)},
      {{{0},{0.125},{0.25},{0.375},{0.5}}},
      2, 0)
  
  local sk_attack_speed = Skill:new("Itchy Trigger Finger",
      "Increases attack speed by &y&|0|.&!&",
      {{"7.5%%", "15%%", "22.5%%", "30%%"}}, 4,
      "health", {AttackSpeedSkillEffect:new(player_id)},
      {{{0},{0.075},{0.15},{0.225},{0.30}}}, 
      4, 0.5)
  
  local sk_health = Skill:new("Resilient",
      "Increases max health by &y&|0|.&!&",
      {{"80", "160", "240"}}, 3,
      "health", {FlatHealthSkillEffect:new(player_id)},
      {{{0},{80},{160},{240}}}, 
      0.5, 0)
  
  local sk_damage_fmj = Skill:new("More Metal Jackets",
      "&or&Full Metal Jacket&!& does &y&|0|&!& damage.",
      {{"1.2x", "1.4x", "1.6x"}}, 4,
      "skill", {AbilityDamageSkillEffect:new(player_id, 2)},
      {{{0},{.2},{.4},{.6}}}, 
      3, 0)
  
  local sk_point_blank_fmj = Skill:new("Point Blank",
      "&or&Full Metal Jacket&!& always crits at very close range.",
      {}, 1,
      nil, {PointBlankFMJSkillEffect:new(player_id)}, {{{0},{20}}},
      2.5, 1)
  
  local sk_attack_speed_for_crit = Skill:new("Steady Aim",
      "Attack speed is permanently cut by &y&|0|,&!& but &or&Double Tap&!& and\n&or&Suppressive Fire&!& always crit.",
      {{"45%%"}}, 1,
      nil, {PersistentAttackSpeedSkillEffect:new(player_id), AlwaysCritSkillEffect:new(player_id, 1, 4)},
      {{{0},{-0.45}}, {{0},{1}}},
      2, 2)
  
  local sk_faster_suppressive_fire = Skill:new("fast suppressive",
      "&or&Suppressive Fire&!& shoots &y&|0|&!& faster.",
      {{"10%%","20%%","30%%"}}, 3,
      nil, {AttackSpeedDuringAbilitySkillEffect:new(player_id, 4)},
      {{{0},{0.1},{0.2},{0.3}}},
      4, 1.5)
  
  local sk_continuous_suppressive_fire = Skill:new("Endless Clip",
      "&or&Suppressive Fire&!& will last for as long as you hold down the ability.",
      {}, 1,
      nil, {ContinuousSuppressiveFireSkillEffect:new(player_id)},
      {{{0},{1}}},
      3.5, 2.5)
  
  local sk_roll_speed = Skill:new("Rounder Knees",
      "&or&Tactical Dive&!& travels &y&|0|&!& more distance.",
      {{"1.5x", "2.0x"}}, 2,
      nil, {MoveSpeedDuringAbilitySkillEffect:new(player_id, 3)},
      {{{0},{0.5},{1.0}}},
      0, 1.5)
  
  local sk_roll_cd = Skill:new("Acrobatics",
      "On kill, refunds &y&|0|&!& of &or&Tactical Dive's&!& remaining cooldown,\nbut the base cooldown is &y&|1|&!& as long.",
      {{"25%%", "50%%", "100%%"}, {"1.5x", "2.0x", "3.0x"}}, 3,
      nil, {AbilityResetOnKillSkillEffect:new(player_id, 3), AbilityCooldownSkillEffect:new(player_id, 3)},
      {{{0},{0.25},{0.5},{1.0}}, {{0},{0.5},{1.0},{2.0}}},
      0, 2.5)
    
  sk_health:addChildren(sk_roll_speed, sk_crit_healing)
  sk_roll_speed:addChildren(sk_roll_cd)
  sk_damage_fmj:addChildren(sk_point_blank_fmj)
  sk_crit_damage:addChildren(sk_crit_healing, sk_point_blank_fmj)
  sk_crit_healing:addChildren(sk_attack_speed_for_crit)
  sk_attack_speed:addChildren(sk_faster_suppressive_fire)
  sk_faster_suppressive_fire:addChildren(sk_continuous_suppressive_fire)
  
  skilltree:addSkill(sk_crit_damage)
  skilltree:addSkill(sk_attack_speed)
  skilltree:addSkill(sk_health)
  skilltree:addSkill(sk_crit_healing)
  skilltree:addSkill(sk_damage_fmj)
  skilltree:addSkill(sk_point_blank_fmj)
  skilltree:addSkill(sk_attack_speed_for_crit)
  skilltree:addSkill(sk_faster_suppressive_fire)
  skilltree:addSkill(sk_continuous_suppressive_fire)
  skilltree:addSkill(sk_roll_speed)
  skilltree:addSkill(sk_roll_cd)
  skilltree:refresh()
  
  return skilltree
end



--
--        COMMANDO SPECIFIC SKILL EFFECTS
--
--full metal jacket will always crit at close range
PointBlankFMJSkillEffect = SkillEffect:new(true)
function PointBlankFMJSkillEffect:new(player_id, subclass)
  local t = setmetatable({}, { __index = PointBlankFMJSkillEffect })
  
  t.values = {0}
  t.active = false
  t.player_id = player_id
  t.skill_index = 2

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
  end, true)
  registercustomcallback("onHit", function(damager, hit, x, y)
    if damager:get("FMJ_start_x") ~= nil then
      local dist = math.abs(damager:get("FMJ_start_x") - x)
      local player = Object.findInstance(self.player_id)
      
      if dist < self.values[1] then
        if damager:get("critical") == 0 then
          damager:set("critical", 1)
          damager:set("damage", damager:get("damage") * player:get("critical_damage"))
          damager:set("damage_fake", damager:get("damage_fake") * player:get("critical_damage"))
        end
      else
        if damager:get("critical") == 1 then
          damager:set("critical", 0)
          damager:set("damage", damager:get("damage") / player:get("critical_damage"))
          damager:set("damage_fake", damager:get("damage_fake") / player:get("critical_damage"))
        end
      end
    end
  end, true)
end
function PointBlankFMJSkillEffect:setValues(values)
  self.values = values
  self.active = (self.values[1] > 0)
end



--full metal jacket will always crit at close range
ContinuousSuppressiveFireSkillEffect = SkillEffect:new(true)
function ContinuousSuppressiveFireSkillEffect:new(player_id, subclass)
  local t = setmetatable({}, { __index = ContinuousSuppressiveFireSkillEffect })
  
  t.values = {0}
  t.active = false
  t.player_id = player_id
  t.skill_index = 4
  
  t.skill_held = false
  t.skill_cooldown = 0
  
  t.skill_length = 0
  t.skill_cutoff_length = 0
  t.skill_timer = 0
  t.prev_attack_speed = 0
  
  if(not subclass) then t:initEffect() end
  return t
end
function ContinuousSuppressiveFireSkillEffect:initEffect()
  --[[registercustomcallback("startAbility", function(player, skill_index)
    if self.active and skill_index == self.skill_index and player:get("id") == self.player_id then
      self.skill_held = true
    end
  end, true)]]
  registercustomcallback("onSkill-Commando", function(player, skill_index)
    if self.active and math.floor(skill_index) == self.skill_index and player:get("id") == self.player_id then
      self.skill_timer = self.skill_timer + 1
      local as = player:get("attack_speed")
      if as ~= self.prev_attack_speed then
        self.prev_attack_speed = as
        self.skill_length = math.max(17, math.ceil(47 / as))
        self.skill_cutoff_length = math.floor(self.skill_length * 0.85)
      end
      
      local inp = player:control("ability4")
      if inp == input.RELEASED or (self.skill_cutoff_length ~= 0 and self.skill_timer >= self.skill_cutoff_length) then
        player:set("activity", 0)
        player:set("activity_type", 0)
      else
        
        if self.skill_cooldown == 0 then
          self.skill_cooldown = player:getAlarm(5)
        else
          player:setAlarm(5, self.skill_cooldown)
        end
      end
    end
  end, true)
  registercustomcallback("endAbility", function(player, skill_index)
    if self.active and skill_index == self.skill_index and player:get("id") == self.player_id then
      local inp = player:control("ability4")
      
      Cyclone.w(self.prev_attack_speed.." "..self.skill_timer)
      self.skill_cooldown = 0
      self.skill_timer = 0
      if inp == input.HELD then
        player:set("force_v", 1)
        player:setAlarm(5, 0)
      end
    end
  end, true)
end
function ContinuousSuppressiveFireSkillEffect:setValues(values)
  self.values = values
  self.active = (self.values[1] > 0)
end