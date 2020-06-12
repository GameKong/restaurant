Utils = class("Utils")

function Utils.tostring(p)
    if (type(p) ~= "string") then
        tostring(p)
    end
    return p
end

function Utils.sqlChar(v)
    if (type(v) == "string") then
        v = string.format("'%s'", v)
    else
        v = Utils.tostring(v)
    end

    return v
end

-- 获取金币的简短字符串表示
function Utils.getGoldStr(gold)
    local rlt

    if gold > 1000000 then
        rlt = string.format("%.2fm", gold / 1000000)
    elseif gold > 1000 then
        rlt = string.format("%.2fk", gold / 1000)
    else
        rlt = string.format("%d", gold)
    end

    return rlt
end

function deep_copy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deep_copy(orig_key)] = deep_copy(orig_value)
        end
        setmetatable(copy, deep_copy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function Utils.keys(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

function Utils.values(hashtable,func)
    local values = {}
    for k, v in pairs(hashtable) do
        if func then
            v = func(v)
        end
        values[#values + 1] = v
    end
    return values
end