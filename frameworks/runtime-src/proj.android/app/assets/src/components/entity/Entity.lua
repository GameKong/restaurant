-- 人物对应的信息
local EntityData = {
    sid = "", -- 人物唯一id
    node = nil, -- 实体对应的节点
    type = GameConstants.EntityTypeWaiter, -- 类型 1.服务员，2.传菜员，3.厨师
    level = 1, -- 等级
    floor = 1, -- 所在层数 只有厨师会用到
}

--人物类
local Entity = class("Entity", EntityData)

function Entity:ctor()
    self.node = cc.Sprite:create();
end

return Entity