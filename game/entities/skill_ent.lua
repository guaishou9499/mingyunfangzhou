------------------------------------------------------------------------------------
-- game/entities/skill_ent.lua
--
-- 实体示例
--
-- @module      skill_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local skill_ent = import('game/entities/skill_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class skill_ent
local skill_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME = 'skill_ent module',
    -- 只读模式
    READ_ONLY = false,
}

-- 实例对象
local this         = skill_ent
local decider      = decider
local skill_unit   = skill_unit
local common       = common
local local_player = local_player
local game_unit    = game_unit
local actor_unit   = actor_unit
local ship_unit    = ship_unit
local skill_ctx    = skill_ctx
local trace        = trace
local table        = table
local pairs        = pairs
local rawset       = rawset
local setmetatable = setmetatable
local math         = math
---@type skill_res
local skill_res    = import('game/resources/skill_res')
---@type vehicle_ent
local vehicle_ent  = import('game/entities/vehicle_ent')
---@type item_ent
local item_ent     = import('game/entities/item_ent')
---@type user_set_ent
local user_set_ent = import('game/entities/user_set_ent')
---@type dungeon_cir_res
local dungeon_cir_res = import('game/resources/dungeon_cir_res')
-------------------------------------------------------------------------------------
-- 取可使用快捷建序号
skill_ent.get_use_quick_idx = function(x, y)
    local ret        = 8
    local name       = '普攻'
    local pro_idx    = 0 -- 0 直接使用技能 1 选择后使用技能
    local attack_dis = 650
    local mp         = local_player:mp()
    local info       = skill_res.SKILL_INFO
    local list       = {}
    local dist       = local_player:dist_xy(x, y)
    for i = 0, 7 do
        local id         = skill_unit.get_quick_skill_id_byidx(i)
        local skill_info = this.get_skill_info_by_id(id)
        if not table.is_empty(skill_info) then
            if skill_info.cd_time <= 0 and skill_info.consume_mp <= mp then
                -- 是否选择目标后攻击
                local pro_idx1       = info[skill_info.name] and info[skill_info.name].sel_attack and 1 or 0
                -- 技能的攻击距离
                local attack_dis1    = info[skill_info.name] and info[skill_info.name].attack_dis or 650
                -- 是否关闭使用技能
                local close_use      = info[skill_info.name] and info[skill_info.name].close_use or false
                -- 技能优先顺序
                local use_idx        = info[skill_info.name] and info[skill_info.name].use_idx or 0
                -- 其他方式关闭技能
                local stop_use,s_idx = this.is_stop_use_skill(skill_info.name)

                use_idx = s_idx ~= 666 and s_idx or use_idx
                if dist <= attack_dis1 and not close_use and not stop_use then
                    table.insert(list,{ idx = i,name = skill_info.name,pro_idx = pro_idx1 ,attack_dis = attack_dis1,use_idx = use_idx })
                end
            end
        end
    end
    if not table.is_empty(list) then
        table.sort(list,function(a, b) return a.use_idx < b.use_idx end)
        ret,name,pro_idx,attack_dis = list[1].idx,list[1].name,list[1].pro_idx,list[1].attack_dis
    end
    return ret,name,pro_idx,attack_dis
end

-------------------------------------------------------------------------------------
-- 其他方式关闭技能设置
skill_ent.is_stop_use_skill = function(cur_skill_name)
    -- 需要执行的任务列表
    local list          = dungeon_cir_res.MUST_DO_TASK
    local use_skill_idx = 666
    -- 遍历可刷任务-1
    for fb_name,v in pairs(list) do
        if user_set_ent[fb_name] and user_set_ent[fb_name] >= 1 and ( not table.is_empty(v.stop_skill) or not table.is_empty(v.use_skill)) then
            if not table.is_empty(v.use_idx) then
                use_skill_idx = v.use_idx[cur_skill_name] or use_skill_idx
            end
            -- 可使用的技能
            if common.is_exist_list_arg(v.use_skill,cur_skill_name,true) then
                return false,use_skill_idx
            end
            -- 当前技能不可使用
            if common.is_exist_list_arg(v.stop_skill,cur_skill_name,true) then
                return true,use_skill_idx
            end
        end
    end
    return false,use_skill_idx
end

-------------------------------------------------------------------------------------
-- 获取可设技能快捷资源
skill_ent.get_can_set_quick_res = function()
    local list          = dungeon_cir_res.MUST_DO_TASK
    -- 遍历可刷任务-1
    for fb_name,v in pairs(list) do
        if user_set_ent[fb_name] and user_set_ent[fb_name] >= 1 and not table.is_empty(v.use_idx) then
            return v.use_idx
        end
    end
    return skill_res.SKILL_INFO
end

-------------------------------------------------------------------------------------
-- 取人物指定状态下可使用快捷建序号
skill_ent.get_use_quick_idx_by_status = function(x, y)
    -- 获取人物状态
    local status  = actor_unit.get_local_player_status()
    -- 获取对应资源
    local info    = skill_res.STATUS_SKILL[status]
    -- 获取距离
    local dist    = local_player:dist_xy(x, y)
    if not table.is_empty(info) then
        table.sort(info,function(a, b) return a.cd_time > b.cd_time end)
        for _,v in pairs(info) do
            -- 技能名称
            local name       = v.name
            -- 技能CD
            local time       = v.cd_time
            -- 是否选择目标后攻击
            local sel        = v.sel_attack and 1 or 0
            -- 技能对应序号
            local i          = v.idx
            -- 技能攻击距离
            local attack_dis = v.attack_dis or math.huge
            if common.is_sleep_any('USE_'..status..name,time) and dist <= attack_dis then
                return i,name,sel,attack_dis
            end
        end
    end
    return -1,'',-1,-1
end

-------------------------------------------------------------------------------------
-- 自动技能(目标x,目标y,目标z,加血技能,击杀ID是否需要普攻,是否使用觉醒技能)
skill_ent.auto_skill = function(x, y, z,add_func,kill_id,use_unique)
    -- 获取人物状态对应的技能信息
    local use_quick_idx,skill_name,sel_attack,attack_dis = this.get_use_quick_idx_by_status(x, y)
    if use_quick_idx == -1 then
        -- 获取正常状态下的技能信息
       use_quick_idx,skill_name,sel_attack,attack_dis    = this.get_use_quick_idx(x, y)
    end
    -- 激活游戏窗口才能使用鼠标功能
    if use_quick_idx == 8 and not game_unit.is_active_game_wnd() then
        game_unit.active_game_wnd()
    end
    -- 快捷序号对应的技能按键
    local skill_data                                     = skill_res.SKILL_QUICK[use_quick_idx]
    local skill_key                                      = skill_data.key
    if kill_id then
        -- 当前ID需要首普攻击
        if not common.get_key_table(kill_id) then
            sel_attack     = 0
            skill_key      = 'KEY_C'
            common.set_key_table(kill_id,true)
        end
    end
    -- 是否开启觉醒技能检测
    use_unique = not use_unique and local_player:hp()/local_player:max_hp() <= 0.35 or use_unique
    -- 检测觉醒技能
    if use_unique and local_player:level() >= 50 and item_ent.get_item_num_by_name('混沌碎片') > 0 then
        for s_name,v in pairs(skill_res.SKILL_UNIQUE_INFO) do
            if v.attack_dis and local_player:dist(x,y) <= v.attack_dis or not v.attack_dis then
                local skill_info = skill_ent.get_skill_info_by_name(s_name)
                if not table.is_empty(skill_info) and skill_info.cd_time <= 0 then -- and common.is_sleep_any('use_unique_skill',301)
                    skill_key      = 'KEY_V'
                    sel_attack     = v.sel_attack and 1 or 0
                    break
                end
            end
        end
    end
    --xxmsg(skill_data.key..' '..skill_key)
    local use_z_time = 90
    -- 获取职业名称,使用Z技能间隔
    local job_name,use_z = this.get_job()
    use_z_time = use_z
    -- 间隔90秒使用一次Z技能
    if common.is_sleep_any('auto_use_z',use_z_time) then
        common.key_call('KEY_Z')
    end
    if sel_attack == 1 then
        -- 按下抬起一次技能键
        common.key_call(skill_key)
        decider.sleep(100)
        -- 选择目标位置
        game_unit.set_mouse_pos(x, y, z )
        decider.sleep(200)
        -- 按下技能键
        common.key_call(skill_key,0)
        decider.sleep(200)
        -- 等待技能完成
        common.wait_over_state(add_func)
        -- 抬起技能键
        common.key_call(skill_key,1)
    else
        -- 设置目标位置
        game_unit.set_mouse_pos(x, y, z)
        decider.sleep(100)
        -- 按下技能键
        common.key_call(skill_key,0)
        decider.sleep(200)
        -- 等待技能完成
        common.wait_over_state(add_func)
        -- 抬起技能键
        common.key_call(skill_key,1)
    end
    decider.sleep(200)
end

------------------------------------------------------------------------------------
-- [行为] 设置技能到快捷
skill_ent.config_skill = function()
    -- 在副本中不设置技能快捷
    if actor_unit.is_dungeon_map() then
        return
    end
    if ship_unit.is_in_ocean() or ship_unit.is_open_anchor_frame() then
        return false
    end
    local quick = this.get_can_set_quick_res()
    for name,v in pairs(quick) do
        -- 指定技能是否已配置
        if not this.is_config_name(name) then
            local pos = this.get_can_config_pos()
            if pos ~= -1 then
                local skill_info = this.get_skill_info_by_name(name)
                if not table.is_empty(skill_info) then
                    if not decider.is_working() then
                        break
                    end
                    vehicle_ent.execute_down_riding()
                    skill_unit.set_skill_quick_slot(skill_info.id, pos)
                    decider.sleep(1000)
                end
            end
        end
    end
end

------------------------------------------------------------------------------------
-- [条件] 指定技能是否已配置
skill_ent.is_config_name = function(name)
    for i = 0, 7 do
        local skill_id   = skill_unit.get_quick_skill_id_byidx(i)
        local skill_inf  = this.get_skill_info_by_id(skill_id)
        if not table.is_empty(skill_inf) then
            if skill_inf.name == name then
                return true
            end
        end
    end
    return false
end

------------------------------------------------------------------------------------
-- [读取] 获取可设技能位置
skill_ent.get_can_config_pos = function()
    local pos     = -1
    local quick   = this.get_can_set_quick_res()
    -- 技能记录 如果技能记录次数大于1 则重复
    local skill_i = {}
    for i = 0, 7 do
        local skill_id   = skill_unit.get_quick_skill_id_byidx(i)
        local skill_inf  = this.get_skill_info_by_id(skill_id)
        local is_can_set = true
        if not table.is_empty(skill_inf) then
            for name,v in pairs(quick) do
                if name == skill_inf.name then
                    is_can_set = false
                    skill_i[name] = not skill_i[name] and 1 or skill_i[name] + 1
                    if skill_i[name] > 1 then
                        is_can_set = true
                    end
                    break
                end
            end
        end
        if is_can_set then
            pos = i
            break
        end
    end
    return pos
end

------------------------------------------------------------------------------------
-- 自动升级技能
function skill_ent.auto_up_skill()
    -- 在副本中不升级技能
    if actor_unit.is_dungeon_map() then
        return
    end
    local skill_data = skill_res.SKILL_INFO
    for skill_name, v in pairs(skill_data) do
        while decider.is_working() do
            if local_player:is_battle() then
                return
            end
            -- 获取技能点数
            local skill_num = skill_unit.get_remain_point()
            if skill_num < 1 then
                return
            end
            -- 通过技能名字获取技能信息
            local skill_info = skill_ent.get_skill_info_by_name(skill_name)
            if table.is_empty(skill_info) then
                break
            end
            if skill_info.cd_time > 0 then
                break
            end
            if skill_info.level >= v.skill_level then
                break
            end
            if skill_info.up_next_level_point > skill_num then
                break
            end
            common.wait_loading_map()
            trace.output('技能【'..skill_name..'】加到'..math.floor(skill_info.level + 1))
            skill_unit.upgrade_skill(skill_info.id, skill_info.level + 1)
            decider.sleep(2000)
        end
    end
end

------------------------------------------------------------------------------------
-- [读取] 获取职业 [根据技能甄别职业名]
function skill_ent.get_job()
    for skill_name,job in pairs(skill_res.SKILL_JOB) do
        if not table.is_empty(this.get_skill_info_by_name(skill_name)) then
            return job.name,job.use_z
        end
    end
    return '',90
end

------------------------------------------------------------------------------------
-- 通过技能名字获取技能信息
function skill_ent.get_skill_info_by_name(skill_name)
    local ret = {}
    local list = skill_unit.list()
    for i = 1, #list do
        local obj = list[i]
        if skill_ctx:init(obj) and skill_ctx:name() == skill_name then
            ret.obj = obj
            ret.name = skill_name
            ret.id = skill_ctx:id()
            ret.level = skill_ctx:level()
            ret.cd_time = skill_ctx:cd_time()
            ret.consume_mp = skill_ctx:consume_mp()
            ret.res_ptr = skill_ctx:res_ptr()
            ret.up_next_level_point = skill_ctx:up_next_level_point()
            break
        end
    end
    return ret
end

------------------------------------------------------------------------------------
-- 通过技能id获取技能信息
function skill_ent.get_skill_info_by_id(skill_id)
    local ret = {}
    local list = skill_unit.list()
    for i = 1, #list do
        local obj = list[i]
        if skill_ctx:init(obj) and skill_ctx:id() == skill_id then
            ret.obj = obj
            ret.name = skill_ctx:name()
            ret.id = skill_id
            ret.level = skill_ctx:level()
            ret.cd_time = skill_ctx:cd_time()
            ret.consume_mp = skill_ctx:consume_mp()
            ret.res_ptr = skill_ctx:res_ptr()
            ret.up_next_level_point = skill_ctx:up_next_level_point()
            break
        end
    end
    return ret
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function skill_ent.__tostring()
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
function skill_ent.__newindex(t, k, v)
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
skill_ent.__index = skill_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function skill_ent:new(args)
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
    return setmetatable(new, skill_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return skill_ent:new()

-------------------------------------------------------------------------------------
