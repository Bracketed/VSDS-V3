local VSDS = {}
local internal = {}

internal.project = getfenv().game
internal.require = getfenv().require
internal.self = getfenv().script
internal.pairs = getfenv().pairs
internal.lib = internal.self.Parent
internal.console = internal.require(internal.lib['console'])
internal.scriptservice = internal.project:GetService('ServerScriptService')

function VSDS.RetrieveInstall()
    internal.console.log('Checking for VSDS install...')
    for _, Instance in internal.pairs(internal.scriptservice:GetDecendants()) do
        if Instance.Name == "VSDS-SRC" and Instance:IsA('Folder') then
            internal.console.log('VSDS install found!')
            return Instance.Parent
        end
    end

    internal.console.log('VSDS install not found.')
    return nil
end

function VSDS.Download() end

function VSDS.Update() end

function VSDS.Install() end

return VSDS
