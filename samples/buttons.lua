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
mask = {"up", "down", "left", "right", "cross", "circle", "square", "triangle", "r", "l", "start", "select", "home", "volup", "voldown"}

function draw.rectHighlight(x, y, w, h,color_in,color_line)
	if not color_in then color_in = color.shine end
	if not color_line then color_line = color.white end
	draw.fillrect(x, y, w, h, color_in); draw.rect(x, y, w, h, color_line)
end

released_alfa = 0
released_msg = ""

press_alfa = 0
press_msg = ""

buttons.analogtodpad(0) -- Disable analog to pad.
buttons.homepopup(0) -- Block out to livearea.

local pallete = {"red","blue","green","cyan","magenta","yellow","maroon","grass","navy","turquoise","violet","olive","white","gray","black","orange","chocolate"}
local over_pallete = 1

while true do -- Main Bucle.
	buttons.read() -- Read Buttons :P
	
	if back then back:blit(0,0) end
	draw.rectHighlight(200,10,320,30)
	screen.print(205,15,"Buttons Tester ONElua Sample",1,color.white)
	
	draw.rectHighlight(200,430,300,110)
	screen.print(210,430,"Pressed Test Area",1,color.white)
	screen.print(210,475,"Released Test Area",1,color.white)
	
	draw.rectHighlight(10,10,180,530)
	screen.print(15,12,"Held Test Area",1,color.white)
	
	local x = 20
	local y = 40
	for i=1,#mask do
		if buttons.held[mask[i]] then
			screen.print(x,y,mask[i].." Held!",1.0,color.white)
			y += 20
		end
		if buttons[mask[i]] then
			press_alfa = 255
			press_msg = mask[i].." Press!"
		end
		if buttons.released[mask[i]] then
			released_alfa = 255
			released_msg = mask[i].." released!"
		end
	end
	
	screen.print(210,455,press_msg,1,color.white:a(press_alfa))
	if press_alfa > 0 then press_alfa -= 4 end
	
	screen.print(210,495,released_msg,1,color.white:a(released_alfa))
	if released_alfa > 0 then released_alfa -= 4 end
	screen.print(600,30,"Analog Left: "..string.format("x: %03d - y: %03d",buttons.analoglx,buttons.analogly))
	screen.print(600,50,"Analog Right: "..string.format("x: %03d - y: %03d",buttons.analogrx,buttons.analogry))
	local ports = buttons.portinfo() -- Check the ports.
	screen.print(600,70,string.format("Ports INFO\n#1: %s\n#2: %s",ports[1].type, ports[2].type))
	if ports[1].type == "DS4" then
		-- Code of set color light bar in ds4
		if buttons.right then
			over_pallete += 1
			if over_pallete > #pallete then over_pallete = 1 end
		end
		if buttons.left then
			over_pallete -= 1
			if over_pallete < 1 then over_pallete = #pallete end
		end
		draw.rectHighlight(510,400,440,140)
		screen.print(520,449-40,"Press <-/-> to change light bar in ds4 ctrl.")
		screen.print(520,449-20,string.format("Color: %s - R: %03d - G: %03d - B: %03d",pallete[over_pallete],color[pallete[over_pallete]]:r(),color[pallete[over_pallete]]:g(),color[pallete[over_pallete]]:b()))
		draw.fillrect(520,449,420,85,color[pallete[over_pallete]])
		draw.rect(520,449,420,85,color.white)
		buttons.lbar(1, color[pallete[over_pallete]])
	end
	if ports[1].type == "DS3" or ports[1].type == "DS4" then
		-- Code of set rumble!
		buttons.rumble(1, math.abs(buttons.analogly*2), math.abs(buttons.analogry*2))
	end
	--if buttons.r then buttons.emu(__VOLUP)
	--elseif buttons.l then buttons.emu(__VOLDOWN) end
	screen.flip() -- Show Buff
	
	if buttons.released.start then break end -- back to main.

end
buttons.homepopup(1) -- Enable out to livearea.
buttons.analogtodpad(60)