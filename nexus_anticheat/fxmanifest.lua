
fx_version "cerulean"
game "gta5"
author "Phoenix"
description "Free FiveM Anticheat"
version "1.0.5"

shared_scripts {
    "config/config.lua",
}


server_scripts {
    "config/admins.lua",
    "config/webhooks.lua",
    "server/s_main.lua",
    "server/s_logs.lua",
}

client_scripts {
    "client/c_main.lua",
}
