------------------------------------------------------------------------------------
-- game/entities/actor_ent.lua
--
-- 这个模块主要是项目内周围环境相关功能操作。
--
-- @module      actor_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local actor_ent = import('game/entities/actor_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class actor_ent
local actor_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION      = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE  = '2023-03-22 - Initial release',
    -- 模块名称
    MODULE_NAME  = 'actor_ent module',
    -- 只读模式
    READ_ONLY    = false,
    -- 1玩家 2怪 3NPC4地面物品 6任务采集物品
    -- 玩家
    OTHER_PLAYER = 1,
    -- 怪物
    GAME_MONSTER = 2,
    -- npc
    GAME_NPC     = 3,
    -- 采集类
    GAME_GATHER  = 4,
    -- 地面物品
    -- 任务采集物品
    -- 其他怪物类型
    --6.   name:混沌裂痕
    --6.   name:战斗道具箱子
    --6.   name:继承星辰护卫意志
    --6.   小岛类obj:D1CA13C0  dist:211.8 is_move:   name:扭曲次元岛
    --7.   name:龟裂之核
}

-- 实例对象
local this = actor_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
---@type common
local common       = common
local pairs        = pairs
local table        = table
local ipairs       = ipairs
local math         = math
local rawset       = rawset
local setmetatable = setmetatable
local item_unit    = item_unit
local actor_unit   = actor_unit
local import       = import
local local_player = local_player
local utils        = import('base/utils')
local actor_res    = import('game/resources/actor_res')
local item_ent     = import('game/entities/item_ent')
local music_ent    = import('game/entities/music_ent')
local ui_ent       = import('game/entities/ui_ent')

------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
actor_ent.super_preload = function()

end

------------------------------------------------------------------------------------
-- [行为] 复活角色[使用时调用此命令]1原地 2就近
------------------------------------------------------------------------------------
actor_ent.check_dead = function(set_rise)
    local rise_type = 0
    local last_posX = 0
    local last_posY = 0
    local last_posZ = 0
    while decider.is_working() do
        -- 角色未死返回
        if not local_player:is_dead() then
            break
        end
        -- 默认复活点复活
        set_rise = set_rise or actor_res.need_stay_rise() and 1 or 2
        -- 设置原地复活 但不存在羽毛则 复活点复活
        if set_rise == 1 and  item_unit.get_money_byid(6) == 0 then
            set_rise = 2
        end
        if item_ent.is_need_repair_equip(5,0.01) then
            set_rise = 2
        end
        if set_rise == 2 then
            last_posX,last_posY,last_posZ = local_player:cx(),local_player:cy(),local_player:cz()
        end
        rise_type = set_rise
        -- 检测死亡UI是否存在
        if ui_ent.is_find_deadSceneWnd() then
            local str = rise_type == 1 and '原地' or rise_type == 2 and '就近' or '未知'
            trace.output('执行复活（'..str..'）')
            -- 等待6秒缓冲执行复活
            common.wait_show_str('执行复活（'..str..'）',6)
            if local_player:is_dead() then
                actor_unit.rise_man(set_rise)
            end
        else
            trace.output('未发现复活UI')
        end
        decider.sleep(2000)
    end
    if rise_type >= 2 and not actor_res.not_wait_time_m() then
        common.wait_show_str('就近复活后等待',5)
    end
    -- xxmsg('rise_type:'..rise_type)
    if rise_type ~= 0 and ( rise_type == 2 and actor_unit.is_dungeon_map() or item_ent.is_need_repair_equip(5,0.01) ) then
        -- 周围怪物数量
        if this.get_actor_num_by_pos(nil,nil,nil,500,2) == 0 then
            if item_ent.is_need_repair_equip(2,0.01) or item_ent.is_need_repair_equip(5,0.01)  then
                music_ent.use_music_by_name('逃离之歌')
            end
        end
    end
    return rise_type,last_posX,last_posY
end

------------------------------------------------------------------------------------
-- 读取附近奶球
actor_ent.get_can_gather_add_hp_info = function()
    local info_list = this.get_actor_info_list(6,'dist','name','type_seven_status','can_gather','cx','cy','cz')
    if not table.is_empty(info_list) then
        table.sort(info_list,function(a, b) return a.dist < b.dist end)
        for _,v in pairs(info_list) do
            if v.type_seven_status == 1 and v.name ~= '战斗道具箱子' and v.name ~= '继承星辰护卫意志' and v.dist < 1500 then
                return v
            end
        end
    end
    return {}
end

------------------------------------------------------------------------------------
-- [读取] 获取角色位置信息
actor_ent.get_local_pos = function()
    local info = this.get_actor_info_by_name(local_player:name(),this.OTHER_PLAYER)
    if not table.is_empty(info) then
        return info.cx,info.cy,info.cz
    end
    return 0,0,0
end

------------------------------------------------------------------------------------
-- [读取] 获取角色战斗状态
actor_ent.is_battle = function()
    local info = this.get_actor_info_by_name(local_player:name(),this.OTHER_PLAYER)
    if not table.is_empty(info) then
        return info.is_battle
    end
    return false
end

------------------------------------------------------------------------------------
-- [读取] 根据NPC名称获取指定NPC res_id
--
-- @tparam      string      name        NPC名称
-- @treturn     number                  返回NPC res_id
------------------------------------------------------------------------------------
actor_ent.get_npc_res_id = function(name)
    local info = this.get_actor_info_by_name(name, this.GAME_NPC)
    return not table.is_empty(info) and info.res_id or 0
end

------------------------------------------------------------------------------------
-- [读取] 根据NPC名称获取指定NPC ID
--
-- @tparam      string      name        NPC名称
-- @treturn     number                  返回NPC ID
------------------------------------------------------------------------------------
actor_ent.get_npc_id = function(name)
    local info = this.get_actor_info_by_name(name, this.GAME_NPC)
    return not table.is_empty(info) and info.id or 0
end

------------------------------------------------------------------------------------
-- [读取] 根据NPC名称获取指定NPC信息
--
-- @tparam      string      name        NPC名称
-- @treturn     table                   返回NPC信息表
------------------------------------------------------------------------------------
actor_ent.get_npc_info = function(name)
    local info = this.get_actor_info_by_name(name, this.GAME_NPC)
    return info
end

------------------------------------------------------------------------------------
-- [读取] 根据NPC名称获取指定NPC最近信息
--
-- @tparam      string      name        NPC名称
-- @treturn     table                   返回NPC信息表
------------------------------------------------------------------------------------
actor_ent.get_nearest_npc_info_for_list = function(name)
    local info_list = this.get_actor_list_by_list_any(name, 'name',this.GAME_NPC)
    if not table.is_empty(info_list) then
        table.sort(info_list,function(a, b) return a.dist < b.dist end)
        local info = info_list[1]
        if not info.npc_can_talk then
            for _,v in pairs(info_list) do
                if v.npc_can_talk then
                    info = v
                    break
                end
            end
        end
        return info
    end
    return {}
end

------------------------------------------------------------------------------------
-- [读取] 根据NPC名称获取指定NPC信息【多个集合】
--
-- @tparam      string      name        NPC名称
-- @treturn     table                   返回NPC信息表
------------------------------------------------------------------------------------
actor_ent.get_npc_info_list = function(name)
    local info_list = this.get_actor_list_by_list_any(name, 'name',this.GAME_NPC)
    return info_list
end

------------------------------------------------------------------------------------
-- [读取] 根据怪物名称获取指定怪物信息
--
-- @tparam      string      name        怪物名称
-- @treturn     table                   返回怪物信息表
------------------------------------------------------------------------------------
actor_ent.get_monster_info = function(name)
    local info = this.get_actor_info_by_name(name, this.GAME_MONSTER)
    return info
end

------------------------------------------------------------------------------------
-- [读取] 根据资源ID获取指定对象信息
--
-- @tparam      string      res_id      对象资源ID
-- @treturn     table                   返回对象信息表
------------------------------------------------------------------------------------
actor_ent.get_actor_info_by_res_id = function(res_id,obj_type)
    local info = this.get_actor_info_by_any(res_id, 'res_id', obj_type)
    return info
end

------------------------------------------------------------------------------------
-- [读取] 根据名称获取指定对象信息
--
-- @tparam      string      name      对象资源ID
-- @treturn     table                 返回对象信息表
------------------------------------------------------------------------------------
actor_ent.get_actor_info_by_name = function(name,obj_type)
    local info = this.get_actor_info_by_any(name, 'name', obj_type)
    return info
end

------------------------------------------------------------------------------------
-- [读取] 获取范围内多种类型对象信息距离角色最近
-- kill_list = { { name = '副头目玛戈',type = 2,res_id = 0,x = 0,y = 0,r = 0 },{ name = '青爪团成员',type = 2,res_id = 0 } }
actor_ent.get_actor_info_list_by_rad_pos_and_list = function(kill_list,x,y,r,calc_z)
    if not table.is_empty(kill_list) then
        -- 获取需要击杀最近怪物信息
        local kill_info   = {}
        -- 需要优先击杀的对象
        local kill_pir    = {}
        -- 标记目标是否已记录
        local insert_tab  = {}
        for _,v in pairs(kill_list) do
            local name     = v.name or ''
            local obj_type = v.type or 2
            local res_id   = v.res_id
            x              = v.x or x
            y              = v.y or y
            r              = v.r or r
            local seven_st = v.type_seven_status
            local filter   = v.filter or {}
            local filter_g = actor_res.FILTER_MONSTER
            -- 优先击杀设置
            local pri_clean= v.pri_clean
            table.move(filter_g,1,#filter_g,#filter + 1,filter)
            if res_id and res_id ~= 0 then
                name = res_id
            end
            -- xxmsg(string.format('%X',name)..' '..obj_type)
            local key_name  = ''
            if type(name) == 'table' then
                for _,v_name in pairs(name) do
                    key_name = v_name..key_name
                end
                key_name = key_name..obj_type
            else
                key_name = name..obj_type
            end
            if not insert_tab[key_name] then
                insert_tab[key_name] = true
                -- 获取指定对象信息
                local actor_info = this.get_nearest_self_actor_info_by_rad_pos(name,x,y,r,obj_type)
                if not table.is_empty(actor_info) and ( not calc_z or math.abs( local_player:cz() - actor_info.cz ) <= calc_z ) and not actor_info.is_dead then
                    local read = true
                    for _,a_name in pairs(filter) do
                        if string.find(actor_info.name,a_name) then
                            read = false
                            break
                        end
                    end
                    if read then
                        actor_info.type = obj_type
                        table.insert(kill_info,actor_info)
                        if pri_clean then
                            table.insert(kill_pir,actor_info)
                        end
                    end
                end
            end
        end
        if not table.is_empty(kill_info) then
            table.sort(kill_info,function(a, b) return a.dist < b.dist end)
            if not table.is_empty(kill_pir) then
                table.sort(kill_pir,function(a, b) return a.dist < b.dist end)
                return kill_pir[1],kill_pir
            end
            -- 获取指定对象信息
            return kill_info[1],kill_info
        end
    end
    return {},{}
end

------------------------------------------------------------------------------------
-- [读取] 获取范围内最大血量最高的对象
actor_ent.get_max_hp_actor_info_list_by_rad_pos = function(args,x,y,r,obj_type)
    obj_type        = obj_type or this.OTHER_PLAYER
    x               = x or local_player:cx()
    y               = y or local_player:cy()
    r               = r or 800
    local a_result  = {}
    local name      = local_player:name() --actor_obj:can_gather()
    local info_list = this.get_actor_info_list(obj_type,'name','id','cx','cy','cz','dist','hp','is_dead','max_hp','res_id','type_seven_status','is_valid','monster_can_attack','npc_can_talk','can_gather')
    if not table.is_empty(info_list) then
        for _,v in pairs(info_list) do
            if name ~= v.name and ( not args or args == '' or common.is_exist_list_arg( args,v.name ) or type(args) == 'number' and args == v.res_id )
                    and not v.is_dead and utils.is_inside_radius(v.cx, v.cy, x, y, r) then
                table.insert(a_result,v)
            end
        end
        table.sort(a_result,function(a, b) return a.max_hp > b.max_hp end)
    end
    return a_result
end

------------------------------------------------------------------------------------
-- [读取] 获取指定圆形范围内对象信息 每个对象包含范围内包含对象的数量[从多到少排序]
actor_ent.get_actor_info_list_by_rad_pos = function(args,x,y,r,obj_type,rad)
    obj_type        = obj_type or this.OTHER_PLAYER
    x               = x or local_player:cx()
    y               = y or local_player:cy()
    r               = r or 800
    rad             = rad or r
    local a_result  = {}
    local name      = local_player:name()
    local info_list = this.get_actor_info_list(obj_type,'name','id','cx','cy','cz','dist','hp','is_dead','max_hp','res_id','type_seven_status','is_valid','monster_can_attack','npc_can_talk','can_gather')
    if not table.is_empty(info_list) then
        for _,v in pairs(info_list) do
            if name ~= v.name and ( not args or args == '' or common.is_exist_list_arg( args,v.name ) or type(args) == 'number' and args == v.res_id )
                     and not v.is_dead and utils.is_inside_radius(v.cx, v.cy, x, y, r) then
                local result = v
                result.r_num = this.get_actor_num_by_pos(args,v.cx,v.cy,rad,obj_type,x,y,r)
                table.insert(a_result,result)
            end
        end
        table.sort(a_result,function(a, b) return a.r_num > b.r_num end)
    end
    return a_result
end

------------------------------------------------------------------------------------
-- [读取] 获取圆形范围内血量大于0 距离自身最近的怪物
actor_ent.get_nearest_self_actor_info_by_rad_pos = function(args,x,y,r,obj_type,calc_z)
    local best_info,all_list = this.get_nearest_actor_info_by_rad_pos(args,x,y,r,obj_type)

    if not table.is_empty(all_list) then
        calc_z = calc_z or math.huge
        table.sort(all_list,function(a, b) return a.dist < b.dist end)
        local z = local_player:cz()
        for i,v in pairs(all_list) do
            if math.abs(z - v.cz) <= calc_z
                    -- 是否需配对类型7
                    and ( not actor_res.CAN_READ_TYPE_SEVEN[v.res_id] or actor_res.CAN_READ_TYPE_SEVEN[v.res_id] and v.type_seven_status == 1 )
                    -- 是否需过滤的目标
                    and not common.is_exist_list_arg(actor_res.FILTER_MONSTER,v.name) then
                return all_list[i]
            end
        end
    end
    return best_info
end

------------------------------------------------------------------------------------
-- [读取] 获取圆形范围内血量大于0 距离中心点最近对象,所有对象信息
actor_ent.get_nearest_actor_info_by_rad_pos = function(args,x,y,r,obj_type,filter_info,wait_time)
    obj_type        = obj_type or this.OTHER_PLAYER
    x               = x or local_player:cx()
    y               = y or local_player:cy()
    r               = r or 800
    wait_time       = wait_time or 30 --采集过滤等待的时间
    local name      = local_player:name()

    local info_list = this.get_actor_info_list(obj_type,'name','id','cx','cy','cz','dist','hp','is_dead','max_hp','res_id','type_seven_status','is_valid','monster_can_attack','npc_can_talk','can_gather')
    local best_info = {}
    local best_dist = math.huge
    local all_list  = {}
    if not table.is_empty(info_list) then
        for _,v in pairs(info_list) do
            if name ~= v.name and ( not args or args == '' or common.is_exist_list_arg( args,v.name ) or type(args) == 'number' and args == v.res_id )
                    and not v.is_dead and utils.is_inside_radius(v.cx, v.cy, x, y, r) then
                local dist = utils.distance(x, y, v.cx, v.cy)
                if dist < best_dist then
                    best_dist = dist
                    best_info = v
                end
                -- xxmsg(args)
                table.insert(all_list,v)
            end
        end
    end
    if not table.is_empty(all_list) then
        local new_list = {}
        if #all_list > 1 then
            for _,v in pairs(all_list) do
                if not filter_info or filter_info and ( filter_info[v.obj] and os.time() - filter_info[v.obj] > 30 or not filter_info[v.obj] ) then
                    table.insert(new_list,v)
                end
            end
            all_list = {}
            all_list = new_list
            table.sort(all_list,function(a, b) return a.dist < b.dist end)
        end
    end
    return best_info,all_list
end

------------------------------------------------------------------------------------
-- [读取] 获取指定范围内最近NPC信息
actor_ent.get_nearest_actor_info_list = function()
    local info_list = this.get_actor_info_list(3,'name','id','cx','cy','cz','dist','res_id','npc_can_talk')
    if not table.is_empty(info_list) then
        table.sort(info_list,function(a, b) return a.dist < b.dist end)
    end
    return info_list
end

------------------------------------------------------------------------------------
-- [读取] 获取指定范围内类型6信息
actor_ent.get_nearest_gather_info_list = function(g_type,res_id)
    g_type = g_type or 6
    local info_list = this.get_actor_info_list(g_type,'dist','res_id','is_valid','can_gather','cx','cy','cz')
    if not table.is_empty(info_list) then
        table.sort(info_list,function(a, b) return a.dist < b.dist end)
        for _,v in pairs(info_list) do
            if v.can_gather and v.is_valid and ( not res_id or res_id and res_id == v.res_id ) then
                return v
            end
        end
    end
    return {}
end

------------------------------------------------------------------------------------
-- [读取] 获取指定范围内对象数
------------------------------------------------------------------------------------
actor_ent.get_actor_num_by_pos = function(args,x,y,r,obj_type,cen_x,cen_y,cen_r)
    obj_type        = obj_type or this.OTHER_PLAYER
    local num       = 0
    x               = x or local_player:cx()
    y               = y or local_player:cy()
    r               = r or 800
    local name      = local_player:name()
    local info_list = this.get_actor_info_list(obj_type,'name','cx','cy','cz','dist','hp','is_dead','max_hp')
    if not table.is_empty(info_list) then
        for _,v in pairs(info_list) do
            if name ~= v.name
                    and ( not args or args == '' or common.is_exist_list_arg( args,v.name ) )
                    and not v.is_dead and ( not cen_x or cen_x and cen_y and cen_r
                    and utils.is_inside_radius(v.cx, v.cy, cen_x,cen_y, cen_r) )
                    and utils.is_inside_radius(v.cx, v.cy, x, y, r) then
                num = num + 1
            end
        end
    end
    return num
end

------------------------------------------------------------------------------------
-- [读取] 根据环境对象任意字段或多个字段值返回包含对象信息的所有对象表
------------------------------------------------------------------------------------
actor_ent.get_actor_list_by_list_any = function(args, any_key, actor_type)
    actor_type      = actor_type or 0
    local r_tab     = {}
    local list      = actor_unit.list(actor_type)
    local actor_obj = actor_unit:new()
    for _, obj in ipairs(list) do
        if actor_obj:init(obj) then
            -- 获取指定属性的值
            local _any       = actor_obj[any_key](actor_obj)
            local name       = actor_obj:name()
            local can_attack = actor_obj:monster_can_attack()
            local res_id     = actor_obj:res_id()
            local need       = common.is_exist_list_arg( actor_res.NOT_FILTER_TYPE_7,res_id )
            local ins        = actor_type == 7 and ( need or not need and actor_obj:type_seven_status() > 0 ) or actor_type ~= 7
            ins              = actor_type == 2 and can_attack or actor_type ~= 2 and ins or false
            local can_kill1  = common.is_exist_list_arg( actor_res.CAN_ATT_ERROR_M,name )
            if can_kill1 and actor_type == 2 and not can_attack then
                ins = true
            end
            local can_kill   = common.is_exist_list_arg( actor_res.CAN_KILL_VALID,res_id )
            if can_kill then
                if not actor_obj:is_valid() then
                    ins = false
                end
            end
            -- 当前对象 是否需获取的目标
            if ins and common.is_exist_list_arg( args,_any ) then
                local result = {
                    -- 对象指针
                    obj            = obj,
                    -- 对象ID
                    id             = actor_obj:id(),
                    -- 对象名称
                    name           = name,
                    -- 对象资源ID
                    res_id         = res_id, --类型6和 NPC 都有的 固困ID
                    -- 对象类型名称
                    cls_name       = actor_obj:cls_name(),
                    -- 对象等级
                    level          = actor_obj:level(),
                    -- 对象坐标x
                    cx             = actor_obj:cx(),
                    -- 对象坐标y
                    cy             = actor_obj:cy(),
                    -- 对象坐标z
                    cz             = actor_obj:cz(),
                    -- 对象距离
                    dist           = actor_obj:dist(),
                    -- 对象是否死亡
                    is_dead        = actor_obj:is_dead(),
                    -- 是否在战斗
                    is_battle      = actor_obj:is_battle(),
                    -- 当前血量
                    hp             = actor_obj:hp(),
                    -- 最大血量
                    max_hp         = actor_obj:max_hp(),
                    -- 对象是否移动
                    is_move        = actor_type == 1 and actor_obj:is_move() or false,
                    -- 怪物是否可攻击
                    can_attack     = actor_type == 2 and actor_obj:monster_can_attack() or false,
                    -- 类型6采集类是否有效的，，门之类的不能用这（门之类的用资源ID做静太资源 ）
                    is_valid       = actor_obj:is_valid(),
                    -- 类型是否有效显示
                    type_seven_status = actor_obj:type_seven_status(),
                    -- 是否可对话
                    npc_can_talk      = actor_type == 3 and actor_obj:npc_can_talk() or false,
                    -- 是否可采集
                    can_gather        = common.is_exist_list_arg( actor_res.GATHER_TYPE,actor_type ) and actor_obj:can_gather() or false
                }
                table.insert( r_tab, result )
            end
        end
    end
    actor_obj:delete()
    return r_tab
end

------------------------------------------------------------------------------------
-- [读取] 获取所有actor数据 【 1 玩家 3 npc 2 怪物 ...】
--
-- @tparam   number     actor_type        读取类型
-- @tparam：可变参数 读取的字段
-- @treturn  table                        包含指定目标属性的表
------------------------------------------------------------------------------------
actor_ent.get_actor_info_list = function(actor_type,...)
    actor_type       = actor_type or 0
    local ret        = {}
    local unit_list  = actor_unit.list(actor_type)
    local actor_obj  = actor_unit:new()
    for _,obj in pairs(unit_list) do
        if actor_obj:init(obj) then
            local res_id     = actor_obj['res_id'](actor_obj)
            local name       = actor_obj:name()
            local need       = common.is_exist_list_arg( actor_res.NOT_FILTER_TYPE_7,res_id )
            local ins        = actor_type == 7 and ( need or not need and actor_obj:type_seven_status() > 0 ) or actor_type ~= 7
            ins              = actor_type == 9 and actor_obj:is_valid() or ins
            ins              = actor_type == 2 and actor_obj:monster_can_attack() or actor_type ~= 2 and ins or false
            local can_kill1  = common.is_exist_list_arg( actor_res.CAN_ATT_ERROR_M,name )
            if can_kill1 and actor_type == 2 and not actor_obj:monster_can_attack() then
                ins = true
            end
            local can_kill   = common.is_exist_list_arg( actor_res.CAN_KILL_VALID,res_id )
            if can_kill then
                if not actor_obj:is_valid() then
                    ins = false
                end
            end
            if ins then
                local result  = {}
                result['obj'] = obj
                for _,v in pairs({...} ) do
                    local can_set = true
                    -- 类型非采集类 时 不获取采集
                    if not common.is_exist_list_arg( actor_res.GATHER_TYPE,actor_type ) and v == 'can_gather' then
                        can_set = false
                    end
                    if actor_type ~= 3 and v == 'npc_can_talk' then
                        can_set = false
                    end
                    if actor_type ~= 1 and v == 'is_move' then
                        can_set = false
                    end
                    if actor_type ~= 2 and v == 'monster_can_attack' then
                        can_set = false
                    end
                    -- 获取指定属性的值
                    result[v] = can_set and actor_obj[v](actor_obj) or false
                end
                table.insert(ret,result)
            end
        end
    end
    actor_obj:delete()
    return ret
end

------------------------------------------------------------------------------------
-- [读取] 获取actor数据根据对象OBJ 【 1 玩家 3 npc 2 怪物 ...】
--
-- @tparam   number     actor_type        读取类型
-- @tparam：可变参数 读取的字段
-- @treturn  table                        包含指定目标属性的表
------------------------------------------------------------------------------------
actor_ent.get_actor_info_by_obj = function(obj,...)
    local result  = {}
    local actor_obj  = actor_unit:new()
    if actor_obj:init(obj) then
        result['obj'] = obj
        for _,v in pairs({...} ) do
            -- 获取指定属性的值
            result[v] = actor_obj[v](actor_obj) or false
        end
    end
    actor_obj:delete()
    return result
end

------------------------------------------------------------------------------------
-- [读取] 根据对象任意字段值返回对象信息表
------------------------------------------------------------------------------------
actor_ent.get_actor_info_by_any = function(args, any_key, actor_type)
    actor_type = actor_type or 0
    local result    = {}
    local list      = actor_unit.list(actor_type)
    local actor_obj = actor_unit:new()
    for _, obj in ipairs(list) do
        if actor_obj:init(obj) then
            -- 获取指定属性的值
            local _any   = actor_obj[any_key](actor_obj)
            local res_id = actor_obj:res_id()
            local name   = actor_obj:name()
            local need   = common.is_exist_list_arg( actor_res.NOT_FILTER_TYPE_7,res_id )
            local ins    = actor_type == 7 and ( need or not need and actor_obj:type_seven_status() > 0 ) or actor_type ~= 7
            ins          = actor_type == 2 and actor_obj:monster_can_attack() or actor_type ~= 2 and ins or false
            local can_kill   = common.is_exist_list_arg( actor_res.CAN_KILL_VALID,res_id )
            local can_kill1  = common.is_exist_list_arg( actor_res.CAN_ATT_ERROR_M,name )
            if can_kill1 and actor_type then
                ins = true
            end
            if can_kill then
                if not actor_obj:is_valid() then
                    ins = false
                end
            end
            -- 配对目标值
            if args == _any and ins then
                result = {
                    -- 对象指针
                    obj            = obj,
                    -- 对象ID
                    id             = actor_obj:id(),
                    -- 对象名称
                    name           = name,
                    -- 对象资源ID
                    res_id         = res_id, --类型6和 NPC 都有的 固困ID
                    -- 对象类型名称
                    cls_name       = actor_obj:cls_name(),
                    -- 对象等级
                    level          = actor_obj:level(),
                    -- 对象坐标x
                    cx             = actor_obj:cx(),
                    -- 对象坐标y
                    cy             = actor_obj:cy(),
                    -- 对象坐标z
                    cz             = actor_obj:cz(),
                    -- 对象距离
                    dist           = actor_obj:dist(),
                    -- 对象是否死亡
                    is_dead        = actor_obj:is_dead(),
                    -- 是否在战斗
                    is_battle      = actor_obj:is_battle(),
                    -- 当前血量
                    hp             = actor_obj:hp(),
                    -- 最大血量
                    max_hp         = actor_obj:max_hp(),
                    -- 对象是否移动
                    is_move        = actor_type == 1 and actor_obj:is_move() or false,
                    -- 怪物是否可攻击
                    can_attack     = actor_type == 2 and actor_obj:monster_can_attack() or false,
                    -- 类型6采集类是否有效的，，门之类的不能用这（门之类的用资源ID做静太资源 ）
                    is_valid       = actor_obj:is_valid(),
                    -- 类型是否有效显示
                    type_seven_status = actor_obj:type_seven_status(),
                    -- 是否可对话
                    npc_can_talk      = actor_type == 3 and actor_obj:npc_can_talk() or false,
                    -- 是否可采集
                    can_gather        = common.is_exist_list_arg( actor_res.GATHER_TYPE,actor_type ) and actor_obj:can_gather() or false
                }
                break
            end
        end
    end
    actor_obj:delete()
    return result
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function actor_ent.__tostring()
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
actor_ent.__newindex = function(t, k, v)
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
actor_ent.__index = actor_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function actor_ent:new(args)
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
    return setmetatable(new, actor_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return actor_ent:new()

-------------------------------------------------------------------------------------