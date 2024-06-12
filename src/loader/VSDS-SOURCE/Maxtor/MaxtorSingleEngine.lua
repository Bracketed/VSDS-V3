return {
    run = function(script, ...)
        local Door1 = script.Parent.DoorL
        local DoorSettings = require(script.Parent.Settings)
        local ClickBarL = Instance.new("ClickDetector", Door1.Bar.ClickHolder)
        local ClickHandleL = Instance.new("ClickDetector", Door1.Pull)
        local WeldL = Instance.new("WeldConstraint", Door1.Door)
        local DoorL_Unlocked = false
        local DoorLDisabled = false
        local ToolCooldownL = false

        WeldL.Name = "Weld_DoorL"
        WeldL.Part0 = Door1.Door
        WeldL.Part1 = script.Parent.Frame.DoorFrame.Left
        ClickBarL.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.BAR_L
        ClickHandleL.MaxActivationDistance = 0

        -- Door Stuff with making them able to be moved
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
        -- Main door stuff
        local function LeftDoorFunction()
            if DoorL_Unlocked == false then
                DoorL_Unlocked = true
                Door1.Door.BarSound:Play()
                ClickBarL.MaxActivationDistance = 0

                Door1.Bar.MainBar.In.Transparency = 0
                Door1.Bar.MainBar.Out.Transparency = 1
                Door1.Latch.LatchOut.Transparency = 1
                Door1.Latch.LatchIn.Transparency = 0
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
                Door1.Latch.LatchOut.Transparency = 1
                Door1.Latch.LatchIn.Transparency = 0
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
            if DoorLDisabled == false then
                if isWhitelisted(plr) then LeftDoorFunction() end
            end
        end)
        ClickHandleL.MouseClick:Connect(function(plr)
            if DoorLDisabled == true then
                if isWhitelisted(plr) then DoorHandleL() end
            end
        end)

        -- Key Things

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
                        -- Unlocking the door
                        WeldL.Enabled = false
                        UnlockL()
                        DoorLDisabled = true
                        DoorL_Unlocked = true
                        ClickBarL.MaxActivationDistance = 0
                        ClickHandleL.MaxActivationDistance =
                            DoorSettings.DOOR_SETTINGS.HANDLE_L
                        Door1.Bar.MainBar.In.Transparency = 0
                        Door1.Bar.MainBar.Out.Transparency = 1

                        Door1.Latch.LatchOut.Transparency = 1
                        Door1.Latch.LatchIn.Transparency = 0
                        task.wait(2)
                        ToolCooldownL = false
                    end
                elseif DoorLDisabled == true then
                    if ToolCooldownL == false then
                        ToolCooldownL = true
                        -- Locking the door
                        LockL()
                        DoorLDisabled = false
                        DoorL_Unlocked = false
                        Door1.Bar.MainBar.In.Transparency = 1
                        Door1.Bar.MainBar.Out.Transparency = 0
                        ClickHandleL.MaxActivationDistance = 0

                        task.wait(3.5)
                        WeldL.Enabled = false
                        ClickBarL.MaxActivationDistance = DoorSettings.DOOR_SETTINGS.BAR_L
                        Door1.Latch.LatchOut.Transparency = 1
                        Door1.Latch.LatchIn.Transparency = 0
                        task.wait(2)
                        ToolCooldownL = false
                    end
                end
            end
        end)
    end
}
