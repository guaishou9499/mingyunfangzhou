------------------------------------------------------------------------------------
-- game/entities/other_task_ent.lua
--
-- 其他必执任务：如岛屿 支线 连环任务等
--
-- @module      other_task_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local other_task_ent    = import('game/entities/other_task_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class other_task_ent
local other_task_ent = {
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
local this           = other_task_ent
-- 日志模块
local trace          = trace
-- 决策模块
local decider        = decider
local table          = table
local setmetatable   = setmetatable
local pairs          = pairs
local type           = type
local rawset         = rawset
local local_player   = local_player
local actor_unit     = actor_unit
local import         = import
local item_unit      = item_unit
---@type other_task_res
local other_task_res = import('game/resources/other_task_res')
---@type quest_ent
local quest_ent      = import('game/entities/quest_ent')
---@type user_set_ent
local user_set_ent   = import('game/entities/user_set_ent')
local dungeon_res    = import('game/resources/dungeon_res')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function other_task_ent.super_preload()

end

-- 保存可接任务信息[中转]
local can_accept = {}

------------------------------------------------------------------------------------
-- [行为] 接指定任务
other_task_ent.execute_accept_task = function()
    quest_ent.finish_task()
    if not table.is_empty(can_accept) and not table.is_empty(can_accept[1]) then
        quest_ent.accept_task(can_accept)
    end
end

------------------------------------------------------------------------------------
-- [条件] 是否需要接取任务
other_task_ent.is_need_accept_task = function(is_check_task,is_check_dun,is_check_tf)
    -- 人物等级小于50时不触发
    if local_player:level() < 50 then
        return false,''
    end
    -- 是否开启支线
    if user_set_ent['开启支线'] == 0 then
        return false,''
    end
    -- 是否需做主线
    if not is_check_task and not quest_ent.is_stop_main_task() then
        return false,''
    end
    local map_name = actor_unit.map_name()
    -- 是否在混沌
    if map_name == '混沌地牢' then
        return false,''
    end
    -- 是否在讨伐
    if dungeon_res.is_in_stars_guard() then
        return false,''
    end
    -- 需要执行的任务列表
    local list         = other_task_res.MUST_DO_TASK
    -- 获取主角序号设置
    local leading_idx  = user_set_ent['主角序号']
    -- 当前角色序号
    local role_idx     = trace.ROLE_IDX
    -- 任务已接取时返回 false
    for name,_ in pairs(list) do
        local task_info = quest_ent.get_quest_info_by_task_name(name)
        if not table.is_empty(task_info) then
            return false,''
        end
    end
    local curr_map_id = actor_unit.map_id()
    -- 存在未完成的任务并且可接时返回 true,优先接当前地图ID任务
    for name,v in pairs(list) do
        v.task_name        = name
        local r_map_id     = v.r_map_id or v.map_id or -1
        local curr_id      = r_map_id == -1 and curr_map_id or v.map_id
        local special_task = v.special_task
        local execute_read = true
        if not special_task and leading_idx ~= 0 and role_idx ~= leading_idx and leading_idx ~= 0 then
            execute_read   = false
        end
        if execute_read and curr_map_id == curr_id and not quest_ent.is_finish_quest_by_map_id_and_name(name,r_map_id) and this.is_can_accept(v) then
            -- xxmsg(name)
            return true
        end
    end
    -- 存在未完成的任务并且可接时返回 true,设置可接任务资源
    for name,v in pairs(list) do
        v.task_name        = name
        local r_map_id     = v.r_map_id or v.map_id or -1
        local special_task = v.special_task
        local execute_read = true
        if not special_task and leading_idx ~= 0 and role_idx ~= leading_idx and leading_idx ~= 0 then
            execute_read   = false
        end
        -- xxmsg(name..' '..r_map_id..' '..tostring(quest_ent.is_finish_quest_by_map_id_and_name(name,r_map_id))..' '..tostring(other_task_ent.is_can_accept(name)))
        if execute_read and not special_task and not quest_ent.is_finish_quest_by_map_id_and_name(name,r_map_id) and this.is_can_accept(v) then
            -- xxmsg(name..' '..r_map_id..' '..tostring(quest_ent.is_finish_quest_by_map_id_and_name(name,r_map_id))..' '..tostring(other_task_ent.is_can_accept(name)))
            return true
        end
    end
    return false,''
end

------------------------------------------------------------------------------------
-- [条件] 任务是否可接取
other_task_ent.is_can_accept = function(task_info)
    local info = other_task_res.ACCEPT_TASK[task_info.task_name]
    if not table.is_empty(info) then
        local g_info = info[1]
        -- 标记是否需要完成前置任务
        local need_task = false
        -- 标记是否需要读取到任务可接
        local need_can  = true
        if task_info.need_task and task_info.need_task ~= '' then
            if not quest_ent.is_finish_quest_by_map_id_and_name(task_info.need_task,task_info.need_task_map or -1) then
                need_task = true
            else
                -- 标记不从NPC判断任务是否完成
                if task_info.not_read_npc then
                    need_can = false
                end
            end
        end
        -- 是否战力限制
        local need_power = task_info.need_power
        if type(need_power) == 'number' then
            if item_unit.get_equip_prop_level() < need_power then
                need_task = true
            end
        end
        -- 无需前置任务,可接取时
        if not need_task then

            if not task_info.type
                    -- 对话接取的任务
                    and ( need_can and quest_ent.is_exist_quest_in_npc(g_info.npc_res_id,g_info.quest_id) ~= 0 or not need_can )
                    -- 采集接取任务
                    or task_info.type then
                -- xxmsg(task_info.task_name)
                can_accept = info
                return true
            end
        end
    end
    can_accept = {}
    return false
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function other_task_ent.__tostring()
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
function other_task_ent.__newindex(t, k, v)
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
other_task_ent.__index = other_task_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function other_task_ent:new(args)
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
    return setmetatable(new, other_task_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return other_task_ent:new()

-------------------------------------------------------------------------------------
