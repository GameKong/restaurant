local Employee = class("Employee", function(data)
    local employee = {}

    if data.type == GameConstants.EntityTypeCook then
        employee.m_data = {
            type = GameConstants.EntityTypeCook,
            floor = 1, -- 所属层
            idx = 1, -- 位置索引
            attr = { 1, 1, 1, 1 }, -- 移动速度等级,制作速度等级,厨艺等级,携带容量等级
            state = GameConstants.STATE_WAIT, -- 角色当前状态
            start_time = 0,
            deadline = 0,
            food = nil, -- 当前所持有的食物信息
        }
    elseif data.type == GameConstants.EntityTypeRunner then
        employee.m_data = {
            type = GameConstants.EntityTypeRunner,
            floor = 0, -- 当前所在层
            attr = { 1, 1, 1, 1 }, -- 移动速度等级,制作速度等级,厨艺等级,携带容量等级
            state = GameConstants.STATE_WAIT, -- 角色当前状态
            start_time = 0,
            deadline = 0,
            have_gold = 0, -- 当前所持有的金币数量
            capacity = GameConfig.getEmployeeConfig(GameConstants.EntityTypeRunner).capacity
        }
    elseif data.type == GameConstants.EntityTypeWaiter then
        employee.m_data = {
            type = GameConstants.EntityTypeWaiter,
            attr = { 1, 1, 1, 1 }, -- 移动速度等级,制作速度等级,厨艺等级,携带容量等级
            state = GameConstants.STATE_WAIT, -- 角色当前状态
            start_time = 0,
            deadline = 0,
            have_gold = 0, -- 当前所持有的金币数量
            capacity = GameConfig.getEmployeeConfig(GameConstants.EntityTypeWaiter).capacity
        }
    end

    return employee
end)

function Employee:ctor(data)
    if data then
        for k, v in pairs(data) do
            self.m_data[k] = v
        end
    end
end

return Employee