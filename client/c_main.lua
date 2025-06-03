if nexus.Framework == "QBCore" then 
    nexus.PL = 'QBCore:Client:OnPlayerLoaded'
end
if nexus.Framework == "ESX" then
    nexus.PL = 'esx:playerLoaded'
end


PlayerLoaded = false

AddEventHandler(nexus.PL, function()
    if nexus.debug == true then
        print("A player has loaded.")
    end

    TriggerServerEvent("nexus:playerloaded")
    
    Citizen.Wait(10000)

    PlayerLoaded = true

    Citizen.Wait(10000)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

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
        Wait(nexus.CheckTeleport)
        neni_v_aute = IsPedInAnyVehicle(PlayerPedId(), false)
        pada = IsPedFalling(PlayerPedId())

        local coords = GetEntityCoords(playerPed)
        if PlayerLoaded == true then
            TriggerServerEvent('nexusac:checkCoords', coords, neni_v_aute, pada)
            if nexus.debug == true then 
                print("[ NEXUS AC ] AC is checking for coords.")
            end
        end

        -- vehicle speed
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local speed = GetEntitySpeed(vehicle) * 3.6
            TriggerServerEvent('nexusac:checkSpeed', speed)
            if nexus.debug == true then 
                print("[ NEXUS AC ] AC is checking for speed.")
            end
        end

        if PlayerLoaded == true then
            TriggerEvent('nexusac:checkInvisible')
            if nexus.debug == true then 
                print("[ NEXUS AC ] AC is checking for invisibility.")
            end
        end

        TriggerEvent('nexusac:checkHealth')
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking for health.")
        end

        TriggerEvent('nexusac:checkArmor')
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking for armor.")
        end

        TriggerEvent('nexusac:checkStamina')
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking for stamina.")
        end

        TriggerEvent('nexusac:checkNightv')
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking for Night vision.")
        end

        TriggerEvent('nexusac:checkFreecam')
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking for freecam.")
        end

        TriggerEvent('nexusac:props')
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking for props in the whole map.")
        end

        local hb = true
        TriggerServerEvent('nexusac:hbuu', hb)
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking hb")
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

RegisterNetEvent('nexusac:checkHealth')
AddEventHandler(('nexusac:checkHealth'), function(health)
    local playerPed = PlayerPedId()
    local health = GetEntityHealth(playerPed)

    if health > nexus.MaxHealth then 
        TriggerEvent("nexusac:logHealth")
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking sending HEALTH report.")
        end
    end
end)

RegisterNetEvent('nexusac:checkArmor')
AddEventHandler(('nexusac:checkArmor'), function(armor)
    local playerPed = PlayerPedId()
    local armor = GetPedArmour(playerPed)

    if armor > nexus.MaxArmor then 
        TriggerEvent("nexusac:logArmor")
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking sending ARMOR report.")
        end
    end
end)

RegisterNetEvent('nexusac:checkStamina')
AddEventHandler(('nexusac:checkStamina'), function(staminaLevel)
    local playerPed = PlayerPedId()
    local armor = GetPedArmour(playerPed)

    if not IsPedInAnyVehicle(PlayerPedId(), true)
        and not IsPedRagdoll(PlayerPedId())
        and not IsPedFalling(PlayerPedId())
        and not IsPedJumpingOutOfVehicle(PlayerPedId())
        and not IsPedInParachuteFreeFall(PlayerPedId())
        and GetEntitySpeed(PlayerPedId()) > 7
    then
            local staminaLevel = GetPlayerSprintStaminaRemaining(PlayerId())
    end
    if tonumber(staminaLevel) == 0.0 then
        TriggerEvent("nexusac:logStamina")
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking sending STAMINA report.")
        end
    end
end)

RegisterNetEvent('nexusac:checkNightv')
AddEventHandler(('nexusac:checkNightv'), function()
    if GetUsingnightvision(true) and not IsPedInAnyHeli(PlayerPedId()) then
        TriggerEvent("nexusac:logNightvision")
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking sending NIGHT VISION report.")
        end
    end
    if GetUsingseethrough(true) and not IsPedInAnyHeli(PlayerPedId()) then
        TriggerEvent("nexusac:logNightvision")
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking sending THERMAL VISION report.")
        end
    end
end)

RegisterNetEvent('nexusac:checkFreecam')
AddEventHandler(('nexusac:checkFreecam'), function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local camCoords = GetFinalRenderedCamCoord()
    local distance = #(playerCoords - camCoords)
    if distance > 50 and not IsCinematicCamRendering() then 
        TriggerEvent("nexusac:logFreecam")
        if nexus.debug == true then 
            print("[ NEXUS AC ] AC is checking sending NIGHT VISION report.")
        end
    end
end)

RegisterNetEvent('nexusac:props')
AddEventHandler(('nexusac:props'), function()
    while true do
        local handle, object = FindFirstObject()
        local finished = false
        repeat
            Citizen.Wait(1)
            if nexus.Objects[GetEntityModel(object)] == true then
                DeleteObjects(object)
                TriggerServerEvent("nexus:logprop")
            end
            finished, object = FindNextObject(handle)
        until not finished
        EndFindObject(handle)
        Citizen.Wait(7500)
    end
end)
function DeleteObjects(object)
	if DoesEntityExist(object) then
		NetworkRequestControlOfEntity(object)
		while not NetworkHasControlOfEntity(object) do
			Citizen.Wait(1)
		end
		DetachEntity(object, 0, false)
		SetEntityCollision(object, false, false)
		SetEntityAlpha(object, 0.0, true)
		SetEntityAsMissionEntity(object, true, true)
		SetEntityAsNoLongerNeeded(object)
		DeleteEntity(object)
	end
end

RegisterNetEvent('nexusac:heartbeat', function()
    Wait(1000)
    hb = true
    TriggerEvent("nexusac:gothb", hb)
end)