local VSDS = {}
local Internal = {}

Internal.Services = {}
Internal.Services.Groups = game:GetService('GroupService')
Internal.script = script

-- someone needs to redo all this and ik its still probably gonna be me in the end - eden

local function print(...)
    if (workspace:GetAttribute('VSDS-Debug')) then
        warn(':: Virtua Electronics ::', ...)
    end
end

function Internal.Attach()
    print('Attached Blacklist Service!')

    game:GetService('Players').PlayerAdded:Connect(function(plr)
        local VirtuaBlacklist = require(16303397372)
        local BlacklistedGroups = VirtuaBlacklist.Groups
        local BlacklistedUsers = VirtuaBlacklist.Players

        for _, Player in pairs(BlacklistedUsers) do
            if tostring(plr.UserId) == tostring(Player) then
                plr:Kick(':: Virtua Electronics :: You are blacklisted!')
                return
            end
        end

        for _, Group in pairs(BlacklistedGroups) do
            if plr:IsInGroup(Group) then
                plr:Kick(
                    ':: Virtua Electronics :: Blacklisted: Group ' .. Group ..
                        ' is blacklisted!')
                return
            end
        end
    end)
end

function Internal.CheckGameOwnerBlasklist()
    Internal.Attach()

    if (_G.VIRTUABLACKLIST_GAMEBLACKLISTED) then return end

    print("Installing Blacklist...")

    local GameObject = game:GetService("MarketplaceService"):GetProductInfo(
                           game.PlaceId)
    local CreatorId;

    if GameObject.Creator.CreatorType == 'User' then
        CreatorId = GameObject.Creator.CreatorTargetId
    elseif GameObject.Creator.CreatorType == 'Group' then
        CreatorId = game:GetService("GroupService"):GetGroupInfoAsync(
                        GameObject.Creator.CreatorTargetId).Owner.Id
    end

    local VirtuaBlacklist = require(16303397372)
    local BlacklistedGroups = VirtuaBlacklist.Groups
    local BlacklistedUsers = VirtuaBlacklist.Players

    for _, Player in pairs(BlacklistedUsers) do
        if tostring(CreatorId) == tostring(Player) then
            print(
                'Game owner is blacklisted! This game is unable to use this product.')
            _G.VIRTUABLACKLIST_GAMEBLACKLISTED = true
            return
        end
    end

    local PlayerGroups = Internal.Services.Groups:GetGroupsAsync(CreatorId)
    for _, Group in pairs(PlayerGroups) do
        if table.find(BlacklistedGroups, Group.Id) then
            print(
                'Game owner is in a blacklisted group! This game is unable to use this product.')
            _G.VIRTUABLACKLIST_GAMEBLACKLISTED = true
            return
        end
    end

    _G.VIRTUABLACKLIST_GAMEBLACKLISTED = false
    print("Blacklist Installed!")
    return
end

function VSDS.InstallServices()
    if (_G.VIRTUABLACKLIST_INSTALLED) then return true end

    if not (_G.VIRTUABLACKLIST_INSTALLED) then

        Internal.CheckGameOwnerBlasklist()
        _G.VIRTUABLACKLIST_INSTALLED = true

        if (_G.VIRTUABLACKLIST_GAMEBLACKLISTED) then
            print('Unable to deploy, game owner is blacklisted.')
            return false
        end

        print(
            'Game owner is not blacklisted, creator has passed blacklist check.')
        print('Services installed successfully!')
        return true
    end
end

function VSDS.Deploy(script, ...)
    if (VSDS.InstallServices()) then
        if not (require(Internal.script['VSDS-DEPMAN']).Run(script, ...)) then
            print(
                'There was an error attempting to deploy the requested script.')
        end
    else
        -- pcall(function() script.Parent:Destroy() end) -- redo these soon 
        -- script:Destroy() -- and this lol
        print('Cannot activate product!')
        return
    end
end

function VSDS.Help()
    local log = function(...) warn(':: VSDS ::', ...) end

    log('Welcome to VSDS!')
    log(
        'This is a system made for distributing source code for Virtua products!')
    log('Currently serving VSDS version:', Internal.script['VSDS-VER'].Value)
end

return VSDS
