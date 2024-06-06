--[[

__/\\\________/\\\_____/\\\\\\\\\\\____/\\\\\\\\\\\\________/\\\\\\\\\\\___        
 _\/\\\_______\/\\\___/\\\/////////\\\_\/\\\////////\\\____/\\\/////////\\\_       
  _\//\\\______/\\\___\//\\\______\///__\/\\\______\//\\\__\//\\\______\///__      
   __\//\\\____/\\\_____\////\\\_________\/\\\_______\/\\\___\////\\\_________     
    ___\//\\\__/\\\_________\////\\\______\/\\\_______\/\\\______\////\\\______    
     ____\//\\\/\\\_____________\////\\\___\/\\\_______\/\\\_________\////\\\___   
      _____\//\\\\\_______/\\\______\//\\\__\/\\\_______/\\\___/\\\______\//\\\__  
       ______\//\\\_______\///\\\\\\\\\\\/___\/\\\\\\\\\\\\/___\///\\\\\\\\\\\/___ 
        _______\///__________\///////////_____\////////////_______\///////////_____

    A source management system by ninjaninja140, eledontlie and Virtua Electronics.

--]] local VSDS = {}

VSDS.plugin = plugin
VSDS.self = getfenv().script
VSDS.project = getfenv().game
VSDS.require = getfenv().require
VSDS.Assets = VSDS.require(VSDS.self['VSDS-ASSETS'])
VSDS.UI = VSDS.require(VSDS.self['ROACT-UI'])

VSDS = {}
VSDS.console = VSDS.require(VSDS.Assets.Plugin.Project['VSDS-LIB'].console)
VSDS.http = VSDS.require(VSDS.Assets.Plugin.Project['VSDS-LIB'].http)

VSDS.plugin:CreateToolbar(VSDS.Assets.Configuration.ToolBarTitle):CreateButton(
    VSDS.Assets.Configuration.ToolBarButton.ID,
    VSDS.Assets.Configuration.ToolBarButton.TOOLTIP,
    VSDS.Assets.Configuration.ToolBarButton.IMAGE,
    VSDS.Assets.Configuration.ToolBarButton.NAME)

VSDS.console.info('Welcome to VSDP!')
VSDS.console.info(
    'To see other logs in your game from VSDP, create a ModuleScript in Workspace titled "VSDS_CONFIGURATION" with a key inside it called "VSDS_PLUGIN_DEBUG" and set it to true.')
VSDS.console.log('Welcome to VSDP!')
VSDS.console.log('Initialising VSDP Version',
                 VSDS.Assets.Plugin.Version .. '...')

if not VSDS.plugin then
    VSDS.console.log('VSDP Should be ran in a plugin environment!')
    return
end

VSDS.httpState = VSDS.http.Test()

if not VSDS.httpState then
    VSDS.console.log(
        'VSDP is unable to initialise, error: VSDS RELEASE UNAVAILABLE')
    return
else
    VSDS.console.log('VSDP has found the VSDS repository successfully!')
end

VSDS.ApplicationUI = VSDS.UI.mount(VSDS.UI.createElement(
                                       VSDS.require(VSDS.self.Parent['VSDS-APPLICATION']),
                                       {plugin = VSDS.plugin}),
                                   VSDS.project:GetService('CoreGui'),
                                   'VSDS-Plugin-UI')

plugin.Unloading:Connect(function() VSDS.UI.unmount(VSDS.ApplicationUI) end)
