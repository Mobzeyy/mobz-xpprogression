fx_version 'cerulean'
game 'gta5'

author 'mobz'
description 'Live XP Progression UI for QB-Core'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua', 
    'config.lua'
}

client_scripts {
    'client/main.lua',
}

server_script 'server/main.lua'


dependency {
	'qb-core',
	--'ox_lib',
}


exports {
    "AddXP",
    "RemoveXP"
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}