-- 游戏常量
GameConstants = {
    EntityTypeWaiter = 1, --类型-服务员
    EntityTypeRunner = 2, --类型-传菜员
    EntityTypeCook = 3, --类型-厨师

    ATTR_MOVE = 1, -- 属性 移动速度等级
    ATTR_MAKE = 2, -- 属性 制作(取菜)速度等级
    ATTR_COOKING = 3, -- 属性 厨艺等级
    ATTR_CAPACITY = 4, -- 容量 升级增加传菜员携带容量

    STATE_WAIT = 0,
    STATE_MAKE = 1,
    STATE_GO = 2,
    STATE_BACK = 3,
    STATE_PUSH = 4,
    STATE_POP = 5,
}