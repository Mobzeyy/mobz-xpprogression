Config = {}

-- UI positioning and style
Config.UI = {
    enabledByDefault = true,
    position = { x = 0.5, y = 0.1 }, -- top center
    scale = 10.0,
    colors = {
        low = '#FF0000',
        medium = '#FFA500',
        high = '#00FF00'
    }
}

-- XP logic
Config.XPPlayTime = {
    Enabled = true,
    IntervalMinutes = 5,        -- Every 5 minutes
    XPPerInterval = 10,         -- Amount of XP to give
    Notify = true               -- Whether to notify the player
}

Config.XP = {
    maxXP = 100,
    metadataKey = 'xp',
	adminJob = "driver",       -- Admin job name
	
    -- XP Values
    xpOnKill = 15,
    xpOnDeath = -10,

    -- Kill cooldown (anti-farm)
    killCooldown = 60,

    -- Streaks
    enableStreaks = true,
    bonusPerStreak = 2,

    -- Notifications
    enableNotifications = true,
    notify = {
        gain = "🔥 You earned %s XP! (Streak: %s)",
        loss = "💀 You lost %s XP for dying.",
        cooldown = "⛔ No XP - Kill cooldown active."
    }
}

Config.Images = {
    header = "https://i.postimg.cc/RZrBFgCH/ZOMBIEWAR.png", -- Example header image
    iconAdd = "fa-solid fa-plus",
    iconRemove = "fa-solid fa-minus",
    iconSet = "fa-solid fa-pen",
    iconTP = "fa-solid fa-location-dot"
}

Config.EnableRewards = true -- Global toggle
Config.Levels = {
	--[2] = {reward = false}, -- no reward
	
    [1] = {reward = true, items = {"bread"}, money = 1000}, -- so level 1 will get bread item and 1000 cash
    [2] = {reward = false}, -- no reward
    [3] = {reward = true, items = {"bread"}, money = 1500},
	[4] = {reward = true, items = {"bread"}, money = 2000},
	[5] = {reward = true, items = {"bread"}, money = 3000},
	
	[6] = {reward = true, items = {"bread"}, money = 3000},
    [7] = {reward = true, items = {"bread"}, money = 3000}, -- no reward
    [8] = {reward = true, items = {"weapon_pistol"}, money = 10000},
	[9] = {reward = true, items = {"weapon_smg"}, money = 15000},
	[10] = {reward = true, items = {"weapon_assaultrifle"}, money = 25000},
    -- Continue as needed
}

Config.CelebrationDuration = 5 -- in seconds

Config.UseOxLib = true -- toggle for using ox_lib menu


--[[
Config.JobXPGrades = {
    ['driver'] = {
        [1] = 500,
        [2] = 2000,
        [3] = 5000,
        [4] = 7500,
        [5] = 10000,
        [6] = 15000,
        [7] = 20000,
        [8] = 25000,
        [9] = 30000,
        [10] = 50000,
    },
    ['medic'] = {
        [1] = 500,
        [2] = 2000,
        [3] = 5000,
        [4] = 7500,
        [5] = 10000,
        [6] = 15000,
        [7] = 20000,
        [8] = 25000,
        [9] = 30000,
        [10] = 50000,
    },
	['scavenger'] = {
        [1] = 500,
        [2] = 2000,
        [3] = 5000,
        [4] = 7500,
        [5] = 10000,
        [6] = 15000,
        [7] = 20000,
        [8] = 25000,
        [9] = 30000,
        [10] = 50000,
    },
}
Config.EnableCelebration = true
--]]
Config.Notify = function(source, msg, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = (type == 'demote' and 'Demotion') or 'Promotion!',
        description = msg,
        type = (type == 'demote' and 'error') or 'success',
        position = 'top',
        duration = 5000
    })
end




-- Number of levels required to increase a grade
Config.LevelsPerGrade = 1 -- e.g., every 3 levels = 1 grade

-- Max grades per job (customize per job name)
Config.MaxGrades = {
    ["driver"] = 10,
    ["medic"] = 10,
    ["scavenger"] = 10,
    ["taxi"] = 5,
    ["unemployed"] = 0
}

-- Enable debug output
Config.Debug = true


Config.CheckInterval = 3



Config.LeaderboardKey = 'F2'--F11

Config.LeaderboardTitle = "🏆 XP Leaderboard"
Config.MaxLeaderboard = 30
Config.UpdateInterval = 10 -- seconds

Config.HeaderImage = "https://i.postimg.cc/RZrBFgCH/ZOMBIEWAR.png"

Config.Badges = {
    [1] = { icon = "🏆", label = "Champion", color = "gold" },
    [2] = { icon = "🥈", label = "Elite", color = "silver" },
    [3] = { icon = "🥉", label = "Veteran", color = "bronze" },
    -- fallback: XP thresholds
    ["xp"] = {
        { threshold = 10000, icon = "🔥", color = "orange", label = "XP Master" },
        { threshold = 5000, icon = "⚡", color = "green", label = "XP Hunter" }
    }
}

Config.Display3DTextTime = 10 -- seconds

Config.Locations = {
    vector3(-266.57, -960.94, 31.22) -- example for zone-based triggers if needed
}

