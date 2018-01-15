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

if not files.exists("samples/sprites/") then
	os.message("Not found the sprites!")
	return 0 -- back script.lua
end

link = {
	crono = timer.new(),
	stay = {
		up = image.load("samples/sprites/link_stay_up.png"), -- faltaba el file xD
		down = image.load("samples/sprites/link_stay_down.png"),
		right = image.load("samples/sprites/link_stay_right.png"),
		left = image.load("samples/sprites/link_stay_left.png"),
	},
	walk = {
		up = image.load("samples/sprites/link_walk_up.png",22,27),
		down = image.load("samples/sprites/link_walk_down.png",22,27),
		right = image.load("samples/sprites/link_walk_right.png",22,27),
		left = image.load("samples/sprites/link_walk_left.png",22,27),
	}
}
link.crono:start()
 
status = "stay"
direction = "up" -- look "down"
x = 10
y = 10
anim = 0 -- frame current (0-10)

while true do
	buttons.read()

	if buttons.held.up or buttons.held.down or buttons.held.left or buttons.held.right then
		if link.crono:time() > 83 then 
			link.crono:reset(); link.crono:start();
			anim += 1
			if anim > 9 then
				anim = 0
			end
		end
		status = "walk"
	else
		anim = 0
		status = "stay"
	end

	if buttons.held.up then
		y -= 1
		direction = "up"
	elseif buttons.held.down then
		y += 1
		direction = "down"
	elseif buttons.held.right then
		x +=1
		direction = "right"
	elseif buttons.held.left then
		x -= 1
		direction = "left"
	end

	if x<0 then
		x=0
	elseif x+22>960 then
		x=960-22
	end

	if y<0 then
		y=0
	elseif y+27>544 then
		y=544-27
	end

	if status == "stay" then
		link[status][direction]:blit(x,y)
	else
		link[status][direction]:blitsprite(x,y,anim)
	end

	screen.print(240,10,"Sprites Link Sample ONElua",1,color.new(255,255,255),0x0,__ACENTER)

	screen.flip()

	if buttons.released.start then break end -- back to main
end
