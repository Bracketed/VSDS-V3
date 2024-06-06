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
assert(VSDS.plugin,
       ':: VSDS [PLUGIN] :: VSDP Should be ran in a plugin environment!')

VSDS.require = getfenv().require
VSDS.Assets = VSDS.require(VSDS.self.Configuration)
VSDS.Roact = VSDS.require(VSDS.Assets.Container['VSDS-Packages']['Roact'])

VSDS.console = VSDS.require(VSDS.Assets.Container['VSDS-Libraries'].Console)
VSDS.http = VSDS.require(VSDS.Assets.Container['VSDS-Libraries'].HTTP)

VSDS.plugin:CreateToolbar(VSDS.Assets.Configuration.ToolBarTitle):CreateButton(
    VSDS.Assets.Configuration.ToolBarButton.ID,
    VSDS.Assets.Configuration.ToolBarButton.TOOLTIP .. ' [ Version ' ..
        VSDS.Assets.Version .. ' ]',
    VSDS.Assets.Configuration.ToolBarButton.IMAGE,
    VSDS.Assets.Configuration.ToolBarButton.NAME)

VSDS.console.info('Welcome to VSDP!')
VSDS.console.info(
    'To see other logs in your game from VSDP, create a ModuleScript in Workspace titled "VSDS_CONFIGURATION" with a key inside it called "VSDS_PLUGIN_DEBUG" and set it to true.')
VSDS.console.log('Welcome to VSDP!')
VSDS.console.log('Initialising VSDP Version', VSDS.Assets.Version .. '...')

assert(VSDS.http.Test(),
       ':: VSDS [PLUGIN] :: VSDP is unable to initialise, error: VSDS RELEASE UNAVAILABLE')

VSDS.console.log('VSDP has found the VSDS repository successfully!')

VSDS.Application = VSDS.require(VSDS.self['Application'])
assert(VSDS.Application,
       'VSDP is unable to initialise, error: UNABLE TO GET APP-UI')

VSDS.ApplicationUI = VSDS.Roact.mount(
                         VSDS.Roact.createElement(VSDS.Application,
                                                  {plugin = VSDS.plugin}),
                         VSDS.project:GetService('CoreGui'), 'VSDS-Plugin-UI')

plugin.Unloading:Connect(function() VSDS.Roact.unmount(VSDS.ApplicationUI) end)
