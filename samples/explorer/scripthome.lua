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

--Principal Script

pathini="ux0:/ONEMENU/ONEMENU.INI" -- ruta del Archivo de configuracion...
files.mkdir("ux0:/ONEMENU/") -- creamos el directorio de ONEmenu en raiz.

if files.exists("ux0:/ONEMENU/LANG.LUA") then dofile("ux0:/ONEMENU/LANG.LUA")
else dofile("samples/explorer/ING.LUA") end -- cargamos el lenguaje de acuerdo a existencia.

mimes = image.load("samples/explorer/ICONS.PNG",16,16)--Sprites icons

--[[1 CustomColor
	2 Background]]
config = {0xffffff,"BACK.PNG"}

if files.exists(pathini) then dofile(pathini) else write_ini(pathini, config) end

wall = image.load(config[2]) -- Load a custom wallpaper
if not wall then wall=image.load("BACK.PNG") end -- if nil, then load default wallpaper

if wall and (image.getrealw(wall) < __DISPLAYW or image.getrealh(wall) < __DISPLAYH) or
	(image.getrealw(wall) > __DISPLAYW or image.getrealh(wall) > __DISPLAYH) then
	wall:resize(__DISPLAYW, __DISPLAYH)
end

accept,cancel = "cross","circle"
if buttons.assign()==0 then accept,cancel = "circle","cross" end

if buttons.assign() then _button = "X" else _button = "O" end

BarColor = color.new(0,255,0,95)

-- Create two scrolls :P
scroll = {
	list = newScroll(),
	menu = newScroll(),
}

Root = {"ux0:/","ur0:/"}
if link_state then
	Root[2] = "host0:/"
end
Dev=1
backl,slide_open = {},{false,false}
update_opts_txt()
divsect = 1
buttons.interval(10,6)

while true do
	buttons.read()
	if wall then wall:blit(0,0) end

	if divsect == 1 then -- List
		show_explorer_list() -- regla siempre el draw
		ctrls_explorer_list()
		if buttons.triangle then
			BackExpl = screen.buffertoimage()
			divsect, slide_open = 2, {true,true}
		end
	elseif divsect == 2 then -- Menu
		if BackExpl then BackExpl:blit(0,0) end
		main_explorer_menu()
	end

	screen.flip()
	if buttons.start then break end--test
end
