ESX = exports['es_extended']:getSharedObject()

function StartFishingMiniGame()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local waterCheckResult, waterZ = TestProbeAgainstWater(playerCoords.x, playerCoords.y, playerCoords.z + 10.0, playerCoords.x, playerCoords.y, playerCoords.z - 10.0)

    if not waterCheckResult then
        ESX.ShowNotification("~r~You must be near water to fish.")
        return
    end

    local fishingRodModel = GetHashKey("prop_fishing_rod_01")
    RequestModel(fishingRodModel)
    while not HasModelLoaded(fishingRodModel) do
        Citizen.Wait(100)
    end

    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_FISHING", 0, true)
    Citizen.Wait(500)

    local fishingRod = CreateObject(fishingRodModel, 0, 0, 0, true, true, true)
    AttachEntityToEntity(fishingRod, playerPed, GetPedBoneIndex(playerPed, 57005), 0.15, 0.08, 0.0, 150.0, -130.0, 0.0, true, true, false, true, 1, true)

    ESX.ShowHelpNotification("~b~Wait for the right moment...")

    Citizen.Wait(math.random(Config.minigame.fishBiteTime.min, Config.minigame.fishBiteTime.max))
    
    ESX.ShowHelpNotification("~b~Fish is biting! Press ~INPUT_CONTEXT~ NOW!")

    local catchDeadline = GetGameTimer() + Config.minigame.catchTime
    local fishingSuccessful = false

    while GetGameTimer() < catchDeadline do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 38) then 
            TriggerServerEvent('hw_fishing:catchFish', "salmon")
            ESX.ShowHelpNotification("~g~You've caught a fish!")
            fishingSuccessful = true
            break
        elseif IsControlJustReleased(0, 74) then
            ESX.ShowHelpNotification("~r~You stopped fishing.")
            break
        end
    end

    DeleteEntity(fishingRod)
    ClearPedTasks(playerPed)

    if not fishingSuccessful then
        ESX.ShowHelpNotification("~r~The fish got away...")
    end
end

RegisterNetEvent('hw_fishing:startFishingMiniGame')
AddEventHandler('hw_fishing:startFishingMiniGame', function()
    StartFishingMiniGame()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = GetDistanceBetweenCoords(playerCoords, Config.shopLocation.x, Config.shopLocation.y, Config.shopLocation.z, true)

        if distance < 100.0 then
            DrawMarker(1, Config.shopLocation.x, Config.shopLocation.y, Config.shopLocation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 255, 0, 100, false, true, 2, false, false, false, false)
        end
        
        if distance < 1.5 then
            ESX.ShowHelpNotification("~b~Press ~INPUT_TALK~ to buy fishing gear")
            if IsControlJustReleased(0, 46) then
                OpenFishingShop()
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = GetDistanceBetweenCoords(playerCoords, Config.sellLocation.x, Config.sellLocation.y, Config.sellLocation.z, true)

        if distance < 1.5 then
            ESX.ShowHelpNotification("~b~Press ~INPUT_TALK~ to sell fish")
            if IsControlJustReleased(0, 46) then
                TriggerServerEvent('hw_fishing:sellAllFish')
            end
        end
    end
end)

function OpenFishingShop()
    if Config.items["fishing_rod"] == nil or Config.items["bait"] == nil then
        print("Error: Fishing Rod or Bait item not defined in Config.")
        return
    end

    local elements = {
        {label = "Fishing Rod ($" .. Config.items["fishing_rod"].price .. ")", value = 'fishing_rod'},
        {label = "Bait ($" .. Config.items["bait"].price .. ")", value = 'bait'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'fishing_shop',
        {
            title    = "Fishing Shop",
            align    = 'top-left',
            elements = elements,
        },
        function(data, menu) 
            local item = data.current.value
            OpenQuantityMenu(item)
            menu.close()
        end,
        function(data, menu) 
            menu.close()
        end
    )
end

function OpenQuantityMenu(item)
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'fishing_shop_buy_amount',
        {
            title = "Enter Quantity"
        },
        function(data, menu)
            local quantity = tonumber(data.value)
            if quantity ~= nil and quantity > 0 then
                TriggerServerEvent('hw_fishing:buyItem', item, quantity)
                menu.close()
            else
                ESX.ShowNotification("Invalid quantity.")
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end