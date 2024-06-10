local Application = {}

Application.self = script
Application.require = require
Application.Assets = Application.require(Application.self.Parent.Configuration)

Application.container = Application.Assets.Container
Application.components = Application.container['VSDS-Interface']
Application.RoactUI = Application.require(
                          Application.Assets.Plugin.Packages.Roact)
Application.Dictionary = Application.require(
                             Application.Assets.Plugin.Packages.Dictionary)

Application.RoactApplication = Application.RoactUI.Component:extend(
                                   'VSDS-Application')
Application.NewRoactElement = Application.RoactUI.createElement
Application.Branding = Application.require(Application.components.Branding)

function Application.RoactApplication:render()
    return Application.NewRoactElement("ScreenGui", {
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 200
    }, {
        ['VSDS-InterfaceBoundaries'] = Application.NewRoactElement("UIPadding",
                                                                   {
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15)
        }),
        ['VSDS-Branding'] = Application.NewRoactElement(Application.Branding)
    })
end

return function(parameters)
    return Application.NewRoactElement(Application.RoactApplication,
                                       Application.Dictionary.merge(parameters))
end

