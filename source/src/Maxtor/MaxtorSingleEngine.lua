return {
    run = function(script, ...)
        local Door1 = script.Parent.DoorL
        local DoorSettings = require(script.Parent.Settings)
        local DoorProperties = DoorSettings.DOOR_SETTINGS
        local State = Instance.new("StringValue", script.Parent)
        local ClickBarL = Instance.new("ClickDetector", Door1.Bar.ClickHolder)
        local ClickHandleL = Instance.new("ClickDetector", Door1.Pull)
        local WeldL = Instance.new("WeldConstraint", Door1.Door)
        local DoorL_Unlocked = Instance.new("BoolValue", script)
        local DoorLDisabled = Instance.new("BoolValue", script)
        local ToolCooldownL = Instance.new("BoolValue", script)

        WeldL.Name = "Weld_DoorL"
        WeldL.Part0 = Door1.Door
        WeldL.Part1 = script.Parent.Frame.DoorFrame.Left
        State.Name = "DOORSTATE"
        State.Value = "DOOR_UNUSED"
        ClickBarL.MaxActivationDistance = DoorProperties.BAR_L
        ClickHandleL.MaxActivationDistance = 0
        DoorL_Unlocked.Value = false
        DoorLDisabled.Value = false
        ToolCooldownL.Value = false
        DoorL_Unlocked.Name = "DOORL.IS-UNLOCKED"
        DoorLDisabled.Name = "DOORL.IS-DISABLED"
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
                Door1.Latch.LatchOut.Transparency = 1
                Door1.Latch.LatchIn.Transparency = 0
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
            if DoorLDisabled.Value == false then
                if isWhitelisted(plr) then
                    spawn(LeftDoorFunction)
                end
            end
        end)
        ClickHandleL.MouseClick:Connect(function(plr)
            if DoorLDisabled.Value == true then
                if isWhitelisted(plr) then spawn(DoorHandleL) end
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

                        Door1.Latch.LatchOut.Transparency = 1
                        Door1.Latch.LatchIn.Transparency = 0
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
                        Door1.Latch.LatchOut.Transparency = 1
                        Door1.Latch.LatchIn.Transparency = 0
                        wait(2)
                        ToolCooldownL.Value = false
                    end
                end
            end
        end)
    end
}
