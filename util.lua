

customcallbacks = {}
customskillcallbacks = {}
function createcustomcallback(string)
  customcallbacks[string] = {}
  customskillcallbacks[string] = {}
  
  callback = function(...)
    for _,func in ipairs(customcallbacks[string]) do
      func(...)
    end
    for _,func in ipairs(customskillcallbacks[string]) do
      func(...)
    end
  end
  return callback
end
function registercustomcallback(string, func, is_skill_related)
  if is_skill_related then
    table.insert(customskillcallbacks[string], func)
  else
    table.insert(customcallbacks[string], func)
  end
end

local on_step_copy = createcustomcallback("onStep")
registercallback("onStep", on_step_copy)
local on_hit_copy = createcustomcallback("onHit")
registercallback("onHit", on_hit_copy)
local on_npc_death_proc_copy = createcustomcallback("onNPCDeathProc")
registercallback("onNPCDeathProc", on_npc_death_proc_copy)

function resetSkillCallbacks()
  customskillcallbacks = {}
  for str,_ in pairs(customcallbacks) do
    customskillcallbacks[str] = {}
  end
end

local _missingicon = Sprite.load("missing_icon","res/missing.png", 1,11,11)
function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end
function removeColorFormatting(string)
  local color_keys = {"&r&","&g&","&b&","&y&","&or&","&bl&","&lt&","&dk&","&w&","&p&","&!&"}
  local str = string
  for _,color in ipairs(color_keys) do
    str = str:gsub(color, "")
  end
  return str
end