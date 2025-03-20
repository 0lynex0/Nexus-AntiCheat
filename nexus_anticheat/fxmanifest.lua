
fx_version "cerulean"
game "gta5"
author "Phoenix"
description "Free FiveM Anticheat"
version "1.0.0"

shared_scripts {
    "config/config.lua",
    "config/admins.lua",
}


server_scripts {
    "server/s_main.lua",
    "server/s_logs.lua",
}

client_scripts {
    "client/c_main.lua",
}
