-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   dungeon
-- @describe: 副本自动打怪
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
--
local dungeon_stars_guard = {
    VERSION           = '20211016.28',
    AUTHOR_NOTE       = "-[dungeon_stars_guard module - 20211016.28]-",
    MODULE_NAME       = '星辰副本模块',
}

-- 自身模块
local this            = dungeon_stars_guard
-- 配置模块
local settings        = settings
-- 日志模块
local trace           = trace
local common          = common
-- 决策模块
local decider         = decider
-- 优化列表
local game_unit       = game_unit
local hook_unit       = hook_unit
local setmetatable    = setmetatable
local pairs           = pairs
local import          = import
-------------------------------------------------------------------------------------
---@type dungeon_stars_guard_ent
local dungeon_stars_guard_ent = import('game/entities/dungeon_stars_guard_ent')
---@type login_res
local login_res               = import('game/resources/login_res')
---@type loop_ent
local loop_ent                = import('game/entities/loop_ent')

-------------------------------------------------------------------------------------
-- 运行前置条件
this.eval_ifs = {
    -- [启用] 游戏状态列表
    yes_game_state = { login_res.STATUS_IN_GAME , login_res.STATUS_LOADING_MAP , login_res.STATUS_IN_GAME2 },
    -- [禁用] 游戏状态列表
    not_game_state = { login_res.STATUS_CHARACTER_SELECT,login_res.STATUS_CREATE_CHARACTER },
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
        -- 返回是否可执行副本
        return dungeon_stars_guard_ent.can_in_stars_guard()
    end,
    -- [其它] 功能函数条件(可选)
    is_execute     = function()
        return true
    end,
}

-- 轮循函数列表
dungeon_stars_guard.poll_functions = {}

------------------------------------------------------------------------------------
-- 预载函数(重载脚本时)
dungeon_stars_guard.super_preload = function()

end

-------------------------------------------------------------------------------------
-- 预载处理
dungeon_stars_guard.preload = function()
    settings.log_level        = 2
    settings.log_type_channel = 3
end


-------------------------------------------------------------------------------------
-- 轮循功能入口
dungeon_stars_guard.looping = function()
    loop_ent.looping()
end

-------------------------------------------------------------------------------------
-- 功能入口函数
dungeon_stars_guard.entry = function()
    decider.sleep(2000)
    hook_unit.enable_mouse_screen_pos(true)
    while decider.is_working()
    do
        -- 执行轮循任务
        decider.looping()
        -- 开始星辰副本
        dungeon_stars_guard_ent.start_stars_guard()
        -- 适当延时(切片)
        decider.sleep(2000)
    end
    hook_unit.enable_mouse_screen_pos(false)
end

-------------------------------------------------------------------------------------
-- 模块超时处理
dungeon_stars_guard.on_timeout = function()
    local status = game_unit.get_game_status_ex()
    -- 非排队状态时超时-重启
end

-------------------------------------------------------------------------------------
-- 定时调用入口
dungeon_stars_guard.on_timer = function(timer_id)
    xxmsg('dungeon.on_timer -> '..timer_id)
end

-------------------------------------------------------------------------------------
-- 卸载处理
dungeon_stars_guard.unload = function()
    --xxmsg('login.unload')
end

-------------------------------------------------------------------------------------
-- 实例化新对象
function dungeon_stars_guard.__tostring()
    return this.MODULE_NAME
end

dungeon_stars_guard.__index = dungeon_stars_guard

function dungeon_stars_guard:new(args)
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
    return setmetatable(new, dungeon_stars_guard)
end

-------------------------------------------------------------------------------------
-- 返回对象
return dungeon_stars_guard:new()

-------------------------------------------------------------------------------------