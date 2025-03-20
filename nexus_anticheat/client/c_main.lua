Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            if nexus.debug == true then
                print("✅ ", "Heartbeat from playerload has been accepted")
            end
            
            Citizen.Wait(10000)

        end)

        -- get player weapon
        local playerPed = PlayerPedId()
        local weapon = GetSelectedPedWeapon(playerPed)


        if weapon ~= nil then
            TriggerServerEvent('nexusac:checkWeapons', weapon)

            if nexus.debug == true then 
                print("[ NEXUS AC ] Player has weapon: " .. weapon)
            end
        else
            if nexus.debug == true then
                print("[ NEXUS AC ] Player has no weapon equipped.")
            end
        end

        -- teleportation
        local coords = GetEntityCoords(playerPed)
        TriggerServerEvent('nexusac:checkCoords', coords)
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking for coords.")
        end

        -- vehicle speed
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local speed = GetEntitySpeed(vehicle) * 3.6 -- m/s na km/h
            TriggerServerEvent('nexusac:checkSpeed', speed)
            if nexus.debug == true then 
                print("[ NEXUS AC ] AC is checking for speed.")
            end
        end
        
        -- invis
        TriggerEvent('nexusac:checkInvisible')
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking for invisibility.")
        end
    end
end)





-- REGISTERS

RegisterNetEvent('nexusac:checkInvisible')
AddEventHandler('nexusac:checkInvisible', function()
    local playerPed = PlayerPedId()

    if not IsEntityVisible(playerPed) then
        TriggerServerEvent('nexusac:logInvisiblePlayer')
    end
end)