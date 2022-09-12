fx_version 'cerulean'
games {'gta5'}

lua54 'yes'

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

chat_theme "chat-design-v2" {
    styleSheet = "chat-design-v2.css"
}