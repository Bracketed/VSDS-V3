local ASSETS = {}

ASSETS.Plugin = {}
ASSETS.Services = {}
ASSETS.Configuration = {}
ASSETS.Version = "VERSION_UNKNOWN"
ASSETS.Container = script:FindFirstAncestor('VSDS-PLUGIN')

ASSETS.Project = game
ASSETS.Tick = tick()
ASSETS.Require = require
ASSETS.Pairs = pairs
ASSETS.String = string
ASSETS.Math = math
ASSETS.OS = os

ASSETS.Configuration.ToolBarLogo =
    'https://www.roblox.com/asset/?id=17735487445'
ASSETS.Configuration.ToolBarTitle = 'Plugins by Virtua.'
ASSETS.Configuration.ToolBarButton = {
    ID = 'VSDS',
    TOOLTIP = 'VSDS Importer Plugin by Virtua.',
    IMAGE = ASSETS.Configuration.ToolBarLogo,
    NAME = 'VSDS Importer Plugin'
}

ASSETS.Plugin.Project = script:FindFirstAncestor('VSDS-PLUGIN')
ASSETS.Plugin.Libraries = ASSETS.Plugin.Project['VSDS-Libraries']
ASSETS.Plugin.Interface = ASSETS.Plugin.Project['VSDS-Interface']
ASSETS.Plugin.Packages = ASSETS.Plugin.Project['VSDS-Packages']

ASSETS.Services.RunService = ASSETS.Project:GetService('RunService')
ASSETS.Services.HttpService = ASSETS.Project:GetService('HttpService')
ASSETS.Services.ServerScriptService = ASSETS.Project:GetService(
                                          'ServerScriptService')
ASSETS.Services.CoreGui = ASSETS.Project:GetService("CoreGui")
ASSETS.Services.TweenService = ASSETS.Project:GetService("TweenService")

return ASSETS
