fx_version 'cerulean'
games { 'gta5' }

author 'Henk W'
description 'Advanced Fishing Script'
version '0.0.2'

client_scripts {
    'client/main.lua',
}
server_scripts {
    'server/main.lua',
    'server/version.lua',
}
shared_scripts {
    'config.lua',
    '@es_extended/imports.lua',
}

