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

	screen.print(10,10,"Draw Shape ONElua Sample")

	draw.gradrect(960,10,-150,150,color.blue,color.yellow,__HORIZONTAL)
	draw.gradrect(960,180,-150,150,color.blue,color.yellow,__VERTICAL)
	draw.gradrect(960,350,-150,150,color.blue,color.yellow,__DIAGONAL)
	draw.gradrect(800,10,-150,150,color.blue,color.yellow,__DOUBLEHOR)
	draw.gradrect(800,180,-150,150,color.blue,color.yellow,__DOUBLEVER)

	draw.filltriangle(670,480,710,380,780,490,color.blue)
	
	draw.framerect(170,150,150,150,color.blue,color.red,30)
	draw.gradarc(300,180,200,color.blue,color.red,20,90,40)
	draw.framearc(400,100,80,color.green,20,90,40)
	draw.circlesection(600,400,100,color.yellow,1)

	screen.flip() -- Show Buff

	if buttons.released.start then break end -- back to main

end
