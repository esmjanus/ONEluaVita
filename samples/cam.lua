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

local resolution = 1
local resolutions = {
	{ res= __CAM_RES_VGA, 	w=640, h=480 },		--	640_480);	Dont work cam.zoom()
	{ res= __CAM_RES_QVGA, 	w=320, h=240 },		--	320_240);	//120fps	cam.zoom(1.0x - 2.0x) only 60fps
	{ res= __CAM_RES_QQVGA, w=160, h=120 },		--	160_120);	//120fps	cam.zoom(1.0x - 3.2x) only 60fps
	{ res= __CAM_RES_CIF, 	w=352, h=288 },		--	352_288);	//120fps	cam.zoom(1.0x - 1.6x) only 60fps
	{ res= __CAM_RES_QCIF, 	w=176, h=144 },		--	176_144);	cam.zoom(1.0x - 3.2x)
	{ res= __CAM_RES_PSP, 	w=480, h=272 },		--	480_272);	cam.zoom(1.0x - 1.3x)
	{ res= __CAM_RES_NGP, 	w=640, h=360 },		--	640_360);	Dont work cam.zoom()
}

local res = cam.init(__CAM_REAR,resolutions[resolution].res,60)
cam.sharpness(400)

local bright,contrast,zoom = cam.brightness(),cam.contrast(),cam.zoom()
local fx_mode = {"Normal", "Negative", "Gray Scale", "Sepsia","Blue | Cyan","Red | Magenta","Green"}
local iso_mode,iso = {1,100,200,400,800},1
local ev_level,EV = {-2.0,-1.7,-1.5,-1.3,-1.0,-0.7,-0.5,-0.3, 0.0, 0.3,0.5,0.7,1.0,1.3,1.5,1.7,2.0},1
local sat_level,sat = {0.0,0.5,1.0,2.0,3.0,4.0},1
local wb = { "Automatic","Daylight","Cool White","Stand Light"}

while true do
	buttons.read() -- Read Buttons :P
	
	--Blit Output
	cam.render(10,30)

	screen.print(10,10,"Camera Sample ONElua - ".."FPS: "..tostring(screen.fps()))

	screen.print(13+resolutions[resolution].w,30,"cam.init(): "..tostring(res))
	if cam.state(__CAM_FRONT) then
		screen.print(13+resolutions[resolution].w,50,"State: Front")
	elseif cam.state(__CAM_REAR) then
		screen.print(13+resolutions[resolution].w,50,"State: Back")
	end

	screen.print(13+resolutions[resolution].w,90,"Up/Down Effect: "..tostring(fx_mode[cam.effect()]))			--ok
	screen.print(13+resolutions[resolution].w,110,"Left/Right brightness: "..tostring(cam.brightness()))--0,255									--ok
	screen.print(13+resolutions[resolution].w,130,"L/R Whitebalance: "..tostring(wb[cam.whitebalance()]))--tostring(cam.whitebalance()))											--ok

	screen.print(13+resolutions[resolution].w,170,"Hold Triangle")
	screen.print(13+resolutions[resolution].w,190,"Up/Down Contrast: "..tostring(cam.contrast()))--0,255								--ok
	screen.print(13+resolutions[resolution].w,210,"Left/Right Zoom: "..tostring(cam.zoom()).." | "..tostring(zoom))
	screen.print(13+resolutions[resolution].w,230,"L/R Saturation: "..tostring(cam.saturation()).." | "..tostring(sat_level[sat]))	--ok

	screen.print(13+resolutions[resolution].w,270,"Hold Square")
	screen.print(13+resolutions[resolution].w,290,"Up/Down Nightmode(): "..tostring(cam.nightmode()))									--ok
	screen.print(13+resolutions[resolution].w,310,"Left/Right Evlevel(): "..tostring(cam.evlevel()).." | "..tostring(ev_level[EV]))		--ok
	screen.print(13+resolutions[resolution].w,330,"L/R ISO: "..tostring(cam.iso()).." | "..tostring(iso_mode[iso]))

	screen.print(13+resolutions[resolution].w,370,"Hold Circle")
	screen.print(13+resolutions[resolution].w,390,"Up/Down Mirror: "..tostring(cam.mirror()))											--ok
	screen.print(13+resolutions[resolution].w,410,"Left/Right Flicker: "..tostring(cam.flicker()))										--ok
	screen.print(13+resolutions[resolution].w,430,"L/R Backlight: "..tostring(cam.backlight()))

	screen.print(13+resolutions[resolution].w,490,"Hold L + R scan QR code")

	screen.print(10,518,"Press SELECT to change camera frontal/back")

	screen.flip(0x64330066) -- Show Buff

	if buttons.select then cam.toggle() end

	if buttons.cross then
		cam.shot("ux0:/ONElua_ShotCamera.png",1)
		if files.exists("ux0:/ONElua_ShotCamera.png") then
			local tmp = image.load("ux0:/ONElua_ShotCamera.png")
			if tmp then
				tmp:blit(0,0)
				screen.flip()
				buttons.waitforkey() 
			end
		end
	end

	if not buttons.held.triangle and not buttons.held.square and not buttons.held.circle then

		if buttons.up then cam.effect(cam.effect()-1) elseif buttons.down then cam.effect(cam.effect()+1) end
	
		if buttons.left and bright > 0 then bright -= 1 cam.brightness(bright)
		elseif buttons.right and bright < 255 then bright += 1 cam.brightness(bright) end

		if buttons.l then cam.whitebalance(cam.whitebalance()-1) elseif buttons.r then cam.whitebalance(cam.whitebalance()+1) end

		if buttons.held.l and buttons.held.r then
			os.message(tostring(cam.scanqr("QR Code")))
		end

	end

	if buttons.held.triangle then
		if buttons.up and contrast > 0 then contrast -= 1 cam.contrast(contrast)
		elseif buttons.down and contrast < 255 then contrast += 1 cam.contrast(contrast) end

		if buttons.left and zoom > 10 then zoom -= 1 cam.zoom(zoom)
		elseif buttons.right and zoom < 32 then zoom += 1 cam.zoom(zoom) end

		if buttons.l and sat > 1 then sat -= 1 cam.saturation(sat_level[sat])
		elseif buttons.r and sat < #sat_level then sat += 1 cam.saturation(sat_level[sat]) end

	end


	if buttons.held.square then

		if buttons.up then cam.nightmode(cam.nightmode()-1)
		elseif buttons.down then cam.nightmode(cam.nightmode()+1) end

		if buttons.left and EV > 1 then EV -= 1 cam.evlevel(ev_level[EV])
		elseif buttons.right and EV < #ev_level then EV += 1 cam.evlevel(ev_level[EV]) end

		if buttons.l and iso > 1 then iso -= 1 cam.iso(iso_mode[iso])
		elseif buttons.r and iso < #iso_mode then iso += 1 cam.iso(iso_mode[iso]) end

	end


	if buttons.held.circle then
		if buttons.up then cam.mirror(cam.mirror()-1)
		elseif buttons.down then cam.mirror(cam.mirror()+1)	end

		if buttons.left then cam.flicker(cam.flicker()-1)
		elseif buttons.right then cam.flicker(cam.flicker()+1) end

		if buttons.l then cam.backlight(cam.backlight()-1)
		elseif buttons.r then cam.backlight(cam.backlight()+1) end

	end

	if buttons.released.start then	break end -- back to main

end

cam.term()
