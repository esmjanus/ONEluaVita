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

function draw.rectHighlight(x, y, w, h,color_in,color_line)
	if not color_in then color_in = color.shine end
	if not color_line then color_line = color.white end
	draw.fillrect(x, y, w, h, color_in); draw.rect(x, y, w, h, color_line)
end

touch_alfa_top = {0,0,0,0,0,0}
touch_alfa_back = {0,0,0,0,0,0}
touch_col = {color.white, color.green, color.blue, color.red, color.yellow, color.orange, color.cyan}

local frame = 0
local tail = {}
for i=0,59 do
	tail["id"..i] = {x=0,y=0} -- use string index to jump limit of 0 as index XD :D
end
while true do
	buttons.read() -- Read Buttons :P
	touch.read()
	if back then back:blit(0,0) end
	screen.print(480,15,"Touch ONElua Sample",1,color.white,0x0,__ACENTER)
	local y = 35
	for i=1,touch.front.count do
		screen.print(10,y,string.format("Frontal Touch: x: %03d - y: %03d - pressed: %s - held: %s - released: %s",touch.front[i].x,touch.front[i].y,tostring(touch.front[i].pressed),tostring(touch.front[i].held),tostring(touch.front[i].released)))
		y += 20
	end
	y = 170
	for i=1,touch.back.count do
		screen.print(10,y,string.format("Back Touch: x: %03d - y: %03d - pressed: %s - held: %s - released: %s",touch.back[i].x,touch.back[i].y,tostring(touch.back[i].pressed),tostring(touch.back[i].held),tostring(touch.back[i].released)))
		y += 20
	end
	for i=1,6 do
		screen.print(touch.front[i].x,touch.front[i].y, "+",1,touch_col[i]:a(touch_alfa_top[i]))
		if touch.front[i].held then
			touch_alfa_top[i] = 255
		elseif touch_alfa_top[i] > 0 then
			touch_alfa_top[i] -= 2
		end
	end

	for i=1,4 do
		screen.print(touch.back[i].x,touch.back[i].y, "X",1,touch_col[i]:a(touch_alfa_back[i]))
		if touch.back[i].held then
			touch_alfa_back[i] = 255
		elseif touch_alfa_back[i] > 0 then
			touch_alfa_back[i] -= 2
		end
	end

	local k = frame % 60
	tail["id"..k] = {x = touch.front[1].x, y = touch.front[1].y}
	for i=0,59 do
		local t = tail["id"..((k+1+i)%60)]
		draw.circle(t.x,t.y,i,color.white:a(4.25*i))
	end
	frame += 1
	if frame > 59 then
		frame = frame % 60
	end
	screen.flip() -- Show Buff

	if buttons.released.start then break end -- back to main.

end
