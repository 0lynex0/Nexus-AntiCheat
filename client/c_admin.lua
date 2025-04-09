RegisterCommand("nexusadmin", function()
    TriggerServerEvent("nexus:checkIfAdmin")
    TriggerServerEvent("nexus:getBans")
end)

RegisterNetEvent("nexus:sendBans", function(bans)
    SendNUIMessage({
        action = "receiveBans",
        bans = bans
    })
end)

RegisterNetEvent("nexus:showAdminPanel", function()
    SetNuiFocus(true, true) 
    SendNUIMessage({ action = "openPanel" })
end)

RegisterNUICallback('closePanel', function(data, cb)
    SetNuiFocus(false, false) 
    print("Panel byl zavřen.")

    -- Odpověď na callback
    cb('ok')
end)

RegisterNUICallback("unbanPlayer", function(data, cb)
    TriggerServerEvent("nexus:unbanPlayer", data.banID)
    cb({ success = true })
end)

RegisterNUICallback("getBans", function(data, cb)
    TriggerServerEvent("nexus:getBans")
    cb({ success = true })
end)
