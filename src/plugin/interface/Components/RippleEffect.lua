local RippleComponent = {}
RippleComponent.self = script
RippleComponent.require = require

RippleComponent.container =
    RippleComponent.self:FindFirstAncestor('VSDS-PLUGIN')
RippleComponent.RoactUI = RippleComponent.require(
                              RippleComponent.container['VSDS-Packages']['Roact'])
RippleComponent.FlipperUI = RippleComponent.require(
                                RippleComponent.container['VSDS-Packages']['Flipper'])
RippleComponent.Component = RippleComponent.RoactUI.Component:extend(
                                "ButtonRipple")

function RippleComponent.Component.fromMotor(motor)
    local motorBinding, setMotorBinding =
        RippleComponent.RoactUI.createBinding(motor:getValue())
    motor:onStep(setMotorBinding)

    return motorBinding
end

function RippleComponent.Component.deriveProperty(binding, propertyName)
    return binding:map(function(values) return values[propertyName] end)
end

function RippleComponent.Component.blendAlpha(alphaValues)
    local alpha = 0

    for _, value in pairs(alphaValues) do alpha = alpha + (1 - alpha) * value end

    return alpha
end

function RippleComponent.Component:init()
    self.ref = RippleComponent.RoactUI.createRef()

    self.motor = RippleComponent.FlipperUI.GroupMotor.new({
        scale = 0,
        opacity = 0
    })
    self.binding = RippleComponent.Component.fromMotor(self.motor)

    self.position, self.setPosition = RippleComponent.RoactUI.createBinding(
                                          Vector2.new(0, 0))
end

function RippleComponent.Component:reset()
    self.motor:setGoal({
        scale = RippleComponent.FlipperUI.Instant.new(0),
        opacity = RippleComponent.FlipperUI.Instant.new(0)
    })

    -- Forces motor to update
    self.motor:step(0)
end

function RippleComponent.Component:calculateRadius(position)
    local container = self.ref.current

    if container then
        local corner = Vector2.new(math.floor((1 - position.X) + 0.5),
                                   math.floor((1 - position.Y) + 0.5))

        local size = container.AbsoluteSize
        local ratio = size / math.min(size.X, size.Y)

        return ((corner * ratio) - (position * ratio)).Magnitude
    else
        return 0
    end
end

function RippleComponent.Component:render()
    local scale = RippleComponent.Component
                      .deriveProperty(self.binding, "scale")
    local transparency = RippleComponent.Component.deriveProperty(self.binding,
                                                                  "opacity"):map(
                             function(value) return 1 - value end)

    transparency = RippleComponent.RoactUI.joinBindings({
        transparency, self.props.transparency
    }):map(RippleComponent.Component.blendAlpha)

    return RippleComponent.RoactUI.createElement("Frame", {
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = self.props.zIndex,
        BackgroundTransparency = 1,

        [RippleComponent.RoactUI.Ref] = self.ref,

        [RippleComponent.RoactUI.Event.InputBegan] = function(object, input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:reset()

                local position = Vector2.new(input.Position.X, input.Position.Y)
                local relativePosition =
                    (position - object.AbsolutePosition) / object.AbsoluteSize

                self.setPosition(relativePosition)

                self.motor:setGoal({
                    scale = RippleComponent.FlipperUI.Spring.new(1, {
                        frequency = 7,
                        dampingRatio = 2
                    }),
                    opacity = RippleComponent.FlipperUI.Spring.new(1, {
                        frequency = 7,
                        dampingRatio = 2
                    })
                })

                input:GetPropertyChangedSignal("UserInputState"):Connect(
                    function()
                        local userInputState = input.UserInputState

                        if userInputState == Enum.UserInputState.Cancel or
                            userInputState == Enum.UserInputState.End then
                            self.motor:setGoal({
                                opacity = RippleComponent.FlipperUI.Spring
                                    .new(0, {frequency = 5, dampingRatio = 1})
                            })
                        end
                    end)
            end
        end
    }, {
        Circle = RippleComponent.RoactUI.createElement("ImageLabel", {
            Image = 'https://www.roblox.com/asset/?id=17763395145',
            ImageColor3 = self.props.color,
            ImageTransparency = transparency,

            Size = RippleComponent.RoactUI.joinBindings({
                scale = scale,
                position = self.position
            }):map(function(values)
                local targetSize = self:calculateRadius(values.position) * 2
                local currentSize = targetSize * values.scale

                local container = self.ref.current

                if container then
                    local containerSize = container.AbsoluteSize
                    local containerAspect = containerSize.X / containerSize.Y

                    return UDim2.new(currentSize / math.max(containerAspect, 1),
                                     0, currentSize *
                                         math.min(containerAspect, 1), 0)
                end
            end),

            Position = self.position:map(function(value)
                return UDim2.new(value.X, 0, value.Y, 0)
            end),
            AnchorPoint = Vector2.new(0.5, 0.5),

            BackgroundTransparency = 1
        })
    })
end

return RippleComponent.Component
