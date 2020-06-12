local TipLayer = require "ui.TipLayer.TipLayer"
local Employee = require "components.entity.Employee"
local Money = require "components.info.Money"
local Audio = require "components.Audio.Audio"

PlayerInfo = {}
local m_data = {
    gold = 1000, --玩家金币数
    free_gold = 0, --玩家闲置金币数
    waiter_list = {}, -- 玩家所拥有的服务员列表
    runner_list = {}, -- 玩家所拥有的传菜员列表
    floor_list = { {} }, -- 每层玩家所拥有的厨师列表
    menu_list = {}, -- 当前菜单集合
    cook_box = {}, -- 每层厨师当前待传送的菜
    runner_box = 0, -- 当前待上桌的菜的总价值   
}

function PlayerInfo.init()
    local user_data = Sqlite3DB:query("player_data")[1]

    if not user_data then
        -- 根据层数 初始化cook_box 字段
        for i = 1, Floor.getMaxFloor() do
            m_data.cook_box[#m_data.cook_box + 1] = { id_list = {}, price = 0, food_price = 0 }
        end

        Sqlite3DB:insert("player_data", m_data, true)
    else
        m_data = user_data
    end
end

function PlayerInfo.get(key)
    return m_data[key]
end

function PlayerInfo.set(key, value)
    m_data[key] = value

    -- 更新数据库
    local update_data = {}
    update_data[key] = value
    Sqlite3DB:update("player_data", update_data)
end

function PlayerInfo.getMenuNum()
    local num = 0
    for k, v in pairs(m_data.menu_list) do
        num = num + v.num
    end

    return num
end

function PlayerInfo.getMaxFloor()
    return #m_data.floor_list
end

function PlayerInfo.getGold()
    return m_data.gold
end

function PlayerInfo.setGold(gold)
    m_data.gold = gold

    Sqlite3DB:update("player_data", { gold = gold })
end

function PlayerInfo.getFreeGold()
    return m_data.free_gold
end

function PlayerInfo.setFreeGold(freeGold)
    local free_gold = m_data.runner_box

    for i = 1, #m_data.cook_box do
        free_gold = free_gold + m_data.cook_box[i].price
    end

    m_data.free_gold = free_gold

    Sqlite3DB:update("player_data", { free_gold = free_gold })
end

-- 获取雇员属性等级
function PlayerInfo.getEmployeeAttrLevel(type, floor, idx, attrId)
    local employee_data

    if type == GameConstants.EntityTypeCook then
        employee_data = m_data.floor_list[floor][idx]
    elseif type == GameConstants.EntityTypeRunner then
        employee_data = m_data.runner_list[idx]
    elseif type == GameConstants.EntityTypeWaiter then
        employee_data = m_data.waiter_list[idx]
    end

    local attr_data = employee_data.attr

    if attrId then
        return attr_data[attrId]
    end

    return attr_data
end

-- 设置雇员属性等级
function PlayerInfo.setEmployeeAttrLevel(param)
    local idx = param.idx
    local attrId = param.attrId
    local level = param.level

    if param.type == GameConstants.EntityTypeCook then
        local floor = param.floor
        local floor_data = m_data.floor_list[floor]
        floor_data[idx].attr[attrId] = level

        Sqlite3DB:update("player_data", { floor_list = m_data.floor_list })
    elseif param.type == GameConstants.EntityTypeRunner then
        m_data.runner_list[idx].attr[attrId] = level

        Sqlite3DB:update("player_data", { runner_list = m_data.runner_list })
    elseif param.type == GameConstants.EntityTypeWaiter then
        m_data.waiter_list[idx].attr[attrId] = level

        Sqlite3DB:update("player_data", { waiter_list = m_data.waiter_list })
    end

end

function PlayerInfo.getCook(floor, idx)
    local floor_data = m_data.floor_list[floor]
    if not floor_data then
        return nil
    end

    return floor_data[idx]
end

function PlayerInfo.getCookList()
    return m_data.floor_list
end

-- 创建新的厨师
function PlayerInfo.addCook(floor, idx)
    Audio.PlayEffect("music/upgrade.wav")
    local cookData = Employee.new({ type = GameConstants.EntityTypeCook, floor = floor, idx = idx })
    m_data.floor_list[floor][idx] = cookData.m_data

    -- 同步到数据库
    Sqlite3DB:update("player_data", { floor_list = m_data.floor_list })
end

-- 更新服务员信息
function PlayerInfo.updateWaiterList(init)
    local synch = false
    local waiterList = PlayerInfo.getWaiterList()

    for idx = 1, #waiterList do
        synch = PlayerInfo.updateWaiter(idx, init) or synch
    end

    -- 同步到数据库
    if (synch) then
        Sqlite3DB:update("player_data", { waiter_list = m_data.waiter_list })
    end

end

-- 更新服务员信息
function PlayerInfo.updateWaiter(idx, init)
    local synch = false
    local waiterList = PlayerInfo.getWaiterList()
    local waiterData = waiterList[idx]

    if waiterData then
        if waiterData.state == GameConstants.STATE_WAIT then -- 空闲状态
            waiterData.state = GameConstants.STATE_GO
            local pData = { type = GameConstants.EntityTypeWaiter, idx = idx, attrId = GameConstants.ATTR_MOVE }
            local delayTime = GameConfig.getDelayTimeByType(pData)
            waiterData.start_time = os.time()
            waiterData.deadline = os.time() + delayTime

            synch = true

            -- 更新动画
            if not init then
                display.MainUI:updateWaiterAction(idx)
            end
        else
            -- 时间到达
            if os.time() >= waiterData.deadline then
                -- 更新状态
                if waiterData.state == GameConstants.STATE_GO then -- 去取菜结束后变为返回状态
                    waiterData.state = GameConstants.STATE_BACK
                    PlayerInfo.getGoldFromRunnerBox(idx)

                    if not init then
                        display.MainUI:updateRunnerBox()
                    end

                elseif waiterData.state == GameConstants.STATE_BACK then -- 上菜结束后 返回取菜,并且增加相应金币
                    waiterData.state = GameConstants.STATE_GO
                    PlayerInfo.getGoldFromGuest(idx, init)
                end

                local pData = { type = GameConstants.EntityTypeWaiter, idx = idx, attrId = GameConstants.ATTR_MOVE }
                local delayTime = GameConfig.getDelayTimeByType(pData)
                waiterData.start_time = os.time()
                waiterData.deadline = os.time() + delayTime

                synch = true

                -- 更新动画
                if not init then
                    display.MainUI:updateWaiterAction(idx)
                end
            end
        end
    end

    return synch
end

-- 服务员从储物柜中拿食物
function PlayerInfo.getGoldFromRunnerBox(idx)
    local waiterData = PlayerInfo.getWaiterList()[idx]

    -- 服务员员可以接受的金币数
    local waiterGetNum = PlayerInfo.getWaiterCapacity(idx) - waiterData.have_gold
    -- 储物箱现有的金币数
    local runnerBoxGiveNum = PlayerInfo.getRunnerBox()

    -- 取小值
    local price = math.min(waiterGetNum, runnerBoxGiveNum)

    waiterData.have_gold = waiterData.have_gold + price
    PlayerInfo.addRunnerBox(-price)
end

-- 服务员交付食物赚钱金钱
function PlayerInfo.getGoldFromGuest(idx, init)
    local waiterData = PlayerInfo.getWaiterList()[idx]
    local gold = waiterData.have_gold
    waiterData.have_gold = 0

    if not init then
        Money.addGold(gold)
        if gold > 0 then
            Audio.PlayEffect("music/gold.wav")
        end
    end

end

-- 更新传菜员信息
function PlayerInfo.updateRunnerList(init)
    local synch = false
    local runnerList = PlayerInfo.getRunnerList()

    for idx = 1, #runnerList do
        synch = PlayerInfo.updateRunner(idx, init) or synch
    end

    -- 同步到数据库
    if (synch) then
        Sqlite3DB:update("player_data", { runner_list = m_data.runner_list })
    end

end

-- 更新传菜员信息
function PlayerInfo.updateRunner(idx, init)
    local synch = false
    local runnerList = PlayerInfo.getRunnerList()
    local runnerData = runnerList[idx]

    if runnerData then
        if runnerData.state == GameConstants.STATE_WAIT then -- 空闲状态
            runnerData.state = GameConstants.STATE_GO
            local pData = { type = GameConstants.EntityTypeRunner, idx = idx, attrId = GameConstants.ATTR_MOVE }
            local delayTime = GameConfig.getDelayTimeByType(pData)
            runnerData.start_time = os.time()
            runnerData.deadline = os.time() + delayTime

            synch = true

            -- 更新动画
            if not init then
                display.MainUI:updateRunnerAction(idx)
            end
        else
            -- 时间到达
            if os.time() >= runnerData.deadline then
                -- 更新状态
                local attrId = GameConstants.ATTR_MOVE
                if runnerData.state == GameConstants.STATE_MAKE then -- 从某层中取菜状态结束
                    -- 取菜
                    PlayerInfo.getFoodFromCookBox(runnerData.floor, idx)

                    -- 达到容量上限或最后一层，则返回
                    if runnerData.have_gold >= PlayerInfo.getRunnerCapacity(idx) or runnerData.floor >= PlayerInfo.getMaxFloor() then
                        runnerData.state = GameConstants.STATE_BACK
                    else
                        runnerData.state = GameConstants.STATE_GO
                    end

                    if not init then
                        display.MainUI:updateCompleteTableViewForFloor(runnerData.floor)
                    end
                elseif runnerData.state == GameConstants.STATE_GO then -- 去取菜路上的状态完毕后层数+1 进入收菜阶段
                    runnerData.floor = runnerData.floor + 1

                    local cookBoxPrice = PlayerInfo.getCookBoxForFloor(runnerData.floor).price

                    -- 有钱才停留
                    if cookBoxPrice > 0 then
                        runnerData.state = GameConstants.STATE_MAKE
                        attrId = GameConstants.ATTR_MAKE
                    elseif runnerData.floor >= PlayerInfo.getMaxFloor() then
                        runnerData.state = GameConstants.STATE_BACK
                    end
                elseif runnerData.state == GameConstants.STATE_BACK then -- 返回路上状态完毕后  判断是否还需要继续返回
                    runnerData.floor = runnerData.floor - 1

                    -- 达到顶部后，进入继续返回取菜
                    if runnerData.floor <= 0 then
                        runnerData.state = GameConstants.STATE_GO

                        PlayerInfo.addRunnerBox(runnerData.have_gold)
                        runnerData.have_gold = 0

                        if not init then
                            display.MainUI:updateRunnerBox()
                        end
                    end
                end

                local pData = { type = GameConstants.EntityTypeRunner, idx = idx, attrId = attrId }
                local delayTime = GameConfig.getDelayTimeByType(pData)
                runnerData.start_time = os.time()
                runnerData.deadline = os.time() + delayTime

                synch = true

                -- 更新动画
                if not init then
                    display.MainUI:updateRunnerAction(idx)
                end
            end
        end
    end

    return synch
end

-- 增加或减少待上菜金额
function PlayerInfo.addRunnerBox(gold)
    m_data.runner_box = m_data.runner_box + gold

    Sqlite3DB:update("player_data", { runner_box = m_data.runner_box })
end

-- 增加或减少待上菜金额
function PlayerInfo.getRunnerBox()
    return m_data.runner_box
end

-- 从指定层获取金币
function PlayerInfo.getFoodFromCookBox(floor, idx)
    local cookBoxData = PlayerInfo.getCookBoxForFloor(floor)
    local runnerData = PlayerInfo.getRunnerList()[idx]

    -- 传菜员可以接受的金币数
    local runnerGetNum = PlayerInfo.getRunnerCapacity(idx) - runnerData.have_gold
    -- 储物箱现有的金币数
    local cookBoxGiveNum = cookBoxData.price

    -- 取小值
    local price = math.min(runnerGetNum, cookBoxGiveNum)

    runnerData.have_gold = runnerData.have_gold + price
    PlayerInfo.deleteFromCookBox(floor, price)
end

-- 获取指定传菜员拥有的容量
function PlayerInfo.getRunnerCapacity(idx)
    local runnerData = PlayerInfo.getRunnerList()[idx]
    local base_capacity = runnerData.capacity
    local factor = GameConfig.getAttrEffect({ type = GameConstants.EntityTypeRunner, idx = idx, attrId = GameConstants.ATTR_CAPACITY })
    return base_capacity * factor
end

-- 获取指定服务员拥有的容量
function PlayerInfo.getWaiterCapacity(idx)
    local waiterData = PlayerInfo.getWaiterList()[idx]
    local base_capacity = waiterData.capacity
    local factor = GameConfig.getAttrEffect({ type = GameConstants.EntityTypeWaiter, idx = idx, attrId = GameConstants.ATTR_CAPACITY })
    return base_capacity * factor
end

-- 更新每层厨师信息
function PlayerInfo.updateCookList(init)
    local synch = false
    local cookList = PlayerInfo.getCookList()

    for floor = 1, #cookList do
        for idx = 1, 2 do
            synch = PlayerInfo.updateCook(floor, idx, init) or synch
        end
    end

    -- 同步到数据库
    if (synch) then
        Sqlite3DB:update("player_data", { floor_list = m_data.floor_list })
    end
end

-- 更新指定厨师信息
function PlayerInfo.updateCook(floor, idx, init)
    local synch = false
    local cookList = PlayerInfo.getCookList()
    local cookData = cookList[floor][idx]

    if cookData then
        if cookData.state == GameConstants.STATE_WAIT then -- 空闲状态
            cookData.state = GameConstants.STATE_MAKE
            local pData = { type = GameConstants.EntityTypeCook, floor = floor, idx = idx, attrId = GameConstants.ATTR_MAKE }
            local delayTime = GameConfig.getDelayTimeByType(pData)
            cookData.start_time = os.time()
            cookData.deadline = os.time() + delayTime

            -- 做菜阶段，从菜单中取出一个菜加到人物身上
            local foodId = Menu.popMenu(init)
            local price = Menu.getPriceForId(floor, idx, foodId)
            cookData.food = { id = foodId, price = price }

            synch = true

            -- 更新动画
            if not init then
                display.MainUI:updateCookAction(floor, idx)
            end
        else
            -- 时间到达
            if os.time() >= cookData.deadline then
                -- 更新状态
                local attrId = GameConstants.ATTR_MOVE
                if cookData.state == GameConstants.STATE_MAKE then -- 做菜状态
                    cookData.state = GameConstants.STATE_GO
                elseif cookData.state == GameConstants.STATE_GO then -- 送菜状态
                    cookData.state = GameConstants.STATE_BACK

                    -- 送完菜后 将菜到数据加到层中，并且从人物身上去除,然后更新UI显示
                    local foodData = cookData.food
                    PlayerInfo.insertToCookBox(floor, foodData)
                    cookData.food = nil

                    if not init then
                        display.MainUI:updateCompleteTableViewForFloor(floor)
                    end
                elseif cookData.state == GameConstants.STATE_BACK then -- 返回状态
                    cookData.state = GameConstants.STATE_MAKE
                    attrId = GameConstants.ATTR_MAKE

                    -- 返回后为做菜阶段，从菜单中取出一个菜加到人物身上
                    local foodId = Menu.popMenu(init)
                    local price = Menu.getPriceForId(floor, idx, foodId)
                    cookData.food = { id = foodId, price = price }

                end

                local pData = { type = GameConstants.EntityTypeCook, floor = floor, idx = idx, attrId = attrId }
                local delayTime = GameConfig.getDelayTimeByType(pData)
                cookData.start_time = os.time()
                cookData.deadline = os.time() + delayTime

                synch = true

                -- 更新动画
                if not init then
                    display.MainUI:updateCookAction(floor, idx)
                end
            end
        end
    end

    return synch
end

-- 将金币加入从对应层到储物箱中移除
function PlayerInfo.deleteFromCookBox(floor, price)
    local cook_box_data = m_data.cook_box[floor]
    cook_box_data.price = cook_box_data.price - price

    local foodData = cook_box_data.id_list

    -- 显示的食物价值已经超过总价值时，则删除超出的食物
    if cook_box_data.food_price > cook_box_data.price then
        for i = #foodData, 1, -1 do
            cook_box_data.food_price = cook_box_data.food_price - foodData[i].price
            table.remove(foodData, i)

            if cook_box_data.food_price < cook_box_data.price then
                break
            end
        end

    end

    Sqlite3DB:update("player_data", { cook_box = m_data.cook_box })
end

-- 将菜品加入到对应层到储物箱中
function PlayerInfo.insertToCookBox(floor, foodData)
    local cook_box_data = m_data.cook_box[floor]
    if table.nums(cook_box_data.id_list) < 4 then
        table.insert(cook_box_data.id_list, foodData)
        cook_box_data.food_price = cook_box_data.food_price + foodData.price
    end

    cook_box_data.price = cook_box_data.price + foodData.price
    Sqlite3DB:update("player_data", { cook_box = m_data.cook_box })
end

-- 将菜品加入到对应层到储物箱中
function PlayerInfo.getCookBoxShowNum(floor)
    local rlt = 0
    local cook_box_data = m_data.cook_box[floor]
    local food_list = cook_box_data.id_list

    if #food_list > 0 then
        local total_price = cook_box_data.price
        local price = 0

        for i = 1, #food_list do
            price = food_list[i].price + price

            if total_price >= price then
                rlt = rlt + 1
            else
                break
            end
        end
    end

    return rlt
end

-- 将菜品加入到对应层到储物箱中
function PlayerInfo.getCookBoxForFloor(floor)
    return m_data.cook_box[floor]
end

-- 获得某层厨师数量
function PlayerInfo.cookNumForFloor(floor)
    local floor_data = m_data.floor_list[floor]
    if not floor_data then
        return 0
    end

    return #floor_data
end

-- 获得传菜员列表
function PlayerInfo.getRunnerList()
    return m_data.runner_list
end

-- 获得传菜员数量
function PlayerInfo.getRunnerNum()
    local runner_list = m_data.runner_list

    return #runner_list
end

-- 创建新的传菜员
function PlayerInfo.addRunner()
    Audio.PlayEffect("music/upgrade.wav")
    local runnerData = Employee.new({ type = GameConstants.EntityTypeRunner })
    table.insert(m_data.runner_list, runnerData.m_data)

    -- 同步到数据库
    Sqlite3DB:update("player_data", { runner_list = m_data.runner_list })
end

-- 创建新的服务员
function PlayerInfo.addWaiter()
    Audio.PlayEffect("music/upgrade.wav")
    local waiterData = Employee.new({ type = GameConstants.EntityTypeWaiter })
    table.insert(m_data.waiter_list, waiterData.m_data)

    -- 同步到数据库
    Sqlite3DB:update("player_data", { waiter_list = m_data.waiter_list })
end

-- 获得服务员数量
function PlayerInfo.getWaiterList()
    return m_data.waiter_list
end

-- 获得服务员数量
function PlayerInfo.getWaiterNum()
    local waiter_list = m_data.waiter_list

    return #waiter_list
end

-- 创建新的层
function PlayerInfo.addFloor(floor)
    assert(#m_data.floor_list + 1 == floor and floor <= Floor.getMaxFloor(), "层数不对，floor:%d,m_floor:%d,cfg_floor:%d", floor, #m_data.floor_list, Floor.getMaxFloor())

    m_data.floor_list[floor] = {}

    -- 同步到数据库
    Sqlite3DB:update("player_data", { floor_list = m_data.floor_list })
end

PlayerInfo.init()