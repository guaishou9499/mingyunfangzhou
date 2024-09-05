-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2023-02-14
-- @module:   start
-- @describe: 入口文件
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
local main_ctx      = main_ctx
local is_exit       = is_exit
local sleep         = sleep
local import        = import
-- 引入管理对象
local core          = import('base/core')

-------------------------------------------------------------------------------------
-- LUA入口函数(正式 CTRL+F5)
function main()
	-- 预载处理
	core.preload()
	-- 主循环
	while not is_exit()
	do
		core.entry() -- 入口调用
		sleep(1000)
	end
	-- 卸载处理
	core.unload()
	-- main_ctx:set_action('脚本停止')
end

-------------------------------------------------------------------------------------
-- 定时器入口
function on_timer(timer_id)
	-- 分发到脚本管理
	-- core.on_timer(timer_id)
end

function main_test()
	local module_list = {
		import('game/modules/test')
	}
	core.set_module_list(module_list)
	core.entry() -- 入口调用
	-- 打开创建角色页面
	-- xxmsg(login_unit.pre_create_char())
	-- 选择职业
	--xxmsg(login_unit.select_class(0xC9))
	-- 创建角色
	--  xxmsg(login_unit.create_character(''))
	sleep(500)
	if ui_unit.has_dialog() then
	    sleep(500)
	    ui_unit.confirm_dialog(true)
	    sleep(1000)
	end
	-------------------------------------------------------
end