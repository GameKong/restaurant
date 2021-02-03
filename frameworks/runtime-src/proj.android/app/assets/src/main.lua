
-- 设置加载图像失败时是否弹出消息框
cc.FileUtils:getInstance():setPopupNotify(false)

-- 添加搜索路径，为了避免运行时获取不到目录文件，将其置顶
local writePath = cc.FileUtils:getInstance():getWritablePath()
cc.FileUtils:getInstance():addSearchPath(writePath)
cc.FileUtils:getInstance():addSearchPath(writePath .. "../res/")

require "config"
require "cocos.init"

local function main()
    local a = 10
    local  b = 1.2
    local c = math.ceil( a/b )
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
