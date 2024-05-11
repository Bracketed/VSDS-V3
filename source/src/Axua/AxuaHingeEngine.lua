return {
    run = function(script, ...)
        local Doors = {}

        for Index, Instance in pairs(script.Parent:GetChildren()) do
            if string.find(Instance.Name, 'DOOR') and Instance:IsA('Model') then
                table.insert(Doors, Instance)
            end
        end

        local function print(...) warn(':: Virtua Axua ::', ...) end

        -- //GAME SERVICES\\--
        local TS = game:GetService("TweenService")

        -- //DOOR AND CONFIG\\--
        local this = script.Parent

        -- //DOOR LOGIC PROCESS\\--
        local state = 'CLOSED'
        local altsate = 'NONE'

        -- //TWEEN CONFIG\\--

        local Tweens_DEFAULTPOS = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

        -- //DOOR ENGINE\\--
        for i, v in pairs(this.Sensors:GetChildren()) do
            if v:FindFirstChild('SensorRange') then
                local LED = v:FindFirstChild('LED') or nil
                v.SensorRange.Touched:connect(function()
                    if state == 'CLOSED' or state == 'CLOSING' and state ~=
                        'OPEN' then
                        this.AxuaAPI:Invoke('EVENTS_DOOROPEN')
                    end
                    if (LED) then
                        TS:Create(LED, Tweens_DEFAULTPOS,
                                  {Color = Color3.fromRGB(0, 255, 0)}):Play()
                        wait(1)
                        TS:Create(LED, Tweens_DEFAULTPOS,
                                  {Color = Color3.fromRGB(255, 0, 0)}):Play()
                    end
                end)
            end
        end

        for _, Door in pairs(Doors) do
            Door.Door.HingeConstraint.TargetAngle = 0
        end

        -- //DOOR OPEN FUNCTION\\--
        function DOOROPEN()
            state = 'OPENING'
            for _, v in pairs(this.Doors:GetChildren()) do
                if v:IsA('Model') then
                    v.Door.HingeConstraint.TargetAngle = 90
                    coroutine.resume(coroutine.create(function()
                        local time = 0
                        repeat
                            time = time + 0.05
                            wait(0.05)
                        until time >= 1 / 2
                        repeat
                            time = time - 0.05
                            wait(0.05)
                        until time <= 0
                    end))
                end
            end
            if not ((altsate == 'HOLD') or (altsate == 'LOCKED')) then
                wait(6)
                DOORCLOSE()
            end
        end

        coroutine.resume(coroutine.create(function()
            local timer

            repeat
                timer = timer + 0.1
                wait(0.1)
            until timer >= 1
            state = 'OPEN'
        end))

        -- //DOOR CLOSE FUNCTION\\--
        function DOORCLOSE()
            state = 'CLOSING'
            for _, v in pairs(this.Doors:GetChildren()) do
                if v:IsA('Model') then
                    v.Door.HingeConstraint.TargetAngle = 0
                    coroutine.resume(coroutine.create(function()
                        local time = 0
                        repeat
                            time = time + 0.05
                            wait(0.05)
                        until time >= 1 / 2
                        repeat
                            time = time - 0.05
                            wait(0.05)
                        until time <= 0
                    end))
                end
            end
        end

        coroutine.resume(coroutine.create(function()
            local timer

            repeat
                timer = timer + 0.1
                wait(0.1)
            until timer >= 1
            state = 'CLOSED'
        end))

        -- //DOOR API\\--

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
