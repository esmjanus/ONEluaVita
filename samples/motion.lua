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
local x,y = 480,272
while true do
	buttons.read() -- Read Buttons :P
	motion.read()
	
	if back then back:blit(0,0) end
	screen.print(10,15,"Motion ONElua Sample",1,color.white,color.blue)
	
	draw.circle(x,y,40,color.white)
	if (motion.acceleration.x > 0.150)  then
		x += 16 * math.abs(motion.acceleration.x)
	elseif (motion.acceleration.x < -0.150) then
		x -= 16 * math.abs(motion.acceleration.x)
	end
	if x < 0+40 then
		x = 40
	elseif x > 960-40 then
		x = 920
	end
	if (motion.acceleration.y > 0.150) and y > 0+40  then
		y -= 16* math.abs(motion.acceleration.y)
	end
	if (motion.acceleration.y < -0.150) and y < 544-40 then
		y += 16* math.abs(motion.acceleration.y)
	end
	screen.print(10,35,string.format("Acceleration x: %03f - y: %03f - %03f",motion.acceleration.x,motion.acceleration.y,motion.acceleration.z))
	screen.print(10,55,string.format("Velocity x: %03f - y: %03f - %03f",motion.velocity.x,motion.velocity.y,motion.velocity.z))

	screen.flip() -- Show Buff

	if buttons.released.start then break end -- back to main.

end
