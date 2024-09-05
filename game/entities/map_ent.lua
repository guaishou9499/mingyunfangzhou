------------------------------------------------------------------------------------
-- game/entities/map_ent.lua
--
-- 地图单元
--
-- @module      map_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local map_ent = import('game/entities/map_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class map_ent
local map_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION        = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE    = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME    = 'map_ent module',
    -- 只读模式
    READ_ONLY      = false,
}

-- 实例对象
local this         = map_ent
-- 日志模块
local trace        = trace
-- 决策模块
---@type common
local common       = common
local decider      = decider
local map_unit     = map_unit
local map_ctx      = map_ctx
local actor_unit   = actor_unit
local local_player = local_player
local ship_unit    = ship_unit
local game_unit    = game_unit
local import       = import
local ipairs       = ipairs
local pairs        = pairs
local setmetatable = setmetatable
local rawset       = rawset
local type         = type
local table        = table
local os           = os
local math         = math
local string       = string
local tonumber     = tonumber
local map_res      = import('game/resources/map_res')
---@type map_area_res
local map_area_res = import('game/resources/map_area_res')
---@type dungeon_res
local dungeon_res  = import('game/resources/dungeon_res')
local utils        = import('base/utils')
local ui_ent       = import('game/entities/ui_ent')
---@type actor_ent
local actor_ent    = import('game/entities/actor_ent')
---@type music_ent
local music_ent    = import('game/entities/music_ent')
---@type vehicle_ent
local vehicle_ent  = import('game/entities/vehicle_ent')
---@type skill_ent
local skill_ent    = import('game/entities/skill_ent')
local actor_res    = import('game/resources/actor_res')
---@type item_ent
local item_ent     = import('game/entities/item_ent')
---@type equip_ent
local equip_ent    = import('game/entities/equip_ent')
---@type ship_ent
local ship_ent     = import('game/entities/ship_ent')
-- 是否传送的中转
local filter_tran  = {}
-- 保存使用移动攻击道具时间
local use_status_l = {}
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function map_ent.super_preload()

end

-------------------------------------------------------------------------------------
-- 移动按路径[根据路径资源]
-- kill_list = { { name = '副头目玛戈',type = 2,res_id = 0,x = 0,y = 0,r = 0 },{ name = '青爪团成员',type = 2,res_id = 0 } }
map_ent.execute_move_by_path = function(pos_path,target_x, target_y,target_z, target_r,kill_list,check_task_func,close_attack,stop_riding)
    -- 获取当前地图名称
    local cur_map_name   = actor_unit.map_name()
    -- 没有设置路径退出
    if table.is_empty(pos_path) then return false end
    -- 获取开始节点
    local find_idx,c_dis = this.find_best_start_point(pos_path)
    -- 获取终止节点
    local end_idx        = this.find_best_start_point(pos_path,target_x,target_y,target_z)
    -- 终止节点的条件赋值
    end_idx              = end_idx == 0 and #pos_path  or end_idx == 1 and #pos_path > 1 and #pos_path  or end_idx
    -- 遍历路径表
    for i ,pos in pairs(pos_path) do
        if not decider.is_working() then
            return false
        end
        -- 已在目标点范围 并且高度比值在范围内？？？ 退出
        if local_player:dist_xy(target_x, target_y) < target_r and math.abs(local_player:cz() - target_z) <= c_dis then
            -- 击杀终止范围内怪物
            if not close_attack then
                this.move_to_kill_actor(kill_list,target_r)
            end
            return true
        end
        -- 从获取的节点开始
        if i >= find_idx and i <= end_idx then
            -- 当前节点坐标X
            local x      = pos.x
            -- 当前节点坐标Y
            local y      = pos.y
            -- 当前节点坐标Z
            local z      = pos.z
            -- 当前节点读取目标操作时的范围
            pos.r        = pos.r or 200
            -- 自身移动时的打怪范围
            local k      = pos.kill_r or 100
            -- 打怪时查询目标怪物坐标Z与自身Z的决定差值
            local calc_z = pos.calc_z
            -- 如果在最终的节点 并且高度比值在范围内？？？
            if #pos_path == i then
                if local_player:dist_xy(x, y) < pos.r then
                    return true
                end
            end
            -- 只杀目标点怪物
            local spe_kill = pos.spe_kill
            -- 退出当前节点的距离
            local break_dist   = pos.break_dist
            -- 寻路异常的断出次数
            local break_num    = pos.break_num or 30
            -- 标记寻路的次数
            local flag_move_num  = 0
            -- 标记节点开始时间
            local start_time_idx = {}
            while decider.is_working() do
                -- 过图检测
                common.wait_loading_map()
                -- 动画判断
                ui_ent.esc_cinema()
                -- 死亡检测
                if actor_ent.check_dead() == 2 then
                    return false
                end
                -- 获取当前地图名称
                local now_map  = actor_unit.map_name()
                -- 地图已切换
                if cur_map_name ~= now_map then return false end
                -- 当前节点坐标为0退出
                if x == 0 and y == 0 and z == 0 then break end
                --寻路次数过多时退出【】
                if flag_move_num > break_num then return false end
                -- 任务发生变化时退出
                if check_task_func and type(check_task_func) == 'table' and type(check_task_func.func) == 'function' then
                    if check_task_func.func(check_task_func.task_name,check_task_func.branch_name,check_task_func.quest_idx) then
                        if local_player:is_move() then
                            common.auto_move(local_player:cx() + 200,local_player:cy(),local_player:cz())
                        end
                        return false
                    end
                end
                if start_time_idx[now_map..i] then
                    if os.time() - start_time_idx[now_map..i] > 1800 then
                        if actor_unit.is_dungeon_map() then
                            -- 超时退出副本
                            this.move_go_away()
                        else
                            --
                        end
                    end
                else
                    start_time_idx[now_map..i] = os.time()
                end

                -- 寻路到当前节点,并打怪
                if not close_attack and not this.move_to_kill_actor(pos['击杀'],k,calc_z,nil,nil,spe_kill) or close_attack then
                    -- 检测操作
                    local pos_controls = pos['操作'] or {}
                    -- 需要操作对象的资源ID
                    local res_id       = pos_controls.res_id
                    -- 需要操作对象的名称
                    local name         = pos_controls.name
                    -- 需要操作对象的类型
                    local p_type       = pos_controls.type
                    -- 点击移动到物体上时的高度最大差
                    local max_cz       = pos_controls.max_cz or 50
                    -- 直接G操作
                    local exe_call_g   = pos_controls.call_key
                    -- 是否不改变状态
                    local change_stat  = pos_controls.change_status
                    -- 操作对象后延迟时间
                    local wait_time    = pos_controls.wait_time or 1
                    -- 是否移动到对象上面[移动到目标点后退出] { res_id = 0x10502D,type = 15,wait_to = { x = 0,y = 0,z = 0,action = 1 } }
                    local wait_to      = pos_controls.wait_to
                    -- action = 1 升降机  2 船  0默认 普通寻路 4 鼠标右键
                    local action       = pos_controls.action or 0
                    -- 设置退出距离 不使用默认
                    break_dist         = pos_controls.break_dist or 200
                    -- 备用目标传送
                    local res_id1      = pos_controls.res_id1
                    local p_type1      = pos_controls.type1
                    if type(wait_to) == 'table' and table.is_empty(wait_to) then
                        wait_to        = false
                    end
                    -- 保存需要操作的目标信息
                    local actor_info   = {}
                    if res_id and res_id ~= 0 and p_type then
                        -- 获取指定资源ID 的目标
                        name = res_id
                    end
                    -- 根据条件定义查询对象名
                    name = ( name == '' or not name ) and '未知' or name
                    -- 如果行为不为普通 则设置退出距离为100
                    if action ~= 0 then break_dist = 100 end

                    if now_map == '卢特兰王陵' then
                        break_dist = 50
                    end
                    -- 距离大于指定范围时 或者 高度相差大时移动
                    local dist      = local_player:dist_xy(x,y)--
                    local c_cz      = math.abs(local_player:cz() - z)
                    local max_z     = 100 + (vehicle_ent.is_higth() and 250 or 0)
                    -- 寻路检测
                    this.check_move(x,y,z,stop_riding)
                    -- 检测是否复活传送点
                    local break_func = function()
                        if utils.is_inside_radius(local_player:cx(), local_player:cy(), pos.x,pos.y, 900) then
                            return true
                        end
                        return false
                    end
                    -- 传送工具检测
                    if this.move_transfer_dead(pos.x,pos.y,600,break_func) then
                        decider.sleep(2000)
                        return false
                    end
                    -- 普通模式寻路到目标点
                    if action == 0 and ( dist > break_dist or c_cz >= max_z ) then
                        if not common.is_move() then
                            if not stop_riding then
                                vehicle_ent.auto_riding_vehicle()
                            end
                            trace.output('寻路到节点['..i..','..end_idx..']距：'..math.floor(dist)..' >'..flag_move_num)
                            trace.log_info(i..'----'..end_idx..' 距离：'..dist..' 坐标：'..x..','..y..','..z)
                            common.auto_move(x,y,z,nil,nil,action)
                            flag_move_num = flag_move_num + 1
                            decider.sleep(300*1)
                            if flag_move_num >= break_num then
                                if not table.is_empty(pos.check_move) then
                                    common.auto_move(pos.check_move.x,pos.check_move.y,pos.check_move.z)
                                    decider.sleep(2000)
                                else
                                    common.auto_move(local_player:cx() + 50, local_player:cy() + 50, local_player:cz())
                                end
                            end
                        else
                            -- 5秒检测一次使用装备
                            if common.is_sleep_any('使用装备USE',5) then
                                equip_ent.ues_equip()
                            end
                        end
                    elseif action ~= 0 then -- 针对 船 或 升降机的操作
                        if name ~= '未知' and p_type then
                            -- 下马方便比较高度
                            vehicle_ent.execute_down_riding()
                            -- 获取 指定高范围内的最佳距离物
                            actor_info = actor_ent.get_nearest_self_actor_info_by_rad_pos(name,pos.x,pos.y,pos.r,p_type)
                            if table.is_empty(actor_info) then
                                trace.output('暂未发现可移动目标')
                            else
                                -- 检测高度
                                c_cz      = math.abs(local_player:cz() - actor_info.cz)
                                if c_cz <= max_cz then
                                    if dist > 100 then
                                        trace.output('寻路到节点['..i..','..end_idx..']距：'..math.floor(dist)..' >'..flag_move_num)
                                        trace.log_info(i..'----'..end_idx..' 距离：'..dist..' 坐标：'..x..','..y..','..z)
                                        if action == 4 then
                                            common.mouse_move(x,y,z)
                                        else
                                            common.auto_move(x,y,z,nil,nil,action)
                                        end

                                        flag_move_num = flag_move_num + 1
                                        decider.sleep(300)
                                    else
                                        trace.output('已在物体上..')
                                        local time_out = os.time()
                                        -- 等待到达指定坐标点
                                        while decider.is_working() do
                                            if type(wait_to) ~= 'table' or table.is_empty(wait_to) then
                                                break
                                            end
                                            -- 超时退出
                                            if os.time() - time_out > 300 then
                                                break
                                            end
                                            local m_x = wait_to.x
                                            local m_y = wait_to.y
                                            local m_z = wait_to.z
                                            local b_z = wait_to.break_d or 150
                                            local dis = local_player:dist_xy(m_x,m_y)
                                            local ccz = math.abs(local_player:cz() - m_z)
                                            vehicle_ent.execute_down_riding()
                                            trace.output('等待抵达目标点:',math.floor(dis),' 高:',math.floor(ccz))
                                            if dis < b_z then
                                                if ccz <= 50 then
                                                    break
                                                end
                                            end
                                            decider.sleep(200)
                                        end
                                        break
                                    end
                                else
                                    trace.output('等待目标['..actor_info.name..'靠近]',math.floor(c_cz))
                                    decider.sleep(1000)
                                end
                            end
                        end
                    else
                        -- 获取 指定高范围内的最佳距离物
                        actor_info = actor_ent.get_nearest_self_actor_info_by_rad_pos(name,pos.x,pos.y,pos.r,p_type,300)
                        if table.is_empty(actor_info) then
                            break
                        end
                        local is_do = true
                        -- 检测是否有效[问号传送]
                        if p_type == 8 and actor_info.type_seven_status == 0 then
                            trace.output('目标未显示,等待操作..')
                            is_do = false
                        end
                        -- 获取备用传送信息
                        if not is_do and res_id1 and p_type1 then
                            local actor_info1 = actor_ent.get_nearest_self_actor_info_by_rad_pos(res_id1,pos.x,pos.y,pos.r,p_type1,600)
                            if not table.is_empty(actor_info1) then
                                actor_info = actor_info1
                                p_type     = p_type1
                                is_do      = true
                                wait_time  = 3
                            end
                        end
                        -- 将 坐标 重新定义为对象坐标
                        x,y,z = actor_info.cx,actor_info.cy,actor_info.cz
                        if is_do then
                            local w = wait_time and wait_time * 1000 or 1000
                            -- 移动到这个点 --
                            if actor_info.dist < 200 then
                                -- 检测状态
                                if actor_unit.get_local_player_status() ~= 1 and not change_stat then
                                    common.key_call('KEY_R')
                                    decider.sleep(1000)
                                end
                                if not exe_call_g and ( p_type == 6 and actor_info.is_valid or p_type ~= 6 ) then
                                    trace.output('按键G操作')
                                    decider.sleep(1000)

                                    if p_type == 8 then
                                        trace.log_info(string.format('采集8：0x%X',actor_info.obj))
                                        actor_unit.transfer_talk(actor_info.obj)
                                    else
                                        if actor_info.can_gather then
                                            trace.log_info(string.format('采集O：0x%X',actor_info.obj))
                                            actor_unit.gather_talk(actor_info.obj)
                                        end
                                    end
                                end
                                -- 按键G
                                common.key_call(exe_call_g or 'KEY_G')
                                decider.sleep(1000)
                                common.wait_over_state()
                                common.wait_show_str('切换到['.. i + 1 ..']节点',wait_time)
                                --trace.output('等待',wait_time,'秒,切换下一节点')
                                --sleep(w)
                                break
                            end
                        end
                    end
                else
                    -- 如果是打怪 将寻路标记为0
                    flag_move_num = 0
                end
                decider.sleep(100)
            end
        end
    end
end

-------------------------------------------------------------------------------------
-- [行为] 攻击范围内怪物
map_ent.move_to_kill_actor = function(kill_list,r,kill_z,kill_f5,kill_self,kill_spe)
    kill_list = kill_list or {}
    -- xxmsg(string.format('%X----%s',kill_list[1].res_id,kill_list[1].type))
    -- 死亡后返回真 退出移动
    if actor_ent.check_dead() == 2 then
        return true
    end
    local map_name   =  actor_unit.map_name()
    local height     = vehicle_ent.is_higth()
    local add_kill_z = 0
    -- 设置击杀绝对高度
    if not kill_z then
        if height then
            add_kill_z = 100
            if map_name == '克拉提尔之心' then
                add_kill_z = 150
            end
        end
        kill_z = 200 + add_kill_z
    end
    -- 集合击杀目标列表
    local palisade = actor_res.PALISADE_MON
    local pal_idx  = 1
    if not table.is_empty(kill_list) then
        pal_idx = 2
    end
    table.move(palisade,pal_idx,#palisade,#kill_list + 1,kill_list)
    --for _,v in pairs(kill_list) do
    --    xxmsg(string.format('%X',v.res_id))
    --end
    -- 自身读取障碍范围
    local self_kill  = kill_self or 100
    -- 攻击范围
    local kill_a_dis = 500
    -- 定义需要击杀的信息,最佳
    local kill_info  = {}
    -- 所有符合的环境
    local all_list   = {}
    -- 角色是否在移动
    local is_move    = local_player:is_move()
    -- 角色移动 并且在马时不击杀
    if vehicle_ent.is_riding() and is_move then
        return false
    end
    -- 移动时检测是否特别地图
    local need_move_kill = actor_res.NEED_MOVE_KILL[map_name]
    if need_move_kill and not table.is_empty(need_move_kill) then
        self_kill = need_move_kill.search_dis or self_kill
        kill_a_dis = need_move_kill.attack_dis or kill_a_dis
    end
    -- 是否在讨伐
    if dungeon_res.is_in_stars_guard() then
        self_kill = 60
        r         = 60
    end
    -- 读取自身范围内的目标
    local self_r,s_all_list  = actor_ent.get_actor_info_list_by_rad_pos_and_list(kill_list,local_player:cx(),local_player:cy(),self_kill)
    -- xxmsg(tostring(table.is_empty(self_r)).. ' '..tostring(table.is_empty(s_all_list)).. ' '..tostring(table.is_empty(kill_list)))
    -- 自身在移动  只击杀自身100范围内目标
    if  is_move and not table.is_empty(self_r) then
        if not r then
            r = 100
        end
        kill_info   = self_r
        all_list    = s_all_list
    end
    -- 如果在战斗状态 或者 未移动
    if local_player:is_battle() or not is_move then
        r = r or 1000
        kill_info,all_list = actor_ent.get_actor_info_list_by_rad_pos_and_list(kill_list,local_player:cx(),local_player:cy(),r)
        -- xxmsg(tostring(table.is_empty(kill_info)).. ' '..tostring(table.is_empty(all_list)))
    end
    -- 检测血量
    item_ent.auto_use_hp_ex()
    -- xxmsg(tostring(table.is_empty(kill_info)).. ' '..tostring(table.is_empty(all_list)))
    -- 从所有目标中取符合击杀高度的对象
    if not table.is_empty(all_list) then
        for _,v in pairs(all_list) do
            local add_h = actor_res.get_need_add_kill_h(v.name,v.res_id)
            if  math.abs(local_player:cz() - v.cz) <= ( add_h > 0 and add_h or kill_z ) then
                kill_info = v
                break
            end
        end
        -- 血量为0的怪物
        if kill_info.hp == 0 and kill_info.type == 2 then
            -- 选择血量大于0对象
            for _,v in pairs(all_list) do
                local add_h = actor_res.get_need_add_kill_h(v.name,v.res_id)
                if v.hp > 0 and math.abs(local_player:cz() - v.cz) <= ( add_h > 0 and add_h or kill_z ) then
                    kill_info = v
                    break
                end
            end
        end
        local s_kill_info = {}
        -- 特殊怪物血量的最低值
        for _,v in pairs(all_list) do
            local hp    = actor_res.HP_MONSTER[v.name]
            local add_h = actor_res.get_need_add_kill_h(v.name,v.res_id)
            if type(hp) == 'number' and v.hp >= hp and math.abs(local_player:cz() - v.cz) <= ( add_h > 0 and add_h or kill_z ) then
                s_kill_info = v
                break
            end
        end
        if not table.is_empty(s_kill_info) then
            kill_info = s_kill_info
        end
    end
    -- 检测击杀绝对高度,重筛
    if not table.is_empty(kill_info) then
        local add_h = actor_res.get_need_add_kill_h(kill_info.name,kill_info.res_id)
        if add_h and add_h > 0 then
            kill_z = add_h
        end
        -- 同名异常的情况
        if #all_list == 2 then
            table.sort(all_list,function(a, b) return a.type_seven_status > b.type_seven_status end)
            -- type_seven_status
            for _,v in pairs(all_list) do
                if v.name == kill_info.name then
                    kill_info = v
                    break
                end
            end
        end
        -- xxmsg(tostring(table.is_empty(kill_info))..' '..math.abs(local_player:cz() - kill_info.cz)..' '..kill_z)
    end

    -- 击杀目标
    if not table.is_empty(kill_info) and math.abs(local_player:cz() - kill_info.cz) <= kill_z then
        -- 是否需要按键H的对象
        if  actor_res.need_key_h(kill_info.name) and common.is_sleep_any('USE_KEY_H_KILL',10)  then
            common.key_call('KEY_H')
        end
        -- 特殊处理的怪物攻击距离
        local dis_special = actor_res.NEED_SET_DIS[kill_info.name]
        kill_a_dis = dis_special or kill_a_dis
        if kill_info.dist <= kill_a_dis then
            vehicle_ent.execute_down_riding()
            trace.output('击杀：',kill_info.name,' HP：',kill_info.max_hp > 0 and math.floor(kill_info.hp * 100/kill_info.max_hp) or 100,'%')
            -- 沼泽怪物
            local cx,cy,cz = string.format('%0.3f',kill_info.cx),string.format('%0.3f',kill_info.cy),string.format('%0.3f',kill_info.cz)
            cx,cy,cz = tonumber(cx),tonumber(cy),tonumber(cz)
            if kill_info.hp > 0 and kill_info.type == 2 or kill_info.type ~= 2 then
                if kill_f5 then
                    common.key_call('KEY_F5')
                    decider.sleep(300)
                    game_unit.set_mouse_pos(cx,cy,cz)
                    decider.sleep(300)
                    common.key_call('KEY_F5')
                    common.wait_over_state()
                else
                    if actor_unit.get_local_player_status() == 4 then
                        common.key_call('KEY_R')
                    end
                    skill_ent.auto_skill(kill_info.cx, kill_info.cy, kill_info.cz,item_ent.auto_use_hp_ex,nil,actor_res.NEED_UNIQUE_SKILL[kill_info.name])
                end
            end
        else
            local key = kill_info.obj..kill_info.cx..kill_info.cy..kill_info.cz
            if not common.is_move() then
                common.get_interval_change('attack_obj',true)
                -- 需要鼠标右键移动的怪物
                local mouse_name = actor_res.NEED_MOUSE_M[kill_info.name] or actor_res.NEED_MOUSE_M[kill_info.res_id]
                if mouse_name then -- or kill_info.dist < 600
                    common.mouse_move(kill_info.cx, kill_info.cy, kill_info.cz)
                else
                    common.auto_move(kill_info.cx, kill_info.cy, kill_info.cz)
                end
                decider.sleep(200)
            else
                -- 计算上次锁定目标
                local bool_val,count = common.get_interval_change('attack_obj',key,10)
                if bool_val == 2 and count > 5 then
                    common.get_interval_change('attack_obj',true)
                    common.auto_move_ex(local_player:cx() + 100,local_player:cy(),local_player:cz())
                end
            end
        end
        return true
    end
    -- 在地牢时检测道具
    if actor_unit.is_dungeon_map() then
        -- 检测是否去获取道具物品
        local status = actor_unit.get_local_player_status()
        if status == 1 then
            local info = actor_ent.get_actor_info_list_by_rad_pos_and_list(actor_res.NEED_STATUS,local_player:cx(),local_player:cy(),1000,300)
            if not table.is_empty(info) then
                local key = 'USE_'..info.name..info.res_id
                if not use_status_l[key] then
                    use_status_l[key] = 0
                end
                if os.time() - use_status_l[key] > 5 then
                    if info.dist < 600 then
                        common.mouse_move(info.cx, info.cy, info.cz)
                    end
                    if info.dist <= 200 then
                        common.key_call('KEY_G')
                        decider.sleep(300)
                        -- 计算当前执行的次数
                        local count = common.get_handle_count(key,60)
                        if actor_unit.get_local_player_status() == 1 and count < 5 then
                            common.key_call('KEY_Q')
                        else
                            use_status_l[key] = os.time()
                        end
                    else
                        if not common.is_move() then
                            common.auto_move(info.cx, info.cy, info.cz)
                            decider.sleep(500)
                        end
                    end
                    return true
                end
            end
        end
    end
    return false
end

-------------------------------------------------------------------------------------
-- [行为] 开启宝箱
map_ent.move_to_gather_chest = function()
    while decider.is_working() do
        local can_gather  = false
        local _,info_list = actor_ent.get_actor_info_list_by_rad_pos_and_list(actor_res.CHEST_INFO,local_player:cx(),local_player:cy(),1000,300)
        if not table.is_empty(info_list) then
            for _,v in pairs(info_list) do
                if v.type_seven_status == 1 then
                    common.wait_loading_map()
                    ui_ent.esc_cinema()
                    trace.output('拾取宝箱.')
                    this.move_curr_map_to(nil,nil,v.cx,v.cy,v.cz,150)
                    common.key_call('KEY_G')
                    common.wait_over_state()
                    common.key_call('KEY_Q')
                    can_gather = true
                    decider.sleep(1000)
                    break
                end
            end
        end
        if not can_gather then
            break
        end
        decider.sleep(1000)
    end
end

-------------------------------------------------------------------------------------
-- [行为] 寻路到NPC对话
map_ent.move_to_talk = function(npc_info)
    if not table.is_empty(npc_info) then
        local npc_info1 = actor_ent.get_nearest_npc_info_for_list(npc_info.name)
        if not table.is_empty(npc_info1) and npc_info1.dist < 300 then
            npc_info = npc_info1
        end
        -- NPC不可对话 返回
        if not npc_info.npc_can_talk then
            xxxmsg(3,npc_info.name..' 已完成对话')
            return false
        end
        -- 获取距离最近的目标
        if npc_info.dist < 200 then
            -- 对话
            actor_unit.npc_talk(npc_info.id, 1)
            decider.sleep(3000)
        else
            -- 移动到村民 G
            xxmsg(npc_info.dist..' 移动到 '..npc_info.name..' '..npc_info.cx..','..npc_info.cy..','..npc_info.cz)
            if not local_player:is_move() then
                common.auto_move(npc_info.cx,npc_info.cy,npc_info.cz)
            end
        end
        return true
    end
    return false
end

-------------------------------------------------------------------------------------
-- [读取] 寻找最佳的起始坐标（三维）
map_ent.find_best_start_point = function(pos_path,x,y,z)
    local bestStartIndex = 0
    local bestDistance   = math.huge
    local m_x            = x or local_player:cx()
    local m_y            = y or local_player:cy()
    local m_z            = z or local_player:cz()
    local c_dis          = 300
    local map_name       =  actor_unit.map_name()
    local height         = vehicle_ent.is_higth()
    -- Z的比值范围
    local can_z_rand    = height and ( map_name == '克拉提尔之心' and 350 or 250 ) or 50
    -- 如果地图在卢特兰
    if map_name == '卢特兰王陵' then -- or map_name == '克拉提尔之心'
        can_z_rand = 100
        c_dis = 200
    end
    local can_z_list     = {}
    -- 获取区域信息
    local area_list      = {}
    for i, pos in ipairs(pos_path) do
        -- 将Z在一定范围内的比值 放入列表
        local  cacl_z = math.abs(m_z - pos.z)
        local action  = pos['操作'] and pos['操作'].action or 0
        if cacl_z < can_z_rand and action == 0 then
            pos.idx    = i
            pos.cacl_z = cacl_z
            table.insert(can_z_list,pos)

        end
        -- 获取当前坐标所在的区域  将区域加入到列表
        local coords = pos['区域']
        if not table.is_empty(coords) then
            -- 判断指定点是否在区域
            if utils.is_inside_polygon(m_x, m_y, coords) then
                pos.idx    = i
                pos.cacl_z = cacl_z
                table.insert(area_list,pos)
            end
        end
    end
    if not table.is_empty(area_list) then
        can_z_list = area_list
    end
    if not table.is_empty(can_z_list) then
        table.sort(can_z_list,function(a, b) return a.cacl_z < b.cacl_z end)
        -- 计算区域
        for _, pos in ipairs(can_z_list) do
            local distance = math.sqrt((pos.x - m_x) ^ 2 + (pos.y - m_y) ^ 2 + (pos.z - m_z) ^ 2)
             -- xxmsg(pos.x..','..pos.y..','..pos.z..' '..pos.idx..' distance:'..distance..' bestDistance:'..bestDistance)
            if distance < bestDistance then
                bestDistance = distance
                bestStartIndex = pos.idx
            end
        end
    end
   --  xxmsg('bestStartIndex:'..bestStartIndex)
    return bestStartIndex,c_dis
end

-------------------------------------------------------------------------------------
-- [行为] 激活当前地图的传送柱
map_ent.move_to_active_transfer = function(active_name,active_map_name)
    while decider.is_working() do
        -- 动画判断
        ui_ent.esc_cinema()
        -- 在小岛或者剧情 退出
        if actor_unit.is_dungeon_map() then
            return
        end
        local map_id      = actor_unit.map_id()
        local map_name    = active_map_name or actor_unit.map_name()
        local t_info_res  = this.get_transfer_res_info_by_map_name(map_name)
        local t_info      = this.get_map_transfer_info_by_map_id(map_id)
        -- 保存最近坐标
        local min_dis     = 9999999
        if active_name then
            for _,info in pairs(t_info) do
                if info.is_active then
                    local name = info.name
                    if not table.is_empty(t_info_res) and t_info_res[name] and active_name and active_name == name then
                        return
                    end
                end
            end
        end
        -- 保存最佳的传送点
        local best_t_info = {}
        for _,info in pairs(t_info) do
            -- 当前传送点已激活
            if not info.is_active then
                -- 传送点名称
                local name = info.name
                -- xxmsg(name..' '..tostring(table.is_empty(t_info_res)))
                if not table.is_empty(t_info_res) and t_info_res[name] then
                    local x_res,y_res = t_info_res[name].x,t_info_res[name].y
                    local dist = utils.distance(local_player:cx(),local_player:cy(),x_res,y_res)
                    if dist < min_dis or active_name and active_name == name then
                        -- 获取的是距离最近的传送点
                        min_dis          = dist
                        best_t_info      = info
                        best_t_info.pos  = t_info_res[name]
                        best_t_info.dist = dist
                        if active_name and active_name == name then
                            break
                        end
                    end
                end
            end
        end
        if table.is_empty(best_t_info) then return end
        trace.output('去激活',best_t_info.name,'传送柱')
        this.move_curr_map_to(map_name,false,best_t_info.pos.x,best_t_info.pos.y,best_t_info.pos.z,100)
        local actor_info = actor_ent.get_actor_info_by_name(best_t_info.name,6)
        if not table.is_empty(actor_info)  then
            actor_unit.gather_talk(actor_info.obj)
        end
        decider.sleep(2000)
    end
end

-------------------------------------------------------------------------------------
-- [条件] 判断指定地图是否存在激活的传送点
map_ent.is_active_transfer_by_map_name = function(map_name)
    local map_id        = this.get_map_id_by_map_name(map_name)
    local transfer_list	= map_unit.get_transfer_list_by_mapid(map_id)
    for i = 1, #transfer_list do
        local obj = transfer_list[i]
        if map_ctx:init(obj) and map_ctx:is_active() then
            return true
        end
    end
    return false
end

-------------------------------------------------------------------------------------
-- [条件] 获取指定地图指定传送柱名是否已激活
map_ent.is_active_by_map_id_and_transfer_name = function(map_id,transfer_name)
    local transfer_list	= map_unit.get_transfer_list_by_mapid(map_id)
    for i = 1, #transfer_list do
        local obj = transfer_list[i]
        if map_ctx:init(obj) and transfer_name == map_ctx:name() then
            local need_task_info = map_res.TRANSFER_NEED_FINISH_TASK[transfer_name]
            -- 如果需要任务完成,未完成则返回 false
            if need_task_info and not common.is_finish_quest_by_map_id_and_name(need_task_info.need_task,need_task_info.need_task_map) then
                return false
            end
            return map_ctx:is_active()
        end
    end
    return false
end

-------------------------------------------------------------------------------------
-- [行为] 移动到大海
map_ent.move_to_sea = function(map_name)
    -- 目标地图不是大海时退出
    if not string.find(map_name,'大航海') then
        return
    end
    -- 寻路的次数
    local c_move_num = 0
    while decider.is_working() do
        -- 自身在大海时退出
        local cur_map_name   = actor_unit.map_name()
        if string.find(cur_map_name,'大航海') then
            return
        end
        -- 获取大陆
        local curr_main_name = this.get_main_map_by_map_name(cur_map_name)
        --1. 寻找当前地图码头
        local curr_quay      = this.get_quay_pos_by_main_name(curr_main_name)
        if not table.is_empty(curr_quay) then
            -- 寻路到码头
            if this.move_to_map(curr_quay['地图名']) then
                this.move_curr_map_to(curr_quay['地图名'],nil,curr_quay['出港'].x,curr_quay['出港'].y,curr_quay['出港'].z,100,nil,nil,nil,true,nil,curr_quay['出港'].call)
                c_move_num = c_move_num + 1
                if c_move_num > 2 and not curr_quay['出港'].call then
                    this.move_away_from_this_pos(150)
                end
            end
        else
            trace.output('出港-',curr_main_name,'没有码头城市资源')
        end
        decider.sleep(2000)
        common.wait_loading_map()
    end
end

-------------------------------------------------------------------------------------
-- [行为] 检测维修船
map_ent.check_require_ship = function(x,y)
    while decider.is_working() do
        local cur_map_name   = actor_unit.map_name()
        local is_in_ship = string.find(cur_map_name,'大航海')
        if not is_in_ship then
            break
        end
        -- 船耐大于0 退出
        local ship_durable = ship_unit.get_cur_ship_durable()
        if  ship_durable > 0 then
            break
        end
        local n_quay_city,n_quay_x,n_quay_y,n_quay_z = this.get_nearest_quay_pos(x,y)
        if n_quay_city == '' then
            break
        end
        local m_dist = local_player:dist_xy(n_quay_x,n_quay_y)
        if m_dist > 500 then
            ui_ent.esc_cinema()
            trace.output('前往：',n_quay_city,'修理【'..math.floor(ship_durable)..'】')
            if not local_player:is_move() then
                common.auto_move(n_quay_x,n_quay_y,n_quay_z)
            end
        else
            -- 检测耐久修理
            ship_ent.require_ship()
        end
        decider.sleep(2000)
    end
end

-------------------------------------------------------------------------------------
-- [条件] 是否在相同大陆,非时航海
map_ent.is_in_same_main_map = function(map_name)
    -- 保存上次航行距离信息
    local s_move     = {}
    -- 保存航行速度
    local sdu        = 0
    -- 异常寻路次数
    local c_move_num = 0
    while decider.is_working() do
        -- 检测过图
        common.wait_loading_map()
        -- 关闭UI相关
        ui_ent.esc_cinema()
        -- 当前地图名称
        local cur_map_name   = actor_unit.map_name()
        -- 检测是否在相同的大陆
        local curr_main_name = this.get_main_map_by_map_name(cur_map_name)
        -- 目标大陆名称
        local go_main_name   = this.get_main_map_by_map_name(map_name)
        -- xxmsg(tostring(curr_main_name)..'-----'..tostring(go_main_name))
        -- 不在同一大陆
        if curr_main_name ~= go_main_name and cur_map_name ~= '罗纳道' then
            --1. 寻找当前地图码头
            local curr_quay  = this.get_quay_pos_by_main_name(curr_main_name)
            --2. 寻找指定地图码头
            local go_quay    = this.get_quay_pos_by_main_name(go_main_name)
            -- 是否在大海
            local is_in_ship = string.find(cur_map_name,'大航海')
            -- 异常寻路次数
            c_move_num       = is_in_ship and 0 or c_move_num
            -- 非在船上
            if not is_in_ship then
                if not table.is_empty(curr_quay) then
                    -- 寻路到码头
                    if this.move_to_map(curr_quay['地图名']) then
                        this.move_curr_map_to(curr_quay['地图名'],nil,curr_quay['出港'].x,curr_quay['出港'].y,curr_quay['出港'].z,100,nil,nil,nil,true,nil,curr_quay['出港'].call)
                        c_move_num = c_move_num + 1
                        if c_move_num > 2 and not curr_quay['出港'].call then
                            this.move_away_from_this_pos(150)
                        end
                    end
                else
                    trace.output('大陆-',curr_main_name,'没有码头城市资源')
                    -- 当前地图是否为地牢地图-- 检测使用逃离之歌
                    if actor_unit.is_dungeon_map() then
                        -- 检测宝箱
                        this.move_to_gather_chest()
                        this.move_go_away()
                    end
                end
            else
                local cur_ship_durable = ship_unit.get_cur_ship_durable()
                local ship_max_durable = ship_unit.get_cur_ship_max_durable()
                -- 首次打开船描[刷新数据]
                if cur_ship_durable == 0 and ship_max_durable == 0 then
                    trace.output('刷新船数据')
                    common.key_call('KEY_Z')
                    decider.sleep(3000)
                    cur_ship_durable = ship_unit.get_cur_ship_durable()
                    ship_max_durable = ship_unit.get_cur_ship_max_durable()
                end
                -- 标记是否维修触发
                local is_repaire = false
                -- 获取最近的码头位置
                local n_quay_city,n_quay_x,n_quay_y,n_quay_z = this.get_nearest_quay_pos()
                -- 检测耐久,距离码头小于1000
                if local_player:dist_xy(n_quay_x,n_quay_y,n_quay_z) < 500 then
                    -- 检测耐久修理
                    ship_ent.require_ship()
                    -- 选择指定船
                    ship_ent.sel_ship_by_name()
                    -- 检测耐久修理
                    ship_ent.require_ship()
                end
                -- 正在船上 移动到指定的码头位置
                if not table.is_empty(go_quay) then
                    local g_quay_map_name,g_quay_x,g_quay_y,g_quay_z,g_quay_call = go_quay['地图名'],go_quay['进港'].x,go_quay['进港'].y,go_quay['进港'].z,go_quay['进港'].call
                    -- 如果当前耐久为0 ,获取距离目标点最近的码头
                    if g_quay_call and cur_ship_durable == 0 then
                        -- xxmsg('需维修：'.. cur_ship_durable..' '..ship_max_durable)
                        g_quay_map_name,g_quay_x,g_quay_y,g_quay_z,g_quay_call = this.get_nearest_quay_pos(g_quay_x,g_quay_y)
                        is_repaire = true
                    end
                    local m_dist          = local_player:dist_xy(g_quay_x,g_quay_y)
                    local need_t          = '未知'
                    if table.is_empty(s_move) then
                        s_move.x    = local_player:cx()
                        s_move.y    = local_player:cy()
                        s_move.time = os.time()
                    else
                        if os.time() - s_move.time >= 5 then
                            sdu = utils.distance(local_player:cx(),local_player:cy(),s_move.x,s_move.y)/( os.time() - s_move.time )
                            s_move.x = local_player:cx()
                            s_move.y = local_player:cy()
                            s_move.time = os.time()
                        end
                    end
                    -- 速度大于0
                    if sdu > 0 then
                        need_t = '预计'..math.floor(m_dist/sdu)..'秒'
                    end
                    local b_dis = 300
                    if g_quay_call then
                        b_dis = 100
                    end
                    if m_dist > b_dis then
                        -- 执行出港[停靠界面]
                        if ship_unit.is_open_anchor_frame() then
                            ship_unit.ship_leave_potr()
                            decider.sleep(1000)
                        end
                        local m_state = common.is_move()
                        local ship_durable_pro = cur_ship_durable * 100/ship_max_durable
                        local str_move = m_state and '正航行..['..math.floor(ship_durable_pro)..']' or '正停泊..['..math.floor(ship_durable_pro)..']'
                        trace.output('前往【',g_quay_map_name,'】港(',need_t,')',str_move)
                        -- xxmsg(g_quay_x..' '..g_quay_y..' '..g_quay_z..' '..tostring(m_state))
                        if not m_state then
                            sdu = 0 -- 重置速度
                            common.auto_move(g_quay_x,g_quay_y,g_quay_z)
                        else
                            --- 检测能量 按键空格加速
                            if m_dist > 2000 and common.is_sleep_any('按键空格加速',11) then
                            --    common.key_call(32)
                            end
                        end
                    else
                        ---   执行入港
                        trace.output('已到达【',g_quay_map_name,'】港')
                        if not is_repaire then
                            if not g_quay_call then
                                -- 检测耐久修理
                                ship_ent.require_ship()
                                if ship_unit.is_open_anchor_frame() then
                                    decider.sleep(2000)
                                    ship_unit.ship_into_port()
                                else
                                    common.key_call('KEY_Z')
                                end
                            else
                                common.key_call(g_quay_call)
                            end
                            decider.sleep(3000)
                        end
                    end
                else
                    trace.output(go_main_name,'没有目标码头资源记录')
                end
            end
        else
            -- 在相同的大陆
            return true
        end
        decider.sleep(2000)
        common.wait_loading_map()
    end
    return false
end

-------------------------------------------------------------------------------------
-- [行为] 退出地牢
map_ent.move_go_away = function()
    if actor_unit.map_name() ~= '特里希温' then
        if not map_ent.move_to_kill_actor(nil,500) then
            music_ent.use_music_by_name('逃离之歌')
            decider.sleep(1000)
        end
    else
        if common.auto_move_ex(12907.96875, 148.98905944824, 232.8,1) then
            common.key_call('KEY_G')
            decider.sleep(1000)
        end
    end
    common.wait_loading_map()
end

-------------------------------------------------------------------------------------
-- [行为] 离开 特里希温
map_ent.move_go_away_tlsw = function()
    while decider.is_working() do
        if actor_unit.map_name() ~= '特里希温' then
            break
        else
            ui_ent.esc_cinema()
            trace.output('离开 特里希温')
            if common.auto_move_ex(12907.96875, 148.98905944824, 232.8,1) then
                common.key_call('KEY_G')
                decider.sleep(1000)
            end
        end
        decider.sleep(1000)
        common.wait_loading_map()
    end
end

-------------------------------------------------------------------------------------
-- [行为] 寻路到指定地图指定位置
map_ent.move_to = function(map_name,area_name,x,y,z,stop_dist,stop_riding)
    -- 在相同的大陆
    if this.move_to_map(map_name) then
        -- 寻路到指定目标点
        if this.move_curr_map_to(map_name,area_name,x,y,z,stop_dist,nil,nil,stop_riding) then
            return true
        end
    end
    return false
end

-------------------------------------------------------------------------------------
-- [行为] 寻路到指定地图
map_ent.move_to_map = function(map_name_e,check_task_func,stop_transfer)
    local map_name = map_name_e
    while decider.is_working() do
        -- 获取当前地图名称
        local cur_map = actor_unit.map_name()
        -- 当前位置是否在目标地图时退出
        if cur_map == map_name or not map_name or map_name and string.find(map_name,'大航海') then
            return true
        end
        ----------------------------------------------------------------------------------------------------------------
        -- 任务发生变化时退出
        if check_task_func and type(check_task_func) == 'table' then
            if type(check_task_func.func) == 'function' then
                -- xxmsg(check_task_func.task_name..' '..check_task_func.branch_name)
                if check_task_func.func(check_task_func.task_name,check_task_func.branch_name,check_task_func.quest_idx) then
                    xxmsg('move_to_map..暂停：'..check_task_func.task_name)
                    if local_player:is_move() then
                        common.auto_move(local_player:cx() + 200,local_player:cy(),local_player:cz())
                    end
                    break
                end
            end
        end
        ----------------------------------------------------------------------------------------------------------------
        actor_ent.check_dead()
        ui_ent.esc_cinema()
        ----------------------------------------------------------------------------------------------------------------
        -- 如果在大海则去最近的大陆
        if map_name == '特里希温' and string.find(cur_map,'大航海') then
            map_name = this.get_best_power_city()
        else
            map_name = map_name_e
        end
        ----------------------------------------------------------------------------------------------------------------
        if map_name == '特里希温' then
            -- 使用 特里希温之歌
            music_ent.use_music_by_name('特里希温之歌')
        else
            -- 在相同大陆时
            if this.is_in_same_main_map(map_name) then
                if not stop_transfer then
                    -- 获取指定地图传送点信息
                    this.execute_transfer_to_map(map_name)
                end
                -- 当前位置是否在目标地图时退出
                if actor_unit.map_name() == map_name then return true end
                -- 获取寻路路径
                local is_in_map,move_path,move_path1 = this.get_move_map_path_by_map_name(map_name)
                if is_in_map then return true end
                local is_transfer = false
                -- 检测是否传送到可传送点
                for _,info in pairs(move_path1) do
                    -- 如果可传送则传送后退出
                    --xxmsg(info.map_name..' '..info.idx..' ,'..info.move_pos.x..' '..info.move_pos.y..' '..info.move_pos.z)
                    if not stop_transfer and this.execute_transfer_to_map(info.map_name,info.move_pos.x,info.move_pos.y,info.move_pos.z) then
                        is_transfer = true
                        break
                    end
                end
                if not is_transfer then
                    for _,info in pairs(move_path) do
                        if actor_unit.map_name() ~= map_name then
                            -- xxmsg(info.map_name..' '..info.move_pos.x..','..info.move_pos.y..','..info.move_pos.z)
                            -- 当前地图寻路到指定点
                            this.move_curr_map_to(info.map_name,info.move_pos.area_name,info.move_pos.x,info.move_pos.y,info.move_pos.z,100,nil,map_name,nil,nil,nil,nil,stop_transfer)
                        end
                    end
                end
            end
        end
        decider.sleep(1000)
        common.wait_loading_map()
    end
    return false
end

-------------------------------------------------------------------------------------
-- [行为] 当前地图区域寻路
map_ent.move_curr_map_to_ex = function(map_name,x,y,z,action,func_area)
    map_name       = map_name or actor_unit.map_name()
    action         = action   or 0
    local time_out = 0
    while decider.is_working() do
        common.wait_loading_map()
        if actor_unit.map_name() ~= map_name then
            break
        end
        actor_ent.check_dead()
        ui_ent.esc_cinema()
        if local_player:dist_xy(x,y) < 100 then
            break
        end
        if type(func_area) == 'function' then
            -- xxmsg('func_area :'..tostring(func_area()))
            if func_area() then
                break
            end
        end
        if time_out > 10 then
            break
        end
        if not local_player:is_move() then
            if action == 4 then
                common.mouse_move(x,y,z)
            else
                trace.output('寻路到(',math.floor(x),',',math.floor(y),',',math.floor(z),').')
                common.auto_move(x,y,z,nil,nil,action)
            end
            time_out = time_out + 1
        end
        decider.sleep(200)
    end
end

-------------------------------------------------------------------------------------
-- [行为] 远离当前点一定距离
map_ent.move_away_from_this_pos = function(away_dist)
    local x,y,z = this.get_nearest_transfer_info()
    if x == 0 and y == 0 then return end
    local cur_map_name = actor_unit.map_name()
    local cur_x,cur_y  = local_player:cx(),local_player:cy()
    while decider.is_working() do
        -- 地图切换了退出
        if cur_map_name ~= actor_unit.map_name() then
            break
        end
        if local_player:dist_xy(cur_x,cur_y) > away_dist then
            if local_player:is_move() then
                common.auto_move(local_player:cx(),local_player:cy(),local_player:cz())
            end
            break
        end
        common.auto_move_ex(x,y,z,100)
        decider.sleep(1000)
    end
end

-------------------------------------------------------------------------------------
-- [行为] 当前地图寻路到指定点 如果目标存在区域则需要区域判断
-- @tparam  string  map_name         地图名称当前
-- @tparam  string  area_name        区域名称
-- @tparam  number  x                地图坐标x
-- @tparam  number  y                地图坐标y
-- @tparam  number  z                地图坐标z
-- @tparam  number  stop_dist        退出目标点的距离
-- @tparam  table   check_task_func  检测退出任务的表：
-- @tparam  string  m_map_name       地图名称,主要使用传送住
-- @tparam  bool    stop_riding      是否终止上马 true 不上马
-- @tparam  bool    go_air           是否去大海
-- @tparam  bool    close_attack     是否关闭攻击
-- @tparam  string  call_key         到达目标点时使用指定按键
-- @tparam  bool    stop_transfer    是否禁用传送 默认传送  true禁用
map_ent.move_curr_map_to = function(map_name,area_name,x,y,z,stop_dist,check_task_func,m_map_name,stop_riding,go_air,close_attack,call_key,stop_transfer)
    stop_dist                  = stop_dist or 200
    map_name                   = map_name  or actor_unit.map_name()
    local move_x,move_y,move_z = x,y,z
    local ret                  = false
    local wait                 = false
    -- 标记引用移动的次数
    local move_num             = 0
    while decider.is_working() do
        local w_time = 1000
        -- 检测过图
        common.wait_loading_map()
        if actor_unit.map_name() ~= map_name then
            break
        end
        -- 是否出港口
        if go_air then
            if ship_unit.is_in_ocean() or ship_unit.is_open_anchor_frame() then
                break
            end
        end
        if m_map_name and not go_air then
            if not stop_transfer then
                this.execute_transfer_to_map(m_map_name)
            end
            if actor_unit.map_name() == m_map_name then
                break
            end
        end

        if ( local_player:dist_xy(x,y) < stop_dist or x == 0 and y == 0 )
                and ( not area_name or area_name == this.get_cur_scene_map_name() or area_name == '' ) then
            ret = true
            break
        end

        -- 检测死亡
        actor_ent.check_dead()
        -- 动画检测
        ui_ent.esc_cinema()
        -- 对话框检测
        ui_ent.exist_npc_talk()
        -- 自动使用药品
        item_ent.auto_use_hp_ex()
        -- 任务发生变化时退出
        if check_task_func and type(check_task_func) == 'table' then
            if type(check_task_func.func) == 'function' then
                -- xxmsg(check_task_func.task_name..' '..check_task_func.branch_name)
                if check_task_func.func(check_task_func.task_name,check_task_func.branch_name,check_task_func.quest_idx) then
                    xxmsg('切换任务..暂停：'..check_task_func.task_name)
                    if local_player:is_move() then
                        common.auto_move(local_player:cx() + 200,local_player:cy(),local_player:cz())
                    end
                    break
                end
            end
        end
        -- 触发了过图 等待延迟加长
        if wait then decider.sleep(5000) wait = false end
        local cur_scene_name = this.get_cur_scene_map_name()
        -- xxmsg(cur_scene_name)
        if area_name and area_name ~= '' then
            -- xxmsg(cur_scene_name..' area_name:'..area_name)
            -- 如果当前区域等于目标区域
            if cur_scene_name == area_name then
                move_x,move_y,move_z = x,y,z
                trace.output('已达场景【',area_name,'】')
            else
                -- 当前不在场景地图
                if cur_scene_name == '' then
                    -- 是否找到进门就是该场景
                    local area_t = this.get_area_info_by_main_name(map_name,area_name)
                    if not table.is_empty(area_t) then
                        -- 找到进门数据,为第一场景
                        if area_t['进门'] and not table.is_empty(area_t['进门'][map_name]) then
                            trace.output('进门寻路到【',map_name,'】')
                            move_x,move_y,move_z = area_t['进门'][map_name].x,area_t['进门'][map_name].y,area_t['进门'][map_name].z
                        else
                            -- 可能为第二场景,获取当前场景出门数据对应 进门地图
                            for map,_ in pairs(area_t['出门']) do
                                if map then
                                    local area_t1 = this.get_area_info_by_main_name(map_name,map)
                                    if not table.is_empty(area_t1) then
                                        if area_t1['进门'] and not table.is_empty(area_t1['进门'][map_name]) then
                                            trace.output('进门寻路到【',map,'】')
                                            move_x,move_y,move_z = area_t1['进门'][map_name].x,area_t1['进门'][map_name].y,area_t1['进门'][map_name].z
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        if local_player:dist_xy(move_x,move_y) < 300 then
                            vehicle_ent.execute_down_riding()
                        end
                    else
                        trace.output(area_name..' -没有找到坐标资源【目标场景】')
                    end
                else
                    local is_find_move = false
                    -- 获取当前场景的对应  出门 进门信息
                    local area_t = this.get_area_info_by_main_name(map_name,area_name)
                    if not table.is_empty(area_t) then
                        -- 找是否进门
                        if area_t['进门'] and not table.is_empty(area_t['进门'][cur_scene_name]) then
                            trace.output('进门寻路到【',area_name,'】')
                            move_x,move_y,move_z = area_t['进门'][cur_scene_name].x,area_t['进门'][cur_scene_name].y,area_t['进门'][cur_scene_name].z
                            is_find_move = true
                            if local_player:dist_xy(move_x,move_y) < 300 then
                                vehicle_ent.execute_down_riding()
                            end
                        end
                        -- xxmsg(move_x..'/'..move_y..'/'..move_z)
                    else
                        trace.output(area_name..' -没有找到坐标资源【目标场景】')
                    end
                    if not is_find_move  then
                        area_t = this.get_area_info_by_main_name(map_name,cur_scene_name)
                        if not table.is_empty(area_t) then
                            -- 找是否出门
                            if area_t['出门'] and not table.is_empty(area_t['出门'][area_name]) then
                                trace.output('出门寻路到【',area_name,'】')
                                move_x,move_y,move_z = area_t['出门'][area_name].x,area_t['出门'][area_name].y,area_t['出门'][area_name].z
                            elseif area_t['出门'] and not table.is_empty(area_t['出门'][map_name]) then
                                trace.output('出门寻路到【',map_name,'】')
                                move_x,move_y,move_z = area_t['出门'][map_name].x,area_t['出门'][map_name].y,area_t['出门'][map_name].z
                            elseif area_t['出门'] then -- 非目标场景时 选一个门出去

                                for _,v in pairs(area_t['出门']) do
                                    if not table.is_empty(v) then
                                        move_x,move_y,move_z = v.x,v.y,v.z
                                    end
                                end
                            end
                            -- xxmsg(map_name..' '..cur_scene_name..':'..move_x..','..move_y..','..move_z)
                        else
                            trace.output(cur_scene_name..' -没有找到坐标资源【当前场景】')
                        end
                    end
                end
            end
        else
            -- xxmsg('走出当前场景:'..cur_scene_name)
            -- 走出当前场景
            if cur_scene_name ~= '' then
                local area_t = this.get_area_info_by_main_name(map_name,cur_scene_name)
                if not table.is_empty(area_t) then
                    -- 指定坐标非区域
                    -- 找是否出门
                    for map,pos in pairs(area_t['出门']) do
                        if map then
                            trace.output('出门寻路到【',map,'】')
                            move_x,move_y,move_z = pos.x,pos.y,pos.z
                            break
                        end
                    end
                else
                    trace.output(cur_scene_name..' -没有找到坐标资源【当前场景】')
                    -- 传送出去
                    this.execute_transfer_to_map(map_name,1,1)
                end
            else
                trace.output('前往【',map_name,'】点 距：',math.floor(local_player:dist_xy(x,y)))
                move_x,move_y,move_z = x,y,z
                -- xxxmsg(2,move_x..','..move_y..','..move_z)
            end
        end
        local k_dis = 80
        -- 在副本中 提高打怪的范围
        if  actor_unit.is_dungeon_map() then
            k_dis = 200
        end
        if not stop_transfer then
            -- 传送检测
            this.execute_transfer_to_map(map_name,move_x,move_y)
        end
        -- 攻击范围内怪物
        if vehicle_ent.is_riding() or not close_attack and not this.move_to_kill_actor(nil,k_dis) or close_attack then
            -- 检测是否可上马
            if not stop_riding then
                local actor_num = actor_ent.get_actor_num_by_pos(nil,nil,nil,600,2)
                vehicle_ent.auto_riding_vehicle(actor_num,move_x,move_y)
            end
            -- 关闭航海窗口
            if ship_unit.is_open_anchor_frame() then
                common.key_call('KEY_Z')
                decider.sleep(3000)
            end
            -- 路障检测
            this.check_move(move_x,move_y,move_z,stop_riding)
            -- xxmsg('2.'..move_x..','..move_y..','..move_z)
            -- 检测是否移动
            if not common.is_move() then
                if area_name and area_name ~= '' then
                    decider.sleep(2000)
                end
                move_num = move_num + 1
                common.auto_move(move_x,move_y,move_z)
                if move_num > 10 then
                    decider.sleep(1000)
                    common.auto_move(local_player:cx() + 30, local_player:cy() + 30, local_player:cz())
                    move_num = 0
                end
                -- 在副本时检测寻路次数
                if actor_unit.is_dungeon_map() then
                    local key_move       = actor_unit.map_name()..math.floor(move_x)..math.floor(move_y)..math.floor(move_z)
                    local bool_val,count = common.get_interval_change('connected_server',key_move,10)
                    if bool_val == 2 and count > 15 then
                        xxxmsg(3,'副本中寻路异常-使用逃离之歌退出')
                        this.move_go_away()
                        break
                    end
                end
                decider.sleep(1000)
                -- 检测下马
                if vehicle_ent.is_riding() and not common.is_move() then
                    local actor_num = actor_ent.get_actor_num_by_pos(nil,nil,nil,100,2)
                    if actor_num > 1 then
                        vehicle_ent.execute_down_riding()
                    end
                end
            else
                move_num = 0
            end
        else
            w_time = 100
        end
        decider.sleep(w_time)
    end

    if call_key then
        common.key_call(call_key)
        decider.sleep(3000)
        common.wait_over_state()
        common.wait_loading_map()
    end
    return ret
end

-------------------------------------------------------------------------------------
-- [读取] 获取从起点地图到目标地图的路径
map_ent.get_move_map_path_ex = function(startPoint, endPoint,map)
    -- 创建一个空路径,返回
    local path = {}
    map        = map or map_res.map_info
    -- 检查起点和终点是否存在于地图资源中
    if not map[startPoint] or not map[endPoint] then
        return path
    end
    -- 创建一个队列数据结构用于辅助搜索
    local queue   = {}
    -- 创建一个已访问过的节点列表
    local visited = {}
    -- 记录每个节点的父节点
    local parents = {}

    -- 将起点添加到队列中
    table.insert(queue, { point = startPoint, move_pos = nil })

    while #queue > 0 do
        -- 从队列中取出一个节点
        local current = table.remove(queue, 1)

        if not visited[current.point] then
            visited[current.point] = true
            -- xxmsg(current.point..'>'..endPoint)
            -- 检查当前节点是否为终点
            if current.point == endPoint then
                -- 找到了路径，回溯路径并存储在path表中
                table.insert(path, { map_name = endPoint, move_pos = current.move_pos })
                local parent = parents[current.point]
                while parent do
                    local move_pos = map[parent]['可换地图'][current.point]
                    table.insert(path, { map_name = parent, move_pos = move_pos })
                    current.point = parent
                    parent = parents[parent]
                end
                -- 反转路径表，得到正向路径
                local reversedPath = {}
                for i = #path, 1, -1 do
                    table.insert(reversedPath, path[i])
                end
                path = reversedPath
                return path
            end
            -- 获取当前节点的可换地图列表
            local possibleMoves = map[current.point] and map[current.point]['可换地图'] or {}
            -- 遍历可换地图列表
            for nextPoint, move_pos in pairs(possibleMoves) do
                if not visited[nextPoint] then
                    table.insert(queue, {point = nextPoint, move_pos = move_pos})  -- 将下一个节点添加到队列中
                    -- 记录下一节点的父节点为当前节点
                    parents[nextPoint] = current.point
                end
            end
        end
    end
    -- 没有找到路径，返回空路径
    return path
end

-------------------------------------------------------------------------------------
-- [读取] 寻路到指定地图的路径[相同大陆]
map_ent.get_move_map_path_by_map_name = function(map_name)
    -- 为距离目标地图最近开始节点
    local move_path1 = {}
    -- 标记是否已在目标地图
    local is_in_map = false
    -- 当前地图开始寻路路径节点
    local move_path = this.get_move_map_path_ex(actor_unit.map_name(),map_name)
    local curr_map_name = actor_unit.map_name()

    if curr_map_name == map_name then
        is_in_map = true
    end
    -- 赋值 距离目标地图由近到远节点
    for i = #move_path,1,-1 do
        --    xxmsg(move_path[i].map_name..' '..move_path[i].move_pos.x..' '..move_path[i].move_pos.y..' '..move_path[i].move_pos.z)
        table.insert(move_path1,move_path[i])
    end
    return is_in_map,move_path,move_path1
end

-------------------------------------------------------------------------------------
-- [行为] 传送到指定的驻点
map_ent.execute_transfer_to_transfer_name = function(map_name,transfer_name)
    local map_id = map_ent.get_map_id_by_map_name(map_name)
    this.is_active_by_map_id_and_transfer_name(map_id,transfer_name)
end

-------------------------------------------------------------------------------------
-- [行为] 传送到可传传送点[相同大陆]
map_ent.execute_transfer_to_map = function(map_args,x,y)
    if game_unit.game_status() ~= 0x100009 then
        return false
    end
    -- 动画判断
    ui_ent.esc_cinema()
    -- 其他状态不可传送
    if actor_unit.get_local_player_status() > 8 then
        return false
    end
    -- 获取可传送的柱点信息
    local info = this.get_best_transfer_info_by_map_name_and_pos(map_args,x,y)
    if table.is_empty(info) then
        return false
    end
    -- 在指定的地图未激活时退出  特殊情况
    local  map_name = actor_unit.map_name()
    if (map_args == 10211 or map_args == '罗格希尔') and not this.is_active_by_map_id_and_transfer_name(10211,'罗格希尔哨所') then
        return false
    end
    -- 战斗状态时退出
    if local_player:is_battle() then return false end
    -- 范围内怪物数大于0退出
    local actor_num = actor_ent.get_actor_num_by_pos(nil,nil,nil,500,2)
    if actor_num > 0 then
        return false
    end
    if x and y then
        local do_name = map_args..math.floor(x)..math.floor(y)..map_name
        -- 当前不在传送目标
        if filter_tran[do_name] then
            return false
        end

        -- 同一地图 坐标传送 在 90秒内超过2次 则 直接返回
        local count = common.get_handle_count(do_name,90)
        if count >= 2 then
            -- 标记当前不在传送
            filter_tran[do_name] = true
            return false
        end
    end
    if actor_ent.check_dead() == 2 then
        return false
    end
    local kill_dis  = actor_num > 0 and 500 or 100
    if not this.move_to_kill_actor(nil,kill_dis) then
        trace.output('传送到【',info.name,'】')
        -- 关闭对话UI
        ui_ent.exist_npc_talk()
        -- 传送
        --  trace.log_info(string.format('%X',info.res_id))
        map_unit.transfer(info.res_id)
        decider.sleep(1000)
        common.wait_over_state()
        decider.sleep(2000)
        common.wait_loading_map()
        if map_name == map_args and not local_player:is_battle() then
            common.wait_show_str('传送稳定',2)
        end
        return true
    end
    return false
end

-------------------------------------------------------------------------------------
-- [读取] 获取指定地图/地图ID,指定位置最佳传送点
map_ent.get_best_transfer_info_by_map_name_and_pos = function(map_args,x,y)
    -- 未输入 则为当前地图ID
    if not map_args then map_args = actor_unit.map_name() end
    local map_id = type(map_args) == 'number' and map_args
            or type(map_args) == 'string' and this.get_map_id_by_map_name(map_args)
    -- 获取当前传送点是否配置坐标资源
    map_args = type(map_args) ~= 'string' and this.get_map_name_by_map_id(map_args) or map_args
    local t_info_res  = this.get_transfer_res_info_by_map_name(map_args)
    local t_info      = this.get_map_transfer_info_by_map_id(map_id)
    -- 标记是否在相同地图
    local b_map       = actor_unit.map_name() ~= map_args
    -- 保存最近坐标
    local min_dis     = 9999999
    -- 保存最佳的传送点
    local best_t_info = {}
    for _,info in pairs(t_info) do
        -- 当前传送点已激活
        if info.is_active then
            -- 传送点名称
            local name = info.name
            -- xxmsg(name..' '..tostring(table.is_empty(t_info_res)))
            if not table.is_empty(t_info_res) and t_info_res[name] then
                local x_res,y_res = t_info_res[name].x,t_info_res[name].y
                local x1,y1       = x,y
                if x1 == nil or y1 == nil then
                    x1,y1       = 1,1
                end
                local dist = utils.distance(x1,y1,x_res,y_res)
                if dist < min_dis then
                    -- 获取的是距离最近的传送点
                    min_dis          = dist
                    best_t_info      = info
                    best_t_info.pos  = t_info_res[name]
                    best_t_info.dist = dist
                end
            end
        end
    end
    if not table.is_empty(best_t_info) then

        -- 不同的地图 必定传送
        if b_map then
            return best_t_info
        elseif x and x ~= 0 and y and y ~= 0 then
            local can_transfer = false
            -- 传送点与目标点的距离

            local dist1 = utils.distance(best_t_info.pos.x,best_t_info.pos.y,x,y)
            -- 当前点与目标点的距离
            local dist2 = utils.distance(local_player:cx(),local_player:cy(),x,y)
            -- 当前点与传送点的距离
            local dist3 = utils.distance(local_player:cx(),local_player:cy(),best_t_info.pos.x,best_t_info.pos.y)
            -- dist2 < dist1  不传送   当前点与目标点的距离 小于 传送点与目标点的距离
            --当前点与目标点的距离 大于 传送点与目标点的距离
            if dist2 > dist1 * 1.3 then
                can_transfer = true
            end
            --  xxmsg(actor_unit.map_name()..'/'..map_args..' dist1:'..dist1..' '..tostring(can_transfer)..'/'..dist2..'/'..dist3..'>>'..x..','..y)
            if dist2 < 1500 or dist3 < 1500 then
                can_transfer = false
            end
            if can_transfer then
                return best_t_info
            end
        end
    end
    return {}
end

-------------------------------------------------------------------------------------
-- [读取] 获取当前地图最近传送点信息
map_ent.get_nearest_transfer_info = function()
    local info_list     = {}
    local t_info_res    = this.get_transfer_res_info_by_map_name(actor_unit.map_name())
    local transfer_info = this.get_map_transfer_info_by_map_id(actor_unit.map_id())
    for _,v in pairs(transfer_info) do
        local t_info = t_info_res[v.name]
        if t_info then
            local x,y  = t_info.x,t_info.y
            local dist = local_player:dist_xy(x,y)
            v.dist     = dist
            v.x        = x
            v.y        = y
            v.z        = t_info.z
            table.insert(info_list,v)
        end
    end
    if not table.is_empty(info_list) then
        table.sort(info_list,function(a, b) return a.dist < b.dist end)
        return info_list[1].x,info_list[1].y,info_list[1].z
    end
    return 0,0,0
end

-------------------------------------------------------------------------------------
-- [读取] 根据地图ID 获取传送点
map_ent.get_map_transfer_info_by_map_id = function(map_id)
    local transfer_list	= map_unit.get_transfer_list_by_mapid(map_id)
    local transfer_info = {}
    for i = 1, #transfer_list do
        local obj = transfer_list[i]
        if map_ctx:init(obj) then
            local result     = {}
            result.obj       = obj
            result.id        = map_ctx:id()
            result.res_ptr   = map_ctx:res_ptr()
            result.res_id    = map_ctx:res_id()
            result.is_active = map_ctx:is_active()
            result.name      = map_ctx:name()
            table.insert(transfer_info,result)
        end
    end
    return transfer_info
end

-------------------------------------------------------------------------------------
-- [读取] 获取最佳的精炼大陆城市
map_ent.get_best_power_city = function()
    local cur_power_map     = map_res.get_main_city()
    if cur_power_map ~= '' then
        return cur_power_map
    end
    -- 获取当前大陆港口信息
    local cur_map_name      = actor_unit.map_name()
    local info              = map_res.map_info[cur_map_name]
    -- 获取当前地图的进港坐标
    local cur_x,cur_y,cur_z = local_player:cx(),local_player:cy(),local_player:cz()
    local is_in_ship        = string.find(cur_map_name,'大航海')
    -- 非大海上时 获取码头信息
    if not is_in_ship then
        if not table.is_empty(info) and info['码头'] then
            local quay_res = info['码头']['进港']
            if not table.is_empty(quay_res) then
                cur_x,cur_y,cur_z = quay_res.x,quay_res.y,quay_res.z
            end
        end
    end
    -- 保存所有可去城市
    local can_power_list    = {}
    -- 非精炼大陆时 获取可精炼大陆的入港坐标
    for map_name,info in pairs(map_res.map_info) do
        if info and not table.is_empty(info['码头']) then
            local city_name = map_res.get_main_city(map_name)
            if city_name ~= '' then
                local quay_res  = info['码头']['进港']
                if quay_res and not table.is_empty(quay_res) then
                    if quay_res.x and quay_res.x ~= 0 and quay_res.y and quay_res.y ~= 0 then
                        if this.is_active_transfer_by_map_name(city_name) then
                            local dist = utils.distance(cur_x,cur_y,quay_res.x,quay_res.y)
                            table.insert(can_power_list,{ dist = dist,city_name = city_name })
                        end
                    end
                end
            end
        end
    end
    -- 获取最佳码头 并且 当前码头属于可精炼的大陆
    if not table.is_empty(can_power_list) then
        table.sort(can_power_list,function(a, b) return a.dist < b.dist  end)
        return can_power_list[1].city_name
    end
    return '贝隆城'
end

-------------------------------------------------------------------------------------
-- [读取] 获取距离最近的码头位置[在大海时的读取]
-- 返回：地图名称,x,y,z
map_ent.get_nearest_quay_pos = function(x,y)
    local best_info = {}
    local best_dist = math.huge
    x               = x or local_player:cx()
    y               = y or local_player:cy()
    for map_name,info in pairs(map_res.map_info) do
        if info and not table.is_empty(info['码头']) then
            local quay_res = info['码头']['进港']
            if quay_res and not table.is_empty(quay_res) then
                if quay_res.x and quay_res.x ~= 0 and quay_res.y and quay_res.y ~= 0 and not quay_res.call then
                    -- 当前码头已激活传送柱时可维修
                    if this.is_active_transfer_by_map_name(map_name) then
                        -- 计算自身到码头的距离
                        local dist = utils.distance(x,y,quay_res.x,quay_res.y)
                        if dist < best_dist then
                            best_dist = dist
                            quay_res.map_name = map_name
                            best_info = quay_res
                        end
                    end
                end
            end
        end
    end
    if not table.is_empty(best_info) then
        return best_info.map_name,best_info.x,best_info.y,best_info.z,best_info.call
    end
    return '',0,0,0,false
end

-------------------------------------------------------------------------------------
-- [读取] 根据大陆名称寻找对应码头位置
map_ent.get_quay_pos_by_main_name = function(main_name)
    for map_name,info in pairs(map_res.map_info) do
        if info and main_name == info['所属大陆']  then
            local map_id_res = info['码头']
            if map_id_res and not table.is_empty(map_id_res) then
                map_id_res['地图名'] = map_name
                return map_id_res
            end
        end
    end
    return {}
end

-------------------------------------------------------------------------------------
-- [读取] 根据指定地图,指定场景名,获取场景资源数据,存在进门出门信息
map_ent.get_area_info_by_main_name = function(map_name,area_name)
    local info = map_res.map_info[map_name]
    if info then
        local area_t = info['场景区域']
        if area_t and area_t[area_name] then
            return area_t[area_name]
        end
    end
    return {}
end

-------------------------------------------------------------------------------------
-- [读取] 重新封装场景区域
map_ent.get_cur_scene_map_name = function()
    if map_area_res.get_area_name() == '亡者峡谷-右' then
        return '亡者峡谷'
    end
    local info      = map_res.map_info[actor_unit.map_name()]
    local area_name = map_res.get_map_area_name_ex()
    if info and area_name == '' then
        local area_t     = info['场景区域']
        local game_cur_s = actor_unit.get_cur_scene_map_name()
        if area_t and area_t[game_cur_s] then
            -- 检测是否自定义区域
            if map_res.is_get_area_name(game_cur_s) then
                return area_name
            end
            return game_cur_s
        end
    end
    return area_name
end

-------------------------------------------------------------------------------------
-- [读取] 根据地图ID获取地图名称
map_ent.get_map_name_by_map_id = function(map_id)
    for map_name,info in pairs(map_res.map_info) do
        if info then
            local map_id_res = info['地图ID']
            if map_id_res and map_id == map_id_res then
                return map_name
            end
        end
    end
    return ''
end

-------------------------------------------------------------------------------------
-- [读取] 根据地图名称获取地图ID
map_ent.get_map_id_by_map_name = function(map_name)
    local info = map_res.map_info[map_name]
    if info and info['地图ID'] then
        return info['地图ID']
    end
    return 0
end

-------------------------------------------------------------------------------------
-- [读取] 根据地图名称获取传送点资源数据
map_ent.get_transfer_res_info_by_map_name = function(map_name)
    local info = map_res.map_info[map_name]
    if info and info['传送点'] then
        return info['传送点']
    end
    return {}
end

-------------------------------------------------------------------------------------
-- [读取] 根据地图名称获取所属大陆
map_ent.get_main_map_by_map_name = function(map_name)
    local info = map_res.map_info[map_name]
    if info and info['所属大陆'] then
        return info['所属大陆']
    end
    return ''
end

-------------------------------------------------------------------------------------
-- [行为] 当前地图区域寻路检测[只寻路指定坐标所属区域]
map_ent.move_curr_map_by_area_res = function(x,y,z,stop_riding)
    while decider.is_working() do
        -- 死亡检测
        if actor_ent.check_dead() == 2 then
            break
        end
        -- 获取当前坐标对应区域
        local start_pos    = map_area_res.get_area_name()
        -- 未检测到区域时 检测是否在移动的物体上 如果是则移动
        if start_pos == '无区域' then
            this.check_moving_obj()
        end
        -- 获取指定坐标对应区域
        local end_pos      = map_area_res.get_area_name(x,y,z)
        -- 获取地图区域切换信息
        local area_move    = map_area_res.get_map_area_move_by_map_name()
        -- 获取从起点地图到目标地图的路径
        local move_path    = this.get_move_map_path_ex(start_pos,end_pos,area_move)
        -- xxmsg(start_pos..' '..end_pos)
        -- 没有可寻路径退出
        if #move_path == 0 then break end
        -- 寻路完成退出
        if end_pos == start_pos then break end
        ui_ent.esc_cinema()
        -- this.execute_transfer_to_map(nil,x,y)
        for i = 1,#move_path do
            -- 路径完成退出
            if end_pos == start_pos then break end
            --
            local move = move_path[i]
            -- 当前节点在路径所在节点[非终点区域]
            -- xxmsg('当前：'..start_pos..'>'..' '..move.map_name)
            if move.map_name == start_pos then
                local cx        = move.move_pos.x
                local cy        = move.move_pos.y
                local cz        = move.move_pos.z
                local break_h   = move.move_pos.break_h
                local break_m   = move.move_pos.break_m
                local stop_rid  = stop_riding or move.move_pos.stop_riding
                local move_type = map_area_res.get_area_move_type_by_area_name(start_pos)
                local dist      = local_player:dist_xy(cx,cy)
                -- xxmsg('当前：'..start_pos..'>'..' '..move.map_name..' cx:'..cx..' cy:'..cy)
                item_ent.auto_use_hp_ex()
                -- 如果区域与目标区域相等则退出
                if dist > 30 then
                    trace.output('当前：'..start_pos..'>',end_pos)
                    if not this.move_to_kill_actor(nil,100) then
                        -- 获取自身600范围内的怪物数
                        local actor_num = actor_ent.get_actor_num_by_pos(nil,nil,nil,600,2)
                        local key = '检测异常'..start_pos..end_pos..math.floor(cx)..math.floor(cy)..math.floor(cz)
                        if move_type == '普通' or not move_type then
                            if not common.is_move() then
                                common.auto_move(cx,cy,cz)
                                decider.sleep(1000)
                            end
                            -- 检测是否上马
                            if not stop_rid then
                                vehicle_ent.auto_riding_vehicle(actor_num,cx,cy)
                            end
                        elseif move_type == '升降' then
                            -- 检测下马
                            vehicle_ent.execute_down_riding()
                            local calc_z = math.abs(local_player:cz() - cz)
                            -- xxmsg('calc_z:'..calc_z)
                            if calc_z > ( break_h or 35 ) then
                                -- 检测与当前高度 相近的移动点【超时时使用】
                                local bool_val,count = common.get_interval_change(key,calc_z,5)
                                trace.output('升降中,高度【'..math.floor(calc_z)..'】('..count..')')
                                if bool_val == 2 and count > 6 then
                                   local mx,my,mz = map_area_res.get_change_info_by_area_name(start_pos)
                                    if mx ~= 0 and my ~= 0 then
                                        this.move_curr_map_to_ex(nil,mx,my,mz)
                                        common.get_interval_change(key,true)
                                        break
                                    end
                                end
                            else
                                this.move_curr_map_to_ex(nil,cx,cy,cz)
                            end
                        elseif move_type == '移动' then
                            if dist > ( break_m or 500 ) then
                                local bool_val,count = common.get_interval_change(key,dist,10)
                                trace.output('移动中,距离【'..math.floor(local_player:dist_xy(cx,cy))..'】('..count..')')
                                -- 检测与当前高度 相近的移动点【超时时使用】
                                if bool_val == 2 and count > 12 then
                                    local mx,my,mz = map_area_res.get_change_info_by_area_name(start_pos)
                                    if mx ~= 0 and my ~= 0 then
                                        this.move_curr_map_to_ex(nil,mx,my,mz)
                                        common.get_interval_change(key,true)
                                        break
                                    end
                                end
                            else
                                this.move_curr_map_to_ex(nil,cx,cy,cz)
                            end
                        end
                    end
                else
                    local operate = move.move_pos['操作']
                    if not table.is_empty(operate) then
                        --  读取范围
                        local r       = operate.r or 700
                        -- 读取对象类型
                        local r_type  = operate.type
                        -- 读取对象资源ID
                        local res_id  = operate.res_id
                        -- 读取名字
                        local name    = operate.name
                        -- 移动的方式
                        local action  = operate.action
                        name = res_id ~= 0 and res_id or name

                        if name and name ~= '' then
                            -- 读取是否存在指定的目标
                            local actor_info = actor_ent.get_nearest_actor_info_by_rad_pos(name,cx,cy,r,r_type)
                            if not table.is_empty(actor_info) then
                                while decider.is_working() do
                                    local now_pos = map_area_res.get_area_name()
                                    if start_pos ~= now_pos and now_pos ~= '无区域' then
                                        break
                                    end
                                    if actor_ent.check_dead() == 2 then
                                        return false
                                    end
                                    -- 下马方便比较高度
                                    vehicle_ent.execute_down_riding()
                                    item_ent.auto_use_hp_ex()
                                    actor_info = actor_ent.get_nearest_actor_info_by_rad_pos(name,cx,cy,r,r_type)
                                    if not table.is_empty(actor_info) then
                                        local move_x = actor_info.cx
                                        local move_y = actor_info.cy
                                        local move_z = actor_info.cz
                                        local dist_d = local_player:dist_xy(move_x,move_y)
                                        -- 当前区域等于目标区域 停止
                                        if now_pos == end_pos and dist_d < 60 then
                                            break
                                        end
                                        if dist_d > 50 then
                                            if not this.move_to_kill_actor(nil,100) then
                                                local calc_z = math.abs(local_player:cz() - move_z)
                                                local m_name = actor_info.name ~= '' and actor_info.name or '移动物'
                                                if calc_z <= ( break_h or 35 ) then
                                                    trace.output('移动到【'..m_name..'】上')
                                                    if action == 4 then
                                                        common.mouse_move(move_x,move_y,move_z)
                                                    else
                                                        common.auto_move(move_x,move_y,move_z,nil,nil,action)
                                                    end
                                                else
                                                    trace.output('等待【'..m_name..'】靠近:'..math.floor(calc_z))
                                                    if move_type == '普通' or not move_type then
                                                        if local_player:dist_xy(cx,cy) > 50 then
                                                            if not common.is_move() then
                                                                common.auto_move(cx,cy,cz)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        else
                                            break
                                        end
                                    else
                                        trace.output('暂未发现'..move_type..'工具')
                                    end
                                    decider.sleep(100)
                                end
                            end
                        end
                    end
                    local key_str = move.move_pos.key_call
                    if type(key_str) == 'string' then
                        common.key_call('KEY_G')
                    end
                    local wait_time = move.move_pos.wait_time or 2
                    common.wait_show_str('等待',wait_time)
                end
                break
            end
        end
        decider.sleep(1000)
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------以下为 寻路障碍检测-----------------------------------------------------------------------------------------------------------------
map_ent.check_move = function(x,y,z,stop_riding)
    while decider.is_working() do
        -- 获取当前地图
        local map_name    = actor_unit.map_name()
        -- 特殊处理的地图
        local special_map = this.special_map(x,y)
        if special_map == 0 then
            -- 区域的检测
            this.move_curr_map_by_area_res(x,y,z,stop_riding)
        end
        -- 死亡检测
        if actor_ent.check_dead() == 2 then
            break
        end
        if map_name == '荣耀之墙' then
            local cur_z = local_player:cz()
            -- 检测当前坐标所在范围 -14931.0, -6984.0
            if utils.is_inside_quire(local_player:cx(), local_player:cy(), -14931, -6984.0, 300) then
                if cur_z < 430 and cur_z >= 400 then
                    -- 检测传送对象
                    local actor_info = actor_ent.get_nearest_actor_info_by_rad_pos(0x13C38,-14931.0, -6984.0,100,8)
                    if not table.is_empty(actor_info) then
                        if actor_info.dist > 200 then
                            trace.output('移动到光标位置.')
                            common.auto_move(actor_info.cx,actor_info.cy,actor_info.cz)
                            decider.sleep(1000)
                        else
                            trace.output('点击光标爬升.')
                            actor_unit.transfer_talk(actor_info.obj)
                            decider.sleep(1000)
                        end
                    end
                elseif cur_z >= 900 then
                    -- 在楼上  点击鼠标右键盘 ['荣耀之墙'] = { x = -15397.0, y = -6571.0, z = 913 },--false
                    common.mouse_move(-15397.0,-6571.720703125, 913)
                    decider.sleep(2000)
                else
                    trace.output('正在爬升中[',math.floor(900 - cur_z),']')
                end
            else
                break
            end
        elseif map_name == '卢特兰王座' and actor_unit.is_dungeon_map() then
            if utils.is_inside_quire(x,y, 16673, -9, 1000) and not utils.is_inside_quire(local_player:cx(), local_player:cy(), 16673, -9, 2240) then
                -- 检测传送对象
                local actor_info = actor_ent.get_nearest_actor_info_by_rad_pos('传送',13993, -14,300,6)
                if not table.is_empty(actor_info) then
                    if actor_info.type_seven_status == 0 then
                        break
                    end
                    if actor_info.dist > 100 then
                        trace.output('移动到传送位置.')
                        if not common.is_move() then
                            common.auto_move(actor_info.cx,actor_info.cy,actor_info.cz)
                            decider.sleep(1000)
                        end
                    else
                        trace.output('点击传送.') -- 类型6
                        actor_unit.gather_talk(actor_info.obj)
                        decider.sleep(1000)
                    end
                else
                    trace.output('没有找到传送对象')
                end
            else
                break
            end
        elseif map_name == '科罗克尼斯海岸' then
            -- 目标坐标在此范围
            if utils.is_inside_quire(x,y, 17634, 54389, 5165)  then
                local cur_z = local_player:cz()

                local mov_z = false
                if not utils.is_inside_quire(local_player:cx(), local_player:cy(), 17634, 54389, 5165) then
                    mov_z = true
                elseif cur_z < 900 then
                    mov_z = true
                else
                    break
                end
                if mov_z then
                    this.execute_transfer_to_map('哭泣风暴',17634, 54389)
                    if local_player:dist_xy(12514,52675) > 300 then
                        if not common.is_move() then
                            common.auto_move(12514,52675,511)
                        end
                    else
                        -- 检测传送对象
                        local actor_info = actor_ent.get_nearest_actor_info_by_rad_pos(0x144D0,12514,52675,500,8)
                        if not table.is_empty(actor_info) then
                            if actor_info.type_seven_status == 0 then
                                break
                            end
                            if actor_info.dist > 100 then
                                trace.output('移动到传送位置.')
                                if not common.is_move() then
                                    common.auto_move(actor_info.cx,actor_info.cy,actor_info.cz)
                                    decider.sleep(1000)
                                end
                            else
                                trace.output('点击传送.') -- 类型6
                                actor_unit.transfer_talk(actor_info.obj)
                                common.wait_show_str('爬升等待',6)
                            end
                        else
                            trace.output('没有找到传送对象')
                        end
                    end
                end
            else
                break
            end
        elseif map_name == '鬃波港' then
            if not utils.is_inside_quire(local_player:cx(), local_player:cy(), 5019, 6611, 150)  then
                break
            end
            if utils.is_inside_quire(x, y, 5019, 6611, 150)  then
                break
            end
            if not common.is_move() then
                common.auto_move(4670,6554,255)
                decider.sleep(2000)
            end
        elseif map_name == '咒灵洞穴' then
            local cur_z = local_player:cz()
            -- 自身在当前区域时
            if not utils.is_inside_quire(local_player:cx(), local_player:cy(), -3221, 3003, 400) then
                break
            end
            if cur_z > 760 then
                break
            end
            -- 目标点在此范围内时跳出
            if utils.is_inside_quire(x, y, -3221, 3003, 400) and z <= 760 then
                break
            end
            if not common.is_move() then
                if common.auto_move_ex( -3308,2871,755) then
                    common.key_call('KEY_G')
                    decider.sleep(3000)
                end
            end
        else
            if special_map == 0 then
                break
            end
        end
        decider.sleep(1000)
    end
end

------------------------------------------------------------------------------------
-- [行为] 移动到传送[死亡后出现的点]
map_ent.move_transfer_dead = function(x,y,r,func)
    local ret = false
    while decider.is_working() do
        -- 需要原地复活的地图时不检测
        if actor_res.need_stay_rise() then
            break
        end
        -- 检测传送对象
        local actor_info,all_list = actor_ent.get_nearest_actor_info_by_rad_pos({ '传送','朝着里面','朝着对面','朝着上面' },x,y,r,6)
        if table.is_empty(all_list) then
            actor_info,all_list = actor_ent.get_nearest_actor_info_by_rad_pos(0xA52A,x,y,r,6)
        end
        if not table.is_empty(all_list) then
            for _,v in pairs(all_list) do
                if v.type_seven_status == 1 then
                    actor_info = v
                    break
                end
            end
        end
        if table.is_empty(actor_info) then
            break
        end
        -- 比较高度
        local cacl_z = math.abs(local_player:cz() - actor_info.cz)
        if cacl_z > 200 then
            break
        end
        -- 类型7是否为1
        if actor_info.type_seven_status == 0 then
            break
        end
        if type(func) == 'function' then
            if not func() then
                break
            end
        end
        ret = true
        if actor_info.dist > 100 then
            trace.output('移动到传送位置.')
            if not common.is_move() then
                common.auto_move(actor_info.cx,actor_info.cy,actor_info.cz)
            end
        else
            trace.output('点击传送.') -- 类型6
            if common.is_sleep_any('点击传送',10) then
                actor_unit.gather_talk(actor_info.obj)
            end
            common.key_call('KEY_G')
            decider.sleep(2000)
        end
        decider.sleep(1000)
    end
    return ret
end

------------------------------------------------------------------------------------
-- [行为] 移动到升降机 执行上升
map_ent.move_to_lifter_go_up = function(res_id,r_type,wait_to_x,wait_to_y,wait_to_z,move_to_x,move_to_y,move_to_z,move_cz)
    this.move_to_lifter(res_id,r_type,wait_to_x,wait_to_y,wait_to_z,move_to_x,move_to_y,move_to_z,move_cz,'升')
end

------------------------------------------------------------------------------------
-- [行为] 移动到升降机 执行下降
map_ent.move_to_lifter_go_down = function(res_id,r_type,wait_to_x,wait_to_y,wait_to_z,move_to_x,move_to_y,move_to_z,move_cz)
    this.move_to_lifter(res_id,r_type,wait_to_x,wait_to_y,wait_to_z,move_to_x,move_to_y,move_to_z,move_cz,'降')
end

------------------------------------------------------------------------------------
-- [行为] 移动到升降机
map_ent.move_to_lifter = function(res_id,r_type,wait_to_x,wait_to_y,wait_to_z,move_to_x,move_to_y,move_to_z,move_cz,up_and_down)
    if not res_id then return end
    while decider.is_working() do
        local cur_z = local_player:cz()

        local actor_info = actor_ent.get_nearest_actor_info_by_rad_pos(res_id,wait_to_x,wait_to_y,500,r_type)
        if not table.is_empty(actor_info) then
            -- local dist = local_player:dist_xy(wait_to_x,wait_to_y)
            if actor_info.dist >= 500 then
                if actor_info.dist > 1000 then
                    vehicle_ent.auto_riding_vehicle()
                end
                if not common.is_move() then
                    common.auto_move(wait_to_x,wait_to_y,wait_to_z)
                end
            else
                vehicle_ent.execute_down_riding()
                item_ent.auto_use_hp_ex()
                local cac_zz = math.abs(cur_z - actor_info.cz )
                if cac_zz <= 30 then
                    if actor_info.dist > 100 then
                        trace.output('移到升降机['..( math.floor(cur_z) )..']')
                        common.mouse_move(actor_info.cx,actor_info.cy,actor_info.cz)
                    else
                        local str = '上升'
                        if up_and_down == '降' then
                            str = '下降'
                            if actor_info.cz <= move_cz then
                                this.move_curr_map_to_ex(nil,move_to_x,move_to_y,move_to_z)
                                break
                            end
                        else
                            if actor_info.cz >= move_cz then
                                this.move_curr_map_to_ex(nil,move_to_x,move_to_y,move_to_z)
                                break
                            end
                        end

                        trace.output('升降机'..str..'['..( math.floor(cur_z) )..']')
                    end
                else
                    trace.output('等待升降机['..(math.floor(math.abs(cur_z - actor_info.cz)))..']')
                end
            end
        else
            if not common.is_move() and local_player:dist_xy(wait_to_x,wait_to_y) >= 50 then
                common.auto_move(wait_to_x,wait_to_y,wait_to_z)
            end
        end
        decider.sleep(1000)
    end
end

------------------------------------------------------------------------------------
-- [读取] 移出升降机
map_ent.move_in_lifter_to = function(res_id,wait_to_x,wait_to_y,r_type,in_dist,move_to_x,move_to_y,move_to_z)
    in_dist = in_dist or 200
    local actor_info = actor_ent.get_nearest_actor_info_by_rad_pos(res_id,wait_to_x,wait_to_y,500,r_type)
    if not table.is_empty(actor_info) then
        local cur_z  = local_player:cz()
        local cac_zz = math.abs(cur_z - actor_info.cz )
        if actor_info.dist < in_dist then
            return true
        end
    end
    return false
end

------------------------------------------------------------------------------------
-- 检测自身范围内是否存在升降机【移动到升降机-无法读取到区域时使用】
map_ent.check_moving_obj = function()
    local list = map_area_res.get_curr_area_lifter_list()
    for _,v in pairs(list) do
        -- xxmsg(v.res_id..' '..v.type..' '..v.action..' '..v.area_name)
        -- 获取指定对象信息
        local actor_info = actor_ent.get_nearest_actor_info_by_rad_pos(v.res_id,local_player:cx(),local_player:cy(),600,v.type)
        if not table.is_empty(actor_info) then
            -- 移动到目标身上
            while decider.is_working() do
                vehicle_ent.execute_down_riding()
                item_ent.auto_use_hp_ex()
                local cur_z = local_player:cz()
                actor_info   = actor_ent.get_nearest_actor_info_by_rad_pos(v.res_id,local_player:cx(),local_player:cy(),600,v.type)
                local cac_zz = math.abs(cur_z - actor_info.cz )
                if cac_zz <= 30 then
                    if actor_info.dist > 100 then
                        trace.output('移到：'..actor_info.name..'['..( math.floor(cur_z) )..']')
                        common.mouse_move(actor_info.cx,actor_info.cy,actor_info.cz)
                    else
                        break
                    end
                else
                    trace.output('等待：'..actor_info.name..'['..(math.floor(math.abs(cur_z - actor_info.cz)))..']')
                end
                decider.sleep(100)
            end
            break
        end
    end
end

------------------------------------------------------------------------------------
-- 特殊地图
function map_ent.special_map(x,y,z)
    -- 获取当前地图
    local map_name = actor_unit.map_name()
    -- 大岩林 特殊区域1
    local polygon = {
        { x = 18691.0 + 100, y = 12444.0 - 100 },
        { x = 19012.0 + 100, y = 12474.0 - 100 },
        { x = 20630.0 + 500, y = 12508.0 - 500 },
        { x = 21397.0 + 200, y = 14118.0 - 200 },
        { x = 21430.0 + 200, y = 14851.0 + 200 },
        { x = 20948.0 + 200, y = 15660.0 + 200 },
        { x = 19298.0 - 200, y = 15921.0 + 200 },
        { x = 18664.0 - 100, y = 15373.0 + 100 },
        { x = 17806.0 - 200, y = 14917.0 },
        { x = 17590.0, y = 14690.0 },
        { x = 17590.0, y = 14413.0 },
        { x = 17612.0 - 50, y = 13520.553710938 - 50 },
        { x = 17622.0 - 10, y = 13283.0 - 10 },
        { x = 17857.54296875, y = 13310.780273438 - 150 },
    }
    -- 大岩林 特殊区域2
    local polygon1 = {
        { x = 26122.0 , y = 19228.0 - 500},
        { x = 26149.44921875, y = 19460.388671875 + 500 },
        { x = 25631.0 - 20, y = 19561.0 },
        { x = 25632.0 - 10, y = 19517.0 },
        { x = 25634.107421875, y = 19370.958984375 },
        { x = 25635.0, y = 19296.0 },
        { x = 25636.0, y = 19241.0 },
    }
    -- 托托克体内
    local polygon3 = {
        { x = 20303.0 + 100, y = 17427.0 - 100 },
        { x = 20541.0 + 100, y = 17851.0},
        { x = 20198.0 - 500, y = 18013.0 + 500 },
        { x = 20047.0 - 100, y = 17584.0 - 100 },
    }
    -- 紫藤之丘
    local polygon5 = {
        { x = 13021.879882812, y = 12392.438476562 },
        { x = 12686.491210938, y = 12680.885742188 },
        { x = 12547.797851562 + 200, y = 13282.803710938 },
        { x = 12442.0 - 10, y = 13388.0 + 10 },
        { x = 12311.0 - 10, y = 13250.0 + 10 },
        { x = 12258.0 - 10, y = 13010.0 + 10 },
        { x = 12306.0 - 10, y = 12806.0 - 10 },
        { x = 12557.0 - 10, y = 12524.0 - 10 },
        { x = 12894.0, y = 12205.0 - 20 },--false 无区域
    }
    -- 赤红沙漠
    local polygon6 = {
        { x = 16290, y = 8114 },
        { x = 15950, y = 9302 },
        { x = 13126, y = 9903 },
        { x = 13393, y = 8309 },
        { x = 12884, y = 7751 },
        { x = 13062, y = 7207 },
        { x = 13898, y = 7096 },
        { x = 15035, y = 7218 },
        { x = 15605, y = 6992 },
        { x = 16220, y = 7907 },
    }
    local stop = 0
    -- 其他特殊地图检测寻路
    if map_name == '赤红沙漠' then
        -- 获取当前坐标对应区域
        local start_pos    = map_area_res.get_area_name()
        -- 如果当前区域属于中区
        if start_pos == '赤红沙漠中' then
            -- 获取指定坐标对应区域
            local end_pos  = map_area_res.get_area_name(x,y,z)
            local m_x,m_y,m_z,m_time  = 0,0,0,0
            if end_pos == '赤红沙漠下' then
                trace.output('移动赤红沙漠下')
                m_x,m_y,m_z = 7977,9351,-548
                m_time      = 10
            elseif end_pos == '赤红沙漠左' then
                trace.output('移动赤红沙漠左')
                m_x,m_y,m_z = 11167,8018,-501
                m_time      = 5
            elseif end_pos == '赤红沙漠右' then
                trace.output('移动赤红沙漠右')
                m_x,m_y,m_z = 6746,12471,-506
                m_time      = 5
            elseif end_pos == '赤红沙漠上' then
                if utils.is_point_in_polygon(x,y, polygon6) then
                    trace.output('移动赤红沙漠左')
                    m_x,m_y,m_z = 11167,8018,-501
                    m_time      = 5
                else
                    trace.output('移动赤红沙漠右')
                    m_x,m_y,m_z = 6746,12471,-506
                    m_time      = 5
                end
            end
            if m_x ~= 0 then
                stop = 5
                if common.auto_move_ex(m_x,m_y,m_z) then
                    common.key_call('KEY_G')
                    common.wait_show_str('切换',m_time or 1)
                end
            end
        end
    end
    if map_name == '托托克体内' then
        local is_in = function()
            return utils.is_point_in_polygon(local_player:cx(), local_player:cy(), polygon3)
        end
        if is_in() then
            -- 移动到传送点
            this.move_transfer_dead(20541,17851,300,is_in)
        end
    end
    if map_name == '大岩林' then
        if utils.is_point_in_polygon(x,y, polygon) then
            if not utils.is_point_in_polygon(local_player:cx(), local_player:cy(), polygon) and map_area_res.get_area_name() == '大岩林-北中' then
                stop = 1
                -- 使用升降机上升
                this.move_to_lifter_go_up(0x10CE59,15,17146.6, 14555.0,2558,17863,14559,3585,3550)
            end
        end
        if utils.is_point_in_polygon(local_player:cx(), local_player:cy(), polygon) then
            if not utils.is_point_in_polygon(x,y, polygon) then
                stop = 2
                -- 使用升降机下降
                this.move_to_lifter_go_down(0x10CE59,15,17691.6, 14537.0,3585,16988,14559,2559,2570)
            end
        end
        if utils.is_point_in_polygon(x,y, polygon1) then
            if not utils.is_point_in_polygon(local_player:cx(), local_player:cy(), polygon1) and map_area_res.get_area_name() == '大岩林-北中' then
                stop = 3
                if local_player:dist_xy(25424,19318) >= 100 then
                    local actor_num = actor_ent.get_actor_num_by_pos(nil,nil,nil,600,2)
                    vehicle_ent.auto_riding_vehicle(actor_num)
                    if not this.move_to_kill_actor(nil,200) then
                        if not common.is_move() then
                            common.auto_move(25424,19318,2559)
                        end
                    end
                else
                    common.key_call('KEY_G')
                    common.wait_show_str('等待爬升',6)
                end
            end
       end
        if utils.is_point_in_polygon(local_player:cx(), local_player:cy(), polygon1) then
            if not utils.is_point_in_polygon(x,y, polygon1) then
                stop = 4
                if local_player:dist_xy(25664,19495) >= 100 then
                    if not common.is_move() then
                        common.auto_move(25664,19495,3088)
                    end
                else
                    common.key_call('KEY_G')
                    common.wait_show_str('等待下去',2)
                end
            end
        end
    end
    if map_name == '紫藤之丘' then
        -- 在场景区域
        if utils.is_inside_quire(local_player:cx(), local_player:cy(), -4644.0, 11048, 500) then
            -- 目标不在当前区域
            if not utils.is_inside_quire(x, y, -4644.0, 11048, 500) then
                stop = 5
                trace.output('移动到出门口')
                common.auto_move_ex(-5199.4,11147,1758)
            end
        end
        -- 在门口区域
        if utils.is_point_in_polygon(local_player:cx(), local_player:cy(), polygon5) then
            if utils.is_inside_quire(x, y, -4644.0, 11048, 500) then
                stop = 5
                trace.output('移动到进门口')
                common.auto_move_ex(12640,13104,1130)
            else
                if not utils.is_point_in_polygon(x, y, polygon5) then
                    stop = 5
                    local actor_num = actor_ent.get_actor_num_by_pos(nil,nil,nil,600,2)
                    vehicle_ent.auto_riding_vehicle(actor_num,12398,12861)
                    if not this.move_to_kill_actor(nil,100) then
                        if common.auto_move_ex(12398,12861,1152) then
                            common.key_call('KEY_G')
                            decider.sleep(2000)
                        else
                            trace.output('移动到跳跃点-下')
                        end
                    end
                end
            end
        end

        if stop == 0 and ( utils.is_inside_quire(x, y, -4644.0, 11048, 500) and not utils.is_inside_quire(local_player:cx(), local_player:cy(), -4644.0, 11048, 500)
                or utils.is_point_in_polygon(x, y, polygon5) and not utils.is_point_in_polygon(local_player:cx(), local_player:cy(), polygon5) ) then
            stop = 5
            if common.auto_move_ex(11944,12952,895) then
                common.key_call(71)
                decider.sleep(2000)
            else
                trace.output('移动到跳跃点-上')
                vehicle_ent.auto_riding_vehicle(nil,11944,12952)
            end
        end
    end
    -- map_area_res.get_area_name(x,y,z)
    --if map_name == '卡拉贾村' then
    --    if map_area_res.get_area_name(x,y,z) ~= '无区域' and map_area_res.get_area_name(local_player:cx(),local_player:cy(),local_player:cz()) == '无区域' then
    --        -- 寻路到进门点['卡拉贾村'] = { x = -555.63916015625, y = 5058.3061523438, z = 84 },--true
    --        common.auto_move_ex(-555,5058,84)
    --        stop = 6
    --    end
    --end
    return stop
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function map_ent.__tostring()
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
function map_ent.__newindex(t, k, v)
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
map_ent.__index = map_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function map_ent:new(args)
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
    return setmetatable(new, map_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return map_ent:new()

-------------------------------------------------------------------------------------
