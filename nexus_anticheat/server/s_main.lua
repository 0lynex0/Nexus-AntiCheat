local QBCore = exports['qb-core']:GetCoreObject()

local blacklistedWeapons = nexus.BlacklistedWeapons

local playerData = {}

-- Check if the player is an admin
-- Check if the player is an admin using Discord ID
local function isAdmin(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local identifiers = GetPlayerIdentifiers(src)  -- Get all identifiers
        for _, id in pairs(identifiers) do
            if string.find(id, "discord:") then  -- Check for the Discord identifier
                local discordId = string.sub(id, 9)  -- Remove "discord:" prefix
                for _, admin in pairs(nexus.Admins) do
                    if discordId == admin then  -- Compare with admin list
                        return true
                    end
                end
            end
        end
    end
    return false
end


RegisterNetEvent("nexusac:checkWeapons")
AddEventHandler("nexusac:checkWeapons", function(weapon)
    if nexus.debug == true then 
        print("[ NEXUS AC ] Anticheat has started a WEAPON check")
    end
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)

    local playerName = GetPlayerName(src)
    local PlayerId = src

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    if Player then
        for _, blacklisted in pairs(blacklistedWeapons) do
            if weapon == blacklisted then
                exports["nexus_anticheat"]:SendLog("detection",{
                    color = 8454399,
                    title = "[ NEXUS AC ] A player has been detected for blacklisted weapon!",
                    description = "**Player:** " .. playerName .. "\n" ..
                                  "**ID:** " .. PlayerId .. "\n" ..
                                  "**Weapon hash:** " .. weapon,
                })
                if nexus.BlacklistedWeapon == true then 
                    DropPlayer(src, "[ NEXUS AC ] You have been detected for using blacklisted weapon!")
                    return 
                end
            end 
        end
    end
end)

RegisterNetEvent("nexusac:checkCoords")
AddEventHandler("nexusac:checkCoords", function(coords, neni_v_aute, pada)

    if nexus.debug == true then 
        print("[ NEXUS AC ] Anticheat has started a COORDS check")
    end

    local src = source
    local playerName = GetPlayerName(src)
    local PlayerId = src

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    if not playerData[src] then 
        playerData[src] = { lastCoords = coords, lastCheck = os.time() }
        return 
    end

    local lastCoords = playerData[src].lastCoords
    local distance = #(vector3(coords.x, coords.y, coords.z) - vector3(lastCoords.x, lastCoords.y, lastCoords.z))

    if distance > nexus.Distance then 
        if os.time() - playerData[src].lastCheck > 10 then
            if neni_v_aute and not pada then
                exports["nexus_anticheat"]:SendLog("detection",{
                    color = 8454399,
                    title = "[ NEXUS AC ] A player has been detected for teleporting!",
                    description = "**Player:** " .. playerName .. "\n" ..
                                "**ID:** " .. PlayerId .. "\n" ..
                                "**Distance:** " .. distance,
                })
                playerData[src].lastCoords = coords
                playerData[src].lastCheck = os.time()
                if nexus.Teleport == true then
                    DropPlayer(src, "[ NEXUS AC ] You have been detected for teleporting!")
                    return
                end
            else
                if nexus.debug == true then 
                    print("[ NEXUS AC ] Detected a potential teleport, but waiting for cooldown.")
                end
            end
        else
            playerData[src].lastCheck = os.time()
        end
    end
end)

RegisterServerEvent('nexusac:checkSpeed')
AddEventHandler('nexusac:checkSpeed', function(speed)
    if nexus.debug == true then 
        print("[ NEXUS AC ] Anticheat has started a SPEED check")
    end
    local src = source
    local playerName = GetPlayerName(src)
    local PlayerId = src
    local maxSpeed = nexus.maxSpeed -- Maximální normální rychlost

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    if speed > maxSpeed then
        if nexus.debug == true then 
            print("[ NEXUS AC ] DETECTION !")
            print("[ NEXUS AC ] Anticheat has detected a BOOSTED VEHICLE! " .. playerName .. " exceeded max speed of " .. nexus.maxSpeed .. nexus.speedm .. " !")
        end
        exports["nexus_anticheat"]:SendLog("detection",{
            color = 8454399,
            title = "[ NEXUS AC ] A player has been detected for a boosted vehicle!",
            description = "**Player:** " .. playerName .. "\n" ..
                          "**ID:** " .. PlayerId .. "\n" ..
                          "**Speed exceeded:** " .. nexus.maxSpeed .. " " .. nexus.speedm,
        })
        if nexus.BoostedVehicles == true then
            DropPlayer(src, "[ NEXUS AC ] You have been detected for boosted vehicle!")
            return
        end
    end
end)


RegisterServerEvent('nexusac:logInvisiblePlayer')
AddEventHandler('nexusac:logInvisiblePlayer', function()
    if nexus.debug == true then 
        print("[ NEXUS AC ] Anticheat has LOGGED an INVISIBLE player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Invisible player detected!",
        description = "**Hráč:** " .. playerName .. "\n" ..
                      "**ID:** " .. src,
    })

    if nexus.Invisible == true then
        DropPlayer(src, "[NEXUS AC] You have been detected for invisibility!")
        return
    end
end)

RegisterNetEvent('nexusac:logHealth')
AddEventHandler("nexusac:logHealth", function(health)
    if nexus.debug == true then
        print("[ NEXUS AC ] Anticheat has LOGGED an HEALTH exceeding player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Health exceeding player detected!",
        description = "**Hráč:** " .. playerName .. "\n" ..
                      "**ID:** " .. src ..
                      "**Health:**" .. health,
    })

    if nexus.Health == true then
        DropPlayer(src, "[NEXUS AC] You have been detected for health cheats!")
        return
    end
end)

RegisterNetEvent('nexusac:logArmor')
AddEventHandler("nexusac:logArmor", function(armor)
    if nexus.debug == true then
        print("[ NEXUS AC ] Anticheat has LOGGED an Armor exceeding player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Armor exceeding player detected!",
        description = "**Hráč:** " .. playerName .. "\n" ..
                      "**ID:** " .. src ..
                      "**Health:**" .. health,
    })

    if nexus.Armor == true then
        DropPlayer(src, "[NEXUS AC] You have been detected for armor cheats!")
        return
    end
end)

RegisterNetEvent('nexusac:logStamina')
AddEventHandler("nexusac:logStamina", function(staminaLevel)
    if nexus.debug == true then
        print("[ NEXUS AC ] Anticheat has LOGGED an Stamina exceeding player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Stamina exceeding player detected!",
        description = "**Hráč:** " .. playerName .. "\n" ..
                      "**ID:** " .. src ..
                      "**Stamina:**" .. staminaLevel,
    })

    if nexus.Stamina == true then
        DropPlayer(src, "[NEXUS AC] You have been detected for stamina cheats!")
        return
    end
end)

RegisterNetEvent('nexusac:logNightvision')
AddEventHandler("nexusac:logNightvision", function()
    if nexus.debug == true then
        print("[ NEXUS AC ] Anticheat has LOGGED a Night Vision/Thermal Vision using player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Night Vision/Thermal Vision using player detected!",
        description = "**Hráč:** " .. playerName .. "\n" ..
                      "**ID:** " .. src,
    })

    if nexus.NightVision == true then
        DropPlayer(src, "[NEXUS AC] You have been detected for Night Vision/Thermal Vision cheats!")
        return
    end
end)

RegisterNetEvent('nexusac:logFreecam')
AddEventHandler("nexusac:logFreecam", function()
    if nexus.debug == true then
        print("[ NEXUS AC ] Anticheat has LOGGED a FREECAM using player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Freecam using player detected!",
        description = "**Hráč:** " .. playerName .. "\n" ..
                      "**ID:** " .. src,
    })

    if nexus.Freecam == true then
        DropPlayer(src, "[NEXUS AC] You have been detected for freecam cheats!")
        return
    end
end)

RegisterNetEvent("nexus:playerloaded")
AddEventHandler("nexus:playerloaded", function()
    if nexus.debug == true then
        print("[ NEXUS AC ] Anticheat has LOGGED a player loaded")
    end

    local src = source
    local playerName = GetPlayerName(src)

    exports["nexus_anticheat"]:SendLog("joinlog",{
        color = 6029134,
        title = "[ NEXUS AC ] Player has joined.",
        description = "**Hráč:** " .. playerName .. "\n" ..
                      "**ID:** " .. src,
    })
    print("\27[35m[ NEXUS AC ] \27[0m player " .. "\27[36m".. playerName .. "\27[0m has connected!")
end)