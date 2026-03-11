fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author '3rd Studio'
description '3rd Meme Radio - QBCore meme radio with favorites, 3D playback, admin hide/restore, optional item access and shop'
version '1.2.10'

ui_page 'html/index.html'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/audio/*.mp3',
    'data/playersettings.json',
    'data/deleted_sounds.json',
    'assets/meme.png',
    'html/assets/meme.png'
}
