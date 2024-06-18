return {
    run = function(script, ...)
        local UI = script.Parent.ControllerParts.LCD.ControllerUI
        local settings = require(script.Parent.Parent.CommCommanderConfig)
        local API = script.Parent.Parent.CommCommanderAPI
        local OnlineState = true

        local db = false

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

        script.Parent.ControllerParts.LCD.Color = Color3.fromRGB(93, 137, 167)
        script.Parent.ControllerParts.LCD.Material = Enum.Material.Neon
        UI.Enabled = true
        UI.SystemTitle.Text = string.format('CommCommander - %s', game.Name)
        if not (settings.config.power_controller) then
            script.Parent.PowerButton.ClickDetector.MaxActivationDistance = 0
        end

        script.Parent.PowerButton.ClickDetector.MouseClick:Connect(function(plr)
            if not (settings.config.power_controller) then return end
            if db then return end
            if not (isUserWhitelisted(plr)) then return end

            db = true
            if (OnlineState) then
                OnlineState = false
                UI.SystemState.Text = 'System State: OFFLINE'
                task.wait(2)
                UI.Enabled = false
                task.wait(1)
                script.Parent.ControllerParts.LCD.Color =
                    Color3.fromRGB(36, 36, 36)
                script.Parent.ControllerParts.LCD.Material = Enum.Material.Glass
            else
                OnlineState = true
                UI.SystemState.Text = 'System State: ONLINE'
                script.Parent.ControllerParts.LCD.Color = Color3.fromRGB(93,
                                                                         137,
                                                                         167)
                script.Parent.ControllerParts.LCD.Material = Enum.Material.Neon
                task.wait(2)
                UI.Enabled = true
            end

            API:Fire('SetRadioControllerState', {State = OnlineState})

            task.wait(5)
            db = false
        end)
    end
}
