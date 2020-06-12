local TipLayer = require "ui.TipLayer.TipLayer"
local Money = require "components.info.Money"

local InviteLayer = class("InviteLayer")

function InviteLayer.showUI(data)
    local instance = InviteLayer.new()
    instance.data = data

    instance.mUI = {
        onTouchClose = handler(instance, instance.onTouchClose),
        onTouchInvite = handler(instance, instance.onTouchInvite),
    }

    PopView:pushView({
        classOwner = instance,
        ccbName = "InviteLayer",
        ccbOwner = instance.mUI,
        ccbFile = "ccbi/InviteLayer.ccbi"
    })
end

-- 进入界面回调
function InviteLayer:onEnter()
    local tip = ""

    -- 招聘厨师
    if self.data.type == GameConstants.EntityTypeCook then
        local floor = self.data.floor
        local idx = self.data.idx

        local need_gold = Floor.getInviteCost(floor, idx)
        tip = string.format("是否花费%d的金币招聘该厨师", need_gold)
    elseif self.data.type == GameConstants.EntityTypeRunner then
        local need_gold = GameConfig.getGoldForInviteRunner()
        tip = string.format("是否花费%d的金币招聘该传菜员", need_gold)
    elseif self.data.type == GameConstants.EntityTypeWaiter then
        local need_gold = GameConfig.getGoldForInviteWaiter()
        tip = string.format("是否花费%d的金币招聘该服务员", need_gold)
    end

    self.mNode:getChildByTag(2):setString(tip)
end

-- 退出界面回调
function InviteLayer:onExit()
    print("退出Invitelayer")
end

-- 关闭界面
function InviteLayer:onTouchClose(sender, type)
    PopView:popView()
end

-- 招聘按钮
function InviteLayer:onTouchInvite(sender, type)
    -- 招聘厨师
    if self.data.type == GameConstants.EntityTypeCook then
        local floor = self.data.floor
        local idx = self.data.idx

        -- 必须先招聘第一个人
        if idx == 2 and not PlayerInfo.getCook(floor, 1) then
            TipLayer.showTip(string.format("请先开启一号厨师位"))
            return
        end

        -- 金币不足
        local need_gold = Floor.getInviteCost(floor, idx)
        if not Money.isGoldEnough(need_gold) then
            TipLayer.showTip(string.format("金币不足，无法招聘"))
            return
        end

        -- 扣除金币，招聘对象
        if not PlayerInfo.getCook(floor, idx) then
            -- 更新金币
            Money.addGold(-need_gold)

            -- 新增厨师
            PlayerInfo.addCook(floor, idx)

            --关闭界面
            PopView:popView()

            -- 更新主界面
            display.MainUI:updateCellAtIndex(floor)

            TipLayer.showTip("购买成功")
        else
            TipLayer.showTip("该岗位已有员工")
            PopView:popView()
        end
    elseif self.data.type == GameConstants.EntityTypeRunner then
        -- 金币不足
        local need_gold = GameConfig.getGoldForInviteRunner()
        if not Money.isGoldEnough(need_gold) then
            TipLayer.showTip(string.format("金币不足，无法招聘"))
            return
        end

        -- 更新金币
        Money.addGold(-need_gold)

        -- 新增厨师
        PlayerInfo.addRunner()

        --关闭界面
        PopView:popView()

        -- 更新主界面
        display.MainUI:updateRunnerList()
        display.MainUI:updateInviteBtnStr()

        TipLayer.showTip("购买成功")

    elseif self.data.type == GameConstants.EntityTypeWaiter then
        -- 金币不足
        local need_gold = GameConfig.getGoldForInviteWaiter()
        if not Money.isGoldEnough(need_gold) then
            TipLayer.showTip(string.format("金币不足，无法招聘"))
            return
        end

        -- 更新金币
        Money.addGold(-need_gold)

        -- 新增厨师
        PlayerInfo.addWaiter()

        --关闭界面
        PopView:popView()

        -- 更新主界面
        display.MainUI:updateCellAtIndex(0)

        TipLayer.showTip("购买成功")
    end

end

return InviteLayer