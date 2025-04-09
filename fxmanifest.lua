
fx_version "cerulean"
game "gta5"
author "Phoenix"
description "Free FiveM Anticheat"
version "1.0.8.2"

shared_scripts {
    "config/config.lua",
}


server_scripts {
    "config/admins.lua",
    "config/webhooks.lua",
    "server/s_main.lua",
    "server/s_logs.lua",
    "server/s_banning.lua",
    '@oxmysql/lib/MySQL.lua',
    "server/s_admin.lua",
}

client_scripts {
    "client/c_main.lua",
    "client/c_admin.lua"
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css'
}
