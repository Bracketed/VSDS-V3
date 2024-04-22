return {
	run = function(script, ...)
		local System = pcall(function() if script.Parent.Parent.Parent:FindFirstChild('VirtuaAPI') then return script.Parent.Parent.Parent:WaitForChild('VirtuaAPI') else return nil end end)
		local function print(...) warn(':: Virtua Artix ::', ...) end

		local Door = script.Parent
		local LeftHingeConstraint = Door.Doors.DoorL.Door.DoorHinge
		local RightHingeConstraint = Door.Doors.DoorR.Door.DoorHinge
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

		local InteractionLeftPull;
		local InteractionLeftPush;

		local InteractionRightPull;
		local InteractionRightPush;

		if Settings.DoorInteractionType == "ProximityPrompt" then
			local AttachmentLeftPull = Instance.new("Attachment", Door.Doors.DoorL.Pull)
			local AttachmentLeftPush = Instance.new("Attachment", Door.Doors.DoorL.Push)
			InteractionLeftPull = Instance.new("ProximityPrompt", AttachmentLeftPull)
			InteractionLeftPush = Instance.new("ProximityPrompt", AttachmentLeftPush)

			InteractionLeftPull.MaxActivationDistance = 10
			InteractionLeftPush.MaxActivationDistance = 10
			InteractionLeftPull.ActionText = 'Open Door'
			InteractionLeftPush.ActionText = 'Open Door'
			InteractionLeftPull.HoldDuration = 0.5
			InteractionLeftPush.HoldDuration = 0.5

			local AttachmentRightPull = Instance.new("Attachment", Door.Doors.DoorR.Pull)
			local AttachmentRightPush = Instance.new("Attachment", Door.Doors.DoorR.Push)
			InteractionRightPull = Instance.new("ProximityPrompt", AttachmentRightPull)
			InteractionRightPush = Instance.new("ProximityPrompt", AttachmentRightPush)

			InteractionRightPull.MaxActivationDistance = 10
			InteractionRightPush.MaxActivationDistance = 10
			InteractionRightPull.ActionText = 'Open Door'
			InteractionRightPush.ActionText = 'Open Door'
			InteractionRightPull.HoldDuration = 0.5
			InteractionRightPush.HoldDuration = 0.5
		elseif Settings.DoorInteractionType == "ClickDetector" then
			InteractionRightPull = Instance.new("ClickDetector", Door.Doors.DoorL.Pull)
			InteractionRightPush = Instance.new("ClickDetector", Door.Doors.DoorL.Push)

			InteractionRightPush.MaxActivationDistance = 10
			InteractionRightPull.MaxActivationDistance = 10

			InteractionRightPull = Instance.new("ClickDetector", Door.Doors.DoorR.Pull)
			InteractionRightPush = Instance.new("ClickDetector", Door.Doors.DoorR.Push)

			InteractionRightPush.MaxActivationDistance = 10
			InteractionRightPull.MaxActivationDistance = 10
		end

		if Settings.DoorLabel then
			if Door.Doors.DoorL:FindFirstChild('Tag') then
				Door.Doors.DoorL.Tag.Tag.TagUI.TagText.Text = Settings.DoorLabel
			end
			if Door.Doors.DoorR:FindFirstChild('Tag') then
				Door.Doors.DoorR.Tag.Tag.TagUI.TagText.Text = Settings.DoorLabel
			end
		else
			if Door.Doors.DoorL:FindFirstChild('Tag') then
				Door.Doors.DoorL.Tag.Tag.Transparency = 1
				Door.Doors.DoorL.Tag.Case.Transparency = 1
				Door.Doors.DoorL.Tag.Tag.TagUI.Enabled = false
			end
			if Door.Doors.DoorR:FindFirstChild('Tag') then
				Door.Doors.DoorR.Tag.Tag.Transparency = 1
				Door.Doors.DoorR.Tag.Case.Transparency = 1
				Door.Doors.DoorR.Tag.Tag.TagUI.Enabled = false
			end
		end

		function DoorFunctions.checkForWhitelist(player)
			if not (Settings.Whitelist.WhitelistEnabled) then return true end
			for GroupID, GroupRanks in pairs(Settings.Whitelist.WhitelistTable.WhitelistedGroups) do
				local gr = player:GetRankInGroup(GroupID)
				for _, RankID in pairs(GroupRanks) do if (gr == RankID) then return true end end
			end
			for _, UserId in pairs(Settings.Whitelist.WhitelistTable.WhitelistedPlayers) do if (player.UserId == UserId) then return true end end
			return false
		end

		function DoorFunctions.Open()
			LeftHingeConstraint.TargetAngle = Settings.LeftDoorOpenAngle
			RightHingeConstraint.TargetAngle = Settings.RightDoorOpenAngle
			OpenValue.Value = true

			if Settings.DoorInteractionType == "ProximityPrompt" then
				InteractionLeftPull.ActionText = 'Close Door'
				InteractionLeftPush.ActionText = 'Close Door'
				InteractionRightPull.ActionText = 'Close Door'
				InteractionRightPush.ActionText = 'Close Door'
			end
		end

		function DoorFunctions.Close()
			LeftHingeConstraint.TargetAngle = 0
			RightHingeConstraint.TargetAngle = 0
			OpenValue.Value = false

			if Settings.DoorInteractionType == "ProximityPrompt" then
				InteractionLeftPull.ActionText = 'Open Door'
				InteractionLeftPush.ActionText = 'Open Door'
				InteractionRightPull.ActionText = 'Open Door'
				InteractionRightPush.ActionText = 'Open Door'
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
				Door.Doors.DoorL.Lock.Locked.Transparency = 0
				Door.Doors.DoorL.Lock.Unlocked.Transparency = 1
				DoorFunctions.DisableInteractions()
				DoorFunctions.Close()
			else
				LockedValue.Value = false
				Door.Doors.DoorL.Lock.Locked.Transparency = 1
				Door.Doors.DoorL.Lock.Unlocked.Transparency = 0
				DoorFunctions.EnableInteractions()
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

		function DoorFunctions.LockInteraction(obj)
			if (not obj.Parent:FindFirstChild("VirtuaCard")) then return end
			if (not obj.Parent:FindFirstChild("CardRank")) then return end
			if (not table.find(Settings.KeyLevel, obj.Parent:FindFirstChild("CardRank").Value)) then return end
			if not game:GetService('Players'):FindFirstChild(obj.Parent.Parent.Name) then return end
			if not DoorFunctions.checkForWhitelist(game:GetService('Players')[obj.Parent.Parent.Name]) then return end

			if HoldingValue.Value then return end
			if DoorDebounceValue.Value then return end
			DoorDebounceValue.Value = true

			DoorFunctions.Lock()

			task.wait(DoorDebounceTime)
			DoorDebounceValue.Value = false
		end

		function DoorFunctions.DisableInteractions()
			if Settings.DoorInteractionType == "ProximityPrompt" then
				InteractionLeftPull.Enabled = false
				InteractionLeftPush.Enabled = false
				InteractionRightPull.Enabled = false
				InteractionRightPush.Enabled = false
			else
				InteractionLeftPull.MaxActivationDistance = 0
				InteractionLeftPush.MaxActivationDistance = 0
				InteractionRightPull.MaxActivationDistance = 0
				InteractionRightPush.MaxActivationDistance = 0
			end
		end

		function DoorFunctions.EnableInteractions()
			if Settings.DoorInteractionType == "ProximityPrompt" then
				InteractionLeftPull.Enabled = true
				InteractionLeftPush.Enabled = true
				InteractionRightPull.Enabled = true
				InteractionRightPush.Enabled = true
			else
				InteractionLeftPull.MaxActivationDistance = 10
				InteractionLeftPush.MaxActivationDistance = 10
				InteractionRightPull.MaxActivationDistance = 10
				InteractionRightPush.MaxActivationDistance = 10
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
				if not OpenValue.Value then
					DoorFunctions.Open()
				end
			elseif Command == 'DoorClose' then
				if LockedValue.Value == true then return end
				if HoldingValue.Value == true then return end
				if OpenValue.Value then
					DoorFunctions.Close()
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
				elseif ev =='FireMode' then
					if HoldingValue.Value == true then return end
					DoorFunctions.Lock()
				end
			end)
		end

		if (Settings.LockedOnStartup) then
			DoorFunctions.Lock()
		end

		if Settings.DoorInteractionType == "ProximityPrompt" then
			InteractionLeftPull.Triggered:Connect(function(plr) DoorFunctions.Interaction(plr) end)
			InteractionLeftPush.Triggered:Connect(function(plr) DoorFunctions.Interaction(plr) end)
			InteractionRightPull.Triggered:Connect(function(plr) DoorFunctions.Interaction(plr) end)
			InteractionRightPush.Triggered:Connect(function(plr) DoorFunctions.Interaction(plr) end)
		else
			InteractionLeftPull.MouseClick:Connect(function(plr) DoorFunctions.Interaction(plr) end)
			InteractionLeftPush.MouseClick:Connect(function(plr) DoorFunctions.Interaction(plr) end)
			InteractionRightPull.MouseClick:Connect(function(plr) DoorFunctions.Interaction(plr) end)
			InteractionRightPush.MouseClick:Connect(function(plr) DoorFunctions.Interaction(plr) end)
		end

		Door.Doors.DoorL.Lock.Sensor.Touched:Connect(function(obj)
			DoorFunctions.LockInteraction(obj)
		end)

		DoorDebounceValue.Changed:Connect(function(value)
			if LockedValue.Value then return end
			if value then
				DoorFunctions.DisableInteractions()
			else
				DoorFunctions.EnableInteractions()
			end
		end)
	end,
}
