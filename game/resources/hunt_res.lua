------------------------------------------------------------------------------------
-- game/resources/hunt_res.lua
--
--
--
-- @module      hunt_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local hunt_res = import('game/resources/hunt_res')
------------------------------------------------------------------------------------
---@class hunt_res
local hunt_res = {
    -- 生成redis中记录坐标
    CREATE_POS_LIST = {
        ['挂机坐标-1'] = {
            --1 = MAP：aaa,MID:3,X：14553,Y：-6708,Z：190,NLV：4,MLV：100,R：100,LINE：1,TIME：3
            'MAP：地图名,MID:3,X：14553,Y：-6708,Z：190,NLV：4,MLV：100,R：100,LINE：1,TIME：3',
        },
    }
}

-- 自身模块
local this = hunt_res

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return hunt_res

-------------------------------------------------------------------------------------