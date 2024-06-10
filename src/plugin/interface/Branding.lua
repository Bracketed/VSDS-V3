local Branding = {}
Branding.self = script
Branding.require = require

Branding.container = Branding.self:FindFirstAncestor('VSDS-PLUGIN')
Branding.Assets = Branding.require(Branding.container.Plugin.Configuration)
Branding.RoactUI =
    Branding.require(Branding.container['VSDS-Packages']['Roact'])
Branding.FlipperUI = Branding.require(
                         Branding.container['VSDS-Packages']['Flipper'])

Branding.RoactBranding = Branding.RoactUI.Component:extend("VSDS-Branding")
Branding.NewRoactElement = Branding.RoactUI.createElement

function Branding.RoactBranding.fromMotor(motor)
    local motorBinding, setMotorBinding =
        Branding.RoactUI.createBinding(motor:getValue())
    motor:onStep(setMotorBinding)

    return motorBinding
end

function Branding.RoactBranding:init()
    self.motor = Branding.FlipperUI.SingleMotor.new(-1)
    self.binding = Branding.RoactBranding.fromMotor(self.motor)

    self.lifetime = 3
    self.speed = 2

    self.motor:onStep(function(value)
        if value <= -1 then
            if self.props.onClose then self.props.onClose() end
        end
    end)
end

function Branding.RoactBranding:dismiss()
    self.motor:setGoal(Branding.FlipperUI.Spring.new(-1, {
        frequency = self.speed - 1,
        dampingRatio = 1
    }))
end

function Branding.RoactBranding:didMount()
    self.motor:setGoal(Branding.FlipperUI.Spring.new(0, {
        frequency = self.speed,
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

    self.running = true
end

function Branding.RoactBranding:willUnmount()
    task.cancel(self.timeout)
    self.running = false
end

function Branding.RoactBranding:render()
    local position = self.binding:map(function(value)
        return UDim2.new(0, 0, value, 0)
    end)

    return Branding.RoactUI.createElement("Frame", {
        Name = 'VSDS-BRANDING',
        Size = UDim2.new(0, 220, 0, 50),
        Position = position,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    }, {
        Branding.RoactUI.createElement("UICorner",
                                       {CornerRadius = UDim.new(0, 4)}),
        Branding.RoactUI.createElement("UIGradient", {
            Offset = Vector2.new(0, 0),
            Color = ColorSequence.new(Color3.fromRGB(0, 34, 85),
                                      Color3.fromRGB(0, 19, 52)),
            Rotation = 45
        }), Branding.RoactUI.createElement("TextLabel", {
            Name = 'VSDS_TEXT',
            Font = Enum.Font.MontserratMedium,
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.8, 0, 1, 0),
            Text = "VSDP initialised.",
            TextScaled = true,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        }, {
            Branding.RoactUI.createElement("UIPadding", {
                PaddingBottom = UDim.new(0.3, 0),
                PaddingTop = UDim.new(0.3, 0),
                PaddingRight = UDim.new(0.05, 0),
                PaddingLeft = UDim.new(0.07, 0)
            })
        }), Branding.RoactUI.createElement("ImageLabel", {
            Name = 'VIRTUA_LOGO',
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            Image = "rbxassetid://17698501085",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -45, 0, 0),
            Size = UDim2.new(0, 25, 1, 0),
            ScaleType = Enum.ScaleType.Fit,
            Transparency = 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        })
    })
end

return Branding.RoactBranding
