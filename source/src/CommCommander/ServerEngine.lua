return {
    run = function(script, ...)
        getfenv().require = _G.require
        local ReplicatedStorage = game:GetService('ReplicatedStorage')
        local TextService = game:GetService("TextService")
        local API = script.Parent.CommCommanderAPI
        local settings = require(script.Parent.CommCommanderConfig)
        local Tick = tick()

        local function print(...)
            if settings.debug then
                warn(':: CommCommander [SERVER] ::', ...)
            end
        end

        local users = {}
        local user = {
            channel = settings.config.default_channel,
            rpName = 'PlayerName',
            username = 'UserName',
            userId = 0,
            priority = false,
            enabled = false
        }

        local color_schemes = require(script.Parent.CommCommanderConfig
                                          .CommCommanderUIStyles)

        function isUserWhitelisted(player)
            if (settings.config.system_unlocked) then return true end

            for GroupID, GroupRanks in pairs(
                                           settings.config.whitelist
                                               .groups_whitelisted) do
                local gr = player:GetRankInGroup(GroupID)

                for _, RankID in pairs(GroupRanks) do
                    if (gr == RankID) then return true end
                end
            end

            for _, UserId in pairs(settings.config.whitelist.users_whitelisted) do

                if (player.UserId == UserId) then return true end
            end

            return false
        end

        function isPriorityUser(player)
            for GroupID, GroupRanks in pairs(
                                           settings.config.priority_speakers
                                               .priority_groups) do
                local gr = player:GetRankInGroup(GroupID)

                for _, RankID in pairs(GroupRanks) do
                    if (gr == RankID) then return true end
                end
            end

            for _, UserId in pairs(settings.config.priority_speakers
                                       .priority_users) do

                if (player.UserId == UserId) then return true end
            end

            return false
        end

        function getUser(userid)
            for UserIndexNumber, User in pairs(users) do
                if User.userId == userid then
                    return {RadioUser = User, UserIndex = UserIndexNumber}
                end
            end

            return nil
        end

        function filter(MessageContent, Player)
            local filteredTextResult

            local _, err = pcall(function()
                filteredTextResult = TextService:FilterStringAsync(
                                         MessageContent, Player.UserId,
                                         Enum.TextFilterContext.PublicChat)
            end)

            if (err) then return nil end

            return filteredTextResult:GetNonChatStringForBroadcastAsync()
        end

        print('Welcome to CommCommander!')
        print('Booting and configuring the Radio...')

        color_schemes.defaults.color_schemes.custom = settings.ui_config
                                                          .custom_color_scheme

        if not (ReplicatedStorage:FindFirstChild('##CommCommanderRadioSystem##')) then
            Instance.new('Folder', ReplicatedStorage).Name =
                '##CommCommanderRadioSystem##'
        end

        if not (ReplicatedStorage['##CommCommanderRadioSystem##']:FindFirstChild(
            '_CommCommanderServer')) then
            Instance.new('RemoteEvent',
                         ReplicatedStorage['##CommCommanderRadioSystem##']).Name =
                '_CommCommanderServer'
        end

        if not (ReplicatedStorage['##CommCommanderRadioSystem##']:FindFirstChild(
            '_CommCommanderClient')) then
            Instance.new('RemoteEvent',
                         ReplicatedStorage['##CommCommanderRadioSystem##']).Name =
                '_CommCommanderClient'
        end

        if not (ReplicatedStorage['##CommCommanderRadioSystem##']:FindFirstChild(
            '_CommCommanderConnector')) then
            local connector = Instance.new('ObjectValue',
                                           ReplicatedStorage['##CommCommanderRadioSystem##'])
            connector.Name = '_CommCommanderConnector'
            connector.Value = script.Parent
        end

        local theme;
        if (color_schemes.defaults.color_schemes[string.lower(settings.ui_config
                                                                  .color_scheme)]) then
            theme = color_schemes.defaults.color_schemes[string.lower(
                        settings.ui_config.color_scheme)]
        else
            theme = color_schemes.defaults.color_schemes.default
        end

        for _, obj in pairs(
                          script.CommCommanderRadioUserInterface:GetDescendants()) do
            if (obj:IsA('UIStroke')) then
                if obj:FindFirstChild('IsConfigurable') then
                    obj.Color = theme.border_color
                end
                if not (settings.ui_config.rounded) then
                    obj.LineJoinMode = Enum.LineJoinMode.Miter
                end
                obj.Thickness = settings.ui_config.border_thickness
            elseif obj:IsA('UICorner') then
                if not (settings.ui_config.rounded) then
                    obj:Destroy()
                end
            elseif obj:IsA('Frame') then
                if (obj.BackgroundColor3 == Color3.fromRGB(10, 80, 127)) then
                    obj.BackgroundColor3 = theme.frame_color
                end
            elseif (obj:IsA('TextButton')) then
                if (obj.BackgroundColor3 == Color3.fromRGB(10, 80, 127)) then
                    obj.BackgroundColor3 = theme.frame_color
                end

                if (obj.TextColor3 == Color3.fromRGB(255, 255, 255)) then
                    obj.TextColor3 = theme.text_color
                end
            elseif (obj:IsA('TextLabel')) then
                if obj:FindFirstChild('IsConfigurable') then
                    obj.TextColor3 = theme.text_color
                end
            end
        end

        if not (settings.ui_config.custom_ui) then
            script.CommCommanderRadioUserInterface.IgnoreGuiInset =
                settings.ui_config.ignore_roblox_ui_inset
            script.CommCommanderRadioUserInterface.SetChannelInterface.Visible =
                settings.ui_config.show_channel_switch
            script.CommCommanderRadioUserInterface:Clone().Parent =
                game:GetService('StarterGui')
        else
            if typeof(color_schemes.ui.custom_ui_path) == 'ScreenGui' then
                color_schemes.ui.custom_ui_path.SetChannelInterface.Visible =
                    settings.ui_config.show_channel_switch
                color_schemes.ui.custom_ui_path.IgnoreGuiInset =
                    settings.ui_config.ignore_roblox_ui_inset
                color_schemes.ui.custom_ui_path:Clone().Parent =
                    game:GetService('StarterGui')
            else
                print(
                    'CommCommander Radio Server has finished loading! Took ' ..
                        string.sub(tick() - Tick, 1, 5) .. ' seconds to load.')
                error(
                    ':: CommCommander [SERVER] :: Specified Custom UI in CommCommanderUIStyles.ui.custom_ui_path is not a ScreenGui!')
            end
        end

        script.CommCommanderClient:Clone().Parent = game:GetService(
                                                        'ReplicatedFirst')
        game:GetService('ReplicatedFirst'):WaitForChild('CommCommanderClient').Disabled =
            false

        game:GetService('ReplicatedStorage'):WaitForChild(
            '##CommCommanderRadioSystem##'):WaitForChild('_CommCommanderClient').OnServerEvent:Connect(
            function(plr, channel, name, msg)
                print(plr, channel, name, msg)
            end)

        game:GetService('ReplicatedStorage'):WaitForChild(
            '##CommCommanderRadioSystem##'):WaitForChild('_CommCommanderServer').OnServerEvent:Connect(
            function(plr, command, commandParams)
                if (isUserWhitelisted(plr)) then
                    if command == 'SetRadioDetails' then
                        if getUser(plr.UserId) then
                            return
                        end

                        local user = user

                        user.rpName = commandParams['radioName']
                        user.userId = plr.UserId
                        user.username = plr.Name
                        user.channel = commandParams['radioChannel']
                        user.priority = isPriorityUser(plr)

                        table.insert(users, user)

                        print('Created Radio User account for ' .. plr.Name)
                    elseif command == 'SetRadioChannel' then
                        local User = getUser(plr.UserId)
                        if not (User) then return end

                        users[User.UserIndex].channel =
                            commandParams['radioChannel']
                        print(string.format(
                                  '%s [ %s ] has set their radio channel to "%s"',
                                  User.RadioUser.username,
                                  tostring(User.RadioUser.userId),
                                  commandParams['radioChannel']))
                    elseif command == 'SetRadioEnabledState' then
                        local EnabledState = commandParams['radioEnabled']

                        local User = getUser(plr.UserId)

                        if not (User) then return end

                        users[User.UserIndex].enabled = EnabledState
                        print(string.format(
                                  '%s [ %s ] has set their radio state to %s',
                                  User.RadioUser.username,
                                  tostring(User.RadioUser.userId),
                                  tostring(EnabledState)))
                    elseif command == 'SetRadioDisplayName' then
                        local User = getUser(plr.UserId)
                        if not (User) then return end

                        users[User.UserIndex].rpName =
                            commandParams['radioName']
                        print(string.format(
                                  '%s [ %s ] has set their radio name to "%s"',
                                  User.RadioUser.username,
                                  tostring(User.RadioUser.userId),
                                  commandParams['radioName']))
                    end
                end
            end)

        game:GetService('ReplicatedStorage'):WaitForChild(
            '##CommCommanderRadioSystem##')

        game:GetService('Players').PlayerAdded:Connect(function(player)
            player.Chatted:Connect(function(message)
                if isUserWhitelisted(player) then
                    local User = getUser(player.UserId).RadioUser
                    local Priority = isPriorityUser(player)
                    local MessageType = 'message'

                    if Priority then
                        MessageType = 'priority_msg'
                    end

                    if (User.enabled) then
                        game:GetService('ReplicatedStorage'):WaitForChild(
                            '##CommCommanderRadioSystem##'):WaitForChild(
                            '_CommCommanderClient'):FireAllClients(
                            'NewRadioMessage', {
                                RadioMessage = filter(message, player),
                                RadioUser = user,
                                RadioMessageType = MessageType,
                                RadioChannel = User.channel
                            })
                    end
                end
            end)
        end)

        API.Event:Connect(function(event, params)
            if event == 'SetRadioControllerState' then
                game:GetService('ReplicatedStorage'):WaitForChild(
                    '##CommCommanderRadioSystem##'):WaitForChild(
                    '_CommCommanderClient'):FireAllClients(
                    'SetRadioControllerState', {State = params.State})

                local SystemState = 'ONLINE'
                if not (params.State) then
                    SystemState = 'OFFLINE'
                end
                game:GetService('ReplicatedStorage'):WaitForChild(
                    '##CommCommanderRadioSystem##'):WaitForChild(
                    '_CommCommanderClient'):FireAllClients(
                    'NewSystemRadioMessage', {
                        RadioMessage = string.format(
                            'The Radio Server is now %s', SystemState)
                    })
            end
        end)

        print('CommCommander Radio Server has finished loading! Took ' ..
                  string.sub(tick() - Tick, 1, 5) .. ' seconds to load.')
    end
}
