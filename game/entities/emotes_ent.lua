------------------------------------------------------------------------------------
-- game/entities/emotes_ent.lua
--
-- 表情单元
--
-- @module      emotes_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local emotes_ent = import('game/entities/emotes_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class emotes_ent
local emotes_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE             = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME             = 'emotes_ent module',
    -- 只读模式
    READ_ONLY               = false,
}

-- 实例对象
local this         = emotes_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local common       = common
local setmetatable = setmetatable
local pairs        = pairs
local rawset       = rawset
local emotes_unit  = emotes_unit
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function emotes_ent.super_preload()

end

------------------------------------------------------------------------------------
-- [行为] 使用指定表情
function emotes_ent.use_emotes_by_name(name)
    if common.is_move() then
        return false
    end
    -- 取表情ID列表
    local emotes_id_list = emotes_unit.emotes_id_list()
    for i = 1, #emotes_id_list do
        local id = emotes_id_list[i]
        if name == emotes_unit.get_emotes_name_byid(id) and this.is_exist_emotes(name) then
            -- 使用表情
            trace.output('使用：',name)
            emotes_unit.use_emotes(id)
            return true
        end
    end
    return false
end

------------------------------------------------------------------------------------
-- [条件] 是否存在指定表情
function emotes_ent.is_exist_emotes(name)
    if name and name ~= '' then
        return true
    end
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function emotes_ent.__tostring()
    return this.MODULE_NAME
end

------------------------------------------------------------------------------------
-- [内部] 防止动态修改(this.READ_ONLY值控制)
--
-- @local
-- @tparam       table     t                被修改的表
-- @tparam       any       k                要修改的键
-- @tparam       any       v                要修改的值
------------------------------------------------------------------------------------
function emotes_ent.__newindex(t, k, v)
    if this.READ_ONLY then
        error('attempt to modify read-only table')
        return
    end
    rawset(t, k, v)
end

------------------------------------------------------------------------------------
-- [内部] 设置item的__index元方法指向自身
--
-- @local
------------------------------------------------------------------------------------
emotes_ent.__index = emotes_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function emotes_ent:new(args)
    local new = {}
    -- 预载函数(重载脚本时)
    if this.super_preload then
        this.super_preload()
    end
    -- 将args中的键值对复制到新实例中
    if args then
        for key, val in pairs(args) do
            new[key] = val
        end
    end
    -- 设置元表
    return setmetatable(new, emotes_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return emotes_ent:new()

-------------------------------------------------------------------------------------
