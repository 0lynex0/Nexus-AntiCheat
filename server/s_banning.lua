if nexus.Framework == "QBCore" then 
    local QBCore = exports['qb-core']:GetCoreObject()
end
if nexus.Framework == "ESX" then
    local ESX = exports["es_extended"]:getSharedObject()
end

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()  -- Deferring the connection to check the ban status  
    
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local discordID, license = nil, nil

    local playerName = GetPlayerName(src)

    print("\27[35m[ NEXUS AC ] \27[0m Player " .. playerName .. " is connecting.")

    if nexus.ConnectText == true then
        deferrals.update("🛡️ Nexus AC: Checking identifiers...")
        Wait(1000)
        deferrals.update("🔍 Nexus AC: Searching bans database...")
        Wait(1250)
        deferrals.update("✅ Nexus AC: Done searching")
    end

    Citizen.Wait(2000)

    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, 8) == "discord:" then
            discordID = string.sub(id, 9)
        elseif string.sub(id, 1, 8) == "license:" then
            license = id
        end
    end

    if not discordID or not license then
        deferrals.done("Missing required identifiers.")
        return
    end

    exports.oxmysql:execute('SELECT * FROM nexus_bans WHERE discordID = ? OR license = ?', {discordID, license}, function(result)
        if result[1] then
            local banID = result[1].banID
            local reason = result[1].reason or "No reason provided"
            local bannedBy = result[1].bannedBy or "Unknown"
            local banTimestamp = result[1].timestamp

            
            deferrals.done(
                "\n\n[ NEXUS ANTICHEAT ]\n\n" ..
                "⛔ You are banned from the server.\n\n" ..
                "📄 Ban ID: " .. banID .. "\n" ..
                "📌 Reason: " .. reason .. "\n" ..
                "🛡️  Banned by: " .. bannedBy .. "\n" ..
                "🔗 Unban Request: " .. nexus.Discord
            )            

            print("\27[35m[ NEXUS AC ] \27[0m Player " .. playerName .. " tried to connect, but has an active ban " .. banID)
        else
            deferrals.done()
        end
    end)
end)



local function GenerateBanID(length)
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local result = ''
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

local function GenerateID(length)
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local result = ''
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

RegisterCommand("nexus", function(source, args, rawCommand)
    local subcommand = args[1]

    if not subcommand then
        print([[
        
💠 Nexus Anticheat Admin Commands 💠

▸ /nexus ban [id] [reason]       - Ban a player by ID
▸ /nexus unban [banID]           - Unban a player by Ban ID

Example: /nexus ban 3 invisibility hacks
Example: /nexus unban E770

        ]])
        return
    end

    if subcommand == "ban" then
        local targetId = tonumber(args[2])
        if not targetId then
            print("⚠️ Usage: /nexus ban [id] [reason]")
            return
        end

        local targetName = GetPlayerName(targetId)
        if not targetName then
            print("❌ Player is not online.")
            return
        end

        local reason = table.concat(args, " ", 3)
        if reason == nil or reason == "" then
            reason = "No reason provided"
        end

        local bannedBy = source == 0 and "Console" or (GetPlayerName(source) or "Unknown")
        local banID = GenerateBanID(nexus.banIDlength)

        local identifiers = GetPlayerIdentifiers(targetId)
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

        exports.oxmysql:insert([[
            INSERT INTO nexus_bans (banID, discordID, license, reason, bannedBy)
            VALUES (?, ?, ?, ?, ?)
        ]], {banID, discordID, license, reason, bannedBy})

        DropPlayer(targetId, "You've been banned!\n\nReason: " .. reason .. "\nBan ID: " .. banID)
        print("✅ Ban ID: [" .. banID .. "] Player " .. discordID .. " has been banned by " .. bannedBy .. " | Reason: " .. reason)

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

    elseif subcommand == "unban" then
        local banId = args[2]
        if not banId then
            print("⚠️ Usage: /nexus unban [banID]")
            return
        end

        local unbannedBy = source == 0 and "Console" or (GetPlayerName(source) or "Unknown")

        exports.oxmysql:execute([[
            DELETE FROM nexus_bans WHERE banID = ?
        ]], {banId}, function(result)
            if result.affectedRows and result.affectedRows > 0 then
                print("✅ [" .. banId .. "] Unbanned by " .. unbannedBy .. ".")
            else
                print("❌ No ban record found for Ban ID: " .. banId)
            end
        end)

    else
        print("❌ Unknown subcommand. Use `/nexus` to see available options.")
    end
end, true)
