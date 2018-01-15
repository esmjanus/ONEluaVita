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

local res = wlan.connect()
if res == 1 then
	hand = socket.connect("devonelua.x10.mx",80) -- Create Socket to server
	os.delay(50)
	hand:send("GET /".." HTTP/1.1\r\n".."host: ".."devonelua.x10.mx".."\r\n")-- Put request
	hand:send("User-Agent: ONElua/v1\r\n\r\n") -- Send By ONElua :D
end
local sock_data = ""
local sock_size = 0
while true do
	buttons.read() -- Read Buttons :P
	if back then back:blit(0,0) end
	
	screen.print(10,10,"Socket Sample ONElua | sock: "..tostring(hand).." | len: "..sock_size)
	screen.print(10,30,"recv: "..tostring(sock_data))
	if hand then
		local tmp_val,tmp_byte = hand:recv(1) -- read from server 1 byte by step :D
		sock_data = sock_data..tmp_val
		sock_size += tmp_byte
	end

	screen.flip() -- Show Buff

	if buttons.released.start then
		if hand then hand:close() end
		break
	end
end
