return {
	run = function(script, ...)
		local InUse = false
		local Button = {}
		local settings = require(script.Parent)
		local function print(...) warn(':: Virtua Arctix ::', ...) end
		local TS = game:GetService('TweenService')
		local TSInfo = TweenInfo.new(1)
		local TSInfo2 = TweenInfo.new(0.2)
		local Toggled = false

		local ButtonInteraction

		function Button.ChangeLED(Color)
			for i, LED in pairs(script.Parent.Parent.Parts:GetDescendants()) do
				if LED.Name == 'ButtonLED' then
					if Color then TS:Create(LED, TSInfo, {Color = Color}):Play() end
					if not Color then TS:Create(LED, TSInfo, {Color = settings['Button-Colors']["Idle-Color"]}):Play() end
				end
			end
		end

		function Button.ButtonPress()
			local TweenIn = TS:Create(script.Parent.Parent.Parts.ButtonBody.Button.Button, TSInfo2, {CFrame = script.Parent.Parent.Parts.ButtonBody.Button.ButtonIn.CFrame})
			local TweenOut = TS:Create(script.Parent.Parent.Parts.ButtonBody.Button.Button, TSInfo2, {CFrame = script.Parent.Parent.Parts.ButtonBody.Button.ButtonOut.CFrame})

			if settings.ToggleButton then
				if Toggled then
					TweenOut:Play()
				else
					TweenIn:Play()
				end
			else
				TweenIn:Play()
				TweenIn.Completed:Wait()
				TweenOut:Play()
			end
		end

		function Button.checkForWhitelist(player)
			if not (settings['Button-Whitelist'].WhitelistEnabled) then return true end
			for GroupID, GroupRanks in pairs(settings['Button-Whitelist'].WhitelistTable.WhitelistedGroups) do
				local gr = player:GetRankInGroup(GroupID)
				for _, RankID in pairs(GroupRanks) do if (gr == RankID) then return true end end
			end
			for _, UserId in pairs(settings['Button-Whitelist'].WhitelistTable.WhitelistedPlayers) do if (player.UserId == UserId) then return true end end
			return false
		end

		function Button.ButtonPressed(plr)
			if (InUse) then return end

			Button.ButtonPress()

			if not Button.checkForWhitelist(plr) then
				Button.ChangeLED(settings['Button-Colors']["Denied-Color"])
				InUse = true
				task.wait(settings.PressTime)
				InUse = false
				Button.ChangeLED()
				return
			end

			if not Toggled then
				settings["Button-Functions"]["Button-Pressed"]()
			end

			if settings.ToggleButton then
				if not Toggled then
					Toggled = true
				elseif Toggled then
					settings["Button-Functions"]["Button-Return"]()
					Toggled = false
				end
			end

			Button.ChangeLED(settings['Button-Colors']["Pressed-Color"])
			InUse = true
			task.wait(settings.PressTime)
			InUse = false
			Button.ChangeLED()
			if not settings.ToggleButton then
				settings["Button-Functions"]["Button-Return"]()
			end
		end

		Button.ChangeLED()

		if (settings.ButtonType == 'ProximityPrompt') then
			local ProxAttachment = Instance.new('Attachment', script.Parent.Parent.Parts.ButtonSensor)
			ButtonInteraction = Instance.new('ProximityPrompt', ProxAttachment)
			ButtonInteraction.MaxActivationDistance = 10
			ButtonInteraction.HoldDuration = 0.5
			if (settings.ToggleButton) then ButtonInteraction.ActionText = 'Toggle Button' else ButtonInteraction.ActionText = 'Press Button' end
			ButtonInteraction.ObjectText = string.format('[%s]', string.upper(script.Parent.Parent.Name))

			ButtonInteraction.Triggered:Connect(function(plr)
				Button.ButtonPressed(plr)
			end)
		elseif (settings.ButtonType == 'ClickDetector') then
			ButtonInteraction = Instance.new('ClickDetector', script.Parent.Parent.Parts.ButtonSensor)
			ButtonInteraction.MaxActivationDistance = 10

			ButtonInteraction.MouseClick:Connect(function(plr)
				Button.ButtonPressed(plr)
			end)
		end

	end,
}
