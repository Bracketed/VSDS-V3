return {
	run = function(script, ...)
		local InUse = Instance.new('BoolValue')
		local Reader = {}
		local settings = require(script.Parent)
		local function print(...) warn(':: Virtua Arctix ::', ...) end
		local TS = game:GetService('TweenService')
		local TSInfo = TweenInfo.new(
			2,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.InOut
		)

		function Reader.ChangeLED(Color, Material)
			for i, LED in pairs(script.Parent.Parent.ReaderComponents:GetDescendants()) do
				if LED.Name == 'ReaderLED' then
					LED.Color = Color
					if Material == nil then
						LED.Material = Enum.Material.Neon
					else
						LED.Material = Material
					end
				end
			end
		end

		function Reader.Flash(Color, AmmountOfTimes)
			for i = 1, AmmountOfTimes do
				Reader.ChangeLED(Color3.fromRGB(143, 142, 144), Enum.Material.Glass)
				wait(0.2)
				Reader.ChangeLED(Color)
				wait(0.2)
			end
		end

		function Reader.checkForWhitelist(player)
			if not (settings['Reader-Whitelist'].WhitelistEnabled) then return true end
			for GroupID, GroupRanks in pairs(settings['Reader-Whitelist'].WhitelistTable.WhitelistedGroups) do
				local gr = player:GetRankInGroup(GroupID)
				for _, RankID in pairs(GroupRanks) do if (gr == RankID) then return true end end
			end
			for _, UserId in pairs(settings['Reader-Whitelist'].WhitelistTable.WhitelistedPlayers) do if (player.UserId == UserId) then return true end end
			return false
		end

		function Reader.CardScanned(cardHit)
			if not cardHit.Parent:FindFirstChild("VirtuaCard") then return end
			if not cardHit.Parent:FindFirstChild("CardRank") then return end
			if not table.find(settings.KeyLevel, cardHit.Parent:FindFirstChild("CardRank").Value) then Reader.Flash(settings['Reader-Colors']["Denied-Color"], 7) settings["Reader-Functions"]["Reader-Denied"]() return end
			if not game:GetService('Players'):FindFirstChild(cardHit.Parent.Parent.Name) then return end
			if not Reader.checkForWhitelist(game:GetService('Players')[cardHit.Parent.Parent.Name]) then Reader.Flash(settings['Reader-Colors']["Denied-Color"], 7) settings["Reader-Functions"]["Reader-Denied"]() return end

			if (InUse.Value) then return end
			settings["Reader-Functions"]["Reader-Accepted"]()
			Reader.Flash(settings['Reader-Colors']["Accepted-Color"], 7)
			InUse.Value = true
			task.wait(settings.ReaderTime)
			InUse.Value = false
			settings["Reader-Functions"]["Reader-Return"]()
			for i, LED in pairs(script.Parent.Parent.ReaderComponents:GetDescendants()) do
				if LED.Name == 'ReaderLED' then
					local T = TS:Create(LED, TSInfo, {Color = settings['Reader-Colors']['Idle-Color']})
					T:Play()
					T.Completed:Wait()
				end
			end

		end

		-- Startup Stuff
		for i = 1,5 do
			Reader.ChangeLED(Color3.fromRGB(143, 142, 144), Enum.Material.Glass)
			wait(0.5)
			Reader.ChangeLED(Color3.fromRGB(126, 255, 251))
			wait(0.5)
		end
		wait(2)
		for i, LED in pairs(script.Parent.Parent.ReaderComponents:GetDescendants()) do
			if LED.Name == 'ReaderLED' then
				local T = TS:Create(LED, TSInfo, {Color = settings['Reader-Colors']['Idle-Color']})
				T:Play()
				T.Completed:Wait()
			end
		end

		Reader.ChangeLED(settings['Reader-Colors']['Idle-Color'])

		for i, Sensor in pairs(script.Parent.Parent.ReaderComponents.ReaderParts:GetDescendants()) do
			if Sensor.Name == 'ReaderSensor' then
				Sensor.Touched:Connect(function(Tool)
					Reader.CardScanned(Tool)
				end)
			end
		end
	end,
}
