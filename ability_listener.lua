
local debug_messages = false

local callback_on_ability_damager = createcustomcallback("onAbilityDamager")
local callback_start_ability = createcustomcallback("startAbility")
local callback_end_ability = createcustomcallback("endAbility")

player_skill_timers = {}
survivor_ability_data = {}

CALLBACK_FIRE = 0
CALLBACK_HIT = 1

CHECK_DAMAGE = 0
CHECK_ATTRIBUTE = 1

registercallback("onPlayerInit", function(player)
  local data = {}
  data["player"] = player
  data["skill_index"] = 0
  data["skill_timer"] = 0
  data["skill_active"] = false
  data["skill_prev_active"] = false
  
  player_skill_timers[player:get("id")] = data
end)

function addSurvivorAbilityData(survivor_name, skill_data)
  survivor_ability_data[survivor_name] = skill_data
  
  local survivor_use_skill_callback = createcustomcallback("useSkill-"..survivor_name)
  local survivor_on_skill_callback = createcustomcallback("onSkill-"..survivor_name)
  
  local survivor = Survivor.find(survivor_name)
  survivor:addCallback("useSkill", function(player, skill)
    survivor_use_skill_callback(player, skill)
    
    local data = player_skill_timers[player:get("id")]
    data.skill_index = skill
    data.skill_timer = 0
    data.skill_active = true
    
    callback_start_ability(player, data.skill_index)
  end)
  survivor:addCallback("onSkill", function(player, skill)
    survivor_on_skill_callback(player, skill)
      
    local data = player_skill_timers[player:get("id")]
    data.skill_active = true
  end)
end

registercallback("onStep", function()
  for id, data in pairs(player_skill_timers) do
    data.skill_prev_active = data.skill_active
    if(data.skill_active) then
      data.skill_active = false
      data.skill_timer = data.skill_timer + 1
    else
      if(data.skill_index ~= 0) then
        callback_end_ability(Object.findInstance(id), data.skill_index)
      end
      
      data.skill_index = 0
      data.skill_timer = 0
    end
  end
end)

function damager_checks(callback_type, damager)
  if(damager:get("team") == "player") then
    local player = damager:getParent()
    if(player_skill_timers[player:get("id")]) then
      local data = player_skill_timers[player:get("id")]
      if(data.skill_active or data.skill_prev_active) then
        --Cyclone.terminal.write("there could be a projectile right now. frame "..tostring(data.skill_timer))
        local check_data = survivor_ability_data[player:getSurvivor():getName()][data.skill_index]
        if(check_data[1] ~= nil and check_data[1] == callback_type) then
          
          --checks
          local passed_checks = true
          for _, check in ipairs(check_data) do
            --Cyclone.terminal.write(tostring(check).." "..type(check))
            if type(check) == "table" then
              if check[1] == CHECK_DAMAGE then
                local _crit = damager:get("critical")
                local _damage = damager:get("damage")
                local _expected_damage = check[2](player:get("damage")) * (1 + _crit)
                local _error = math.abs(_damage - _expected_damage) / _damage
                
                --Cyclone.terminal.write(_damage.." "..player:get("damage").."-".._expected_damage.." ".._error)
                if(_error <= check[3]) then
                  if debug_messages then Cyclone.terminal.write("ABILITY "..data.skill_index.." PASSES NEAR DAMAGE CHECK") end
                else
                  if debug_messages then Cyclone.terminal.write("ABILITY "..data.skill_index.." FAILS NEAR DAMAGE CHECK: ".._error.."%") end
                  
                  passed_checks = false
                end
                
              elseif check[1] == CHECK_ATTRIBUTE then
                local _attrib = damager:get(check[2])
                local _error = math.abs(_attrib - check[3]) / math.max(0.01, _attrib)
                
                --Cyclone.terminal.write("attrib "..check[2].." expected: "..check[3].."  actual: ".._attrib.."  error: ".._error)
                if(_error <= check[4]) then
                  if debug_messages then Cyclone.terminal.write("ABILITY "..data.skill_index.." PASSES NEAR ATTRIBUTE CHECK") end
                else
                  if debug_messages then Cyclone.terminal.write("ABILITY "..data.skill_index.." FAILS NEAR ATTRIBUTE CHECK: "..check[2].." ".._error.."%") end
                  
                  passed_checks = false
                end
                
              end
            end
          end
          
          if(passed_checks) then
            if debug_messages then Cyclone.terminal.write("ABILITY "..data.skill_index.." PASSES ALL CHECKS") end
            callback_on_ability_damager(player, data.skill_index, damager)
          end
        end
      end
    end
  end
end

registercallback("preHit", function(damager)
  if(damager:get("damager_checked") == nil) then
    damager:set("damager_checked", 1)
    damager_checks(CALLBACK_HIT, damager)
  end
end)
registercallback("onFire", function(damager)
  damager_checks(CALLBACK_FIRE, damager)
end)
