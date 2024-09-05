-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2023-2-10
-- @module:   login
-- @describe: 登陆单元
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
---@class login_ent
local login_ent = {
    VERSION     = '20230301',
    AUTHOR_NOTE = '-[login ent - 20230301]-',
    MODULE_NAME = '登陆单元',
}
local decider         = decider
local trace           = trace
-- 自身模块
local this            = login_ent
local main_ctx        = main_ctx
local login_unit      = login_unit
local game_unit       = game_unit
local ui_unit         = ui_unit
---@type login_res
local login_res       = import('game/resources/login_res')
local configer        = import('base/configer')
---@type switch_user_ent
local switch_user_ent = import('game/entities/switch_user_ent')

------------------------------------------------------------------------------------
-- [行为] 选择服务器
------------------------------------------------------------------------------------
login_ent.enter_select_character = function()
    local config_server_name = main_ctx:c_server_name()
    local server_status      = login_unit.get_server_status(config_server_name)
    if server_status ~= -1 then
        -- 连接服务器
        login_unit.login_game_server(config_server_name)
        trace.output('选择大区【'.. config_server_name .. '】进入游戏')
        decider.sleep(1000)
        login_ent.wait_to_status({ login_res.STATUS_CHARACTER_SELECT,login_res.STATUS_CREATE_CHARACTER },'1.等待进入角色选择界面')
    else
        main_ctx:set_action('选择的大区【'.. config_server_name .. '】不可进入')
        decider.sleep(5000)
    end
end

------------------------------------------------------------------------------------
-- [行为] 执行创建角色
------------------------------------------------------------------------------------
login_ent.do_create_character = function()
    local job_name = login_res.CREATE_JOB
    if login_res.can_create_job(job_name) then
        local job_id = login_res.job_by_id(job_name)
        if job_id ~= 0 then
            trace.output('选择职业(',job_name,')')
            login_unit.select_class(job_id)
            decider.sleep(1000)
            login_ent.wait_to_status(login_res.STATUS_CREATE_NAME,'等待进入角色外观选择')
        else
            main_ctx:set_action('角色'..job_name..'获取id失败')
            decider.sleep(5000)
        end
    else
        main_ctx:set_action('角色'..job_name..'不是可创建的角色')
        decider.sleep(5000)
    end
end

------------------------------------------------------------------------------------
-- [行为] 执行创建角色
------------------------------------------------------------------------------------
login_ent.do_create_name = function()
    -- 起名创建角色
    if login_unit.create_character('') then
        trace.output('创建角色')
        decider.sleep(1500)
        login_ent.wait_to_status(login_res.STATUS_CHARACTER_SELECT,'2.等待进入角色选择界面')
        for i = 1,2 do
            if ui_unit.has_dialog() then
                ui_unit.confirm_dialog(true)
                decider.sleep(1000)
            end
        end
    end
    decider.sleep(1000)
end

------------------------------------------------------------------------------------
-- [行为] 选择角色进入游戏
login_ent.enter_game_ex = function()
    -- 写入角色序号
    switch_user_ent.write_role_idx_in_ini()
    local is_enter,idx,name = switch_user_ent.get_can_login_id()
    if is_enter then
        login_unit.pre_create_char()
        trace.output('进入角色创建界面')
        decider.sleep(1000)
        login_ent.wait_to_status(login_res.STATUS_CREATE_CHARACTER,'1.等待进入角色创建界面')
    else
        trace.output('选择['.. name ..']进入游戏')
        login_unit.enter_game(idx)
        decider.sleep(2000)
        login_ent.wait_to_status(login_res.STATUS_IN_GAME,'等待进入游戏')
    end
end

------------------------------------------------------------------------------------
-- [行为] 选择角色进入游戏
------------------------------------------------------------------------------------
login_ent.enter_game = function()
    -- 获取角色数量
    local char_count = login_unit.get_char_count()
    for i = 0, char_count -1
    do
        configer.set_user_profile_today('角色序号', login_unit.get_char_name(i),i)
        decider.sleep(1000)
    end
    xxmsg('获取角色数量'..char_count)
    if char_count == 0 then
        login_unit.pre_create_char()
        trace.output('进入角色创建界面')
        decider.sleep(1000)
        login_ent.wait_to_status(login_res.STATUS_CREATE_CHARACTER,'1.等待进入角色创建界面')
    else
        -- 判断是否创建完角色后下线
        if login_res.END_GAME_OFTER_CREATE == 1 then
            if char_count >= 6 then
                -- 标记完成结束游戏
                main_ctx:set_ex_state(1)
                decider.sleep(2000)
                main_ctx:end_game()
            else
                login_unit.pre_create_char()
                decider.sleep(2000)
                login_ent.wait_to_status(login_res.STATUS_CREATE_CHARACTER,'2.等待进入角色创建界面')
            end
        elseif login_res.END_GAME_OFTER_CREATE == 0 then
            -- 选择进入游戏的角色序号
            local  idx = login_res.player_idx()
            if idx >= 3 then
                -- 标记完成结束游戏
                main_ctx:set_ex_state(1)
                decider.sleep(2000)
                main_ctx:end_game()
            elseif char_count - 1 >= idx then
                trace.output('选择第'..idx..'个角色进入游戏')
                login_unit.enter_game(idx)
                decider.sleep(2000)
                login_ent.wait_to_status(login_res.STATUS_IN_GAME,'等待进入游戏')
            else
                login_unit.pre_create_char()
                decider.sleep(2000)
                login_ent.wait_to_status(login_res.STATUS_CREATE_CHARACTER,'3.等待进入角色创建界面')
            end
        end
    end
end

------------------------------------------------------------------------------------
-- [行为] 等待登陆排队
------------------------------------------------------------------------------------
login_ent.wait_for_login_queue = function()

end

------------------------------------------------------------------------------------
-- 等待进入指定界面
login_ent.wait_to_status = function(status, tips, timeout)
    local wait_status = 0

    if tips ~= nil then
        main_ctx:set_action(tips)
    end

    if timeout == nil then
        timeout = 60
    end

    local start_time = os.time()
    while decider.is_working()
    do
        if type(status) == 'table' then
            local game_status = game_unit.game_status()
            local break_ = false
            for i = 1, #status do
                if game_status == status[i] then
                    break_ = true
                    break
                end
            end
            if break_ then
                decider.sleep(3000)
                break
            end
        else
            if game_unit.game_status() == status then
                decider.sleep(3000)
                break
            end
        end
        if os.time() - start_time >= timeout then
            wait_status = -1
            break
        end
        decider.sleep(1000)
    end

    return wait_status
end

------------------------------------------------------------------------------------
-- 实例化新对象

function login_ent.__tostring()
    return this.MODULE_NAME
end

login_ent.__index = login_ent

function login_ent:new(args)
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
    return setmetatable(new, login_ent)
end

-------------------------------------------------------------------------------------
-- 返回对象
return login_ent:new()

-------------------------------------------------------------------------------------