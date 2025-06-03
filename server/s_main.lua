if nexus.ServerID == "YOURSERVERID" then 
    print("\27[35m[ NEXUS AC ] \27[0m Please change your Server ID - config/config.lua -> nexus.ServerID.")
end

if nexus.Framework == "QBCore" then 
    QBCore = exports['qb-core']:GetCoreObject()
end

if nexus.Framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()
end


local blacklistedWeapons = nexus.BlacklistedWeapons

local playerData = {}

-- Check if the player is an admin
-- Check if the player is an admin using Discord ID
local function isAdmin(src)
    if nexus.Framework == "QBCore" then 
        local Player = QBCore.Functions.GetPlayer(src)
    end
    if nexus.Framework == "ESX" then
        local Player = ESX.GetPlayerFromId(src)
    end
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


local function GenerateBanID(length)
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local result = ''
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end


local function BanPlayer(src, reason)
    local banID = GenerateBanID(4)  -- Generate a unique Ban ID
    local bannedBy = "Nexus AntiCheat"  -- Or set as "Console" for console bans

    local identifiers = GetPlayerIdentifiers(src)
    local discordID, license = "Unknown", "Unknown"

    if identifiers and #identifiers > 0 then
        for _, id in ipairs(identifiers) do
            if string.sub(id, 1, 8) == "discord:" then
                discordID = string.sub(id, 9)
            elseif string.sub(id, 1, 8) == "license:" then
                license = id
            end
        end
    end

    -- Insert ban into the database
    exports.oxmysql:insert([[ 
        INSERT INTO nexus_bans (banID, discordID, license, reason, bannedBy)
        VALUES (?, ?, ?, ?, ?)
    ]], {banID, discordID, license, reason, bannedBy})

    -- DropPlayer after banning the player
    DropPlayer(src, "[NEXUS AC] You have been banned for: " .. reason .. "\nBan ID: " .. banID)

    print("Ban ID: [" .. banID .. "] Player " .. discordID .. " has been banned for: " .. reason)

    PerformHttpRequest("https://bans.aspectcommunity.com/logban", function(err, text, headers)
        if err ~= 200 then
            print("Ban log failed to send.")
        end
    end, "POST", json.encode({
        banID = banID,
        reason = reason,
        serverID = nexus.ServerID or "unknown"
    }), {
        ["Content-Type"] = "application/json"
    })
end
-- --- --- -- - -- 
RegisterNetEvent("nexusac:hbuu")
AddEventHandler('nexusac:hbuu', function(hb)
    if nexus.Heartbeat == true then 
        if nexus.debug == true then
            print("[ NEXUS AC ] triggering a heartbeat")
        end
        if nexus.debug == true then
        print("[ NEXUS AC ] got a heartbeat")
        end

        if hb == nil or hb ~= true then
            hb = false
        end
    
        local src = source 
        local playerName = GetPlayerName(src)
        local PlayerId = src

        if hb == false then
            print("[ NEXUS AC ] " .. playerName .. " has not sent a heartbeat!" )
        end
        if nexus.debug == true and hb == true then 
            print("[ NEXUS AC ] " .. playerName .. " heartbeat recieved.")
        end
    end
end)

-- REGISTERS
RegisterNetEvent("nexusac:checkWeapons")
AddEventHandler("nexusac:checkWeapons", function(weapon)
    if nexus.debug == true then 
        print("\27[35m[ NEXUS AC ] \27[0m Anticheat has started a WEAPON check")
    end

    local src = source

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    if nexus.Framework == "QBCore" then 
        local Player = QBCore.Functions.GetPlayer(src)
    end
    if nexus.Framework == "ESX" then
        local Player = ESX.GetPlayerFromId(src)
    end

    local playerName = GetPlayerName(src)
    local PlayerId = src

    if Player then
        for _, blacklisted in pairs(blacklistedWeapons) do
            if weapon == blacklisted then
                if isAdmin(src) then
                    return  -- Skip the check if the player is an admin
                end
                exports["nexus_anticheat"]:SendLog("detection",{
                    color = 8454399,
                    title = "[ NEXUS AC ] A player has been detected for blacklisted weapon!",
                    description = "**Player:** " .. playerName .. "\n" ..
                                  "**ID:** " .. PlayerId .. "\n" ..
                                  "**Weapon hash:** " .. weapon,
                })

                if nexus.BlacklistedWeapon == true then
                    if nexus.debug == false then
                        BanPlayer(src, "Blacklisted weapon detected")
                    end
                    return 
                end
            end 
        end
    end
end)

RegisterNetEvent("nexusac:checkCoords")
AddEventHandler("nexusac:checkCoords", function(coords, neni_v_aute, pada)

    if nexus.debug == true then 
        print("\27[35m[ NEXUS AC ] \27[0m Anticheat has started a COORDS check")
    end

    local src = source

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    local playerName = GetPlayerName(src)
    local PlayerId = src


    if not playerData[src] then 
        playerData[src] = { lastCoords = coords, lastCheck = os.time() }
        return 
    end

    local lastCoords = playerData[src].lastCoords
    local distance = #(vector3(coords.x, coords.y, coords.z) - vector3(lastCoords.x, lastCoords.y, lastCoords.z))

    if distance > nexus.Distance then 
        if os.time() - playerData[src].lastCheck > 10 then
            if neni_v_aute and not pada then
                if isAdmin(src) then
                    return  -- Skip the check if the player is an admin
                end
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
                    if nexus.debug == false then
                        BanPlayer(src, "Teleport detected")
                    end
                    return
                end
            else
                if nexus.debug == true then 
                    print("\27[35m[ NEXUS AC ] \27[0m Detected a potential teleport, but waiting for cooldown.")
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
        print("\27[35m[ NEXUS AC ] \27[0m Anticheat has started a SPEED check")
    end
    local src = source

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    local playerName = GetPlayerName(src)
    local PlayerId = src
    local maxSpeed = nexus.maxSpeed -- Maximální normální rychlost

    if speed > maxSpeed then
        if isAdmin(src) then
            return  -- Skip the check if the player is an admin
        end
        if nexus.debug == true then 
            print("\27[35m[ NEXUS AC ] \27[0m DETECTION !")
            print("\27[35m[ NEXUS AC ] \27[0m Anticheat has detected a BOOSTED VEHICLE! " .. playerName .. " exceeded max speed of " .. nexus.maxSpeed .. nexus.speedm .. " !")
        end
        exports["nexus_anticheat"]:SendLog("detection",{
            color = 8454399,
            title = "[ NEXUS AC ] A player has been detected for a boosted vehicle!",
            description = "**Player:** " .. playerName .. "\n" ..
                          "**ID:** " .. PlayerId .. "\n" ..
                          "**Speed exceeded:** " .. nexus.maxSpeed .. " " .. nexus.speedm,
        })

        if nexus.BoostedVehicles == true then
            if nexus.debug == false then
                BanPlayer(src, "Boosted vehicle detected")
            end
            return
        end
    end
end)


RegisterServerEvent('nexusac:logInvisiblePlayer')
AddEventHandler('nexusac:logInvisiblePlayer', function()
    if nexus.debug == true then 
        print("\27[35m[ NEXUS AC ] \27[0m Anticheat has LOGGED an INVISIBLE player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Invisible player detected!",
        description = "**Player:** " .. playerName .. "\n" ..
                      "**ID:** " .. src,
    })

    if nexus.Invisible == true then
        if nexus.debug == false then
            BanPlayer(src, "Invisibility detected")
        end
        return
    end
end)

RegisterNetEvent('nexusac:logHealth')
AddEventHandler("nexusac:logHealth", function(health)
    if nexus.debug == true then
        print("\27[35m[ NEXUS AC ] \27[0m Anticheat has LOGGED an HEALTH exceeding player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Health exceeding player detected!",
        description = "**Player:** " .. playerName .. "\n" ..
                      "**ID:** " .. src ..
                      "**Health:**" .. health,
    })

    if nexus.Health == true then
        if nexus.debug == false then
            BanPlayer(src, "Exceeded health detected")
        end
        return
    end
end)

RegisterNetEvent('nexusac:logArmor')
AddEventHandler("nexusac:logArmor", function(armor)
    if nexus.debug == true then
        print("\27[35m[ NEXUS AC ] \27[0m Anticheat has LOGGED an Armor exceeding player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Armor exceeding player detected!",
        description = "**Player:** " .. playerName .. "\n" ..
                      "**ID:** " .. src ..
                      "**Health:**" .. health,
    })

    if nexus.Armor == true then
        if nexus.debug == false then
            BanPlayer(src, "Exceeded armor detected")
        end
        return
    end
end)

RegisterNetEvent('nexusac:logStamina')
AddEventHandler("nexusac:logStamina", function(staminaLevel)
    if nexus.debug == true then
        print("\27[35m[ NEXUS AC ] \27[0m Anticheat has LOGGED an Stamina exceeding player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Stamina exceeding player detected!",
        description = "**Player:** " .. playerName .. "\n" ..
                      "**ID:** " .. src ..
                      "**Stamina:**" .. staminaLevel,
    })

    if nexus.Stamina == true then
        if nexus.debug == false then
            BanPlayer(src, "Exceeded stamina detected")
        end
        return
    end
end)

RegisterNetEvent('nexusac:logNightvision')
AddEventHandler("nexusac:logNightvision", function()
    if nexus.debug == true then
        print("\27[35m[ NEXUS AC ] \27[0m Anticheat has LOGGED a Night Vision/Thermal Vision using player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Night Vision/Thermal Vision using player detected!",
        description = "**Player:** " .. playerName .. "\n" ..
                      "**ID:** " .. src,
    })

    if nexus.NightVision == true then
        if nexus.debug == false then
            BanPlayer(src, "Nightvision detected")
        end
        return
    end
end)

RegisterNetEvent('nexusac:logFreecam')
AddEventHandler("nexusac:logFreecam", function()
    if nexus.debug == true then
        print("\27[35m[ NEXUS AC ] \27[0m Anticheat has LOGGED a FREECAM using player")
    end
    local src = source
    local playerName = GetPlayerName(src)

    if isAdmin(src) then
        return  -- Skip the check if the player is an admin
    end

    exports["nexus_anticheat"]:SendLog("detection",{
        color = 8454399,
        title = "[ NEXUS AC ] Freecam using player detected!",
        description = "**Player:** " .. playerName .. "\n" ..
                      "**ID:** " .. src,
    })

    if nexus.Freecam == true then
        if nexus.debug == false then
            BanPlayer(src, "Freecam detected")

            PerformHttpRequest("http://bans.aspectcommunity.com/logban", function(err, text, headers)
                if err ~= 200 then
                    print("Ban log failed to send.")
                end
            end, "POST", json.encode({
                banID = banID,
                reason = reason,
                serverID = nexus.ServerID or "unknown"
            }), {
                ["Content-Type"] = "application/json"
            })
            
        end
        return
    end
end)

RegisterNetEvent("nexus:playerloaded")
AddEventHandler("nexus:playerloaded", function()
    if nexus.debug == true then
        print("\27[35m[ NEXUS AC ] \27[0m Anticheat has LOGGED a player loaded")
    end


    local src = source
    local playerName = GetPlayerName(src)
    if playerName == nil then
        playerName = "Unknown"
    end

    Wait(1000)
    
    exports["nexus_anticheat"]:SendLog("joinlog",{
        color = 6029134,
        title = "[ NEXUS AC ] Player has joined.",
        description = "**Player:** " .. playerName .. "\n" ..
                      "**ID:** " .. src,
    })
    print("\27[35m[ NEXUS AC ] \27[0m player " .. "\27[36m".. playerName .. "\27[0m has connected!")
    Citizen.SetTimeout(5000)
end)

RegisterServerEvent("nexus:logprop")
AddEventHandler("nexus:logprop", function()
    PerformHttpRequest("http://bans.aspectcommunity.com/logban", function(err, text, headers)
        if err ~= 200 then
            print("Ban log failed to send.")
        end
    end, "POST", json.encode({
        banID = "Prop delete",
        reason = "A prop has been deleted!",
        serverID = nexus.ServerID or "unknown"
    }), {
        ["Content-Type"] = "application/json"
    })
end)
