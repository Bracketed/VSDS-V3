return {
	run = function(script, ...)
		local Button = {}
		local settings = require(script.Parent)
		local function print(...) warn(':: Virtua Arctix ::', ...) end
		local Toggled = false

		local ButtonInteraction
		local ResetInteraction

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
			if (Toggled) then return end
			if not Button.checkForWhitelist(plr) then return end

			Toggled = true
			script.Parent.Parent.Parts.Element.click:Play()
			script.Parent.Parent.Parts.Flag.Transparency = 0
			ButtonInteraction.MaxActivationDistance = 0
			if settings.ClickReset then
				ResetInteraction.MaxActivationDistance = 10
			end
			settings["Button-Functions"]["Button-Pressed"]()
		end

		function Button.ToolReset(obj)
			if not (Toggled) then return end
			if not obj.Parent:FindFirstChild("VirtuaCard") then return end
			if not obj.Parent:FindFirstChild("CardRank") then return end
			if not table.find(settings.KeyLevel, obj.Parent:FindFirstChild("CardRank").Value) then return end
			if not game:GetService('Players'):FindFirstChild(obj.Parent.Parent.Name) then return end
			if not Button.checkForWhitelist(game:GetService('Players')[obj.Parent.Parent.Name]) then return end

			Toggled = false
			script.Parent.Parent.Parts.Element.click:Play()
			script.Parent.Parent.Parts.Flag.Transparency = 1
			ButtonInteraction.MaxActivationDistance = 10
			if settings.ClickReset then
				ResetInteraction.MaxActivationDistance = 0
			end
			settings["Button-Functions"]["Button-Reset"]()
		end

		function Button.PlrReset(plr)
			if not (Toggled) then return end
			if not Button.checkForWhitelist(plr) then return end

			Toggled = false
			script.Parent.Parent.Parts.Element.click:Play()
			script.Parent.Parent.Parts.Flag.Transparency = 1
			ButtonInteraction.MaxActivationDistance = 10
			if settings.ClickReset then
				ResetInteraction.MaxActivationDistance = 0
			end
			settings["Button-Functions"]["Button-Reset"]()
		end

		if (settings.ButtonType == 'ProximityPrompt') then
			local ProxAttachment = Instance.new('Attachment', script.Parent.Parent.Parts.Element)
			ButtonInteraction = Instance.new('ProximityPrompt', ProxAttachment)
			ButtonInteraction.MaxActivationDistance = 10
			ButtonInteraction.HoldDuration = 0.5
			ButtonInteraction.ActionText = 'Press MCP'
			ButtonInteraction.ObjectText = string.format('[%s]', string.upper(script.Parent.Parent.Name))

			ButtonInteraction.Triggered:Connect(function(plr)
				Button.ButtonPressed(plr)
			end)
		elseif (settings.ButtonType == 'ClickDetector') then
			ButtonInteraction = Instance.new('ClickDetector', script.Parent.Parent.Parts.Element)
			ButtonInteraction.MaxActivationDistance = 10

			ButtonInteraction.MouseClick:Connect(function(plr)
				Button.ButtonPressed(plr)
			end)
		end

		ResetInteraction = Instance.new('ClickDetector', script.Parent.Parent.Parts.CallpointBody.Body3)
		ResetInteraction.MaxActivationDistance = 0

		ResetInteraction.MouseClick:Connect(function(plr)
			Button.PlrReset(plr)
		end)

		script.Parent.Parent.Parts.CallpointBody.Body3.Touched:Connect(function(obj)
			Button.ToolReset(obj)
		end)
	end,
}
