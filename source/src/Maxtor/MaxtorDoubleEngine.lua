return {
    run = function(script, ...)
        -- ill be back to update these doors one day
        local Door1 = script.Parent.DoorL
        local Door2 = script.Parent.DoorR
        local DoorSettings = require(script.Parent.Settings)
        local DoorProperties = DoorSettings.DOOR_SETTINGS
        local State = Instance.new("StringValue", script.Parent)
        local ClickBarL = Instance.new("ClickDetector", Door1.Bar.ClickHolder)
        local ClickBarR = Instance.new("ClickDetector", Door2.Bar.ClickHolder)
        local ClickHandleL = Instance.new("ClickDetector", Door1.Pull)
        local ClickHandleR = Instance.new("ClickDetector", Door2.Pull)
        local WeldR = Instance.new("WeldConstraint", Door2.Door)
        local WeldL = Instance.new("WeldConstraint", Door1.Door)
        local DoorL_Unlocked = Instance.new("BoolValue", script)
        local DoorR_Unlocked = Instance.new("BoolValue", script)
        local DoorRDisabled = Instance.new("BoolValue", script)
        local DoorLDisabled = Instance.new("BoolValue", script)
        local ToolCooldownR = Instance.new("BoolValue", script)
        local ToolCooldownL = Instance.new("BoolValue", script)

        WeldL.Name = "Weld_DoorL"
        WeldR.Name = "Weld_DoorR"
        WeldL.Part0 = Door1.Door
        WeldL.Part1 = script.Parent.Frame.DoorFrame.Left
        WeldR.Part0 = Door2.Door
        WeldR.Part1 = script.Parent.Frame.DoorFrame.Right
        State.Name = "DOORSTATE"
        State.Value = "DOOR_UNUSED"
        ClickBarL.MaxActivationDistance = DoorProperties.BAR_L
        ClickBarR.MaxActivationDistance = DoorProperties.BAR_R
        ClickHandleL.MaxActivationDistance = 0
        ClickHandleR.MaxActivationDistance = 0
        DoorL_Unlocked.Value = false
        DoorR_Unlocked.Value = false
        DoorRDisabled.Value = false
        DoorLDisabled.Value = false
        ToolCooldownR.Value = false
        ToolCooldownL.Value = false
        DoorL_Unlocked.Name = "DOORL.IS-UNLOCKED"
        DoorR_Unlocked.Name = "DOORR.IS-UNLOCKED"
        DoorRDisabled.Name = "DOORR.IS-DISABLED"
        DoorLDisabled.Name = "DOORL.IS-DISABLED"
        ToolCooldownR.Name = "DOORR.ON-COOLDOWN"
        ToolCooldownL.Name = "DOORR.ON-COOLDOWN"

        -- Door Stuff with making them able to be moved
        local function UnlockL()
            State.Value = "DOOR_UNLOCKED"
            Door1.Door.DoorHinge.ActuatorType = "None"
            Door1.Door.DoorHinge.LimitsEnabled = true
            Door1.Door.DoorHinge.UpperAngle = 0
            Door1.Door.DoorHinge.LowerAngle = DoorProperties.DOOR_L
        end
        local function LockL()
            State.Value = "DOOR_LOCKED"
            Door1.Door.DoorHinge.ActuatorType = "Servo"
            Door1.Door.DoorHinge.LimitsEnabled = false
            Door1.Door.DoorHinge.TargetAngle = 1
            wait(1.5)
            Door1.Door.DoorHinge.TargetAngle = 0
        end
        local function UnlockR()
            State.Value = "DOOR_UNLOCKED"
            Door2.Door.DoorHinge.ActuatorType = "None"
            Door2.Door.DoorHinge.LimitsEnabled = true
            Door2.Door.DoorHinge.UpperAngle = DoorProperties.DOOR_R
            Door2.Door.DoorHinge.LowerAngle = 0
        end
        local function LockR()
            State.Value = "DOOR_LOCKED"
            Door2.Door.DoorHinge.ActuatorType = "Servo"
            Door2.Door.DoorHinge.LimitsEnabled = false
            Door2.Door.DoorHinge.TargetAngle = -1
            wait(1.5)
            Door2.Door.DoorHinge.TargetAngle = 0
        end
        local function DoorHandleR()
            Door2.Door.DoorHinge.ActuatorType = "Servo"
            Door2.Door.DoorHinge.LimitsEnabled = false
            Door2.Door.DoorHinge.TargetAngle = DoorProperties.DOOR_R
            ClickHandleR.MaxActivationDistance = 0
            wait(3)
            Door2.Door.DoorHinge.ActuatorType = "None"
            ClickHandleR.MaxActivationDistance = DoorProperties.HANDLE_R
            Door2.Door.DoorHinge.LimitsEnabled = true
            Door2.Door.DoorHinge.UpperAngle = DoorProperties.DOOR_R
            Door2.Door.DoorHinge.LowerAngle = 0
        end
        local function DoorHandleL()
            Door1.Door.DoorHinge.ActuatorType = "Servo"
            Door1.Door.DoorHinge.LimitsEnabled = false
            Door1.Door.DoorHinge.TargetAngle = DoorProperties.DOOR_L
            ClickHandleL.MaxActivationDistance = 0
            wait(3)
            Door1.Door.DoorHinge.ActuatorType = "None"
            ClickHandleL.MaxActivationDistance = DoorProperties.HANDLE_L
            Door1.Door.DoorHinge.LimitsEnabled = true
            Door1.Door.DoorHinge.UpperAngle = DoorProperties.DOOR_L
            Door1.Door.DoorHinge.LowerAngle = 0
        end
        -- Main door stuff
        local function LeftDoorFunction()
            if DoorL_Unlocked.Value == false then
                DoorL_Unlocked.Value = true
                Door1.Door.BarSound:Play()
                ClickBarL.MaxActivationDistance = 0
                Door1.Bar.MainBar.In.Transparency = 0
                Door1.Bar.MainBar.Out.Transparency = 1
                if DoorR_Unlocked.Value == false then
                    Door2.Latch.LatchOut.Transparency = 1
                    Door2.Latch.LatchIn.Transparency = 0
                end
                wait(0.4)
                Door1.Bar.MainBar.In.Transparency = 1
                Door1.Bar.MainBar.Out.Transparency = 0
                spawn(UnlockL)
                WeldL.Enabled = false
                ClickBarL.MaxActivationDistance = DoorProperties.BAR_L
            elseif DoorL_Unlocked.Value == true then
                State.Value = "DOOR_LOCKED"
                DoorL_Unlocked.Value = false
                Door1.Door.BarSound:Play()
                ClickBarL.MaxActivationDistance = 0
                Door1.Bar.MainBar.In.Transparency = 0
                Door1.Bar.MainBar.Out.Transparency = 1
                wait(0.4)
                Door1.Bar.MainBar.In.Transparency = 1
                Door1.Bar.MainBar.Out.Transparency = 0
                spawn(LockL)
                wait(2.5)
                WeldL.Enabled = true
                ClickBarL.MaxActivationDistance = DoorProperties.BAR_L
                if DoorR_Unlocked.Value == false then
                    Door2.Latch.LatchOut.Transparency = 0
                    Door2.Latch.LatchIn.Transparency = 1
                end
            end
        end
        local function RightDoorFunction()
            if DoorR_Unlocked.Value == false then
                DoorR_Unlocked.Value = true
                Door2.Door.BarSound:Play()
                ClickBarR.MaxActivationDistance = 0
                Door2.Bar.MainBar.In.Transparency = 0
                Door2.Bar.MainBar.Out.Transparency = 1
                if DoorL_Unlocked.Value == false then
                    Door2.Latch.LatchOut.Transparency = 1
                    Door2.Latch.LatchIn.Transparency = 0
                end
                wait(0.4)
                Door2.Bar.MainBar.In.Transparency = 1
                Door2.Bar.MainBar.Out.Transparency = 0
                spawn(UnlockR)
                WeldR.Enabled = false
                ClickBarR.MaxActivationDistance = DoorProperties.BAR_R
            elseif DoorR_Unlocked.Value == true then
                DoorR_Unlocked.Value = false
                Door2.Door.BarSound:Play()
                ClickBarR.MaxActivationDistance = 0
                Door2.Bar.MainBar.In.Transparency = 0
                Door2.Bar.MainBar.Out.Transparency = 1

                wait(0.4)
                Door2.Bar.MainBar.In.Transparency = 1
                Door2.Bar.MainBar.Out.Transparency = 0

                spawn(LockR)
                wait(2.5)
                WeldR.Enabled = true
                ClickBarR.MaxActivationDistance = DoorProperties.BAR_R
                if DoorL_Unlocked.Value == false then
                    Door2.Latch.LatchOut.Transparency = 0
                    Door2.Latch.LatchIn.Transparency = 1
                end
            end
        end

        function isWhitelisted(plr)
            if not (plr:IsA('Player')) then
                return error('Supplied argument is not a Player!')
            end

            if not DoorSettings.WHITELISTENABLED then return true end

            for GroupID, Ranks in pairs(DoorSettings.WHITELIST.GROUP_WHITELIST) do
                local GroupRank = plr:GetRankInGroup(tonumber(GroupID)) -- Don't worry, this most definatley works

                for _, RankNumber in pairs(Ranks) do
                    if (RankNumber == GroupRank) then
                        return true
                    end
                end
            end

            for _, UserID in pairs(DoorSettings.WHITELIST.USERS_WHITELIST) do
                if (UserID == plr.UserId) then return true end
            end

            return false
        end

        -- ClickBar Stuff

        ClickBarL.MouseClick:Connect(function(plr)
            if DoorLDisabled.Value == false then
                if isWhitelisted(plr) then
                    spawn(LeftDoorFunction)
                end
            end
        end)
        ClickBarR.MouseClick:Connect(function(plr)
            if DoorRDisabled.Value == false then
                if isWhitelisted(plr) then
                    spawn(RightDoorFunction)
                end
            end
        end)

        -- Door Handles
        ClickHandleR.MouseClick:Connect(function(plr)
            if DoorRDisabled.Value == true then
                if isWhitelisted(plr) then spawn(DoorHandleR) end
            end
        end)
        ClickHandleL.MouseClick:Connect(function(plr)
            if DoorLDisabled.Value == true then
                if isWhitelisted(plr) then spawn(DoorHandleL) end
            end
        end)
        -- Key Things

        Door2.Bar.ClickHolder.Touched:Connect(function(Tool)
            local MainTool = Tool.Parent
            local plr = MainTool:FindFirstAncestorWhichIsA("Player") or
                            game:GetService("Players")
                                :GetPlayerFromCharacter(MainTool.Parent)

            if not plr then return end

            if not (isWhitelisted(plr)) then return end

            if MainTool:IsA('Tool') and MainTool:FindFirstChild("MaxtorKey") then
                -- We verify the key here to make sure its got everything we need
                if DoorRDisabled.Value == false then
                    if ToolCooldownR.Value == false then
                        ToolCooldownR.Value = true
                        -- Unlocking the door
                        WeldR.Enabled = false
                        spawn(UnlockR)
                        DoorRDisabled.Value = true
                        DoorR_Unlocked.Value = true
                        ClickBarR.MaxActivationDistance = 0
                        ClickHandleR.MaxActivationDistance =
                            DoorProperties.HANDLE_R
                        Door2.Bar.MainBar.In.Transparency = 0
                        Door2.Bar.MainBar.Out.Transparency = 1

                        if DoorL_Unlocked.Value == false then
                            Door2.Latch.LatchOut.Transparency = 1
                            Door2.Latch.LatchIn.Transparency = 0
                        end
                        wait(2)
                        ToolCooldownR.Value = false
                    end
                elseif DoorRDisabled.Value == true then
                    if ToolCooldownR.Value == false then
                        ToolCooldownR.Value = true
                        -- Locking the door
                        spawn(LockR)
                        DoorRDisabled.Value = false
                        DoorR_Unlocked.Value = false
                        ClickHandleR.MaxActivationDistance = 0
                        Door2.Bar.MainBar.In.Transparency = 1
                        Door2.Bar.MainBar.Out.Transparency = 0

                        wait(3.5)
                        WeldR.Enabled = false
                        ClickBarR.MaxActivationDistance = DoorProperties.BAR_R
                        if DoorL_Unlocked.Value == false then
                            Door2.Latch.LatchOut.Transparency = 0
                            Door2.Latch.LatchIn.Transparency = 1
                        end
                        wait(2)
                        ToolCooldownR.Value = false
                    end
                end
            end
        end)

        Door1.Bar.ClickHolder.Touched:Connect(function(Tool)
            local MainTool = Tool.Parent
            local plr = MainTool:FindFirstAncestorWhichIsA("Player") or
                            game:GetService("Players")
                                :GetPlayerFromCharacter(MainTool.Parent)

            if not plr then return end

            if not (isWhitelisted(plr)) then return end

            if MainTool:IsA('Tool') and MainTool:FindFirstChild("MaxtorKey") then
                if DoorLDisabled.Value == false then
                    if ToolCooldownL.Value == false then
                        ToolCooldownL.Value = true
                        -- Unlocking the door
                        WeldL.Enabled = false
                        spawn(UnlockL)
                        DoorLDisabled.Value = true
                        DoorL_Unlocked.Value = true
                        ClickBarL.MaxActivationDistance = 0
                        ClickHandleL.MaxActivationDistance =
                            DoorProperties.HANDLE_L
                        Door1.Bar.MainBar.In.Transparency = 0
                        Door1.Bar.MainBar.Out.Transparency = 1

                        if DoorR_Unlocked.Value == false then
                            Door2.Latch.LatchOut.Transparency = 1
                            Door2.Latch.LatchIn.Transparency = 0
                        end
                        wait(2)
                        ToolCooldownL.Value = false
                    end
                elseif DoorLDisabled.Value == true then
                    if ToolCooldownL.Value == false then
                        ToolCooldownL.Value = true
                        -- Locking the door
                        spawn(LockL)
                        DoorLDisabled.Value = false
                        DoorL_Unlocked.Value = false
                        Door1.Bar.MainBar.In.Transparency = 1
                        Door1.Bar.MainBar.Out.Transparency = 0
                        ClickHandleL.MaxActivationDistance = 0

                        wait(3.5)
                        WeldL.Enabled = false
                        ClickBarL.MaxActivationDistance = DoorProperties.BAR_L
                        if DoorR_Unlocked.Value == false then
                            Door2.Latch.LatchOut.Transparency = 0
                            Door2.Latch.LatchIn.Transparency = 1
                        end
                        wait(2)
                        ToolCooldownL.Value = false
                    end
                end
            end
        end)
    end
}
