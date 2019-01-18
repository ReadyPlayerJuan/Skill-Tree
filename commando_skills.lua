
require("skill_effect")


TestSkillEffect = SkillEffect:new(true)

function TestSkillEffect:new(subclass)
  local t = setmetatable({}, { __index = TestSkillEffect })
  
  t.values = {0}
  t.active = false
  if(not subclass) then t:init() end
  
  return t
end

function TestSkillEffect:init()
  registercallback("onStep", function()
    Cyclone.terminal.write("test skill: "..tostring(self.values[1]))
  end)
end