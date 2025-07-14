local QBCore = exports['qb-core']:GetCoreObject()

local showingXP = Config.UI.enabledByDefault
local xpValue = 0

RegisterNetEvent('xp:client:updateXP', function(val)
    xpValue = val
    if showingXP then
        updateUI()
    end
end)

-- Initial fetch when player loads
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(data)
        xpValue = data.metadata[Config.XP.metadataKey] or 0
        if showingXP then updateUI() end
    end)
end)

function updateUI()
    local level = math.floor(xpValue / Config.XP.maxXP)
    local currentXP = xpValue % Config.XP.maxXP
    local percent = (currentXP / Config.XP.maxXP) * 100

    local color = Config.UI.colors.low
    if percent >= 75 then
        color = Config.UI.colors.high
    elseif percent >= 50 then
        color = Config.UI.colors.medium
    end

    SendNUIMessage({
        action = 'showXP',
        level = level,
        currentXP = currentXP,
        maxXP = Config.XP.maxXP,
        color = color,
        visible = true
    })
end

-- Toggle command + keybind
RegisterCommand("togglexpbar", function()
    showingXP = not showingXP
    SendNUIMessage({ action = "toggleXP", visible = showingXP })
    if showingXP then updateUI() end
end, false)

RegisterKeyMapping("togglexpbar", "Toggle XP Bar Display", "keyboard", "F10")



exports('addClientXP', function(amount)
    if type(amount) == 'number' and amount > 0 then
        TriggerServerEvent('xp:server:addXP', amount)
    end
end)

exports('removeClientXP', function(amount)
    if type(amount) == 'number' and amount > 0 then
        TriggerServerEvent('xp:server:removeXP', amount)
    end
end)


exports('getPlayerLevel', function()
    return math.floor(xpValue / Config.XP.maxXP)
end)

exports('isPlayerLevelAtLeast', function(requiredLevel)
    local level = math.floor(xpValue / Config.XP.maxXP)
    return level >= requiredLevel
end)

exports('isPlayerLevel', function(levelToCheck)
    local level = math.floor(xpValue / Config.XP.maxXP)
    return level == levelToCheck
end)


--[[
    
local lvl = exports['mobz-xpprogression']:getPlayerLevel()
if lvl >= 5 then
    print("Unlocked advanced skill!")
end
    
    
exports['mobz-xpprogression']:addClientXP(10)
exports['mobz-xpprogression']:removeClientXP(5)

local xpAmount = math.random(10, 50)

-- Value 1
exports['mobz-xpprogression']:addClientXP(serverId, xpAmount)
	
--]]


RegisterNetEvent('xp:notifyReward', function(level, reward)
    local msg = string.format("You reached Level %d!", level)
    if reward.money or reward.items then
        msg = msg .. " You've received rewards!"
    end
    QBCore.Functions.Notify(msg, 'success', 7500)
end)

RegisterNetEvent('xp:celebrate', function(src)
    local ped = GetPlayerPed(GetPlayerFromServerId(src))
    if not DoesEntityExist(ped) then return end

    local coords = GetEntityCoords(ped)
    StartParticleFx(coords)
end)

function StartParticleFx(coords)
    RequestNamedPtfxAsset("scr_indep_fireworks")
    while not HasNamedPtfxAssetLoaded("scr_indep_fireworks") do
        Wait(10)
    end
    UseParticleFxAsset("scr_indep_fireworks")
    for i = 1, 5 do
        StartParticleFxNonLoopedAtCoord("scr_indep_firework_starburst", coords.x, coords.y, coords.z + 1.0, 0, 0, 0, 1.0, false, false, false)
        Wait(1000)
    end
end


------------------------------------------------------------------------------
--			CELEBARTIONS
------------------------------------------------------------------------------


local activeLevelText = nil

-- 3D Text Draw
function Draw3DLevelText(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    if onScreen then
        SetTextScale(0.45, 0.45)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 215, 0, 215) -- Gold
        SetTextCentre(true)

        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

-- Event: Show Level Text
RegisterNetEvent("xp:showLevelText", function(level, xp)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local startTime = GetGameTimer()
    activeLevelText = {coords = vector3(coords.x, coords.y, coords.z + 1.0), level = level, xp = xp}

    -- Notification
    lib.notify({
        title = "🆙 Level Up!",
        description = ("You are now level %s with %s XP!"):format(level, xp),
        type = "success"
    })

    -- Remove after 10 seconds
    CreateThread(function()
        Wait(10000)
        activeLevelText = nil
    end)
end)

-- Draw Tick
CreateThread(function()
    while true do
        Wait(0)
        if activeLevelText then
            Draw3DLevelText(activeLevelText.coords, ("🆙 Level %s — %s XP"):format(activeLevelText.level, activeLevelText.xp))
        end
    end
end)


RegisterNetEvent("xp:celebrateLevelUp", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    -- 🎆 Fireworks
    for i = 1, 3 do
        CreateFirework(coords)
        Wait(1000)
    end

    -- 🔊 Sound effect (optional)
    PlaySoundFrontend(-1, "WIN", "HUD_AWARDS", true)

    -- 💨 Particle FX
    RequestNamedPtfxAsset("scr_rcbarry2")
    while not HasNamedPtfxAssetLoaded("scr_rcbarry2") do Wait(10) end

    UseParticleFxAssetNextCall("scr_rcbarry2")
    StartParticleFxNonLoopedAtCoord("scr_clown_appears", coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

    -- 🕺 Emote (optional)
    if lib then
        lib.requestAnimDict("anim@mp_player_intcelebrationmale@wank")
        TaskPlayAnim(ped, "anim@mp_player_intcelebrationmale@wank", "wank", 8.0, -8, 2000, 0, 0, false, false, false)
    end
end)
  
  
  
function CreateFirework(coords)
    local firework = CreateObject(`ind_prop_firework_01`, coords.x, coords.y, coords.z, true, false, false)
    SetEntityRotation(firework, 0.0, 90.0, 0.0, 2, true)
    StartParticleFxNonLoopedOnEntity("scr_indep_firework_starburst", firework, 0.0, 0.0, 0.0, 0, 0, 0, 1.0, false, false, false)
    SetTimeout(2000, function()
        DeleteEntity(firework)
    end)
end
  
  
--[[  
  
 Bonus FX options:

"scr_indep_firework_burst"

"scr_indep_firework_trailburst"

"scr_rcpaparazzo1" for confetti

--]]


RegisterNetEvent("xp:leveledUp")
AddEventHandler("xp:leveledUp", function(level)
    -- ✅ Notif
    lib.notify({
        title = "Level Up!",
        description = ("You've reached Level %s"):format(level),
        type = "success"
    })

    -- 🔊 Sound effect (requires InteractSound)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "levelup", 0.4)
	PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", true)

    -- 💃 Emote (optional)
    if Config.LevelUpAnimation then
        local ped = PlayerPedId()
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CHEERING", 0, true)
        Wait(3000)
        ClearPedTasks(ped)
    end
end)

------------------------------------------------------------------------------
--			 ADMIN MENU
------------------------------------------------------------------------------

RegisterCommand("openxpadmin", function()
    local Player = QBCore.Functions.GetPlayerData()
    if Player.job.name == Config.XP.adminJob then
        lib.registerContext({
            id = 'xp_admin_main',
            title = 'XP Admin Menu',
            options = {
                {
                    title = "📊 Player Progress Overview",
                    description = "View all players' XP and levels",
                    icon = 'fa-solid fa-chart-line',
                    onSelect = function()
                        TriggerServerEvent("xpadmin:getPlayersProgress")
                    end
                },
                {
                    title = "🔧 Manage Players",
                    description = "Add/Remove/Set XP, TP",
                    icon = 'fa-solid fa-tools',
                    onSelect = function()
                        TriggerServerEvent("xpadmin:getPlayers")
                    end
                },
				{
					title = 'View Progress (Read-only)',
					icon = 'fa-solid fa-eye',
					onSelect = function()
						TriggerServerEvent("xpadmin:showPlayerStats")
					end
				}
            }
        })
        lib.showContext('xp_admin_main')
    else
        lib.notify({ title = "Access Denied", description = "You are not authorized.", type = "error" })
    end
end)

RegisterNetEvent("xpadmin:showPanel", function(players)
    local options = {}

    for _, player in pairs(players) do
        table.insert(options, {
            title = player.name .. " | XP: " .. (player.xp or 0),
            description = "ID: " .. player.source,
            icon = 'fa-solid fa-user',
            image = Config.Images.header,
            onSelect = function()
                openPlayerOptions(player)
            end
        })
    end

    lib.registerContext({
        id = 'xp_admin_panel',
        title = '🔧 Manage Players',
        menu = 'xp_admin_main',
        options = options
    })

    lib.showContext('xp_admin_panel')
end)

function openPlayerOptions(player)
    lib.registerContext({
        id = 'xp_player_options',
        title = 'Manage ' .. player.name,
        menu = 'xp_admin_panel',
        options = {
            {
                title = '➕ Add XP',
                icon = Config.Images.iconAdd,
                onSelect = function()
                    local input = lib.inputDialog('Add XP', { {type = 'number', label = 'XP Amount', required = true} })
                    if input then TriggerServerEvent('xpadmin:addXP', player.source, tonumber(input[1])) end
                end
            },
            {
                title = '➖ Remove XP',
                icon = Config.Images.iconRemove,
                onSelect = function()
                    local input = lib.inputDialog('Remove XP', { {type = 'number', label = 'XP Amount', required = true} })
                    if input then TriggerServerEvent('xpadmin:removeXP', player.source, tonumber(input[1])) end
                end
            },
            {
                title = '🎚️ Set XP',
                icon = Config.Images.iconSet,
                onSelect = function()
                    local input = lib.inputDialog('Set XP', { {type = 'number', label = 'XP Amount', required = true} })
                    if input then TriggerServerEvent('xpadmin:setXP', player.source, tonumber(input[1])) end
                end
            },
            {
                title = '🚀 Teleport To Player',
                icon = Config.Images.iconTP,
                onSelect = function()
                    SetEntityCoords(PlayerPedId(), player.coords.x, player.coords.y, player.coords.z)
                end
            }
        }
    })

    lib.showContext('xp_player_options')
end

RegisterNetEvent("xpadmin:showProgressOverview", function(players)
    local options = {}

    for _, player in pairs(players) do
        local level = math.floor((player.xp or 0) / 100)
        local nextXP = (level + 1) * 100
        local progress = math.floor(((player.xp or 0) / nextXP) * 100)

        table.insert(options, {
            title = ("%s | Level %s | XP: %s"):format(player.name, level, player.xp),
            description = ("ID: %s | %s%% to next level"):format(player.source, progress),
            icon = 'fa-solid fa-user-graduate',
            image = Config.Images.header,
        })
    end

    lib.registerContext({
        id = 'xp_admin_progress',
        title = '📊 Player Progress Overview',
        menu = 'xp_admin_main',
        options = options
    })

    lib.showContext('xp_admin_progress')
end)


------------------------------------------------------------------------------
--			PLAYERS PANEL
------------------------------------------------------------------------------

RegisterCommand("xpstats", function()
    local Player = QBCore.Functions.GetPlayerData()
    local xp = Player.metadata[Config.XP.metadataKey] or 0
    local level = math.floor(xp / 100)
    local nextXP = (level + 1) * 100
    local xpToNext = nextXP - xp
    local progress = math.floor((xp / nextXP) * 100)

    local info = {
        {
            title = "🧍 Name",
            description = Player.charinfo.firstname .. " " .. Player.charinfo.lastname,
            icon = 'fa-solid fa-user'
        },
        {
            title = "🔢 Level",
            description = tostring(level),
            icon = 'fa-solid fa-layer-group'
        },
        {
            title = "📈 XP",
            description = ("%s XP | %s%% to next level"):format(xp, progress),
            icon = 'fa-solid fa-chart-line'
        },
        {
            title = "🕐 XP Needed",
            description = ("%s XP to Level %s"):format(xpToNext, level + 1),
            icon = 'fa-solid fa-bullseye'
        },
		{
			title = '📊(CLICK HERE) XP Stats',
			icon = 'fa-solid fa-eye',
			onSelect = function()
				TriggerServerEvent("xpadmin:showPlayerStats")
			end
		}
    }

    lib.registerContext({
        id = 'xp_player_menu',
        title = '🎮 Your Progress',
        options = info,
        image = Config.Images.header
    })

    lib.showContext('xp_player_menu')
end)


RegisterCommand("xpleaderboard", function()
    TriggerServerEvent("xpadmin:getLeaderboard")
end)


RegisterNetEvent("xpadmin:showLeaderboard", function(players)
    local sessionTab = {}
    local totalTab = {}

    for _, player in ipairs(players) do
        local level = math.floor(player.xp / 100)
        local nextXP = (level + 1) * 100
        local progress = math.floor((player.xp / nextXP) * 100)

        local sessionLevel = math.floor(player.sessionXP / 100)
        local sessionNextXP = (sessionLevel + 1) * 100
        local sessionProgress = math.floor((player.sessionXP / sessionNextXP) * 100)

        table.insert(totalTab, {
            title = ("%s | Lvl %s"):format(player.name, level),
            description = ("XP: %s | %s%% to next level"):format(player.xp, progress),
            icon = 'fa-solid fa-star',
            progress = progress,
            onSelect = function()
                TriggerServerEvent("xpadmin:showPlayerStats")
            end
        })

        table.insert(sessionTab, {
            title = ("(CLICK HERE) %s | Lvl %s"):format(player.name, sessionLevel),
            description = ("Session XP: %s | %s%% to next level"):format(player.sessionXP, sessionProgress),
            icon = 'fa-solid fa-clock',
            progress = sessionProgress,
            onSelect = function()
				TriggerEvent("mobz:openleader2")
     
            end
        })
    end

    lib.registerContext({
        id = 'xp_leaderboard_menu',
        title = '🏆 XP Leaderboard',
        menu = 'xp_leaderboard_tabs',
        options = totalTab
    })

    lib.registerContext({
        id = 'xp_session_menu',
        title = '🕐 Session Leaderboard',
        menu = 'xp_leaderboard_tabs',
        options = sessionTab
    })

    lib.registerContext({
        id = 'xp_leaderboard_tabs',
        title = '📊 XP Tabs',
        options = {
            {
                title = "🏆 Total XP",
                icon = 'fa-solid fa-award',
                menu = 'xp_leaderboard_menu'
            },
            {
                title = "🎯 Session XP/Leaderboard",
                icon = 'fa-solid fa-clock',
                menu = 'xp_session_menu'
            },
	
        }
    })

    lib.showContext('xp_leaderboard_tabs')
end)


--[[
RegisterCommand("openxpboard", function()
    TriggerServerEvent("xpadmin:showPlayerStats")
end, false)
--]]

--RegisterKeyMapping("openxpboard", "Open XP Leaderboard", "keyboard", "F9")

local function PlayAmbientSound(soundName, soundDict)
    if not soundName or not soundDict then return end
    PlaySoundFrontend(-1, soundName, soundDict, true)
end

--    PlayAmbientSound(npc.ambientSound, npc.ambientDict)





local leaderboard = {}

RegisterNetEvent("xp_leaderboard:update", function(data)
    leaderboard = data
end)

function getXP(id)
    for _, v in pairs(leaderboard) do
        if tonumber(v.id) == tonumber(id) then
            return tonumber(v.xp) or 0
        end
    end
    return 0
end

RegisterNetEvent("xp_leaderboard:show3dtext", function(playerId)
    local ped = GetPlayerPed(GetPlayerFromServerId(playerId))
    if not ped then return end

    local coords = GetEntityCoords(ped)
    local timer = GetGameTimer() + (Config.Display3DTextTime * 1000)

    CreateThread(function()
        while GetGameTimer() < timer do
            local dist = #(coords - GetEntityCoords(PlayerPedId()))
            if dist < 30 then
                DrawText3D(coords.x, coords.y, coords.z + 1.2, 
                    ("~y~%s\n~b~XP: ~w~%d"):format(GetPlayerName(GetPlayerFromServerId(playerId)), getXP(playerId)))
            end
            Wait(0)
        end
    end)
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local dist = #(p - vector3(x, y, z))

    local scale = (1 / dist) * 2
    scale = scale * (1 / GetGameplayCamFov()) * 100

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end


RegisterNetEvent("mobz:openleader2", function()
	openLeaderboard()
end)
function openLeaderboard()


    if #leaderboard == 0 then
        TriggerServerEvent("xp_leaderboard:request")
        Wait(1000)
    end

    local entries = {}

    for i, data in ipairs(leaderboard) do
        local badge = Config.Badges[i]

        if not badge and Config.Badges["xp"] then
            for _, v in ipairs(Config.Badges["xp"]) do
                if data.xp >= v.threshold then
                    badge = v
                    break
                end
            end
        end

        table.insert(entries, {
            title = string.format("%d. %s", i, data.name),
            description = "XP: " .. data.xp,
            icon = badge and badge.icon or "user",
            iconColor = badge and badge.color or "blue",
            onSelect = function()
                TriggerServerEvent("xp_leaderboard:request3dtext", data.id)
            end
        })
    end

    lib.registerContext({
        id = 'xp_leaderboard_menu',
        title = Config.LeaderboardTitle,
        menu = 'main_menu',
        options = entries,
        metadata = {
            { label = 'Players Ranked', value = #leaderboard },
            --{ label = 'Updated', value = os.date("%X") } -- line 723
			{ label = 'Updated', value = tostring(GetGameTimer() // 1000) .. "s ago" }

        },
        image = Config.HeaderImage
    })

    lib.showContext('xp_leaderboard_menu')
end

RegisterCommand("xpleaderboard", openLeaderboard)
RegisterKeyMapping("xpleaderboard", "Open XP Leaderboard", "keyboard", Config.LeaderboardKey)



RegisterNetEvent("xp:celebratePromotion", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    for i = 1, 5 do
        UseParticleFxAssetNextCall("scr_indep_fireworks")
        StartParticleFxNonLoopedAtCoord("scr_indep_firework_starburst", coords.x, coords.y, coords.z + 2.0, 0.0, 0.0, 0.0, 1.5, false, false, false)
        Wait(1000)
    end
end)
------------------------------------------------------------------------------
--			
------------------------------------------------------------------------------

