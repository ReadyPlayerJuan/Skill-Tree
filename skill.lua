
Skill = {}

function Skill:new(name, description_template, variable_description_values, num_levels, icon, skill_effect, skill_effect_values)
  local t = setmetatable({}, { __index = Skill })
  
  if(icon) then
    if(Sprite.find(icon)) then
      t.icon = Sprite.find(icon)
    else
      t.icon = Sprite.load(icon,"res/"..icon..".png", 1,11,11)
    end
  else
    t.icon = Sprite.find("missing_icon")
  end
  
  t.name = name or "unnamed"
  t.description_template = description_template or "no description available"
  t.description = t.description_template
  t.variable_description_values = variable_description_values or {}
  t.current_level = 0
  t.num_levels = num_levels or 1
  t.skill_effect = skill_effect
  t.skill_effect_values = skill_effect_values
  
  t.hover_frame_count = 0
  
  t.skill_point_available = false
  t.skill_available = false
  
  t.parents = {}
  t.children = {}
  
  t:refresh()
  
  registercallback("onStep", function()
    if(t.button and t.button.highlighted) then
      t.hover_frame_count = t.hover_frame_count + 1
    else
      t.hover_frame_count = 0
    end
  end)
  
  return t
end

function Skill:setLevel(level)
  self.current_level = level
  self:refresh()
end

function Skill:resetLevel()
  self:setLevel(0)
end

function Skill:increaseLevel()
  self:setLevel(self.current_level + 1)
end

function Skill:addChildren(...)
  for i,child in pairs{...} do
    self.children[#self.children + 1] = child
    child.parents[#child.parents + 1] = self
  end
end

function Skill:refresh()
  if(self.skill_effect) then
    self.skill_effect:setValues(self.skill_effect_values[self.current_level + 1])
    
    if(self.skill_effect.deactivate_at_level_zero) then
      if(self.current_level == 0) then
        self.skill_effect:deactivateEffect()
      else
        self.skill_effect:activateEffect()
      end
    end
  end
  
  
  self:updateDescription()
end

function Skill:updateDescription()
  local desc = self.description_template
  
  if(not skill_available) then
    local color_keys = {"&r&","&g&","&b&","&y&","&or&","&bl&","&lt&","&dk&","&w&","&p&","&!&"}
    for i=1, #color_keys do
      desc = desc:gsub(color_keys[i], "")
    end
  end
  
  for i=0, #self.variable_description_values-1 do
    local new_val = ""
    if(self.current_level == 0) then
      new_val = self.variable_description_values[i+1][self.current_level+1]
    else
      new_val = self.variable_description_values[i+1][self.current_level+0]
      if (self.skill_available and self.skill_point_available and self.current_level < self.num_levels) then
        new_val = new_val.." ("..(self.variable_description_values[i+1][self.current_level+1])..")"
      end
    end
    desc = desc:gsub("|"..tostring(i).."|", new_val)
  end
  
  self.description = desc
  return desc
end

function Skill:printDebugInfo()
  for i=0, self.num_levels do
    self.current_level = i
    self:refresh()
    
    print(self.name..": "..self.description)
    if(Cyclone) then
      Cyclone.terminal.write(self.name..": "..self.description)
    end
  end
end


    
    