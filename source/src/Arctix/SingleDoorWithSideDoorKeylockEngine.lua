return {
    run = function(script, ...)
        local System = pcall(function()
            if script.Parent.Parent.Parent:FindFirstChild('VirtuaAPI') then
                return script.Parent.Parent.Parent:WaitForChild('VirtuaAPI')
            else
                return nil
            end
        end)
        local function print(...) warn(':: Virtua Artix ::', ...) end

        local Door = script.Parent
        local HingeConstraint = Door.Doors.Door.Door.DoorHinge
        local SideDoorHingeConstraint = Door.Doors.SideDoor.Door.SideHinge
        local VirtuaFunction = Door.VirtuaFunction
        local OpenValue = Instance.new('BoolValue', script)
        local SideDoorOpenValue = Instance.new('BoolValue', script)
        local HoldingValue = Instance.new('BoolValue', script)
        local LockedValue = Instance.new('BoolValue', script)
        local Settings = require(Door.DoorSettings)

        OpenValue.Name = 'DoorOpenState'
        SideDoorOpenValue.Name = 'SideDoorOpenState'
        HoldingValue.Name = 'DoorHoldingState'
        LockedValue.Name = 'DoorLockedState'

        local DoorFunctions = {};

        local DoorDebounceTime = Settings.DoorDebounceTime
        local DoorDebounceValue = Instance.new('BoolValue')
        local SideDoorDebounceValue = Instance.new('BoolValue')

        local InteractionPull;
        local InteractionPush;
        local InteractionSideDoor;

        if Settings.DoorInteractionType == "ProximityPrompt" then
            local AttachmentPull = Instance.new("Attachment",
                                                Door.Doors.Door.Pull)
            local AttachmentPush = Instance.new("Attachment",
                                                Door.Doors.Door.Push)
            local AttachmentSideDoor = Instance.new("Attachment", Door.Doors
                                                        .SideDoor.SideDoorSystem
                                                        .Main)

            InteractionPull = Instance.new("ProximityPrompt", AttachmentPull)
            InteractionPush = Instance.new("ProximityPrompt", AttachmentPush)
            InteractionSideDoor = Instance.new("ProximityPrompt",
                                               AttachmentSideDoor)

            InteractionPull.MaxActivationDistance = 10
            InteractionPush.MaxActivationDistance = 10
            InteractionSideDoor.MaxActivationDistance = 10
            InteractionPull.ActionText = 'Open Door'
            InteractionPush.ActionText = 'Open Door'
            InteractionSideDoor.ActionText = 'Open Side Door'
            InteractionPull.HoldDuration = 0.5
            InteractionPush.HoldDuration = 0.5
            InteractionSideDoor.HoldDuration = 0.5
        elseif Settings.DoorInteractionType == "ClickDetector" then
            InteractionPull =
                Instance.new("ClickDetector", Door.Doors.Door.Pull)
            InteractionPush =
                Instance.new("ClickDetector", Door.Doors.Door.Push)
            InteractionSideDoor = Instance.new("ClickDetector", Door.Doors
                                                   .SideDoor.SideDoorSystem.Main)

            InteractionPush.MaxActivationDistance = 10
            InteractionPull.MaxActivationDistance = 10
            InteractionSideDoor.MaxActivationDistance = 10
        end

        if Settings.DoorLabel then
            if Door.Doors.Door:FindFirstChild('Tag') then
                Door.Doors.Door.Tag.Tag.TagUI.TagText.Text = Settings.DoorLabel
            end
        else
            if Door.Doors.Door:FindFirstChild('Tag') then
                script.Parent.Doors.Door.Tag.Tag.Transparency = 1
                script.Parent.Doors.Door.Tag.Case.Transparency = 1
                script.Parent.Doors.Door.Tag.Tag.TagUI.Enabled = false
            end
        end

        function DoorFunctions.checkForWhitelist(player)
            if not (Settings.Whitelist.WhitelistEnabled) then
                return true
            end
            for GroupID, GroupRanks in pairs(
                                           Settings.Whitelist.WhitelistTable
                                               .WhitelistedGroups) do
                local gr = player:GetRankInGroup(GroupID)
                for _, RankID in pairs(GroupRanks) do
                    if (gr == RankID) then return true end
                end
            end
            for _, UserId in pairs(Settings.Whitelist.WhitelistTable
                                       .WhitelistedPlayers) do
                if (player.UserId == UserId) then return true end
            end
            return false
        end

        function DoorFunctions.Open()
            HingeConstraint.TargetAngle = Settings.LeftDoorOpenAngle
            OpenValue.Value = true

            if Settings.DoorInteractionType == "ProximityPrompt" then
                InteractionPull.ActionText = 'Close Door'
                InteractionPush.ActionText = 'Close Door'
            end
        end

        function DoorFunctions.OpenSideDoor()
            SideDoorHingeConstraint.ActuatorType = Enum.ActuatorType.None
            SideDoorHingeConstraint.LimitsEnabled = true
            SideDoorHingeConstraint.LowerAngle = -Settings.RightDoorOpenAngle
            SideDoorHingeConstraint.UpperAngle = Settings.RightDoorOpenAngle
            SideDoorOpenValue.Value = true

            Door.Doors.SideDoor.SideDoorSystem.LowerLatch.Up.Transparency = 0
            Door.Doors.SideDoor.SideDoorSystem.LowerLatch.Down.Transparency = 1
            Door.Doors.SideDoor.SideDoorSystem.UpperLatch.Up.Transparency = 0
            Door.Doors.SideDoor.SideDoorSystem.UpperLatch.Down.Transparency = 1
            Door.Doors.SideDoor.Door.Lock:Play()

            if Settings.DoorInteractionType == "ProximityPrompt" then
                InteractionSideDoor.ActionText = 'Close Side Door'
            end
        end

        function DoorFunctions.CloseSideDoor()
            SideDoorHingeConstraint.ActuatorType = Enum.ActuatorType.Servo
            SideDoorHingeConstraint.LimitsEnabled = true
            SideDoorOpenValue.Value = false

            Door.Doors.SideDoor.SideDoorSystem.LowerLatch.Up.Transparency = 1
            Door.Doors.SideDoor.SideDoorSystem.LowerLatch.Down.Transparency = 0
            Door.Doors.SideDoor.SideDoorSystem.UpperLatch.Up.Transparency = 1
            Door.Doors.SideDoor.SideDoorSystem.UpperLatch.Down.Transparency = 0
            Door.Doors.SideDoor.Door.Lock:Play()

            if Settings.DoorInteractionType == "ProximityPrompt" then
                InteractionSideDoor.ActionText = 'Open Side Door'
            end
        end

        function DoorFunctions.Close()
            HingeConstraint.TargetAngle = 0
            OpenValue.Value = false

            if Settings.DoorInteractionType == "ProximityPrompt" then
                InteractionPull.ActionText = 'Open Door'
                InteractionPush.ActionText = 'Open Door'
            end
        end

        function DoorFunctions.Hold()
            local HoldState = HoldingValue.Value

            HoldState = not HoldState
            if (not HoldState) then
                DoorFunctions.Open()
            else
                DoorFunctions.Close()
            end
        end

        function DoorFunctions.Lock()
            if (not LockedValue.Value) then
                LockedValue.Value = true
                Door.Doors.Door.Lock.Locked.Transparency = 0
                Door.Doors.Door.Lock.Unlocked.Transparency = 1
                DoorFunctions.DisableInteractions()
                DoorFunctions.Close()
            else
                LockedValue.Value = false
                Door.Doors.Door.Lock.Locked.Transparency = 1
                Door.Doors.Door.Lock.Unlocked.Transparency = 0
                DoorFunctions.EnableInteractions()
            end
        end

        function DoorFunctions.LockInteraction(obj)
            if (not obj.Parent:FindFirstChild("VirtuaCard")) then
                return
            end
            if (not obj.Parent:FindFirstChild("CardRank")) then
                return
            end
            if (not table.find(Settings.KeyLevel,
                               obj.Parent:FindFirstChild("CardRank").Value)) then
                return
            end
            if not game:GetService('Players'):FindFirstChild(obj.Parent.Parent
                                                                 .Name) then
                return
            end
            if not DoorFunctions.checkForWhitelist(
                game:GetService('Players')[obj.Parent.Parent.Name]) then
                return
            end

            if HoldingValue.Value then return end
            if DoorDebounceValue.Value then return end
            DoorDebounceValue.Value = true

            DoorFunctions.Lock()

            task.wait(DoorDebounceTime)
            DoorDebounceValue.Value = false
        end

        function DoorFunctions.Interaction(plr)
            if HoldingValue.Value then return end
            if DoorDebounceValue.Value then return end
            DoorDebounceValue.Value = true

            local IsWhitelisted = DoorFunctions.checkForWhitelist(plr)
            if not IsWhitelisted then return end

            if not OpenValue.Value then
                DoorFunctions.Open()
            else
                DoorFunctions.Close()
            end

            task.wait(DoorDebounceTime)
            DoorDebounceValue.Value = false
        end

        function DoorFunctions.SideDoorInteraction(plr)
            if HoldingValue.Value then return end
            if SideDoorDebounceValue.Value then return end
            SideDoorDebounceValue.Value = true

            local IsWhitelisted = DoorFunctions.checkForWhitelist(plr)
            if not IsWhitelisted then return end

            if not SideDoorOpenValue.Value then
                DoorFunctions.OpenSideDoor()
            else
                DoorFunctions.CloseSideDoor()
            end

            task.wait(DoorDebounceTime)
            SideDoorDebounceValue.Value = false
        end

        function DoorFunctions.DisableInteractions()
            if Settings.DoorInteractionType == "ProximityPrompt" then
                InteractionPull.Enabled = false
                InteractionPush.Enabled = false
                InteractionSideDoor.Enabled = false
            else
                InteractionPull.MaxActivationDistance = 0
                InteractionPush.MaxActivationDistance = 0
                InteractionSideDoor.MaxActivationDistance = 0
            end
        end

        function DoorFunctions.EnableInteractions()
            if Settings.DoorInteractionType == "ProximityPrompt" then
                InteractionPull.Enabled = true
                InteractionPush.Enabled = true
                InteractionSideDoor.Enabled = true
            else
                InteractionPull.MaxActivationDistance = 10
                InteractionPush.MaxActivationDistance = 10
                InteractionSideDoor.MaxActivationDistance = 10
            end
        end

        function VirtuaFunction.OnInvoke(Command)
            if Command == 'DisableInteractions' then
                if LockedValue.Value == true then return end
                DoorFunctions.DisableInteractions()
            elseif Command == 'EnableInteractions' then
                if LockedValue.Value == true then return end
                DoorFunctions.EnableInteractions()
            elseif Command == 'DoorOpen' then
                if LockedValue.Value == true then return end
                if HoldingValue.Value == true then return end
                if not OpenValue.Value then DoorFunctions.Open() end
            elseif Command == 'DoorClose' then
                if LockedValue.Value == true then return end
                if HoldingValue.Value == true then return end
                if OpenValue.Value then DoorFunctions.Close() end
                if SideDoorOpenValue.Value then
                    DoorFunctions.CloseSideDoor()
                end
            elseif Command == 'DoorHold' then
                if LockedValue.Value == true then return end
                DoorFunctions.Hold()
            elseif Command == 'DoorLock' then
                if HoldingValue.Value == true then return end
                DoorFunctions.Lock()
            elseif Command == 'DoorRelease' then
                if LockedValue.Value == true then return end
                DoorFunctions.Hold()
            end
        end

        if System then
            script.Parent.Parent.Parent.VirtuaAPI.Event:Connect(function(ev)
                if ev == 'OpenDoors' then
                    if LockedValue.Value == true then return end
                    if HoldingValue.Value == true then return end
                    if not OpenValue.Value then
                        DoorFunctions.Open()
                    end
                elseif ev == 'CloseDoors' then
                    if LockedValue.Value == true then return end
                    if HoldingValue.Value == true then return end
                    if OpenValue.Value then
                        DoorFunctions.Close()
                    end
                elseif ev == 'ReleaseDoors' or ev == 'HoldDoors' then
                    if LockedValue.Value == true then return end
                    DoorFunctions.Hold()
                elseif ev == 'LockDoors' then
                    if HoldingValue.Value == true then return end
                    DoorFunctions.Lock()
                elseif ev == 'FireMode' then
                    if HoldingValue.Value == true then return end
                    DoorFunctions.Lock()
                end
            end)
        end

        if (Settings.LockedOnStartup) then DoorFunctions.Lock() end

        if Settings.DoorInteractionType == "ProximityPrompt" then
            InteractionPull.Triggered:Connect(function(plr)
                DoorFunctions.Interaction(plr)
            end)
            InteractionPush.Triggered:Connect(function(plr)
                DoorFunctions.Interaction(plr)
            end)
            InteractionSideDoor.Triggered:Connect(function(plr)
                DoorFunctions.SideDoorInteraction(plr)
            end)
        else
            InteractionPull.MouseClick:Connect(function(plr)
                DoorFunctions.Interaction(plr)
            end)
            InteractionPush.MouseClick:Connect(function(plr)
                DoorFunctions.Interaction(plr)
            end)
            InteractionSideDoor.MouseClick:Connect(function(plr)
                DoorFunctions.SideDoorInteraction(plr)
            end)
        end

        Door.Doors.Door.Lock.Sensor.Touched:Connect(function(obj)
            DoorFunctions.LockInteraction(obj)
        end)

        DoorDebounceValue.Changed:Connect(function(value)
            if value then
                DoorFunctions.DisableInteractions()
            else
                DoorFunctions.EnableInteractions()
            end
        end)

        SideDoorDebounceValue.Changed:Connect(function(value)
            if value then
                if Settings.DoorInteractionType == "ProximityPrompt" then
                    InteractionSideDoor.Enabled = false
                else
                    InteractionSideDoor.MaxActivationDistance = 0
                end
            else
                if Settings.DoorInteractionType == "ProximityPrompt" then
                    InteractionSideDoor.Enabled = true
                else
                    InteractionSideDoor.MaxActivationDistance = 10
                end
            end
        end)
    end
}
