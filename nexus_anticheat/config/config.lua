nexus = nexus or {} 

--
--░█████╗░░█████╗░███╗░░██╗███████╗██╗░██████╗░
--██╔══██╗██╔══██╗████╗░██║██╔════╝██║██╔════╝░
--██║░░╚═╝██║░░██║██╔██╗██║█████╗░░██║██║░░██╗░
--██║░░██╗██║░░██║██║╚████║██╔══╝░░██║██║░░╚██╗
--╚█████╔╝╚█████╔╝██║░╚███║██║░░░░░██║╚██████╔╝
--░╚════╝░░╚════╝░╚═╝░░╚══╝╚═╝░░░░░╚═╝░╚═════╝░


-- Debug mode will NOT BAN PLAYERS, but it will log a detection.
nexus.debug = false

nexus.Discord = "https://discord.com/" -- Your Discord link


--░██╗░░░░░░░██╗███████╗██████╗░██╗░░██╗░█████╗░░█████╗░██╗░░██╗░██████╗
--░██║░░██╗░░██║██╔════╝██╔══██╗██║░░██║██╔══██╗██╔══██╗██║░██╔╝██╔════╝
--░╚██╗████╗██╔╝█████╗░░██████╦╝███████║██║░░██║██║░░██║█████═╝░╚█████╗░
--░░████╔═████║░██╔══╝░░██╔══██╗██╔══██║██║░░██║██║░░██║██╔═██╗░░╚═══██╗
--░░╚██╔╝░╚██╔╝░███████╗██████╦╝██║░░██║╚█████╔╝╚█████╔╝██║░╚██╗██████╔╝
--░░░╚═╝░░░╚═╝░░╚══════╝╚═════╝░╚═╝░░╚═╝░╚════╝░░╚════╝░╚═╝░░╚═╝╚═════╝░


nexus.Webhooks = { 
    ['detection']= { -- DO NOT TOUCH
        author = "", -- Name on the webhook
        icon = '', -- Icon for the webhook
        URL = 'WEBHOOK', -- The webhook URL
    },
}



--██████╗░███████╗████████╗███████╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
--██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
--██║░░██║█████╗░░░░░██║░░░█████╗░░██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
--██║░░██║██╔══╝░░░░░██║░░░██╔══╝░░██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
--██████╔╝███████╗░░░██║░░░███████╗╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
--╚═════╝░╚══════╝░░░╚═╝░░░╚══════╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░

nexus.BlacklistedWeapon = true
nexus.Teleport          = true
nexus.BoostedVehicles   = true
nexus.Invisible         = true
nexus.Health            = true
nexus.Armor             = true
nexus.Stamina           = true
nexus.NightVision       = true
nexus.Freecam           = true


--░██████╗███████╗████████╗████████╗██╗███╗░░██╗░██████╗░░██████╗
--██╔════╝██╔════╝╚══██╔══╝╚══██╔══╝██║████╗░██║██╔════╝░██╔════╝
--╚█████╗░█████╗░░░░░██║░░░░░░██║░░░██║██╔██╗██║██║░░██╗░╚█████╗░
--░╚═══██╗██╔══╝░░░░░██║░░░░░░██║░░░██║██║╚████║██║░░╚██╗░╚═══██╗
--██████╔╝███████╗░░░██║░░░░░░██║░░░██║██║░╚███║╚██████╔╝██████╔╝
--╚═════╝░╚══════╝░░░╚═╝░░░░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░╚═════╝░

nexus.BlacklistedWeapons = {
    GetHashKey("WEAPON_GADGETPISTOL"),    
    GetHashKey("weapon_raypistol"),       
    GetHashKey("weapon_raycarbine"),      
    GetHashKey("weapon_rayminigun"),      
    GetHashKey("weapon_hominglauncher"),  
    GetHashKey("weapon_railgunxm3"),      
    GetHashKey("weapon_rpg"),             
    GetHashKey("weapon_minigun"),         
    GetHashKey("weapon_railgun"),     
}

nexus.Distance = 1000 -- In meters, how many does the player need to teleport to get detected?

nexus.maxSpeed          = 200.0 -- Ignore, if nexus.BoostedVehicles is false.
nexus.speedm            = "KM/H" -- KM/H || Mph -> What you use

nexus.MaxHealth         = 100.0
nexus.MaxArmor          = 100.0