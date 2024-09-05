------------------------------------------------------------------------------------
-- game/entities/daily_quest_ent.lua
--
-- 关闭UI单元
--
-- @module      daily_quest_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local daily_quest_ent = import('game/entities/daily_quest_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class daily_quest_ent
local daily_quest_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION           = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE       = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME       = 'daily_quest_ent module',
    -- 只读模式
    READ_ONLY         = false,
}

-- 实例对象
local this            = daily_quest_ent
-- 日志模块
local trace           = trace
-- 决策模块
local decider         = decider
local common          = common
local table           = table
local type            = type
local pairs           = pairs
local setmetatable    = setmetatable
local ui_unit         = ui_unit
local item_unit       = item_unit
local import          = import
local daily_unit      = daily_unit
local quest_unit      = quest_unit
local actor_unit      = actor_unit
local local_player    = local_player
local daily_quest_res = import('game/resources/daily_quest_res')
---@type ui_ent
local ui_ent          = import('game/entities/ui_ent')
---@type map_ent
local map_ent         = import('game/entities/map_ent')
---@type map_res
local map_res         = import('game/resources/map_res')
---@type user_set_ent
local user_set_ent    = import('game/entities/user_set_ent')
---@type quest_ent
local quest_ent       = import('game/entities/quest_ent')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function daily_quest_ent.super_preload()

end

------------------------------------------------------------------------------------
-- [条件] 是否需要接日常
function daily_quest_ent.is_need_accept_day_task()
    local every_num = user_set_ent['每日可做次数']
    if every_num == 0 then
        return false,'没有开启日常次数'
    end
    -- 是否需做主线
    if not quest_ent.is_stop_main_task() then
        return false,'执行主线退出'
    end
    -- 积分领完毕 不继续做
    -- daily_unit.reward_is_active(4) daily_unit.reward_is_receive(4)
    if user_set_ent['轮刷周任务出金'] == 1 and daily_unit.reward_is_active(4) then
        return false,'已达70积分'
    end
    -- 当接取了指定的任务时退出当前模块
    local day_list   = this.get_daily_list()
    if #day_list == 0 then
        return false,'没有可接日常'
    end
    for _,v in pairs(day_list) do
        local task_info = quest_ent.get_quest_info_by_task_name(v)
        if not table.is_empty(task_info) then
            return false,'已接日常['..v..']'
        end
    end
    -- 当前角色已完成的日常次数
    local finish_num  = daily_unit.get_daily_quest_complate_num()
    -- 当前角色最大可做日常次数
    local max_num     = daily_unit.get_daily_quest_max_num()
    if user_set_ent['主角序号'] == trace.ROLE_IDX and every_num < 3 then
        every_num = 3
    end
    -- 配置设置的最大完成次数
    local ini_num     = every_num or max_num
    -- 计算可做次数
    max_num           = ini_num > max_num and max_num or ini_num
    -- 计算总完成次数 [缺少读取命令]
    local last_finish = ( trace.ROLE_IDX - 1 ) * max_num
    -- 可做的次数[每周最大9次 所有角色]
    local can_num     = 9 - last_finish
    -- 当前完成次数 小于 可完成次数
    if finish_num < max_num and finish_num < can_num then
        return true
    end
    return false,'日常次数不足'
end

------------------------------------------------------------------------------------
-- [判断] 判断指定任务是否已接取
------------------------------------------------------------------------------------
function daily_quest_ent.daily_quest_is_acc(quest,daily_type)
    local ret_b = false
    --if daily_quest_ent.open_daily_quest_wnd() then
    local list       = daily_unit.list(daily_type)
    local daily_obj  = daily_unit:new()
    for i = 1, #list do
        local obj = list[i]
        if daily_obj:init(obj)then
            local name = daily_obj:name()
            if daily_obj:is_accept() == 1 and common.is_exist_list_arg(quest,name) then
                ret_b = true
                break
            end
        end
    end
    daily_obj:delete()
    --end
    --daily_quest_ent.close_daily_quest_wnd()
    return ret_b
end

------------------------------------------------------------------------------------
-- [判断] 判断指定任务是否可接取
------------------------------------------------------------------------------------
function daily_quest_ent.is_can_accept_in_daily(quest_name,daily_type)
    local ret_b      = false
    local list       = daily_unit.list(daily_type)
    local daily_obj  = daily_unit:new()
    for i = 1, #list do
        local obj = list[i]
        if daily_obj:init(obj)then
            if daily_obj:can_accept() == 1 and common.is_exist_list_arg(quest_name,daily_obj:name(),true) then
                ret_b = true
                break
            end
        end
    end
    daily_obj:delete()
    return ret_b
end

-------------------------------------------------------------------------------------
-- [读取] 获取需执行每日日常列表
------------------------------------------------------------------------------------
daily_quest_ent.get_daily_list = function()
    local list             = {}
    -- 保存返回的任务名称
    local r_list           = {}
    local equip_prop_level = item_unit.get_equip_prop_level()
    for name,info in pairs(daily_quest_res.EVERY_DAY_QUEST) do
        -- 当前任务开启接取
        if info and info.is_open and equip_prop_level >= ( info.power or 0 ) then
            if info.need_finish_task == '' or info.need_finish_task ~= '' and quest_ent.is_finish_quest_by_map_id_and_name(info.need_finish_task,info.need_finish_task) then
                if this.is_can_accept_in_daily(name,0) then
                    local v = info
                    v.name  = name
                    table.insert(list,v)
                end
            end
        end
    end
    if not table.is_empty(list) then
        table.sort(list,function(a, b) return a.idx < b.idx end)
        for _,v in pairs(list) do
            if #r_list >= 3 then
                break
            end
            table.insert(r_list,v.name)
        end
    end
    return r_list
end

------------------------------------------------------------------------------------
-- [行为] 接取指定任务
------------------------------------------------------------------------------------
function daily_quest_ent.acc_daily_quest(quest,daily_type)
    local ret_b      = false
    local daily_obj  = daily_unit:new()
    local list       = daily_unit.list(daily_type)
    local prop_level = item_unit.get_equip_prop_level()
    prop_level       = prop_level < 500 and 500 or prop_level
    for i = 1, #list do
        local obj = list[i]
        if daily_obj:init(obj) and prop_level >= daily_obj:equip_level() then
            local can_acc = false
            local name    = daily_obj:name()
            if common.is_exist_list_arg(quest,name) then
                can_acc = true
            end
            if can_acc and daily_obj:can_accept() == 0 then
                can_acc = false
            end
            if can_acc and daily_obj:is_accept() ~= 0 then
                can_acc = false
            end
            if can_acc then
                local quest_wnd = this.open_daily_quest_wnd()
                -- xxmsg(name..' '..tostring(quest_wnd))
                if quest_wnd then
                    ret_b = true
                    trace.output('接【'..name..'】')
                    -- xxmsg(name..' '..string.format('%X obj:%X',daily_obj:id(),obj))
                    daily_unit.accept(daily_obj:id())
                    decider.sleep(1000)
                    for j = 1, 100 do
                        if daily_obj:is_accept() == 1 then
                            break
                        end
                        decider.sleep(100)
                    end
                end
                break
            end
        end
    end
    daily_obj:delete()
    if ret_b then
        this.close_daily_quest_wnd()
    end
    return ret_b
end

------------------------------------------------------------------------------------
-- [行为] 完成指定任务
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function daily_quest_ent.finish_daily_quest(quest,quest_type)
    local ret_b     = false
    quest_type      = quest_type or 1
    local list      = quest_unit.list()
    local quest_obj = quest_unit:new()
    for i = 1, #list do
        local obj = list[i]
        if quest_obj:init(obj) then
            local over = false
            local name = quest_obj:name()
            if type(quest) == 'table' then
                for k = 1, #quest do
                    if quest[k] == name then
                        local branch_num = quest_obj:branch_num()
                        for j = 0, branch_num-1 do
                            if quest_obj:cur_tar_num(j) == quest_obj:cur_tar_max_num(j) then
                                over = true
                                break
                            end
                        end
                    end
                    if over then
                        break
                    end
                end
            elseif name == quest then
                local branch_num = quest_obj:branch_num()
                for j = 0, branch_num-1 do
                    if quest_obj:cur_tar_num(j) == quest_obj:cur_tar_max_num(j) then
                        over = true
                        break
                    end
                end
            end
            if common.is_exist_list_arg({ '混沌地牢','讨伐星辰守卫' },name)  and daily_unit.get_week_quest_complate_num() >= 3 then
                over = false
            end
            if over then
                quest_unit.complete(quest_obj:id(),-1)
                trace.output('完成【'..name..'】')
                decider.sleep(1000)
                for j = 1, 50 do
                    if not this.daily_quest_is_acc(quest,quest_type) then
                        break
                    end
                    decider.sleep(500)
                end
                ret_b = true
            end
        end
    end
    quest_obj:delete()
    return ret_b
end

------------------------------------------------------------------------------------
-- [行为] 打开每日窗口
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function daily_quest_ent.open_daily_quest_wnd()
    local ret = false
    local num = 1
    while decider.is_working() do
        common.wait_loading_map()
        if daily_unit.is_open_daily_wnd() then
            ret = true
            break
        end
        -- 在地牢状态 并且 非岛屿时 退出
        if actor_unit.is_dungeon_map() and not map_res.is_in_islet() then
            break
        end
        trace.output('打开每日窗口[' .. num .. ']')
        -- 关闭推荐消息页面
        ui_ent.esc_cinema()
        map_ent.move_go_away_tlsw()
        local w_time = 100
        local kill_dist = ( local_player:is_battle() or num > 3 ) and 800 or 200
        if not map_ent.move_to_kill_actor(nil,kill_dist) then
            w_time = 1000
            if not ui_unit.is_open_play_dir_wnd() and not daily_unit.is_open_daily_wnd() then
                trace.output('打开玩法目录')
                decider.sleep(1000)
                common.do_alt_key('KEY_Q')
                decider.sleep(3000)
            end
            if ui_unit.is_open_play_dir_wnd() and not daily_unit.is_open_daily_wnd() then
                trace.output('打开日常窗口')
                daily_unit.open_daily_wnd()
                decider.sleep(2000)
            end
            if num >= 30 then
                break
            end
            num = num + 1
        end
        decider.sleep(w_time)
    end

    return ret
end

------------------------------------------------------------------------------------
-- [行为] 关闭每日窗口
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function daily_quest_ent.close_daily_quest_wnd()
    local ret = false
    local num = 1
    while decider.is_working() do
        trace.output('关闭每日窗口[' .. num .. ']')
        if daily_unit.is_open_daily_wnd() or ui_unit.is_open_play_dir_wnd() then
            decider.sleep(1000)
            common.key_call('KEY_Esc')
        else
            break
        end
        if num >= 30 then
            break
        end
        num = num + 1
        decider.sleep(1000)
    end
    return ret
end

--	-- 注以下命令除了领所要进入日常 窗口别的读取都不用
--
--	-- 领取贡献奖励（从上往下0-4）
--	--daily_unit.receive_reward(idx)
--	-- 领取所有奖励
--	--daily_unit.receive_all_reward()
--	-- 取当前日常贡献点
--	--daily_unit.get_contribute_point()
--	-- 奖励是否已激活（0 - 4 注：这是的激活是贡献点达到，已领取后也为激活 ）
--	--daily_unit.reward_is_active(idx)
--	-- 奖励是否已领（0-4）
--	--daily_unit.reward_is_receive(idx)
--	-- 是否有可领取奖励
--	--daily_unit.has_reward()

function daily_quest_ent.receive_reward()
    -- 当前角色序号
    local role_idx       = trace.ROLE_IDX
    if role_idx ~= user_set_ent['主角序号'] then
        return
    end
    for idx = 0, 4 do
        -- xxmsg(idx..' '..tostring(daily_unit.reward_is_active(idx))..' '..tostring(daily_unit.reward_is_receive(idx)))
        if daily_unit.reward_is_active(idx) and not daily_unit.reward_is_receive(idx) then
            if this.open_daily_quest_wnd() then
                trace.output('领取'..idx..'号奖励')
                daily_unit.receive_reward(idx)
                decider.sleep(2000)
            end
        end
    end
    this.close_daily_quest_wnd()
end

-------------------------------------------------------------------------------------
---材料背包
-- test_pocket_item
function daily_quest_ent.test_pocket_item()
    local list = item_unit.pocket_item_list()
    xxmsg(string.format('物品数量%u', #list))
    for i = 1, #list do
        local obj = list[i]
        if item_ctx:init_pocket_item_obj(obj) then
            xxmsg(string.format("%X   res_id:%X    num:%06d    name:%s",
                    obj,
                    item_ctx:pocket_item_res_id(),
                    item_ctx:pocket_item_num(),
                    item_ctx:name()

            ))
        end

    end

    --材料背包物品资源ID取数量
    --item_unit.get_pocket_item_num_by_res_id(res_id)

end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function daily_quest_ent.__tostring()
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
function daily_quest_ent.__newindex(t, k, v)
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
daily_quest_ent.__index = daily_quest_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function daily_quest_ent:new(args)
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
    return setmetatable(new, daily_quest_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return daily_quest_ent:new()

-------------------------------------------------------------------------------------
