------------------------------------------------------------------------------------
-- game/entities/dungeon_ent.lua
--
-- 实体示例
--
-- @module      dungeon_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local dungeon_ent = import('game/entities/dungeon_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class dungeon_ent
local dungeon_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME = 'dungeon_ent module',
    -- 只读模式
    READ_ONLY = false,
}

-- 实例对象
local this              = dungeon_ent
local trace             = trace
local common            = common
local import            = import
local actor_unit        = actor_unit
local local_player      = local_player
local item_unit         = item_unit
local dungeon_unit      = dungeon_unit
local ui_unit           = ui_unit
local main_ctx          = main_ctx
local decider           = decider
local dungeon_ctx       = dungeon_ctx
local daily_unit        = daily_unit
local table             = table
local os                = os
local hook_unit         = hook_unit
local math              = math
local setmetatable      = setmetatable
local utils             = import('base/utils')
---@type item_ent
local item_ent          = import('game/entities/item_ent')
---@type skill_ent
local skill_ent         = import('game/entities/skill_ent')
---@type daily_quest_ent
local daily_quest_ent   = import('game/entities/daily_quest_ent')
---@type actor_ent
local actor_ent         = import('game/entities/actor_ent')
---@type ui_ent
local ui_ent            = import('game/entities/ui_ent')
---@type loop_ent
local loop_ent          = import('game/entities/loop_ent')
---@type map_ent
local map_ent           = import('game/entities/map_ent')
---@type user_set_ent
local user_set_ent      = import('game/entities/user_set_ent')
---@type equip_ent
local equip_ent         = import('game/entities/equip_ent')
---@type quest_ent
local quest_ent         = import('game/entities/quest_ent')
---@type dungeon_res
local dungeon_res       = import('game/resources/dungeon_res')
---@type map_res
local map_res           = import('game/resources/map_res')
-- 周常任务列表
local daily_quest_list  = dungeon_res.DAILY_QUEST_LIST
------------------------------------------------------------------------------------
-- [行为] 开始混沌地牢
------------------------------------------------------------------------------------
function dungeon_ent.start_chaos_dungeons()
    while decider.is_working() do
        -- 死亡检测
        actor_ent.check_dead()
        -- 过图检测
        common.wait_loading_map()
        -- 检测UI相关
        ui_ent.esc_cinema()
        -- 获取当前地图名称
        local map_name = actor_unit.map_name()
        -- 判断是否在地牢
        if map_name == '混沌地牢' then
            this.fight_chaos_dungeons()
        else
            -- 判断是否可执行地牢
            if not this.can_in_chaos_dungeons() then
                return true
            end
            -- 离开 特里希温
            map_ent.move_go_away_tlsw()
            if not actor_unit.is_dungeon_map() or map_res.is_in_islet() or map_res.is_in_ocean() then
                local main_city = map_ent.get_best_power_city()
                if main_city ~= '' and map_ent.is_active_transfer_by_map_name(main_city) then
                    map_ent.move_to_map(main_city)
                end
            end
            -- 轮循可执行功能
            loop_ent.looping()
            -- 判断是否能打混沌地牢
            if map_name ~= '混沌地牢' and ( daily_quest_ent.finish_daily_quest(daily_quest_list, 1) or common.is_sleep_any('检测打开玩法目录',3600) ) then
                -- 提交任务后打开一下UI 刷新数据
                daily_quest_ent.open_daily_quest_wnd()
            end
            -- 完成任务
            quest_ent.finish_task()
            -- 打开一下UI
            daily_quest_ent.open_daily_quest_wnd()
            local daily_quest_is_acc = daily_quest_ent.daily_quest_is_acc(daily_quest_list, 1)
            -- 检测接取周常任务
            if not daily_quest_is_acc then
                daily_quest_ent.acc_daily_quest(daily_quest_list, 1)
                decider.sleep(1000)
            end
            -- 进入混沌地牢
            trace.output('进入混沌地牢')
            this.enter_chaos_dungeons()
        end
        decider.sleep(3000)
    end
end

------------------------------------------------------------------------------------
-- [行为] 混沌副本内战斗
------------------------------------------------------------------------------------
function dungeon_ent.fight_chaos_dungeons()
    hook_unit.enable_mouse_screen_pos(true)
    while decider.is_working() do
        common.wait_loading_map()
        ui_ent.esc_cinema()
        local rise_type,last_posX,last_posY,last_posZ = actor_ent.check_dead()
        -- 是否退出混沌地牢
        this.exit_dungeon()
        -- 不在地牢退出
        if actor_unit.map_name() ~= '混沌地牢' then
            break
        end
        -- 药品回血
        item_ent.auto_use_hp_ex()
        -- 检测是否存在金块
        local actor_list = actor_ent.get_actor_list_by_list_any({ '预备精炼材料箱子','金块' }, 'name', 4)
        if not table.is_empty(actor_list) then
            for _,v in pairs(actor_list) do
                if v.dist > 100 then
                    if not local_player:is_move() then
                        common.auto_move(v.cx, v.cy, v.cz)
                    end
                else
                    trace.output('拾取：'..v.name)
                    common.key_call('KEY_G')
                end
            end
        else
            local actor_info = actor_ent.get_actor_info_by_name('混沌裂痕', 6)
            -- 如果存在   混沌裂痕 进入混沌裂痕
            if not table.is_empty(actor_info) and ( #actor_unit.list(4) == 0 or dungeon_unit.get_dungeon_remaining_time() < 210 ) then
                -- 移动到 混沌裂痕 范围100 处进入
                if actor_info.dist > 100 then
                    if not local_player:is_move() then
                        common.auto_move(actor_info.cx, actor_info.cy, actor_info.cz)
                    end
                else
                    decider.sleep(1000)
                    --actor_unit.gather_talk(actor_info.obj)
                    common.key_call('KEY_G')
                    common.wait_show_str('切换下一阶段',3)
                end
            else
                -- 判断是否存在 龟裂之核
                local monster_info = actor_ent.get_actor_info_by_name('龟裂之核', 7)
                if table.is_empty(monster_info) then
                    monster_info = actor_ent.get_max_hp_actor_info_list_by_rad_pos(nil,nil,nil,5000,2)
                    if not table.is_empty(monster_info) then
                        monster_info = monster_info[1]
                    end
                else
                    common.set_key_table('kill_龟裂之核',os.time())
                end
                if not table.is_empty(monster_info) then
                    -- 怪物距离过远就靠近
                    if monster_info.dist > 500 then
                        if not local_player:is_move() then
                            common.auto_move(monster_info.cx, monster_info.cy, monster_info.cz)
                        end
                    else
                        trace.output('[混沌]杀：',monster_info.name,' HP：',monster_info.max_hp > 0 and math.floor(monster_info.hp * 100/monster_info.max_hp) or 100,'%')
                        local is_unique = monster_info.max_hp/local_player:max_hp() > 4
                        skill_ent.auto_skill(monster_info.cx, monster_info.cy, monster_info.cz,item_ent.auto_use_hp_ex,nil,is_unique)
                    end
                else
                    if os.time() - ( common.get_key_table('kill_龟裂之核',os.time()) or 0 ) > 10 then
                        -- 检测装备
                        equip_ent.ues_equip()
                        -- 检测分解
                        item_ent.decompose_equip(true)
                    end
                    local m_cx,m_cy,m_cz = local_player:cx() + 150, local_player:cy(), local_player:cz()
                    if not table.is_empty(actor_info) then
                        m_cx,m_cy,m_cz = actor_info.cx, actor_info.cy, actor_info.cz
                    elseif last_posX ~= 0 then
                        m_cx,m_cy,m_cz = last_posX,last_posY,last_posZ
                    end
                    if not local_player:is_move() then
                        if local_player:dist_xy( m_cx,m_cy ) > 100 then
                            common.auto_move(m_cx,m_cy,m_cz)
                        end
                    end
                end
            end
        end
        decider.sleep(100)
    end
    hook_unit.enable_mouse_screen_pos(false)
end

------------------------------------------------------------------------------------
-- [行为] 打开混沌窗口
------------------------------------------------------------------------------------
function dungeon_ent.open_chaos_dungeons_wnd()
    local ret = false
    local num = 1
    while decider.is_working() do
        -- 判断混沌窗口是否打开
        if dungeon_unit.get_dungeon_wnd() > 0 then
            ret = true
            break
        end
        if actor_unit.map_name() == '混沌地牢' then
            break
        end
        common.wait_loading_map()
        ui_ent.esc_cinema()
        local kill_dist = local_player:is_battle() and 800 or 200
        if not map_ent.move_to_kill_actor(nil,kill_dist) then
            trace.output('打开混沌窗口[' .. num .. ']')
            -- 判断玩法目录是否打开
            if not ui_unit.is_open_play_dir_wnd() and dungeon_unit.get_dungeon_wnd() == 0 then
                -- xxmsg('打开玩法目录')
                decider.sleep(1000)
                common.do_alt_key(81)
                decider.sleep(2000)
            end
            -- 判断混沌窗口是否打开
            if ui_unit.is_open_play_dir_wnd() and dungeon_unit.get_dungeon_wnd() == 0 then
                -- xxmsg('打开混沌窗口')
                dungeon_unit.open_dungeon_wnd()
                decider.sleep(1000)
            end
            if num >= 30 then
                -- xxmsg('打开混沌窗口超时')
                break
            end
            num = num + 1
        end
        decider.sleep(1000)
    end
    return ret
end

------------------------------------------------------------------------------------
-- [行为] 进入混沌地牢
------------------------------------------------------------------------------------
function dungeon_ent.enter_chaos_dungeons()
    local enter_name          = this.get_enter_hd_name()
    -- 通过地牢名字获取地牢信息
    local chaos_dungeons_info = this.get_chaos_dungeons_info_by_name(enter_name)
    if table.is_empty(chaos_dungeons_info) then
        -- xxmsg('无法获取【贝隆北部的共鸣1阶段】副本信息')
        return false
    end
    -- 打开混沌地牢窗口
    if this.open_chaos_dungeons_wnd() then
        -- 点击入场
        if dungeon_unit.get_dun_dialog_status() == 0 then
            dungeon_unit.req_enter_dungeon(chaos_dungeons_info.main_id, chaos_dungeons_info.sub_id)
            trace.output('进入【'..enter_name..'】')
            common.wait_change_type(0,'确定进入混沌地牢',10,dungeon_unit.get_dun_dialog_status)
            decider.sleep(2000)
        end
        -- 确认入场
        if dungeon_unit.get_dun_dialog_status() > 0 then
            dungeon_unit.confirm_enter_dungeon()
            decider.sleep(2000)
            common.wait_loading_map()
        end
    end

end

------------------------------------------------------------------------------------
-- [判断] 是否退出混沌地牢
------------------------------------------------------------------------------------
function dungeon_ent.exit_dungeon()
    local out = false
    if ( dungeon_unit.dungeon_is_over() or dungeon_unit.has_result_norma_frame() or dungeon_unit.get_dungeon_remaining_time() == 0 ) and actor_unit.map_name() == '混沌地牢' then
        trace.output('副本完成-退出')
        decider.sleep(3000)
        dungeon_unit.exit_dungeon()
        decider.sleep(5000)
        common.wait_loading_map()
    end
    return out
end

------------------------------------------------------------------------------------
-- [判断] 是否能进入混沌地牢
------------------------------------------------------------------------------------
function dungeon_ent.can_in_chaos_dungeons()
    local map_name = actor_unit.map_name()
    if map_name == '混沌地牢' then
        return true
    end
    if user_set_ent['开启混沌地牢'] == 0 then
        return false,'没有开启混沌地牢'
    end
    -- 在星辰副本中 退出
    if dungeon_res.is_in_stars_guard() then
        return false,'在星辰副本中'
    end
    local level = local_player:level()
    if level < 50 and level ~= 0 then
        return false, '角色等级低于50级'
    end
    local equip_prop_level = item_unit.get_equip_prop_level()
    if equip_prop_level < 250 and equip_prop_level ~= 0 then
        return false, '角色装分低于250'
    end
    if dungeon_unit.get_fatigue_value() < 50 then
        return false, '共鸣气息不足50个'
    end
    -- 是否已开启任务
    local list = daily_unit.list(1)
    if #list == 0 then
        return false, '任务未开启'
    end
    -- 积分领完毕 不继续做
    -- daily_unit.reward_is_active(4) daily_unit.reward_is_receive(4)
    if user_set_ent['轮刷周任务出金'] == 1 and ( trace.ROLE_IDX ~= user_set_ent['主角序号'] or utils.get_weekday() == 2 ) and daily_unit.reward_is_active(4) then
        return false,'已达70积分'
    end
    return true
end

------------------------------------------------------------------------------------
-- [读取] 通过混沌地牢名字获取混沌地牢信息表
------------------------------------------------------------------------------------
function dungeon_ent.get_chaos_dungeons_info_by_name(name)
    local ret_t     = {}
    local list      = dungeon_unit.list()
    for _, obj in pairs(list) do
        if dungeon_ctx:init(obj) then
            if name == dungeon_ctx:name() then
                ret_t = {
                    -- 对象名
                    name        = name,
                    -- 对象指针
                    obj         = obj,
                    -- 对象主ID
                    main_id     = dungeon_ctx:main_id(),
                    -- 对象子ID
                    sub_id      = dungeon_ctx:sub_id(),
                    -- 装备评分（进入混沌地牢的最低装备评分要求）
                    equip_level = dungeon_ctx:equip_level(),
                }
                break
            end
        end
    end
    return ret_t
end

------------------------------------------------------------------------------------
-- [读取] 获取可进入的混沌副本名称
function dungeon_ent.get_enter_hd_name()
    local enter_name  = '贝隆北部的共鸣1阶段'
    local equip_prop_level = item_unit.get_equip_prop_level()
    if equip_prop_level >= 500 then
        enter_name = '贝隆北部的共鸣2阶段'
    end
    -- 获取当前装备评分
    local prop_level  = item_unit.get_equip_prop_level()
    -- 提高战力等级差
    prop_level        = ( prop_level > 530 and prop_level < 1100 ) and prop_level - 30 or prop_level
    -- 保存可执行的所有副本名
    local can_do_list = {}
    -- 获取混沌地牢资源信息
    local d_list      = dungeon_res.CHAOS_INFO
    for _,v in pairs(d_list) do
        local finish_task = v.finish_task
        local task_map_id = v.task_map_id
        local min_power   = v.min_power
        -- 指定任务是否完成
        if task_map_id ~= 0 and prop_level >= min_power then
            if quest_ent.is_finish_quest_by_map_id_and_name(finish_task,task_map_id) then
                table.insert(can_do_list,v)
            end
        end
    end
    if not table.is_empty(can_do_list) then
        table.sort(can_do_list,function(a, b) return a.min_power > b.min_power end)
        enter_name = can_do_list[1].can_do
    end
    return enter_name
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function dungeon_ent.__tostring()
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
function dungeon_ent.__newindex(t, k, v)
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
dungeon_ent.__index = dungeon_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function dungeon_ent:new(args)
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
    return setmetatable(new, dungeon_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return dungeon_ent:new()

-------------------------------------------------------------------------------------
