local QBCore = exports['qb-core']:GetCoreObject()

local sessionXP = {} -- Keep this at the top of your server file

exports('addXP', function(source, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local current = Player.Functions.GetMetaData(Config.XP.metadataKey) or 0
        local new = current + amount
        local oldLevel = math.floor(current / 100)
        local newLevel = math.floor(new / 100)

        -- Save XP permanently
        Player.Functions.SetMetaData(Config.XP.metadataKey, new)
        Player.Functions.Save()

        -- Track session XP
        sessionXP[source] = (sessionXP[source] or 0) + amount

        -- Update client with new total XP
        TriggerClientEvent('xp:client:updateXP', source, new)

        -- Show level text
        if newLevel > oldLevel then
            for level = oldLevel + 1, newLevel do
                if Config.EnableRewards and Config.Levels[level] and Config.Levels[level].reward then
                    local reward = Config.Levels[level]
					
					TriggerClientEvent("xp:showLevelText", source, newLevel, new)

                    -- Give Items
                    if reward.items then
                        for _, item in pairs(reward.items) do
                            Player.Functions.AddItem(item, 1)
                        end
                    end

                    -- Give Money
                    if reward.money then
                        Player.Functions.AddMoney('bank', reward.money)
                    end

                    -- Notify player
                    TriggerClientEvent('xp:notifyReward', source, level, reward)

                    -- Global celebration
                    TriggerClientEvent('xp:celebrate', -1, source)
                end
            end
        end
    end
end)

-- This stays the same
RegisterNetEvent('xp:server:addXP', function(amount)
    local src = source
    if type(amount) == 'number' and amount > 0 then
        exports['mobz-xpprogression']:addXP(src, amount)
    end
end)


QBCore.Functions.CreateCallback("xp:getSessionXP", function(source, cb)
    cb(sessionXP[source] or 0)
end)

AddEventHandler("playerDropped", function()
    sessionXP[source] = nil
end)


exports('removeXP', function(source, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local current = Player.Functions.GetMetaData(Config.XP.metadataKey) or 0
        local new = math.max(current - amount, 0)

        Player.Functions.SetMetaData(Config.XP.metadataKey, new)
        Player.Functions.Save()

        -- Update client with new XP
        TriggerClientEvent('xp:client:updateXP', source, new)
    end
end)


RegisterNetEvent('xp:server:addXP', function(amount)
    local src = source
    if type(amount) == 'number' and amount > 0 then
        exports['mobz-xpprogression']:addXP(src, amount)
    end
end)

RegisterNetEvent('xp:server:removeXP', function(amount)
    local src = source
    if type(amount) == 'number' and amount > 0 then
        exports['mobz-xpprogression']:removeXP(src, amount)
    end
end)
    
exports('getLevel', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local xp = Player.Functions.GetMetaData(Config.XP.metadataKey) or 0
        return math.floor(xp / Config.XP.maxXP)
    end
    return 0
end)

exports('isLevelAtLeast', function(source, required)
    local lvl = exports['mobz-xpprogression']:getLevel(source)
    return lvl >= required
end)


--[[
    
if exports['mobz-xp']:isLevelAtLeast(source, 10) then
    print("Player can access elite area.")
end
   
   
exports['mobz-xpprogression']:addXP(source, 10)
exports['mobz-xp']:removeXP(source, 5)

--]]
    

------------------------------------------------------------------------------
--			DATA
------------------------------------------------------------------------------

QBCore.Functions.CreateCallback("xp:getProgressData", function(src, cb)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local xp = Player.PlayerData.metadata.xp or 0
    local level = math.floor(xp / 100)
    local progress = xp % 100
    cb({level = level, progress = progress, xp = xp})
end)

RegisterServerEvent("xpadmin:getPlayers", function()
    local src = source
    local players = {}

    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(id)
        if Player then
            local name = GetPlayerName(id)
            local xp = Player.Functions.GetMetaData(Config.XP.metadataKey) or 0
            local coords = GetEntityCoords(GetPlayerPed(id))
            table.insert(players, { source = id, name = name, xp = xp, coords = coords })
        end
    end

    TriggerClientEvent("xpadmin:showPanel", src, players)
end)

RegisterServerEvent("xpadmin:getPlayersProgress", function()
    local src = source
    local players = {}

    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(id)
        if Player then
            local name = GetPlayerName(id)
            local xp = Player.Functions.GetMetaData(Config.XP.metadataKey) or 0
            table.insert(players, { source = id, name = name, xp = xp })
        end
    end

    TriggerClientEvent("xpadmin:showProgressOverview", src, players)
end)


------------------------------------------------------------------------------------
-- ADMIN COMMANDS
------------------------------------------------------------------------------------


RegisterServerEvent('xpadmin:addXP', function(target, amount)
	local src = source
	local Player = QBCore.Functions.GetPlayer(target)
    if not Player or Player.PlayerData.job.name ~= Config.XP.adminJob then return end
	if Player then
		exports['mobz-xpprogression']:addXP(target, amount)
	end	
end)

RegisterServerEvent('xpadmin:removeXP', function(target, amount)
	local src = source
	local Player = QBCore.Functions.GetPlayer(target)
    if not Player or Player.PlayerData.job.name ~= Config.XP.adminJob then return end
	
	if Player then
		exports['mobz-xpprogression']:removeXP(target, amount)
	end	
end)

RegisterServerEvent('xpadmin:setXP', function(target, amount)
	local src = source
	local Player = QBCore.Functions.GetPlayer(target)
    if not Player or Player.PlayerData.job.name ~= Config.XP.adminJob then return end
	
    if Player then
        Player.Functions.SetMetaData(Config.XP.metadataKey, amount)
        Player.Functions.Save()
        TriggerClientEvent('xp:client:updateXP', target, amount)
    end
end)

RegisterCommand("xptake", function(src, args)
    if not IsPlayerAdmin(src) then return end
    local id, amount = tonumber(args[1]), tonumber(args[2])
    if id and amount then

		exports['mobz-xpprogression']:removeXP(id, amount)
		TriggerClientEvent("xp:client:updateXP", id, amount)
        TriggerClientEvent("ox_lib:notify", src, {
            type = "inform",
            description = ("Removed %s XP from ID %s"):format(amount, id)
        })
    end
end)

RegisterCommand("xpset", function(src, args)
    if not IsPlayerAdmin(src) then return end
    local id, value = tonumber(args[1]), tonumber(args[2])
    if id and value then
        local Player = QBCore.Functions.GetPlayer(id)
        if Player then
            Player.Functions.SetMetaData(Config.MetadataKey, value)
            TriggerClientEvent("xp:client:updateXP", id, value)
			
            TriggerClientEvent("ox_lib:notify", src, {
                type = "success",
                description = ("Set ID %s XP to %s"):format(id, value)
            })
        end
    end
end)

function IsPlayerAdmin(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player and Player.PlayerData.group == "admin"
end

------------------------------------------------------------------------------------
-- XP PLAY TIME
------------------------------------------------------------------------------------


CreateThread(function()
    while true do
        Wait(Config.XPPlayTime.IntervalMinutes * 60000) -- Line 255

        if Config.XPPlayTime.Enabled then
            local players = QBCore.Functions.GetPlayers()
            for _, src in pairs(players) do
                local Player = QBCore.Functions.GetPlayer(src)
                if Player then
                    exports['mobz-xpprogression']:addXP(src, Config.XPPlayTime.XPPerInterval)

                    if Config.XPPlayTime.Notify then
                        TriggerClientEvent('xp:notify', src, ('You earned %s XP for playing!'):format(Config.XPPlayTime.XPPerInterval), 'playtime')
                    end
                end
            end
        end
    end
end)


------------------------------------------------------------------------------------
-- PLAYER STATS
------------------------------------------------------------------------------------


RegisterServerEvent("xpadmin:showPlayerStats", function(target)
    local src = source

    if target then
        local Player = QBCore.Functions.GetPlayer(target)
        if Player then
            local data = {
                name = GetPlayerName(target),
                xp = Player.Functions.GetMetaData(Config.XP.metadataKey) or 0,
                sessionXP = Player.PlayerData.metadata.session_xp or 0,
                firstname = Player.PlayerData.charinfo.firstname,
                lastname = Player.PlayerData.charinfo.lastname
            }
            TriggerClientEvent("xpadmin:showSinglePlayerStats", src, data)
        end
    else
        local players = {}
        for _, id in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(id)
            if Player then
                table.insert(players, {
                    name = GetPlayerName(id),
                    source = id,
                    xp = Player.Functions.GetMetaData(Config.XP.metadataKey) or 0,
                    sessionXP = Player.PlayerData.metadata.session_xp or 0
                })
            end
        end

        table.sort(players, function(a, b) return a.xp > b.xp end)

        TriggerClientEvent("xpadmin:showLeaderboard", src, players)
		
    end
end)

RegisterServerEvent("xpadmin:getLeaderboard", function()
    local src = source
    local players = {}

    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(id)
        if Player then
            local xp = Player.Functions.GetMetaData(Config.XP.metadataKey) or 0
            local name = GetPlayerName(id)
            table.insert(players, {
                name = name,
                xp = xp
            })
        end
    end

    -- Sort by XP descending
    table.sort(players, function(a, b) return a.xp > b.xp end)

    TriggerClientEvent("xpadmin:showLeaderboard", src, players)
end)



AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    Player.Functions.SetMetaData('session_xp', 0)
end)

RegisterNetEvent('xp:addSessionXP', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local current = Player.PlayerData.metadata.session_xp or 0
        Player.Functions.SetMetaData('session_xp', current + amount)
    end
end)



------------------------------------------------------------------------------------
-- XP DEATHS AND KILLS TRACKING
------------------------------------------------------------------------------------


local XP = Config.XP
local recentKills = {}
local killStreaks = {}

AddEventHandler("playerDropped", function()
    local src = source
    recentKills[src] = nil
    killStreaks[src] = nil
end)

RegisterNetEvent('baseevents:onPlayerDied', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local loss = math.abs(XP.xpOnDeath)
        exports['mobz-xpprogression']:removeXP(src, loss)
        Player.Functions.SetMetaData('session_xp', math.max((Player.PlayerData.metadata.session_xp or 0) - loss, 0))
        killStreaks[src] = 0
        if XP.enableNotifications then
            TriggerClientEvent('xp:client:notifyXP', src, -loss, XP.notify.loss:format(loss))
        end
    end
end)

RegisterNetEvent('baseevents:onPlayerKilled', function(killerId, _, _)
    local victimId = source
    if killerId == victimId then return end

    local Killer = QBCore.Functions.GetPlayer(killerId)
    if not Killer then return end

    recentKills[killerId] = recentKills[killerId] or {}
    local now = os.time()

    if recentKills[killerId][victimId] and now - recentKills[killerId][victimId] < XP.killCooldown then
        if XP.enableNotifications then
            TriggerClientEvent('xp:client:notifyXP', killerId, 0, XP.notify.cooldown)
        end
        return
    end

    recentKills[killerId][victimId] = now
    local sessionXP = Killer.PlayerData.metadata.session_xp or 0

    killStreaks[killerId] = (killStreaks[killerId] or 0) + 1
    local bonus = XP.enableStreaks and (killStreaks[killerId] * XP.bonusPerStreak) or 0
    local totalXP = XP.xpOnKill + bonus

    exports['mobz-xpprogression']:addXP(killerId, totalXP)
    Killer.Functions.SetMetaData('session_xp', sessionXP + totalXP)

    if XP.enableNotifications then
        TriggerClientEvent('xp:client:notifyXP', killerId, totalXP, XP.notify.gain:format(totalXP, killStreaks[killerId]))
    end
end)


------------------------------------------------------------------------------------
-- promotion/demotion
------------------------------------------------------------------------------------
--[[
-- Get level based on XP
local function GetLevelFromXP(xp)
    return math.floor((xp or 0) / Config.XP.maxXP)
end

-- Get grade based on level and grade step
local function GetGradeFromLevel(level)
    return math.floor(level / Config.LevelsPerGrade)
end

-- Main check for promotion/demotion
-- Main check for promotion/demotion
local function CheckPromotion(Player)
    local xp = Player.PlayerData.metadata["xp"] or 0
    local level = GetLevelFromXP(xp)
    local targetGrade = GetGradeFromLevel(level)
    local job = Player.PlayerData.job.name
    local maxGrade = Config.MaxGrades[job]

    if not maxGrade then return end

    local currentGrade = Player.PlayerData.job.grade.level  -- FIX: Extract the grade level properly

    -- Clamp target grade
    targetGrade = math.max(0, math.min(targetGrade, maxGrade))

    -- Only change if grade is different
    if targetGrade ~= currentGrade then
        Player.Functions.SetJob(job, targetGrade)

        local action = targetGrade > currentGrade and "🎉 Promoted" or "⚠️ Demoted"
        local notifyType = targetGrade > currentGrade and "success" or "error"

        Config.Notify(Player.PlayerData.source, ("%s to %s grade %s"):format(action, job, targetGrade), notifyType)

        if Config.Debug then
            print(("[XP] %s -> %s %s to grade %s (XP: %s)")
                :format(Player.PlayerData.name, job, action:upper(), targetGrade, xp))
        end
    end
end


-- Check all players every X seconds
CreateThread(function()
    while true do
        Wait(Config.CheckInterval * 1000)
        for _, src in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(src)
            if Player then
                CheckPromotion(Player)
            end
        end
    end
end)

-- Also check when player joins
RegisterNetEvent("QBCore:Server:PlayerLoaded", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Wait(1000)
        CheckPromotion(Player)
    end
end)

--]]
------------------------------------------------------------------------------
--			
------------------------------------------------------------------------------

------------------------------------------------------------------------------------
-- leaderboardData
------------------------------------------------------------------------------------

local leaderboardData = {}

local function updateLeaderboard()
    leaderboardData = {}

    for _, playerId in ipairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
        if Player then
            local xp = Player.PlayerData.metadata['xp'] or 0
            table.insert(leaderboardData, {
                id = playerId,
                name = GetPlayerName(playerId),
                xp = xp
            })
        end
    end

    -- Sort by XP descending
    table.sort(leaderboardData, function(a, b)
        return a.xp > b.xp
    end)

    -- Limit to Config.MaxLeaderboard
    while #leaderboardData > Config.MaxLeaderboard do
        table.remove(leaderboardData)
    end

    -- Broadcast to all clients
    TriggerClientEvent("xp_leaderboard:update", -1, leaderboardData)
end

-- Run leaderboard update in intervals
CreateThread(function()
    while true do
        Wait(Config.UpdateInterval * 1000)
        updateLeaderboard()
    end
end)

-- Client requests fresh leaderboard
RegisterNetEvent("xp_leaderboard:request", function()
    local data = {}

    for _, playerId in ipairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
        if Player then
            local xp = Player.PlayerData.metadata['xp'] or 0
            table.insert(data, {
                id = playerId,
                name = GetPlayerName(playerId),
                xp = xp
            })
        end
    end

    table.sort(data, function(a, b)
        return a.xp > b.xp
    end)

    -- Respond only to requesting player
    TriggerClientEvent("xp_leaderboard:update", source, data)
end)

-- Handle request to show 3D text for a player's XP
RegisterNetEvent("xp_leaderboard:request3dtext", function(targetId)
    TriggerClientEvent("xp_leaderboard:show3dtext", -1, targetId)
end)