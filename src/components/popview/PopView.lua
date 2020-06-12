--------------------------------
-- @module PopView
-- @author kongl

--[[--
    PopView用法
    
    PopView:pushView({
        ccbName = #string js controller名字 ,params.view被覆盖,
        ccbFile = #string ccbi路径
    })
    
    params参数

    --可选
    params.classOwner #class 实现onEnter/onExit方法
    params.ccbName #string js controller名字 ,params.view被覆盖
    params.ccbOwner #table 
    params.ccbFile #string ccbi路径
    params.callback -- 退出回调

    可调用函数
    onEnter()
    onExit()
    onEnterTransitionFinish()
    onExitTransitionStart()
    onCleanup()
    
    @function popView --关闭当前窗体, 传入classOwner #table 关闭对应窗体
    @function allViews --返回所有窗体
    @function removeAllViews --关闭所有窗体
    @function currentView --返回当前窗体
]]

local PopStyle = require("components.popview.PopStyle")
PopView = {}

local popList = {}
local currentView = nil

function PopView:pushView(params)
    local popLayer = display.ViewLayer
    if popLayer then popLayer:setLocalZOrder(CommonConstants.PopViewZorder) end
    
    if params.ccbName then
        ccb[params.ccbName] = params.ccbOwner
        local proxy = cc.CCBProxy:create()
        params.classOwner.mNode = CCBReaderLoad(params.ccbFile, proxy, params.ccbOwner)
        params.classOwner.mNode:registerScriptHandler(function(event)
            if event == "enter" then
                if params.classOwner.onEnter then
                    params.classOwner:onEnter()
                end
                local className = params.classOwner and params.classOwner.__cname or ""
                printf("打开: ccb[  %s.ccbi  ] | class[  %s  ]", params.ccbName, className)
            elseif event == "exit" then
                if params.classOwner.onExit then
                    params.classOwner:onExit()
                end

                if params.callback then
                	params.callback()
                end

                params.classOwner.mNode = nil
                ccb[params.ccbName] = nil
            elseif event == "enterTransitionFinish" then
                if params.classOwner.onEnterTransitionFinish then
                	params.classOwner:onEnterTransitionFinish()
                end
            elseif event == "exitTransitionStart" then
                if params.classOwner.onExitTransitionStart then
                	params.classOwner:onExitTransitionStart()
                end
            elseif event == "cleanup" then
                if params.classOwner.onCleanup then
                	params.classOwner:onCleanup()
                end
            end
        end)
        
    end
    
    local popStyleView = PopStyle.new(params)
    popList[#popList + 1] = popStyleView
    popLayer:addChild(popStyleView)

    currentView = popStyleView
    
    -- local soundUtils=require("app.components.sound.SoundUtils")
    -- if params.ccbName == "BagPack" then -- 背包打开声音
    --     soundUtils.playDefaultMusic("sysBackpack.mp3")
    --     popStyleView.playSound = 1 -- 设置窗口有打开声音，关闭的时候调用关声音 
    -- end
end

-- 若有值，则在关闭界面处，运行该函数并且不执行关闭界面操作
function PopView:setInvokeBackFunc(fn)
	invokeBackFunc = fn
end

--添加等待的展示的界面
function PopView:pushWaitMission(func)
    if #popList == 0 then
    	func()
    else
        waitListFunc[#waitListFunc+1] = func
    end
end

-- 界面全部移除后执行的任务函数列表
function PopView:popWaitMission()
    if waitListFunc and #waitListFunc > 0 and #popList == 0 then
        local func = waitListFunc[1]
        table.remove(waitListFunc, 1)
        if func then
            func()
        end
    end
end

function PopView:popView(classOwner)
    classOwner = classOwner or currentView and currentView.classOwner
    if classOwner == nil then
    	return
    end
    
    if invokeBackFunc and invokeBackFunc() then
        invokeBackFunc = nil
        return
    end

    local index = -1
    for k, v in pairs(popList) do
        if v.classOwner == classOwner then
        	index = k
            local sequence = cc.Sequence:create({
                cc.RemoveSelf:create(), 
                cc.CallFunc:create(handler(self, PopView.popWaitMission))
            })
            v:runAction(sequence) --延迟一帧移除自己，在自身触摸事件内移除自己需要到下一帧移除，否则出现触摸穿透
            
            -- if v.playSound ~= nil then
            --     local soundUtils=require("app.components.sound.SoundUtils")
            --     soundUtils.playDefaultMusic("sysCloseView.mp3")
            -- end
        	break
        end
    end

    if index > 0 then
        table.remove(popList, index)
        local topIndex = #popList
        currentView = popList[topIndex]
    end
end

function PopView:popViewByClassName(pClassName)
    if pClassName == nil then return end
    if invokeBackFunc and invokeBackFunc() then invokeBackFunc = nil; return end

    local index = -1
    for k, v in pairs(popList) do
        if v.classOwner.__cname == pClassName then
            index = k
            local sequence = cc.Sequence:create( { cc.RemoveSelf:create(), 
                cc.CallFunc:create(handler(self, PopView.popWaitMission)) } )
            v:runAction(sequence) --延迟一帧移除自己，在自身触摸事件内移除自己需要到下一帧移除，否则出现触摸穿透
            
            -- if v.playSound ~= nil then
            --     local soundUtils=require("app.components.sound.SoundUtils")
            --     soundUtils.playDefaultMusic("sysCloseView.mp3")
            -- end
            break
        end
    end

    if index > 0 then
        table.remove(popList, index)
        local topIndex = #popList
        currentView = popList[topIndex]
    end
end



function PopView:allViews()
    return popList
end

function PopView:removeAllViews()
    local bInit = false
    for i=#popList, 1, -1 do
        local view = popList[i]
        local action
        if not bInit then
            action = cc.Sequence:create({
                cc.RemoveSelf:create(),
                cc.CallFunc:create(handler(self, PopView.popWaitMission))
            })
            bInit = true
        else
            action = cc.RemoveSelf:create()
        end
        view:runAction(action)
    end
    
    if bInit then
        -- local soundUtils=require("app.components.sound.SoundUtils")
        -- soundUtils.playDefaultMusic("sysCloseView.mp3")
    end
    
    popList = {}
    currentView = nil
end

function PopView:currentView()
    return currentView
end