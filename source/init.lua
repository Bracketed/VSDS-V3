local __V3 = {}
local __V3_INTERNAL = {}

getfenv().require = _G.require
getfenv().game = _G.game

__V3_INTERNAL.SERVICES = {}
__V3_INTERNAL.SERVICES.HTTPSERVICE = _G.game:GetService('HttpService')
__V3_INTERNAL.SERVICES.GROUPSERVICE = _G.game:GetService('GroupService')
__V3_INTERNAL.script = script
__V3_INTERNAL.DEBUG = false

local function print(...)
    if (__V3_INTERNAL.DEBUG) then warn(':: Virtua Electronics ::', ...) end
end

function __V3_INTERNAL.Attach()
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

function __V3_INTERNAL.CheckGameOwnerBlasklist()
    __V3_INTERNAL.Attach()

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

    local PlayerGroups = __V3_INTERNAL.SERVICES.GROUPSERVICE:GetGroupsAsync(
                             CreatorId)
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

function __V3.InstallServices()
    if (_G.VIRTUABLACKLIST_INSTALLED) then return true end

    if not (_G.VIRTUABLACKLIST_INSTALLED) then

        __V3_INTERNAL.CheckGameOwnerBlasklist()
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

function __V3.Deploy(script, ...)
    local Arguments = {...}
    local debug = Arguments[#Arguments]
    -- if debug == "debug" then __V3_INTERNAL.DEBUG = true end
    __V3_INTERNAL.DEBUG = true
    if (__V3.InstallServices()) then
        if not (require(__V3_INTERNAL.script.DeploymentManagerV1).Run(script,
                                                                      ...)) then
            print(
                'There was an error attempting to deploy the requested script.')
        end
    else
        -- pcall(function() script.Parent:Destroy() end)
        -- script:Destroy()
        print('Cannot activate product!')
        return
    end
end

return __V3
