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
  t.last_used_skill_index = 0
  t.last_used_skill_timer = 0
  t.expected_damage_pct = expected_damage_pct
  t.max_error = 0.05

  if(not subclass) then t:initEffect() end
  return t
end
function ProjectileDamageSkillEffect:initEffect()
  registercallback("onStep", function()
    --if(self.active) then
      self.last_used_skill_timer = self.last_used_skill_timer + 1
    --end
  end)
  self.survivor:addCallback("useSkill", function(player, skill)
    if(self.active) then
      if(skill == self.skill_index) then
        self.last_used_skill_timer = 0
      end
      self.last_used_skill_index = skill
    end
  end)
  self.survivor:addCallback("onSkill", function(player, skill)
    if(self.active) then
      if(skill == self.skill_index) then
        self.last_used_skill_timer = -1 --set to -1 because onStop increases by 1 immediately afterwards
      end
      self.last_used_skill_index = skill
    end
  end)
  registercallback("onFire", function(damager)
    if(self.active) then
      if(damager:get("team") == "player" and self.skill_index == self.last_used_skill_index and self.last_used_skill_timer == 0) then
        for _, player in ipairs(misc.players) do
          if(player:get("id") == damager:get("parent")) then
            local _crit = damager:get("critical")
            local _prev_damage = damager:get("damage")
            local _expected_damage = player:get("damage") * self.expected_damage_pct * (1 + _crit)
            local _error = abs(_expected_damage - _prev_damage) / _prev_damage
            
            --Cyclone.terminal.write(_expected_damage.."  "..damager:get("damage").."  "..(100*_error).."% error")
            if(_error < self.max_error) then
              
              local _prev_damage_fake = damager:get("damage_fake")
              local _new_damage = _prev_damage * (1 + self.values[1])
              local _new_damage_fake = _prev_damage_fake * (1 + self.values[1])
              damager:set("damage", _new_damage)
              damager:set("damage_fake", _new_damage_fake)
            end
            --Cyclone.terminal.write("set damage "..self.last_used_skill_index.."   timer: "..self.last_used_skill_timer)
          end
        end
      end
    end
  end)
end
function ProjectileDamageSkillEffect:setValues(values)
  self.values = values
  self.active = true--(self.values[1] > 0)
end