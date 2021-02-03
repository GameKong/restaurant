local sqlite3 = require("sqlite3")

Sqlite3DB = class("Sqlite3DB")

local _db, _vm  --数据库句柄， 数据库状态

local dbName = "game.db"                             --数据库文件名称
local FileUtils = cc.FileUtils:getInstance()
local inPath = FileUtils:fullPathForFilename("game.db")  --包内数据库文件放res下
local dbPath = FileUtils:getWritablePath() .. dbName         --操作数据库路径

local function checkCopyDB() --查询可操作的数据库路径是否存在db，没有则从包内拷贝过去，通常在游戏第一次安装时用到
    print("cccccccc")
    print("ffffccccccc 1111",FileUtils:fullPathForFilename("assets/game.db"))

    if not io.exists(dbPath) then
        -- local content = io.readfile(dbName)
       local content = FileUtils:getDataFromFile(dbName)

        print("dddddddddd111 content",content)
        if content then
            print("eeeeeeeee")
            io.writefile(dbPath, content)
        end
    end
    print("fffffffff")
end

--[[获取版本号]]
function Sqlite3DB:getDBVersion()
    printf("[SQLite] DB version : " .. sqlite3.version())
end

-- 创建db数据库
function Sqlite3DB:openDB()
    Sqlite3DB.closeDB()  
    checkCopyDB() 
    _db = sqlite3.open(dbPath)
    print("aaaaaaaaa dbPath",dbPath)
    print(_db)
    print("aaaaaaaaabbb inPath",inPath)
    
end

function Sqlite3DB.closeDB()                        --关闭数据库
    if _db then
        _db:close()
        _db = nil
    end
end

-- 初始化表格
function Sqlite3DB:initDB()
    -- Demo表DDL语句
    local init_sql =     [=[
        CREATE TABLE numbers(num1,num2,str);
        INSERT INTO numbers VALUES(1,11,"ABC");
        INSERT INTO numbers VALUES(2,22,"DEF");
        INSERT INTO numbers VALUES(3,33,"UVW");
        INSERT INTO numbers VALUES(4,44,"XYZ");
        SELECT * FROM numbers;
    ]=]

    local showrow = function(udata, cols, values, names)
        assert(udata == 'init_sql')

        -- for i=1,cols do
        --    print('%s |-> %s',names[i],values[i]) 
        -- end
        local v, b = udata, table.concat(values, "-")
        printf('[SQLite-init] table %s rows %s', tableName, table.concat(values, "-"))

        return 0
    end
    _db:exec(init_sql, showrow, 'init_sql')
end

-- 插入数据
-- @tableName,表名
-- @tableParas,插入的数据，例如 tableParas = {column1 = 2, column2 = "ds4"}
function Sqlite3DB:insert(tableName, tableParas, show)
    local key_list = table.concat(table.keys(tableParas), ",")
    local value_list = table.concat(Utils.values(tableParas, function(v)
        return Utils.sqlChar(json.encode(v))
    end), ",")

    local insert_sql = string.format("INSERT INTO %s (%s) VALUES (%s);", tableName, key_list, value_list)

    if show then
        insert_sql = insert_sql .. ";SELECT * FROM numbers;"
    end

    local showrow = function(udata, cols, values, names)
        assert(udata == 'insert_sql')

        -- for i=1,cols do
        --    print('%s |-> %s',names[i],values[i]) 
        -- end
        printf('[SQLite-insert] table %s rows %s', tableName, table.concat(values, "-"))
        return 0
    end

    local ret = _db:exec(insert_sql, showrow, 'insert_sql')

    return ret == sqlite3.OK
end

--删除数据
-- @tableName,表名
-- @conditionParas,条件数据，例如 conditionParas = {"col1"=3, "col2"="ad"}
function Sqlite3DB:delete(tableName, conditionParas, show)
    local delete_sql = string.format("DELETE FROM %s", tableName)

    if type(conditionParas) == "table" then
        for k, v in pairs(conditionParas) do
            v = Utils.sqlChar(v)

            if string.find(delete_sql, "WHERE") then
                delete_sql = string.format("%s AND %s = %s", delete_sql, k, v)
            else
                delete_sql = string.format("%s WHERE %s = %s", delete_sql, k, v)
            end
        end
    end

    if show then
        delete_sql = delete_sql .. ";SELECT * FROM numbers;"
    end

    local showrow = function(udata, cols, values, names)
        assert(udata == 'delete_sql')

        -- for i=1,cols do
        --    print('%s |-> %s',names[i],values[i]) 
        -- end
        printf('[SQLite-delete] table %s rows %s', tableName, table.concat(values, "-"))
        return 0
    end

    local ret = _db:exec(delete_sql, showrow, 'delete_sql')

    return ret == sqlite3.OK
end

--修改数据
-- @tableName,表名
-- @tableParas,修改的数据，例如 tableParas = {"col1"=3, "col2"="ad"}
-- @conditionParas,条件数据，例如 conditionParas = {"col1"=3, "col2"="ad"}
function Sqlite3DB:update(tableName, tableParas, conditionParas, show)
    local setTable = {}
    for k, v in pairs(tableParas) do
        v = Utils.sqlChar(json.encode(v))
        local d = #setTable
        setTable[#setTable + 1] = string.format("%s = %s", k, v)
    end

    local setString = table.concat(setTable, ", ")
    local update_sql = string.format("UPDATE %s SET %s", tableName, setString)

    if type(conditionParas) == "table" then
        for k, v in pairs(conditionParas) do
            v = Utils.sqlChar(v)

            if string.find(update_sql, "WHERE") then
                update_sql = string.format("%s AND %s = %s", update_sql, k, v)
            else
                update_sql = string.format("%s WHERE %s = %s", update_sql, k, v)
            end
        end
    end

    if show then
        update_sql = update_sql .. ";SELECT * FROM player_data;"
    end

    local showrow = function(udata, cols, values, names)
        assert(udata == 'update_sql')

        -- for i=1,cols do
        --    print('%s |-> %s',names[i],values[i]) 
        -- end
        printf('[SQLite-update] table %s rows %s', tableName, table.concat(values, "-"))
        return 0
    end

    local ret = _db:exec(update_sql, showrow, 'update_sql')

    return ret == sqlite3.OK
end


-- 自定义查询数据
-- @tableName,表名
-- @sqlStr,条件数据，例如 sqlStr = "select * from tableName"
function Sqlite3DB:select(tableName, sqlStr)
    local rlt = {}

    local showrow = function(udata, cols, values, names)
        assert(udata == 'select_sql')

        local data = {}
        for i = 1, cols do
            data[names[i]] = values[i] and json.decode(values[i]) or nil
        end

        rlt[#rlt + 1] = data
        printf('[SQLite-delete] table %s rows %s', tableName, table.concat(values, "-"))
        return 0
    end

    local ret = _db:exec(sqlStr, showrow, 'select_sql')

    return rlt
end

-- 查询数据
-- @tableName,表名
-- @queryParas,查询的数据，例如 queryParas = {"col1","col2"}
-- @conditionParas,条件数据，例如 conditionParas = {"col1"=3, "col2"="ad"}
function Sqlite3DB:query(tableName, queryParas, conditionParas)
    local colStr = "*"
    if queryParas and #queryParas > 0 then
        colStr = table.concat(queryParas, ", ")
    end

    local query_sql = string.format("SELECT %s FROM %s", colStr, tableName)

    if type(conditionParas) == "table" then
        for k, v in pairs(conditionParas) do
            v = Utils.sqlChar(v)

            if string.find(query_sql, "WHERE") then
                query_sql = string.format("%s AND %s = %s", query_sql, k, v)
            else
                query_sql = string.format("%s WHERE %s = %s", query_sql, k, v)
            end
        end
    end

    local ret = self:select(tableName, query_sql)

    return ret
end

-- 打开db
Sqlite3DB:openDB()