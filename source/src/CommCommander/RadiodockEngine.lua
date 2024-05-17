return {
    run = function(script, ...)
        local settings = require(script.Parent.Parent.CommCommanderConfig)
        local RadioController = script.Parent.Parent:FindFirstChild(
                                    'CommCommanderController') or nil
        local RadioModel = RadioController:FindFirstChild('RadioTool') or nil
        local API = script.Parent.Parent.CommCommanderAPI

        local function print(...)
            if settings.debug then
                warn(':: CommCommander [SERVER] ::', ...)
            end
        end

        local fakeRadioStates = {
            [1] = true,
            [2] = true,
            [3] = true,
            [4] = true,
            [5] = true,
            [6] = true
        }

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

        function detectRadioTool(player)
            for _, Tool in pairs(player:WaitForChild('Backpack'):GetChildren()) do
                if Tool:IsA('Tool') then
                    if Tool:FindFirstChild('CommCommanderRadioTool') then
                        return true
                    end
                end
            end
            return false
        end

        function eventuallyShowAgain(radioIndex)
            local RadioInstance =
                script.Parent.DockParts.FakeRadios:FindFirstChild('FakeRadio' ..
                                                                      radioIndex) or
                    nil
            if not RadioInstance then return end

            if fakeRadioStates[radioIndex] == false then return end

            for _, I in pairs(RadioInstance:GetDescendants()) do
                pcall(function() I.Transparency = 1 end)
            end
            RadioInstance.LogoBack.SurfaceGui.ImageLabel.ImageTransparency = 1
            RadioInstance.LogoFront.SurfaceGui.ImageLabel.ImageTransparency = 1
            fakeRadioStates[radioIndex] = false

            wait(math.random(20, 300))

            for _, I in pairs(RadioInstance:GetDescendants()) do
                pcall(function() I.Transparency = 0 end)
            end
            RadioInstance.LogoBack.SurfaceGui.ImageLabel.ImageTransparency = 0
            RadioInstance.LogoFront.SurfaceGui.ImageLabel.ImageTransparency = 0
            fakeRadioStates[radioIndex] = true
        end

        script.Parent.TouchPart.PromptHolder.ProximityPrompt.Triggered:Connect(
            function(plr)
                if not RadioController then return end
                if not RadioModel then return end
                if not isUserWhitelisted(plr) then return end
                if detectRadioTool(plr) then return end

                local Radio = RadioModel:Clone()
                Radio.Name = 'Radio'
                Radio.FakeHandle.qPerfectionWeld.Disabled = false
                Radio.FakeHandle.Anchored = false
                Radio.FakeHandle.Name = 'Handle'
                Radio.Enabled = true

                Radio.Parent = plr:WaitForChild('Backpack')
                print(string.format('%s has now equipped a Radio!', plr.Name))

                eventuallyShowAgain(math.random(1, #fakeRadioStates))

                return
            end)

        API.Event:Connect(function(event, params)
            if event == 'SetRadioControllerState' then
                if not (params.State) then
                    script.Parent.TouchPart.PromptHolder.ProximityPrompt.Enabled =
                        false
                    return
                end
                script.Parent.TouchPart.PromptHolder.ProximityPrompt.Enabled =
                    true
                return
            end
        end)
    end
}
