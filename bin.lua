--Cyclone_Example_Bin

--The bin table that will be added
local testmod_bin = {}

--The name that will be used when calling the command
testmod_bin.name = "testmod"

--The table of commands referenced
local commands = {}

--Echo command. example: 'testmod echo hello world'
commands["echo"] = function(args, rawinput)
  argstring = ""
  for i = 2, #args do
    argstring = argstring .. " " .. args[i]
  end
  Cyclone.terminal.write(args[0] .. ": " .. argstring)
end

--Print some test data for player.
commands["showtestdata"] = function(args, rawinput)
  for i = 0, #player_ids do
    local player_instance = Object.findInstance(player_ids[i])
    Cyclone.terminal.write(player_instance:get("testdata"))
  end
end

--Check command table for a command with name matching the first argument
testmod_bin.call = function(args, rawinput)
  for name,command in pairs(commands) do
    if args[1] == name then
      command(args, rawinput)
    end
  end
end

--Adds it to the terminal
Cyclone.terminal.add(testmod_bin)