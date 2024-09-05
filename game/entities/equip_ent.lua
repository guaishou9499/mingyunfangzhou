------------------------------------------------------------------------------------
-- game/entities/equip_ent.lua
--
-- 实体示例
--
-- @module      equip_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local equip_ent = import('game/entities/equip_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class equip_ent
local equip_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME = 'equip_ent module',
    -- 只读模式
    READ_ONLY = false,
}

-- 实例对象
local this         = equip_ent
local decider      = decider
local import       = import
local trace        = trace
local table        = table
local setmetatable = setmetatable
local rawset       = rawset
local pairs        = pairs
local item_unit    = item_unit
---@type item_ent
local item_ent     = import('game/entities/item_ent')
---@type ui_ent
local ui_ent       = import('game/entities/ui_ent')
local equip_res    = import('game/resources/equip_res')

------------------------------------------------------------------------------------
-- [行为]自动佩戴装备
function equip_ent.ues_equip()
    local body_euqip = equip_res.BODY_EUQIP
    local check_close  = false
    for i = 1, #body_euqip do
        if not decider.is_working() then
            break
        end
        local pos      = body_euqip[i].pos
        local par      = body_euqip[i].par
        -- 获取背包装备评分最高的装备
       local bag_equip = item_ent.get_bast_equip_by_par(par)
        if not table.is_empty(bag_equip) then
            -- 获取身上装备评分最高装备
            local body_level = item_ent.get_equip_level_by_pos(pos)
            --  xxmsg(pos..' '..bag_equip.level..' '..bag_equip.name..' '..body_level)
            -- 背包装备等级 大于 身上评分等级
            if bag_equip.level > body_level then
                -- xxmsg('装备：'..bag_equip.name)
                if ui_ent.open_bag() then
                    check_close = true
                    item_unit.move_item(0,bag_equip.pos,1,pos)
                    decider.sleep(1000)
                end
            end
        end
    end
    if check_close then
        ui_ent.close_bag()
    end
end

------------------------------------------------------------------------------------
-- [行为] 自动使用生活工具
equip_ent.auto_use_life_equip = function()
    local info         = equip_res.LIFE_INFO
    local check_close  = false
    for _,v in pairs(info) do
        -- 获取生活技能栏装备信息
        local info     = item_ent.get_max_quality_life_info_by_pos(v.pos,2)
        -- 获取背包
        local bag_info = item_ent.get_max_quality_life_info_by_pos(v.pos,0)
        if not table.is_empty(bag_info) then
            local is_equip = true
            if not table.is_empty(info) then
                if info.quality > bag_info.quality then
                    is_equip = false
                elseif info.quality == bag_info.quality then
                    if info.durability >= bag_info.durability then
                        is_equip = false
                    end
                end
            end
            if is_equip then
                if ui_ent.open_bag() then
                    check_close = true
                    item_unit.move_item(0,bag_info.pos,0x15,v.pos)
                    decider.sleep(1000)
                end
            end
        end
    end
    if check_close then
        ui_ent.close_bag()
    end
end

-- 获取装备强化信息
-- 获取需要强化装备对应的消耗
-- 达成 返回 成长、精炼的操作
------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function equip_ent.__tostring()
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
function equip_ent.__newindex(t, k, v)
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
equip_ent.__index = equip_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function equip_ent:new(args)
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
    return setmetatable(new, equip_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return equip_ent:new()

-------------------------------------------------------------------------------------
