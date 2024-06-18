return {
    run = function(script, ...)
        local Door1 = script.Parent.DoorL
        local Door2 = script.Parent.DoorR
        local DoorSettings = require(script.Parent.Settings)
        local ClickBarL = Instance.new("ClickDetector", Door1.Bar.ClickHolder)
        local ClickBarR = Instance.new("ClickDetector", Door2.Bar.ClickHolder)
        local ClickHandleL = Instance.new("ClickDetector", Door1.Pull)
        local ClickHandleR = Instance.new("ClickDetector", Door2.Pull)
        local WeldR = Instance.new("WeldConstraint", Door2.Door)
        local WeldL = Instance.new("WeldConstraint", Door1.Door)
        local DoorL_Unlocked = false
        local DoorR_Unlocked = false
        local DoorRDisabled = false
        local DoorLDisabled = false
        local ToolCooldownR = false
        local ToolCooldownL = false

        WeldL.Part0 = Door1.Door
        WeldL.Part1 = script.Parent.Frame.DoorFrame.Left
        WeldR.Part0 = Door2.Door
        WeldR.Part1 = script.Parent.Frame.DoorFrame.Right

        ClickBarL.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.BAR_L
        ClickBarR.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.BAR_R
        ClickHandleL.MaxActivationDistance = 0
        ClickHandleR.MaxActivationDistance = 0

        local function UnlockL()
            Door1.Door.DoorHinge.ActuatorType = "None"
            Door1.Door.DoorHinge.LimitsEnabled = true
            Door1.Door.DoorHinge.UpperAngle = 0
            Door1.Door.DoorHinge.LowerAngle = DoorSettings.DOOR_SETTINGS.DOOR_L
        end
        local function LockL()
            Door1.Door.DoorHinge.ActuatorType = "Servo"
            Door1.Door.DoorHinge.LimitsEnabled = false
            Door1.Door.DoorHinge.TargetAngle = 1
            task.wait(1.5)
            Door1.Door.DoorHinge.TargetAngle = 0
        end
        local function UnlockR()
            Door2.Door.DoorHinge.ActuatorType = "None"
            Door2.Door.DoorHinge.LimitsEnabled = true
            Door2.Door.DoorHinge.UpperAngle = DoorSettings.DOOR_SETTINGS.DOOR_R
            Door2.Door.DoorHinge.LowerAngle = 0
        end
        local function LockR()
            Door2.Door.DoorHinge.ActuatorType = "Servo"
            Door2.Door.DoorHinge.LimitsEnabled = false
            Door2.Door.DoorHinge.TargetAngle = -1
            task.wait(1.5)
            Door2.Door.DoorHinge.TargetAngle = 0
        end
        local function DoorHandleR()
            Door2.Door.DoorHinge.ActuatorType = "Servo"
            Door2.Door.DoorHinge.LimitsEnabled = false
            Door2.Door.DoorHinge.TargetAngle = DoorSettings.DOOR_SETTINGS.DOOR_R
            ClickHandleR.MaxActivationDistance = 0
            task.wait(3)
            Door2.Door.DoorHinge.ActuatorType = "None"
            ClickHandleR.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.HANDLE_R
            Door2.Door.DoorHinge.LimitsEnabled = true
            Door2.Door.DoorHinge.UpperAngle = DoorSettings.DOOR_SETTINGS.DOOR_R
            Door2.Door.DoorHinge.LowerAngle = 0
        end
        local function DoorHandleL()
            Door1.Door.DoorHinge.ActuatorType = "Servo"
            Door1.Door.DoorHinge.LimitsEnabled = false
            Door1.Door.DoorHinge.TargetAngle = DoorSettings.DOOR_SETTINGS.DOOR_L
            ClickHandleL.MaxActivationDistance = 0
            task.wait(3)
            Door1.Door.DoorHinge.ActuatorType = "None"
            ClickHandleL.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.HANDLE_L
            Door1.Door.DoorHinge.LimitsEnabled = true
            Door1.Door.DoorHinge.UpperAngle = DoorSettings.DOOR_SETTINGS.DOOR_L
            Door1.Door.DoorHinge.LowerAngle = 0
        end
        local function LeftDoorFunction()
            if DoorL_Unlocked == false then
                DoorL_Unlocked = true
                Door1.Door.BarSound:Play()
                ClickBarL.MaxActivationDistance = 0
                Door1.Bar.MainBar.In.Transparency = 0
                Door1.Bar.MainBar.Out.Transparency = 1
                if DoorR_Unlocked == false then
                    Door2.Latch.LatchOut.Transparency = 1
                    Door2.Latch.LatchIn.Transparency = 0
                end
                task.wait(0.4)
                Door1.Bar.MainBar.In.Transparency = 1
                Door1.Bar.MainBar.Out.Transparency = 0
                UnlockL()
                WeldL.Enabled = false
                ClickBarL.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.BAR_L
            elseif DoorL_Unlocked == true then
                DoorL_Unlocked = false
                Door1.Door.BarSound:Play()
                ClickBarL.MaxActivationDistance = 0
                Door1.Bar.MainBar.In.Transparency = 0
                Door1.Bar.MainBar.Out.Transparency = 1
                task.wait(0.4)
                Door1.Bar.MainBar.In.Transparency = 1
                Door1.Bar.MainBar.Out.Transparency = 0
                LockL()
                task.wait(2.5)
                WeldL.Enabled = true
                ClickBarL.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.BAR_L
                if DoorR_Unlocked == false then
                    Door2.Latch.LatchOut.Transparency = 0
                    Door2.Latch.LatchIn.Transparency = 1
                end
            end
        end
        local function RightDoorFunction()
            if DoorR_Unlocked == false then
                DoorR_Unlocked = true
                Door2.Door.BarSound:Play()
                ClickBarR.MaxActivationDistance = 0
                Door2.Bar.MainBar.In.Transparency = 0
                Door2.Bar.MainBar.Out.Transparency = 1
                if DoorL_Unlocked == false then
                    Door2.Latch.LatchOut.Transparency = 1
                    Door2.Latch.LatchIn.Transparency = 0
                end
                task.wait(0.4)
                Door2.Bar.MainBar.In.Transparency = 1
                Door2.Bar.MainBar.Out.Transparency = 0
                UnlockR()
                WeldR.Enabled = false
                ClickBarR.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.BAR_R
            elseif DoorR_Unlocked == true then
                DoorR_Unlocked = false
                Door2.Door.BarSound:Play()
                ClickBarR.MaxActivationDistance = 0
                Door2.Bar.MainBar.In.Transparency = 0
                Door2.Bar.MainBar.Out.Transparency = 1

                task.wait(0.4)
                Door2.Bar.MainBar.In.Transparency = 1
                Door2.Bar.MainBar.Out.Transparency = 0

                LockR()
                task.wait(2.5)
                WeldR.Enabled = true
                ClickBarR.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.BAR_R
                if DoorL_Unlocked == false then
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
                local GroupRank = plr:GetRankInGroup(tonumber(GroupID))

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


        ClickBarL.MouseClick:Connect(function(plr)
            if DoorLDisabled == false then
                if isWhitelisted(plr) then LeftDoorFunction() end
            end
        end)
        ClickBarR.MouseClick:Connect(function(plr)
            if DoorRDisabled == false then
                if isWhitelisted(plr) then RightDoorFunction() end
            end
        end)

        ClickHandleR.MouseClick:Connect(function(plr)
            if DoorRDisabled == true then
                if isWhitelisted(plr) then DoorHandleR() end
            end
        end)
        ClickHandleL.MouseClick:Connect(function(plr)
            if DoorLDisabled == true then
                if isWhitelisted(plr) then DoorHandleL() end
            end
        end)

        Door2.Bar.ClickHolder.Touched:Connect(function(Tool)
            local MainTool = Tool.Parent
            local plr = MainTool:FindFirstAncestorWhichIsA("Player") or
                            game:GetService("Players")
                                :GetPlayerFromCharacter(MainTool.Parent)

            if not plr then return end

            if not (isWhitelisted(plr)) then return end

            if MainTool:IsA('Tool') and MainTool:FindFirstChild("MaxtorKey") then
                if DoorRDisabled == false then
                    if ToolCooldownR == false then
                        ToolCooldownR = true
                        WeldR.Enabled = false
                        UnlockR()
                        DoorRDisabled = true
                        DoorR_Unlocked = true
                        ClickBarR.MaxActivationDistance = 0
                        ClickHandleR.MaxActivationDistance =
                            DoorSettings.DOOR_SETTINGS.HANDLE_R
                        Door2.Bar.MainBar.In.Transparency = 0
                        Door2.Bar.MainBar.Out.Transparency = 1

                        if DoorL_Unlocked == false then
                            Door2.Latch.LatchOut.Transparency = 1
                            Door2.Latch.LatchIn.Transparency = 0
                        end
                        task.wait(2)
                        ToolCooldownR = false
                    end
                elseif DoorRDisabled == true then
                    if ToolCooldownR == false then
                        ToolCooldownR = true
                        LockR()
                        DoorRDisabled = false
                        DoorR_Unlocked = false
                        ClickHandleR.MaxActivationDistance = 0
                        Door2.Bar.MainBar.In.Transparency = 1
                        Door2.Bar.MainBar.Out.Transparency = 0

                        task.wait(3.5)
                        WeldR.Enabled = false
                        ClickBarR.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.BAR_R
                        if DoorL_Unlocked == false then
                            Door2.Latch.LatchOut.Transparency = 0
                            Door2.Latch.LatchIn.Transparency = 1
                        end
                        task.wait(2)
                        ToolCooldownR = false
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
                if DoorLDisabled == false then
                    if ToolCooldownL == false then
                        ToolCooldownL = true
                        WeldL.Enabled = false
                        UnlockL()
                        DoorLDisabled = true
                        DoorL_Unlocked = true
                        ClickBarL.MaxActivationDistance = 0
                        ClickHandleL.MaxActivationDistance =
                            DoorSettings.DOOR_SETTINGS.HANDLE_L
                        Door1.Bar.MainBar.In.Transparency = 0
                        Door1.Bar.MainBar.Out.Transparency = 1

                        if DoorR_Unlocked == false then
                            Door2.Latch.LatchOut.Transparency = 1
                            Door2.Latch.LatchIn.Transparency = 0
                        end
                        task.wait(2)
                        ToolCooldownL = false
                    end
                elseif DoorLDisabled == true then
                    if ToolCooldownL == false then
                        ToolCooldownL = true
                        LockL()
                        DoorLDisabled = false
                        DoorL_Unlocked = false
                        Door1.Bar.MainBar.In.Transparency = 1
                        Door1.Bar.MainBar.Out.Transparency = 0
                        ClickHandleL.MaxActivationDistance = 0

                        task.wait(3.5)
                        WeldL.Enabled = false
                        ClickBarL.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.BAR_L
                        if DoorR_Unlocked == false then
                            Door2.Latch.LatchOut.Transparency = 0
                            Door2.Latch.LatchIn.Transparency = 1
                        end
                        task.wait(2)
                        ToolCooldownL = false
                    end
                end
            end
        end)
    end
}
