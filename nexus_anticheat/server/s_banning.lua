local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()  -- Deferring the connection to check the ban status  
    
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local discordID, license = nil, nil

    local playerName = GetPlayerName(src)

    print("[ NEXUS AC ] Player " .. playerName .. " is connecting.")

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

            
            deferrals.done("\n\n[ NEXUS ANTICHEAT ] You are banned from the server.\nBan ID: " .. banID .. "\nReason: " .. reason .. "\nBanned by: " .. bannedBy .. "\nBan Timestamp: " .. banTimestamp .. "\n Unban Discord: " .. nexus.Discord)
            print("[ NEXUS AC ] Player " .. playerName .. " tried to connect, but has an active ban " .. banID)
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

RegisterCommand("nexusunban", function(source, args, rawCommand)
    if not args[1] then 
        print("Usage: /nexusunban [banid]")
        return
    end

    local banId = args[1]

    if not banId then
        print("Invalid ban ID.")
        return
    end

    local unbannedBy = source == 0 and "Console" or (GetPlayerName(source) or "Unknown")

    exports.oxmysql:execute([[
        DELETE FROM nexus_bans WHERE banID = ?
    ]], {banId}, function(result)
        if result.affectedRows and result.affectedRows > 0 then
            print("[" .. banId .. "] has been unbanned and removed from the database.")
        else
            print("No ban record found for Ban ID " .. banId)
        end
    end)

end, true)

RegisterCommand("nexusban", function(source, args, rawCommand)
    if not args[1] then 
        print("Usage: /nexusban [id] [reason]")
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        print("Invalid player ID.")
        return
    end

    local targetName = GetPlayerName(targetId)
    if not targetName then
        print("Player is not online.")
        return
    end

    local reason = table.concat(args, " ", 2)
    if reason == nil or reason == "" then
        reason = "No reason provided"
    end

    local bannedBy = source == 0 and "Console" or (GetPlayerName(source) or "Unknown")

    local banID = GenerateBanID(4)

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

    print( "[" .. banID .. "] Player " .. discordID .. " has been banned by " .. bannedBy .. " with the reason: " .. reason )
end, true)
