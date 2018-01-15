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

function onNetGetFile(size,written,speed)
	if back then back:blit(0,0) end
	screen.print(10,10,"Downloading...")
	screen.print(10,30,"Size: "..tostring(size).." Written: "..tostring(written).." Speed: "..tostring(speed).."Kb/s")
	screen.print(10,50,"Percent: "..math.floor((written*100)/size).."%")
	draw.fillrect(0,520,((written*960)/size),24,color.new(0,255,0))
	screen.flip()
	buttons.read()
	if buttons.circle then	return 0 end --Cancel or Abort
	return 1;
end

function onNetPutFile(size,written,speed)
	if back then back:blit(0,0) end
	screen.print(10,10,"Uploading...")
	screen.print(10,30,"Size: "..tostring(size).." Written: "..tostring(written).." Speed: "..tostring(speed).."Kb/s")
	screen.print(10,50,"Percent: "..math.floor((written*100)/size).."%")
	draw.fillrect(0,520,((written*960)/size),24,color.new(0,255,0))
	screen.flip()
	buttons.read()
	if buttons.circle then	return 0 end --Cancel or Abort
	return 1;
end

color.loadpalette() -- Load Defaults colors
res = wlan.connect()
getfile_ret = nil
get_red = nil
while true do
	buttons.read() -- Read Buttons :P

	if back then back:blit(0,0) end
	if imgnet then 
		imgnet:blit(960-480,0)
	end

	screen.print(10,10,"Http Sample ONElua")
	screen.print(10,30,"wlan.connect(): "..tostring(res))
	screen.print(10,50,"wlan.isconnected(): "..tostring(wlan.isconnected()))
	screen.print(10,70,"http.getfile(): "..tostring(getfile_ret))
	screen.print(10,90,"http.get(): "..tostring(get_red))
	screen.print(10,110,"Press cross to download GekiHEN logo in ux0")
	screen.print(10,130,"Press square to download and load GekiHEN header.")

	screen.flip() -- Show Buff

	if buttons.cross then
		getfile_ret = http.getfile("http://gekihen.customprotocol.com/images/gekihen-splash-screen-by-windvern.png","ux0:/gekigen.png")
	end

	if buttons.square then
		databin,datasize,get_red = http.get("http://gekihen.customprotocol.com/images/GekiHEN-logo-header.png")
		if databin then
			imgnet = image.loadfromdata(databin,__PNG)
		end
	end
	if buttons.released.start then
		imgnet, databin = nil,nil
		break
	end
end
