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
	if back then back:blit(0,0) end
	buttons.read() -- Read Buttons :P
	screen.print(10,10,"Ftp Server ONElua Sample")
	screen.print(10,30,"wlan.connect(): "..tostring(res))
	screen.print(10,50,"ftp.init(): "..tostring(ret))
	screen.print(10,70,"ftp.state(): "..tostring(ftp.state()))
	screen.print(10,90,"wlan.isconnected(): "..tostring(wlan.isconnected()))
	screen.print(10,110,"Press cross to init ftp.")
	screen.print(10,130, "Mac: "..tostring(os.mac()))

	if ftp.state() then	screen.print(10,160,"Connect to:\nftp://"..tostring(wlan.getip())..":1337")	end

	screen.flip() -- Show Buff

	if buttons.cross then ret = ftp.init() end
	if buttons.released.start then break end -- back to main

end
