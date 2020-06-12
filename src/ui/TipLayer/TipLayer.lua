local TipLayer = {}

-- 展示短暂的tip消息
function TipLayer.showTip(tip)
    local proxy = cc.CCBProxy:create()
    local ccbNode = CCBReaderLoad("ccbi/Tip.ccbi", proxy, nil)
    ccbNode:align(display.CENTER, display.cx, display.cy):addTo(display.TipLayer)
    ccbNode:setIgnoreAnchorPointForPosition(false)

    ccbNode:getChildByTag(1):setString(tip)

    ccbNode:runAction(cc.Sequence:create(
    cc.DelayTime:create(0.3),
    cc.MoveTo:create(0.8, cc.p(display.cx, display.cy + 200)),
    cc.FadeOut:create(0.5),
    cc.CallFunc:create(function()
        ccbNode:removeFromParent()
    end)))
end

return TipLayer