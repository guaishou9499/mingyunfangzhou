------------------------------------------------------------------------------------
-- game/entities/dungeon_cir_ent.lua
--
-- 循环刷副本
--
-- @module      dungeon_cir_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local dungeon_cir_ent    = import('game/entities/dungeon_cir_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class dungeon_cir_ent
local dungeon_cir_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION          = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE      = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME      = 'other_task_ent module',
    -- 只读模式
    READ_ONLY        = false,
}

-- 实例对象
local this           = dungeon_cir_ent
-- 日志模块
local trace          = trace
-- 决策模块
local decider        = decider
local table          = table
local setmetatable   = setmetatable
local pairs          = pairs
local rawset         = rawset
local actor_unit     = actor_unit
local import         = import
---@type dungeon_cir_res
local dungeon_cir_res = import('game/resources/dungeon_cir_res')
---@type quest_ent
local quest_ent       = import('game/entities/quest_ent')
---@type user_set_ent
local user_set_ent    = import('game/entities/user_set_ent')
local dungeon_res     = import('game/resources/dungeon_res')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function dungeon_cir_ent.super_preload()

end

-- 保存可接任务信息[中转]
local can_accept = {}

------------------------------------------------------------------------------------
-- [行为] 接指定任务
dungeon_cir_ent.execute_accept_task = function()
    quest_ent.finish_task()
    if not table.is_empty(can_accept) then
        quest_ent.move_to_fb_entrance(can_accept.map_pos,can_accept.move_to,can_accept.check_move)
    end
end

------------------------------------------------------------------------------------
-- [条件] 是否需要接取任务
dungeon_cir_ent.is_need_do_dungeon = function()
    -- 是否需做主线
    if  not quest_ent.is_stop_main_task() then
        return false,'执行-主线'
    end
    local map_name = actor_unit.map_name()
    -- 是否在混沌
    if map_name == '混沌地牢' then
        return false,'执行-混沌地牢'
    end
    -- 是否在讨伐
    if dungeon_res.is_in_stars_guard() then
        return false,'执行-讨伐星辰'
    end
    -- 保存需执行的副本
    local read_list    = {}
    -- 需要执行的任务资源列表
    local list         = dungeon_cir_res.MUST_DO_TASK
    -- 任务已接取时返回 false
    for _,v in pairs(list) do
        local task_info = quest_ent.get_quest_info_by_task_name(v.task_name)
        if not table.is_empty(task_info) then
            return false,'执行-已接任务'
        end
    end
    -- 遍历可刷任务-1
    for fb_name,v in pairs(list) do
        if user_set_ent[fb_name] and user_set_ent[fb_name] >= 1 then
            v.move_to.select_level = user_set_ent[fb_name] - 1
            v.fb_name      = fb_name
            table.insert(read_list,v)
        end
    end
    -- 遍历可刷任务-2
    if not table.is_empty(read_list) then
        table.sort(read_list,function(a, b) return a.idx < b.idx end)
        can_accept = read_list[1]
        return true
    end
    return false,''
end

------------------------------------------------------------------------------------
-- [条件] 是否循环任务
dungeon_cir_ent.is_need_cir_fb = function()
    -- 需要执行的任务资源列表
    local list         = dungeon_cir_res.MUST_DO_TASK
    -- 任务已接取时返回 false
    for fb_name,v in pairs(list) do
        if user_set_ent[fb_name] == 1 then
            local task_info = quest_ent.get_quest_info_by_task_name(v.task_name)
            if not table.is_empty(task_info) then
                return true
            end
        end
    end
    -- 遍历可刷任务-1
    for fb_name,v in pairs(list) do
        if user_set_ent[fb_name] == 1 then
            return true
        end
    end
    return false,'没有循环任务'
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function dungeon_cir_ent.__tostring()
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
function dungeon_cir_ent.__newindex(t, k, v)
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
dungeon_cir_ent.__index = dungeon_cir_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function dungeon_cir_ent:new(args)
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
    return setmetatable(new, dungeon_cir_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return dungeon_cir_ent:new()

-------------------------------------------------------------------------------------
