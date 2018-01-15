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
res = wlan.connect()
while true do
	buttons.read()

	if back then back:blit(0,0) end

	screen.print(480,10,"Wlan Sample ONElua",1,color.white,color.green,__ACENTER)
	screen.print(10,30,"wlan.connect(): "..tostring(res))
	screen.print(10,50,"wlan.isconnected(): "..tostring(wlan.isconnected()))
	screen.print(10,70,"wlan.status(): "..tostring(wlan.status()))
	screen.print(10,90,"wlan.strength(): "..tostring(wlan.strength()).."%")
	screen.print(10,110,"wlan.over(): "..tostring(wlan.over()))

	screen.flip()

	if buttons.released.start then break end -- back to main
end
