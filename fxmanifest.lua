fx_version 'cerulean'
games {'gta5'}

lua54 'yes'

name         'toffleeca'
version      '1.0.0'
description  'Fleeca Robbery system'
author       'ChrisToF29380'
repository   'https://github.com/ChrisToFLuA/ToFFleeca'

dependency 'ox_lib'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
}

server_scripts {
	'server/*.lua'
}

client_scripts {
	'client/*.lua'
}

files{
    'locales/*.json'
}
