UIHelper = {}

function UIHelper.setBtnGray(button, gray, forState)
    assert(type(gray) == "boolean","gray is not a boolean value")
    local state = gray and 1 or 0
    
    if forState then
        local scale9Sprite = button:getBackgroundSpriteForState(forState)
        scale9Sprite:setState(state)
    else
        local normal = button:getBackgroundSpriteForState(cc.CONTROL_STATE_NORMAL)
        normal:setState(state)
        
        local highLighted = button:getBackgroundSpriteForState(cc.CONTROL_STATE_HIGH_LIGHTED)
        highLighted:setState(state)
        
        local selected = button:getBackgroundSpriteForState(cc.CONTROL_STATE_SELECTED)
        selected:setState(state)
    end

    button.grayState = gray
end