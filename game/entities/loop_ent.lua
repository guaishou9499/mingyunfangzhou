------------------------------------------------------------------------------------
-- game/entities/loop_ent.lua
--
-- 轮巡功能的整合
--
-- @module      loop_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local loop_ent = import('game/entities/loop_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class loop_ent
local loop_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION          = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE      = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME      = 'loop_ent module',
    -- 只读模式
    READ_ONLY        = false,
}

-- 实例对象
local this           = loop_ent
-- 日志模块
local trace          = trace
-- 决策模块
local decider        = decider
local common         = common
local actor_unit     = actor_unit
local setmetatable   = setmetatable
local rawset         = rawset
local pairs          = pairs
local import         = import
---@type item_ent
local item_ent       = import('game/entities/item_ent')
---@type actor_ent
local actor_ent      = import('game/entities/actor_ent')
---@type ui_ent
local ui_ent         = import('game/entities/ui_ent')
---@type equip_ent
local equip_ent      = import('game/entities/equip_ent')
---@type shop_ent
local shop_ent       = import('game/entities/shop_ent')
---@type mail_ent
local mail_ent        = import('game/entities/mail_ent')
---@type skill_ent
local skill_ent      = import('game/entities/skill_ent')
---@type pet_ent
local pet_ent        = import('game/entities/pet_ent')
---@type sign_ent
local sign_ent       = import('game/entities/sign_ent')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function loop_ent.super_preload()

end

------------------------------------------------------------------------------------
-- 执行功能整合
function loop_ent.looping()
    common.wait_loading_map()
    -- 死亡检测
    actor_ent.check_dead()
    -- 动画检测
    ui_ent.esc_cinema()
    -- 人物正在抬物状态
    if actor_unit.get_local_player_status() == 4 then
        return
    end
    if actor_unit.map_id() == 10902 then
        return
    end
    -- 签到
    sign_ent.execute_sign()
    -- 领取邮件
    mail_ent.get_mail()
    -- 自动升级技能
    skill_ent.auto_up_skill()
    -- 自动配置技能
    skill_ent.config_skill()
    -- 自动加血
    item_ent.auto_use_hp_ex()
    -- 自动使用物品
    item_ent.auto_use_item()
    -- 自动加工使用飞翔石
    shop_ent.auto_process_use_marble()
    -- 自动装备
    equip_ent.ues_equip()
    -- 自动分解装备
    item_ent.decompose_equip()
    -- 自动修理装备
    shop_ent.repair_equip()
    -- 自动购买药品
    shop_ent.buy_potion()
    -- 自动精炼装备
    shop_ent.move_to_enhance_equip()
    -- 召唤宠物
    pet_ent.execute_summon_pet()
    -- 购买混沌碎片
    shop_ent.buy_item(nil,'混沌商人','觉醒：混沌碎片',100,20)
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function loop_ent.__tostring()
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
function loop_ent.__newindex(t, k, v)
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
loop_ent.__index = loop_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function loop_ent:new(args)
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
    return setmetatable(new, loop_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return loop_ent:new()

-------------------------------------------------------------------------------------
