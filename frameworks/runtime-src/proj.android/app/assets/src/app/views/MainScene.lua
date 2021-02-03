local Audio = require "components.Audio.Audio"
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    self:init()   
end

-- 游戏初始化
function MainScene:init()
    self:loadRes()
    self:initData()
    self:initMainLayer()
    self:initGameLayer()
    self:initViewLayer()
    self:initTipLayer()

    Audio.PlayBackgroudMusic()
end


-- 数据初始化
function MainScene:initData()

end

-- 资源加载
function MainScene:loadRes()
    -- 资源加载
    display.loadSpriteFrames("ccbResources/com_res.plist","ccbResources/com_res.png")
    display.loadSpriteFrames("ccbResources/com_res2.plist","ccbResources/com_res2.png")
    display.loadSpriteFrames("ccbResources/people_res.plist","ccbResources/people_res.png")
end

-- 初始化主界面层
function MainScene:initMainLayer()
    local MainLayer = display.newLayer(cc.c4b(170,121,66,255))
    :addTo(self, CommonConstants.MainZOrder)
    :align(display.LEFT_BOTTOM, 0, 0)
    :setIgnoreAnchorPointForPosition(false)

    display.MainLayer = MainLayer

    require("ui.MainLayer.MainLayer"):showUI()

end

-- 初始化游戏界面层
function MainScene:initGameLayer()
    local GameLayer = display.newLayer()
    :addTo(self, CommonConstants.GameZOrder)
    :align(display.LEFT_BOTTOM, 0, 0)
    :setIgnoreAnchorPointForPosition(false)

    display.GameLayer = GameLayer
end

-- 初始化弹窗界面层
function MainScene:initViewLayer()
    local ViewLayer = display.newLayer()
    :addTo(self, CommonConstants.PopViewZorder)
    :align(display.LEFT_BOTTOM, 0, 0)
    :setIgnoreAnchorPointForPosition(false)

    display.ViewLayer = ViewLayer
end

-- 初始化tip界面层
function MainScene:initTipLayer()
    local TipLayer = display.newLayer()
    :addTo(self, CommonConstants.TipZorder)
    :align(display.LEFT_BOTTOM, 0, 0)
    :setIgnoreAnchorPointForPosition(false)

    display.TipLayer = TipLayer
end

return MainScene
