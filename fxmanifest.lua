fx_version 'cerulean'
game 'gta5'

author 'Atina'
description 'Atina Ortak Depo Sistemi - Ox Inventory & Ox Lib'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'ox_lib',
    'ox_inventory'
}