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

--[[
	__GAME_LIST_ALL
	__GAME_LIST_PSPEMU
	__GAME_LIST_APP
	__GAME_LIST_SYS
]]
local type = __GAME_LIST_ALL
local over = 1
local icons = {}
local list = {}

function fillResources()
	list = game.list(type)
	table.sort(list ,function (a,b) return string.lower(a.title)<string.lower(b.title); end)
	list.len = #list
	for i=1,list.len do
		if list[i].dev == "ux0:" then list[i].flag = 0
		elseif list[i].dev == "ur0:" then list[i].flag = 1
		elseif list[i].dev == "uma0:" then list[i].flag = 3
		end
		
		if not icons[list[i].id] then
			local img = nil
			if list[i].type:upper() == "EG" then
				img = game.geticon0(string.format("%s/eboot.pbp",list[i].path))
			else
				img = image.load("ur0:appmeta/"..list[i].id.."/icon0.png")
			end
			icons[list[i].id] = img
		end
		
	end
end

fillResources();

while true do
	buttons.read()
	if back then back:blit(0,0) end

	screen.print(480,10,"Game Manager (Apps - Bubbles)",1,color.white,color.blue,__ACENTER)
	screen.print(950,10,"Count: " .. list.len,1,color.red,0x0,__ARIGHT)

	if list.len > 0 then

		if buttons.up and over > 1 then over -= 1 end
		if buttons.down and over < list.len then over += 1 end

		
		if buttons.cross then game.launch(list[over].id) end

		if buttons.square then
			if os.message("Really wish remove/uninstall "+ list[over].id + "?",1) == 1 then
				result_rmv = game.delete(list[over].id)
				if result_rmv == 1 then
					table.remove(list, over)
					table.remove(icons, over)
					over = math.max(over-1, 1)
					list.len -= 1
				end
			end
		end

		if icons[list[over].id] then
			screen.clip(950-64,35+64, 128/2)
			icons[list[over].id]:center()
			icons[list[over].id]:blit(950-128 + 64,35 + 64)
			screen.clip()
		else
			draw.fillrect(950-128,35, 128, 128, color.white:a(100))
			draw.rect(950-128,35, 128, 128, color.white)
		end

		local y = 35
		for i=over,math.min(list.len,over+19) do
			if i == over then
				screen.print(10,y,"->")
			end
			screen.print(40, y, '#'..string.format("%03d",i))
			screen.print(114, y, (list[i].title or "unk"))
			
			local x = 400
			x+=screen.print(x,y,list[i].dev or "unk",1,color.green)
			
			x+=20
			x+=screen.print(x,y,list[i].version or "unk",1,color.blue)
			
			x+=20
			x+=screen.print(x,y,list[i].type or "unk",1,color.blue)
			
			x+=20
			x+=screen.print(x,y,list[i].id or "unk")
			
			y += 20
		end

		screen.print(10,484,"Press X to launch " .. list[over].id)
		screen.print(10,504,"Press [] to remove " .. list[over].id .. " - result: " .. tostring(result_rmv))

	else
		screen.print(10,30,"Any o error?")
	end

	screen.flip()

	if buttons.released.start then break end
end
