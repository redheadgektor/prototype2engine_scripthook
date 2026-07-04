# Prototype 2 ScriptHook
> The plugin allows you to load third-party plugins and interact with the LUA language environment directly in the game using the in-game overlay.

# How use?
> Download 'xinput1_3.dll' and place into game directory

# Content Replacer
> The plugin allows you to replace game content by specifying what content and what to replace it with. For more details, see the scripthook\mods\replacer\replacer.cfg config.


## Some functionality is not yet fully implemented, but 2 exported functions are available for mod developers.
>Function for obtaining a native function for interaction without using LUA
> > void* GetNativeFunction(const char* function)
<details>
<summary>C++ Sample</summary>
  
```c++
typedef unsigned short* (__cdecl* GameObjectGetLocalPlayer_t)(unsigned short* outHandle);
GameObjectGetLocalPlayer_t GameObjectGetLocalPlayerFunc;
GameObjectGetLocalPlayerFunc = (GameObjectGetLocalPlayer_t)GetNativeFunction("go_GetLocalPlayer")

unsigned short handle[2];
GameObjectGetLocalPlayerFunc(handle);

localplayer_id = (handle[1] << 16) | handle[0];

typedef void(__cdecl* GameObjectTeleport_t)(int handle, Vector3 vec, Vector3 rot);
GameObjectTeleport_t GameObjectTeleportFunc;
GameObjectTeleportFunc = (GameObjectTeleport_t)GetNativeFunction("go_Teleport");

GameObjectTeleportFunc(localplayer_id, Vector3(0,0,0), Vector(0,0,0));
```

</details>

>The function for executing your code
> > int ExecuteLuaScript(const char* code, int length)
