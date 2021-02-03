GameConfig = {

}

local IdToColName = {
    { "move_gold", "move_rate" }, -- 移动速度
    { "make_gold", "make_rate" }, -- 制作速度
    { "cooking_gold", "cooking_rate" }, -- 厨艺等级
    { "capacity_gold", "capacity_rate" }, -- 传菜员携带金币容量
}

local m_data = {
    cfg_common = {}
}

-- 初始化
function GameConfig.init()
    m_data.cfg_common = Sqlite3DB:query("common_config")
    m_data.cfg_employee = Sqlite3DB:query("employee")
    m_data.cfg_attr = Sqlite3DB:query("attr")
    m_data.cfg_attr_ui = Sqlite3DB:query("attr_ui")
end

function GameConfig.getCommonConfig()
    return m_data.cfg_common
end

function GameConfig.getEmployeeConfig(type)
    if type then
        return m_data.cfg_employee[type]
    end

    return m_data.cfg_employee
end

function GameConfig.getAtrrConfig()
    return m_data.cfg_attr
end

function GameConfig.getAttrUIConfig(attrId)
    if attrId then
        return m_data.cfg_attr_ui[attrId]
    end

    return m_data.cfg_attr_ui
end

function GameConfig.getAttrList(type)
    return GameConfig.getEmployeeConfig(type).attr_list
end

function GameConfig.getAttrEffect(data)
    local level
    if data.level then
        level = data.level
    else
        level = PlayerInfo.getEmployeeAttrLevel(data.type, data.floor, data.idx, data.attrId)
    end

    local colName = IdToColName[data.attrId][2]
    return GameConfig.getAtrrConfig()[level][colName]
end

function GameConfig.getNeedGoldForUpgradeAttr(data)
    local level
    if data.level then
        level = data.level
    else
        level = PlayerInfo.getEmployeeAttrLevel(data.type, data.floor, data.idx, data.attrId)
    end

    local colName = IdToColName[data.attrId][1]
    return GameConfig.getAtrrConfig()[level][colName]
end

function GameConfig.getMaxAttrLevel()
    return #GameConfig.getAtrrConfig()
end

-- 获取雇员某个动作所需要的时间
function GameConfig.getDelayTimeByType(data)
    local baseTime = m_data.cfg_employee[data.type]["base_time"][data.attrId]

    -- 厨师独有的层数到基础加成
    local floorRate = 1
    if data.type == GameConstants.EntityTypeCook then
        if data.attrId == GameConstants.ATTR_MOVE then
            floorRate = Floor.get(data.floor, "move_rate")
        elseif data.attrId == GameConstants.ATTR_MAKE then
            floorRate = Floor.get(data.floor, "make_rate")
        end
    end

    -- 属性加成
    local attrRate = GameConfig.getAttrEffect(data)
    local time = math.floor(baseTime / attrRate / floorRate + 0.5)

    return time
end

-- 获取招聘传菜员所需得金币
function GameConfig.getGoldForInviteRunner()
    local gold_list = GameConfig.getEmployeeConfig(GameConstants.EntityTypeRunner).invite_cost
    local num = PlayerInfo.getRunnerNum()

    return gold_list[num + 1]
end

-- 获取招聘服务员所需得金币
function GameConfig.getGoldForInviteWaiter()
    local gold_list = GameConfig.getEmployeeConfig(GameConstants.EntityTypeWaiter).invite_cost
    local num = PlayerInfo.getWaiterNum()

    return gold_list[num + 1]
end


GameConfig.init()