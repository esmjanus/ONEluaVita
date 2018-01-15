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

	screen.print(10,10,"Power Sample ONElua")
	screen.print(10,30,"power.plugged(): "..tostring(power.plugged()))
	screen.print(10,50,"power.timer(): "..tostring(power.timer()))
	screen.print(10,70,"power.usbcharging(): "..power.usbcharging())
	
	screen.print(10,280,"Press L/R On/Off USB charging")
	screen.print(10,300,"Press Triangle to Suspend Vita")
	screen.print(10,320,"Press X Shutdown Vita")
	screen.print(10,340,"Press [] to reboot Vita (Warning Complete Reboot)")

	screen.flip() -- Show Buff

	if buttons.l then power.usbcharging(power.usbcharging()-1) end
	if buttons.r then power.usbcharging(power.usbcharging()+1) end

	if buttons.triangle then power.suspend() end
	if buttons.cross then power.shutdown() end
	if buttons.square then power.restart() end

	if buttons.released.start then break end -- back to main
end
