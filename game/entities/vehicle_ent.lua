------------------------------------------------------------------------------------
-- game/entities/vehicle_ent.lua
--
-- 坐骑单元
--
-- @module      vehicle_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local vehicle_ent = import('game/entities/vehicle_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class vehicle_ent
local vehicle_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE             = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME             = 'vehicle_ent module',
    -- 只读模式
    READ_ONLY               = false,
}

-- 实例对象
local this         = vehicle_ent
-- 日志模块
local trace        = trace
local common       = common
-- 决策模块
local decider      = decider
local setmetatable = setmetatable
local pairs        = pairs
local rawset       = rawset
local table        = table
local ship_unit    = ship_unit
local vehicle_unit = vehicle_unit
local actor_unit   = actor_unit
local local_player = local_player
local vehicle_res  = import('game/resources/vehicle_res')
local map_res      = import('game/resources/map_res')
local utils        = import('base/utils')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function vehicle_ent.super_preload()

end

----------------------------------------------------------------------------------------
-- [行为] 下马
function vehicle_ent.execute_down_riding()
    --   xxmsg('下马')
    local id = vehicle_unit.get_cur_riding_id()
    if this.is_riding() then
        vehicle_unit.riding(id)
        decider.sleep(1000)
    end
end

----------------------------------------------------------------------------------------
-- [条件] 是否在马上
function vehicle_ent.is_riding()
    if actor_unit.get_local_player_status() == 8 then
        return true
    end
    return false
end

----------------------------------------------------------------------------------------
-- [条件] 是否增加高度
function vehicle_ent.is_higth()
    if actor_unit.get_local_player_status() ~= 1 then
        return true
    end
    return false
end

----------------------------------------------------------------------------------------
-- [行为] 自动上马
function vehicle_ent.auto_riding_vehicle(actor_num,x,y)
    if x and y and local_player:dist_xy(x,y) < 1500 then
        return false
    end
    local is_ride = false
    local info    = vehicle_res.get_can_riding_by_curr_map()
    for _,name in pairs(info) do
        if this.riding_vehicle_name(name,actor_num) then
            is_ride = true
            break
        end
    end
end

----------------------------------------------------------------------------------------
-- [行为] 上马指定坐骑
function vehicle_ent.riding_vehicle_name(name,actor_num)
    if not this.is_can_riding(actor_num) then
        return false
    end
    local info = this.get_vehicle_info_by_name(name)
    if not table.is_empty(info) then
        -- 已在马 返回
        if info.is_ride then return true end
        --local v_id = vehicle_unit.get_cur_riding_id()
        --if vehicle_unit.is_riding(v_id) then
        --    vehicle_unit.riding(v_id)
        --    sleep(3000)
        --end
        common.wait_loading_map()
        trace.output('上马：',name)
        vehicle_unit.riding(info.id)
        decider.sleep(2000)
        return true
    end
    return false
end

----------------------------------------------------------------------------------------
-- [读取] 获取指定坐骑信息
function vehicle_ent.get_vehicle_info_by_name(name)
    local info_list = this.get_vehicle_info_list()
    for _,v in pairs(info_list) do
        if v.name == name then
            return v
        end
    end
    return {}
end

-------------------------------------------------------------------------------------
-- [条件] 是否可上马
vehicle_ent.is_can_riding = function(actor_num)
    -- 在指定可上马地图时
    if vehicle_res.is_can_rid_in_special_map() then
        return true
    end
    -- 在副本中 中断
    if actor_unit.is_dungeon_map() or local_player:is_battle() and not actor_num or actor_num and actor_num > 0 then
        return false
    end
    -- 在航海中
    if ship_unit.is_in_ocean() or ship_unit.is_open_anchor_frame() then
        return false
    end
    if utils.is_inside_quire(local_player:cx(), local_player:cy(), 8488, 5779, 500) then
        return false
    end
    -- 在指定的地图[不可上马]
    --for _,map in pairs(vehicle_res.NOT_RID_MAP) do
    --    if map == actor_unit.map_name() then
    --        return false
    --    end
    --end
    local main_map  = ''
    local area_name = ''
    local map_name  = actor_unit.map_name()
    local info = map_res.map_info[map_name]
    if info then
        local area_t  = info['场景区域']
        main_map      = info['所属大陆']
        local can_rid = area_t and area_t[actor_unit.get_cur_scene_map_name()] and area_t[actor_unit.get_cur_scene_map_name()]['上马']
        if area_t and not can_rid and area_t[actor_unit.get_cur_scene_map_name()] then
            area_name = actor_unit.get_cur_scene_map_name()
        end
    end
    -- 在场景中 中断
    if area_name ~= '' or  main_map == map_name then --or actor_unit.get_cur_scene_map_name() ~= ''
        return false
    end
    return true
end

----------------------------------------------------------------------------------------
-- [读取] 获取所有坐骑信息
function vehicle_ent.get_vehicle_info_list()
    local list        = vehicle_unit.list()
    local vehicle_obj = vehicle_unit:new()
    local ret         = {}
    for i = 1, #list do
        local obj = list[i]
        if vehicle_obj:init(obj) then
            local result = {
                obj     = obj,
                id      = vehicle_obj:id(),
                is_ride = vehicle_obj:is_ride(),
                name    = vehicle_obj:name(),
            }
            table.insert(ret,result)
        end
    end
    vehicle_obj:delete()
    -- 上下马
    -- vehicle_unit.riding(id)
    -- 是否骑行中
    -- vehicle_unit.is_riding()
    -- 当前骑马ID
    -- vehicle_unit.get_cur_riding_id()
    return ret
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function vehicle_ent.__tostring()
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
function vehicle_ent.__newindex(t, k, v)
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
vehicle_ent.__index = vehicle_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function vehicle_ent:new(args)
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
    return setmetatable(new, vehicle_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return vehicle_ent:new()

-------------------------------------------------------------------------------------
