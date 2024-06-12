local UTILS = {}
local internal = {}

internal.string = string
internal.math = math
internal.os = os

function UTILS.StartsWith(str, search)
    return internal.string.sub(str, 1, internal.string.len(search)) == search
end

function UTILS.EndsWith(str, search)
    return search == "" or
               internal.string.sub(str, -internal.string.len(search)) == search
end

function UTILS.Contains(str, substr)
    return internal.string.find(str, substr) ~= nil
end

function UTILS.Replace(str, target, replacement)
    local result, _ = internal.string.gsub(str, target, replacement)
    return result
end

function UTILS.FullNameFix(FullName)
    local start, stop, toFix = string.find(FullName, "([^.]+%-[^.]+)")

    if not toFix then return FullName end
    FullName = string.sub(FullName, 1, start - 1) .. "['" .. toFix .. "']" ..
                   string:sub(FullName, stop + 1)

    return FullName
end

return UTILS
