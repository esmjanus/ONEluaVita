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

color.loadpalette() -- Load Defaults colors

local msg = "Counter: Unk"
local crono = 0
while true do
	buttons.read() -- Read Buttons :P

	if back then back:blit(0,0) end

	crono += 1

	screen.print(10,10,"Ini Sample ONElua")
	screen.print(10,30,"Press X to save, [] to load, Crono: "..crono)
	screen.print(10,50,"ini.read(): "..tostring(msg))

	if buttons.cross then ini.write("samples/config_onelua.ini","crono",crono) end

	if buttons.square then msg = ini.read("samples/config_onelua.ini","crono","Counter: Unk") end

	screen.flip() -- Show Buff

	if buttons.released.start then break end -- back to main

end
