local Application = {}
Application.self = getfenv().script
Application.require = getfenv().require

Application.container = Application.self:FindFirstAncestor('VSDS-PLUGIN').Plugin
Application.Assets = Application.require(Application.container['VSDS-ASSETS'])
Application.components = Application.Assets.Plugin.UI
Application.RoactUI = Application.require(Application.container['ROACT-UI'])

Application.RoactApplication = Application.RoactUI.Component:extend(
                                   'VSDS-Application')
Application.NewRoactElement = Application.RoactUI.createElement

Application.Notifications = Application.require(
                                Application.Assets.Plugin.UserInterface
                                    .Notification)

function Application.RoactApplication:init() self:setState({notifications = {}}) end

function Application.RoactApplication:newNotification(messageContent, callback)
    local notifications = table.clone(self.state.notifications)
    table.insert(notifications, {
        message = messageContent,
        timestamp = DateTime.now().UnixTimestampMillis,
        timeout = 5,
        callback = callback
    })

    self:setState({notifications = notifications})
end

function Application.RoactApplication:closeNotification(notificationIndex)
    local notifications = table.clone(self.state.notifications)
    table.remove(notifications, notificationIndex)

    self:setState({notifications = notifications})
end
function Application.RoactApplication:render()
    return Application.NewRoactElement(Application.RoactUI.createContext(nil)
                                           .Provider, {}, {
        Application.NewRoactElement("ScreenGui",
                                    {Name = 'VSDS-PLUGIN-NOTIFICATIONS'}, {
            layout = Application.NewRoactElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 8)
            }),
            notifs = Application.NewRoactElement(Application.Notifications, {
                notifications = self.state.notifications,
                onClose = function(index)
                    self:closeNotification(index)
                end
            })
        })
    })
end

return function()
    return Application.NewRoactElement(Application.RoactApplication)
end

