local None = newproxy(true)
getmetatable(None).__tostring = function() return "None" end

return {
    None = None,
    merge = function(...)
        local output = {}

        for i = 1, select("#", ...) do
            local source = select(i, ...)

            if source ~= nil then
                for key, value in pairs(source) do
                    if value == None then
                        output[key] = nil
                    else
                        output[key] = value
                    end
                end
            end
        end

        return output
    end
}
