ESX = exports['es_extended']:getSharedObject()

local function debugAndDiscordLog(message)
    if Config.mode == 'debug' then
        print("^5[HW Fishing Debug]:^0 " .. message)
    end
    if Config.discordLogging then
        local data = {
            ["username"] = "Fishing Script",
            ["embeds"] = {{
                ["title"] = "Fishing Notification",
                ["description"] = message,
                ["color"] = 56108
            }},
            ["avatar_url"] = "https://example.com/fish.png"
        }
        PerformHttpRequest(Config.discordWebhook, function(err, text, headers) end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
    end
end

ESX.RegisterUsableItem('fishing_rod', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getInventoryItem('bait').count > 0 then
        xPlayer.removeInventoryItem('bait', 1)
        TriggerClientEvent('hw_fishing:startFishingMiniGame', source)
        debugAndDiscordLog("Player " .. xPlayer.getIdentifier() .. " started fishing.")
    else
        TriggerClientEvent('esx:showNotification', source, "~r~You need bait to fish.")
    end
end)

RegisterServerEvent('hw_fishing:buyItem')
AddEventHandler('hw_fishing:buyItem', function(item, quantity)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = Config.items[item] and Config.items[item].price or 0

    if price > 0 then
        local totalPrice = price * quantity
        if xPlayer.getMoney() >= totalPrice then
            xPlayer.removeMoney(totalPrice)
            xPlayer.addInventoryItem(item, quantity)
            TriggerClientEvent('esx:showNotification', source, "You bought " .. quantity .. "x " .. item .. " for $" .. totalPrice)
            debugAndDiscordLog("Buying Item", "Player " .. xPlayer.getIdentifier() .. " bought " .. quantity .. "x " .. item .. " for $" .. totalPrice)
        else
            TriggerClientEvent('esx:showNotification', source, "~r~You don't have enough money to buy " .. quantity .. "x " .. item)
        end
    else
        TriggerClientEvent('esx:showNotification', source, "~r~Invalid item: " .. item)
    end
end)

RegisterServerEvent('hw_fishing:catchFish')
AddEventHandler('hw_fishing:catchFish', function(fishType)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(fishType, 1)
    debugAndDiscordLog("Player " .. xPlayer.getIdentifier() .. " caught a " .. fishType)
end)

RegisterServerEvent('hw_fishing:sellAllFish')
AddEventHandler('hw_fishing:sellAllFish', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local totalMoney = 0
    local soldFish = false

    for _, fish in ipairs(Config.fishTypes) do
        local fishCount = xPlayer.getInventoryItem(fish.name).count
        if fishCount > 0 then
            local fishPrice = Config.fishPrices[fish.name] or 0
            local reward = fishPrice * fishCount
            totalMoney = totalMoney + reward
            xPlayer.addMoney(reward)
            xPlayer.removeInventoryItem(fish.name, fishCount)
            soldFish = true
            debugAndDiscordLog("Selling Fish", "Player " .. xPlayer.getIdentifier() .. " sold " .. fishCount .. "x " .. fish.name .. " for $" .. reward, 65280)
        else
            TriggerClientEvent('esx:showNotification', source, "~r~You don't have any fish on you to sell!")
        end
    end

    if soldFish then
        TriggerClientEvent('esx:showNotification', source, "You sold your fish for $" .. totalMoney)
    else
        TriggerClientEvent('esx:showNotification', source, "~r~You don't have any fish to sell.")
    end
end)