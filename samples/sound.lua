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

-- Sound Sample ONElua :P
buttons.interval() -- Disables the function Autorepeat.

bgm = sound.load("samples/test.mp3")
if not bgm then os.message("Not Found Audio") return nil end -- if not found, back to menu...

local tags = sound.getid3("samples/test.mp3") -- Get ID3 info, note only use if the sound is not play...
bgm:play(2) -- play sound in the channel 2.

while true do -- Main cycle.
    buttons.read()
	if back then back:blit(0,0) end

	if tags then
		y=120
		for f,v in pairs(tags) do
			if(f~="cover") then  screen.print(950,y,f..": "..tostring(v),1,color.white,0x0,__ARIGHT)
			else v:center()
			v:blit(480,272) end
			y = y + 20
		end
	end
	
	screen.print(480,10,"Sound Sample ONElua",1,color.white,color.green,__ACENTER)
	screen.print(10,30,"sound.playing(): "..tostring(sound.playing(bgm)))
	screen.print(10,50,"sound.endstream(): "..tostring(sound.endstream(bgm)))
	screen.print(10,70,"sound.channel(): "..tostring(sound.channel(bgm)))
	screen.print(10,90,"sound.looping(): "..tostring(sound.looping(bgm)))
	screen.print(10,110,"Press X to pause/resume")
	screen.print(10,130,"Press [] to resume if is in pause")
	screen.print(10,150,"Press Triangle to pause if is in resume")
	screen.print(10,170,"Press O to stop")
	screen.print(10,190,"Press R to play")
	screen.print(10,210,"Press L to Enable/Disable Loop")
	screen.print(10,230,"Press Select to save cover to ux0:/")

	screen.flip()
	power.tick(__POWER_TICK_SUSPEND) -- only no sleep, but turn off the screen.

	if buttons.cross then sound.pause(bgm) end

	if buttons.square then sound.pause(bgm,0) end

	if buttons.triangle then sound.pause(bgm,1) end

	if buttons.circle then sound.stop(bgm) end

	if buttons.r then sound.stop(bgm) sound.play(bgm,2)	end

	if buttons.l then sound.loop(bgm) end

	if buttons.select then
		sound.extractcover("samples/test.mp3","ux0:/") -- save cover to folder samples as cover.<ext>
	end

	if buttons.released.start then break end -- back to main

end
--sound.stop(bgm)
--bgm = nil
buttons.interval(8,8)