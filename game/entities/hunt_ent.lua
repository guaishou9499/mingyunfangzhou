------------------------------------------------------------------------------------
-- game/entities/hunt_ent.lua
--
-- 这个模块主要是项目内物品相关功能操作。
--
-- @module      hunt_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local hunt_ent = import('game/entities/hunt_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class hunt_ent
local hunt_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION      = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE  = '2023-03-22 - Initial release',
    -- 模块名称
    MODULE_NAME  = 'hunt_ent module',
    -- 只读模式
    READ_ONLY    = false,
    -- 坐标设置生成路径
    POS_PATH     = '方舟:机器[%s]:坐标设置',
    -- 是否本地配置
    IS_LOCAL_INI = true,
    -- 本地配置时的生成名
    INI_NAME     = '挂机设置.ini',
    -- 连接服务器
    CONNECT_OBJ  = nil,

}

-- 自身单元
local this         = hunt_ent
-- 日志模块
local trace        = import('base/trace')
-- 决策模块
local decider      = decider
---@type common
local common       = common
local os           = os
local tonumber     = tonumber
local pairs        = pairs
local table        = table
local setmetatable = setmetatable
local string       = string
local hook_unit    = hook_unit
local local_player = local_player
local actor_unit   = actor_unit
local import       = import
local configer     = import('base/configer')
---@type hunt_res
local hunt_res     = import('game/resources/hunt_res')
---@type ui_ent
local ui_ent       = import('game/entities/ui_ent')
---@type map_ent
local map_ent      = import('game/entities/map_ent')
---@type item_ent
local item_ent     = import('game/entities/item_ent')
---@type shop_ent
local shop_ent     = import('game/entities/shop_ent')
---@type actor_ent
local actor_ent    = import('game/entities/actor_ent')
---@type vehicle_ent
local vehicle_ent  = import('game/entities/vehicle_ent')
---@type skill_ent
local skill_ent    = import('game/entities/skill_ent')
---@type redis_ent
local redis_ent    = import('game/entities/redis_ent')
---@type user_set_ent
local user_set_ent = import('game/entities/user_set_ent')
---@type dungeon_ent
local dungeon_ent  = import('game/entities/dungeon_ent')
---@type quest_ent
local quest_ent    = import('game/entities/quest_ent')
---@type daily_quest_ent
local daily_quest_ent         = import('game/entities/daily_quest_ent')
---@type other_task_ent
local other_task_ent          = import('game/entities/other_task_ent')
---@type dungeon_stars_guard_ent
local dungeon_stars_guard_ent = import('game/entities/dungeon_stars_guard_ent')
---@type dungeon_cir_ent
local dungeon_cir_ent         = import('game/entities/dungeon_cir_ent')
------------------------------------------------------------------------------------
-- [事件]预载函数(重载脚本时)
------------------------------------------------------------------------------------
hunt_ent.super_preload = function()

end

------------------------------------------------------------------------------------
-- [事件]预载函数(重载脚本时)
------------------------------------------------------------------------------------
hunt_ent.super_preload = function()

end

------------------------------------------------------------------------------------
-- [行为] 执行挂机
hunt_ent.execute_hunt = function()
    local sel_key            = '挂机坐标-'..user_set_ent['选择坐标']
    local need_time          = user_set_ent['挂机时长']
    local time_out           = 60
    -- 标记是否超时
    local is_time_o    = false
    hook_unit.enable_mouse_screen_pos(true)
    local local_use_hp = function()
        item_ent.auto_use_hp_ex(60)
    end
    while decider.is_working() do
        local w_time = 100
        -- 获取挂机坐标
        local idx,map_id,x,y,z,r,line,time,start_time = this.get_cache_kill_monster_pos(sel_key,time_out,need_time)
        if idx == -1 or is_time_o then
            trace.output('挂机时长已完【'..need_time..'】小时')
            w_time = 2000
            -- 检测设置是否完成下线
            decider.sleep(3000)
        elseif idx == 0 then
            trace.output('没有可用的坐标资源')
            decider.sleep(3000)
        else
            local map_name = map_ent.get_map_name_by_map_id(map_id)
            if map_name == '' then
                trace.output(actor_unit.map_name()..'['..map_id..']没有地图资源,需反馈记录')
                decider.sleep(3000)
            else
                -- 关闭ui
                ui_ent.close_ui()
                -- 检测死亡
                actor_ent.check_dead()
                -- 去指定地图
                if map_ent.move_to_map(map_name) then
                    -- 吃药
                    local_use_hp()
                    -- 修装备
                    shop_ent.repair_equip()
                    -- 自动分解检测
                    item_ent.decompose_equip()
                    -- 非休息时间下
                    if not common.get_cache_result_ex('execute_check_rest',hunt_ent.check_rest,60) then
                        -- 线路检测
                        if line then

                        end
                        -- 移动寻怪
                        local monster_info = actor_ent.get_nearest_self_actor_info_by_rad_pos('', x, y, r * 100, 2)
                        local str          = '已挂['..common.get_time_status( os.time() - start_time )..']'
                        if os.time() - start_time >= need_time * 3600 then
                            is_time_o = true
                        end
                        if not table.is_empty(monster_info) then
                            -- 下马
                            vehicle_ent.execute_down_riding()
                            trace.output('挂[' .. idx .. '] 打怪中.'..str)
                            ui_ent.close_bag()
                            if monster_info.dist > 500 then
                                if not local_player:is_move() then
                                    common.auto_move(monster_info.cx, monster_info.cy, monster_info.cz)
                                end
                            else
                                skill_ent.auto_skill(monster_info.cx, monster_info.cy, monster_info.cz,local_use_hp)
                            end
                        else
                            trace.output('没有可杀怪 '..str)
                            if not local_player:is_move() then
                                if local_player:dist_xy(x,y) > 500 then
                                    common.auto_move(x, y, z)
                                    decider.sleep(1000)
                                end
                            end
                        end
                    end
                end
            end
        end
        decider.sleep(w_time)
    end
    hook_unit.enable_mouse_screen_pos(false)
end

------------------------------------------------------------------------------------
-- [条件] 是否执行挂机
hunt_ent.is_start_hunt = function()
    if user_set_ent['野外挂机'] == 1 and local_player:level() >= 30 then
        -- 是否执行主线
        if not quest_ent.is_stop_main_task() then
            return false,'执行主线退出挂机'
        end
        -- 是否执行混沌地牢
        if dungeon_ent.can_in_chaos_dungeons() then
            return false,'执行混沌退出挂机'
        end
        -- 是否执行讨伐星辰
        if dungeon_stars_guard_ent.can_in_stars_guard() then
            return false,'执行星辰退出挂机'
        end
        -- 是否执行日常[日常任务]
        if daily_quest_ent.is_need_accept_day_task() then
            return false,'执行日常退出挂机'
        end
        -- 是否执行其他[跑岛任务相关]
        if other_task_ent.is_need_accept_task() then
            return false,'执行其他退出挂机'
        end
        if dungeon_cir_ent.is_need_cir_fb() then
            return false,'执行循环副本'
        end
        local sel_key   = '挂机坐标-'..user_set_ent['选择坐标']
        local need_time = user_set_ent['挂机时长']
        -- 获取挂机是否完成 完成时退出
        local idx = this.get_cache_kill_monster_pos(sel_key,120,need_time)
        if idx == -1 then
            return false,'执行主线退出挂机'
        end
        return true
    end
    return false,'退出挂机'
end

------------------------------------------------------------------------------------
-- [行为] 检测休息
hunt_ent.check_rest = function()
    -- 设置的 休息间隔
    local rest_interval_time = user_set_ent['休息间隔'] or 0
    if rest_interval_time == 0 then
        return false,'没有开启间隔休息'
    end
    -- 设置的 休息时长
    local rest_time          = user_set_ent['休息时长'] or 0
    if rest_time == 0 then
        return false,'没有开启休息时长'
    end
    local last_rest_time = configer.get_user_profile_expire('挂机', '开始挂机')
    if last_rest_time == '' then
        configer.set_user_profile_expire('挂机', '开始挂机',os.time(),86400)
    else
        -- 计算当次挂机时长
        if os.time() - tonumber(last_rest_time) < rest_interval_time * 3600 then
            return false,'正在可挂机范围'
        end
        -- 获取当前开始休息
        local start_rest_time = configer.get_user_profile_expire('挂机', '开始休息')
        if start_rest_time == '' then
            configer.set_user_profile_expire('挂机', '开始休息',os.time(),86400)
        else
            if os.time() - tonumber(start_rest_time) < rest_time * 3600 then
                trace.output('休息中...（'..( rest_time * 3600 + tonumber(start_rest_time) - os.time() )..'）')
            else
                -- 休息完毕后 刷新数据
                configer.set_user_profile_expire('挂机', '开始挂机',os.time(),86400)
                configer.set_user_profile_expire('挂机', '开始休息','',86400)
            end
        end
        return true
    end
    return false,''
end

------------------------------------------------------------------------------------
-- [行为]  生成坐标资源
hunt_ent.create_pos = function()
    -- 生成每个地图资源
    local crete_list = hunt_res.CREATE_POS_LIST
    local line_path = not this.IS_LOCAL_INI and string.format(this.POS_PATH,redis_ent.computer_id) or this.INI_NAME
    -- 生成每个地图
    for k,v in pairs(crete_list) do
        for i = 1,#v do
            local value = redis_ent.get_string_redis_ini_ex(line_path,k,i,this.CONNECT_OBJ,this.INI_NAME)
            if value == '' then
                redis_ent.set_string_redis_ini_ex(line_path,k,i,v[i],this.CONNECT_OBJ,this.INI_NAME)
            end
        end
    end
end

------------------------------------------------------------------------------------
-- [读取] 获取挂机坐标,延迟刷新[默认60 秒]
hunt_ent.get_cache_kill_monster_pos = function(key,time_out,need_time)
    time_out = time_out or 60
    return common.get_cache_result_ex(key,this.get_kill_monster_pos,time_out,key,need_time)
end

------------------------------------------------------------------------------------
-- [读取] 获取挂机坐标
hunt_ent.get_kill_monster_pos = function(key,need_time)
    -- 保存坐标数据
    local data      = this.get_can_use_pos_data(key)
    local num       = #data
    local cacl_time = 0
    local session_s = 'start_pos'
    local session_e = 'end_pos'
    -- 计算已挂机的时间
    for i = 1,num do
        -- 取表中pos.坐标
        if not table.is_empty(data[i]) then-- PK模式：%d+
            local idx     = data[i].idx
            local w_key   = key..'_坐标_'..idx
            -- 获取当前点已执行的时间
            local start_time = configer.get_user_profile_expire(session_s, w_key)
            start_time = start_time == '' and 0 or tonumber(start_time)
            -- 累计计算已挂机的时间 秒
            if start_time > 0 then
                local end_time = configer.get_user_profile_expire(session_e, w_key)
                end_time  = end_time == '' and os.time() or tonumber(end_time)
                cacl_time = cacl_time + ( end_time - start_time )
            end
        end
    end
    -- 选择可挂机的坐标点
    if cacl_time < need_time * 3600 then
        for i = 1,num do
            -- 取表中pos.坐标
            if not table.is_empty(data[i]) then-- PK模式：%d+
                --MAP：aaa,MID:3,X：14553,Y：-6708,Z：190,NLV：4,MLV：100,R：100,LINE:1,TIME：2
                local map_id,x,y,z,min_lv,max_lv,r,line,time = table.unpack(data[i].pos)
                local sel_pos = 0
                local idx     = data[i].idx
                -- 获取地图ID
                map_id        = map_id  and tonumber(map_id)   or 0
                -- 获取坐标x
                x             = x       and tonumber(x)        or 0
                -- 获取坐标y
                y             = y       and tonumber(y)        or 0
                -- 获取坐标z
                z             = z       and tonumber(z)        or 0
                -- 获取打怪范围
                r             = r       and tonumber(r)        or 50
                -- 获取线路
                line          = line    and tonumber(line)     or 0
                -- 当前点可执行时间
                time          = time    and tonumber(time)     or 0

                local w_key   = key..'_坐标_'..idx
                -- 当前点没有限制挂机时间
                if time == 0 then
                    sel_pos = 1
                else
                    -- 当前点限时了挂机时间  -- 获取当前点已执行的时间
                    local start_time = configer.get_user_profile_expire(session_s, w_key)
                    if start_time ~= '' then
                        -- 当前挂机点时间是否已挂满
                        local already_time = os.time() - tonumber(start_time)
                        if already_time < time * 3600 then
                            -- 当前挂机点时间可继续 返回坐标
                            sel_pos = 2
                        else
                            configer.set_user_profile_expire(session_e, w_key,os.time(),86400)
                        end
                    else
                        sel_pos = 1
                    end
                end

                if sel_pos > 0 then
                    local start_time = configer.get_user_profile_expire(session_s, w_key)
                    if start_time == '' then
                        configer.set_user_profile_expire(session_s, w_key,os.time(),86400)
                        start_time = os.time()
                    end
                    -- 返回坐标
                    if os.time() - tonumber(start_time) < need_time * 3600 then
                        return idx,map_id,x,y,z,r,line,tonumber(time),tonumber(start_time)
                    end
                end
            end
        end
        return 0,0,0,0,0,0,0,0,0
    end
    return -1,0,0,0,0,0,0,0,0
end

------------------------------------------------------------------------------------
-- [读取] 读取所有坐标
hunt_ent.get_pos_all = function(key)
    local num       = 10
    local data      = {}
    local line_path = not this.IS_LOCAL_INI and string.format(this.POS_PATH,redis_ent.computer_id) or this.INI_NAME
    for i = 1,num do
        local value = redis_ent.get_string_redis_ini_ex(line_path,key,i,this.CONNECT_OBJ,this.IS_LOCAL_INI)
        if value ~= '' then
            local data1 = {}
            data1.idx = i
            data1.pos = this.get_split_pos(value)
            -- 将分割后的坐标保存到DATA
            table.insert(data,data1)
        end
    end
    return data
end

------------------------------------------------------------------------------------
-- [读取] 读取可选坐标列表[根据等级段]
hunt_ent.get_can_use_pos_data = function(key,level)
    level          = level or local_player:level()
    local data     = this.get_pos_all(key)
    local can_data = {}
    for i = 1,#data do
        -- MAP：aaa,MID:1,X：14553,Y：-6708,Z：190,NLV：1,MLV：100,R：100,LINE:1,TIME：2
        local map_id,x,y,z,min_lv,max_lv = table.unpack(data[i].pos)
        if level >= tonumber(min_lv) and level < tonumber(max_lv)  then
            table.insert(can_data,data[i])
        end
    end
    if not table.is_empty(can_data) then
        table.sort(can_data,function(a, b) return a.idx < b.idx end)
    end
    return can_data
end

------------------------------------------------------------------------------------
-- [读取] 分割坐标,返回坐标数据表
hunt_ent.get_split_pos = function(pos_str)
    local data = {}
    for k in string.gmatch(pos_str,'-?%d+') do
        table.insert(data,k)
    end
    return data
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function hunt_ent.__tostring()
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
hunt_ent.__newindex = function(t, k, v)
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
hunt_ent.__index = hunt_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function hunt_ent:new(args)
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
    return setmetatable(new, hunt_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return hunt_ent:new()

-------------------------------------------------------------------------------------