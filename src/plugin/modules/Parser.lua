return function(jsonContent, parentInstance)
    local function splitLongString(str, partSize)
        local parts = {}
        for i = 1, #str, partSize do
            table.insert(parts, str:sub(i, i + partSize - 1))
        end
        return parts
    end

    local function appendLongString(newInstance, propName, value)
        local parts = splitLongString(value, 199999)
        newInstance[propName] = parts[1]
        for i = 2, #parts do
            newInstance[propName] = newInstance[propName] .. parts[i]
        end
    end

    local function createInstance(instanceData, parent)
        local className = instanceData["$"].class
        local newInstance = Instance.new(className)

        if instanceData.Properties then
            for _, property in ipairs(instanceData.Properties) do
                for propertyType, propertyValues in pairs(property) do
                    for _, propertyValue in ipairs(propertyValues) do
                        local propName = propertyValue["$"].name
                        local value = propertyValue["_"]

                        if type(value) == "string" and #value > 200000 then
                            appendLongString(newInstance, propName, value)
                        else
                            newInstance[propName] = value
                        end
                    end
                end
            end
        end

        newInstance.Parent = parent

        if instanceData.Item then
            for _, childData in ipairs(instanceData.Item) do
                createInstance(childData, newInstance)
            end
        end

        return newInstance
    end

    local vsdsInstance = Instance.new("Folder", parentInstance)
    vsdsInstance.Name = "VSDS-SRC"

    createInstance(jsonContent, vsdsInstance)

    return vsdsInstance
end
