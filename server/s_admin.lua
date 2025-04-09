RegisterServerEvent("nexus:checkIfAdmin")
AddEventHandler("nexus:checkIfAdmin", function()
    local src = source

    local function isAdmin(src)
        if nexus.Framework == "QBCore" then 
            local Player = QBCore.Functions.GetPlayer(src)
        end
        if nexus.Framework == "ESX" then
            local Player = ESX.GetPlayerFromId(src)
        end
        if Player then
            local identifiers = GetPlayerIdentifiers(src)
            for _, id in pairs(identifiers) do
                if string.find(id, "discord:") then
                    local discordId = string.sub(id, 9)
                    for _, admin in pairs(nexus.Admins) do
                        if discordId == admin then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    if isAdmin(src) then
        TriggerClientEvent("nexus:showAdminPanel", src)
    else
        TriggerClientEvent("nexus:closePanel", src)
    end
end)

RegisterServerEvent("nexus:getBans")
AddEventHandler("nexus:getBans", function()
    local src = source
    exports.oxmysql:execute("SELECT * FROM nexus_bans", {}, function(result)
        TriggerClientEvent("nexus:sendBans", src, result)
    end)
end)

RegisterServerEvent("nexus:unbanPlayer")
AddEventHandler("nexus:unbanPlayer", function(banID)
    local src = source

    if not banID then return end

    exports.oxmysql:execute("DELETE FROM nexus_bans WHERE banID = @banID", {
        ['@banID'] = banID
    }, function(affectedRows)
        if 0 == 0 then
            print("^2[NEXUS AC]^7 Ban ID "..banID.." has been unbanned.")
        end
    end)
end)

