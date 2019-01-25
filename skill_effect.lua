
require("ability_listener")

--base abstract skill effect
SkillEffect = {}
function SkillEffect:new(subclass)
  local t = setmetatable({}, { __index = SkillEffect })
  
  t.values = {}
  t.active = false
  t.deactivate_at_level_zero = false
  
  return t
end
function SkillEffect:initEffect() end
function SkillEffect:activateEffect() self.active = true end
function SkillEffect:deactivateEffect() self.active = false end
function SkillEffect:setValues(values) self.values = values end


--test skill effect, prints its value
TestSkillEffect = SkillEffect:new(true)
function TestSkillEffect:new(subclass)
  local t = setmetatable({}, { __index = TestSkillEffect })
  
  t.values = {0}
  
  if(not subclass) then t:initEffect() end
  return t
end
function TestSkillEffect:initEffect()
  registercallback("onStep", function()
    if(self.active) then
      Cyclone.terminal.write("test skill: "..tostring(self.values[1]))
    end
  end)
end
function TestSkillEffect:setValues(values)
  self.values = values
  self.active = (self.values[1] > 0)
end


--flat health bonus
FlatHealthSkillEffect = SkillEffect:new(true)
function FlatHealthSkillEffect:new(subclass)
  local t = setmetatable({}, { __index = FlatHealthSkillEffect })
  
  t.values = {0}
  t.prev_values = {0}
  
  if(not subclass) then t:initEffect() end
  return t
end
function FlatHealthSkillEffect:setValues(values)
  self.prev_values = self.values
  self.values = values
  
  for _, player in ipairs(misc.players) do
    local _prev_maxhp = player:get("maxhp_base")
    local _new_maxhp = _prev_maxhp + (self.values[1] - self.prev_values[1])
    
    local _prev_hp = player:get("hp")
    local _new_hp = min(_prev_hp, _new_maxhp)
    
    player:set("maxhp_base", _new_maxhp)
    player:set("maxhp", _new_maxhp)
    player:set("hp", _new_hp)
  end
end


--change damage of one ability by a percentage (value of 0.5 = 50% damage increase)
ProjectileDamageSkillEffect = SkillEffect:new(true)
function ProjectileDamageSkillEffect:new(survivor_name, skill_index, expected_damage_pct, subclass)
  local t = setmetatable({}, { __index = ProjectileDamageSkillEffect })
  
  t.values = {0}
  t.active = true
  t.deactivate_at_level_zero = true
  t.survivor = Survivor.find(survivor_name)
  t.skill_index = skill_index or 0

  if(not subclass) then t:initEffect() end
  return t
end
function ProjectileDamageSkillEffect:initEffect()
  registercustomcallback("onAbilityDamager", function(player, skill_index, damager)
    if skill_index == self.skill_index and player:getSurvivor() == self.survivor then
      local _prev_damage = damager:get("damage")
      local _prev_damage_fake = damager:get("damage_fake")
      local _new_damage = _prev_damage * (1 + self.values[1])
      local _new_damage_fake = _prev_damage_fake * (1 + self.values[1])
      damager:set("damage", _new_damage)
      damager:set("damage_fake", _new_damage_fake)
      Cyclone.terminal.write("set damage")
    end
  end)
end
function ProjectileDamageSkillEffect:setValues(values)
  self.values = values
  self.active = true--(self.values[1] > 0)
end