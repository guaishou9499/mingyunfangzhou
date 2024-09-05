------------------------------------------------------------------------------------
-- game/entities/quest_ent.lua
--
-- 执行主线的单元
--
-- @module      quest_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local quest_ent = import('game/entities/quest_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class quest_ent
local quest_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION           = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE       = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME       = 'quest module',
    -- 只读模式
    READ_ONLY         = false,
    -- 主线读取类型[ -1, 0, 1]
    MAIN_TASK_TYPE    = -1,
    -- 当前断资源 的任务名称 当任务在当前任务时 终止任务
    STOP_QUEST_NAME   = '艾尔菲斯1',
    -- 当前任务对应的地图ID
    STOP_QUEST_MAP_ID = 0,
}

-- 实例对象
local this            = quest_ent
-- 日志模块
---@type trace
local trace           = trace
-- 公共模块
---@type common
local common          = common
-- 决策模块
local decider         = decider
local table           = table
local type            = type
local pairs           = pairs
local math            = math
local string          = string
local item_unit       = item_unit
local quest_ctx       = quest_ctx
local quest_unit      = quest_unit
local actor_unit      = actor_unit
local game_unit       = game_unit
local local_player    = local_player
local dungeon_unit    = dungeon_unit
local daily_unit      = daily_unit
local import          = import
---@type actor_ent
local actor_ent       = import('game/entities/actor_ent')
---@type ui_ent
local ui_ent          = import('game/entities/ui_ent')
---@type quest_res
local quest_res       = import('game/resources/quest_res')
---@type music_ent
local music_ent       = import('game/entities/music_ent')
---@type emotes_ent
local emotes_ent      = import('game/entities/emotes_ent')
---@type map_ent
local map_ent         = import('game/entities/map_ent')
---@type item_ent
local item_ent        = import('game/entities/item_ent')
---@type equip_ent
local equip_ent       = import('game/entities/equip_ent')
---@type vehicle_ent
local vehicle_ent     = import('game/entities/vehicle_ent')
---@type loop_ent
local loop_ent        = import('game/entities/loop_ent')
---@type shop_ent
local shop_ent        = import('game/entities/shop_ent')
local actor_res       = import('game/resources/actor_res')
local user_set_ent    = import('game/entities/user_set_ent')
---@type dungeon_res
local dungeon_res     = import('game/resources/dungeon_res')
--------------------------------------------------------------------------------
-- [行为] 接受任务
--------------------------------------------------------------------------------
quest_ent.accept_task = function(task_list)
    local close_npc = false
    local success   = false
    if not table.is_empty(task_list) then
        for _,v in pairs(task_list) do
            local k_dis     = 200
            while decider.is_working() do
                -- 任务名称
                local task_name    = v.task_name
                -- 接取任务的NPC资源ID
                local npc_res_id   = v.npc_res_id
                -- 任务已配置好的任务ID
                local quest_id     = v.quest_id
                -- 任务接取类型【非NPC时】
                local acc_type     = v.type
                -- 任务接取地图ID
                local acc_map_id   = v.map_id
                -- 接取任务NPC名称
                local npc_name     = v.npc_name or ''
                -- 接取任务地图名称
                local map_name     = v.map_name or actor_unit.map_name()
                -- 接取任务场景名称
                local area_name    = v.area_name or ''
                -- 标记是否从NPC判断任务是否可接
                local not_read_npc = v.not_read_npc
                local x            = v.x
                local y            = v.y
                local z            = v.z
                local r            = v.r or 300
                -- 检测打怪的范围
                k_dis              = v.kill_dis or 200
                -- 执行等待延迟
                local w_time       = 1000
                --  任务ID 不等于 0 时 任务已接成功
                if this.get_quest_id_by_task_name(task_name) ~= 0 then
                    success = true
                    break
                end
                -- 没有传入NPC时退出
                if not npc_res_id and not quest_id then
                    break
                end
                -- 指定的NPC是否存在指定的任务【可接】
                if not acc_type and not not_read_npc and this.is_exist_quest_in_npc(npc_res_id,quest_id) ~= 2 then
                    break
                end
                -- 指定任务是否完成
                if ( acc_type or not_read_npc ) and this.is_finish_quest_by_map_id_and_name(task_name,acc_map_id) then
                    break
                end
                -- 移动到目标点
                if map_ent.move_to(map_name,area_name,x,y,z,r) then
                    -- 获取NPC信息
                    local npc_info = {} -- actor_ent.get_nearest_npc_info_for_list(npc_name)
                    -- 非采集后接取的类型时引用NPC信息
                    if not acc_type then
                        if type(npc_name) == 'string' then
                            npc_info = actor_ent.get_nearest_npc_info_for_list(npc_name)
                        else
                            npc_info = actor_ent.get_actor_info_by_res_id(npc_name,3)
                        end
                    else
                        npc_info = actor_ent.get_nearest_gather_info_list(6,npc_res_id)
                    end
                    if not table.is_empty(npc_info) then
                        if npc_info.dist < 200 then
                            close_npc = true
                            w_time = 1000
                            if not acc_type then
                                -- 打开NPC对话窗口
                                if actor_unit.get_cur_talk_npc_id() == 0 then
                                    local attack = map_ent.move_to_kill_actor(nil,k_dis)
                                    if not attack then
                                        if local_player:dist_xy(npc_info.cx,npc_info.cy) <= 200 then
                                            trace.output('打开【',npc_info.name,'】对话')
                                            actor_unit.npc_talk(npc_info.id, 1)
                                            decider.sleep(1500)
                                            if actor_unit.get_cur_talk_npc_id() == 0 then
                                                common.key_call('KEY_G')
                                                decider.sleep(1000)
                                            end
                                            if actor_unit.get_cur_talk_npc_id() == 0 then
                                                local actor_num = actor_ent.get_actor_num_by_pos(nil,nil,nil,1000,2)
                                                if actor_num > 0 then
                                                    k_dis = 1000
                                                end
                                            end
                                        end
                                    else
                                        w_time = 100
                                    end
                                end
                            else
                                common.key_call('KEY_G')
                                decider.sleep(1000)
                                common.wait_over_state()
                                decider.sleep(1000)
                            end
                            if v.accept_type ~= 1 then
                                if not acc_type and actor_unit.get_cur_talk_npc_id() ~= 0 then
                                    trace.output('1.接【',task_name,'】')
                                    xxmsg(string.format('%X  %X',actor_unit.get_cur_talk_npc_id(),quest_id))
                                    quest_unit.accept(quest_id)
                                    decider.sleep(2000)
                                end
                                if acc_type and quest_unit.get_quest_summary_wnd() > 0 then
                                    trace.output('2.接【',task_name,'】')
                                    ui_ent.accept_task()
                                    decider.sleep(2000)
                                end
                            else
                                common.do_shift_key('KEY_G')
                                decider.sleep(1000)
                                common.key_call('KEY_G')
                                decider.sleep(1000)
                            end
                        else
                            if not common.is_move() then
                                -- xxmsg(npc_info.cx..' '..npc_info.cy..' '..npc_info.cz)
                                common.auto_move(npc_info.cx,npc_info.cy,npc_info.cz)
                            end
                        end
                    end
                end
                decider.sleep(w_time)
            end
            if success then
                break
            end
        end
    end
    if close_npc then
        if actor_unit.get_cur_talk_npc_id() ~= 0 then
            ui_ent.exist_npc_talk()
            decider.sleep(1000)
        end
    end
    return success
end

-------------------------------------------------------------------------------------
-- [行为] 移动到指定副本入口
quest_ent.move_to_fb_entrance = function(map_pos,move_to,check_move)
    if map_ent.move_to(map_pos.map_name,map_pos.area_name,move_to.x,move_to.y,move_to.z,move_to.r) then
        this.enter_task_fb(move_to.select_level)
        if not table.is_empty(move_to) then
            if actor_unit.map_name() == map_pos.map_name then
                if not table.is_empty(check_move) then
                    map_ent.move_curr_map_to(map_pos.map_name,map_pos.area_name,check_move.x,check_move.y,check_move.z,check_move.r)
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------
-- [行为] 自动执行任务
quest_ent.auto_execute_quest = function()
    -- 任务类型：主线  支线  连锁支线 远征队 限时 特殊  世界  剧情副本
    -- 遍历面板任务  排序  执行主线
    while decider.is_working() do
        common.wait_loading_map()
        ui_ent.esc_cinema()
        local w_time = 2000
        local task_name = this.get_priority_quest_info()
        if task_name == '' then
            trace.output('没有可执任务,任务需资源设置')
        else
            local task_info = this.get_quest_info_by_task_name(task_name)
            loop_ent.looping()
            if not table.is_empty(task_info) then
                local branch_info = task_info.branch_info
                local g_task_res  = quest_res.QUEST_INFO[task_name]
                local global_func = g_task_res['全局执行']--
                -- 此任务 全部执行一个函数
                if global_func and global_func ~= '' then
                    common.execute_function_by_name(global_func)
                else
                    for _,v1 in pairs(branch_info) do
                        if decider.is_working() then
                            local branch_name = v1.branch_name
                            xxxmsg(2,branch_name.. ' idx:'..task_info.idx..' task_name:'..task_name..' '..task_info.id)
                            if '按搭乘或放入快捷栏，骑<FONT COLOR=\'#FF973A\'>马</FONT>' == branch_name then
                                vehicle_ent.execute_down_riding()
                                vehicle_ent.auto_riding_vehicle()
                            elseif '前往<FONT color=\'#74AAE2\'>卢特兰城</FONT>内' == branch_name then
                                w_time = 5000
                            end
                            this.finish_task()
                            this.do_task(task_name,branch_name,task_info.idx,g_task_res)
                        end
                    end
                end
            else
                trace.output(task_name,'没有任务资源')
            end
        end
        decider.sleep(w_time)
    end
end

--------------------------------------------------------------------------------
-- [条件] 是否终止主线
--------------------------------------------------------------------------------
quest_ent.is_stop_main_task = function()
    if user_set_ent['开启主线'] ~= 1 then
        return true
    end
    -- 标记是否终止主线
    local stop_task      = false
    -- 当前角色序号
    local role_idx       = trace.ROLE_IDX
    -- 连接状态
    local connect        = game_unit.get_connect_status()
    if connect == 9 then
        local map_name = actor_unit.map_name()
        -- 是否在混沌
        if map_name == '混沌地牢' then
            return true
        end
        -- 是否在讨伐
        if dungeon_res.is_in_stars_guard() then
            return true
        end
        -- 是否在深渊

        -- 获取当前最优执行任务
        local task_name,task_type = this.get_priority_quest_info()
        -- 当前任务类型为 剧情副本  或者 限时 时
        if string.find(task_type,'剧情')
                or string.find(task_type,'限时')
                or string.find(task_type,'日常') then
            return false
        end
        -- 当前装备评分等级
        local equip_prop_level    = item_unit.get_equip_prop_level()
        -- 当前人物战斗等级
        local level               = local_player:level()
        -- 是否在地牢地图
        local is_in_dungeon_map   = actor_unit.is_dungeon_map()
        -- 获取共鸣气息
        local get_fatigue_value   = dungeon_unit.get_fatigue_value()
        -- 优先获取装备500装等
        if equip_prop_level < 500 and equip_prop_level >= 250 and level >= 50 and not is_in_dungeon_map and get_fatigue_value >= 50 then
            -- 可做混沌地牢 装等小于 500 大于 250 时 跳出主线 执行混沌
            local list = daily_unit.list(1)
            if #list > 0 then
                return true
            end
        end
        -- 优先执行混沌
        if equip_prop_level > 500 and not is_in_dungeon_map and get_fatigue_value >= 50 then
            return true
        end
        -- 终止任务检测
        local open_kill = user_set_ent['野外挂机']
        if open_kill == 1 or role_idx ~= user_set_ent['主角序号'] then
            local stop_name = '冰封之海彼岸'
            local stop_map  = 11102
            -- 贝隆任务完成直升卷领取
            stop_task = this.is_finish_quest_by_map_id_and_name(stop_name,stop_map)
            if open_kill == 0 and user_set_ent['全部角色执主线'] ~= 0 then
                stop_task = false
            end
        else
            -- 是否已在资源结束任务
            local stop_res   = common.get_cache_result_ex('finish_quest_by_map_id_and_name',this.is_finish_quest_by_map_id_and_name,60,this.STOP_QUEST_NAME,this.STOP_QUEST_MAP_ID)
            if stop_res then
                stop_task = true
            end
        end
        -- 当前目标任务为断档-战力限制
        if not stop_task and quest_res.is_need_break_task(task_name) then
            stop_task = true
        end
        -- xxmsg(task_name..' stop_task:'..tostring(stop_task)..' ROLE_IDX：'..trace.ROLE_IDX..' 主角序号：'..user_set_ent['主角序号']..' is_must_to_do_task：'..tostring(quest_res.is_must_to_do_task(task_name)))
        -- 是否必须执行完毕的任务         -- 战力限制
        if quest_res.is_must_to_do_task(task_name) then
            return false
        end
    end

    return stop_task
end

-------------------------------------------------------------------------------------
-- [条件] 是否终止当前执行任务
quest_ent.is_stop_cur_quest = function(task_name,branch_name,quest_idx)
    local task_info = quest_res.QUEST_INFO[task_name]
    quest_idx       = quest_idx and math.floor(quest_idx) or -1
    -- 没有记录任务资源时退出
    --for name,value in pairs(task_info) do
    --    xxmsg(name..' '..branch_name)
    --end
    if not task_info or task_info and ( not task_info[branch_name] and not task_info[branch_name..quest_idx] ) then
        trace.output(task_name,' 分支没有资源')
        return true,{}
    end
    local task_info1 = task_info[branch_name..quest_idx] or task_info[branch_name]
    task_info1['任务类型'] = task_info['任务类型']
    -- 游戏数据中没有找到当前任务名 对应的 分支数据时退出任务执行
    if quest_ent.is_over_task(task_name,branch_name,quest_idx) then
        return true,{}
    end

    local check_task = this.get_priority_quest_info()
    if check_task ~= task_name then
        xxmsg('切换任务为:'..check_task)
        return true,{}
    end
    -- xxmsg(task_name..' '..branch_name..quest_idx..' '..task_info1['任务类型'])
    return false,task_info1
end

-------------------------------------------------------------------------------------
-- [行为] 执行指定任务
quest_ent.do_task = function(task_name,branch_name,quest_idx,g_task_res)
    local check_task_func = { func = this.is_stop_cur_quest,task_name = task_name,branch_name = branch_name,quest_idx = quest_idx }
    while decider.is_working() do
        -- 过图检测
        common.wait_loading_map()
        -- 获取当前任务是否可执行信息
        local is_stop, task_info = this.is_stop_cur_quest(task_name,branch_name,quest_idx)
        -- 需要终止当前任务 返回
        if is_stop then return false end
        -----------------------------------------------------
        -- 功能集合
        loop_ent.looping()
        -----------------------------------------------------
        -- 开始执行任务
        trace.output('做-',task_name)
        -- 执行特定函数
        local func_name  = task_info.func_name
        if func_name and func_name ~= '' then
            common.execute_function_by_name(func_name)
        else
            -----------------------------------------------------------------
            -- 执行当前主线时优先接的任务,当前为同时做支线任务的扩展
            local other_task = task_info.other_task
            if this.accept_task(other_task) then
                return false
            end
            -----------------------------------------------------------------
            -- 任务类型：需要购买指定物品
            local need_buy     = task_info.need_buy
            if not table.is_empty(need_buy) then
                -- 购买所在地图点
                local buy_map      = need_buy.buy_map or actor_unit.map_name()
                -- 购买的商店类型
                local shop_type    = need_buy.shop_type
                -- 购买名称
                local buy_name     = need_buy.buy_name
                -- 购买数量
                local buy_num      = need_buy.buy_num or 1
                shop_ent.buy_item(buy_map,shop_type,buy_name,buy_num)
                if item_ent.get_item_num_by_name(buy_name,nil,true) < buy_num then
                    trace.output('没有购买：'..buy_num..'个'..buy_name)
                    break
                end
            end
            -----------------------------------------------------------------
            -- 任务类型：需要采集指定数量的物品后提交
            local need_gather     = task_info.need_gather
            if not table.is_empty(need_gather) then
                this.go_gather_get_item(need_gather.item_name,need_gather.num or 1,need_gather.move_to,need_gather.gather,need_gather.close_attack)
            end
            -----------------------------------------------------------------
            -- 以下执行任务各种类型
            -----------------------------------------------------------------
            -- 检测是否远离后再次寻入
            local is_near_move = true
            -- 执行任务的地图信息
            local map_pos      = task_info.map_pos
            local map_name     = actor_unit.map_name() -- 执行的地图名称
            local map_id       = actor_unit.map_id()   -- 执行的地图ID
            local area_name    = ''                    -- 小场景名称
            local check_status = not table.is_empty(map_pos) and map_pos.check_status --检测状态寻路时
            local need_move    = not table.is_empty(map_pos) and map_pos.need_move -- true时 为必须执行地图检测
            local rollback     = not table.is_empty(map_pos) and map_pos.rollback  -- 反转路径
            local use_key_m    = not table.is_empty(map_pos) and map_pos.use_key  -- 寻到地图前使用key
            local stop_trans   = not table.is_empty(map_pos) and map_pos.stop_transfer -- true 时 停止当前地图目标的传送使用
            -- 在当前范围内时不触发路径寻路
            local pos_path_r   = not table.is_empty(map_pos) and map_pos.pos_path_r or 0
            if not table.is_empty(map_pos) and ( task_info['任务类型'] ~= '剧情副本' or need_move ) then
                map_name   = map_pos.map_name
                map_id     = map_pos.map_id
                area_name  = map_pos.area_name
            end
            if check_status and actor_unit.get_local_player_status() == check_status then
                common.key_call('KEY_R')
            end
            -- 切换地图前使用指定KEY
            if use_key_m then
                decider.sleep(2000)
                ui_ent.esc_cinema()
                common.key_call(use_key_m)
                common.wait_over_state()
                decider.sleep(5000)
            end
            -- 移动到大海
            map_ent.move_to_sea(map_name)
            -- 移动到地图
            map_ent.move_to_map(map_name,check_task_func,stop_trans)   --移动到地图
            -----------------------------------------------------------------
            -- 任务类型：移动到指定坐标
            local move_to      = task_info.move_to
            local x            = move_to.x                  -- 坐标x
            local y            = move_to.y                  -- 坐标y
            local z            = move_to.z                  -- 坐标z
            local r            = move_to.r                  -- 距离范围退出
            local kill_z       = move_to.kill_z             -- 攻击高度的设置
            local active_name  = move_to.active_name        -- 去目标点前 优先激活指定传送柱
            local check_statu2 = not table.is_empty(move_to) and move_to.check_status --检测状态寻到时
            local reset_move   = true                       -- 标记是否可执行寻路
            local use_key      = move_to.use_key            -- 寻到目标时使用指定的键盘KEY
            local use_key_wait = move_to.use_key_wait       -- 按键时等待指定秒后弹起
            local use_key0     = move_to.use_key0           -- 寻到目标前使用指定的键盘KEY
            local close_attack = move_to.close_attack       -- 关闭攻击
            local wait_time    = move_to.wait_time          -- 寻到目标点后等待时间
            local stop_transfer= move_to.stop_transfer      -- 是否禁用传送
            local stop_use_path= move_to.stop_use_path      -- 停止使用路径
            local stop_riding  = move_to.stop_riding        -- 是否停止骑马
            local stop_check_move = move_to.stop_check_move -- 停止检测移动
            pos_path_r = pos_path_r == 0 and r or pos_path_r
            -----------------------------------------------------------------
            -- 移动到目标点时的特殊执行路径
            local pos_path   = g_task_res.pos_path or task_info.pos_path or {}
            -- 寻到目标前使用指定的键盘KEY
            if use_key0 then
                decider.sleep(2000)
                ui_ent.esc_cinema()
                common.key_call(use_key0)
                common.wait_over_state()
                decider.sleep(5000)
            end

            -- 前置路径寻路
            if not stop_use_path and not table.is_empty(pos_path) then
                if rollback then
                    pos_path = common.rollback_table_key(pos_path)
                end
                if local_player:dist_xy(x,y) > pos_path_r then
                    -- 执行计算路径寻路
                    reset_move = map_ent.execute_move_by_path(pos_path,x,y,z,pos_path_r,nil,check_task_func,close_attack,stop_riding)
                end
            end
            -- xxmsg('reset_move:'..tostring(reset_move))
            if reset_move or reset_move == nil then
                if active_name and active_name ~= '' then
                    map_ent.move_to_active_transfer(active_name,map_name)
                end
                if not table.is_empty(task_info.must_move) then
                    map_ent.move_curr_map_to(map_name,area_name,task_info.must_move.x,task_info.must_move.y,task_info.must_move.z,100,check_task_func,nil,stop_riding,nil,close_attack,nil,stop_transfer)
                end
                -- 寻路到指定点
                map_ent.move_curr_map_to(map_name,area_name,x,y,z,r,check_task_func,nil,stop_riding,nil,close_attack,nil,stop_transfer)
                if wait_time then
                    common.wait_show_str('查看',wait_time)
                end
                if check_statu2 and actor_unit.get_local_player_status() == check_statu2 then
                    common.key_call('KEY_R')
                    -- 往前移动一点
                    common.auto_move_ex(x + 300,y - 300,z,2000)
                end
                -- 寻路到目标点时的按键操作
                if use_key then
                    if not use_key_wait then
                        common.key_call(use_key)
                    else
                        common.key_call(use_key,0)
                        decider.sleep(use_key_wait * 700)
                        common.key_call(use_key,1)
                    end
                    decider.sleep(5000)
                end
                -- 点击进入副本
                this.enter_task_fb()
                -----------------------------------------------------------------
                -- 任务类型：需要采集
                if not table.is_empty(task_info.gather) then
                    this.go_gather_by_info(task_name,branch_name,task_info,close_attack,quest_idx)
                    is_near_move = false
                end
                -----------------------------------------------------------------
                -- 任务类型：需要击杀的怪物
                if not table.is_empty(task_info.monster) then
                    this.go_kill_mon_by_info(task_name,branch_name,task_info,x,y,z,r,kill_z,stop_riding)
                    is_near_move = false
                end
                -----------------------------------------------------------------
                -- 任务类型：对话的NPC
                local talk       = task_info.talk
                if not table.is_empty(talk) then
                    is_near_move   = false
                    local npc_name = talk.npc_name
                    if npc_name and npc_name ~= '' then
                        local sel_idx   = talk.sel_idx
                        local r1        = talk.r or 300
                        local talk_npc  = npc_name
                        local key_ascii = talk.key_ascii
                        local kill_dis  = talk.kill_dis
                        if type(npc_name) ~= 'table' then
                            talk_npc = { npc_name }
                        end
                        for _,name in pairs( talk_npc ) do
                            this.submit_task(name,task_name,sel_idx,r1,branch_name,key_ascii,close_attack,kill_dis)
                        end
                    end
                end
                -----------------------------------------------------------------
                -- 任务类型：对话多个NPC直接使用的是G对话
                local talk2      = task_info.talk2
                if not table.is_empty(talk2) then
                    for _,v in pairs(talk2) do
                        if v.x and v.x ~= 0 then
                            if not this.is_over_task(task_name,branch_name,quest_idx) then
                                is_near_move   = false
                                map_ent.move_curr_map_to(map_name,area_name,v.x,v.y,v.z,50,check_task_func,nil,stop_riding,nil,close_attack)
                                this.submit_task_2()
                                if v.wait_time then
                                    common.wait_show_str('',v.wait_time)
                                end
                            end
                        end
                    end
                end
                -----------------------------------------------------------------
                -- 任务类型：使用指定的表情
                local use_emotes = task_info.use_emotes
                if not table.is_empty(use_emotes) then
                    is_near_move = false
                    for _,name in pairs(use_emotes) do
                        if not close_attack and not map_ent.move_to_kill_actor(nil,300) or close_attack then
                            if emotes_ent.use_emotes_by_name(name) then
                                for i = 1,20 do
                                    if this.is_over_task(task_name,branch_name,quest_idx) then
                                        break
                                    end
                                    trace.output('使用['..name..']等待任务完成')
                                    decider.sleep(1000)
                                end
                            end
                        end
                    end
                end
                -----------------------------------------------------------------
                -- 任务类型：使用乐普的数据
                local use_music  = task_info.use_music
                if not table.is_empty(use_music) then
                    is_near_move = false
                    for _,name in pairs(use_music) do
                        if not close_attack and not map_ent.move_to_kill_actor(nil,300) or close_attack then
                            if music_ent.use_music_by_name(name) then
                                decider.sleep(3000)
                            end
                        end
                    end
                end
                -----------------------------------------------------------------
                -- 任务类型：将目标移动到指定坐标
                local move_item  = task_info.move_item
                if not table.is_empty(move_item) then
                    is_near_move = false
                    this.execute_move_item_to_pos(move_item,task_name,branch_name)
                end
                -----------------------------------------------------------------
                -- 到指定位置按F5 use_f5  = { is_use = true,x = 0,y = 0,z = 0 },
                local use_f5  = task_info.use_f5
                if not table.is_empty(use_f5) then
                    is_near_move = false
                    if use_f5.is_use then
                        local actor_num = actor_ent.get_actor_num_by_pos(nil,nil,nil,600,2)
                        local k_dis     = actor_num > 0 and 650 or 200
                        if not close_attack and not map_ent.move_to_kill_actor(nil,k_dis) or close_attack then
                            local call_key = use_f5.call_key or { 'KEY_0','KEY_F5','KEY_F6','KEY_F7' }
                            for _, v in pairs(call_key) do
                                if not this.is_over_task(task_name,branch_name,quest_idx) then
                                    if not decider.is_working() then
                                        break
                                    end
                                    ui_ent.esc_cinema()
                                    trace.output('按键：',v)
                                    decider.sleep(100)
                                    common.key_call(v)
                                    decider.sleep(500)
                                    if use_f5.x and use_f5.x ~= 0 then
                                        game_unit.set_mouse_pos(use_f5.x, use_f5.y, use_f5.z)
                                        decider.sleep(500)
                                        common.key_call(v)
                                    end
                                    decider.sleep(1000)
                                    common.wait_over_state()
                                    if use_f5.call_esc then
                                        common.key_call('KEY_Esc')
                                        decider.sleep(1000)
                                    end
                                    if use_f5.use_key then
                                        common.key_call(use_f5.use_key)
                                        decider.sleep(1000)
                                    end
                                end
                            end
                        end
                    end
                end
                -----------------------------------------------------------------
                -- 远离当前点一段距离
                if is_near_move and not stop_check_move then
                    local check_move  = task_info.check_move
                    if not table.is_empty(check_move) then
                        map_ent.move_curr_map_to(map_name,area_name,check_move.x,check_move.y,check_move.z,50,check_task_func,nil,stop_riding,nil,close_attack)
                    else
                        if map_name == actor_unit.map_name() then
                            common.wait_over_state()
                            common.auto_move_ex(local_player:cx() + 200,local_player:cy(),local_player:cz())
                        end
                    end
                end
            end
        end
        decider.sleep(500)
    end
end

--------------------------------------------------------------------------------
-- [行为] 对话操作2
quest_ent.submit_task_2 = function()
    if actor_unit.get_cur_talk_npc_id() == 0 then
        common.key_call('KEY_G')
        decider.sleep(2000)
        common.wait_over_state()
    end
    if actor_unit.get_cur_talk_npc_id() ~= 0 then
        common.do_shift_key('KEY_G')
        common.key_call('KEY_G')
        common.key_call('KEY_G')
        common.key_call('KEY_G')
        common.wait_over_state()
        decider.sleep(2000)
        ui_ent.exist_npc_talk()
        decider.sleep(1000)
    end
end

--------------------------------------------------------------------------------
-- [行为] 提交任务
--------------------------------------------------------------------------------
quest_ent.submit_task = function(npc_name,task_name,sel_idx,r,branch_name,key_ascii,close_attack,kill_dis)
    local is_ok = false
    local k_dis = 200
    while decider.is_working() do
        sel_idx = sel_idx or -1
        -- 获取NPC信息
        local npc_info = {} -- actor_ent.get_nearest_npc_info_for_list(npc_name)
        if type(npc_name) == 'string' then
            npc_info = actor_ent.get_nearest_npc_info_for_list(npc_name)
        else
            npc_info = actor_ent.get_actor_info_by_res_id(npc_name,3)
        end
        if table.is_empty(npc_info) then
            trace.output('没有NPC【',npc_name,'】的数据')
            break
        end
        -- 获取任务ID
        local task_id = this.get_quest_id_by_task_name(task_name)
        if task_id == 0 then
            break
        end
        -- 指定分支任务
        if branch_name and this.is_over_task(task_name,branch_name) then
            break
        end
        -- 死亡检测
        if actor_ent.check_dead() == 2 then
            break
        end
        -- 检测NPC是否存在任务
        --if  quest_ent.is_exist_quest_in_npc(npc_info.res_id,task_id) == 0 then
        --    break
        --end
        -- 动画检测
        ui_ent.esc_cinema()
        local w_time = 1000
        local npc_x  = npc_info.cx
        local npc_y  = npc_info.cy
        local npc_z  = npc_info.cz
        local npc_d  = npc_info.dist
        r            = r or 200
        -- 获取对话ID
        if actor_unit.get_cur_talk_npc_id() == 0 then
            item_ent.auto_use_hp_ex()
            if local_player:is_battle() then
                k_dis = 600
            end
            k_dis = kill_dis or k_dis
            -- 如果与NPC的距离过远 则重置下攻击距离
            if npc_d > 500 and k_dis > 600 then
                k_dis = 200
            end
            if not close_attack and not map_ent.move_to_kill_actor(nil,k_dis) or close_attack then
                -- 任务完成
                if is_ok then break end
                if npc_d <= r then
                    decider.sleep(1000)
                    if not common.is_move() then
                        if npc_info.npc_can_talk then
                            trace.output('1.打开【',npc_info.name,'】对话')
                            actor_unit.npc_talk(npc_info.id, 1)
                            decider.sleep(2000)
                            if actor_unit.get_cur_talk_npc_id() == 0 then
                                trace.output('2.打开【',npc_info.name,'】对话')
                                common.key_call('KEY_G')
                                decider.sleep(1000)
                            end
                        else
                            -- xxmsg(npc_info.res_id)
                            trace.output('',npc_info.name,' 暂不可对话')
                            common.key_call('KEY_G')
                            decider.sleep(1000)
                        end
                        common.wait_over_state()
                        if actor_unit.get_cur_talk_npc_id() == 0 then
                            -- 检测附近怪物数量
                            local actor_num = actor_ent.get_actor_num_by_pos(nil,nil,nil,1000,2)
                            if actor_num > 0 then
                                k_dis = 1000
                            end
                        end
                    end
                else
                    if not common.is_move() then
                        common.auto_move(npc_x,npc_y,npc_z)
                        decider.sleep(1000)
                    end
                end
            else
                w_time = 100
            end
        else
            is_ok = true
            -- 任务ID 不相等 退出对话
            if task_id ~= quest_unit.get_talk_quest_id() then
                break
            end
            -- 当前任务对话状态(2接，3完成，4对话)
            local talk_status = quest_unit.get_talk_quest_status()
            if talk_status == 4 then
                trace.output('正与【',npc_info.name,'】对话')
                key_ascii = key_ascii or 'KEY_1'
                common.do_shift_key('KEY_G')
                if common.is_sleep_any('use_key_ascii',5) and key_ascii ~= -1 then
                    -- xxmsg('key_ascii:'..key_ascii)
                    common.key_call(key_ascii)
                end
                -- common.key_call(71)
               -- quest_unit.quest_talk_next() --
               --  sleep(500)
            elseif talk_status == 3 then
                trace.output('正交【',npc_info.name,'】任务')
                quest_unit.complete(task_id,sel_idx)
            elseif talk_status == 2 or quest_unit.get_quest_summary_wnd() > 0 then
                trace.output('正接【',npc_info.name,'】任务')
                quest_unit.do_quest_event()
            else
                trace.output('获取talk_status：',talk_status,' 异常')
            end
        end
        decider.sleep(w_time)
    end
    if actor_unit.get_cur_talk_npc_id() ~= 0 then
        ui_ent.exist_npc_talk()
        decider.sleep(1000)
    end
end

-------------------------------------------------------------------------------------
-- [行为] 完成任务
quest_ent.finish_task = function()
    local list  = quest_unit.list()
    local key_word = { '任务完成','开始新冒险','觉醒新的力量' }
    for i = 1, #list do
        local obj = list[i]
        if quest_ctx:init(obj)  then
            local branch_num = quest_ctx:branch_num()
            if branch_num > 0 then
                local branch_name = quest_ctx:branch_name(i)
                if string.find(branch_name,'[完成]') then
                    local is_complete = true
                    local name        = quest_ctx:name()
                    if common.is_exist_list_arg({ '混沌地牢','讨伐星辰守卫' },name) and daily_unit.get_week_quest_complate_num() >= 3 then
                        is_complete = false
                    end
                    if common.is_exist_list_arg(key_word,branch_name) and is_complete then
                        trace.output('提交：',name)
                        quest_unit.complete(quest_ctx:id(),-1)
                        decider.sleep(2000)
                    end
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------
-- [行为] 去指定点获取指定物品
quest_ent.go_gather_get_item = function(item_name,num,move_to,gather,close_attack,stop_riding)
    -- 标记需要过滤的采集对象
    local filter_info = {}
    while decider.is_working() do
        if item_ent.get_item_num_by_name(item_name,nil,true) >= num then
            break
        end
        local stop_func = function()
            return item_ent.get_item_num_by_name(item_name,nil,true) >= num
        end
        trace.output('去采集获取：',item_name)
        local w_time    = 1000
        local map_name  = move_to.map_name
        local area_name = move_to.area_name
        local x         = move_to.x
        local y         = move_to.y
        local z         = move_to.z
        local r         = move_to.r
        if map_ent.move_to(map_name,area_name,x,y,z,r,stop_riding) then
            filter_info,w_time = this.do_gather(move_to,gather,close_attack,filter_info,stop_func)
        end
        decider.sleep(w_time)
    end
end

-------------------------------------------------------------------------------------
-- [行为] 通用采集函数
quest_ent.do_gather = function(move_to,gather,close_attack,filter_info,stop_func)
    local w_time = 1000
    filter_info  = filter_info or {}
    if not table.is_empty(gather) then
        -- 保存已完成对话/采集的对象时间
        -- 获取需要采集的对象数据
        for _,v in pairs(gather) do
            -- 需要使用指定物品
            local use_name   = v.use_name
            -- 是否使用生活工具
            local use_life   = v.use_life
            -- 采集或者对话的名字
            local name       = v.name or ''
            -- 采集或者对话对象的资源ID
            local res_id     = v.res_id or 0
            -- 采集或者对话的对象类型
            local obj_type   = v.type or 2
            -- 当前R为寻路到目标点可采距离
            local r          = v.r  or 200
            r                = r == 300 and 200 or r
            -- 指定当前R为读取范围
            local read_r     = v.read_r or move_to.r or 500
            -- 当类型3时 如果为真则引用采集的命令
            local gather_npc = v.gather_npc
            -- 额外设置的击杀的范围
            local kill_dis   = v.kill_dis or 100
            -- 类型7的状态是否需要配对
            local type_seven_status = v.type_seven_status
            -- 当前是否配对此is_valid
            local is_valid          = v.is_valid
            -- 执行完采集按一次ESC
            local call_esc          = v.call_esc
            -- 设置等待时间
            local wait_time         = v.wait_time or 30
            -- 采集完成后等待时间
            local rest_time         = v.rest_time or 0
            -- 设置指定的移动高度
            local set_z             = v.set_z
            -- 配对条件
            if type_seven_status ~= nil or is_valid ~= nil then
                filter_info = false
            end
            -- 是否只寻到指定的坐标 非采集
            local go_move           = v.go_move
            if not close_attack and not map_ent.move_to_kill_actor(nil,kill_dis) or close_attack then
                -- 获取指定对象信息
                local actor_info = {}
                if name and name ~= '' then
                    -- actor_info = actor_ent.get_actor_info_by_name(name,obj_type)
                    -- 获取距离目标点 范围最近的对象  非距离角色最近
                    _,actor_info = actor_ent.get_nearest_actor_info_by_rad_pos(name,move_to.x,move_to.y,read_r,obj_type,filter_info,wait_time)
                end
                if table.is_empty(actor_info) and res_id ~= 0 then
                    -- actor_info = actor_ent.get_actor_info_by_res_id(res_id,obj_type)
                    -- 获取距离目标点 范围最近的对象  非距离角色最近
                    _,actor_info = actor_ent.get_nearest_actor_info_by_rad_pos(res_id,move_to.x,move_to.y,read_r,obj_type,filter_info,wait_time)
                end
                if not table.is_empty(actor_info) then
                    local actor_info1 = actor_info[1]
                    for _,info in pairs(actor_info) do
                        if type_seven_status and info.type_seven_status == type_seven_status or is_valid ~= nil and info.is_valid == is_valid then
                            if info.type_seven_status == type_seven_status then
                                actor_info1 = info
                                break
                            end
                        end
                        if obj_type == 3 and not gather_npc and info.npc_can_talk then
                            actor_info1 = info
                            break
                        end
                    end
                    if use_life then
                        equip_ent.auto_use_life_equip()
                    end
                    -- xxmsg('can_gather:'..tostring(actor_info1.can_gather))
                    while decider.is_working() do
                        if stop_func and stop_func() then
                            return filter_info,w_time
                        end
                        ui_ent.esc_cinema()
                        item_ent.auto_use_hp_ex()
                        -- 移动到目标点采集
                        local gather_x   = actor_info1.cx
                        local gather_y   = actor_info1.cy
                        local gather_z   = set_z or actor_info1.cz
                        local gather_obj = actor_info1.obj
                        local id         = actor_info1.id
                        local key        = math.floor(gather_x)..math.floor(gather_y)..math.floor(gather_z)..gather_obj
                        if local_player:dist_xy(gather_x,gather_y) < r then
                            if not close_attack and not map_ent.move_to_kill_actor(nil,kill_dis) or close_attack then
                                if obj_type == 3 and not gather_npc then
                                    if actor_info1.npc_can_talk then
                                        trace.output('对话:'..string.format('0x%X',gather_obj))
                                        actor_unit.npc_talk(id,1)
                                        decider.sleep(2000)
                                    else
                                        filter_info[gather_obj] = os.time()
                                    end
                                else
                                    -- 放下身上的物品
                                    if actor_unit.get_local_player_status() ~= 1 then
                                        common.key_call('KEY_R')
                                        decider.sleep(2000)
                                    end
                                    common.mouse_move(gather_x,gather_y,gather_z)
                                    -- 执行采集
                                    if obj_type == 8 then
                                        trace.output(string.format('采集：0x%X',gather_obj))
                                        actor_unit.transfer_talk(gather_obj)
                                    else
                                        if actor_info1.can_gather then
                                            trace.output(string.format('采集：0x%X',gather_obj))
                                            actor_unit.gather_talk(gather_obj)
                                        else
                                            trace.output(string.format('暂不可采集：0x%X',gather_obj))
                                        end
                                    end
                                    decider.sleep(500)
                                    common.key_call('KEY_G')
                                end
                                decider.sleep(1000)
                                common.wait_over_state()
                                if type(filter_info) == 'table' and not actor_info1.can_gather then
                                    filter_info[gather_obj] = os.time()
                                end
                                if call_esc then
                                    decider.sleep(3000)
                                    common.key_call('KEY_G')
                                end
                                if rest_time > 0 then
                                    common.wait_show_str('采集完后',rest_time)
                                end
                                -- 检测当前位置 采集的次数
                                local bool_val,count = common.get_interval_change('采集任务',key,60)
                                if bool_val == 2 and count > 2 and move_to.x then
                                    common.auto_move_ex(move_to.x,move_to.y,move_to.z)
                                    common.get_interval_change('采集任务',true)
                                end
                                local is_break = true
                                local gather_info = {}
                                -- 检测是否采集成功
                                if obj_type ~= 8 and obj_type ~= 3 then
                                    gather_info = actor_ent.get_actor_info_by_obj(gather_obj,'can_gather')
                                end
                                if not table.is_empty(gather_info) then
                                    if gather_info.can_gather then
                                        kill_dis = 800
                                        is_break = false
                                    end
                                end
                                if is_break then
                                    break
                                end
                            else
                                w_time = 100
                                if local_player:dist_xy(gather_x,gather_y) > 400 then
                                    kill_dis = 100
                                end
                            end
                        else
                            -- xxmsg(local_player:dist_xy(gather_x,gather_y)..' '..r)
                            if not map_ent.move_to_kill_actor(nil,100) then
                                if not common.is_move() then
                                    -- 同一目标移动的次数
                                    local bool_val,count = common.get_interval_change('采集移动',key,5)
                                    if bool_val == 2 and count > 4 and move_to.x then
                                        common.auto_move_ex(move_to.x,move_to.y,move_to.z)
                                        common.get_interval_change('采集移动',true)
                                    end
                                    if go_move then --计算2坐标距离 --or utils.distance(move_to.x,move_to.y, gather_x,gather_y) < 250
                                        gather_x,gather_y,gather_z = move_to.x,move_to.y,move_to.z
                                    end
                                    common.auto_move(gather_x,gather_y,gather_z)
                                end
                            else
                                w_time = 100
                            end
                        end
                        decider.sleep(100)
                    end
                else
                    xxxmsg(2,'没有找到采集目标')
                end
            end
        end
    end
    return filter_info,w_time
end

-------------------------------------------------------------------------------------
-- [行为] 去指定点采集[任务名称,分支,传入的是任务资源中的数据]
quest_ent.go_gather_by_info = function(task_name,branch_name,task_info,close_attack,quest_idx)
    -- 标记需要过滤的采集对象
    local filter_info = {}
    -- 检测任务切换
    while decider.is_working() do
        -- 当前分支完成时退出采集
        if this.is_over_task(task_name,branch_name,quest_idx) then
            return false
        end
        if actor_ent.check_dead() == 2 then
            return false
        end
        local check_task = this.get_priority_quest_info()
        if check_task ~= task_name then
            return false
        end
        ui_ent.esc_cinema()
        common.wait_loading_map()
        ui_ent.esc_cinema()
        local move_to    = task_info.move_to
        local gather     = task_info.gather
        local w_time     = 1000
        if not table.is_empty(gather) then
            -- 保存已完成对话/采集的对象时间
            -- 获取需要采集的对象数据
            for _,v in pairs(gather) do
                -- 需要使用指定物品
                local use_name   = v.use_name
                -- 是否使用生活工具
                local use_life   = v.use_life
                -- 采集或者对话的名字
                local name       = v.name or ''
                -- 采集或者对话对象的资源ID
                local res_id     = v.res_id or 0
                -- 采集或者对话的对象类型
                local obj_type   = v.type or 2
                -- 当前R为寻路到目标点可采距离
                local r          = v.r  or 200
                r                = r == 300 and 200 or r
                -- 指定当前R为读取范围
                local read_r     = v.read_r or move_to.r or 500
                -- 当类型3时 如果为真则引用采集的命令
                local gather_npc = v.gather_npc
                -- 额外设置的击杀的范围
                local kill_dis   = v.kill_dis or 100
                --if local_player:is_battle() then
                --    kill_dis = kill_dis < 600 and 600 or kill_dis
                --end
                -- 类型7的状态是否需要配对
                local type_seven_status = v.type_seven_status
                -- 当前是否配对此is_valid
                local is_valid          = v.is_valid
                -- 执行完采集按一次ESC
                local call_esc          = v.call_esc
                -- 设置等待时间
                local wait_time         = v.wait_time or 30
                -- 采集完成后等待时间
                local rest_time         = v.rest_time or 0
                -- 设置指定的移动高度
                local set_z             = v.set_z
                -- 配对条件
                if type_seven_status ~= nil or is_valid ~= nil then
                    filter_info = false
                end
                -- 移动类型[无法正常移动时 引用鼠标]
                local move_action       = v.move_action
                -- 是否只寻到指定的坐标 非采集
                local go_move           = v.go_move
                if not close_attack and not map_ent.move_to_kill_actor(nil,kill_dis) or close_attack then
                    -- 获取指定对象信息
                    local actor_info = {}
                    if name and name ~= '' then
                        -- actor_info = actor_ent.get_actor_info_by_name(name,obj_type)
                        -- 获取距离目标点 范围最近的对象  非距离角色最近
                        _,actor_info = actor_ent.get_nearest_actor_info_by_rad_pos(name,move_to.x,move_to.y,read_r,obj_type,filter_info,wait_time)
                    end
                    if table.is_empty(actor_info) and res_id ~= 0 then
                        -- actor_info = actor_ent.get_actor_info_by_res_id(res_id,obj_type)
                        -- 获取距离目标点 范围最近的对象  非距离角色最近
                        _,actor_info = actor_ent.get_nearest_actor_info_by_rad_pos(res_id,move_to.x,move_to.y,read_r,obj_type,filter_info,wait_time)
                    end
                    if not table.is_empty(actor_info) then
                        local actor_info1 = actor_info[1]
                        for _,info in pairs(actor_info) do
                            if type_seven_status and info.type_seven_status == type_seven_status or is_valid ~= nil and info.is_valid == is_valid then
                                if info.type_seven_status == type_seven_status then
                                    actor_info1 = info
                                    break
                                end
                            end
                            if obj_type == 3 and not gather_npc and info.npc_can_talk then
                                actor_info1 = info
                                break
                            end
                        end

                        if use_name then
                        --     item_ent.use_item_by_name(use_name)
                        end
                        if use_life then
                            equip_ent.auto_use_life_equip()
                        end
                       -- xxmsg('can_gather:'..tostring(actor_info1.can_gather))
                        while decider.is_working() do
                            if quest_ent.is_over_task(task_name,branch_name) then
                                return false
                            end
                            ui_ent.esc_cinema()
                            item_ent.auto_use_hp_ex()
                            -- 移动到目标点采集
                            local gather_x   = actor_info1.cx
                            local gather_y   = actor_info1.cy
                            local gather_z   = set_z or actor_info1.cz
                            local gather_obj = actor_info1.obj
                            local id         = actor_info1.id
                            local key        = math.floor(gather_x)..math.floor(gather_y)..math.floor(gather_z)..gather_obj
                            if local_player:dist_xy(gather_x,gather_y) < r then
                                if not close_attack and not map_ent.move_to_kill_actor(nil,kill_dis) or close_attack then
                                    if obj_type == 3 and not gather_npc then
                                        if actor_info1.npc_can_talk then
                                            trace.output('对话：'..string.format('0x%X',gather_obj))
                                            actor_unit.npc_talk(id,1)
                                            decider.sleep(2000)
                                        else
                                            filter_info[gather_obj] = os.time()
                                        end
                                    else
                                        -- 放下身上的物品
                                        if actor_unit.get_local_player_status() ~= 1 then
                                            common.key_call('KEY_R')
                                            decider.sleep(2000)
                                        end
                                        -- 执行采集
                                        if obj_type == 8 then
                                            trace.output(string.format('采集：0x%X',gather_obj))
                                            actor_unit.transfer_talk(gather_obj)
                                        else
                                            if actor_info1.can_gather then
                                                trace.output(string.format('采集：0x%X',gather_obj))
                                                actor_unit.gather_talk(gather_obj)
                                            else
                                                trace.output(string.format('暂不可采集：0x%X',gather_obj))
                                            end
                                        end
                                        -- common.mouse_move(gather_x,gather_y,gather_z)
                                        decider.sleep(500)
                                        common.key_call('KEY_G')
                                        decider.sleep(1000)
                                    end
                                    common.wait_over_state()
                                    if type(filter_info) == 'table' and not actor_info1.can_gather then
                                        filter_info[gather_obj] = os.time()
                                    end
                                    if call_esc then
                                        decider.sleep(3000)
                                        common.key_call('KEY_Esc')
                                    end
                                    if rest_time > 0 then
                                        common.wait_show_str('采集完后',rest_time)
                                    end
                                    -- 检测当前位置 采集的次数
                                    local bool_val,count = common.get_interval_change('采集任务',key,60)
                                    if bool_val == 2 and count > 2 and move_to.x then
                                        common.auto_move_ex(move_to.x,move_to.y,move_to.z)
                                        common.get_interval_change('采集任务',true)
                                    end
                                    local is_break = true
                                    local gather_info = {}
                                    -- 检测是否采集成功
                                    if obj_type ~= 8 and obj_type ~= 3 then
                                        gather_info = actor_ent.get_actor_info_by_obj(gather_obj,'can_gather')
                                    end
                                    if not table.is_empty(gather_info) then
                                        if gather_info.can_gather then
                                            kill_dis = 800
                                            is_break = false
                                        end
                                    end
                                    if is_break then
                                        break
                                    end
                                else
                                    w_time = 100
                                    if local_player:dist_xy(gather_x,gather_y) > 300 then
                                        kill_dis = 100
                                    end
                                end
                            else
                                -- xxmsg(local_player:dist_xy(gather_x,gather_y)..' '..r)
                                if not map_ent.move_to_kill_actor(nil,100) then
                                    if not common.is_move() then
                                        -- 同一目标移动的次数
                                        local bool_val,count = common.get_interval_change('采集移动',key,5)
                                        if bool_val == 2 and count > 4 and move_to.x then
                                            common.auto_move_ex(move_to.x,move_to.y,move_to.z)
                                            common.get_interval_change('采集移动',true)
                                        end
                                        if go_move then --计算2坐标距离 --or utils.distance(move_to.x,move_to.y, gather_x,gather_y) < 250
                                            gather_x,gather_y,gather_z = move_to.x,move_to.y,move_to.z
                                        end
                                        if move_action == 4 then
                                            common.mouse_move(gather_x,gather_y,gather_z)
                                        else
                                            common.auto_move(gather_x,gather_y,gather_z,nil,nil,move_action)
                                        end

                                    end
                                else
                                    w_time = 100
                                end
                            end
                            decider.sleep(100)
                        end
                    else
                        xxxmsg(2,'没有找到采集目标')
                        if not map_ent.move_to_kill_actor(nil,100) then
                            common.auto_move_ex(move_to.x,move_to.y,move_to.z,1000)
                        end
                    end
                end
            end
        else
            break
        end
        decider.sleep(w_time)
    end
end

-------------------------------------------------------------------------------------
-- [行为] 去指定点打怪[任务名称,分支,传入的是任务资源中的数据]
quest_ent.go_kill_mon_by_info = function(task_name,branch_name,task_info,x,y,z,r,kill_z,stop_riding)
    while decider.is_working() do
        -- 当前分支完成时退出采集
        if quest_ent.is_over_task(task_name,branch_name) then
            return false
        end
        if actor_ent.check_dead() == 2 then
            return false
        end
        ui_ent.esc_cinema()
        item_ent.auto_use_hp_ex()
        local w_time      = 1000
        local monster     = task_info.monster -- { { name = '',type = 2,res_id = 0},{ name = '',type = 2,res_id = 0}}
        if not table.is_empty(monster) then
            for _,v in pairs(monster) do
                if  actor_res.need_key_h(v.name) and common.is_sleep_any('USE_KEY_H_KILL',10)  then
                    common.key_call('KEY_H')
                end
            end
            -- 攻击使用F5
            local kill_f5 = task_info.kill_f5
            if not map_ent.move_to_kill_actor(monster,r,kill_z,kill_f5) then
                local dist = local_player:dist_xy(x,y)
                if dist > 100 then
                    if dist > 1800 and not stop_riding then
                        vehicle_ent.auto_riding_vehicle()
                    end
                    if not common.is_move() then
                        common.auto_move(x,y,z)
                    end
                else
                    break
                end
            else
                w_time      = 100
            end
        else
            break
        end
        decider.sleep(w_time)
    end
end

-------------------------------------------------------------------------------------
-- [行为] 移动指定物品到指定位置
quest_ent.execute_move_item_to_pos = function(move_item,task_name,branch_name,execute_num)
    -- 重复执行的次数
    local do_num = 0
    while decider.is_working() do
        -- 当前分支完成时退出采集
        if quest_ent.is_over_task(task_name,branch_name) then
            return false
        end
        if actor_ent.check_dead() == 2 then
            return false
        end
        ui_ent.esc_cinema()
        local t1 = move_item['抬']
        local t2 = move_item['投']
        if execute_num and do_num >= execute_num then
            return false
        end
        if not table.is_empty(t1) and not table.is_empty(t2) and t1.x and t1.x ~= 0 and t2.x and t2.x ~= 0 then
            local r = t1.r or 1000
            r = r < 100 and 200 or r
            -- 寻路到抬起点
            map_ent.move_curr_map_to(t1.map_name,t1.area_name,t1.x,t1.y,t1.z,r)
            -- 获取指定对象信息
            -- xxmsg(t1.type)
            local actor_info =  actor_ent.get_nearest_actor_info_by_rad_pos(t1.res_id,t1.x,t1.y,r,t1.type)
            if not table.is_empty(actor_info) then
                if actor_info.dist < 200 then
                    if actor_unit.get_local_player_status() ~= 4 then
                        common.key_call('KEY_G')
                        decider.sleep(1000)
                        common.wait_over_state()
                    else
                        -- 按键E加速
                        if common.is_sleep_any('按键E加速',12) then
                            common.key_call('KEY_E')
                        end
                        -- 移动到指定投放点
                        map_ent.move_curr_map_to(t2.map_name,t2.area_name,t2.x,t2.y,t2.z,t2.r or 50,nil,nil,true,nil,t2.close_attack)
                        -- 按键KEY
                        common.key_call(t2.call)
                        decider.sleep(1000)
                        game_unit.set_mouse_pos(t2.x,t2.y,t2.z)
                        common.key_call(t2.call)
                        do_num = do_num + 1
                    end
                else
                    if not map_ent.move_to_kill_actor(nil,100) then
                        if not local_player:is_move() then
                            common.auto_move(actor_info.cx,actor_info.cy,actor_info.cz)
                        end
                    end
                end
            end
        else
            break
        end
        decider.sleep(1000)
    end
end

-------------------------------------------------------------------------------------
-- [读取] 获取指定任务资源配置的任务类型
quest_ent.get_task_type_in_res = function(task_name)
    local task_info = this.QUEST_INFO[task_name]
    if not task_info then return '' end
    local task_type = task_info['任务类型']
    return task_type or ''
end

------------------------------------------------------------------------------------
-- [行为] 进入问号副本
quest_ent.enter_task_fb = function(select_level)
    select_level   = select_level or 0
    select_level   = select_level > 1 and 1 or select_level
    local dun_mode = select_level == 1 and '困难' or '普通'
    while decider.is_working() do
        common.wait_loading_map()
        --CDungeonUnit::ConfirmEnterDungeon::<lambda_a7c604646cc46dc90882ecdd94cccedd>::operator () Error.
        if dungeon_unit.get_dun_dialog_status() > 0 then
            actor_ent.check_dead(2)
            decider.sleep(1000)
            --确认进入副本
            trace.output('确认进入副本')
            dungeon_unit.confirm_enter_dungeon()
            decider.sleep(2000)
        elseif dungeon_unit.get_solo_dun_enter_wnd() ~= 0 then
            actor_ent.check_dead(2)
            --点击进入副本
            trace.output('点击进入副本')
            decider.sleep(1000)
            dungeon_unit.click_enter_dungeon()
            decider.sleep(1000)
            --有门的任务副本窗品检测
        elseif dungeon_unit.get_dungeon_entrance_wnd() ~= 0 then
            actor_ent.check_dead(2)
            if dungeon_unit.get_dun_entrance_level() ~= select_level then
                trace.output('选择模式【'..dun_mode..'】')
                dungeon_unit.select_dun_entrance_level(select_level)
                decider.sleep(2000)
            else
                --点击进入
                trace.output('点击进入['..dun_mode..']模式')
                decider.sleep(1000)
                dungeon_unit.click_bing_enter_btn()
                decider.sleep(1000)
            end
        else
            break
        end
        decider.sleep(1000)
    end
end

------------------------------------------------------------------------------------
-- [读取] 检测指定任务ID 是否 在NPC上存在
quest_ent.is_exist_quest_in_npc = function(npc_res_id,quest_id)
    -- 取NPc上的任务(操作)
    local list   = quest_unit.get_npc_quest_list_by_resid(npc_res_id)
    for i = 1, #list do
        local quest = list[i]
        -- type 2 接，3完成，4对话
        local id,q_type = common.split64(quest)
        if id == quest_id then
            return q_type
        end
    end
    return 0
end

------------------------------------------------------------------------------------
-- [条件] 指定任务/分支是否完成[可判断指定任务 或者 分支任务是否完成]
quest_ent.is_over_task = function(task_name,branch_name,quest_idx)
    local info = this.get_quest_info_by_task_name_and_branch_name(task_name,branch_name)
    if not table.is_empty(info) and info.branch_info and info.branch_info.cur_tar_num then
        if not quest_idx or quest_idx == -1 or quest_idx == info.idx then
            if info.branch_info.cur_tar_num < info.branch_info.cur_tar_max_num or info.branch_num == 1 then
                return false
            end
        end
    end
    return true
end

------------------------------------------------------------------------------------
-- [条件] 指定任务是否已完成
quest_ent.is_finish_quest_by_map_id_and_name = function(name,map_id)
    map_id = type( map_id ) == 'number' and map_id or -1
    -- 取完任务ID列表（地图ID，-1所有完成任务不建义用）
    local complate_list = quest_unit.get_complate_quest_id_list(map_id)
    for i = 1 , #complate_list do
        local id = complate_list[i]
        if quest_unit.get_quest_name_byid(id) == name then
            return true
        end
        -- xxmsg(string.format("%X     %s", id, quest_unit.get_quest_name_byid(id)))
    end
    return false
end

------------------------------------------------------------------------------------
-- [读取] 获取指定任务分支信息[任务名,分支名]
quest_ent.get_quest_info_by_task_name_and_branch_name = function(task_name,branch_name)
    local info = this.get_quest_info_by_any(task_name, 'name')
    if not table.is_empty(info) then
        local branch_info = info.branch_info
        -- 优先取未完成的分支
        for _,v in pairs(branch_info) do
            if v.branch_name == branch_name and v.cur_tar_num < v.cur_tar_max_num then
                info.branch_info = v
                return info
            end
        end
        for _,v in pairs(branch_info) do
            if v.branch_name == branch_name then
                info.branch_info = v
                break
            end
        end
    end
    -- 找不到任务信息 说明任务已完成
    return info
end

------------------------------------------------------------------------------------
-- [读取] 获取指定任务ID[任务名]
quest_ent.get_quest_id_by_task_name = function(task_name)
    local info = this.get_quest_info_by_any(task_name, 'name')
    return not table.is_empty(info) and info.id or 0
end

------------------------------------------------------------------------------------
-- [读取] 获取指定任务信息[任务名]
quest_ent.get_quest_info_by_task_name = function(task_name)
    local info = this.get_quest_info_by_any(task_name, 'name')
    return info
end

------------------------------------------------------------------------------------
-- [读取] 获取优先执行的任务名
quest_ent.get_priority_quest_info = function()
    local info   = this.get_quest_info_list('name')
    local can_do = {}

    if not table.is_empty(info) then
        for _,v in pairs(info) do
            local task_info = quest_res.QUEST_INFO[v.name]
            if not table.is_empty(task_info) then
                local task       =  this.get_quest_info_by_task_name(v.name)
                if not table.is_empty(task) then
                    local task_type = task_info['任务类型']
                    local task_idx  = quest_res.QUEST_PRIORITY[task_type]
                    table.insert(can_do,{ name = v.name, task_idx = task_idx,task_type = task.task_type,quest_type = task_type })
                end
            end
        end
    end

    if not table.is_empty(can_do) then

        table.sort(can_do,function(a, b) return a.task_idx < b.task_idx end)
        if #can_do > 1 then
            if can_do[1].name == can_do[2].name or can_do[1].task_idx == can_do[2].task_idx then
                if can_do[1].task_type > can_do[2].task_type then
                    return can_do[2].name,can_do[2].quest_type
                end
            end
        end
        return can_do[1].name,can_do[1].quest_type
    end
    return '',''
end

------------------------------------------------------------------------------------
-- [读取] 获取所有已接任务数据
------------------------------------------------------------------------------------
quest_ent.get_quest_info_list = function(...)
    local ret        = {}
    local list       = quest_unit.list()
    local quest_obj  = quest_unit:new()
    for _,obj in pairs(list) do
        if quest_obj:init(obj) then
            local result  = {}
            for _,v in pairs({...} ) do
                -- 获取指定属性的值
                result[v] = quest_obj[v](quest_obj)
            end
            table.insert(ret,result)
        end
    end
    quest_obj:delete()
    return ret
end

------------------------------------------------------------------------------------
-- [读取] 根据任务任意字段值返回信息表
-- @tparam              string                   args           任务需要配对的参数
-- @tparam              string                   any_key        任务任意(字段)
-- @treturn             table                                   返回任务信息的table
------------------------------------------------------------------------------------
quest_ent.get_quest_info_by_any = function(args, any_key)
    local list       = quest_unit.list()
    local quest_obj  = quest_unit:new()
    local quest_list = {}
    for _, obj in pairs(list) do
        if quest_obj:init(obj) then
            -- 获取指定属性的值
            local _any = quest_obj[any_key](quest_obj)
            -- 配对目标值
            if args == _any then
                local branch_num = quest_obj:branch_num()
                local task_name  = quest_obj:name()
                local main_idx   = quest_obj:idx()
                local task_id    = quest_obj:id()
                -- 保存任务
                local quest_info = {
                    -- 任务实例对象
                    obj        = obj,
                    -- 任务名称
                    name       = task_name,
                    -- 任务ID
                    id         = task_id,
                    -- 任务序号
                    idx        = main_idx,
                    -- 任务状态
                    status     = quest_obj:status(),
                    -- 任务分支数
                    branch_num = branch_num,
                    -- 任务所在地图
                    map_name   = quest_obj:map_name(),
                }
                -- 分支信息表
                local branch_info = {}
                for i = 0, branch_num - 1 do
                    local result = {}
                    -- 分支名称
                    result.branch_name     = quest_obj:branch_name(i)
                    if task_name == '库克赛顿的计谋' and string.find(result.branch_name,'希里安准备的礼物') then
                        result.branch_name =  '去找<FONT color=\'#FF973A\'>布拉依特</FONT>领取希里安准备的礼物'
                    end
                    -- 听<FONT color='#A487F8'>阿丽亚娜</FONT>的反应 idx:1.0 task_name:咨询爱情烦恼 5040106
                    if task_name == '咨询爱情烦恼' and string.find(result.branch_name,'听') then
                        result.branch_name =  '听阿丽亚娜的反应'
                    end
                    --说服<FONT color='#97FFFD'>管理员露安</FONT>  idx:8.0 task_name:营救行动 1204004
                    if task_name == '营救行动' and string.find(result.branch_name,'说服') then
                     --   result.branch_name =  '说服管理员露安'
                    end
                    -- 检测分支资源 任务ID..IDX..i
                    -- xxmsg(task_name..' '..task_id..main_idx..i..'-branch_name:'..result.branch_name)
                    -- local bran_name = quest_res.get_bran_name(task_name,task_id,main_idx,i)
                    local bran_name = quest_res.get_best_bran_name(task_name,result.branch_name,main_idx)
                    if bran_name ~= '' then
                        result.branch_name = bran_name
                    end
                    -- 分支类型
                    result.tar_type        = quest_obj:tar_type(i)
                    -- 已完成数
                    result.cur_tar_num     = quest_obj:cur_tar_num(i)
                    -- 需要完成数
                    result.cur_tar_max_num = quest_obj:cur_tar_max_num(i)
                    -- 当前分支状态
                    result.target_status   = quest_obj:target_status(i)
                    -- 保存分支
                    table.insert(branch_info,result)
                end
                -- 排序分支
                if not table.is_empty(branch_info) then
                    table.sort(branch_info,function(a, b) return a.tar_type < b.tar_type end)
                end
                quest_info.branch_info  = branch_info
                quest_info.task_type    = not table.is_empty(branch_info) and branch_info[1].tar_type or 23
                table.insert(quest_list,quest_info)
            end
        end
    end
    quest_obj:delete()
    if not table.is_empty(quest_list) then
        table.sort(quest_list,function(a, b) return a.task_type < b.task_type end)
        return quest_list[1]
    end
    return {}
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function quest_ent.__tostring()
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
function quest_ent.__newindex(t, k, v)
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
quest_ent.__index = quest_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function quest_ent:new(args)
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
    return setmetatable(new, quest_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return quest_ent:new()

-------------------------------------------------------------------------------------
