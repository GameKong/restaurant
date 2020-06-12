local Money = class("Money")

-- 金币是否充足
function Money.isGoldEnough(gold)
    return PlayerInfo.getGold() >= gold
end

-- 增加或消耗金币
function Money.addGold(gold)
    local m_gold = PlayerInfo.getGold()
    m_gold = m_gold + gold
    PlayerInfo.setGold(m_gold)

    -- 刷新界面
    display.MainUI:setGold()
end

return Money