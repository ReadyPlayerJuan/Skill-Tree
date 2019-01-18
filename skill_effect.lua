
SkillEffect = {}

function SkillEffect:new(subclass)
  local t = setmetatable({}, { __index = SkillEffect })
  
  t.values = {0}
  t.active = false
  if(not subclass) then t:init() end
  
  return t
end

function SkillEffect:init()
end

function SkillEffect:activate()
  self.active = true
end

function SkillEffect:deactivate()
  self.active = false
end

function SkillEffect:setValues(values)
  self.values = values
end

--[[function SkillEffect:resetEffect()
  --reset skill's effect here
end

function SkillEffect:enactEffect()
  --enact skills effect at current level here
end]]