local PopStyle = class("PopStype", function()
    return cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
end)

function PopStyle:ctor(params)
    self.view = params.classOwner.mNode
    self.classOwner = params.classOwner
    self:initStyle()
end

function PopStyle:initStyle()
    self:setTouchEnabled(true)
    self:setSwallowsTouches(true)
    self:registerScriptTouchHandler(handler(self, function(send, type)
        -- 屏蔽触摸
        return true
    end))

    self.view:align(display.CENTER, display.cx, display.cy):setIgnoreAnchorPointForPosition(false):addTo(self)
end

function PopStyle:getViewContent()
    return self.view
end

return PopStyle