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

function VSDS.GetVSDSTree()
    return internal.http.Decode(internal.http.Get(
                                    'https://roblox-apis.bracketed.co.uk/vsds/loader'))
end

function VSDS.Update() end

function VSDS.Install() end

function VSDS.GetRelease()
    internal.console
        .log('Getting latest VSDS release from public repository...')
    local Releases = internal.http.Get(
                         'https://roblox-apis.bracketed.co.uk/vsds')

    if Releases.Headers['x-ratelimit-remaining'] == 0 then
        internal.console.log(
            'Could not retrieve latest releases, you are being rate limited. Please wait:',
            internal.utils.GetRatelimitTime(), 'before checking again.')
        return
    end
    internal.console.log('Retrieved latest releases, you have',
                         Releases.Headers['x-ratelimit-remaining'],
                         'more releases for this hour.')

    return internal.http.Decode(Releases.Body)
end

function VSDS.CheckForUpdates(CURRENT_VER, targetModule)
    local Releases = VSDS.GetRelease()

    if not Releases then return nil end
    if CURRENT_VER == Releases.tag_name then return Releases.tag_name end
    return nil
end

return VSDS
