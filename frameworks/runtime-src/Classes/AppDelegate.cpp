/****************************************************************************
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "AppDelegate.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "cocos2d.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"
#include "Sqlite3/lsqlite3.h"

// #define USE_AUDIO_ENGINE 1
// #define USE_SIMPLE_AUDIO_ENGINE 1
 #define CC_LUA_CRYPT_ENABLED 1
#if USE_AUDIO_ENGINE && USE_SIMPLE_AUDIO_ENGINE
#error "Don't use AudioEngine and SimpleAudioEngine at the same time. Please just select one in your game!"
#endif

#if USE_AUDIO_ENGINE
#include "audio/include/AudioEngine.h"
using namespace cocos2d::experimental;
#elif USE_SIMPLE_AUDIO_ENGINE
#include "audio/include/SimpleAudioEngine.h"
using namespace CocosDenshion;
#endif

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
#if USE_AUDIO_ENGINE
    AudioEngine::end();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::end();
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    RuntimeEngine::getInstance()->end();
#endif

}

// if you want a different context, modify the value of glContextAttrs
// it will affect all platforms
void AppDelegate::initGLContextAttrs()
{
    // set OpenGL context attributes: red,green,blue,alpha,depth,stencil,multisamplesCount
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8, 0 };

    GLView::setGLContextAttrs(glContextAttrs);
}


static int lsqlite_addpath(lua_State *L) {
    std::string cpath = FileUtils::getInstance()->getBaseApkPath();
    
    if (!cpath.compare(""))
        return 0;

    cocos2d::log("path: %s", cpath.c_str());
    int top = lua_gettop(L);
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "cpath");
    const char* luaBasePath = lua_tostring(L, -1);
    std::string basePath(luaBasePath);
    std::string cc = basePath + std::string(";") + cpath + std::string("/assets/res/?.so");
    const char *c = cc.c_str();
    lua_pushstring(L, c);
    lua_setfield(L, -3, "cpath");
    lua_settop(L, top);
    return 0;
}

static const luaL_Reg pathlib[] = {
    {"addpath",         lsqlite_addpath        },
    {NULL, NULL}
};

LUALIB_API int luaopen_pathlib(lua_State *L) {
    luaL_register(L, "pathlib", pathlib);

    return 1;
}

// if you want to use the package manager to install more packages, 
// don't modify or remove this function
static int register_all_packages(lua_State* L)
{
    luaopen_lsqlite3(L); //注册LSQLite3相关内容。
    luaopen_pathlib(L); //注册LSQLite3相关内容。
//    lsqlite_addpath(L); //注册LSQLite3相关内容。
    return 0; //flag for packages manager
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);

    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);
    
    register_all_packages(L);

    #if CC_LUA_CRYPT_ENABLED
        Magic::set((string("fcjw") + string("fJ5O") + string("i4dL") + string("sIF1")).c_str());
    #endif

//    LuaStack* stack = engine->getLuaStack();
//    stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));

    //register custom function
//    LuaStack* stack = engine->getLuaStack();
//    register_custom_function(stack->getLuaState());
    
//    engine->addCpath();
#if CC_64BITS
    FileUtils::getInstance()->addSearchPath("src/64bit");
#endif
    if (Magic::isEnabled()) {
        FileUtils::getInstance()->addSearchPath("res_encrypt");
        FileUtils::getInstance()->addSearchPath("src_encrypt");
    }
    else {
        FileUtils::getInstance()->addSearchPath("res");
        FileUtils::getInstance()->addSearchPath("src");
    }
    
    if (engine->executeScriptFile("main.lua"))
    {
        return false;
    }

    return true;
}

// This function will be called when the app is inactive. Note, when receiving a phone call it is invoked.
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

#if USE_AUDIO_ENGINE
    AudioEngine::pauseAll();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    SimpleAudioEngine::getInstance()->pauseAllEffects();
#endif
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

#if USE_AUDIO_ENGINE
    AudioEngine::resumeAll();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    SimpleAudioEngine::getInstance()->resumeAllEffects();
#endif
}
