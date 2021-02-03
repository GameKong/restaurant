--[[

Copyright (c) 2014-2017 Chukong Technologies Inc.

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

]]

require "cocos.cocos2d.Cocos2d"
require "cocos.cocos2d.Cocos2dConstants"
require "cocos.cocos2d.functions"

-- 添加ludIde调试代码,GitHub: https://github.com/k0204/LuaIde
-- 在cocos2.x中使用LuaDebug；在cocos3.x中使用LuaDebugjit
-- breakInfoFunc: 断点及时刷新函数，需要在定时器中调用，该函数用于确保断点能够及时的发送到lua client
-- xpcallFun: 程序异常监听函数,用于当程序出现异常时调试器定位错误代码
-- 7003在lauch.json中的port端口中配置，一致即可
local breakInfoFun,xpcallFun = require("LuaDebugjit")("localhost", 7003)
-- 1.断点定时器添加，
cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakInfoFun, 0.3, false)

__G__TRACKBACK__ = function(msg)
    xpcallFun()
    print("----------------------------------------")
    local msg = debug.traceback(msg, 3)
    print(msg)
    print("----------------------------------------")
    return msg
end

-- opengl
require "cocos.cocos2d.Opengl"
require "cocos.cocos2d.OpenglConstants"
-- audio
require "cocos.cocosdenshion.AudioEngine"
-- cocosstudio
if nil ~= ccs then
    require "cocos.cocostudio.CocoStudio"
end
-- ui
if nil ~= ccui then
    require "cocos.ui.GuiConstants"
    require "cocos.ui.experimentalUIConstants"
end

-- extensions
require "cocos.extension.ExtensionConstants"
-- network
require "cocos.network.NetworkConstants"
-- Spine
if nil ~= sp then
    require "cocos.spine.SpineConstants"
end

require "cocos.cocos2d.deprecated"
require "cocos.cocos2d.DrawPrimitives"

-- Lua extensions
require "cocos.cocos2d.bitExtend"

-- CCLuaEngine
require "cocos.cocos2d.DeprecatedCocos2dClass"
require "cocos.cocos2d.DeprecatedCocos2dEnum"
require "cocos.cocos2d.DeprecatedCocos2dFunc"
require "cocos.cocos2d.DeprecatedOpenglEnum"

-- register_cocostudio_module
if nil ~= ccs then
    require "cocos.cocostudio.DeprecatedCocoStudioClass"
    require "cocos.cocostudio.DeprecatedCocoStudioFunc"
end


-- register_cocosbuilder_module
require "cocos.cocosbuilder.DeprecatedCocosBuilderClass"

-- register_cocosdenshion_module
require "cocos.cocosdenshion.DeprecatedCocosDenshionClass"
require "cocos.cocosdenshion.DeprecatedCocosDenshionFunc"

-- register_extension_module
require "cocos.extension.DeprecatedExtensionClass"
require "cocos.extension.DeprecatedExtensionEnum"
require "cocos.extension.DeprecatedExtensionFunc"

-- register_network_module
require "cocos.network.DeprecatedNetworkClass"
require "cocos.network.DeprecatedNetworkEnum"
require "cocos.network.DeprecatedNetworkFunc"

-- register_ui_module
if nil ~= ccui then
    require "cocos.ui.DeprecatedUIEnum"
    require "cocos.ui.DeprecatedUIFunc"
end

-- cocosbuilder
require "cocos.cocosbuilder.CCBReaderLoad"

-- physics3d
require "cocos.physics3d.physics3d-constants"

-- 自定义模块初始化
require "components.init"

if CC_USE_FRAMEWORK then
    require "cocos.framework.init"
end