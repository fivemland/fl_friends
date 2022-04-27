fx_version("cerulean")
game("gta5")
author("Csoki")

shared_scripts({
	"@es_extended/imports.lua",
	"shared.lua",
})

client_script("client.lua")

server_scripts({
	"@oxmysql/lib/MySQL.lua",
	"server.lua",
})

files({ "ui/dist/**" })

ui_page("http://localhost:3000/index.html")
