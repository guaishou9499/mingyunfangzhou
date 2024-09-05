------------------------------------------------------------------------------------
-- game/entities/pet_ent.lua
--
-- 实体示例
--
-- @module      pet_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local pet_ent = import('game/entities/pet_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class pet_ent
local pet_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE             = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME             = 'pet_ent module',
    -- 只读模式
    READ_ONLY               = false,
}

-- 实例对象
local this         = pet_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local setmetatable = setmetatable
local pairs        = pairs
local rawset       = rawset
local table        = table
local import       = import
local pet_unit     = pet_unit
local pet_ctx      = pet_ctx
local local_player = local_player
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function pet_ent.super_preload()

end

----------------------------------------------------------------------------------------
-- [行为] 召唤宠物
function pet_ent.execute_summon_pet()
    if local_player:level() < 11 then
        return
    end
    if pet_unit.get_cur_summon_id() then
        return
    end
    local list = this.get_pet_info_list()
    for _,v in pairs(list) do
        if not v.summon then
            trace.output('召唤：',v.name)
            pet_unit.summon(v.id)
            decider.sleep(2000)
            break
        end
    end
end

----------------------------------------------------------------------------------------
-- [读取] 获取所有宠物信息
function pet_ent.get_pet_info_list()
    local list = pet_unit.list()
    local ret  = {}
    for i = 1, #list do
        local obj = list[i]
        if pet_ctx:init(obj) then
            --xxmsg(string.format('obj:%X    id%16X   is_summon:%-6s   name:%s',
            --        obj,
            --        pet_ctx:id(),
            --        pet_ctx:is_summon(),
            --        pet_ctx:name()
            --
            --))
            local result = {
                obj       = obj,
                id        = pet_ctx:id(),
                is_summon = pet_ctx:is_summon(),
                name      = pet_ctx:name(),
            }
            table.insert(ret,result)
        end
    end
    -- 召唤 宠物
    -- pet_unit.summon(id)
    -- 当前召唤宠物ID
    -- pet_unit.get_cur_summon_id()
    return ret
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function pet_ent.__tostring()
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
function pet_ent.__newindex(t, k, v)
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
pet_ent.__index = pet_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function pet_ent:new(args)
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
    return setmetatable(new, pet_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return pet_ent:new()

-------------------------------------------------------------------------------------
