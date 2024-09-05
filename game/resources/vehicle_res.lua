------------------------------------------------------------------------------------
-- game/resources/vehicle_res.lua
--
--
--
-- @module      坐骑资源
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local vehicle_res = import('game/resources/vehicle_res')
------------------------------------------------------------------------------------
local actor_unit  = actor_unit
local table       = table
local vehicle_res = {
    -- 优先上马顺序
    PRIORITY_RID = {
        '特尔佩恩','蓝色独角兽','尤狄亚白马','罗格希尔黑马','迪奥利卡褐马','寒霜狼','红色瓢虫','黄色瓢虫','蓝色瓢虫','绿色瓢虫','紫色瓢虫'
    },
    -- 指定地图只可上马信息
    NOT_RID_MAP = {
       ['摩可可村'] = { '红色瓢虫','黄色瓢虫','蓝色瓢虫','绿色瓢虫','紫色瓢虫' },
       ['丰饶森林'] = { '红色瓢虫','黄色瓢虫','蓝色瓢虫','绿色瓢虫','紫色瓢虫' },
    },
    -- 可上马的地图
    CAN_RID_MAP = {
        ['蓝风岛'] = true
    },
}

-- 自身模块
local this = vehicle_res

-------------------------------------------------------------------------------------
-- 获取当前地图可上马匹
vehicle_res.get_can_riding_by_curr_map = function()
    local map_name = actor_unit.map_name()
    local can_l    = this.NOT_RID_MAP[map_name]
    if not table.is_empty(can_l) then
        return can_l
    end
    return this.PRIORITY_RID
end

-------------------------------------------------------------------------------------
-- 获取可上马的特殊设置地图
vehicle_res.is_can_rid_in_special_map = function()
    local map_name = actor_unit.map_name()
    local can_l    = this.CAN_RID_MAP[map_name]
    return can_l
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return vehicle_res

-------------------------------------------------------------------------------------