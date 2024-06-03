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
        local VirtuaFunction = Door.VirtuaFunction
        local OpenValue = Instance.new('BoolValue', script)
        local HoldingValue = Instance.new('BoolValue', script)
        local LockedValue = Instance.new('BoolValue', script)
        local Settings = require(Door.DoorSettings)

        OpenValue.Name = 'DoorOpenState'
        HoldingValue.Name = 'DoorHoldingState'
        LockedValue.Name = 'DoorLockedState'

        local DoorFunctions = {};

        local DoorDebounceTime = Settings.DoorDebounceTime
        local DoorDebounceValue = Instance.new('BoolValue')

        local InteractionPull;
        local InteractionPush;

        if Settings.DoorInteractionType == "ProximityPrompt" then
            local AttachmentPull = Instance.new("Attachment",
                                                Door.Doors.Door.Pull)
            local AttachmentPush = Instance.new("Attachment",
                                                Door.Doors.Door.Push)

            InteractionPull = Instance.new("ProximityPrompt", AttachmentPull)
            InteractionPush = Instance.new("ProximityPrompt", AttachmentPush)

            InteractionPull.MaxActivationDistance = 10
            InteractionPush.MaxActivationDistance = 10
            InteractionPull.ActionText = 'Open Door'
            InteractionPush.ActionText = 'Open Door'
            InteractionPull.HoldDuration = 0.5
            InteractionPush.HoldDuration = 0.5
        elseif Settings.DoorInteractionType == "ClickDetector" then
            InteractionPull = Instance.new("ClickDetector",
                                           script.Parent.Doors.Door.Pull)
            InteractionPush = Instance.new("ClickDetector",
                                           script.Parent.Doors.Door.Push)
            InteractionPush.MaxActivationDistance = 10
            InteractionPull.MaxActivationDistance = 10
        end

        if Settings.DoorLabel then
            for _, UI in pairs(Door.Doors:GetDescendants()) do
                if UI:IsA('SurfaceGui') and UI.Name == 'TagUI' then
                    if UI.TagText.Text == 'Room' then
                        UI.TagText.Text = Settings.DoorLabel
                    end
                end
            end
        else
            for _, Model in pairs(Door.Doors:GetDescendants()) do
                if Model:IsA('Model') and Model.Name == 'Tag' then
                    for _, Child in pairs(Model:GetDescendants()) do
                        pcall(function()
                            Child.Transparency = 1
                        end)
                        pcall(function()
                            Child.Enabled = false
                        end)
                    end
                end
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
            LockedValue.Value = not LockedValue.Value
            if (not LockedValue.Value) then
                DoorFunctions.Close()
                LockedValue.Value = true
            else
                LockedValue.Value = false
            end
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

        function DoorFunctions.DisableInteractions()
            if Settings.DoorInteractionType == "ProximityPrompt" then
                InteractionPull.Enabled = false
                InteractionPush.Enabled = false
            else
                InteractionPull.MaxActivationDistance = 0
                InteractionPush.MaxActivationDistance = 0
            end
        end

        function DoorFunctions.EnableInteractions()
            if Settings.DoorInteractionType == "ProximityPrompt" then
                InteractionPull.Enabled = true
                InteractionPush.Enabled = true
            else
                InteractionPull.MaxActivationDistance = 10
                InteractionPush.MaxActivationDistance = 10
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

        if Settings.DoorInteractionType == "ProximityPrompt" then
            InteractionPull.Triggered:Connect(function(plr)
                DoorFunctions.Interaction(plr)
            end)
            InteractionPush.Triggered:Connect(function(plr)
                DoorFunctions.Interaction(plr)
            end)
        else
            InteractionPull.MouseClick:Connect(function(plr)
                DoorFunctions.Interaction(plr)
            end)
            InteractionPush.MouseClick:Connect(function(plr)
                DoorFunctions.Interaction(plr)
            end)
        end

        DoorDebounceValue.Changed:Connect(function(value)
            if value then
                DoorFunctions.DisableInteractions()
            else
                DoorFunctions.EnableInteractions()
            end
        end)
    end
}
