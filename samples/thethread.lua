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

local ch = channel.new("test");
local chs = channel.new("test2");
if not ch or not chs then error("Can not create canal! :(") end

gadget = {
	header = "",
	datarecv = "",
	mode = 0,
	xscroll = 0,
	alfaimg = 0,
	data = {},
	geoid = 55487,
	}

function onNetGetFile(size, written)
	channel.push(ch,"size: " + tostring(size) + " - " + "written: " + tostring(written))
end
local databin,datasize,get_red = http.get("http://devonelua.x10.mx/clima.php?id="..gadget.geoid)
if databin then
local tempdata = string.explode(databin,"&")
gadget.data = {ciudad = tempdata[1] or "Unk city", grados = tempdata[2] or "unk grados", detalles = tempdata[3] or "unk details", icon = tempdata[4] or "1"}
channel.push(ch, gadget.data.ciudad .. "\n" .. gadget.data.grados.."\n"..gadget.data.detalles)
databin,datasize,get_red = http.get("http://i5.tutiempo.net/wi/01/70/"+gadget.data.icon+".png")
if databin then
channel.push(chs, databin)
end
end
return 0;--true