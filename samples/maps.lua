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

dofile("samples/maps/table_map.lua")

iMap=image.load("samples/maps/tileset.png",16,16)
if iMap then _map=map.new(iMap,tabla,16,16) end

x,y=0,0
while true do
	buttons.read()

	--Blit
	map.blit(_map,x,y)

	if buttons.held.down then y+=10 elseif buttons.held.up then y-=10 end
	if buttons.held.right then x+=10 elseif buttons.held.left then x-=10 end

	screen.flip()

	if buttons.released.start then
		iMap=nil
		_map=nil
		--collectgarbage("collect")
		break
	end

end