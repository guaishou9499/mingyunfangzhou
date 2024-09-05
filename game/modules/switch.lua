-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   hunt
-- @describe: 切换
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
--
local switch = {
    VERSION          = '20211016.28',
    AUTHOR_NOTE      = "-[switch module - 20211016.28]-",
    MODULE_NAME      = '切换模块',
}

-- 自身模块
local this            = switch
-- 配置模块
local settings        = settings
-- 日志模块
local trace           = trace
local common          =  common
-- 决策模块
local decider         = decider
-- 优化列表
local game_unit       = game_unit
local setmetatable    = setmetatable
local pairs           = pairs
local table           = table
local import          = import
-------------------------------------------------------------------------------------
---@type login_res
local login_res       = import('game/resources/login_res')
---@type loop_ent
local loop_ent        = import('game/entities/loop_ent')
---@type user_set_ent
local user_set_ent    = import('game/entities/user_set_ent')
---@type switch_user_ent
local switch_user_ent = import('game/entities/switch_user_ent')

-------------------------------------------------------------------------------------
-- 运行前置条件
this.eval_ifs = {
    -- [启用] 游戏状态列表
    yes_game_state = { login_res.STATUS_IN_GAME , login_res.STATUS_LOADING_MAP , login_res.STATUS_IN_GAME2 },
    -- [禁用] 游戏状态列表
    not_game_state = { login_res.STATUS_CREATE_CHARACTER },
    -- [启用] 配置开关列表
    yes_config     = {},
    -- [禁用] 配置开关列表
    not_config     = {},
    -- [时间] 模块超时设置(可选)
    time_out       = 0,
    -- [其它] 特殊情况才用(可选)
    is_working     = function()
        -- 检测连接状态
        common.check_connect()
        -- 返回是否可执行
        return switch_user_ent.is_do_switch_user()
    end,
    -- [其它] 功能函数条件(可选)
    is_execute     = function()
        return true
    end,
}

-- 轮循函数列表
switch.poll_functions = {}

------------------------------------------------------------------------------------
-- 预载函数(重载脚本时)
switch.super_preload = function()

end

-------------------------------------------------------------------------------------
-- 预载处理
switch.preload = function()
    -- 获取用户设置
    user_set_ent.load_user_info()
    settings.log_level        = 2
    settings.log_type_channel = 3
end


-------------------------------------------------------------------------------------
-- 轮循功能入口
switch.looping = function()
    loop_ent.looping()
end

-------------------------------------------------------------------------------------
-- 功能入口函数
switch.entry = function()
    decider.sleep(2000)
    while decider.is_working()
    do
        -- 轮循功能
        this.looping()
        switch_user_ent.execute_switch()
        decider.sleep(5000)
    end
end

-------------------------------------------------------------------------------------
-- 模块超时处理
switch.on_timeout = function()
    local status = game_unit.get_game_status_ex()
    -- 非排队状态时超时-重启
end

-------------------------------------------------------------------------------------
-- 定时调用入口
switch.on_timer = function(timer_id)
    xxmsg('hunt.on_timer -> '..timer_id)
end

-------------------------------------------------------------------------------------
-- 卸载处理
switch.unload = function()
    --xxmsg('login.unload')
end

-------------------------------------------------------------------------------------
-- 实例化新对象

function switch.__tostring()
    return this.MODULE_NAME
end

switch.__index = switch

function switch:new(args)
    local new = { }

    -- 预载函数(重载脚本时)
    if this.super_preload then
        this.super_preload()
    end

    if args then
        for key, val in pairs(args) do
            new[key] = val
        end
    end

    -- 设置元表
    return setmetatable(new, switch)
end

-------------------------------------------------------------------------------------
-- 返回对象
return switch:new()

-------------------------------------------------------------------------------------