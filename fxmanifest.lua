fx_version 'cerulean'
games {'gta5'}

lua54 'yes'

name         'toffleeca'
version      '1.0.0'
description  'Fleeca Robbery system'
author       'ChrisToF29380'
repository   'https://github.com/ChrisToFLuA/ToFFleeca'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/*.lua'
}

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/*.lua',
}

shared_scripts {
	'@es_extended/locale.lua',
	'locales/fr.lua',
	'shared/*.lua',
	'@ox_lib/init.lua',
}