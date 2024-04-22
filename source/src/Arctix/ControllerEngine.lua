return {
	run = function(script, ...)
		local Parts = script.Parent.Parent.Parts
		local SurfaceGUI = Parts.Display.SurfaceGui
		local LED = Parts.LED
		local ScanPart = Parts.Recess
		local SettingsModule = require(script.Parent)
		local Debounce = Instance.new('BoolValue')

		local function print(...) warn(':: Virtua Artix ::', ...) end
		local ControllerUnlocked = Instance.new('BoolValue')

		SurfaceGUI.Unlocked.Visible = false
		SurfaceGUI.Locked.Visible = true
		LED.Color = SettingsModule.ControllerLockedLEDColor

		local System = pcall(function() if script.Parent.Parent:FindFirstChild('VirtuaAPI') then return script.Parent.Parent:WaitForChild('VirtuaAPI') else return nil end end)
		
		if not System then
			script.Parent.Parent:Destroy()
			script:Destroy()
			print('Unable to start Controller, no Global API detected.')
			return
		end
		
		for ButtonName, ButtonFunction in pairs(SettingsModule.ControllerButtons) do
			if (typeof(ButtonFunction) == 'function') then
				local Button = Instance.new('TextButton', SurfaceGUI.Unlocked.Frame)
				Button.Name = ButtonName
				Button.BackgroundTransparency = 0.4
				Button.BackgroundColor3 = Color3.fromRGB(39,39,39)
				Button.Font = Enum.Font.Ubuntu
				Button.RichText = true
				Button.Text = ButtonName
				Button.TextColor3 = Color3.fromRGB(255,255,255)
				Button.TextScaled = true

				local UiCorner = Instance.new('UICorner', Button)
				UiCorner.CornerRadius = UDim.new(0.06, 0)

				local UiPadding = Instance.new('UIPadding', Button)
				UiPadding.PaddingBottom = UDim.new(0.2, 0)
				UiPadding.PaddingTop = UDim.new(0.2, 0)
			end
		end

		local FunctionTable = {}

		function FunctionTable.UnlockController()
			ControllerUnlocked.Value = true
			SurfaceGUI.Unlocked.Visible = true
			SurfaceGUI.Locked.Visible = false

			if SettingsModule.ControllerTweens then
				game:GetService('TweenService'):Create(LED, TweenInfo.new(5), {Color = SettingsModule.ControllerUnlockedLEDColor}):Play()
			else
				LED.Color = SettingsModule.ControllerUnlockedLEDColor
			end
		end

		function FunctionTable.LockController()
			ControllerUnlocked.Value = false
			SurfaceGUI.Unlocked.Visible = false
			SurfaceGUI.Locked.Visible = true

			if SettingsModule.ControllerTweens then
				game:GetService('TweenService'):Create(LED, TweenInfo.new(5), {Color = SettingsModule.ControllerLockedLEDColor}):Play()
			else
				LED.Color = SettingsModule.ControllerLockedLEDColor
			end
		end

		function FunctionTable.checkForWhitelist(player)
			if not (SettingsModule.Whitelist.WhitelistEnabled) then return true end
			for GroupID, GroupRanks in pairs(SettingsModule.Whitelist.WhitelistTable.WhitelistedGroups) do
				local gr = player:GetRankInGroup(GroupID)
				for _, RankID in pairs(GroupRanks) do if (gr == RankID) then return true end end
			end
			for _, UserId in pairs(SettingsModule.Whitelist.WhitelistTable.WhitelistedPlayers) do if (player.UserId == UserId) then return true end end
			return false
		end

		function FunctionTable.CardScanned(cardHit)
			if not cardHit.Parent:FindFirstChild("VirtuaCard") then return end
			if not cardHit.Parent:FindFirstChild("CardRank") then return end
			if not table.find(SettingsModule.KeyLevel, cardHit.Parent:FindFirstChild("CardRank").Value) then return end
			if not game:GetService('Players'):FindFirstChild(cardHit.Parent.Parent.Name) then return end
			if not FunctionTable.checkForWhitelist(game:GetService('Players')[cardHit.Parent.Parent.Name]) then return end

			if (Debounce.Value) then return end
			if ControllerUnlocked.Value then
				FunctionTable.LockController()
			else
				FunctionTable.UnlockController()
			end
			Debounce.Value = true
			task.wait(SettingsModule.ControllerDebounce)
			Debounce.Value = false
		end

		function FunctionTable.isButtonFunction(FunctionName)
			for ButtonName, _ in pairs(SettingsModule.ControllerButtons) do
				if ButtonName == FunctionName then
					return true
				end
			end

			return false
		end

		function FunctionTable.getButtonFunction(FunctionName)
			for ButtonName, ButtonFunction in pairs(SettingsModule.ControllerButtons) do
				if ButtonName == FunctionName then
					return {
						Name = ButtonName,
						Function = ButtonFunction
					}
				end
			end

			return nil
		end

		ScanPart.Touched:Connect(function(cardHit)
			FunctionTable.CardScanned(cardHit)
		end)

		if SettingsModule.ControllerTweens then
			Debounce.Changed:Connect(function()
				local ColourToGoBackTo;

				if ControllerUnlocked.Value then
					ColourToGoBackTo = SettingsModule.ControllerUnlockedLEDColor
				else
					ColourToGoBackTo = SettingsModule.ControllerLockedLEDColor
				end

				task.wait(5)
				game:GetService('TweenService'):Create(LED, TweenInfo.new(2), {Color = SettingsModule.ControllerDisabledLEDColor}):Play()
				task.wait(SettingsModule.ControllerDebounce-7)
				game:GetService('TweenService'):Create(LED, TweenInfo.new(2), {Color = ColourToGoBackTo}):Play()
			end)
		end

		for _, Button in pairs(SurfaceGUI.Unlocked.Frame:GetChildren()) do
			if Button:IsA('TextButton') then
				Button.MouseButton1Down:Connect(function()
					local IsButtonFunction = FunctionTable.isButtonFunction(Button.Name)
					local Function = FunctionTable.getButtonFunction(Button.Name)
					if (typeof(Function.Function) == 'nil') then return end

					Function.Function()
				end)
			end
		end
	end,
}
