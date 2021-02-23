local CODTableView = require "components.tableView.CODTableView"
local TipLayer = require "ui.TipLayer.TipLayer"
local Money = require "components.info.Money"
local Audio = require "components.Audio.Audio"
local luaj = require "cocos.cocos2d.luaj"
local offsetH = (display.height - CommonConstants.DHeight) / 2
local pos_1, pos_2, pos_3, cook_height = 267, 417, 601, 180
local poxX, PosY = 82, 30

local MainLayer = class("MainLayer")

-- 加载界面
function MainLayer:showUI()
    self:init()
    display.MainUI = self
end

--初始化界面
function MainLayer:init()
    -- 启动定时器
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, MainLayer.update), 1, false)

    -- 加载主界面
    self.mUI = {
        onTouchHead = handler(self, self.onTouchHead),
        onTouchUp = handler(self, self.onTouchUp),
        onTouchAddGold = handler(self, self.onTouchAddGold),
        onTouchAddEnergy = handler(self, self.onTouchAddEnergy),
        onTouchIncrease = handler(self, self.onTouchIncrease),
        onTouchEarning = handler(self, self.onTouchEarning),
        onTouchEffect = handler(self, self.onTouchEffect),
        onTouchHandbook = handler(self, self.onTouchHandbook),
        onTouchMap = handler(self, self.onTouchMap),
        onTouchInviteRunner = handler(self, self.onTouchInviteRunner),
        onTouchUpgradeRunner = handler(self, self.onTouchUpgradeRunner),



    }
    ccb["MainLayer"] = self.mUI
    local proxy = cc.CCBProxy:create()
    local mNode = CCBReaderLoad("ccbi/MainLayer.ccbi", proxy, self.mUI)
    mNode:onNodeEvent("enter", handler(self, MainLayer.onEnter))
    mNode:onNodeEvent("exit", handler(self, MainLayer.onExit))
    mNode:align(display.CENTER, display.cx, display.cy)
    :setIgnoreAnchorPointForPosition(false)
    display.MainLayer:add(mNode, 0, 99)
    self.mNode = mNode

    --屏幕适配
    self.mUI["node_top"]:setPositionY(offsetH)
    self.mUI["node_bottom"]:setPositionY(-offsetH)
    self.mUI["node_view"]:setPositionY(-offsetH + 96)

    -- 创建厨房列表
    self.mTableView = CODTableView.new({
        rect = cc.rect(0, 0, 750, 800 + 2 * offsetH),
        numbers = 0,
        cellSize = handler(self, self.onCellSize),
        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL
    })
    :showCellAtIndex(handler(self, self.showCell))
    :setBounceable(false)
    :addTo(self.mUI["node_view"])
    :align(display.LEFT_BOTTOM, 0, 0)

    -- printf(string.format("frameSize,width:%s,height:%s",display.sizeInPixels.width, display.sizeInPixels.height))
    -- printf(string.format("winSize,width:%s,height:%s",display.size.width, display.size.height))
    -- printf(string.format("nodeSize,width:%s,height:%s",mNode:getContentSize().width, mNode:getContentSize().height))
    -- printf(string.format("factor:%s",display.contentScaleFactor))
end

function MainLayer:onEnter()
    PlayerInfo.updateCookList(true)
    PlayerInfo.updateWaiterList(true)

    self:setGold()
    self:setFreeGold()
    self:updateRunnerBox()
    self:setTableView(true)
    self:initRunnerView()
    self:initMenu()
    self:updateInviteBtnStr()

    PlayerInfo.updateRunnerList()
end

function MainLayer:onExit()

end

-- 创建传菜员所在层
function MainLayer:initRunnerView()
    local runnerLayer = display.newLayer()
    :addTo(self.mTableView.tableView, 999)
    :align(display.LEFT_BOTTOM, 0, 0)
    :setIgnoreAnchorPointForPosition(false)

    self.runnerLayer = runnerLayer

    self:setRunnerView()
end

-- 设置传菜员所在区域大小
function MainLayer:setRunnerView()
    local size = self.mTableView.tableView:getContentSize()
    size.width = 164
    self.runnerLayer:setContentSize(size)
end

function MainLayer:initMenu()
    -- 创建菜单列表
    self.mMenuTableView = CODTableView.new({
        rect = cc.rect(0, 0, 455, 65),
        numbers = table.nums(PlayerInfo.get("menu_list")),
        cellSize = { width = 100, height = 65 },
        direction = cc.SCROLLVIEW_DIRECTION_HORIZONTAL
    })
    :showCellAtIndex(
    function(tableView, cell, idx, bNew)
        local mNode
        if bNew then
            local proxy = cc.CCBProxy:create()
            cell.mNode = CCBReaderLoad("ccbi/MenuCell.ccbi", proxy, nil)
            cell.mNode:setPosition(0, 0):addTo(cell)
        end

        local data = PlayerInfo.get("menu_list")[idx + 1]
        local cfg = Menu.getConfigWithId(data.id)

        local icon = cell.mNode:getChildByTag(1)
        local tx_num = cell.mNode:getChildByTag(2)
        local tx_price = cell.mNode:getChildByTag(3)

        icon:setSpriteFrame(cfg.res)
        tx_num:setString(string.format("x%d", data.num))
        tx_price:setString(string.format("$%d", cfg.price))
    end
    )
    :addTo(self.mUI["node_menu"])
    :align(display.LEFT_BOTTOM, 0, 0)
    :reloadData()
end

-- 刷新菜单UI
function MainLayer:updateMenu()
    local menu_list = PlayerInfo.get("menu_list")
    self.mMenuTableView:setNumbers(#menu_list):refreshData()
end

-- 每秒更新信息
function MainLayer:update()
    -- 更新服务员数据
    self:updateWaiterList()

    -- 更新传菜员数据
    self:updateRunnerList()

    -- 更新每层服务员信息
    self:updateCookList()

    -- 更新闲置金币的显示
    self:updateFreeGold()
end

-- 更新服务员信息
function MainLayer:updateWaiterList()
    PlayerInfo.updateWaiterList()
end

-- 更新传菜员信息
function MainLayer:updateRunnerList()
    PlayerInfo.updateRunnerList()
end

-- 更新每层厨师信息
function MainLayer:updateCookList()
    PlayerInfo.updateCookList()
end

function MainLayer:updateFreeGold()
    PlayerInfo.setFreeGold()
    self:setFreeGold()
end

function MainLayer:setTableView(init)
    local number

    -- 如果已经全部开启
    if PlayerInfo.getMaxFloor() == Floor.getMaxFloor() then
        number = PlayerInfo.getMaxFloor() + 1
    else
        number = PlayerInfo.getMaxFloor() + 1 + 1 -- 一层服务员层，一层待开启层
    end

    self.mTableView:setNumbers(number)

    if init then
        self.mTableView:reloadData()
    else
        self.mTableView:refreshData()
    end
end

-- 设置金币数量
function MainLayer:setGold()
    self.mUI["tx_gold"]:setString(Utils.getGoldStr(PlayerInfo.getGold()))
end

-- 设置闲置资金数量
function MainLayer:setFreeGold()
    self.mUI["tx_free_gold"]:setString(Utils.getGoldStr(PlayerInfo.getFreeGold()))
end

-- cell 展示回调函数
function MainLayer:showCell(tableView, cell, idx, bNew)
    local itemNode
    if bNew then
        local proxy = cc.CCBProxy:create()
        cell.WaiterCell = CCBReaderLoad("ccbi/WaiterCell.ccbi", proxy, nil)
        cell.WaiterCell:setPosition(0, 0):addTo(cell)

        cell.CookCell = CCBReaderLoad("ccbi/CookCell.ccbi", proxy, nil)
        cell.CookCell:setPosition(0, 0):addTo(cell)
        cell.CookCell:getChildByTag(1):getChildByTag(1):registerControlEventHandler(handler(self, self.onInviteCook), cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
        cell.CookCell:getChildByTag(1):getChildByTag(2):registerControlEventHandler(handler(self, self.onUpgradeCook), cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
        cell.CookCell:getChildByTag(2):getChildByTag(2):registerControlEventHandler(handler(self, self.onOpenNextFloor), cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)

        cell.WaiterCell:getChildByTag(2):registerControlEventHandler(handler(self, self.onTouchInviteWaiter), cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
        cell.WaiterCell:getChildByTag(3):registerControlEventHandler(handler(self, self.onTouchUpgradeWaiter), cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
    end

    -- 顶层显示服务员层，剩下为厨师层
    if idx == 0 then
        cell.WaiterCell:setVisible(true)
        cell.CookCell:setVisible(false)

        self:updateWaiterAction(cell, 1)
        self:updateWaiterAction(cell, 2)
        cell.WaiterCell:getChildByTag(2):setTitleForState(string.format("招聘服务员%d/2", PlayerInfo.getWaiterNum()), cc.CONTROL_STATE_NORMAL)
    else
        -- 厨师层
        cell.WaiterCell:setVisible(false)
        cell.CookCell:setVisible(true)

        -- 如果是待开启层
        local gameNode = cell.CookCell:getChildByTag(1)
        local buttonNode = cell.CookCell:getChildByTag(2)
        local btnInvite = gameNode:getChildByTag(1)
        local btnUpgrade = gameNode:getChildByTag(2)
        local btnOpenFloor = buttonNode:getChildByTag(2)

        -- 设置层数
        btnInvite.userData = idx
        btnUpgrade.userData = idx
        btnOpenFloor.userData = idx

        if idx == self.mTableView.numbers - 1 and PlayerInfo.getMaxFloor() < idx then
            gameNode:hide()
            buttonNode:show()
            buttonNode:getChildByTag(1):setString(string.format("开启下一层需要花费%d个金币", Floor.getGoldForOpenFloor(idx)))
        else
            gameNode:show()
            buttonNode:hide()

            -- 根据当前层信息设置cell表现
            gameNode:getChildByTag(3):setString(idx)
            btnInvite:setTitleForState(string.format("招聘厨师%d/2", PlayerInfo.cookNumForFloor(idx)), cc.CONTROL_STATE_NORMAL)

            -- 更新厨师动画
            self:updateCookAction(cell, idx, 1)
            self:updateCookAction(cell, idx, 2)

            -- 更新每层完成菜的显示
            self:updateCompleteTableViewForFloor(idx, cell)
        end
    end
end

-- 更新服务员
function MainLayer:updateWaiterAction(...)
    local param = { ... }
    local cell, idx

    if #param == 2 then
        cell = param[1]
        idx = param[2]

    elseif #param == 1 then
        cell = self.mTableView:cellAtIndex(0)
        idx = param[1]
    else
        assert(false, "参数个数错误")
    end

    local waiterData = PlayerInfo.getWaiterList()[idx]

    if cell and waiterData then
        local spNode = cell.WaiterCell:getChildByTag(1)
        local sp = spNode:getChildByTag(idx)

        if not sp then
            sp = cc.Sprite:createWithSpriteFrameName("cook_back_1.png")
            sp:align(display.CENTER_BOTTOM, 0, PosY)
            sp:addTo(spNode, 99, idx)

            local size = sp:getContentSize()
            cc.Label:createWithSystemFont("", display.DEFAULT_TTF_FONT, 30)
            :addTo(sp, 0, 1)
            :align(display.CENTER_BOTTOM, size.width / 2, size.height)
            :enableShadow(cc.c4b(0, 0, 0, 255))
        end

        sp:stopAllActions()

        local state = waiterData.state

        local pos, toPos = self:getWaiterPos(state, idx)

        if state == GameConstants.STATE_WAIT then
            sp:setSpriteFrame("cook_back_1.png")
            sp:setPositionX(pos)
        elseif state == GameConstants.STATE_GO then
            -- 摇晃
            sp:setSpriteFrame("cook_back_1.png")
            local animation = display.newAnimation("cook_back_%d.png", 1, 2, 0.2)
            sp:playAnimationForever(animation)

            -- 修正厨师位置
            sp:setPositionX(pos)

            -- 移动
            local delay = math.max(0, waiterData.deadline - os.time())
            local action = cc.MoveTo:create(delay, cc.p(toPos, PosY))
            sp:runAction(action)
        elseif state == GameConstants.STATE_BACK then
            -- 摇晃
            sp:setSpriteFrame("cook_go_1.png")
            local animation = display.newAnimation("cook_go_%d.png", 1, 2, 0.2)
            sp:playAnimationForever(animation)

            -- 修正厨师位置
            sp:setPositionX(pos)

            -- 移动
            local delay = math.max(0, waiterData.deadline - os.time())

            local action1 = cc.MoveTo:create(delay - 0.1, cc.p(toPos, PosY)) --cc.Sequence:create()
            local showGold = string.format("+$%s", Utils.getGoldStr(waiterData.have_gold))
            local action2 = cc.CallFunc:create(handler(cell.WaiterCell, function(waiterCell)
                if waiterCell then
                    local pos_x = idx == 1 and 368 or 620
                    local label = cc.Label:createWithSystemFont(showGold, display.DEFAULT_TTF_FONT, 30)
                    :addTo(waiterCell, 0, 1)
                    :align(display.CENTER_BOTTOM, pos_x, 133)
                    :enableShadow(cc.c4b(0, 0, 0, 255))

                    label:runAction(cc.Sequence:create(cc.MoveTo:create(1, cc.p(pos_x, 233)), cc.RemoveSelf:create()))
                end
            end))

            local action = cc.Sequence:create(action1, action2)
            sp:runAction(action)
        end

        sp:getChildByTag(1):setString(string.format("$%s", Utils.getGoldStr(waiterData.have_gold)))
    end
end

-- 获取服务员当前的位置
function MainLayer:getWaiterPos(state, idx)
    local waiterData = PlayerInfo.getWaiterList()[idx]
    local basePos = 231
    local pos = idx == 1 and 381 or 631

    if state == GameConstants.STATE_WAIT then
        return pos
    elseif state == GameConstants.STATE_GO then
        local factor = (waiterData.deadline - os.time()) / (waiterData.deadline - waiterData.start_time)
        local offset = factor * (pos - basePos)
        local fromPos = basePos + offset
        local toPos = basePos
        return fromPos, toPos
    elseif state == GameConstants.STATE_BACK then
        local factor = (waiterData.deadline - os.time()) / (waiterData.deadline - waiterData.start_time)
        local offset = factor * (pos - basePos)
        local fromPos = pos - offset
        local toPos = pos
        return fromPos, toPos
    end
end

-- 更新厨师动画
function MainLayer:updateCookAction(...)
    local param = { ... }
    local cell, floor, idx

    if #param == 2 then
        floor = param[1]
        idx = param[2]
        cell = self.mTableView:cellAtIndex(floor)
    elseif #param == 3 then
        cell = param[1]
        floor = param[2]
        idx = param[3]
    else
        assert(false, "参数个数错误")
    end

    if cell and cell.CookCell:isVisible() then
        local sp = cell.CookCell:getChildByTag(1):getChildByTag(10 + idx)
        sp:stopAllActions()
        sp:setFlippedX(false)
        sp:removeAllChildren()
        local cookData = PlayerInfo.getCook(floor, idx)

        if cookData then
            local state = cookData.state

            if state == GameConstants.STATE_WAIT then
                sp:setSpriteFrame("cook_back_2.png")
                -- cc.Label:createWithSystemFont("储物箱空间不足", display.DEFAULT_TTF_FONT, 25)
                -- :addTo(sp)
                -- :setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
                -- :setPosition(50,250)
                -- :setTextColor(cc.c4b(255,50,50,255))
                -- :enableShadow()
            elseif state == GameConstants.STATE_MAKE then
                sp:setSpriteFrame("make_1.png")
                local animation = display.newAnimation("make_%d.png", 1, 2, 0.2)
                sp:playAnimationForever(animation)
                self:addFoodIconAndBar(sp, cookData)

                -- 修正厨师位置
                sp:setPositionX(idx == 1 and pos_2 or pos_3)
            elseif state == GameConstants.STATE_GO then
                -- 摇晃
                sp:setSpriteFrame("cook_go_1.png")
                local animation = display.newAnimation("cook_go_%d.png", 1, 2, 0.2)
                sp:playAnimationForever(animation)

                -- 修正厨师位置
                local posX = MainLayer:getCookPos(state, cookData, idx)
                sp:setPositionX(posX)

                -- 移动
                local delay = math.max(0, cookData.deadline - os.time())
                local action2 = cc.MoveTo:create(delay, cc.p(pos_1, cook_height))
                sp:runAction(action2)
            elseif state == GameConstants.STATE_BACK then
                sp:setFlippedX(true)

                -- 摇晃
                sp:setSpriteFrame("cook_back_1.png")
                local animation = display.newAnimation("cook_back_%d.png", 1, 2, 0.2)
                sp:playAnimationForever(animation)

                -- 修正厨师位置
                local posX = MainLayer:getCookPos(state, cookData, idx)
                sp:setPositionX(posX)

                -- 移动
                local delay = math.max(0, cookData.deadline - os.time())

                local pos
                if idx == 1 then
                    pos = cc.p(pos_2, cook_height)
                else
                    pos = cc.p(pos_3, cook_height)
                end

                local action2 = cc.MoveTo:create(delay, pos)
                sp:runAction(action2)
            end
        else
            sp:setSpriteFrame("invite.png")

            -- 修正厨师位置
            sp:setPositionX(idx == 1 and pos_2 or pos_3)
        end
    end
end

-- 计算当前所处的位置
function MainLayer:getCookPos(state, cookData, idx)
    local rlt
    local pos = idx == 1 and pos_2 or pos_3
    local factor = (cookData.deadline - os.time()) / (cookData.deadline - cookData.start_time)
    local offset = (pos - pos_1) * factor

    if state == GameConstants.STATE_GO then
        rlt = pos_1 + offset
    elseif state == GameConstants.STATE_BACK then
        rlt = pos - offset
    end

    return rlt
end

-- 添加菜的标识和进度条
function MainLayer:addFoodIconAndBar(sp, cookData)
    local foodId = cookData.food.id
    local start_time = cookData.start_time
    local deadline = cookData.deadline

    local res = Menu.getConfigWithId(foodId).res
    cc.Sprite:createWithSpriteFrameName(res)
    :setPosition(120, 240)
    :addTo(sp)

    local bar = cc.LayerColor:create(cc.c4b(0, 255, 0, 255))
    :setIgnoreAnchorPointForPosition(false)
    :setAnchorPoint(cc.p(0, 0.5))
    :setContentSize(40, 10)
    :setPosition(100, 210)
    :addTo(sp)

    local scale = math.min(1, (deadline - os.time()) / (deadline - start_time))
    bar:setScaleX(scale)
    bar:runAction(cc.ScaleTo:create(deadline - os.time(), 0, 1))
end

-- 更新传菜员界面
function MainLayer:updateRunnerAction(idx)
    local runnerData = PlayerInfo.getRunnerList()[idx]

    local sp = self.runnerLayer:getChildByTag(idx)

    if not sp then
        sp = cc.Sprite:createWithSpriteFrameName("run_front_1.png")
        sp:align(display.CENTER_BOTTOM, poxX, 0)
        sp:addTo(self.runnerLayer, 99, idx)

        local size = sp:getContentSize()
        cc.Label:createWithSystemFont("", display.DEFAULT_TTF_FONT, 30)
        :addTo(sp, 0, 1)
        :align(display.CENTER_BOTTOM, size.width / 2, size.height)
        :enableShadow(cc.c4b(0, 0, 0, 255))
    end

    sp:stopAllActions()

    if runnerData then
        local state = runnerData.state

        local pos, toPos = self:getRunnerPos(state, idx)

        if state == GameConstants.STATE_WAIT then
            sp:setSpriteFrame("run_front_1.png")
            sp:setPositionY(pos)
        elseif state == GameConstants.STATE_MAKE then
            sp:setSpriteFrame("runner_push_1.png")
            local animation = display.newAnimation("runner_push_%d.png", 1, 2, 0.2)
            sp:playAnimationForever(animation)

            -- 修正runner位置
            sp:setPositionY(pos)
        elseif state == GameConstants.STATE_GO then
            -- 摇晃
            sp:setSpriteFrame("run_front_1.png")
            local animation = display.newAnimation("run_front_%d.png", 1, 2, 0.2)
            sp:playAnimationForever(animation)

            -- 修正厨师位置
            sp:setPositionY(pos)

            -- 移动
            local delay = math.max(0, runnerData.deadline - os.time())
            local action2 = cc.MoveTo:create(delay, cc.p(poxX, toPos))
            sp:runAction(action2)

        elseif state == GameConstants.STATE_BACK then
            -- 摇晃
            sp:setSpriteFrame("run_back_1.png")
            local animation = display.newAnimation("run_back_%d.png", 1, 2, 0.2)
            sp:playAnimationForever(animation)

            -- 修正厨师位置
            sp:setPositionY(pos)

            -- 移动
            local delay = math.max(0, runnerData.deadline - os.time())

            local action2 = cc.MoveTo:create(delay, cc.p(poxX, toPos))
            sp:runAction(action2)
        end

        sp:getChildByTag(1):setString(string.format("$%s", Utils.getGoldStr(runnerData.have_gold)))
    end

end

-- 获取当前runner的位置
function MainLayer:getRunnerPos(state, idx)
    local runnerData = PlayerInfo.getRunnerList()[idx]
    local floor = runnerData.floor
    local basePos = self.runnerLayer:getContentSize().height - 293 -- 0层底部的高度
    local cellHeight = 322 -- 每厨师层高度

    if state == GameConstants.STATE_WAIT then
        return basePos
    elseif state == GameConstants.STATE_MAKE then
        return basePos - floor * cellHeight
    elseif state == GameConstants.STATE_GO then
        local toPost = basePos - (floor + 1) * cellHeight

        local factor = (runnerData.deadline - os.time()) / (runnerData.deadline - runnerData.start_time)
        local offset = factor * cellHeight
        local pos = toPost + offset
        return pos, toPost
    elseif state == GameConstants.STATE_BACK then
        local toPost = basePos - (floor - 1) * cellHeight

        local factor = (runnerData.deadline - os.time()) / (runnerData.deadline - runnerData.start_time)
        local offset = factor * cellHeight
        local pos = toPost - offset
        return pos, toPost
    end
end

-- 更新冰箱内菜的价值显示
function MainLayer:updateRunnerBox()
    local price = Utils.getGoldStr(PlayerInfo.getRunnerBox())
    self.mUI["tx_runner_box"]:setString(string.format("%s", price))
end

-- 更新按钮显示
function MainLayer:updateInviteBtnStr()
    local num = #PlayerInfo.getRunnerList()
    self.mUI["bt_invite_runner"]:setTitleForState(string.format("招聘传菜员%d/2", num), cc.CONTROL_STATE_NORMAL)
end

-- 开启下一层
function MainLayer:onOpenNextFloor(sender, type)
    
    local floor = sender.userData
    local needGold = Floor.getGoldForOpenFloor(floor)

    if Money.isGoldEnough(needGold) then
        -- 更新金币
        Money.addGold(-needGold)

        -- 开启新的层
        PlayerInfo.addFloor(floor)

        -- 更新UI
        self:setTableView()

        -- 更新runnerView大小
        self:setRunnerView()

        TipLayer.showTip("开启成功")

        Audio.PlayEffect("music/upgrade.wav")
    else
        TipLayer.showTip("金币不足")
        Audio.PlayEffect("music/btn.wav")
    end
end

-- 点击招聘服务员
function MainLayer:onTouchInviteWaiter()
    Audio.PlayEffect("music/btn.wav")
    -- 已经招聘满了
    if PlayerInfo.getWaiterNum() >= 2 then
        TipLayer.showTip("服务员已招满")
        return
    end

    local data =    {
        type = GameConstants.EntityTypeWaiter,
    }

    require("ui.PopLayer.InviteLayer").showUI(data)
end

-- 点击升级服务员
function MainLayer:onTouchUpgradeWaiter()
    Audio.PlayEffect("music/btn.wav")
    local data =    {
        type = GameConstants.EntityTypeWaiter,
    }

    require("ui.PopLayer.SelectLayer").showUI(2, data)
end

-- 点击招聘传菜员
function MainLayer:onTouchInviteRunner()
    Audio.PlayEffect("music/btn.wav")
    -- 已经招聘满了
    if PlayerInfo.getRunnerNum() >= 2 then
        TipLayer.showTip("传菜员已招满")
        return
    end

    local data =    {
        type = GameConstants.EntityTypeRunner,
    }

    require("ui.PopLayer.InviteLayer").showUI(data)
end

-- 点击升级传菜员
function MainLayer:onTouchUpgradeRunner()
    Audio.PlayEffect("music/btn.wav")
    local data =    {
        type = GameConstants.EntityTypeRunner,
    }

    require("ui.PopLayer.SelectLayer").showUI(2, data)
end

-- 开启招聘厨师
function MainLayer:onInviteCook(sender, type)
    Audio.PlayEffect("music/btn.wav")
    local floor = sender.userData

    -- 已经招聘满了
    if PlayerInfo.cookNumForFloor(floor) >= 2 then
        TipLayer.showTip("该层厨师已招满")
        return
    end

    local data =    {
        type = GameConstants.EntityTypeCook,
        floor = floor,
    }

    require("ui.PopLayer.SelectLayer").showUI(1, data)
end

-- 升级厨师
function MainLayer:onUpgradeCook(sender, type)
    Audio.PlayEffect("music/btn.wav")
    local data =    {
        type = GameConstants.EntityTypeCook,
        floor = sender.userData,
    }

    require("ui.PopLayer.SelectLayer").showUI(2, data)
end

-- cell 尺寸大小回调函数
function MainLayer:onCellSize(tableView, idx)

    if idx == 0 then
        return { width = 750, height = 293 }
    else
        return { width = 750, height = 332 }
    end

end

-- 更新主界面的指定idx的cell
function MainLayer:updateCellAtIndex(floor)
    self.mTableView:updateCellAtIndex(floor)
end

-- 更新指定层的完成菜单列表
function MainLayer:updateCompleteTableViewForFloor(...)
    local data = { ... }
    local cell, floor
    if #data == 1 then
        floor = data[1]
        cell = self.mTableView:cellAtIndex(floor)
    else
        floor = data[1]
        cell = data[2]
    end

    if cell then
        local CookBoxData = PlayerInfo.getCookBoxForFloor(floor)
        local food_node = cell.CookCell:getChildByTag(1):getChildByTag(103)
        local num = PlayerInfo.getCookBoxShowNum(floor)

        for i = 1, 4 do
            local sp = food_node:getChildByTag(i)
            if i <= num then
                local id = CookBoxData.id_list[i].id
                local price = CookBoxData.id_list[i].price
                sp:setSpriteFrame(Menu.getConfigWithId(id).res)
                sp:getChildByTag(1):setString(string.format("$%d", price))
                sp:setVisible(true)
            else
                sp:setVisible(false)
            end
        end

        food_node:getChildByTag(5):setString(string.format("$%d", CookBoxData.price))
    end
end

-- 点击头像
function MainLayer:onTouchHead()
    TipLayer.showTip("暂未开放")
    Audio.PlayEffect("music/btn.wav")
    -- local a = require "mt"
    -- print(a)
end

-- 点击升级
function MainLayer:onTouchUp()
    TipLayer.showTip("暂未开放")
    Audio.PlayEffect("music/btn.wav")
end
-- 点击添加金币
function MainLayer:onTouchAddGold()
    local className = "org/cocos2dx/lua/AppActivity"
    local methodName = "test"
    local args = {}
    local sig = "()V"
    local isOk,errCode = luaj.callStaticMethod(className,methodName, args,sig)
    if not isOk then
        print("aaaaaaaaaerrCode:"..errCode)
    else
        print(44444)
    end
    print(isOk)
    print(errCode)        

    Audio.PlayEffect("music/btn.wav")
end

-- 点击添加能量
function MainLayer:onTouchAddEnergy()
    TipLayer.showTip("暂未开放")
    Audio.PlayEffect("music/btn.wav")
end

-- 点击提升收益
function MainLayer:onTouchIncrease()
    TipLayer.showTip("暂未开放")
    Audio.PlayEffect("music/btn.wav")
end

-- 点击收益X2
function MainLayer:onTouchEarning()
    TipLayer.showTip("暂未开放")
    Audio.PlayEffect("music/btn.wav")
end

-- 点击效率X2
function MainLayer:onTouchEffect()
    TipLayer.showTip("暂未开放")
    Audio.PlayEffect("music/btn.wav")
end

-- 点击图鉴
function MainLayer:onTouchHandbook()
    TipLayer.showTip("暂未开放")
    Audio.PlayEffect("music/btn.wav")
end

-- 点击我的门店
function MainLayer:onTouchMap()
    TipLayer.showTip("暂未开放")
    Audio.PlayEffect("music/btn.wav")
end



return MainLayer