shared_script '@waitrp_shield2/ai_module_fg-obfuscated.lua'
fx_version "bodacious"
game "gta5"
lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'modules/**/server.lua',
}

client_scripts {
	'modules/*.lua',
    'modules/**/client.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/assets/*.css',
    'html/assets/*.js',
    'html/assets/*.wav',
    'html/assets/*.mp3'
}