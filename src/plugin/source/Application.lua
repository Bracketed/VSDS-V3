local Application = {}
local VSDS = {}

Application.self = getfenv().script
Application.require = getfenv().require
Application.Assets = Application.require(Application.self.Parent.Configuration)

Application.container = Application.Assets.Container
Application.components = Application.container['VSDS-Interface']
Application.RoactUI = Application.require(
                          Application.Assets.Plugin.Packages.Roact)
Application.Dictionary = Application.require(
                             Application.Assets.Plugin.Packages.Dictionary)
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

function Application.RoactApplication:newNotification(text, callback)
    -- callback = {function, buttonTitle}
    local notifications = table.clone(self.state.notifications)
    table.insert(notifications,
                 {message = text, timeout = 5, callback = callback})

    self:setState({notifications = notifications})
end

function Application.RoactApplication:closeNotification(notificationIndex)
    local notifications = table.clone(self.state.notifications)
    table.remove(notifications, notificationIndex)

    self:setState({notifications = notifications})
end
function Application.RoactApplication:render()
    return Application.NewRoactElement("ScreenGui",
                                       {Name = 'VSDS-PLUGIN-NOTIFICATIONS'}, {
        layout = Application.NewRoactElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 8)
        }),
        notifs = Application.NewRoactElement(Application.Notifications, {
            notifications = self.state.notifications,
            onClose = function(index) self:closeNotification(index) end
        })
    })
end

function Application.RoactApplication:didMount()
    -- make sure to remember the little branding dohickey
    self:newNotification('Hello!, Welcome to VSDS!')
    self:newNotification('Hello!, Welcome to VSDS!', {
        action = function() print('Hi hello!') end,
        buttonTitle = 'Hi!'
    })

    VSDS.console.log('VSDP initialised! [ Started plugin successfully in',
                     string.sub(getfenv().tick() - Application.Assets.Tick, 1, 5),
                     ' seconds! ]')
    VSDS.console.info('VSDP initialised! [ Started plugin successfully in',
                      string.sub(getfenv().tick() - Application.Assets.Tick, 1,
                                 5), ' seconds! ]')

    if not VSDS.vsds.RetrieveInstall() then
        self:newNotification(
            'You haven\'t installed VSDS but Virtua products are in-game, would you like to install VSDS?',
            {
                action = function() VSDS.vsds.Install() end,
                buttonTitle = 'Install'
            })
    end

    Application.Assets.Services.RunService.Heartbeat:Connect(function(heartbeat)
        VSDS.SecondsElapsed = VSDS.SecondsElapsed + heartbeat

        if VSDS.SecondsElapsed >= 5 * 60 then
            VSDS.SecondsElapsed = VSDS.SecondsElapsed - 5 * 60
            local NewerVersion = VSDS.plugin.CheckForUpdates(Application.Assets
                                                                 .Plugin.Version)

            if NewerVersion then
                self:newNotification(
                    'Attention! A newer VSDP Version is available: Version ' ..
                        NewerVersion)
            end

            -- save for vsds update sthing
            self:newNotification(
                'It seems like your VSDS loader is out of date, would you like to update to the lastest version?',
                {
                    action = function() VSDS.vsds.Update() end,
                    buttonTitle = 'Update'
                })
        end
    end)

end

return function(parameters)
    return Application.NewRoactElement(Application.RoactApplication,
                                       Application.Dictionary.merge(parameters))
end

