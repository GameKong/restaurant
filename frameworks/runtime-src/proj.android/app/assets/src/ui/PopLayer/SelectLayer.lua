local TipLayer = require "ui.TipLayer.TipLayer"
local Money = require "components.info.Money"

local SelectLayer = class("SelectLayer")

function SelectLayer.showUI(type, data)
    local instance = SelectLayer.new()
    instance.data = data
    instance.type = type -- 1招聘，2升级

    instance.mUI = {
        onTouchClose = handler(instance, instance.onTouchClose),
        onTouchBtn = handler(instance, instance.onTouchBtn),
    }

    PopView:pushView({
        classOwner = instance,
        ccbName = "SelectLayer",
        ccbOwner = instance.mUI,
        ccbFile = "ccbi/SelectLayer.ccbi"
    })
end

-- 进入界面回调
function SelectLayer:onEnter()
    for i = 1, 2 do
        local btn = self.mNode:getChildByTag(i):getChildByTag(2)
        btn:setTitleForState(self.type == 1 and "招聘" or "升级", cc.CONTROL_STATE_NORMAL)
    end
end

-- 关闭界面
function SelectLayer:onTouchClose(sender, type)
    PopView:popView()
end

-- 升级按钮
function SelectLayer:onTouchBtn(sender, type)
    PopView:popView()
    self.data.idx = sender:getParent():getTag()

    if self.type == 1 then
        require("ui.PopLayer.InviteLayer").showUI(self.data)
    else
        require("ui.PopLayer.UpgradeLayer").showUI(self.data)
    end
end

return SelectLayer