--[[

__/\\\________/\\\_____/\\\\\\\\\\\____/\\\\\\\\\\\\________/\\\\\\\\\\\___        
 _\/\\\_______\/\\\___/\\\/////////\\\_\/\\\////////\\\____/\\\/////////\\\_       
  _\//\\\______/\\\___\//\\\______\///__\/\\\______\//\\\__\//\\\______\///__      
   __\//\\\____/\\\_____\////\\\_________\/\\\_______\/\\\___\////\\\_________     
    ___\//\\\__/\\\_________\////\\\______\/\\\_______\/\\\______\////\\\______    
     ____\//\\\/\\\_____________\////\\\___\/\\\_______\/\\\_________\////\\\___   
      _____\//\\\\\_______/\\\______\//\\\__\/\\\_______/\\\___/\\\______\//\\\__  
       ______\//\\\_______\///\\\\\\\\\\\/___\/\\\\\\\\\\\\/___\///\\\\\\\\\\\/___ 
        _______\///__________\///////////_____\////////////_______\///////////_____

    A source management system by ninjaninja140, eledontlie and Virtua Electronics.

--]] local VSDS = {}
VSDS.script = script

local function print(...)
    if (workspace:GetAttribute('VSDS-Debug')) then
        warn(':: Virtua Electronics ::', ...)
    end
end

function VSDS.Deploy(script, ...)
    local __SRC = VSDS.script['VSDS-SOURCE']

    local arguments = {...}
    local _G = script
    local type = arguments[1]
    local script = arguments[2]

    table.remove(arguments, 1)
    table.remove(arguments, 2)

    for _, __DIST in pairs(__SRC:GetChildren()) do
        if (string.lower(__DIST.Name) == string.lower(type)) then
            for _, Module in pairs(__DIST:GetChildren()) do
                if (string.lower(Module.Name) == string.lower(script)) then
                    require(Module).run(_G, arguments)
                end
            end
        end
    end
end

return VSDS
