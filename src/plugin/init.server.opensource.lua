local VSDS = {}

VSDS.plugin = plugin
VSDS.self = getfenv().script
VSDS.require = getfenv().require
VSDS.Assets = VSDS.require(VSDS.self['VSDS-ASSETS'])
VSDS.UI = VSDS.Assets.Require(VSDS.Assets.Plugin.Project['ROACT-UI'])

VSDS.ELAPSEDCOUNT = 0

VSDS.lib = {}
VSDS.lib.console = VSDS.Assets.Require(VSDS.Assets.Plugin.Libraries.console)
VSDS.lib.ui = VSDS.Assets.Require(VSDS.Assets.Plugin.Libraries.ui)
VSDS.lib.http = VSDS.Assets.Require(VSDS.Assets.Plugin.Libraries.http)
VSDS.lib.vsds = VSDS.Assets.Require(VSDS.Assets.Plugin.Libraries.vsds)
VSDS.lib.plugin = VSDS.Assets.Require(VSDS.Assets.Plugin.Libraries.plugin)

VSDS.lib.app = VSDS.Assets.Require(VSDS.Assets.Plugin.Application)

VSDS.plugin:CreateToolbar(ASSETS.Configuration.ToolBarTitle):CreateButton(
    ASSETS.Configuration.ToolBarButton)

VSDS.lib.console.log('Welcome to VSDP!')
VSDS.lib.console.log('Initialising VSDP Version',
                     VSDS.Assets.Plugin.Version .. '...')

if not VSDS.plugin then
    VSDS.lib.console.log('VSDP Should be ran in a plugin environment!')
    return
end

VSDS.ApplicationUI = VSDS.UI.createElement(VSDS.lib.app)
VSDS.ApplicationUITree = VSDS.UI.mount(VSDS.ApplicationUI,
                                       VSDS.Assets.Services.CoreGui,
                                       VSDS.Assets.Configuration.CoreUITitle)

VSDS.httpState = VSDS.lib.http.Test()

if not VSDS.httpState then
    VSDS.lib.ui.Notify(
        'VSDP was unable to initalise, we were unable to find the public VSDS repository.')
    VSDS.lib.console.log(
        'VSDP is unable to initialise, error: VSDS RELEASE UNAVAILABLE')
    return
else
    VSDS.lib.console.log('VSDP has found the VSDS repository successfully!')
end

VSDS.lib.ui.BrandingShow()
VSDS.lib.console.log('VSDP initialised! [ Started plugin successfully in',
                     string.sub(getfenv().tick() - VSDS.Assets.Tick, 1, 5),
                     ' seconds! ]')

VSDS.Install = VSDS.lib.vsds.RetrieveInstall()

if not VSDS.installState then
    VSDS.lib.ui.Prompt(
        'You do not have VSDS installed but Virtua products are in-game, would you like to install VSDS?', -- paraphrase this
        VSDS.lib.vsds.Install())
end

plugin.Unloading:Connect(function() VSDS.UI.unmount(VSDS.ApplicationUITree) end)
VSDS.Assets.Services.RunService.Heartbeat:Connect(function(heartbeat)
    VSDS.ELAPSEDCOUNT = VSDS.ELAPSEDCOUNT + heartbeat

    if VSDS.ELAPSEDCOUNT >= 5 * 60 then
        VSDS.ELAPSEDCOUNT = VSDS.ELAPSEDCOUNT - 5 * 60
        local NewerVersion = VSDS.lib.plugin.CheckForUpdates(VSDS.Assets.Plugin
                                                                 .Version)

        if NewerVersion then
            VSDS.lib.ui.Notify(
                'Attention! A newer VSDP Version is available: Version',
                NewerVersion)
        end

        -- save for vsds update sthing
        VSDS.lib.ui.Prompt(
            'It seems like your VSDS loader is out of date, would you like to update to the lastest version?',
            VSDS.lib.vsds.Update())
    end
end)
