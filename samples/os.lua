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
local devuxo = os.devinfo("ux0:/")
local args = "" -- Clean value
bri = 200
master=os.access()
while true do
	if back then back:blit(0,0) end
	buttons.read()

	screen.print(10,10,"Software Sample ONElua")
	if master == 1 then
		screen.print(10,30,"os.access(): Access Total (Unsafe mode)",1,color.green)
	else
		w=screen.print(10,30,"os.access(): Access Limit (Safe mode)",1,color.red)
		screen.print(w+20,30,"Press X to enable full access")
	end

	screen.print(10,50,"os.language(): "..tostring(os.language()))
	screen.print(10,70,"os.nick(): "..tostring(os.nick()))
	screen.print(10,90,"os.cpu(): "..tostring(os.cpu()))
	screen.print(10,110,"os.busclock(): "..tostring(os.busclock()))
	screen.print(10,130,"os.gpuclock(): "..tostring(os.gpuclock()))
	screen.print(10,150,"os.crossbarclock(): "..tostring(os.crossbarclock()))
	screen.print(10,170,"os.swversion(): "..tostring(os.swversion()).." os.spoofedversion(): "..tostring(os.spoofedversion()))
	screen.print(10,190,"os.mac(): "..tostring(os.mac()))
	screen.print(10,210,"os.login(): "..tostring(os.login()))
	screen.print(10,230,"os.password(): "..tostring(os.password()))
	screen.print(10,250,"os.psnregion(): "..tostring(os.psnregion()))
	screen.print(10,270,"os.idps(): "..tostring(os.idps()))
	screen.print(10,290,"os.psid(): "..tostring(os.psid()))
	screen.print(10,310,"os.account(): "..tostring(os.account()))

	if devuxo then
		screen.print(10,330,"os.devinfo(): ".." Size Max "..files.sizeformat(devuxo.max).." Size Free "..files.sizeformat(devuxo.free).." Size Used "..files.sizeformat(devuxo.used))
	end
	screen.print(10,350,"os.totalram(): "..files.sizeformat(os.totalram()) .. " | os.ram(): "..files.sizeformat(os.ram()))
	screen.print(10,370,"os.titleid(): "..tostring(os.titleid()))

	local tmp_args = os.arg() -- Read the tail of args.
	if #tmp_args > 0 then -- if get any new args update value global
		args = tmp_args
	end

	screen.print(10,390,"os.arg(): "..tostring(args))
	screen.print(10,440,"Press L for launch Web Docu Online ONELUA")
	screen.print(10,460,"Press Triangle for os.message()")

	screen.print(10,480,"screen.brightness(): "..tostring(screen.brightness().."%").." bri: "..bri)
	screen.print(10,500,"Press <- or -> change the brightness")
	screen.print(10,520,"Press [] to restart ONElua")

	screen.flip()
	
	if buttons.held.right or buttons.held.left then
		if buttons.held.right then bri += 10
		elseif buttons.held.left then bri -= 10 end

		if bri > 65536 then bri = 21 end
		if bri < 21 then bri = 65536 end
		screen.brightness(bri)
	end

	if buttons.cross and master==1 then
		if os.master() == 1 then
			os.restart()
		end
	end

	if buttons.triangle then os.message("Hello From Box :D") end

	if buttons.released.l then
		os.browser("http://onelua.x10.mx/")
	end

	if buttons.released.square then os.restart() end

	if buttons.released.start then break end -- back to main

end
