#include "scripting/lua-bindings/auto/lua_bind_test_auto.hpp"
#include "auto_binding.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"

int lua_autobind_AutoBindTest_add(lua_State* tolua_S)
{
    int argc = 0;
    AutoBindTest* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"AutoBindTest",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (AutoBindTest*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_autobind_AutoBindTest_add'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        int arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "AutoBindTest:add");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "AutoBindTest:add");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_autobind_AutoBindTest_add'", nullptr);
            return 0;
        }
        int ret = cobj->add(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "AutoBindTest:add",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_autobind_AutoBindTest_add'.",&tolua_err);
#endif

    return 0;
}
int lua_autobind_AutoBindTest_sub(lua_State* tolua_S)
{
    int argc = 0;
    AutoBindTest* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"AutoBindTest",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (AutoBindTest*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_autobind_AutoBindTest_sub'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        int arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "AutoBindTest:sub");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "AutoBindTest:sub");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_autobind_AutoBindTest_sub'", nullptr);
            return 0;
        }
        int ret = cobj->sub(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "AutoBindTest:sub",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_autobind_AutoBindTest_sub'.",&tolua_err);
#endif

    return 0;
}
int lua_autobind_AutoBindTest_constructor(lua_State* tolua_S)
{
    int argc = 0;
    AutoBindTest* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_autobind_AutoBindTest_constructor'", nullptr);
            return 0;
        }
        cobj = new AutoBindTest();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"AutoBindTest");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "AutoBindTest:AutoBindTest",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_autobind_AutoBindTest_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_autobind_AutoBindTest_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (AutoBindTest)");
    return 0;
}

int lua_register_autobind_AutoBindTest(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"AutoBindTest");
    tolua_cclass(tolua_S,"AutoBindTest","AutoBindTest","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"AutoBindTest");
        tolua_function(tolua_S,"new",lua_autobind_AutoBindTest_constructor);
        tolua_function(tolua_S,"add",lua_autobind_AutoBindTest_add);
        tolua_function(tolua_S,"sub",lua_autobind_AutoBindTest_sub);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(AutoBindTest).name();
    g_luaType[typeName] = "AutoBindTest";
    g_typeCast["AutoBindTest"] = "AutoBindTest";
    return 1;
}
TOLUA_API int register_all_autobind(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"abt",0);
	tolua_beginmodule(tolua_S,"abt");

	lua_register_autobind_AutoBindTest(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

