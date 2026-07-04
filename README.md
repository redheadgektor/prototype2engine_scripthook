# Prototype 2 ScriptHook
> The plugin allows you to load third-party plugins and interact with the LUA language environment directly in the game using the in-game overlay.

# How use?
> Download 'xinput1_3.dll' and place into game directory

# Content Replacer
> The plugin allows you to replace game content by specifying what content and what to replace it with. For more details, see the scripthook\mods\replacer\replacer.cfg config.


## Some functionality is not yet fully implemented, but 2 exported functions are available for mod developers.
>Function for obtaining a native function for interaction without using LUA
> > void* GetNativeFunction(const char* function)

>The function for executing your code
> > int ExecuteLuaScript(const char* code, int length)
