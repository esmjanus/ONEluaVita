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
	if back then back:blit(0,0) end
	buttons.read() -- Read Buttons :P
	
	screen.print(10,10,"Hardware Sample ONElua")
	screen.print(10,30,"hw.model(): "..tostring(hw.model()))
	screen.print(10,50,"hw.board(): "..tostring(hw.board()))

	screen.print(10,70,"hw.iscex(): "..tostring(hw.iscex()))
	screen.print(10,90,"hw.isdex(): "..tostring(hw.isdex()))
	
	screen.print(10,110,"hw.headphone(): "..tostring(hw.headphone()).." - Conected: "..tostring(hw.headphone() == 1))
	screen.print(10,150,"hw.removablemc(): "..tostring(hw.removablemc())) -- Is a memory card?
	screen.print(10,170,"hw.emumc(): "..tostring(hw.emumc())) -- Can emu internal memory if not insert one?
	screen.print(10,220,"hw.is3g(): "..tostring(hw.is3g())) -- 3g??
	
	screen.print(10,240,"L/R vol+/- hw.volume(): "..tostring(hw.volume()))
	screen.print(10,260,"Press [] to Mute")

	screen.flip() -- Show Buff	

	if buttons.l then hw.volume(hw.volume()-1)	elseif buttons.r then hw.volume(hw.volume()+1)	end

	if buttons.square then hw.mute() end

	if buttons.released.start then break end -- back to main

end
