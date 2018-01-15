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
img = image.load("sce_sys/livearea/contents/bg0.png")

front = img:copy()
front:resize(240,136)
if img then img:resize(480,272) end

x,y = 840,500
while true do
	buttons.read() -- Read Buttons :P

	if back then back:blit(0,0) end
	if front then front:blittint(10,540-146,color.red) end

	screen.print(10,30,"img:getrealw(): "..tostring(img:getrealw()).." | img:getrealh(): "..tostring(img:getrealh()))
	screen.print(10,50,"img:getw(): "..tostring(img:getw()).." | img:geth(): "..tostring(img:geth())) 

	screen.print(10,70,"Color img pixel ",1,img:pixel(x,y) or color.new(255,0,0))

	if buttons.up then y -= 1 elseif buttons.down then y += 1 end
	if buttons.left then x -= 1 elseif buttons.right then x += 1 end

	--if buttons.cross then img:pixel(x,y,color.white) end
	--if buttons.square then img:pixel(x,y,color.green) end
	if buttons.triangle then img:fxinvert() end
	if buttons.circle then img:fxgrey() end

	if buttons.r then img:save("ux0:/ONEimage.png")
	elseif buttons.l then img:flipv()
	end
	
	screen.print(10,90,"Export image press select (sce_sys/livearea/contents/bg0.png) : "..tostring(export))
	if buttons.select then export=files.export("sce_sys/livearea/contents/bg0.png") end

	if buttons.square then export=screen.shot() end

	screen.flip() -- Show Buff

	if buttons.released.start then break end -- back to main

end
