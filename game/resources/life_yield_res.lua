------------------------------------------------------------------------------------
-- game/resources/life_yield_res.lua
--
--
--
-- @module      生活资源
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local life_yield_res = import('game/resources/life_yield_res')
------------------------------------------------------------------------------------
local skill_unit = skill_unit

---@class life_yield_res
local life_yield_res = {
    -- 生活技能信息-对应ID序号
    LIFE_SKILL_INFO = {
        ['植物采集'] = 1,
        ['伐木'] = 2,
        ['采矿'] = 3,
        ['狩猎'] = 4,
        ['钓鱼'] = 5,
        ['考古'] = 6,
    },
    -- 生活对象信息
    LIFE_OBJ_INFO = {
        ['植物采集'] = {},
        ['伐木'] = { { name = '',type = 6,res_id = 0x61613A9 } },
        ['采矿'] = { { name = '',type = 6,res_id = 0x61613A9 },{ name = '',type = 6,res_id = 0x6255571 } },
        ['狩猎'] = {},
        ['钓鱼'] = {},
        ['考古'] = {},
    },
}

-- 自身模块
local this = life_yield_res

-------------------------------------------------------------------------------------
-- [读取] 获取指定生活技能等级
life_yield_res.get_life_lv_by_name = function(name)
    local info = life_yield_res.LIFE_SKILL_INFO[name]
    if info then
        return skill_unit.get_life_skill_lv(info)
    end
    return -1
end

-------------------------------------------------------------------------------------
-- [读取] 获取生活目标对应信息
life_yield_res.get_life_obj = function(name)
    local info = life_yield_res.LIFE_OBJ_INFO[name]
    return info
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return life_yield_res

-------------------------------------------------------------------------------------