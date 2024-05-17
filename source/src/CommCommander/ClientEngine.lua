return {
  	run = function(script, ...)
    	local function print(...) warn(':: CommCommander [CLIENT] ::', ...) end
    	local LocalPlayer = game:GetService('Players').LocalPlayer
		
		print('Loading CommCommander Client...')
		
		repeat task.wait() until game:IsLoaded()
		
		local UI = LocalPlayer.PlayerGui:WaitForChild('CommCommanderRadioUserInterface')
		local CommCommanderService = game:GetService('ReplicatedStorage'):WaitForChild('##CommCommanderRadioSystem##')
		local CommCommander = CommCommanderService:WaitForChild('_CommCommanderConnector').Value
		local settings = require(CommCommander.CommCommanderConfig)
		local uiConfig = require(CommCommander.CommCommanderConfig.CommCommanderUIStyles) 
		local InputService = game:GetService("UserInputService")
		local Tick = tick()
		
		local channel = settings.config.default_channel
		local radio_name = LocalPlayer.DisplayName
		local Keybind = settings.config.default_keybind
		local RadioEnabled = false
		local UplinkActive = true
		local RadioCanBeUsed = true
		
		local IsChatting = false
		
		local MessageUI = {}
		local theme;
		
		uiConfig.defaults.color_schemes.custom = settings.ui_config.custom_color_scheme
		if (uiConfig.defaults.color_schemes[string.lower(settings.ui_config.color_scheme)]) then
			theme = uiConfig.defaults.color_schemes[string.lower(settings.ui_config.color_scheme)]
		else
			theme = uiConfig.defaults.color_schemes.default
		end
	
		function isUserWhitelisted(player)
			if (settings.config.system_unlocked) then
				return true
			end
		
			for GroupID, GroupRanks in pairs(settings.config.whitelist.groups_whitelisted) do
				local gr = player:GetRankInGroup(GroupID)
			
				for _, RankID in pairs(GroupRanks) do
					if (gr == RankID) then
						return true
					end
				end
			end
		
			for _, UserId in pairs(settings.config.whitelist.users_whitelisted) do
				if (player.UserId == UserId) then
					return true
				end
			end
		
			return false
		end
	
		function detectBackpackRadioTool()
			for _, Tool in pairs(LocalPlayer:WaitForChild('Backpack'):GetChildren()) do
				if Tool:IsA('Tool') then
					if Tool:FindFirstChild('CommCommanderRadioTool') then
						return true
					end
				end
			end
			return false
		end
	
		function detectPlayerRadioTool()
			for _, Tool in pairs(LocalPlayer.Character:GetChildren()) do
				if Tool:IsA('Tool') then
					if Tool:FindFirstChild('CommCommanderRadioTool') then
						return true
					end
				end
			end
			return false
		end
	
		function play(sound)
    		return
		end
	
		if not (isUserWhitelisted(LocalPlayer)) then
			UI:Destroy()
			print('CommCommander Radio Client has finished loading! Took '..string.sub(tick()-Tick, 1, 5)..' seconds to load. CommCommander has loaded on user: '..LocalPlayer.Name)
			error(':: CommCommander [CLIENT] :: User is not whitelisted!')
		end
	
		function MessageUI.isPingMessage(MsgContent)
			if (string.find(MsgContent, '@')) then
				local StringSplit = string.split(MsgContent, ' ')
			
				for _, str in pairs(StringSplit) do
					if (string.find(str, '@') and (string.find(str, LocalPlayer.Name) or string.find(str, LocalPlayer.DisplayName))) then
						return true
					end
				end
			end
			return false
		end
	
		function MessageUI.formatPingMessage(MsgContent)
			local StringSplit = string.split(MsgContent, ' ')
				
			if (string.find(MsgContent, '@')) then
				for strIndex, str in pairs(StringSplit) do
					if (string.find(str, '@') and (string.find(str, LocalPlayer.Name) or string.find(str, LocalPlayer.DisplayName))) then
						StringSplit[strIndex] = '<u><b>'..str..'</b></u>'
					end
				end
			end
			return table.concat(StringSplit, ' ')
		end
	
		function MessageUI.sysMsg(Content)
			if not (settings.config.system_messages) then return end
		
			if #UI.RadioInterface['RowB-RadioChat']:GetChildren() >  7 then
				local objCount = 0
				for _, Object in pairs(UI.RadioInterface['RowB-RadioChat']:GetChildren()) do
				
					if Object.Name == 'RadioMessage' then
						objCount = objCount + 1
						if objCount == 1 then
							Object:Destroy()
						elseif objCount > 4 then
							Object:Destroy()
						end
					end
				end
			end
		
			uiConfig.ui.system_message(Color3.fromRGB(0, 0, 0), Color3.fromRGB(132, 132, 132), Content).Parent = UI.RadioInterface['RowB-RadioChat']
			play('message')
		end
	
		function MessageUI.new(MessageTypeInstance, Content, Sender)
			MessageTypeInstance = string.lower(MessageTypeInstance)
			if (MessageUI.isPingMessage(Content)) then MessageTypeInstance = 'ping' Content = MessageUI.formatPingMessage(Content) end
			if not (UplinkActive) then MessageTypeInstance = 'offline_msg' Content = Content..' - [ MESSAGE NOT DELIVERED ]' end
		
			local MessageTypes = {
				'message',
				'ping',
				'priority_msg',
				'offline_msg'
			}
		
			if not table.find(MessageTypes, MessageTypeInstance) then return end
		
			if #UI.RadioInterface['RowB-RadioChat']:GetChildren() > 7 then
				local objCount = 0
				for _, Object in pairs(UI.RadioInterface['RowB-RadioChat']:GetChildren()) do
					if Object.Name == 'RadioMessage' then
						objCount = objCount + 1
						if objCount == 1 then
							Object:Destroy()
						elseif objCount > 4 then
							Object:Destroy()
						end
					end
				end
			end
		
			local BackgroundColor = Color3.fromRGB(0, 0, 0)
			local FlagColor = theme.border_color
		
			if (MessageTypeInstance == MessageTypes[2]) then
				BackgroundColor =  Color3.fromRGB(115, 85, 24)
				FlagColor = Color3.fromRGB(240, 177, 50)
			elseif (MessageTypeInstance == MessageTypes[3]) then
				BackgroundColor =  Color3.fromRGB(88, 101, 242)
				FlagColor = Color3.fromRGB(88, 101, 242)
			elseif (MessageTypeInstance == MessageTypes[4]) then
				BackgroundColor =  Color3.fromRGB(242, 63, 66)
				FlagColor = Color3.fromRGB(242, 63, 66)
			end
		
			uiConfig.ui.message(BackgroundColor, FlagColor, Content, Sender).Parent = UI.RadioInterface['RowB-RadioChat']
			if Sender.userId == LocalPlayer.UserId then play('send') else play(MessageTypeInstance) end
		end
	
		if (settings.config.require_tool) then
			UI.Enabled = false
			RadioCanBeUsed = false
		
			if detectBackpackRadioTool() then
				if not (settings.config.require_manual_activation) then
					UI.Enabled = true
					RadioCanBeUsed = true
				end
			end
		end
	
		UI.RadioInterface['RowA-RadioInfo'].RadioInfoState.RadioStatus.TextColor3 = Color3.fromRGB(255, 69, 69)
		CommCommanderService:WaitForChild('_CommCommanderServer'):FireServer('SetRadioDetails', {["radioName"] = radio_name, ['radioChannel'] = channel})
		UI.RadioInterface['RowA-RadioInfo'].RadioInfoState.RadioTitle.Text = string.format('Radio - @%s | Name: %s', LocalPlayer.Name, radio_name)
	
		LocalPlayer.Backpack.ChildAdded:Connect(function(Tool)
			repeat task.wait() until #Tool:GetChildren() ~= 0
		
			if (settings.config.require_tool) then
				if detectBackpackRadioTool() then
					if not (settings.config.require_manual_activation) then
						RadioCanBeUsed = true
						UI.Enabled = true
					else
						RadioCanBeUsed = false
						UI.Enabled = false
					end
				end
			end
		end)
	
		LocalPlayer.Backpack.ChildRemoved:Connect(function(Tool)
			repeat task.wait() until #Tool:GetChildren() ~= 0
		
			if (settings.config.require_tool) then
				if not Tool:FindFirstChild('CommCommanderRadioTool') then return end
				if not LocalPlayer.Character:FindFirstChild(Tool.Name) then
					RadioCanBeUsed = false
					UI.Enabled = false
				end
			end
		end)
	
		LocalPlayer.Character.ChildAdded:Connect(function(Tool)
			repeat task.wait() until #Tool:GetChildren() ~= 0
		
			if LocalPlayer.Character:FindFirstChildOfClass("Tool") then
				if not detectPlayerRadioTool() then return end
				if not (settings.config.require_tool) then return end
				if not (settings.config.require_manual_activation) then return end
			
				RadioCanBeUsed = true
				UI.Enabled = true
			end
		end)
	
		LocalPlayer.Character.ChildRemoved:Connect(function(Tool)
			repeat task.wait() until #Tool:GetChildren() ~= 0
		
			if LocalPlayer.Character:FindFirstChildOfClass("Tool") then
				if not (settings.config.require_tool) then return end
				if not (settings.config.require_manual_activation) then return end
				print(Tool)
				if not Tool:FindFirstChild('CommCommanderRadioTool') then return end
			
				RadioCanBeUsed = false
				UI.Enabled = false
			end
		end)
	
		CommCommanderService:WaitForChild('_CommCommanderClient').OnClientEvent:Connect(function(RadioEvent, EventDetails)
			if not RadioCanBeUsed then return end
		
			if (RadioEvent == 'NewRadioMessage') then
				if EventDetails['RadioChannel'] == channel then
					if UplinkActive then
						if not (EventDetails['RadioMessageType']) then
							MessageUI.new('message', EventDetails['RadioMessage'], EventDetails['RadioUser'])
						else
							MessageUI.new(EventDetails['RadioMessageType'], EventDetails['RadioMessage'], EventDetails['RadioUser'])
						end
					else
						if EventDetails['RadioUser'].userId == LocalPlayer.UserId then
							if not (EventDetails['RadioMessageType']) then
								MessageUI.new('message', EventDetails['RadioMessage'], EventDetails['RadioUser'])
							else
								MessageUI.new(EventDetails['RadioMessageType'], EventDetails['RadioMessage'], EventDetails['RadioUser'])
							end
						end
					end
				end
			elseif (RadioEvent == 'SetRadioControllerState') then
				UplinkActive = EventDetails['State']
			elseif (RadioEvent == 'NewSystemRadioMessage') then
				MessageUI.sysMsg(EventDetails['RadioMessage'])
			end
		end)
	
		InputService.InputEnded:Connect(function(touch, gameProcessedEvent)
			if not RadioCanBeUsed then return end
			if gameProcessedEvent then return end
		
			if touch.UserInputType == Enum.UserInputType.Keyboard then
				if touch.KeyCode.Name == Keybind then
					if RadioEnabled then
						RadioEnabled = false
						UI.RadioInterface['RowA-RadioInfo'].RadioInfoState.RadioStatus.TextColor3 = Color3.fromRGB(255, 69, 69)
						UI.RadioInterface['RowA-RadioInfo'].SetRadioListenStateButton.Text = 'Enable Radio'
					else
						RadioEnabled = true
						UI.RadioInterface['RowA-RadioInfo'].RadioInfoState.RadioStatus.TextColor3 = Color3.fromRGB(85, 255, 127)
						UI.RadioInterface['RowA-RadioInfo'].SetRadioListenStateButton.Text = 'Disable Radio'
					end
				
					CommCommanderService:WaitForChild('_CommCommanderServer'):FireServer('SetRadioEnabledState', {["radioUser"] = LocalPlayer.UserId, ['radioEnabled'] = RadioEnabled})
				end
			end
		end)
	
		UI.RadioInterface['RowA-RadioInfo'].SetRadioListenStateButton.MouseButton1Down:Connect(function()
			if RadioEnabled then
				RadioEnabled = false
				UI.RadioInterface['RowA-RadioInfo'].RadioInfoState.RadioStatus.TextColor3 = Color3.fromRGB(255, 69, 69)
				UI.RadioInterface['RowA-RadioInfo'].SetRadioListenStateButton.Text = 'Enable Radio'
			else
				RadioEnabled = true
				UI.RadioInterface['RowA-RadioInfo'].RadioInfoState.RadioStatus.TextColor3 = Color3.fromRGB(85, 255, 127)
				UI.RadioInterface['RowA-RadioInfo'].SetRadioListenStateButton.Text = 'Disable Radio'
			end
		
			CommCommanderService:WaitForChild('_CommCommanderServer'):FireServer('SetRadioEnabledState', {["radioUser"] = LocalPlayer.UserId, ['radioEnabled'] = RadioEnabled})
		end)
	
		UI.RadioInterface['RowC-RadioConfig'].SetRadioBindStateButton.MouseButton1Down:Connect(function()
			if not (UI.RadioInterface['RowC-RadioConfig'].SetRadioBindTextBox.Text == '') then
				Keybind = UI.RadioInterface['RowC-RadioConfig'].SetRadioBindTextBox.Text
			else
				Keybind = settings.config.default_keybind
			end
		
			UI.RadioInterface['RowC-RadioConfig'].SetRadioBindTextBox.Text = Keybind
			MessageUI.sysMsg(string.format('You have changed your radio keybind to: "%s"', Keybind))
		end)
	
		UI.RadioInterface['RowC-RadioConfig'].SetRadioNameStateButton.MouseButton1Down:Connect(function()
			if not (UI.RadioInterface['RowC-RadioConfig'].SetRadioNameTextBox.Text == '') then
				radio_name = UI.RadioInterface['RowC-RadioConfig'].SetRadioNameTextBox.Text
			else
				radio_name = LocalPlayer.DisplayName
			end
		
			UI.RadioInterface['RowC-RadioConfig'].SetRadioNameTextBox.Text = radio_name
			MessageUI.sysMsg(string.format('You have changed your radio display name to: "%s"', radio_name))
			CommCommanderService:WaitForChild('_CommCommanderServer'):FireServer('SetRadioDisplayName', {['radioName'] = radio_name})
		end)
	
		UI.SetChannelInterface.SetRadioChannelStateButton.MouseButton1Down:Connect(function()
			if not (UI.SetChannelInterface.SetRadioChannelTextBox.Text == '') then
				channel = UI.SetChannelInterface.SetRadioChannelTextBox.Text
			else
				channel = settings.config.default_channel
			end
		
			UI.SetChannelInterface.SetRadioChannelTextBox.Text = channel
			MessageUI.sysMsg(string.format('You have switched your radio channel to: "%s"', channel))
			CommCommanderService:WaitForChild('_CommCommanderServer'):FireServer('SetRadioChannel', {['radioChannel'] = channel})
		end)
	
		-- HOTFIX:
		-- add the respawn check thingr
	
		LocalPlayer.CharacterAdded:Connect(function()
			LocalPlayer.PlayerGui:WaitForChild('CommCommanderRadioUserInterface')
			if not (isUserWhitelisted(LocalPlayer)) then
				UI:Destroy()
				error(':: CommCommander [CLIENT] :: User is not whitelisted!')
			end
		end)
	
		print(string.format('CommCommander Radio Client has finished loading on player: %s (Took %s seconds)', LocalPlayer.Name, string.sub(tick()-Tick, 1, 5)))
  	end
}
