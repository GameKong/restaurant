--------------------------------
-- @module CODTableView
-- @author kongl

--[[--
    CODTableView用法
    local table = CODTableView.new({
        rect = cc.rect(100, 100, 600, 500),
        numbers = 50,
        cellSize = cc.size(#width,#height) --竖排修改height 横向修改width
    })
    :showCellAtIndex(handler(self, xx.showCell))
    :addTo(self)
    :reloadData() --reloadData最后调用
    
    params参数
    rect -- tableView的位置和大小，位置从左下角开始
    numbers -- cell的个数
    cellSize -- cell的高度
    showCell -- 加载cell回调（可选）
    direction -- 列表滑动方向，默认是纵向
    
    @function [parent=#CODTableView] setTouchEnabled --滑动有效
    @param enable boolean
    @return #self 节点
        
    @function [parent=#CODTableView] showCellAtIndex
    @param listener function 加载cell回调,传入参数有tableView,cell,idx,bNew
    @return #self 节点
    
    @function [parent=#CODTableView] updateCellAtIndex
    @param idx number 更新某个cell
    
    @function [parent=#CODTableView] insertCellAtIndex
    @param idx number 插入cell
    
    @function [parent=#CODTableView] removeCellAtIndex
    @param idx number 删除cell
    
    @function [parent=#CODTableView] setShowCellIndex --指定滚到某一行
    @param idx bAni 指定到某行 是否有滚动动画 默认无
    @return #self 节点
        
    @function [parent=#CODTableView] reloadData 刷新tableView
    
    @function [parent=#CODTableView] setNumbers
    @param number number 设置cell个数
    
    @function [parent=#CODTableView] getContentOffset
    @return offset 类型cc.p
    
    @function [parent=#CODTableView] setContentOffset
    @param offset 类型cc.p
    
    @function [parent=#CODTableView] refreshData 刷新tableView并保持当前位置
    
    --  以下方法要在reloadData前调用
    @function [parent=#CODTableView] scrollViewDidScroll
    @param listener function scrollViewDidScroll
    @return #self 节点
    
    @function [parent=#CODTableView] scrollViewDidZoom
    @param listener function scrollViewDidZoom回调
    @return #self 节点
    
    @function [parent=#CODTableView] tableCellHighlight
    @param listener function tableCellHighlight回调
    @return #self 节点
    
    @function [parent=#CODTableView] tableCellUnhighlight
    @param listener function tableCellUnhighlight回调
    @return #self 节点
    
    @function [parent=#CODTableView] tableCellWillRecycle
    @param listener function tableCellWillRecycle回调
    @return #self 节点
    
    @function [parent=#CODTableView] tableCellTouched
    @param listener function tableCellTouched回调
    @return #self 节点
]]

local CODTableView = class("CODTableView", function()
    return cc.Node:create()
end)

local threshold = 15

function CODTableView:ctor(params)
    self.tableRect = params.rect
    self.numbers = params.numbers
    self.cellSize = params.cellSize
    self.showCell = params.showCell
    self.direction = params.direction or cc.SCROLLVIEW_DIRECTION_VERTICAL

    self.tableView = cc.TableView:create(cc.size(params.rect.width, params.rect.height))
    
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
    	self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) --从上至下排列
    end
    
    self.canRefresh = true
    self.topRefresh = false
    self.bottomRefresh = false
    
    self.tableView:setDirection(self.direction)
    self.tableView:setPosition(cc.p(0, 0))
    self.tableView:setDelegate()
    self:addChild(self.tableView)
    
    self:setContentSize(cc.size(self.tableRect.width, self.tableRect.height))
    self:setPosition(self.tableRect.x, self.tableRect.y)
    
    self.tableView:registerScriptHandler(handler(self, CODTableView.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(handler(self, CODTableView.tableCellSizeForIndex), cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self, CODTableView.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self, CODTableView.scrollViewDidScroll__), cc.SCROLLVIEW_SCRIPT_SCROLL)
    -- self.tableView:registerScriptHandler(handler(self, CODTableView.scrollViewDidScrollEnd__), cc.SCROLLVIEW_SCRIPT_SCROLL_END)
end

function CODTableView:setCanRefresh(bRefresh)
    self.canRefresh = bRefresh
end

function CODTableView:setBounceable(enable)
    self.tableView:setBounceable(enable)
    return self
end

function CODTableView:setTouchEnabled(enable)
    self.tableView:setTouchEnabled(enable)
    return self
end

function CODTableView:showCellAtIndex(listener)
    self.showCell = listener
    return self
end

function CODTableView:updateCellAtIndex(idx)
    self.tableView:updateCellAtIndex(idx)
end

function CODTableView:cellAtIndex(idx)
    return self.tableView:cellAtIndex(idx)
end

function CODTableView:insertCellAtIndex(idx)
	self.tableView:insertCellAtIndex(idx)
end

function CODTableView:removeCellAtIndex(idx)
    self.tableView:removeCellAtIndex(idx)
end

function CODTableView:setShowCellIndex(idx, bAni, time) -- 滚动时间
    if idx >= self.numbers or idx < 0 then
    	return
    end
    
    local minOffset = self.tableView:minContainerOffset()
    local maxOffset = self.tableView:maxContainerOffset()

    local posX , posY = 0, 0
    for i=0 , self.numbers - 1 do
        if i == idx then
            break
        end
        local h , w = self:tableCellSizeForIndex(self.tableView,i)
        posX, posY = posX + w, posY + h
    end
    
    
    local viewSize = self.tableView:getViewSize()
    local containerSize = self.tableView:getContentSize()
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        if viewSize.height >= containerSize.height then
        	return
        end
    
    	posX = 0 
        posY = posY + minOffset.y
        
        if posY > maxOffset.y then
            posY = maxOffset.y
        end
    else
        if viewSize.width >= containerSize.width then
            return
        end
        
        posX = maxOffset.x - posX 
        posY = 0
        
        if posX < minOffset.x then
            posX = minOffset.x
        end
    end
    
    local b = bAni or false
    if b and time then
        self.tableView:setContentOffsetInDuration(cc.p(posX,posY), time)
    else
        self.tableView:setContentOffset(cc.p(posX,posY), b)    
    end    
    return self
end

--遍历清除列表所有节点的动作和定时器 ，如果在列表有帧动画需要播放，则需要重新reload列表
function CODTableView:stopAllAction()
    self.tableView:stopTween()
end

function CODTableView:reloadData()
    self.tableView:reloadData()
    return self
end

function CODTableView:setNumbers(number)
    self.numbers = number
    return self
end

function CODTableView:getContentOffset()
    return self.tableView:getContentOffset()
end

function CODTableView:setContentOffset(offset)
    self.tableView:setContentOffset(offset)
end

function CODTableView:refreshData(idx,fn)
    local offset = self.tableView:getContentOffset()
    if idx and fn then
        local h , w = self:tableCellSizeForIndex(self.tableView,idx)
        fn()
        self.tableView:reloadData()
        local h_h , w_w = self:tableCellSizeForIndex(self.tableView,idx)

        local minOffset = self.tableView:minContainerOffset()
        local maxOffset = self.tableView:maxContainerOffset()
        if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
            offset.y = offset.y + h - h_h
            
            if offset.y <= minOffset.y then
                offset.y = minOffset.y
            elseif offset.y >= maxOffset.y then
                offset.y = maxOffset.y
            end
        end
    else
        self.tableView:reloadData()
    end
    
    self.tableView:setContentOffset(offset)
end

function CODTableView:refreshData2()
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        local offset = self.tableView:getContentOffset()
        local minOffset = self.tableView:minContainerOffset()
        local maxOffset = self.tableView:maxContainerOffset()

        local overTop = offset.y - minOffset.y --计算超出列表顶部高度
        self:stopAllAction() --下拉上拉加载数据，列在滚动，最终定位会错误，需要先停了滚动事件
        self.tableView:reloadData()
        local minOffsetNew = self.tableView:minContainerOffset() --获取最新最小偏移
        local offsetY = minOffsetNew.y + overTop --偏移超出列表顶部高度
        if minOffsetNew.y > maxOffset.y or offsetY > maxOffset.y then --所有列表项数量在显示区内，修正不做偏移超出列表顶部高度
            offsetY = minOffsetNew.y
        end
        local offsetNew = cc.p(minOffsetNew.x, offsetY)
        self.tableView:setContentOffset(offsetNew)
    else
        local offset = self.tableView:getContentOffset()
        self:stopAllAction() --下拉上拉加载数据，列在滚动，最终定位会错误，需要先停了滚动事件
        self.tableView:reloadData()
        local minOffset = self.tableView:minContainerOffset()
        local maxOffset = self.tableView:maxContainerOffset()
        if offset.x < minOffset.x then
            offset.x = minOffset.x
        end
        if offset.x > maxOffset.x then
        	offset.x = maxOffset.x
        end
        self.tableView:setContentOffset(offset)
    end
end

function CODTableView:dragToRefresh__(refreshaTag)
    if nil ~= self.dragToRefreshSelector then
    	self.dragToRefreshSelector(refreshaTag)
    end
end

function CODTableView:dragToRefresh(listener)
    self.dragToRefreshSelector = listener
    return self
end

function CODTableView:scrollViewDidScroll__(view)
    if nil ~= self.scrollViewDidScrollSelector then
        self.scrollViewDidScrollSelector(view)
    end
    
    if self.canRefresh then
        local isDrag = view:isDragging()
        if isDrag then
            if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
                if self.beginDrag == nil then
                    self.beginDrag = view:getContentOffset().y
                end

                self.afterDrag = view:getContentOffset().y

                if view:getContentOffset().y < view:minContainerOffset().y - threshold and self.afterDrag < self.beginDrag  then
                    self.topRefresh = true
                end

                if view:getContentOffset().y > view:maxContainerOffset().y + threshold and self.afterDrag > self.beginDrag  then
                    self.bottomRefresh = true
                end
            end

            if self.direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL then
                if self.beginDrag == nil then
                    self.beginDrag = view:getContentOffset().x
                end

                self.afterDrag = view:getContentOffset().x

                if view:getContentOffset().x > view:maxContainerOffset().x + threshold and self.afterDrag > self.beginDrag then
                    self.topRefresh = true
                end

                if view:getContentOffset().x < view:minContainerOffset().x - threshold and self.afterDrag < self.beginDrag then
                    self.bottomRefresh = true
                end
            end
        end
    end
end

function CODTableView:scrollViewDidScroll(listener)
    self.scrollViewDidScrollSelector = listener
    return self
end

function CODTableView:scrollViewDidZoom(listener)
    self.tableView:registerScriptHandler(listener, cc.SCROLLVIEW_SCRIPT_ZOOM)
    return self
end

function CODTableView:scrollViewDidScrollEnd(listener)
    self.scrollViewDidScrollEndSelector = listener
    return self
end

-- function CODTableView:scrollViewDidScrollEnd__(view, bBound)
--     if nil ~= self.scrollViewDidScrollEndSelector then
--         self.scrollViewDidScrollEndSelector(view, bBound)
--     end
    
--     if not bBound then
--     	return
--     end
    
--     if self.topRefresh then
--         self.topRefresh = false
--         self.canRefresh = false
--         self.beginDrag = nil
--         self:dragToRefresh__("topRefresh")
--     end

--     if self.bottomRefresh then
--         self.bottomRefresh = false
--         self.canRefresh = false
--         self.beginDrag = nil
--         self:dragToRefresh__("bottomRefresh")
--     end
-- end

function CODTableView:tableCellHighlight(listener)
    self.tableView:registerScriptHandler(listener, cc.TABLECELL_HIGH_LIGHT)
    return self
end

function CODTableView:tableCellUnhighlight(listener)
    self.tableView:registerScriptHandler(listener, cc.TABLECELL_UNHIGH_LIGHT)
    return self
end

function CODTableView:tableCellWillRecycle(listener)
    self.tableView:registerScriptHandler(listener, cc.TABLECELL_WILL_RECYCLE)
    return self
end

function CODTableView:tableCellTouched(listener)
    self.tableView:registerScriptHandler(listener, cc.TABLECELL_TOUCHED)
    return self
end

function CODTableView:numberOfCellsInTableView(tableView)
    return self.numbers
end

function CODTableView:tableCellSizeForIndex(tableView,idx)
    if type(self.cellSize) == "table" then
    	return self.cellSize.width, self.cellSize.height
    elseif type(self.cellSize) == "function" then
        local size = self.cellSize(tableView,idx)
        return  size.width, size.height
    end
end

function CODTableView:tableCellAtIndex(tableView,idx) -- 使用调用对象获取指定 cell
    if 'number' == type(tableView) then
        idx = tableView
    	tableView = self.tableView
    end
    local cell=tableView:dequeueCell()
    local bNew = false
    if cell == nil then
        cell = cc.TableViewCell:new()
        bNew = true
    end
    
    if self.showCell then
        self.showCell(tableView, cell, idx, bNew)
    end
    
    return cell
end

return CODTableView