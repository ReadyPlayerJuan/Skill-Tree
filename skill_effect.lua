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
  t.active = false
  
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