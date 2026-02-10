fx_version 'cerulean'
game 'gta5'

author 'Koumarianos'
description 'Koumarianos Appearance - ESX Clothing & Character Creator'
version '2.0.0'

shared_scripts {
    '@es_extended/locale.lua',
    'config.lua'
}

client_scripts {
    'client/storage.lua',
    'client/appearance.lua',
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

dependencies {
    'es_extended'
}