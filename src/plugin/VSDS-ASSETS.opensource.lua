local ASSETS = {}

-- // Library Storage
ASSETS.Plugin = {}
ASSETS.Services = {}
ASSETS.Configuration = {}

-- // Default Built-ins for VSDS Assets
ASSETS.Project = getfenv().game
ASSETS.Tick = getfenv().tick
ASSETS.Require = getfenv().require
ASSETS.Pairs = getfenv().pairs
ASSETS.String = getfenv().string
ASSETS.Math = getfenv().math
ASSETS.OS = getfenv().os

-- // Plugin Config
ASSETS.Configuration.ToolBarLogo =
    'https://www.roblox.com/asset/?id=17735487445'
ASSETS.Configuration.ToolBarTitle = 'Plugins by Virtua.'
ASSETS.Configuration.ToolBarButton = {
    ID = 'VSDS',
    TOOLTIP = 'VSDS Importer Plugin by Virtua.',
    IMAGE = ASSETS.Configuration.ToolBarLogo,
    NAME = 'VSDS Importer Plugin'
}
ASSETS.Configuration.ClickableWhenViewportHidden = false
ASSETS.Configuration.CoreUITitle = 'VSDS-Plugin-UI'

-- // Plugin Assets
ASSETS.Plugin.Project = getfenv().script.Parent
ASSETS.Plugin.Libraries = ASSETS.Plugin.Project['VSDS-LIB']
ASSETS.Plugin.Version = ASSETS.Plugin.Project['VSDS-VER'].Value
ASSETS.Plugin.UI = ASSETS.Plugin.Project['VSDS-UI']
ASSETS.Plugin.Application = ASSETS.Plugin.Project['VSDS-APPLICATION']
ASSETS.Plugin.FlipperUtil = ASSETS.Plugin.Project['FLIPPER-UI']

-- // Plugin Services
ASSETS.Services.RunService = ASSETS.Project:GetService('RunService')
ASSETS.Services.HttpService = ASSETS.Project:GetService('HttpService')
ASSETS.Services.ServerScriptService = ASSETS.Project:GetService(
                                          'ServerScriptService')
ASSETS.Services.CoreGui = ASSETS.Project:GetService("CoreGui")
ASSETS.Services.TweenService = ASSETS.Project:GetService("TweenService")

return ASSETS
