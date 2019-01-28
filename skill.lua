
Skill = {}

function Skill:new(name, description_template, variable_description_values, num_levels, icon, skill_effects, skill_effect_values, icon_x, icon_y)
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
  t.name_trimmed = removeColorFormatting(name)
  t.description_template = description_template or "no description available"
  t.description = t.description_template
  t.description_trimmed = t.description_template
  t.variable_description_values = variable_description_values or {}
  t.current_level = 0
  t.num_levels = num_levels or 1
  t.skill_effects = skill_effects
  t.skill_effect_values = skill_effect_values
  
  t.icon_x = icon_x
  t.icon_y = icon_y
  t.button = nil
  
  t.hover_frame_count = 0
  t.unhover_frame_count = 0
  
  t.skill_point_available = false
  t.skill_available = false
  
  t.parents = {}
  t.children = {}
  
  t:refresh()
  
  registercallback("onStep", function()
    if(t.button and t.button.highlighted) then
      t.hover_frame_count = t.hover_frame_count + 1
      t.unhover_frame_count = 0
    else
      t.unhover_frame_count = t.unhover_frame_count + 1
      
      if(t.unhover_frame_count > 1) then
        t.hover_frame_count = 0
      end
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
  if(self.skill_effects) then
    for i,skill_effect in ipairs(self.skill_effects) do
      skill_effect:setValues(self.skill_effect_values[i][self.current_level + 1])
    end
    --[[if(self.skill_effect.deactivate_at_level_zero) then
      if(self.current_level == 0) then
        self.skill_effect:deactivateEffect()
      else
        self.skill_effect:activateEffect()
      end
    end]]
  end
  
  
  self:updateDescription()
end

function Skill:updateDescription()
  local desc = self.description_template
  
  for i=0, #self.variable_description_values-1 do
    local new_val = ""
    if(self.current_level == 0) then
      new_val = self.variable_description_values[i+1][self.current_level+1]
    else
      new_val = self.variable_description_values[i+1][self.current_level+0]
      if (self.skill_available and self.skill_point_available and self.current_level < self.num_levels) then
        new_val = new_val.." &g&("..(self.variable_description_values[i+1][self.current_level+1])..")"--&!&"
      end
    end
    desc = desc:gsub("|"..tostring(i).."|", new_val)
  end
  
  self.description = desc
  self.description_trimmed = removeColorFormatting(desc)
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


    
    