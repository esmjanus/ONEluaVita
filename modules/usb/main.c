/*
	VitaShell
	Copyright (C) 2015-2018, TheFloW
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
	ONElua.
	Lua Interpreter for PlayStation®Vita.
	
	Licensed by GNU General Public License v3.0
	
	Copyright (C) 2014-2018, ONElua Team
	http://onelua.x10.mx/staff.html
	
	Designed By:
	- DevDavisNunez (https://twitter.com/DevDavisNunez).
	- Gdljjrod (https://twitter.com/gdljjrod).
*/

#include <vitasdk.h>
#include <taihen.h>

//Lua
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

// Un-Mount- Memory
int vshIoUmount(int id, int a2, int a3, int a4);
int _vshIoMount(int id, const char *path, int permission, void *buf);
int vshIoMount(int id, const char *path, int permission, int a4, int a5, int a6);
void remount(int id);

#include "./resources/patch_prx.h"
#define PATH_PATCH_PRX "ux0:data/patch_prx.skprx"

#include "./resources/usbdevice_skprx.h"
#define PATH_USB_SKPRX "ux0:data/usbdevice.skprx"

static SceUID usbdevice_modid = -1;

int checkFileExist(const char *file){
	SceUID fd = sceIoOpen(file, SCE_O_RDONLY, 0);
	if (fd < 0)
		return 0;

	sceIoClose(fd);
	return 1;
}

int checkFolderExist(const char *folder){
	SceUID dfd = sceIoDopen(folder);
	if (dfd < 0)
		return 0;

	sceIoDclose(dfd);
	return 1;
}

int vshIoMount(int id, const char *path, int permission, int a4, int a5, int a6) {
	uint32_t buf[3];

	buf[0] = a4;
	buf[1] = a5;
	buf[2] = a6;

	return _vshIoMount(id, path, permission, buf);
}

void remount(int id) {
	vshIoUmount(id, 0, 0, 0);
	vshIoUmount(id, 1, 0, 0);
	vshIoMount(id, NULL, 0, 0, 0, 0);
}

SceUID usbRunPatchPrx(){
	SceUID fd = sceIoOpen(PATH_PATCH_PRX, SCE_O_WRONLY | SCE_O_CREAT | SCE_O_TRUNC, 0777);
	if(fd < 0) return 0;
	
	if(sceIoWrite(fd, patch_prx, size_patch_prx) != size_patch_prx) {
		sceIoClose(fd);
		sceIoRemove(PATH_PATCH_PRX);
		return 0;
	}
	sceIoClose(fd);

	SceUID modID = taiLoadStartKernelModule(PATH_PATCH_PRX, 0, NULL, 0);
	sceIoRemove(PATH_PATCH_PRX);
	return modID;

}

SceUID startUsb(const char *usbDevicePath, const char *imgFilePath, int type) {
	SceUID modid = -1;

	// Destroy other apps
	sceAppMgrDestroyOtherApp();

	// Load and start usbdevice module
	int res = taiLoadStartKernelModule(usbDevicePath, 0, NULL, 0);
	if (res < 0)
		goto ERROR_LOAD_MODULE;

	modid = res;

	// Stop MTP driver
	res = sceMtpIfStopDriver(1);
	if (res < 0)
		goto ERROR_STOP_DRIVER;

	// Set device information
	res = sceUsbstorVStorSetDeviceInfo("\"PS Vita\" MC", "1.00");
	if (res < 0)
		goto ERROR_USBSTOR_VSTOR;

	// Set image file path
	res = sceUsbstorVStorSetImgFilePath(imgFilePath);
	if (res < 0)
		goto ERROR_USBSTOR_VSTOR;

	// Start USB storage
	res = sceUsbstorVStorStart(type);
	if (res < 0)
		goto ERROR_USBSTOR_VSTOR;

	return modid;

ERROR_USBSTOR_VSTOR:
	sceMtpIfStartDriver(1);

ERROR_STOP_DRIVER:
	taiStopUnloadKernelModule(modid, 0, NULL, 0, NULL, NULL);

ERROR_LOAD_MODULE:
	return res;
}

int stopUsb(SceUID modid) {
	int res;

	// Stop USB storage
	res = sceUsbstorVStorStop();
	if (res < 0)
		return res;

	// Start MTP driver
	res = sceMtpIfStartDriver(1);
	if (res < 0)
		return res;

	// Stop and unload usbdevice module
	res = taiStopUnloadKernelModule(modid, 0, NULL, 0, NULL, NULL);
	if (res < 0)
		return res;

	// Remount Memory Card
	remount(0x800);

	// Remount uma0:
	if (checkFolderExist("uma0:"))
		remount(0xF00);

	return 0;
}

int usbUpdatePrx(){
	SceUID fd = sceIoOpen(PATH_USB_SKPRX, SCE_O_WRONLY | SCE_O_CREAT | SCE_O_TRUNC, 0777);
	if(fd < 0) return 0;
	
	if(sceIoWrite(fd, usbdevice_skprx, size_usbdevice_skprx) != size_usbdevice_skprx) {
		sceIoClose(fd);
		sceIoRemove(PATH_USB_SKPRX);
		return 0;
	}
	sceIoClose(fd);
	return 1;

}

static void initUsb(const char *prx_path, const char *path) {

	usbdevice_modid = startUsb(prx_path, path, SCE_USBSTOR_VSTOR_TYPE_FAT);

	if (usbdevice_modid >= 0)
		sceShellUtilLock(SCE_SHELL_UTIL_LOCK_TYPE_PS_BTN);
	else {
		sceShellUtilUnlock(SCE_SHELL_UTIL_LOCK_TYPE_PS_BTN);
		stopUsb(usbdevice_modid);
	}
	sceIoRemove(prx_path);
}

static int usb_init(lua_State *L){

	if (usbUpdatePrx() && !sceKernelIsPSVitaTV()) {

		int usbmode = 0;
		if(lua_gettop(L) == 1 )
			usbmode = CLAMP(luaL_checknumber(L,1),0,3);

		char *path = NULL;

		// 0:	USBDEVICE_MODE_MEMORY_CARD
		// 1:	USBDEVICE_MODE_GAME_CARD
		// 2:	USBDEVICE_MODE_SD2VITA
		// 3:	USBDEVICE_MODE_PSVSD
		switch(usbmode){
			case 0:
				if (checkFileExist("sdstor0:xmc-lp-ign-userext"))
					path = "sdstor0:xmc-lp-ign-userext";
				else if (checkFileExist("sdstor0:int-lp-ign-userext"))
					path = "sdstor0:int-lp-ign-userext";
			break;
			case 1:
				if (checkFileExist("sdstor0:gcd-lp-ign-gamero"))
					path = "sdstor0:gcd-lp-ign-gamero";
			break;
			case 2:
				if (checkFileExist("sdstor0:gcd-lp-ign-entire"))
					path = "sdstor0:gcd-lp-ign-entire";
			break;
			case 3:
				if (checkFileExist("sdstor0:uma-pp-act-a"))
					path = "sdstor0:uma-pp-act-a";
				else if (checkFileExist("sdstor0:uma-lp-act-entire"))
					path = "sdstor0:uma-lp-act-entire";
			break;	
		}

		if (!path){
			lua_pushnumber(L,-1);
			return 1;
		}

		SceUdcdDeviceState state;
		sceUdcdGetDeviceState(&state);
		if (	(state.state & SCE_UDCD_STATUS_ACTIVATED) &&
			(state.cable & SCE_UDCD_STATUS_CABLE_CONNECTED) &&
			(state.connection & SCE_UDCD_STATUS_CONNECTION_ESTABLISHED)
		)
			initUsb(PATH_USB_SKPRX, path);
	}

	return 0;
}

static int usb_actived(lua_State *L){
	SceUdcdDeviceState state;
	sceUdcdGetDeviceState(&state);
	if (	(state.state & SCE_UDCD_STATUS_ACTIVATED) &&
			(state.cable & SCE_UDCD_STATUS_CABLE_CONNECTED) &&
			(state.connection & SCE_UDCD_STATUS_CONNECTION_ESTABLISHED)
		)
		lua_pushnumber(L,1);
	else
		lua_pushnumber(L,0);
	return 1;
}

static int usb_state(lua_State *L){
	SceUdcdDeviceState state;
	sceUdcdGetDeviceState(&state);
	if (state.connection & SCE_UDCD_STATUS_CONNECTION_ESTABLISHED)
		lua_pushnumber(L,1);
	else
		lua_pushnumber(L,0);
	return 1;
}

static int usb_cable(lua_State *L){
	SceUdcdDeviceState state;
	sceUdcdGetDeviceState(&state);
	if (state.cable & SCE_UDCD_STATUS_CABLE_CONNECTED)
		lua_pushnumber(L,1);
	else
		lua_pushnumber(L,0);
	return 1;
}

static int usb_term(lua_State *L){
	if (usbdevice_modid >= 0) {
		sceShellUtilUnlock(SCE_SHELL_UTIL_LOCK_TYPE_PS_BTN);
		stopUsb(usbdevice_modid);
	}
	return 0;
}

static const luaL_reg usb_functions[] = {
	{"start", usb_init},
	{"stop", usb_term},
	{"state", usb_state},
	{"cable", usb_cable},
	{"actived", usb_actived},
	{0,0}
};

void _start() __attribute__ ((weak, alias ("module_start")));

int module_start(SceSize argc, const void *args) {
	lua_State *L = *(lua_State**)args;
	luaL_register(L, "usb", usb_functions);
	
	usbRunPatchPrx();

	return SCE_KERNEL_START_SUCCESS;

}

int module_stop(SceSize argc, const void *args) {
	return SCE_KERNEL_STOP_SUCCESS;
}

// Thanks to xerpi for this solution "newlib issue"!
int _free_vita_newlib() {
	return 0;
}

int _fini(){
	return 0;
}
