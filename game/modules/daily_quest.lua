-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   hunt
-- @describe: 日常任务检测单元
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
--
local daily_quest = {
    VERSION          = '20211016.28',
    AUTHOR_NOTE      = "-[daily_quest module - 20211016.28]-",
    MODULE_NAME      = '日常模块',
}

-- 自身模块
local this            = daily_quest
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
local import          = import
-------------------------------------------------------------------------------------
---@type login_res
local login_res       = import('game/resources/login_res')
---@type user_set_ent
local user_set_ent    = import('game/entities/user_set_ent')
---@type daily_quest_ent
local daily_quest_ent = import('game/entities/daily_quest_ent')
---@type quest_ent
local quest_ent       = import('game/entities/quest_ent')

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
        -- 返回是否可执行日常
        return daily_quest_ent.is_need_accept_day_task()
    end,
    -- [其它] 功能函数条件(可选)
    is_execute     = function()
        return true
    end,
}

-- 轮循函数列表
daily_quest.poll_functions = {}

------------------------------------------------------------------------------------
-- 预载函数(重载脚本时)
daily_quest.super_preload = function()

end

-------------------------------------------------------------------------------------
-- 预载处理
daily_quest.preload = function()
    -- 获取用户设置
    user_set_ent.load_user_info()
    settings.log_level        = 2
    settings.log_type_channel = 3
end


-------------------------------------------------------------------------------------
-- 轮循功能入口
daily_quest.looping = function()

end

-------------------------------------------------------------------------------------
-- 功能入口函数
daily_quest.entry = function()
    decider.sleep(2000)
    while decider.is_working()
    do
        common.wait_loading_map()
        quest_ent.finish_task()
        daily_quest_ent.open_daily_quest_wnd()
        local day_list = daily_quest_ent.get_daily_list()
        for _,name in pairs(day_list) do
            -- 接指定任务
            if not daily_quest_ent.acc_daily_quest(name,0) then
                trace.output('没有可接的日常资源')
            end
        end
        decider.sleep(2000)
    end
end

-------------------------------------------------------------------------------------
-- 模块超时处理
daily_quest.on_timeout = function()
    local status = game_unit.get_game_status_ex()
    -- 非排队状态时超时-重启
end

-------------------------------------------------------------------------------------
-- 定时调用入口
daily_quest.on_timer = function(timer_id)
    xxmsg('hunt.on_timer -> '..timer_id)
end

-------------------------------------------------------------------------------------
-- 卸载处理
daily_quest.unload = function()
    --xxmsg('login.unload')
end

-------------------------------------------------------------------------------------
-- 实例化新对象

function daily_quest.__tostring()
    return this.MODULE_NAME
end

daily_quest.__index = daily_quest

function daily_quest:new(args)
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
    return setmetatable(new, daily_quest)
end

-------------------------------------------------------------------------------------
-- 返回对象
return daily_quest:new()

-------------------------------------------------------------------------------------