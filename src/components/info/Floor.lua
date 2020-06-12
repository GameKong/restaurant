-- 开启地层模块
Floor = {
   
}
-- 初始化
function Floor.init()
    Floor.cfg_floor = Sqlite3DB:query("floor")
end

-- 获取层数相关信息
function  Floor.get(floor, key)
    return Floor.cfg_floor[floor][key]
end

-- 获取开启每层所需金币
function Floor.getGoldForOpenFloor(floor)
    assert(floor <= Floor.getMaxFloor(), "参数层%d超出了最大索引%d", floor,Floor.getMaxFloor()) 
    return Floor.cfg_floor[floor].needGold
end

-- 获取指定层指定索引对应的招聘厨师的消耗
function  Floor.getInviteCost(floor,idx)
    return Floor.cfg_floor[floor].invite_cost[idx]
end

-- 表格配置的总层数
function Floor.getMaxFloor()
    return #Floor.cfg_floor
end

Floor.init()
