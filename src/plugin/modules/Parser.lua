return function(jsonContent, parentInstance)
    local function splitLongString(str, partSize)
        local parts = {}
        for i = 1, #str, partSize do
            table.insert(parts, str:sub(i, i + partSize - 1))
        end
        return parts
    end

    local function createInstance(instanceData, parent)
        local className = instanceData["$"].class

        if className == "Part" or className == "MeshPart" or className ==
            "UnionOperation" or className == "BasePart" then return end

        local newInstance = Instance.new(className, parent)

        if instanceData.Properties then
            for _, property in ipairs(instanceData.Properties) do
                for propertyType, propertyValues in pairs(property) do
                    for _, propertyValue in ipairs(propertyValues) do
                        local propName = propertyValue["$"].name
                        local value = propertyValue["_"]

                        pcall(function()
                            newInstance[propName] = value
                        end)
                    end
                end
            end
        end

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
