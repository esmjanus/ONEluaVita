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
if not ch then error("Can not create #1 channel :(") end
hand,res = thread.new("samples/thethread.lua","Any arg? xD!")
local val = "---"
local icon = nil
while true do
	if back then back:blit(0,0) end
	buttons.read()
	screen.print(480,10,"Thread & Channel Sample",1,color.white,color.blue,__ACENTER) -- Titulo
	screen.print(10,30,"Handle: "..tostring(hand).." | res: "..tostring(res).." | status: "..tostring(hand:state()),1,color.white,color.black)
	if hand and thread.state(hand) == -1 then
		screen.print(10,50,"MSG Error Thread:",1,color.white,color.black)
		screen.print(10,70,tostring(thread.geterror(hand)),1,color.white,color.black)
	end
	screen.print(10,90,"Channel Available: "..tostring(channel.available(ch)),1,color.white,color.black)
	local tmp = channel.pop(chs)
	if tmp then icon = image.loadfromdata(tmp,__PNG) end
	tmp = ch:pop()
	--channel.clear(ch)
	if tmp != nil then val += "\n"+tmp end
	screen.print(10,110,"Channel Datos:\n"..tostring(val),1,color.white,color.black)
	
	if icon then icon:scale(200)icon:blit(10,230) end

	screen.flip()
	if buttons.start then break end
end