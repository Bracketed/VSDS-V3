local Application = {}
local VSDS = {}

Application.self = script
Application.require = require
Application.Assets = Application.require(Application.self.Parent.Configuration)

Application.container = Application.Assets.Container
Application.components = Application.container['VSDS-Interface']
Application.RoactUI = Application.require(
                          Application.Assets.Plugin.Packages.Roact)
Application.Dictionary = Application.require(
                             Application.Assets.Plugin.Packages.Dictionary)
VSDS.console = Application.require(Application.Assets.Plugin.Libraries.Console)
VSDS.vsds = Application.require(Application.Assets.Plugin.Libraries.VSDS)
VSDS.SecondsElapsed = 0

Application.RoactApplication = Application.RoactUI.Component:extend(
                                   'VSDS-Application')
Application.NewRoactElement = Application.RoactUI.createElement

Application.Notifications = Application.require(
                                Application.components.Notification)

function Application.RoactApplication:init()
    self.notificationIndex = 0
    self:setState({notifications = {}, plugin = self.props.plugin})
end

function Application.RoactApplication:newNotification(text, callback)
    self.notificationIndex = self.notificationIndex + 1
    local notifications = table.clone(self.state.notifications)

    notifications[self.notificationIndex] = {
        message = text,
        timestamp = DateTime.now().UnixTimestampMillis,
        timeout = 8,
        callback = callback or nil
    }

    self:setState({notifications = notifications})

    return function() self:closeNotification(self.notificationIndex) end
end

function Application.RoactApplication:closeNotification(notificationIndex)
    if not self.state.notifications[notificationIndex] then return end

    local notifications = table.clone(self.state.notifications)
    notifications[notificationIndex] = nil

    self:setState({notifications = notifications})
end
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
        ['VSDS-InterfaceLayout'] = Application.NewRoactElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 8)
        }),
        ['VSDS-NotificationInterface'] = Application.NewRoactElement(
            Application.Notifications, {
                notifications = self.state.notifications,
                onClose = function(index)
                    self:closeNotification(index)
                end
            })

    })
end

function Application.RoactApplication:didMount()
    local MigratableInstances = VSDS.vsds.FindMigratables(Application.Assets
                                                              .Project:GetService(
                                                              'Workspace'))

    if (#MigratableInstances ~= 0) and VSDS.vsds.RetrieveInstall() then
        self:newNotification(
            'VSDP has detected old VSDS products in-game, should VSDP migrate them to the latest version?',
            {
                action = function()
                    local MigrateState = VSDS.vsds.Migrate()

                    if MigrateState == true then
                        self:newNotification('VSDP Migrated ' ..
                                                 #MigratableInstances ..
                                                 ' scripts successfully.')
                    else
                        self:newNotification(
                            'VSDP errored whilst migrating ' ..
                                #MigratableInstances ..
                                ' scripts, report this error or try again.')
                    end
                end,
                buttonTitle = 'Migrate'
            })
    elseif (#MigratableInstances ~= 0) and not VSDS.vsds.RetrieveInstall() then
        self:newNotification(
            'You haven\'t installed VSDS but Virtua products are in-game, would you like to install VSDS?',
            {
                action = function()
                    local StartingTime = tick()
                    local InstallState = VSDS.vsds.Install()

                    if InstallState == true then
                        self:newNotification(
                            'VSDP Installed VSDS successfully in ' ..
                                string.sub(tick() - StartingTime, 1, 5) ..
                                ' seconds.')
                    else
                        self:newNotification(
                            'VSDP errored whilst installing VSDS, report this error or try again.')
                    end
                end,
                buttonTitle = 'Install'
            })
    end

    Application.Assets.Project:GetService('Workspace').ChildAdded:Connect(
        function(NewInstance)
            local MigratableInstances = VSDS.vsds.FindMigratables(NewInstance)

            if (#MigratableInstances ~= 0) and VSDS.vsds.RetrieveInstall() then
                self:newNotification(
                    'Would you like to migrate the Virtua product you\'ve just inserted to the latest version?',
                    {
                        action = function()
                            local StartingTime = tick()
                            local MigrateState = VSDS.vsds.Migrate()

                            if MigrateState == true then
                                self:newNotification('VSDP Migrated ' ..
                                                         #MigratableInstances ..
                                                         ' scripts successfully in ' ..
                                                         string.sub(
                                                             tick() -
                                                                 StartingTime,
                                                             1, 5) ..
                                                         ' seconds.')
                            else
                                self:newNotification(
                                    'VSDP errored whilst migrating ' ..
                                        #MigratableInstances ..
                                        ' scripts, report this error or try again.')
                            end
                        end,
                        buttonTitle = 'Migrate'
                    })
            elseif (#MigratableInstances ~= 0) and
                not VSDS.vsds.RetrieveInstall() then
                self:newNotification(
                    'You haven\'t installed VSDS but Virtua products are in-game, would you like to install VSDS?',
                    {
                        action = function()
                            local StartingTime = tick()
                            local InstallState = VSDS.vsds.Install()

                            if InstallState == true then
                                self:newNotification(
                                    'VSDP Installed VSDS successfully in ' ..
                                        string.sub(tick() - StartingTime, 1, 5) ..
                                        ' seconds.')
                            else
                                self:newNotification(
                                    'VSDP errored whilst installing VSDS, report this error or try again.')
                            end
                        end,
                        buttonTitle = 'Install'
                    })
            end
        end)

    Application.Assets.Services.RunService.Heartbeat:Connect(function(heartbeat)
        VSDS.SecondsElapsed = VSDS.SecondsElapsed + heartbeat

        if VSDS.SecondsElapsed >= 5 * 60 then
            VSDS.SecondsElapsed = VSDS.SecondsElapsed - 5 * 60
            local NewerPluginVersion = VSDS.vsds.CheckForPluginUpdates(
                                           Application.Assets.Plugin.Version)
            local VSDS_Loader = VSDS.vsds.RetrieveInstall()

            if NewerPluginVersion ~= nil then
                self:newNotification(
                    'Attention! A newer VSDP Version is available: Version ' ..
                        NewerPluginVersion)
                task.wait(1)
                self:newNotification(
                    'You can get the latest release from GitHub or the Studio Plug-ins manager.')
            end

            if VSDS_Loader ~= nil then
                local NewerLoaderVersion =
                    VSDS.vsds.CheckForLoaderUpdates(
                        VSDS_Loader['VSDS-VER'].Value)

                if NewerLoaderVersion ~= nil then
                    self:newNotification(
                        'It seems like your VSDS loader is out of date, would you like to update to the latest version?',
                        {
                            action = function()
                                local StartingTime = tick()
                                local InstallState = VSDS.vsds.Update()

                                if InstallState == true then
                                    self:newNotification(
                                        'VSDP updated VSDS successfully in ' ..
                                            string.sub(tick() - StartingTime, 1,
                                                       5) .. ' seconds.')
                                else
                                    self:newNotification(
                                        'VSDP errored whilst updating VSDS, report this error or try again.')
                                end
                            end,
                            buttonTitle = 'Update'
                        })
                end
            end
        end
    end)

    VSDS.console.log('VSDP initialised! [ Started plugin successfully in',
                     string.sub(tick() - Application.Assets.Tick, 1, 5),
                     ' seconds! ]')
    VSDS.console.info('VSDP initialised! [ Started plugin successfully in',
                      string.sub(tick() - Application.Assets.Tick, 1, 5),
                      ' seconds! ]')

end

return function(parameters)
    return Application.NewRoactElement(Application.RoactApplication,
                                       Application.Dictionary.merge(parameters))
end

