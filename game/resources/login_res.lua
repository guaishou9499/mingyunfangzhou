-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   login_res
-- @describe: 登陆模块用到的资源
-- @version:  v1.0

local main_ctx = main_ctx
local configer = import('base/configer')
-------------------------------------------------------------------------------------
-- 登陆模块资源
---@class login_res
local login_res = {
    -- 创建角色后下线[0关闭  1开启]
    END_GAME_OFTER_CREATE           = 0,
    -- 可创建角色职业
    CAN_CREATE_JOB = {
        ['战士']      = false,
        ['射手']      = false,
        ['术士']      = false,
        ['格斗家']     = false,
        ['魔法师']     = true,
    },
    -- 创建角色
    CREATE_JOB                      = main_ctx:c_job(),
    -- 命运方舟                                         TODO:缺少排队命令
    STATUS_SERVER_SELECT_PAGE       = 0x800,        -- 服务器选择页面   3.0
    STATUS_CHARACTER_SELECT         = 0x4005,       -- 选择角色进入游戏界面  5.0
    STATUS_CREATE_CHARACTER         = 0x40005,      -- 创建角色选择职业  5.0
    STATUS_CREATE_NAME              = 0x20005,      -- 创建角色决定外形  5.0
    STATUS_IN_GAME                  = 0x100009,     -- 进入游戏界面
    STATUS_IN_GAME2                 = 0X8,          -- 加载地图1
    STATUS_LOADING_MAP              = 0x200009,     -- 加载地图2

    -- 职业信息
    JOP_INFO = {
        ['战士']      =  {
            job_id = 0x65,
            info   = {

            },
        },
        ['射手']      = {
            job_id = 0x1F5,
        },
        ['术士']      = {
            job_id = 0x259,
        },
        ['格斗家']     = {
            job_id = 0x1D2,
        },
        ['魔法师']     = {
            job_id = 0xC9,
        },
        ['潜伏者']     = {
            job_id = 0x191,
        },
    },
}


local this = login_res

-------------------------------------------------------------------------------------
-- 是否为可创建的职业
login_res.can_create_job = function(job_name)
    return this.CAN_CREATE_JOB[job_name]
end

-------------------------------------------------------------------------------------
-- 是否为可创建的职业 选择职业(战士0x65 法师0xC9  格斗0x1D2, 射手：0x1F5  巫师0x259  潜伏者 0x191)
login_res.job_by_id = function(job_name)
    local job_id = 0
    if job_name == '战士' then
        job_id = 0x65
    elseif job_name == '魔法师' then
        job_id = 0xC9
    elseif job_name == '格斗家' then
        job_id = 0x1D2
    elseif job_name == '射手' then
        job_id = 0x1F5
    elseif job_name == '术士' then
        job_id = 0x259
    elseif job_name == '潜伏者' then
        job_id = 0x191
    end
    return job_id
end

--默认进入游戏角色序号
login_res.player_idx = function()
    local idx = configer.get_user_profile_today('角色选择', '选择角色序号')
    xxmsg('选择角色序号'..idx)
    if idx == '' then
        idx = 0
    end
    idx = tonumber(idx)
    return idx
end
-------------------------------------------------------------------------------------
-- 返回对象
return login_res

-------------------------------------------------------------------------------------