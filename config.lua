Config = {}

-- Mode: 'active' or 'debug'
Config.mode = 'debug'
Config.checkForUpdates = true

-- Discord Logging
Config.discordLogging = true
Config.discordWebhook = 'https://discord.com/api/webhooks/1224749991256657992/0N8X4pClt1QH0V_flN9iNbFvZGlwbxJzRFviQ1Ztk1G0eozJKv7qZRV8a1Qnzg8U9bbT'

-- Fishing Shop Location
Config.shopLocation = {x = -1038.74, y = -1396.92, z = 5.55}

-- Fishing Sell Location
Config.sellLocation = {x = -1035.6, y = -1397.04, z = 5.52}

-- Fishing Items
Config.items = {
    ["fishing_rod"] = {price = 100},
    ["bait"] = {price = 5},
}

-- Fish Types and Rarity
Config.fishTypes = {
    {name = "Salmon", probability = 0.6}, -- Adjust probability values as needed
    {name = "Trout", probability = 0.3},
    {name = "Golden Fish", probability = 0.1},
}

Config.fishPrices = {
    ["Salmon"] = 50,
    ["Trout"] = 30,
    ["Golden Fish"] = 100,
}

-- Mini-game configurations
Config.minigame = {
    fishBiteTime = {
        min = 5000, -- Minimum time in milliseconds for fish to bite
        max = 10000 -- Maximum time in milliseconds for fish to bite
    },
    catchTime = 5000 -- Time in milliseconds that the player has to catch the fish
}
