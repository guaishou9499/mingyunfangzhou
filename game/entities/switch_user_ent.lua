-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
--- @author:   monster
--- @email:    88888@qq.com
--- @date:     2023-2-13
--- @module:   switch_user
--- @describe: 切换用户模块
--- @version:  v1.0
-------------------------------------------------------------------------------------
local VERSION         = '20211017' -- version history at end of file
local AUTHOR_NOTE     = '-[20211017]-'
local main_ctx        = main_ctx
---@class switch_user_ent
local switch_user_ent = {
    VERSION           = VERSION,
    AUTHOR_NOTE       = AUTHOR_NOTE,
    -- 开启本地记录，0 在redis中保存，1 本地保存
    ROLE_OPEN_LOCAL   = 1,
    -- 记录角色的路径
    ROLE_RECORD       = '方舟:内置数据:服务器:' .. main_ctx:c_server_name() .. ':Profile:'..main_ctx:c_account(),
    -- 连接服务器
    CONNECT_OBJ       = nil,
}
local this            = switch_user_ent
local pairs           = pairs
local setmetatable    = setmetatable
local tostring        = tostring
local tonumber        = tonumber
local table           = table
local type            = type
local trace           = trace
local decider         = decider
local import          = import
local ship_unit       = ship_unit
local login_unit      = login_unit
local common          = common
local actor_unit      = actor_unit
local game_unit       = game_unit
local local_player    = local_player
local configer        = import('base/configer')
local utils           = import('base/utils')
---@type user_set_ent
local user_set_ent    = import('game/entities/user_set_ent')
---@type redis_ent
local redis_ent       = import('game/entities/redis_ent')
---@type quest_ent
local quest_ent       = import('game/entities/quest_ent')
---@type dungeon_ent
local dungeon_ent     = import('game/entities/dungeon_ent')
---@type hunt_ent
local hunt_ent        = import('game/entities/hunt_ent')
---@type daily_quest_ent
local daily_quest_ent = import('game/entities/daily_quest_ent')
---@type other_task_ent
local other_task_ent  = import('game/entities/other_task_ent')
---@type map_ent
local map_ent         = import('game/entities/map_ent')
---@type shop_ent
local shop_ent        = import('game/entities/shop_ent')
---@type map_res
local map_res         = import('game/resources/map_res')
---@type ui_ent
local ui_ent          = import('game/entities/ui_ent')
---@type dungeon_stars_guard_ent
local dungeon_stars_guard_ent = import('game/entities/dungeon_stars_guard_ent')

------------------------------------------------------------------------------------
-- 角色选择序号
this.select_idx     = 1

------------------------------------------------------------------------------------
-- [行为] 切换角色
switch_user_ent.execute_switch = function()
    -- 无需切换时返回
    if not this.is_do_switch_user() then
        return false
    end
    -- 脚本终止时
    if not decider.is_working() then
        return false
    end
    local idx = common.get_cache_result_ex('switch_name',switch_user_ent.get_active_status_idx,10)
    trace.set_role_idx(idx)
    quest_ent.finish_task()
    if common.is_sleep_any('检测打开玩法目录',3600) then
        daily_quest_ent.open_daily_quest_wnd()
    end
    idx                  = this.get_active_status_idx()
    local num            = user_set_ent['角色数量']
    local sel_idx        = user_set_ent['指定登录序号']
    num                  = sel_idx > 0 and num < sel_idx and sel_idx or num
    local stop_s         = sel_idx > 0 and sel_idx == idx or false
    -- 领取积分
    daily_quest_ent.receive_reward()
    -- 设置完成序号
    switch_user_ent.set_finish_idx(idx)
    local not_finish_idx = this.get_best_not_finish_idx()  --this.is_finish_idx
    -- 计算下一登录序号
    local set_idx        = not_finish_idx > 0 and not_finish_idx or idx + 1
    if ( idx < num or not_finish_idx > 0 and idx >= num ) and not stop_s and not this.is_finish_idx(set_idx) then
        this.set_active_status_idx(set_idx)
        -- 切换登录
        this.reset_login()
    else
        -- 最后一个角色时
        trace.output('角色已完成['..idx..'/'..num..']')
        -- 移动到最近的大陆城市
        if not actor_unit.is_dungeon_map() or map_res.is_in_islet() or map_res.is_in_ocean() then
            local main_city = map_ent.get_best_power_city()
            map_ent.move_to_map(main_city)
        end
        -- 兑换积分
        shop_ent.buy_gold(
                function()
                    -- 当前角色序号
                    local role_idx       = trace.ROLE_IDX
                    local leading_idx    = user_set_ent['主角序号']
                    if role_idx ~= leading_idx and leading_idx ~= 0 then
                        return false
                    end
                    return true
                end
        )
        -- 当前角色序号
        local role_idx    = trace.ROLE_IDX
        local leading_idx = user_set_ent['主角序号']
        if role_idx ~= leading_idx and leading_idx ~= 0 and leading_idx <= num then
            this.set_active_status_idx(leading_idx)
            -- 切换登录
            this.reset_login()
            return false
        end
        -- 检测是否下线
        if user_set_ent['完成切换下线'] == 1 then
            -- 重置登录
            this.set_active_status_idx(1)
            decider.sleep(3000)
            main_ctx:set_ex_state(1)
            decider.sleep(3000)
            main_ctx:end_game()
        end
    end
    return true
end

------------------------------------------------------------------------------------
-- [行为] 设置登录
switch_user_ent.reset_login = function()
    ui_ent.close_ui()
    -- 在航海中
    if ship_unit.is_in_ocean() or ship_unit.is_open_anchor_frame() then
        common.key_call('KEY_Z')
        return false
    end
    trace.output('切换到登录界面')
    decider.sleep(3000)
    actor_unit.leave_game()
    common.wait_change_type(9,'切换到登录界面',30,game_unit.get_connect_status)
    common.wait_show_str('切换到登录界面',20,true)
end

------------------------------------------------------------------------------------
-- [条件] 是否执行当前模块
switch_user_ent.is_do_switch_user = function()
    -- 当前角色是否执行主线  false时 返回
    if not quest_ent.is_stop_main_task() then
        return false
    end
    -- 当前角色是否混沌副本  true时 返回
    if dungeon_ent.can_in_chaos_dungeons() then
        return false
    end
    -- 当前角色是否执行跑岛  true时 返回
    if other_task_ent.is_need_accept_task() then
        return false
    end
    -- 当前角色是否执行日常  true时 返回
    if daily_quest_ent.is_need_accept_day_task() then
        return false
    end
    -- 当前角色是否执行生活产出 true时 返回

    -- 当前角色是否执行讨伐  true时 返回
    if dungeon_stars_guard_ent.can_in_stars_guard() then
        return false
    end
    -- 当前角色是否执行挂机  true时 返回
    if hunt_ent.is_start_hunt() then
        return false
    end
    -- 执行当前模块
    return true
end

------------------------------------------------------------------------------------
-- [读取] 获取可登录序号
switch_user_ent.get_can_login_id = function()
    -- 获取当前活跃序号[从ini]
    local idx1               = this.get_active_status_idx()
    -- 指定登录序号
    local sel_idx            = user_set_ent['指定登录序号']
    -- 角色数量
    local num                = user_set_ent['角色数量']
    num                      = sel_idx > 0 and num < sel_idx and sel_idx or num
    -- 赋值登录序号
    idx1                     = sel_idx > 0 and sel_idx or idx1
    -- 获取当前活跃下对应的名称,ID[从ini]
    local name,idx           = this.get_name_and_id_by_idx_ini(idx1)
    -- 获取角色信息[游戏数据]
    local role_list          = this.get_role_list()
    -- 取记录路径
    local path               = this.ROLE_RECORD
    -- 遍历角色游戏数据信息
    for _,v in pairs(role_list) do
        if v.name == name and name ~= '' or idx == tostring(v.idx) and idx ~= -1 then
            -- 根据ID 进入游戏
            return false,v.idx,v.name
        end
    end

    -- 判断角色数
    if #role_list < num then
        -- 需要创建角色
        return true,#role_list,''
    else
        -- 重置状态 选择1角色进入
        this.write_string_to_ini(path,'role_status','login',1)
        -- 获取当前活跃下对应的
        name,idx         = this.get_name_and_id_by_idx_ini(1)
        local is_exist = false
        -- 检测角色是否存在
        for _,v in pairs(role_list) do
            if name == v.name and name ~= '' then
                is_exist = true
                break
            end
        end
        if name ~= '' and is_exist then
            return false,tonumber(idx),name
        else
            -- 清空第一角色信息
            -- 取当前路径下的角色序号信息
            this.write_string_to_ini(this.ROLE_RECORD,'role_info',1,'')
            return false,role_list[1].idx,role_list[1].name
        end
    end
end

------------------------------------------------------------------------------------
-- [读取] 获取当前活跃状态角色序号
switch_user_ent.get_active_status_idx = function()
    -- 取记录路径
    local path      = this.ROLE_RECORD
    -- 获取激活的角色序号
    local str_idx   = this.read_string_to_ini(path,'role_status','login')
    -- 检测自身序号,不配对时重新选择
    local role_idx  = this.get_self_role_idx()
    if str_idx ~= '' and role_idx ~= tonumber(str_idx) and role_idx >= 0 then
        this.set_active_status_idx( role_idx )
        str_idx = role_idx
    end
    -- 返回显示序号
    if str_idx ~= '' then return tonumber(str_idx) end
    -- 设置第一个序号为活跃号
    this.write_string_to_ini(path,'role_status','login',1)
    return 0
end

------------------------------------------------------------------------------------
-- [写入] 设置活跃序号
switch_user_ent.set_active_status_idx = function(idx)
    -- 取记录路径
    local path      = this.ROLE_RECORD
    local str_idx   = this.read_string_to_ini(path,'role_status','login')
    if str_idx ~= idx then
        this.write_string_to_ini(path,'role_status','login',idx)
    end
end

------------------------------------------------------------------------------------
-- [读取] 获取任务未完成的最前序号
switch_user_ent.get_best_not_finish_idx = function()
    local num      = user_set_ent['角色数量']
    -- 取记录路径
    local path     = this.ROLE_RECORD
    -- 检测自身序号,不配对时重新选择
    local role_idx = this.get_self_role_idx()
    for i = 1,num do
        local str = this.read_string_to_ini(path,'finish_task',i,true)
        if str == '' and role_idx ~= i then
            return i
        end
    end
    return 0
end

------------------------------------------------------------------------------------
-- [条件] 指定角色序号是否完成
switch_user_ent.is_finish_idx = function(idx)
    -- 取记录路径
    local path = this.ROLE_RECORD
    local str  = this.read_string_to_ini(path,'finish_task',idx,true)
    if str == '' then
        return false
    end
    return true
end

------------------------------------------------------------------------------------
-- [写入] 设置完成序号
switch_user_ent.set_finish_idx = function(idx)
    -- 取记录路径
    local path      = this.ROLE_RECORD
    local str       = this.read_string_to_ini(path,'finish_task',idx,true)
    if str == '' then
        this.write_string_to_ini(path,'finish_task',idx,1,true)
    end
end

------------------------------------------------------------------------------------
-- [写入] 写入角色序号
switch_user_ent.write_role_idx_in_ini = function()
    -- 获取角色信息
    local role_list       = this.get_role_list()
    -- 遍历角色信息
    for _,v in pairs(role_list) do
        local name        = v.name
        local idx         = v.idx
        -- 读写角色序号
        this.set_role_by_name_in_ini(name,idx,#role_list)
    end
end

------------------------------------------------------------------------------------
-- [读取] 取序号对应的角色记录
switch_user_ent.get_name_and_id_by_idx_ini = function(idx)
    -- 取记录路径
    local path      = this.ROLE_RECORD
    -- 取当前路径下的角色序号信息
    local str_idx = this.read_string_to_ini(path,'role_info',idx)
    local str = utils.split_string(str_idx,',')
    return str[1] or '',str[2] or -1
end

------------------------------------------------------------------------------------
-- [读取] 获取自身角色序号【0开始】
switch_user_ent.get_self_role_idx = function()
    local role_num = 6
    local my_name  = local_player:name()
    for i = 1,role_num do
        local name,idx = this.get_name_and_id_by_idx_ini(i)
        if name == my_name and name ~= '' then
            return tonumber(i)
        end
    end
    return -1
end

------------------------------------------------------------------------------------
-- [读写] 写入/读取角色序号
switch_user_ent.set_role_by_name_in_ini = function(name,id,num)
    local idx       = 0
    -- 取记录路径
    local path      = this.ROLE_RECORD
    -- 保存角色的列表
    local role_list = {}
    -- 需要数量
    local need_count= num or this.ROLE_NUM
    -- 遍历角色序号
    for i = 1,need_count do
        local ret   = {}
        -- 读取当前序号下的记录
        local str_idx = this.read_string_to_ini(path,'role_info',i)
        -- 角色序号
        ret.idx     = i
        -- 角色名称
        ret.name    = ''
        -- 角色ID
        ret.id      = -1
        if str_idx ~= '' then
            -- 角色记录格式为：角色名,角色ID
            local str = utils.split_string(str_idx,',')
            if type(str) == 'table' then
                ret.name       = str[1]
                ret.id         = tonumber(str[2])
            end
        end
        -- 保存到列表
        table.insert(role_list,ret)
    end
    -- 配对名称
    for _,role in pairs(role_list) do
        if role.name == name or role.id == id then
            idx = role.idx
            break
        end
    end
    -- 取空记录位置
    if idx == 0 then
        for _,role in pairs(role_list) do
            if role.name == '' then
                idx = role.idx
                break
            end
        end
        if idx ~= 0 then
            local write = name..','..id
            -- 写入位置
            this.write_string_to_ini(path,'role_info',idx,write)
        end
    end
    return idx
end

------------------------------------------------------------------------------------
-- [读取] 获取所有角色数据[等级从高到低排序]
switch_user_ent.get_role_list = function()
    local ret                     = {}
    -- 角色选择页面功能
    local char_count = login_unit.get_char_count()
    for i = 0, char_count -1
    do
        local result          = {}
        --result.id             = login_unit.get_char_classid(i)
        result.name           = login_unit.get_char_name(i)
        result.id             = login_unit.get_charptr_byidx(i)
        result.idx            = i
        result.level          = login_unit.get_char_level(i)
        table.insert(ret,result)
    end
    -- table.sort(ret,function(a, b) return a.level > b.level end)
    return ret
end

------------------------------------------------------------------------------------
-- [读取] 读取封装
switch_user_ent.read_string_to_ini = function(path,session,key,is_day)
    if this.ROLE_OPEN_LOCAL == 1 then
        --get_user_profile_today
        if is_day then
            return configer.get_user_profile_today_and_nextday_hour(session,key)
        end
        return configer.get_user_profile(session,key)
    end
    path = path or this.ROLE_RECORD
    return redis_ent.get_string_redis_ini_ex(path,session,key,this.CONNECT_OBJ)
end

------------------------------------------------------------------------------------
-- [写入] 写入封装
switch_user_ent.write_string_to_ini = function(path,session,key,value,is_day)
    if this.ROLE_OPEN_LOCAL == 1 then
        --set_user_profile_today
        if is_day then
            return configer.set_user_profile_today_and_nextday_hour(session,key,value)
        end
        return configer.set_user_profile(session,key,value)
    end
    path = path or this.ROLE_RECORD
    return redis_ent.set_string_redis_ini_ex(path,session,key,value,this.CONNECT_OBJ)
end

------------------------------------------------------------------------------------
-- 实例化新对象

function switch_user_ent.__tostring()
    return "FZ switch_user_ent package"
end

switch_user_ent.__index = switch_user_ent

function switch_user_ent:new(args)
    local new = { }

    if args then
        for key, val in pairs(args) do
            new[key] = val
        end
    end

    -- 设置元表
    return setmetatable(new, switch_user_ent)
end

-------------------------------------------------------------------------------------
-- 返回对象
return switch_user_ent:new()

-------------------------------------------------------------------------------------