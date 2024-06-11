local VSDS = {}
local internal = {}

internal.require = require
internal.self = script
internal.pairs = pairs
internal.project = game
internal.table = table
internal.lib = internal.self.Parent
internal.http = internal.require(internal.lib['HTTP'])
internal.console = internal.require(internal.lib['Console'])
internal.utils = internal.require(internal.lib['Utilities'])
internal.scriptservice = internal.project:GetService('ServerScriptService')
internal.workspace = internal.project:GetService('Workspace')
internal.edit = internal.project:GetService('ScriptEditorService')

VSDS.map = {}

function VSDS.RetrieveInstall()
    internal.console.log('Checking for VSDS install...')
    for _, Instance in internal.pairs(internal.project:GetDescendants()) do
        if Instance.Name == "VSDS-SRC" and Instance:IsA('Folder') then
            internal.console.log('VSDS install found!')
            return Instance.Parent
        end
    end

    internal.console.log('VSDS install not found.')
    return nil
end

function VSDS.FindMigratables(Instance)
    local MigratableProducts = {}

    for _, script in pairs(Instance:GetDescendants()) do
        if script:IsA('Script') then
            if internal.utils.StartsWith(script.Source, 'require(16582923129)') then
                table.insert(MigratableProducts, script)
            end
        end
    end

    return MigratableProducts
end

function VSDS.Migrate(Instance)
    local VSDSInstall = VSDS.RetrieveInstall()
    if not Instance then Instance = internal.workspace end

    local MigrationSuccess, MigrationFaliureError = pcall(function()
        for _, script in pairs(Instance:GetDescendants()) do
            if script:IsA('Script') then
                if internal.utils.StartsWith(script.Source,
                                             'require(16582923129)') then
                    internal.console.log('Migrating script:',
                                         script:GetFullName())
                    internal.edit:UpdateSourceAsync(script, function(Source)
                        return internal.utils.Replace(Source, '16582923129',
                                                      'game.' ..
                                                          VSDSInstall:GetFullName())

                    end)

                    if not internal.utils.StartsWith(script.Source,
                                                     'require(game.' ..
                                                         VSDSInstall:GetFullName() ..
                                                         ')') then
                        error('Unable to apply changes to script: ' ..
                                  script:GetFullName())
                    end

                    internal.console.log(script:GetFullName(),
                                         'was migrated successfully.')
                end
            end
        end
    end)

    return MigrationSuccess
end

function VSDS.ParseRobloxInstance(AssetJSONData, isFirstAsset)
    local ParsedAsset = Instance.new(AssetJSONData["$"]["class"])

    for _, properties in ipairs(AssetJSONData["Properties"]) do
        for propertyType, propertyArray in pairs(properties) do
            for _, property in ipairs(propertyArray) do
                local propertyName = property["$"]["name"]
                local propertyValue = property["_"]

                if propertyType == "string" then
                    ParsedAsset[propertyName] = propertyValue
                elseif propertyType == "int" then
                    ParsedAsset[propertyName] = tonumber(propertyValue)
                elseif propertyType == "bool" then
                    ParsedAsset[propertyName] = propertyValue == "true"
                elseif propertyType == "float" then
                    ParsedAsset[propertyName] = tonumber(propertyValue)
                end
            end
        end
    end

    if (isFirstAsset) then ParsedAsset.Name = "VSDS" end

    local instanceId = itemData["$"]["referent"]
    VSDS.map[instanceId] = ParsedAsset

    return ParsedAsset
end

function VSDS.GetVSDSTree()
    return internal.http.Decode(internal.http.Get(
                                    'https://roblox-apis.bracketed.co.uk/vsds/loader'))
end

function VSDS.Update()
    local vsds = VSDS.RetrieveInstall()

    if (not vsds) then return false end
    vsds:Destroy()

    local install = VSDS.Install()
    return install
end

function VSDS.Install()
    VSDS.map = {}

    local VSDSTree = VSDS.GetVSDSTree()
    if (VSDSTree['message']) then return false end

    local isFirst = true
    for _, itemData in ipairs(data["roblox"]["Item"]) do
        VSDS.ParseRobloxInstance(itemData, isFirst)
        isFirst = false
    end

    for _, AssetJSONData in ipairs(data["roblox"]["Item"]) do
        local instanceId = AssetJSONData["$"]["referent"]
        local newInstance = instanceMap[instanceId]

        local parentIdentifier = AssetJSONData["Properties"]["Parent"]
        if parentIdentifier then
            parentIdentifier = parentIdentifier[1]["Ref"]
            newInstance.Parent = instanceMap[parentIdentifier] or
                                     internal.scriptservice
        else
            newInstance.Parent = internal.scriptservice
        end
    end

    return true
end

function VSDS.GetRelease()
    internal.console
        .log('Getting latest VSDS release from public repository...')
    local Releases = internal.http.Get(
                         'https://roblox-apis.bracketed.co.uk/vsds/plugin')

    internal.console.log('Retrieved latest release data from VSDS API.')
    return internal.http.Decode(Releases.Body)
end

function VSDS.CheckForPluginUpdates(CURRENT_VER)
    local Releases = VSDS.GetPluginRelease()

    if not Releases then return nil end
    if CURRENT_VER == Releases.tag_name then return Releases.tag_name end
    return nil
end

function VSDS.CheckForLoaderUpdates(CURRENT_VER)
    local Releases = VSDS.GetRelease()

    if not Releases then return nil end
    if CURRENT_VER == Releases.tag_name then return Releases.tag_name end
    return nil
end

return VSDS
