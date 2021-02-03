local TipLayer = require "ui.TipLayer.TipLayer"
local Money = require "components.info.Money"
local CODTableView = require "components.tableView.CODTableView"
local Audio = require "components.Audio.Audio"

local UpgradeLayer = class("UpgradeLayer")

function UpgradeLayer.showUI(data)
    local type = data.type
    local floor = data.floor
    local idx = data.idx
    if type == GameConstants.EntityTypeCook then
        if not PlayerInfo.getCook(floor, idx) then
            TipLayer.showTip("还未招聘该厨师")
            return
        end
    elseif type == GameConstants.EntityTypeRunner then
        if not PlayerInfo.getRunnerList()[idx] then
            TipLayer.showTip("还未招聘该传菜员")
            return
        end
    elseif type == GameConstants.EntityTypeWaiter then
        if not PlayerInfo.getWaiterList()[idx] then
            TipLayer.showTip("还未招聘该服务员")
            return
        end
    end

    local instance = UpgradeLayer.new()
    instance.data = data
    instance.type = type
    instance.floor = floor
    instance.idx = idx


    instance.mUI = {
        onTouchClose = handler(instance, instance.onTouchClose),
        onTouchInvite = handler(instance, instance.onTouchInvite),
    }

    PopView:pushView({
        classOwner = instance,
        ccbName = "UpgradeLayer",
        ccbOwner = instance.mUI,
        ccbFile = "ccbi/UpgradeLayer.ccbi"
    })
end

function UpgradeLayer:onEnter()
    -- 该类型角色 拥有的属性ID列表
    self.attrIdList = GameConfig.getAttrList(self.type)

    self.mTableView = CODTableView.new({
        rect = cc.rect(0, 0, 450, 320),
        numbers = #self.attrIdList,
        cellSize = cc.size(450, 80),
        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL
    })
    :showCellAtIndex(handler(self, self.showCell))
    :addTo(self.mUI["tb_node"])
    :align(display.LEFT_BOTTOM, 0, 0)
    :reloadData()

    self:setTopUI()
end

function UpgradeLayer:setTopUI()
    self.mNode:getChildByTag(3):setString(GameConfig.getEmployeeConfig(self.type).name)

    for i = 1, 4 do
        local desc = self.mNode:getChildByTag(10 + i)

        local attrId = self.attrIdList[i]
        if attrId then
            desc:show()
            local uiCfg = GameConfig.getAttrUIConfig(attrId)
            local value = GameConfig.getAttrEffect({ type = self.type, floor = self.floor, idx = self.idx, attrId = attrId })
            desc:setString(string.format(uiCfg.desc2, value * 100))
        else
            desc:hide()
        end
    end
end

function UpgradeLayer:showCell(tableView, cell, idx, bNew)
    local itemNode
    if bNew then
        local proxy = cc.CCBProxy:create()
        cell.itemNode = CCBReaderLoad("ccbi/AttrCell.ccbi", proxy, nil)
        cell.itemNode:getChildByTag(3):registerControlEventHandler(handler(self, self.onTouchUpgrade), cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
        cell.itemNode:addTo(cell)
    end

    itemNode = cell.itemNode
    local icon = itemNode:getChildByTag(1)
    local txDesc = itemNode:getChildByTag(2)
    local btnUp = itemNode:getChildByTag(3)
    local txLevel = itemNode:getChildByTag(4)
    local txGold = itemNode:getChildByTag(5)


    local attrId = self.attrIdList[idx + 1]
    local uiCfg = GameConfig.getAttrUIConfig(attrId)

    local level = PlayerInfo.getEmployeeAttrLevel(self.type, self.floor, self.idx, attrId)
    local maxLevel = GameConfig.getMaxAttrLevel()

    icon:setSpriteFrame(uiCfg.res)

    if level < maxLevel then
        local param = { type = self.type, level = level + 1, attrId = attrId }
        local value = GameConfig.getAttrEffect(param)
        txDesc:setString(string.format(uiCfg.desc, value * 100))
        btnUp:setEnabled(true)
        UIHelper.setBtnGray(btnUp, false)
        btnUp.userData = idx

        local needGold = GameConfig.getNeedGoldForUpgradeAttr(param)
        txGold:show():setString(string.format("$%d", needGold))
    else
        txDesc:setString("满级")
        btnUp:setEnabled(false)
        UIHelper.setBtnGray(btnUp, true)
    end

    txLevel:setString(string.format("Lv:%d", level))
end

function UpgradeLayer:onTouchClose(sender, type)
    PopView:popView()
end

function UpgradeLayer:onTouchUpgrade(sender, type)
    local idx = sender.userData
    local attrId = self.attrIdList[idx + 1]
    local level = PlayerInfo.getEmployeeAttrLevel(self.type, self.floor, self.idx, attrId)
    local maxLevel = GameConfig.getMaxAttrLevel()

    if level >= maxLevel then
        TipLayer.showTip("该属性已满级")
    else
        local param = { level = level + 1, attrId = attrId }
        local needGold = GameConfig.getNeedGoldForUpgradeAttr(param)

        if Money.isGoldEnough(needGold) then
            -- 更新金币
            Money.addGold(-needGold)

            -- 升级属性
            param = {type = self.type, floor = self.floor, idx = self.idx, level = level + 1, attrId = attrId }
            PlayerInfo.setEmployeeAttrLevel(param)

            -- 更新界面
            self:setTopUI()
            self.mTableView:updateCellAtIndex(idx)

            
            TipLayer.showTip("升级成功")

            Audio.PlayEffect("music/upgrade.wav")
        else
            TipLayer.showTip("金币不足")

            Audio.PlayEffect("music/btn.wav")
        end
    end
end

return UpgradeLayer