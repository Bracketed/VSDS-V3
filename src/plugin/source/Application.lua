local Application = {}
local VSDS = {}

Application.self = getfenv().script
Application.require = getfenv().require
Application.Assets = Application.require(Application.self.Parent.Configuration)

Application.container = Application.Assets.Container
Application.components = Application.container['VSDS-Interface']
Application.RoactUI = Application.require(
                          Application.Assets.Plugin.Packages.Roact)
VSDS.console = Application.require(Application.Assets.Plugin.Libraries.Console)
VSDS.vsds = Application.require(Application.Assets.Plugin.Libraries.VSDS)
VSDS.plugin = Application.require(Application.Assets.Plugin.Libraries.Internal)
VSDS.SecondsElapsed = 0

Application.RoactApplication = Application.RoactUI.Component:extend(
                                   'VSDS-Application')
Application.NewRoactElement = Application.RoactUI.createElement

Application.Notifications = Application.require(
                                Application.components.Notification)

function Application.RoactApplication:init()
    self:setState({notifications = {}, plugin = self.props.plugin})
end

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
    Application:start()

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

function Application:start()
    -- make sure to remember the little branding dohickey
    self:addNotification('Hello!, Welcome to VSDS!')
    self:addNotification('Hello!, Welcome to VSDS!',
                         function() print('Hi hello!') end)

    VSDS.console.log('VSDP initialised! [ Started plugin successfully in',
                     string.sub(getfenv().tick() - Application.Assets.Tick, 1, 5),
                     ' seconds! ]')
    VSDS.console.info('VSDP initialised! [ Started plugin successfully in',
                      string.sub(getfenv().tick() - Application.Assets.Tick, 1,
                                 5), ' seconds! ]')

    if not VSDS.vsds.RetrieveInstall() then
        self:addNotification(
            'You haven\'t installed VSDS but Virtua products are in-game, would you like to install VSDS?',
            VSDS.vsds.Install())
    end

    Application.Assets.Services.RunService.Heartbeat:Connect(function(heartbeat)
        VSDS.SecondsElapsed = VSDS.SecondsElapsed + heartbeat

        if VSDS.SecondsElapsed >= 5 * 60 then
            VSDS.SecondsElapsed = VSDS.SecondsElapsed - 5 * 60
            local NewerVersion = VSDS.plugin.CheckForUpdates(Application.Assets
                                                                 .Plugin.Version)

            if NewerVersion then
                self:addNotification(
                    'Attention! A newer VSDP Version is available: Version',
                    NewerVersion)
            end

            -- save for vsds update sthing
            self:addNotification(
                'It seems like your VSDS loader is out of date, would you like to update to the lastest version?',
                VSDS.vsds.Update())
        end
    end)

end

return function()
    return Application.NewRoactElement(Application.RoactApplication)
end

