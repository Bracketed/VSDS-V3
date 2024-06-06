local Notifications = {}
Notifications.self = getfenv().script
Notifications.require = getfenv().require

-- u need to redo these for the new structure
Notifications.container = Notifications.self:FindFirstAncestor('VSDS-PLUGIN')
Notifications.Assets = Notifications.require(
                           Notifications.container.Plugin.Configuration)
Notifications.components = Notifications.Assets.Plugin.Interface
Notifications.RoactUI = Notifications.require(
                            Notifications.container['VSDS-Packages']['Roact'])
Notifications.FlipperUI = Notifications.require(
                              Notifications.container['VSDS-Packages']['Flipper'])

Notifications.RoactNotification = Notifications.RoactUI.Component:extend(
                                      'VSDS-Notification')
Notifications.RoactNotifications = Notifications.RoactUI.Component:extend(
                                       "VSDS-Notifications")
Notifications.NewRoactElement = Notifications.RoactUI.createElement

function Notifications.RoactNotification.fromMotor(motor)
    local motorBinding, setMotorBinding =
        Notifications.RoactUI.createBinding(motor:getValue())
    motor:onStep(setMotorBinding)

    return motorBinding
end

function Notifications.RoactNotification:init()
    self.motor = Notifications.FlipperUI.SingleMotor.new(0)
    self.binding = Notifications.RoactNotification.fromMotor(self.motor)
    self:setState({
        rotation = 0,
        noButtonGradientColor = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
        yesButtonGradientColor = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    })

    self.UIGradientYes = Notifications.RoactUI.createRef()
    self.UIGradientNo = Notifications.RoactUI.createRef()

    self.lifetime = self.props.timeout

    self.motor:onStep(function(value)
        if value <= 0 then
            if self.props.onClose then self.props.onClose() end
        end
    end)
end

function Notifications.RoactNotification:dismiss()
    self.motor:setGoal(Notifications.FlipperUI.Spring.new(0, {
        frequency = 5,
        dampingRatio = 1
    }))
end

function Notifications.RoactNotification:didMount()
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

    self.running = true
    Notifications.Assets.Services.RunService.RenderStepped:Connect(function(
        deltaTime)
        if not self.running then return end
        local newRotation = (self.state.rotation + deltaTime * 100) % 360
        self:setState({rotation = newRotation})
    end)
end

function Notifications.RoactNotification:willUnmount()
    task.cancel(self.timeout)
    self.running = false
end

function Notifications.RoactNotification:render()
    local transparency = self.binding:map(function(value) return 1 - value end)
    -- set up animation with RoactAnimate
    if self.props.callback then
        return Notifications.RoactUI.createElement("Frame", {
            Name = 'VSDS-PROMPT',
            Position = UDim2.new(1, -420, 0.9, -50),
            Size = UDim2.new(0, 400, 0, 110),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        }, {
            Notifications.RoactUI.createElement("UICorner",
                                                {CornerRadius = UDim.new(0, 6)}),
            Notifications.RoactUI.createElement("UIGradient", {
                Offset = Vector2.new(0, 0),
                Transparency = NumberSequence.new(0),
                Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
                Rotation = 45
            }), Notifications.RoactUI.createElement("TextLabel", {
                Name = 'PROMPT-TEXT',
                Position = UDim2.new(0, 0, 0.03, 0),
                Font = Enum.Font.MontserratMedium,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(1, 0, 0.45, 0),
                Text = self.props.message,
                TextSize = 17,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }, {
                Notifications.RoactUI.createElement("UIPadding", {
                    PaddingRight = UDim.new(0.04, 0),
                    PaddingLeft = UDim.new(0.04, 0)
                })
            }), Notifications.RoactUI.createElement("TextButton", {
                Name = 'Option-No',
                Position = UDim2.new(0, 20, 1, -54),
                Font = Enum.Font.MontserratBold,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 120, 0, 40),
                Text = "Dismiss",
                TextScaled = true,
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Active = true,

                [Notifications.RoactUI.Event.MouseButton1Click] = function(
                    context)
                    context.Active = false

                    self:dismiss()
                end,
                [Notifications.RoactUI.Event.MouseEnter] = function(context)

                    Notifications.Assets.Services.TweenService:Create(context,
                                                                      TweenInfo.new(
                                                                          1.5,
                                                                          Enum.EasingStyle
                                                                              .Linear),
                                                                      {
                        Color = ColorSequence.new(Color3.fromRGB(154, 154, 154),
                                                  Color3.fromRGB(255, 255, 255))
                    }):Play()
                end,
                [Notifications.RoactUI.Event.MouseLeave] = function(context)
                    Notifications.Assets.Services.TweenService:Create(context,
                                                                      TweenInfo.new(
                                                                          1.5,
                                                                          Enum.EasingStyle
                                                                              .Linear),
                                                                      {
                        Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
                    }):Play()
                end
            }, {
                Notifications.RoactUI.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 4)
                }), Notifications.RoactUI.createElement("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    LineJoinMode = Enum.LineJoinMode.Round,
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 2,
                    Transparency = 0
                }, {
                    Notifications.RoactUI.createElement("UIGradient", {
                        Offset = Vector2.new(0, 0),
                        Transparency = NumberSequence.new(0),
                        Color = self.state.noButtonGradientColor,
                        Rotation = self.state.rotation,

                        [Notifications.RoactUI.Ref] = self.UIGradientNo
                    })
                }), Notifications.RoactUI.createElement("UIPadding", {
                    PaddingBottom = UDim.new(0.3, 0),
                    PaddingTop = UDim.new(0.3, 0)
                })
            }), Notifications.RoactUI.createElement("TextButton", {
                Name = 'Option-Yes',
                Font = Enum.Font.MontserratBold,
                Position = UDim2.new(0, 160, 1, -54),
                TextColor3 = Color3.fromRGB(0, 22, 58),
                Size = UDim2.new(0, 120, 0, 40),
                Text = self.props.callback.buttonTitle,
                TextScaled = true,
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Active = true,

                [Notifications.RoactUI.Event.MouseButton1Click] = function(
                    context)
                    context.Active = false

                    self.props.callback.action()
                end,
                [Notifications.RoactUI.Event.MouseEnter] = function(context)
                    Notifications.Assets.Services.TweenService:Create(context,
                                                                      TweenInfo.new(
                                                                          1.5,
                                                                          Enum.EasingStyle
                                                                              .Linear),
                                                                      {
                        Color = ColorSequence.new(Color3.fromRGB(154, 154, 154),
                                                  Color3.fromRGB(255, 255, 255))
                    }):Play()
                end,
                [Notifications.RoactUI.Event.MouseLeave] = function(context)
                    Notifications.Assets.Services.TweenService:Create(context,
                                                                      TweenInfo.new(
                                                                          1.5,
                                                                          Enum.EasingStyle
                                                                              .Linear),
                                                                      {
                        Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
                    }):Play()
                end
            }, {
                Notifications.RoactUI.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 4)
                }), Notifications.RoactUI.createElement("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    LineJoinMode = Enum.LineJoinMode.Round,
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 2,
                    Transparency = 0
                }, {
                    Notifications.RoactUI.createElement("UIGradient", {
                        Offset = Vector2.new(0, 0),
                        Transparency = NumberSequence.new(0),
                        Color = self.state.yesButtonGradientColor,
                        Rotation = self.state.rotation,

                        [Notifications.RoactUI.Ref] = self.UIGradientYes
                    })
                }), Notifications.RoactUI.createElement("UIPadding", {
                    PaddingBottom = UDim.new(0.3, 0),
                    PaddingTop = UDim.new(0.3, 0)
                })
            })
        })
    else
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
end

function Notifications.RoactNotifications:render()
    local notifs = {}

    for index, notif in ipairs(self.props.notifications) do
        if notif.callback then notif.timeout = notif.timeout + 2.5 * 60 end

        notifs[notif] = Notifications.NewRoactElement(
                            Notifications.RoactNotification, {
                message = notif.text,
                timeout = notif.timeout,
                callback = notif.callback,
                onClose = function() self.props.onClose(index) end
            })
    end

    return Notifications.RoactUI.createFragment(notifs)
end

return Notifications.RoactNotifications
