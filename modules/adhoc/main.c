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
#include <vita2d.h>
#include <taihen.h>

//Lua
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#define NETCHECK_DIALOG_RESULT_NONE 0
#define NETCHECK_DIALOG_RESULT_RUNNING 1
#define NETCHECK_DIALOG_RESULT_FINISHED 2
#define NETCHECK_DIALOG_RESULT_CONNECTED 3
#define NETCHECK_DIALOG_RESULT_NOT_CONNECTED 4

#define DEBUG(...)

#define SOCKET_BUFSIZE 128 * 1024
#define SHARE_SIZE 4096
#define RECEIVE_WAIT 100 * 1000

#define PEERLIST_MAX 4

static char IdTitle[12] = "";
static char recvBuff[SOCKET_BUFSIZE];

static int DeviceMode = SCE_NETCHECK_DIALOG_MODE_PSP_ADHOC_JOIN;

static SceNetAdhocctlPeerInfo  peer_list[PEERLIST_MAX];
static int peer_count = 0;

static SceNetAdhocctlPeerInfo server_peer_info;
static SceNetEtherAddr client_addr, server_addr;
static int client_socket = -1, server_socket = -1;
static SceUID client_waiting_thid = -1;
static int server_request_result = 0;

void adhocTerm();

void adhocAlertSockets() {
  if (client_socket >= 0)
    sceNetAdhocSetSocketAlert(client_socket, SCE_NET_ADHOC_F_ALERTALL);

  if (server_socket >= 0)
    sceNetAdhocSetSocketAlert(server_socket, SCE_NET_ADHOC_F_ALERTALL);  
}

void adhocCloseSockets(){
  adhocAlertSockets();

  if (client_waiting_thid >= 0) {
    sceKernelWaitThreadEnd(client_waiting_thid, NULL, NULL);
    client_waiting_thid = -1;
  }

  if (client_socket >= 0) {
    sceNetAdhocPtpClose(client_socket, 0);
    client_socket = -1;
  }

  if (server_socket >= 0) {
    sceNetAdhocPtpClose(server_socket, 0);
    server_socket = -1;
  }
}

int client_waiting_thread(SceSize args, void *argp) {
	// Create PTP socket and wait for connection
	sceNetAdhocctlGetEtherAddr(&client_addr);
	client_socket = sceNetAdhocPtpListen(&client_addr, 1, SOCKET_BUFSIZE, RECEIVE_WAIT, 50, 1, 0);
	if (client_socket < 0) {
		server_request_result = client_socket;
		goto EXIT;
	}
	
	// Establish PTP connection
	SceUShort16 server_port;
	server_socket = sceNetAdhocPtpAccept(client_socket, &server_addr, &server_port, 0, 0);
	if (server_socket < 0) {
		server_request_result = server_socket;
		goto EXIT;
	}
	
	// Check if we have successfully received a request from a server
	int res = sceNetAdhocctlGetPeerInfo(&server_addr, sizeof(SceNetAdhocctlPeerInfo), &server_peer_info);
	if (res < 0) {
		server_request_result = res;
		goto EXIT;
	}
	
	server_request_result = 1;
	
EXIT:
	return sceKernelExitDeleteThread(0);
}

// BOOLEAN adhoc.init(mode, timeout)
static int adhoc_init(lua_State *L){
	DEBUG("adhoc.init()\n");
	if(sceSysmoduleIsLoaded(SCE_SYSMODULE_PSPNET_ADHOC) == SCE_SYSMODULE_LOADED){ // Previus Load return Ok!
		lua_pushboolean(L, 1);
		return 1;
	}
	int res = sceSysmoduleLoadModule(SCE_SYSMODULE_PSPNET_ADHOC);
	DEBUG("0x%08X sceSysmoduleLoadModule(SCE_SYSMODULE_PSPNET_ADHOC)\n", res);

	res = sceNetAdhocInit();
	DEBUG("0x%08X sceNetAdhocInit()\n", res);

	SceNetAdhocctlAdhocId adhocId;
	memset(&adhocId, 0, sizeof(SceNetAdhocctlAdhocId));
	adhocId.type = SCE_NET_ADHOCCTL_ADHOCTYPE_RESERVED;
	memcpy(&adhocId.data[0], IdTitle, SCE_NET_ADHOCCTL_ADHOCID_LEN);
	res = sceNetAdhocctlInit(&adhocId);
	DEBUG("0x%08X sceNetAdhocctlInit()\n", res);

	SceNetCheckDialogParam param;
	sceNetCheckDialogParamInit(&param);

	SceNetAdhocctlGroupName groupName;
	memset(groupName.data, 0, SCE_NET_ADHOCCTL_GROUPNAME_LEN);
	param.groupName = &groupName;
	memcpy(&param.npCommunicationId.data, IdTitle, 9);
	param.npCommunicationId.term = '\0';
	param.npCommunicationId.num = 0;
	param.mode = luaL_checkint(L,1);//mode;
	DeviceMode = luaL_checkint(L,1);
	if(lua_isnumber(L,2) && luaL_checkint(L,1) == SCE_NETCHECK_DIALOG_MODE_PSP_ADHOC_JOIN) // User set timeout client
		param.timeoutUs = luaL_checkint(L,2); //timeoutUs;
	else if(luaL_checkint(L,1) == SCE_NETCHECK_DIALOG_MODE_PSP_ADHOC_JOIN) // Default timeout client
		param.timeoutUs = 10 * 1000 * 1000;
	else // Server
		param.timeoutUs = 0;
	
	res = sceNetCheckDialogInit(&param);
	DEBUG("0x%08X | %d sceNetCheckDialogInit()\n", res, res);
	if(res >= 0){
		SceCommonDialogStatus status = NETCHECK_DIALOG_RESULT_RUNNING;
		while(1){
			vita2d_end_drawing();
			vita2d_common_dialog_update();
			vita2d_swap_buffers();
			sceDisplayWaitVblankStart();
			vita2d_start_drawing();
			vita2d_clear_screen();
			
			status = sceNetCheckDialogGetStatus();

			if (status == NETCHECK_DIALOG_RESULT_FINISHED) {
				SceNetCheckDialogResult result;
				memset(&result, 0, sizeof(SceNetCheckDialogResult));
				sceNetCheckDialogGetResult(&result);
				
				if (result.result == SCE_COMMON_DIALOG_RESULT_OK) {
					status = NETCHECK_DIALOG_RESULT_CONNECTED;
				} else {
					status = NETCHECK_DIALOG_RESULT_NOT_CONNECTED;
				}
				
				sceNetCheckDialogTerm();
				break;
			}
		}
		DEBUG("0x%08X | %d sceNetCheckDialogGetStatus()\n", status, status);
		if(status == NETCHECK_DIALOG_RESULT_CONNECTED){
			lua_pushboolean(L, 1);
			return 1;
		}
	}
	adhocTerm();
	lua_pushboolean(L, 0);
	lua_pushnumber(L, res);
	return 2;
}

// TABLE adhoc.scan()
static int adhoc_scan(lua_State *L){
	DEBUG("adhoc.scan()\n");
	// Reset
	memset(peer_list, 0, PEERLIST_MAX * sizeof(SceNetAdhocctlPeerInfo));
	peer_count = 0;

	int res = -1, buflen = 0;
	buflen = PEERLIST_MAX * sizeof(SceNetAdhocctlPeerInfo);
	res = sceNetAdhocctlGetPeerList(&buflen, peer_list);
	peer_count = buflen / sizeof(SceNetAdhocctlPeerInfo);
	DEBUG("0x%08X sceNetAdhocctlGetPeerList() %d\n", res, buflen);
	DEBUG("peer_count: %d\n", peer_count);

	if (peer_count > 0) {
		SceNetAdhocctlPeerInfo *curr = peer_list;
		char temp[20];
		lua_newtable(L);
		for (int i=0; i < peer_count; i++){
			if(curr){
				lua_pushnumber(L,i+1);
				lua_newtable(L);

					lua_pushstring(L, (char *)curr->nickname.data);
					lua_setfield(L,-2,"name");

					sprintf(temp, "%02X:%02X:%02X:%02X:%02X:%02X", curr->macAddr.data[0], curr->macAddr.data[1], curr->macAddr.data[2], curr->macAddr.data[3], curr->macAddr.data[4], curr->macAddr.data[5]);
					//sceNetEtherNtostr(&curr->macAddr, temp, sizeof(SceNetEtherAddr));
					lua_pushstring(L, temp);
					lua_setfield(L,-2,"mac");
					
					lua_pushstring(L, (char *)curr->macAddr.data);
					lua_setfield(L,-2,"addr");

					/*lua_pushnumber(L, );
					lua_setfield(L,-2,"state");*/

				lua_settable(L,-3);

				curr = curr->next;
			}
		}
		return 1;
	}
	return 0;
}

//NUMBER adhoc.available
static int adhoc_available(lua_State *L){
	lua_pushnumber(L, peer_count);
	return 1;
}

int adhocSend(int socket, const void *buf, int size) {
  return sceNetAdhocPtpSend(socket, buf, &size, 0, 0);
}

// NUMBER adhoc.send(STRING data, [NUMBER len])
static int adhoc_send(lua_State *L){
	size_t size;
	const char *data = luaL_checklstring(L, 1, &size);

	if(lua_isnumber(L,2))
		size = luaL_checknumber(L,2);
	int res = 0;
	if(DeviceMode == SCE_NETCHECK_DIALOG_MODE_PSP_ADHOC_CONN && (server_socket >= 0)){ // Server
		res = adhocSend(server_socket, (void*)data, size);
	} else if(DeviceMode == SCE_NETCHECK_DIALOG_MODE_PSP_ADHOC_JOIN && (client_socket >= 0)) { // Client
		res = adhocSend(client_socket, (void*)data, size);
	}
	if (res <=0) res=0;
	lua_pushnumber(L, res);
	return 1;
}

int adhocRecv(int socket, void *buf, int *size) {
  return sceNetAdhocPtpRecv(socket, buf, size, 0, SCE_NET_ADHOC_F_NONBLOCK);
}

// STRING, NUMBER adhoc.recv([NUMBER len])
static int adhoc_recv(lua_State *L){
	int size = 1024;
	if(lua_isnumber(L,1))
		size = luaL_checknumber(L,1);

	char *data = recvBuff;//malloc(size); // in prx you can not use malloc / free.
	int res = -1;
	if(DeviceMode == SCE_NETCHECK_DIALOG_MODE_PSP_ADHOC_CONN && (server_socket >= 0)){ // Server
		res = adhocRecv(server_socket, (void*)data, &size);
	} else if(DeviceMode == SCE_NETCHECK_DIALOG_MODE_PSP_ADHOC_JOIN && (client_socket >= 0)) { // Client
		res = adhocRecv(client_socket, (void*)data, &size);
	}
	if(res == 0){
		lua_pushlstring(L, data, size);
		lua_pushnumber(L, size);
	} else {
		lua_pushstring(L, "");
		lua_pushnumber(L, 0);
	}
	//free(data);
	return 2;
}

// BOOLEAN adhoc.request(STRING addr)
static int adhoc_request(lua_State *L){
	size_t size;
	const char *data = luaL_checklstring(L, 1, &size);
	memcpy(&client_addr, data, sizeof(SceNetEtherAddr));
	// Create PTP socket and start connection
	sceNetAdhocctlGetEtherAddr(&server_addr);
	client_socket = sceNetAdhocPtpOpen(&server_addr, 0, &client_addr, 1, SOCKET_BUFSIZE, RECEIVE_WAIT, 50, 0);
	if (client_socket < 0) {
		sceNetCtlAdhocDisconnect();
		//errorDialog(client_socket);
		lua_pushboolean(L, 0);
		return 1;
	}
	lua_pushboolean(L, 1);
	return 1;
}

// BOOLEAN adhoc.getrequest()
static int adhoc_getconnectionrequest(lua_State *L){
	if(DeviceMode == SCE_NETCHECK_DIALOG_MODE_PSP_ADHOC_CONN && client_waiting_thid < 0){ // TO-DO: add support to reopen.
		server_request_result = 0;
		client_waiting_thid = sceKernelCreateThread("client_waiting_thread", client_waiting_thread, 0x10000100, 0x4000, 0, 0, NULL);
		if (client_waiting_thid >= 0)
			sceKernelStartThread(client_waiting_thid, 0, NULL);
	}
	((server_request_result == 1) ? lua_pushboolean(L,1) : lua_pushboolean(L,0));
	return 1;
}

// No added functionality yet
static int adhoc_acceptconnection(lua_State *L){
	//This can be enable using a mutex and check the info of the thread!
	return 0;
}

//No added functionality yet
static int adhoc_rejectconnection(lua_State *L){
	//This can be enable using a mutex and check the info of the thread!
	return 0;
}


int trickNet(SceSize args, void *argp){
	sceKernelDelayThread(1*1000*1000); // 1s // Avoid the dialogue that warns the use of WiFi in AdHoc. 
	int tmplId = -1, connId = -1, reqId = -1, res = -1;
	tmplId = sceHttpCreateTemplate("OSL-agent/0.0.1 libhttp/1.0.0", SCE_HTTP_VERSION_1_1, SCE_TRUE);
	if (tmplId < 0)
		goto ERROR_EXIT;
	connId = sceHttpCreateConnectionWithURL(tmplId, "https://www.google.com", SCE_TRUE);
	if (connId < 0)
		goto ERROR_EXIT;
	reqId = sceHttpCreateRequestWithURL(connId, SCE_HTTP_METHOD_GET, "https://www.google.com", 0);
	if (reqId < 0)
		goto ERROR_EXIT;
	res = sceHttpSendRequest(reqId, NULL, 0);
	if (res < 0)
		goto ERROR_EXIT;
	
	ERROR_EXIT:
	if (reqId >= 0)
		sceHttpDeleteRequest(reqId);
	if (connId >= 0)
		sceHttpDeleteConnection(connId);
	if (tmplId >= 0)
		sceHttpDeleteTemplate(tmplId);
	
	return sceKernelExitDeleteThread(0);
}

void adhocTerm(){
	if(sceSysmoduleIsLoaded(SCE_SYSMODULE_PSPNET_ADHOC) == SCE_SYSMODULE_LOADED){
		adhocCloseSockets();
		sceNetCtlAdhocDisconnect();
		sceNetAdhocctlTerm();
		sceNetAdhocTerm();
		sceSysmoduleUnloadModule(SCE_SYSMODULE_PSPNET_ADHOC);
		SceUID trickNet_thid = sceKernelCreateThread("trickNet_thread", trickNet, 0x10000100, 0x4000, 0, 0, NULL);
		if (trickNet_thid >= 0)
			sceKernelStartThread(trickNet_thid, 0, NULL);
	}
}

static int adhoc_term(){
	adhocTerm();
	return 0;
}

static int adhoc_getmac(lua_State *L){
	static SceNetEtherAddr mac;
	sceNetGetMacAddress(&mac, 0);
	char MacAddr[32] = "XX:XX:XX:XX:XX:XX";
	sprintf(MacAddr, "%02X:%02X:%02X:%02X:%02X:%02X", mac.data[0], mac.data[1], mac.data[2], mac.data[3], mac.data[4], mac.data[5]);
	lua_pushstring(L, MacAddr);
	return 1;
}

static const luaL_Reg adhoc_functions[] = {
	{"init",adhoc_init},
	{"scan",adhoc_scan},
	{"available",adhoc_available},
	{"sendrequest",adhoc_request},
	{"getrequest",adhoc_getconnectionrequest},
	{"accept",adhoc_acceptconnection},
	{"reject",adhoc_rejectconnection},
	{"send",adhoc_send},
	{"recv",adhoc_recv},
	{"term",adhoc_term},
	{"getmac",adhoc_getmac},
    {0,0}
};

void _start() __attribute__ ((weak, alias ("module_start")));

int module_start(SceSize argc, const void *args) {
	lua_State *L = *(lua_State**)args;
	luaL_register(L, "adhoc", adhoc_functions);
	
	lua_pushnumber(L,SCE_NETCHECK_DIALOG_MODE_PSP_ADHOC_JOIN);
	lua_setglobal(L,"__ADHOC_JOIN");
	
	lua_pushnumber(L,SCE_NETCHECK_DIALOG_MODE_PSP_ADHOC_CONN);
	lua_setglobal(L,"__ADHOC_CONN");
	
	sceAppMgrGetNameById(sceKernelGetProcessId(), IdTitle);
	
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
