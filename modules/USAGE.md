### Usage Quick Start ###
Here are a couple of examples that demonstrate how to use the ONElua require APIs.

### Basic sketch ###
Based on this sketch, you should be able to create / modify modules for ONElua.

```c
// Headers
#include <vitasdk.h>
#include <taihen.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

// Module
#define MODULE_NAME "extra" // Name of module

static int counter = 0;

static int extra_hello(lua_State *L){ // in lua MODULE_NAME.hello()
	lua_pushstring(L, "Hello from Extra Module!"); // Send a string to lua.
	return 1;
}

static int extra_count(lua_State *L){ // in lua MODULE_NAME.count()
	lua_pushnumber(L, counter++); // Send a number to lua.
	return 1;
}

// Here are added the functions of the module,
// Next the rule, {"Name of the function", Pointer to Function}
static const luaL_reg functions[] = {
	{"hello", extra_hello}, 
	{"count", extra_count}, 
	{0,0}
};

void _start() __attribute__ ((weak, alias ("module_start")));

int module_start(SceSize argc, const void *args) {
	lua_State *L = *(lua_State**)args;
	luaL_register(L, MODULE_NAME, functions);
	
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
```

### TO-DO ###
- Improve these instructions separately by parts.
