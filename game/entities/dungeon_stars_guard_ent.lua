------------------------------------------------------------------------------------
-- game/entities/dungeon_stars_guard_ent.lua
--
-- 星辰副本
--
-- @module      dungeon_stars_guard_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local dungeon_stars_guard_ent = import('game/entities/dungeon_stars_guard_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class dungeon_stars_guard_ent
local dungeon_stars_guard_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME = 'dungeon_stars_guard_ent module',
    -- 只读模式
    READ_ONLY = false,
}

local this              = dungeon_stars_guard_ent
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
local hook_unit         = hook_unit
local os                = os
local math              = math
local table             = table
local rawset            = rawset
local pairs             = pairs
local setmetatable      = setmetatable
local utils             = import('base/utils')
---@type item_ent
local item_ent          = import('game/entities/item_ent')
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
local configer          = import('base/configer')
---@type dungeon_res
local dungeon_res       = import('game/resources/dungeon_res')
---@type map_res
local map_res           = import('game/resources/map_res')
---@type skill_ent
local skill_ent         = import('game/entities/skill_ent')
-- 星辰周长任务列表
local daily_quest_list  = dungeon_res.DAILY_STARS_QUEST_LIST

------------------------------------------------------------------------------------
-- [行为] 开始星辰副本
------------------------------------------------------------------------------------
function dungeon_stars_guard_ent.start_stars_guard()
    while decider.is_working() do
        -- 死亡检测
        actor_ent.check_dead()
        -- 过图检测
        common.wait_loading_map()
        -- 检测UI相关
        ui_ent.esc_cinema()
        -- xxmsg('is_in_stars_guard '..tostring(dungeon_res.is_in_stars_guard()))
        -- 判断是否在星辰地牢
        if dungeon_res.is_in_stars_guard() then
            configer.set_user_profile_today_and_nextday_hour('副本记录', '讨伐星辰'..local_player:name(),1)
            this.fight_stars_guard()
        else
            -- 判断是否可执行星辰
            if not this.can_in_stars_guard() then
                return true
            end
            -- 离开 特里希温
            map_ent.move_go_away_tlsw()
            -- 不在副本地图
            if not actor_unit.is_dungeon_map() or map_res.is_in_islet() or map_res.is_in_ocean() then
                local main_city = map_ent.get_best_power_city()
                if main_city ~= '' and map_ent.is_active_transfer_by_map_name(main_city) then
                    map_ent.move_to_map(main_city)
                end
            end
            -- 轮循可执行功能
            loop_ent.looping()
            -- 判断是否能打星辰副本
            if not dungeon_res.is_in_stars_guard() and daily_quest_ent.finish_daily_quest(daily_quest_list, 1) then
                -- 提交任务后打开一下UI 刷新数据
                daily_quest_ent.open_daily_quest_wnd()
            end
            daily_quest_ent.finish_daily_quest(daily_quest_list, 1)
            daily_quest_ent.open_daily_quest_wnd()
            local daily_quest_is_acc = daily_quest_ent.daily_quest_is_acc(daily_quest_list, 1)
            if not daily_quest_is_acc then
                -- 接受周常任务
                daily_quest_ent.acc_daily_quest('[讨伐星辰护卫]收集星辰护卫意志！（发展）', 1)
                daily_quest_ent.acc_daily_quest(daily_quest_list, 1)
                decider.sleep(1000)
            end
            trace.output('进入讨伐星辰')
            this.enter_stars_guard()
        end
        decider.sleep(2000)
    end
end

------------------------------------------------------------------------------------
-- [行为] 星辰副本内战斗
------------------------------------------------------------------------------------
function dungeon_stars_guard_ent.fight_stars_guard()
    -- 进入前的数量
    local not_find   = 0
    -- 标记第一次进入,拾取
    local gather_h   = true
    -- 设置复活模式,默认就近
    local set_rise   = 2
    -- 如果战力高于 1250 则 原地复活
    if item_unit.get_equip_prop_level() >= 1250 then
        set_rise = 1
    end
    while decider.is_working() do
        local w_time = 100
        common.wait_loading_map()
        ui_ent.esc_cinema()
        if actor_ent.check_dead(set_rise) == 2 then
            -- 死亡后重置使用次数
            common.set_key_table('use_stars_hp',0)
            gather_h  = true
        end
        -- 不在星辰副本 退出
        if not dungeon_res.is_in_stars_guard() then
            break
        end
        -- 保存当前副本的信息
        local actor_info = {}
        -- 获取当前地图 对应的BOSS名称
        local info_list  = this.get_stars_guard_kill_monster()
        -- 默认第一个读取的数据
        local info       = info_list[1]
        for _,v in pairs(info_list) do
            local actor_1 = actor_ent.get_actor_info_by_name(v.boss_name, 2)
            if not table.is_empty(actor_1) then
                actor_info = actor_1
                info       = v
                break
            end
        end
        if table.is_empty(actor_info) then
            -- 是否退出星辰副本
            not_find = not_find + 1
            trace.output('没有发现【'..info.boss_name..'】-',not_find)
            if not_find > 9 then
                -- 检测星辰意志
                map_ent.move_to_gather_chest()
                if not_find > 20 and decider.is_working() then
                    common.auto_move(local_player:cx() + 30, local_player:cy() + 30, local_player:cz())
                    trace.output('退出讨伐【'..info.boss_name..'】')
                    ui_ent.exist_stars()
                end
            end
            w_time = 1000
        else
            local is_move_kill = true
            -- 获取血药数
            local cur_hp_num   = item_ent.get_item_num_by_name('高级恢复药',0)
            -- 在中间点500范围时 拾取药品
            if local_player:dist_xy(info.gather_x,info.gather_y) <= 500 and ( cur_hp_num < 15 or gather_h ) then
                -- 战斗道具箱子
                local actor = actor_ent.get_actor_info_by_name('战斗道具箱子', 6)
                if not table.is_empty(actor) then
                    -- 移动到道具口位置
                    if common.auto_move_ex(actor.cx,actor.cy,actor.cz,1000) then
                        common.key_call('KEY_G')
                        common.wait_over_state()
                        decider.sleep(2000)
                        -- 领取道具箱子
                        ui_ent.get_all_item_in_stars()
                        -- 是否攻击标记
                        is_move_kill = false
                        -- 拾起道具箱子标记
                        gather_h     = false
                    end
                end
            end
            -- 检测自身血量
            local cur_hp   = local_player:hp() * 100 / local_player:max_hp()
            -- 检测附近奶球
            if cur_hp < 75 then
                local g_info   = actor_ent.get_can_gather_add_hp_info()
                if not table.is_empty(g_info) then
                    is_move_kill = false
                    if common.auto_move_ex(g_info.cx,g_info.cy,g_info.cz,500) then
                        common.key_call('KEY_G')
                    end
                    cur_hp   = local_player:hp() * 100 / local_player:max_hp()
                end
            end
            -- 如果血量低 并且不存在药品
            if cur_hp < 50 then
                local is_check_hp = true
                -- 标记使用恢复药次数
                local use_hp_num = common.get_key_table('use_stars_hp') or 0

                if cur_hp_num > 0 then
                    -- 检测CD
                    local hp_info = item_ent.get_item_info_by_name('高级恢复药(绑定)')
                    -- 上次使用时间
                    local use_time = common.get_key_table('use_stars_hp_time') or 0
                    if use_hp_num < 5 and not table.is_empty(hp_info) and item_unit.get_item_cooldown(hp_info.res_id) == 0 and os.time() - use_time > 10 then
                        is_check_hp = false
                        -- 按键快捷1
                        common.key_call('KEY_1')
                        -- 设置使用次数
                        common.set_key_table('use_stars_hp',use_hp_num + 1)
                        -- 设置使用时间
                        common.set_key_table('use_stars_hp_time',os.time())
                    end
                end
                -- 没有检测HP血量
                if is_check_hp then
                    -- 检测距离怪物最远的目标玩家信息
                    local _,all_list = actor_ent.get_nearest_actor_info_by_rad_pos(nil,actor_info.cx,actor_info.cy,1500,actor_ent.OTHER_PLAYER)
                    if not table.is_empty(all_list) and all_list[1].name == local_player:name() then
                        -- 移动到该目标点
                        local b_info = all_list[#all_list]
                        if not table.is_empty(b_info) then
                            if b_info.dist > 200 then
                                if not local_player:is_move() then
                                    common.auto_move(b_info.cx, b_info.cy, b_info.cz)
                                end
                                -- 移动到此位置
                                is_move_kill = false
                            end
                        end
                    end
                end
            end
            -- 去怪物点击杀怪物
            if is_move_kill then
                actor_info = actor_ent.get_actor_info_by_name(info.boss_name, 2)
                if not table.is_empty(actor_info) then
                    -- 怪物距离过远就靠近
                    if actor_info.dist > 500 then
                        if actor_info.dist > 1500 then
                            map_ent.check_move(actor_info.cx,actor_info.cy,actor_info.cz,true)
                        end
                        -- 移动时检测是否存在堵路怪物
                        if not map_ent.move_to_kill_actor(nil,60,nil,nil,60) then
                            if not local_player:is_move() then
                                trace.output('[星辰]寻到（'..info.boss_name..'）位 距：'..math.floor(actor_info.dist))
                                common.auto_move(actor_info.cx, actor_info.cy, actor_info.cz)
                            end
                        else
                            w_time = 100
                        end
                    else
                        trace.output('[星辰]杀：',actor_info.name,' HP：',actor_info.max_hp > 0 and math.floor(actor_info.hp * 100/actor_info.max_hp) or 100,'%')
                        skill_ent.auto_skill(actor_info.cx, actor_info.cy, actor_info.cz,nil,nil,true)
                    end
                end
            end
        end
        decider.sleep(w_time)
    end
end

------------------------------------------------------------------------------------
-- [行为] 打开星辰副本
------------------------------------------------------------------------------------
function dungeon_stars_guard_ent.open_stars_guard_wnd()
    local ret = false
    local num = 1
    while decider.is_working() do
        -- 判断星辰窗口是否打开
        if dungeon_unit.get_raid_entrance_wnd() > 0 then
            ret = true
            break
        end
        if dungeon_res.is_in_stars_guard() then
            break
        end
        common.wait_loading_map()
        ui_ent.esc_cinema()
        local kill_dist = local_player:is_battle() and 800 or 200
        if not map_ent.move_to_kill_actor(nil,kill_dist) then
            trace.output('打开星辰窗口[' .. num .. ']')
            -- 判断玩法目录是否打开
            if not ui_unit.is_open_play_dir_wnd() and dungeon_unit.get_raid_entrance_wnd() == 0 then
                decider.sleep(1000)
                common.do_alt_key(81)
                decider.sleep(2000)
            end
            -- 判断星辰窗口是否打开
            if ui_unit.is_open_play_dir_wnd() and dungeon_unit.get_raid_entrance_wnd() == 0 then
                dungeon_unit.open_raid_entrance_wnd()
                decider.sleep(2000)
            end
            if num >= 30 then
                break
            end
            num = num + 1
        end
        decider.sleep(2000)
    end
    return ret
end

------------------------------------------------------------------------------------
-- [行为] 进入星辰副本
------------------------------------------------------------------------------------
function dungeon_stars_guard_ent.enter_stars_guard()
    local enter_info          = this.get_enter_stars_guard_info()
    if table.is_empty(enter_info) then
        return false
    end
    -- 打开星辰副本窗口
    if this.open_stars_guard_wnd() then
        decider.sleep(3000)
        -- 点击入场
        if dungeon_unit.get_dun_dialog_status() == 0 and not ui_unit.has_dialog() then
            decider.sleep(1000)
            dungeon_unit.matching_raid(enter_info.main_idx, enter_info.sub_idx)
            trace.output('匹配进入【'..enter_info.can_do..'】')
            decider.sleep(2000)
            for i = 300,1,-1 do
                if dungeon_unit.get_dun_dialog_status() > 0 or ui_unit.has_dialog() then
                    break
                end
                trace.output('等待进入【'..enter_info.can_do..'】('..i..')')
                decider.sleep(1000)
            end
        end
        -- 确认入场
        if dungeon_unit.get_dun_dialog_status() > 0 or ui_unit.has_dialog() then
            trace.output('确认进入【'..enter_info.can_do..'】')
            -- dungeon_unit.confirm_enter_dungeon()
            ui_unit.confirm_dialog(true)
            for i = 120,1,-1 do
                if  not ui_unit.has_dialog() or dungeon_res.is_in_stars_guard() then
                    break
                end
                trace.output('正进星辰【'..enter_info.can_do..'】('..i..')')
                decider.sleep(1000)
            end
            decider.sleep(2000)
            common.wait_loading_map()
        end
    end
end

------------------------------------------------------------------------------------
-- [判断] 是否退出星辰副本
------------------------------------------------------------------------------------
function dungeon_stars_guard_ent.exit_stars_guard()

end

------------------------------------------------------------------------------------
-- [判断] 是否能进入星辰地牢
------------------------------------------------------------------------------------
function dungeon_stars_guard_ent.can_in_stars_guard()
    -- 在星辰地图中
    if dungeon_res.is_in_stars_guard() then
        return true
    end
    local map_name = actor_unit.map_name()
    if map_name == '混沌地牢' then
        return false,'在混沌地牢退出'
    end
    if user_set_ent['开启讨伐星辰'] == 0 then
        return false,'没有开启讨伐星辰'
    end
    local level = local_player:level()
    if level < 50 and level ~= 0 then
        return false, '角色等级低于50级'
    end
    local equip_prop_level = item_unit.get_equip_prop_level()
    if equip_prop_level < 500 and equip_prop_level ~= 0 then
        return false, '角色装分低于500'
    end
    -- 任务次数[实际为可收集的星辰意志次数]
    local read_str = common.get_cache_result_ex('fb_讨伐星辰',configer.get_user_profile_today_and_nextday_hour,10,'副本记录', '讨伐星辰'..local_player:name())
    if read_str == '1' then
        return false, '任务已完成'
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
-- [读取] 通过星辰副本名字获取星辰副本信息表
------------------------------------------------------------------------------------
function dungeon_stars_guard_ent.get_stars_guard_info_by_name(name)
    local ret_t     = {}
    local raid_list = dungeon_unit.raid_dun_list()
    for _, obj in pairs(raid_list) do
        if dungeon_ctx:init(obj) then
            if name == dungeon_ctx:raid_name() then
                ret_t = {
                    -- 对象名
                    name        = name,
                    -- 对象指针
                    obj         = obj,
                    -- 对象主ID
                    main_idx    = dungeon_ctx:raid_main_idx(),
                    -- 对象子ID
                    sub_idx     = dungeon_ctx:raid_sub_idx(),
                    -- 装备评分（进入地牢的最低装备评分要求）
                    equip_level = dungeon_ctx:equip_level(),
                }
                break
            end
        end
    end
    return ret_t
end

------------------------------------------------------------------------------------
-- [读取] 获取可进入的星辰副本信息
function dungeon_stars_guard_ent.get_enter_stars_guard_info()
    -- 保存返回列表
    local enter_info    = {}
    -- 获取当前装备评分
    local prop_level    = item_unit.get_equip_prop_level()
    -- 保存可执行的所有副本名
    local can_do_list   = {}
    -- 获取混沌地牢资源信息
    local d_list        = dungeon_res.STARS_INFO
    for _,v in pairs(d_list) do
        local is_open   = v.is_open
        local min_power = v.min_power
        -- 指定任务是否开启
        if is_open and prop_level >= min_power then
            table.insert(can_do_list,v)
        end
    end
    -- 按战力排序
    if not table.is_empty(can_do_list) then
        table.sort(can_do_list,function(a, b) return a.min_power > b.min_power end)
        enter_info = can_do_list[1]
    end
    return enter_info
end

------------------------------------------------------------------------------------
-- [读取] 获取当前星辰地图需要击杀的信息
function dungeon_stars_guard_ent.get_stars_guard_kill_monster()
    local kill_info = {}
    local map_id    = actor_unit.map_id()
    -- 获取混沌地牢资源信息
    local d_list    = dungeon_res.STARS_INFO
    for _,v in pairs(d_list) do
        if map_id == v.map_id then
            table.insert(kill_info,v)
        end
    end
    return kill_info
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function dungeon_stars_guard_ent.__tostring()
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
function dungeon_stars_guard_ent.__newindex(t, k, v)
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
dungeon_stars_guard_ent.__index = dungeon_stars_guard_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function dungeon_stars_guard_ent:new(args)
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
    return setmetatable(new, dungeon_stars_guard_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return dungeon_stars_guard_ent:new()

-------------------------------------------------------------------------------------
