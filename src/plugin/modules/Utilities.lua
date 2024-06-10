local UTILS = {}
local internal = {}

internal.string = string
internal.math = math
internal.os = os

function UTILS.GetRatelimitTime()
    local currentTime = internal.os.date("*t")
    local secondsUntilNextHour = (60 - currentTime.min - 1) * 60 +
                                     (60 - currentTime.sec)
    local minutes = internal.math.floor(secondsUntilNextHour / 60)
    local seconds = secondsUntilNextHour % 60

    return internal.string.format("%02d:%02d", minutes, seconds)
end

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

return UTILS
