--[[ 
	ONElua.
	Lua Interpreter for PlayStation®Vita.
	
	Licensed by GNU General Public License v3.0
	
	Copyright (C) 2014-2018, ONElua Team
	http://onelua.x10.mx/staff.html
	
	Designed By:
	- DevDavisNunez (https://twitter.com/DevDavisNunez).
	- Gdljjrod (https://twitter.com/gdljjrod).
]]

color.loadpalette()
color.shine = color.new(255,255,255,100) -- new color shine!
local ip = osk.init("Insert the ip host", "192.168.100.23")
if ip then
	link_state = link.init(ip)
end

dofile("samples/explorer/engine.lua") -- Cargamos todas las funciones :P
dofile("samples/explorer/callbacks.lua") -- Cargamos el callback
dofile("samples/explorer/scripthome.lua") -- Cargamos todas las funciones :P

link_state = nil -- clean var..