return {
    run = function(script, ...)
        require = _G.require
        local function print(...) warn(':: Virtua Axua ::', ...) end
        Instance.new('Folder', script.Parent).Name = 'WeldStorage'

        local TS = game:GetService("TweenService")
        local this = script.Parent
        local settings = require(this.AxuaConfiguration)
        local state = 'CLOSED'
        local altsate = 'NONE'

        local Tweens_OPEN = TweenInfo.new(settings.Movement.OpenSpeed,
                                          settings.Tweening.EasingStyle,
                                          settings.Tweening.EasingDirection)
        local Tweens_CLOSE = TweenInfo.new(settings.Movement.CloseSpeed,
                                           settings.Tweening.EasingStyle,
                                           settings.Tweening.EasingDirection)
        local Tweens_DEFAULTPOS = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

        for _, Sensor in pairs(this.Sensors:GetChildren()) do
            if Sensor:FindFirstChild('SensorRange') then
                local LED = Sensor:FindFirstChild('LED') or nil
                Sensor.SensorRange.Touched:connect(function()
                    if state == 'CLOSED' or state == 'CLOSING' and state ~=
                        'OPEN' then
                        this.AxuaAPI:Invoke('EVENTS_DOOROPEN')
                    end
                    if (LED) then
                        TS:Create(LED, Tweens_DEFAULTPOS,
                                  {Color = settings.SensorColours.Active})
                            :Play()
                        task.wait(1)
                        TS:Create(LED, Tweens_DEFAULTPOS,
                                  {Color = settings.SensorColours.Inactive})
                            :Play()
                    end
                end)
            end
        end

        for _, Doors in pairs(this.Doors:GetChildren()) do
            if Doors:FindFirstChild('DoorMovementGoal') then
                for _, DoorPart in pairs(Doors:GetChildren()) do
                    if DoorPart.Name == 'DoorMovementEngine' then
                        DoorPart.Anchored = true
                    end
                    if not (DoorPart.Name == 'DoorMovementEngine') then
                        z = Instance.new('WeldConstraint')
                        local bx = Instance.new('CFrameValue')
                        z.Part0 = Doors.DoorMovementEngine
                        z.Part1 = DoorPart
                        DoorPart.Anchored = false
                        z.Parent = this.WeldStorage
                        if not Doors:FindFirstChild('DoorCFrame') then
                            bx.Value = Doors.DoorMovementEngine.CFrame
                            bx.Name = 'DoorCFrame'
                            bx.Parent = Doors
                        end
                    end
                end
            end
        end

        function DOOROPEN()
            state = 'OPENING'
            for _, Door in pairs(this.Doors:GetChildren()) do
                if Door:IsA('Model') then
                    TS:Create(Door.DoorMovementEngine, Tweens_OPEN,
                              {CFrame = Door.DoorMovementGoal.CFrame}):Play()
                    coroutine.resume(coroutine.create(function()
                        local time = 0
                        repeat
                            time = time + 0.05
                            task.wait(0.05)
                        until time >= settings.Movement.OpenSpeed / 2
                        repeat
                            time = time - 0.05
                            task.wait(0.05)
                        until time <= 0
                    end))
                end
            end
            if not ((altsate == 'HOLD') or (altsate == 'LOCKED')) then
                task.wait(settings.Movement.OpenSpeed +
                              settings.Movement.OpenTime)
                DOORCLOSE()
            end
        end

        coroutine.resume(coroutine.create(function()
            local timer

            repeat
                timer = timer + 0.1
                task.wait(0.1)
            until timer >= settings.Movement.OpenSpeed
            state = 'OPEN'
        end))

        function DOORCLOSE()
            state = 'CLOSING'
            for _, Door in pairs(this.Doors:GetChildren()) do
                if Door:IsA('Model') then
                    TS:Create(Door.DoorMovementEngine, Tweens_CLOSE,
                              {CFrame = Door.DoorCFrame.Value}):Play()
                    coroutine.resume(coroutine.create(function()
                        local time = 0
                        repeat
                            time = time + 0.05
                            task.wait(0.05)
                        until time >= settings.Movement.CloseSpeed / 2
                        repeat
                            time = time - 0.05
                            task.wait(0.05)
                        until time <= 0
                    end))
                end
            end
        end

        coroutine.resume(coroutine.create(function()
            local timer

            repeat
                timer = timer + 0.1
                task.wait(0.1)
            until timer >= settings.Movement.CloseSpeed
            state = 'CLOSED'
        end))

        function this.AxuaAPI.OnInvoke(Command)
            if Command == 'EVENTS_DOOROPEN' and
                not ((altsate == 'HOLD') or (altsate == 'LOCKED')) then
                DOOROPEN()
            elseif Command == 'EVENTS_DOORCLOSE' and
                not ((altsate == 'HOLD') or (altsate == 'LOCKED')) then
                DOORCLOSE()
            elseif Command == 'EVENTS_DOORHOLD' and not (altsate == 'LOCKED') then
                if altsate == 'HOLD' then
                    altsate = 'NONE'
                    DOORCLOSE()
                else
                    altsate = 'HOLD'
                    DOOROPEN()
                end
            elseif Command == 'EVENTS_DOORLOCK' and
                not ((altsate == 'HOLD') or (altsate == 'LOCKED')) then
                if altsate == 'LOCKED' then
                    altsate = 'NONE'
                    DOORCLOSE()
                else
                    altsate = 'LOCKED'
                    DOORCLOSE()
                end
            elseif Command == 'EVENTS_DOORRESET' and
                ((altsate == 'HOLD') or (altsate == 'LOCKED')) then
                altsate = 'NONE'
                DOORCLOSE()
            end
        end
    end
}
