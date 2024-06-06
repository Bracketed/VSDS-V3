local PLUGIN = {}
local internal = {}

internal.require = getfenv().require
internal.self = getfenv().script
internal.pairs = getfenv().pairs
internal.table = getfenv().table
internal.lib = internal.self.Parent
internal.http = internal.require(internal.lib['HTTP'])
internal.console = internal.require(internal.lib['Console'])
internal.utils = internal.require(internal.lib['Utilities'])

function PLUGIN.GetReleases()
    internal.console
        .log('Getting latest VSDS release from public repository...')
    local Releases = internal.http.Get(
                         'https://api.github.com/repos/Bracketed/VSDS/releases')

    if Releases.Headers['x-ratelimit-remaining'] == 0 then
        internal.console.log(
            'Could not retrieve latest releases, you are being rate limited. Please wait:',
            internal.utils.GetRatelimitTime(), 'before checking again.')
        return
    end
    internal.console.log('Retrieved latest releases, you have',
                         Releases.Headers['x-ratelimit-remaining'],
                         'more releases for this hour.')

    print(internal.http.Decode(Releases.Body))
    return internal.http.Decode(Releases.Body)
end

function PLUGIN.FilterReleases(Releases)
    local PluginReleases = {}

    for ReleaseIndex, ReleaseContent in internal.pairs(Releases) do
        print(ReleaseContent)
        if internal.utils.StartsWith(ReleaseContent.tag_name, 'vsds-plugin') then
            internal.table.insert(PluginReleases, ReleaseContent)
        end
    end

    print(PluginReleases)
    return PluginReleases
end

function PLUGIN.GetLatestReleaseFromFilter(Releases) return Releases[0] end

function PLUGIN.CheckForUpdates(CURRENT_VER)
    local Releases = PLUGIN.GetReleases()
    Releases = PLUGIN.FilterReleases(Releases)
    Releases = PLUGIN.GetLatestReleaseFromFilter(Releases)

    print(Releases)
    if CURRENT_VER == Releases.tag_name then return Releases.tag_name end -- user_vsds-plugin-development.rbxmx.VSDS-PLUGIN.VSDS-Libraries.Internal:51: attempt to index nil with 'tag_name'
    return false
end

return PLUGIN
