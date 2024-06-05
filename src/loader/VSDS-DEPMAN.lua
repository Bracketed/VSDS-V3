local __V1 = {}

local __INTERNAL = script
local __SRC = __INTERNAL.Parent['VSDS-SRC']

local function print(...) warn(':: Virtua Electronics ::', ...) end

function __V1.Run(...)
    local arguments = {...}
    local success = false
    local _G = arguments[1]
    local type = arguments[2]
    local script = arguments[3]

    table.remove(arguments, 1)
    table.remove(arguments, 2)
    table.remove(arguments, 3)

    for _, __DIST in pairs(__SRC:GetChildren()) do
        if (string.lower(__DIST.Name) == string.lower(type)) then
            for _, Module in pairs(__DIST:GetChildren()) do
                if (string.lower(Module.Name) == string.lower(script)) then
                    require(Module).run(_G, arguments)

                    success = true
                end
            end
        end
    end

    return success
end

return __V1
