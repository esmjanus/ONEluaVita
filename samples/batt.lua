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

while true do
	buttons.read() -- Read Buttons :P

	if back then back:blit(0,0) end

	screen.print(10,10,"Battery Sample ONElua")
	screen.print(10,30,"batt.charging(): "..tostring(batt.charging()))
	screen.print(10,50,"batt.lifepercent(): "..tostring(batt.lifepercent()).." %")
	screen.print(10,70,"batt.lifetimemin(): "..tostring(batt.lifetimemin()).." Min")
	screen.print(10,90,"batt.lifetime(): "..tostring(batt.lifetime()).." Hr/Min")
	screen.print(10,110,"batt.remaincap(): "..tostring(batt.remaincap()))
	screen.print(10,130,"batt.fullcap(): "..tostring(batt.fullcap()))
	screen.print(10,150,"batt.low(): "..tostring(batt.low()))
	screen.print(10,170,"batt.exists(): "..tostring(batt.exists()))
	screen.print(10,190,"batt.temp(): "..tostring(batt.temp()))
	screen.print(10,210,"batt.volt(): "..tostring(batt.volt()))
	screen.print(10,230,"batt.soh(): "..tostring(batt.soh()).." %")
	screen.print(10,250,"batt.cycle(): "..tostring(batt.cycle()))
	
	screen.flip() -- Show Buff

	if buttons.released.start then	break end -- back to main

end
