local Notifications = {}
Notifications.self = getfenv().script
Notifications.require = getfenv().require

Notifications.container = Notifications.self:FindFirstAncestor('VSDS-PLUGIN')
                              .Plugin
Notifications.Assets = Notifications.require(
                           Notifications.container['VSDS-ASSETS'])
Notifications.components = Notifications.Assets.Plugin.UI
Notifications.RoactUI = Notifications.require(
                            Notifications.container['ROACT-UI'])
Notifications.FlipperUI = Notifications.require(
                              Notifications.container['FLIPPER-UI'])

Notifications.RoactApplication = Notifications.RoactUI.Component:extend(
                                     'VSDS-Notification')
Notifications.RoactNotifications = Notifications.RoactUI.Component:extend(
                                       "VSDS-Notifications")
Notifications.NewRoactElement = Notifications.RoactUI.createElement

function Notifications.RoactApplication.fromMotor(motor)
    local motorBinding, setMotorBinding =
        Notifications.RoactUI.createBinding(motor:getValue())
    motor:onStep(setMotorBinding)
    return motorBinding
end

function Notifications.RoactApplication:init()
    self.motor = Notifications.FlipperUI.SingleMotor.new(0)
    self.binding = Notifications.RoactApplication.fromMotor(self.motor)

    self.lifetime = self.props.timeout

    self.motor:onStep(function(value)
        if value <= 0 then
            if self.props.onClose then self.props.onClose() end
        end
    end)
end

function Notifications.RoactApplication:dismiss()
    self.motor:setGoal(Notifications.FlipperUI.Spring.new(0, {
        frequency = 5,
        dampingRatio = 1
    }))
end

function Notifications.RoactApplication:didMount()
    self.motor:setGoal(Notifications.FlipperUI.Spring.new(1, {
        frequency = 3,
        dampingRatio = 1
    }))

    self.timeout = task.spawn(function()
        local clock = os.clock()
        local seen = false

        while task.wait(1 / 10) do
            local now = os.clock()
            local dt = now - clock
            clock = now

            if not seen then seen = true end

            if seen then
                self.lifetime = self.lifetime - dt

                if self.lifetime <= 0 then
                    self:dismiss()
                    break
                end
            end
        end
    end)
end

function Notifications.RoactApplication:willUnmount() task.cancel(self.timeout) end

function Notifications.RoactApplication:render()
    local transparency = self.binding:map(function(value) return 1 - value end)

    return Notifications.RoactUI.createElement("Frame", {
        Name = 'VSDS-NOTIFICATION',
        BackgroundTransparency = transparency,
        Position = UDim2.new(1, -420, 0.9, 0),
        Size = UDim2.new(0, 400, 0, 60),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    }, {
        Notifications.RoactUI.createElement("UICorner",
                                            {CornerRadius = UDim.new(0, 6)}),

        Notifications.RoactUI.createElement("UIGradient", {
            Offset = Vector2.new(0, 0),
            Transparency = NumberSequence.new(transparency),
            Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
            Rotation = 45
        }), Notifications.RoactUI.createElement("TextLabel", {
            Name = 'PROMPT-TEXT',
            Font = Enum.Font.MontserratMedium,
            BackgroundTransparency = 1,
            TextTransparency = transparency,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.87, 0, 1, 0),
            Text = self.props.message,
            RichText = true,
            TextSize = 18,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        }, {
            Notifications.RoactUI.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 15),
                PaddingTop = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                PaddingLeft = UDim.new(0, 15)
            })
        }), Notifications.RoactUI.createElement("ImageLabel", {
            Name = 'VIRTUA-LOGO',
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            Image = "rbxassetid://17698501085",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -40, 0, 0),
            Size = UDim2.new(0, 25, 1, 0),
            ScaleType = Enum.ScaleType.Fit,
            ImageTransparency = transparency,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        })
    })
end

function Notifications:render()
    local notifs = {}

    for index, notif in ipairs(self.props.notifications) do
        notifs[notif] = Notifications.NewRoactElement(
                            Notifications.RoactApplication, {
                message = notif.text,
                timestamp = notif.timestamp,
                timeout = notif.timeout,
                layoutOrder = (notif.timestamp -
                    DateTime.now().UnixTimestampMillis),
                onClose = function() self.props.onClose(index) end
            })
    end

    return Notifications.RoactUI.createFragment(notifs)
end

return Notifications
