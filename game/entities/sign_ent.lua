------------------------------------------------------------------------------------
-- game/entities/sign_ent.lua
--
-- 签到
--
-- @module      sign_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local sign_ent = import('game/entities/sign_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class sign_ent
local sign_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE             = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME             = 'sign_ent module',
    -- 只读模式
    READ_ONLY               = false,
    -- 开启签到
    IS_OPEN_SIGN            = true,
}

-- 实例对象
local this         = sign_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local common       = common
local setmetatable = setmetatable
local pairs        = pairs
local rawset       = rawset
local sign_unit    = sign_unit
local ui_unit      = ui_unit
local local_player = local_player
local actor_unit   = actor_unit
local import       = import
local user_set_ent = import('game/entities/user_set_ent')
local map_res      = import('game/resources/map_res')
local sign_res     = import('game/resources/sign_res')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function sign_ent.super_preload()

end

------------------------------------------------------------------------------------
-- [行为] 签到
sign_ent.execute_sign = function()
    -- 等级小于11 或者 在地牢中 返回
    if local_player:level() < 11 or actor_unit.is_dungeon_map() and not map_res.is_in_islet() or not this.IS_OPEN_SIGN then
        return false
    end
    if common.is_sleep_any('check_execute_sign',3600) then
        -------------------------------------------------------------------------------------
        -- UI页面签到
        local sign_main_type_num = sign_unit.get_main_sign_type_num()
        for i = 0, sign_main_type_num - 1 do
            -- 序号取是否有可签到物品（目前只有1个）
            if sign_unit.can_sign_by_idx(i) then
                if not decider.is_working() then
                    break
                end
                trace.output('签到')
                -- 取签道窗口
                if sign_unit.get_sign_wnd() == 0 then
                    -- 打开签到窗
                    sign_unit.open_sign_wnd()
                    decider.sleep(3000)
                end
                if sign_unit.get_sign_wnd() ~= 0 then
                    sign_unit.click_get_all_reward(i)
                    decider.sleep(2000)
                    if ui_unit.has_dialog() then
                        decider.sleep(500)
                        ui_unit.confirm_dialog(true)
                        decider.sleep(1000)
                    end
                end
            end
        end
        -------------------------------------------------------------------------------------
        -- 热点签到
        for i = 0, 5 do
            if not decider.is_working() then
                break
            end
            --判断是否可领取(目前主ID是1， 序号0-5) 状态：0 可领取 3是没激活 1 已领取 -1 不存在的序号
            if sign_unit.get_hot_sign_status(1, i) == 0 then
                trace.output('领取热点签到-',i)
                -- 领取热点签到(目前主ID是1， 序号0-5)
                sign_unit.get_hot_sign_reward(1, i)
                decider.sleep(2000)
            end
        end
        -------------------------------------------------------------------------------------
        -- 方舟通行证领取
        -- this.execute_ark_pass_reward()
    end
end

-------------------------------------------------------------------------------------
-- 方舟通行证领取
function sign_ent.execute_ark_pass_reward()
    local leading_idx  = user_set_ent['主角序号']
    if trace.ROLE_IDX ~= leading_idx and leading_idx ~= 0 then
        return false
    end
    -- 取通行证等级
    local ark_pass_level =  actor_unit.get_ark_pass_level()
    for  i = 1, ark_pass_level do
        if not decider.is_working() then
            break
        end
        -- xxmsg(actor_unit.ark_pass_reward_is_receive(i))
        -- 判断对应等级通行证奖励是否领取
        if not actor_unit.ark_pass_reward_is_receive(i) then
            local ark_info = sign_res.ARK_INFO[i]
            trace.output('领取',i,'级:',ark_info.name)
            -- 领取指定等级等通行证奖励(第一个奖是0，第二个是1)
            actor_unit.get_ark_pass_reward(i, ark_info.idx or 0)
            decider.sleep(2000)
        end
    end
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function sign_ent.__tostring()
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
function sign_ent.__newindex(t, k, v)
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
sign_ent.__index = sign_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function sign_ent:new(args)
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
    return setmetatable(new, sign_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return sign_ent:new()

-------------------------------------------------------------------------------------
