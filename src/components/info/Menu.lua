-- 菜单
Menu = {

}

function Menu.init()
    Menu.cfg = Sqlite3DB:query("menu")
    Menu.update()
end

function Menu.getConfigWithId(id)
    return Menu.cfg[id]
end

-- 更新菜单
function Menu.update()
    local offset = Menu.getMenuNum() - PlayerInfo.getMenuNum()

    -- 如果当前菜单数量不足则随机新菜
    if offset > 0 then
        local menu_list = PlayerInfo.get("menu_list")

        -- 生成本层所需的 菜单
        for i = 1, offset do
            local id = Menu.randOneMenu()
            local find = false
            for k, v in pairs(menu_list) do
                if v.id == id then
                    v.num = v.num + 1
                    find = true
                    break
                end
            end

            if not find then
                table.insert(menu_list, { id = id, num = 1 })
            end

        end

        PlayerInfo.set("menu_list", menu_list)
    end
end

-- 根据当前层数 随机生成一个菜单
function Menu.randOneMenu()
    -- 获取当前最大层数
    local floor = PlayerInfo.getMaxFloor()

    -- 获取当前层的菜单列表
    local menu_cfg = Floor.get(floor, "menu_list")
    local count = #menu_cfg
    local rand_index = math.random(count)
    return menu_cfg[rand_index]
end

-- 获取层数相对应的菜单数量
function Menu.getMenuNum(floor)
    if not floor then
        floor = PlayerInfo.getMaxFloor()
    end

    return Floor.get(floor, "menu_num")
end


-- 获取层数相对应的菜单数量
function Menu.popMenu(init)
    local menu_list = PlayerInfo.get("menu_list")
    local menu_data = menu_list[1]

    local id = menu_data.id
    if menu_data.num <= 1 then
        table.remove(menu_list, 1)
    else
        menu_data.num = menu_data.num - 1
    end

    Menu.update()

    if not init then
        display.MainUI:updateMenu()
    end
    
    return id
end

-- 获取菜品价值
function Menu.getPriceForId(floor, idx, foodId)
    local floorFactor = Floor.get(floor, "cooking_rate") -- 层数加成
    local attrFactor = GameConfig.getAttrEffect({ type = GameConstants.EntityTypeCook, floor = floor, idx = idx, attrId = 3 }) -- 属性等级加成
    local basePrice = Menu.getConfigWithId(foodId).price -- 基础价格

    local price = floorFactor * attrFactor * basePrice

    return price
end

Menu.init()