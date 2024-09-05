-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   core
-- @email:    88888@qq.com
-- @date:     2021-11-03
-- @module:   common
-- @describe: 公共功能
-- @version:  v1.0
--

local VERSION = '20211103' -- version history at end of file
local AUTHOR_NOTE = "-[20211103]-"
---@class common
local common = {
	VERSION      = VERSION,
	AUTHOR_NOTE  = AUTHOR_NOTE,
	MODULE_NAME  = '公共功能',
	-- 金币ID
	GOLD_COIN    = 2,
	-- 铜钱
	COP_COIN     = 1
}
local this 			   = common
local decider  		   = decider
local trace            = trace
local sleep            = sleep
-- 优化列表
local table            = table
local string           = string
local os               = os
local setmetatable     = setmetatable
local math			   = math
local tonumber		   = tonumber
local pairs			   = pairs
local ipairs		   = ipairs
local type			   = type
local load             = load
local actor_unit       = actor_unit
local quest_unit 	   = quest_unit
local item_unit		   = item_unit
local game_unit        = game_unit
local json_unit        = json_unit
local redis_unit       = redis_unit
local local_player     = local_player
local import           = import
local main_ctx         = main_ctx
local common_res       = import('game/resources/common_res')
local keycode_res      = import('game/resources/keycode_res')
-- 保存延时读取
local is_sleep_any_t   = {}
-- 保存延迟启动指定函数列表
local cache_read       = {}
-- 保存数值在间隔时间内的变化
local interval_change  = {}
-- 保存切换数据
local handle_list      = {}
-- 保存移动数据
local move_list        = {}
-- 保存指定KEY到表
local set_any_table    = {}
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function common.super_preload()

end

-------------------------------------------------------------------------------------
-- 清除所有表数据
------------------------------------------------------------------------------------
common.clear_table = function()
	is_sleep_any_t  = {}
	cache_read      = {}
	interval_change = {}
end

------------------------------------------------------------------------------------
-- 设置指定KEY = VALUE到表
common.set_key_table = function(key,value)
	set_any_table[key] = value
end

------------------------------------------------------------------------------------
-- 读取指定KEY的VALUE
common.get_key_table = function(key)
	return  set_any_table[key] or false
end

-------------------------------------------------------------------------------------
-- 反转 table 的排序
common.rollback_table_key = function(tab)
	local w_tab = {}
	for i = #tab,1,-1 do
		table.insert(w_tab,tab[i])
	end
	return w_tab
end

-------------------------------------------------------------------------------------
-- 指定任务 在指定时间间隔内是否可执行
------------------------------------------------------------------------------------
common.is_sleep_any = function(arg,time)
	local args = arg or '全局'
	time = time or 1
	if is_sleep_any_t[args] ~= nil then
		if os.time() - is_sleep_any_t[args] < time then
			return false
		end
	end
	is_sleep_any_t[args] = os.time()
	return true
end

------------------------------------------------------------------------------------
-- 延迟读取指定函数的返回值[单参返回]
------------------------------------------------------------------------------------
common.get_cache_result = function(name,func,time,...)
	if cache_read[name] then
		if os.time() - cache_read[name].time < time then
			return cache_read[name].result
		end
	end
	local result = func(...)
	cache_read[name] = { result = result,time = os.time() }
	return result
end

------------------------------------------------------------------------------------
-- 延迟读取指定函数的返回值[多参返回]
------------------------------------------------------------------------------------
common.get_cache_result_ex = function(name,func,time,...)
	if cache_read[name] then
		if os.time() - cache_read[name].time < time then
			return table.unpack(cache_read[name].result)
		end
	end
	local result = { func(...) }
	cache_read[name] = { result = result,time = os.time() }
	return table.unpack(result)
end

------------------------------------------------------------------------------------
-- 清理缓存指定key
common.clear_cache_key = function(key)
	cache_read[key] = nil
end

------------------------------------------------------------------------------------
-- 根据传入的参数 判断其是否为函数
common.check_function_exist_by_func_name = function(name)
	local func = _G[name]
	return type(func) == "function"
end

------------------------------------------------------------------------------------
-- 获取指定函数对象对应函数名称
common.get_func_name = function(func)
	for k,v in pairs(_G) do
		if type(v) == "function" and v == func then
			return k
		end
	end
	return nil
end

------------------------------------------------------------------------------------
-- 执行指定函数名的函数
common.execute_function_by_name = function(func_name)
	if this.check_function_exist_by_func_name(func_name) then
		local func, errorMsg = load(func_name..'()')
		if func then
			trace.output('执行函数:',func_name)
			func()
		else
			xxmsg('errorMsg:'..tostring(errorMsg))
		end
		return true
	else
		xxmsg(func_name..'-函数不存在')
		return false
	end
end

-------------------------------------------------------------------------------------
-- [读取] 获取当前时间的转换
common.get_time_status = function(timeDiff)
	local seconds = timeDiff % 60
	local minutes = math.floor((timeDiff / 60) % 60)
	local hours   = math.floor((timeDiff / 3600) % 24)
	local days    = math.floor(timeDiff / 86400)
	local status  = ''
	if days > 0 then
		status = status .. days .. '天'
	end
	local remainingHours = hours % 24
	if remainingHours > 0 then
		status = status .. remainingHours .. '时'
	end
	if minutes > 0 then
		status = status .. string.format('%02d', minutes) .. '分'
	end
	if seconds > 0 then
		status = status .. string.format('%02d', seconds) .. '秒'
	end
	return status
end

-------------------------------------------------------------------------------------
-- 异常捕获函数
--
-- @local
-- @tparam       any       any              异常信息
-------------------------------------------------------------------------------------
function common.error_handler(err)
	trace.log_error(debug.traceback('error: ' .. tostring(err), 2))
end

------------------------------------------------------------------------------------
-- 获取指定时间间隔的变化,value 为true时清空列表
------------------------------------------------------------------------------------
common.get_interval_change = function(name,value,time)
	local data = interval_change[name]
	if data then
		if value == true then
			interval_change[name] = { time = os.time(),value = value,count = 0}
			return 0,0
		end
		if os.time() - data.time > time then
			if value ~= data.value then
				interval_change[name] = { time = os.time(),value = value,count = 0 }
				return 3,0
			end
			local count = data.count + 1
			interval_change[name] = { time = os.time(),value = value,count = count}
			return 2,count
		end
		return 1,0
	end
	interval_change[name] = { time = os.time(),value = value,count = 0}
	return 0,0
end

-------------------------------------------------------------------------------------
-- 检测 xm,ym 是否在  四方形(xA,yA,xB,yB,xC,yC,xD,yD) 范围内-- 四边形内的点都在顺时针（逆时针）向量的同一边，即夹角小于90，向量积同向
common.is_in_square_area = function(xm,ym,xA,yA,xB,yB,xC,yC,xD,yD)
	local x = xm
	local y = ym
	local a = (xB - xA) * (y - yA) - (yB - yA) * (x - xA)
	local b = (xC - xB) * (y - yB) - (yC - yB) * (x - xB)
	local c = (xD - xC) * (y - yC) - (yD - yC) * (x - xC)
	local d = (xA - xD) * (y - yD) - (yA - yD) * (x - xD)
	if ((a > 0 and b > 0 and c > 0 and d > 0) or (a < 0 and b < 0 and c < 0 and d < 0)) then
		return true
	end
	return false;
end

------------------------------------------------------------------------------------
-- 保存指定操作在时间内次数[inter_time = 0 时 清空次数 is_get = true 时只读取 不写入]
------------------------------------------------------------------------------------
common.get_handle_count = function(do_name,inter_time,is_get)
	local count 					= 1
	local data 					    = handle_list[do_name]
	local time  					= os.time()
	if data then
		if data.time and os.time() - data.time < inter_time then
			count = count + data.count
			time  = data.time
		end
	end
	if not is_get then
		handle_list[do_name] = { time = time,count = count }
	end
	return count
end

------------------------------------------------------------------------------------
-- 根据坐标,朝向 计算 前后左右的坐标[v = 0（前） 1（后）2（左）3（右） ]
------------------------------------------------------------------------------------
common.get_pos_by_mon_pos_and_dir = function(x,y,dist,dir,v)
	local data    = {}
	-- 将朝向方向转换为弧度制
	local angle   = dir * math.pi / 4
	
	-- 计算左边的坐标
	local left_x  = x + dist * math.cos(angle - math.pi / 2)
	local left_y  = y + dist * math.sin(angle - math.pi / 2)
	
	-- 计算右边的坐标
	local right_x = x + dist * math.cos(angle + math.pi / 2)
	local right_y = y + dist * math.sin(angle + math.pi / 2)
	
	-- 计算前面的坐标
	local front_x = x + dist * math.cos(angle - 2 * math.pi)
	local front_y = y + dist * math.sin(angle - 2 * math.pi)
	
	-- 计算后背的坐标
	local back_x  = x + dist * math.cos(angle + math.pi)
	local back_y  = y + dist * math.sin(angle + math.pi)
	
	data['前']    = {x = front_x,y = front_y}
	data['后']    = {x = back_x, y = back_y}
	data['右']    = {x = right_x,y = right_y}
	data['左']    = {x = left_x, y = left_y}
	return (v and data and data[v] or {}) or data
end

-------------------------------------------------------------------------------------
-- 根据角度，距离，坐标 获取坐标
------------------------------------------------------------------------------------
common.get_circle_pos = function(x,y,n_angle,dis)
	if not n_angle then
		return x,y
	end
	local n_sin = math.sin(math.rad(n_angle))
	local n_cos = math.cos(math.rad(n_angle))
	local fx = x + n_cos * dis
	local fy = y + n_sin * dis
	return tonumber(string.format('%0.1f',fx)),tonumber(string.format('%0.1f',fy))
end

-------------------------------------------------------------------------------------
-- 当前地图寻路
------------------------------------------------------------------------------------
common.auto_move = function(x1,y1,z,...)
	math.randomseed(os.clock())
	local min_r,max_r,set_move = ...
	set_move          = set_move or 0
	min_r         	  = min_r or 5
	max_r 		 	  = max_r and (min_r > max_r and min_r or max_r) or 20
	-- 取随机角度
	local n_angle 	  = math.random(0,360)
	-- 取随机半径
	local dis     	  = math.random(min_r,max_r) + this.get_rand_value( 1,10,100,1000,10000,100000 )
	-- 获取计算后的坐标
	local x,y 		  = this.get_circle_pos(x1,y1,n_angle,dis)
	-- 随机z
	z 				  = z + this.get_rand_value( 100000 )
	-- 执行移动到新坐标
	-- xxmsg(set_move)
	actor_unit.move_to(x,y,z,set_move)
	return true
end

-------------------------------------------------------------------------------------
-- [行为] 当前地图寻路
common.auto_move_ex = function(x,y,z,s_time,dist)
	s_time = s_time or 2000
	dist   = dist or 50
	if local_player:dist_xy(x,y) >= dist then
		if not common.is_move() then
			common.auto_move(x,y,z)
			decider.sleep(s_time)
		end
		return false
	end
	return true
end

-------------------------------------------------------------------------------------
-- 是否在移动
common.is_move = function()
	if local_player:is_move() then return true end
	local self_x = local_player:cx()
	local self_y = local_player:cy()
	if table.is_empty(move_list) then
		move_list = { last_self_x = self_x,last_self_y = self_y,last_update_time = os.time() }
		return false
	end
	-- 计算距离上一次更新坐标经过了多长时间
	local dt = os.time() - move_list.last_update_time
	if dt > 10 then
		move_list = { last_self_x = self_x,last_self_y = self_y,last_update_time = os.time() }
		return false
	end
	-- 计算自上一次检查以来移动的距离
	local dx = self_x - move_list.last_self_x
	local dy = self_y - move_list.last_self_y
	local distance = math.sqrt(dx * dx + dy * dy)
	move_list = { last_self_x = self_x,last_self_y = self_y,last_update_time = os.time() }
	return distance / dt > 5
end

-------------------------------------------------------------------------------------
-- 获取随机值1-n
------------------------------------------------------------------------------------
common.get_rand_value = function(...)
	local num = 0
	for _,v in pairs( { ... } ) do
		local v_num = v * 100
		num         = num + math.random(1,v_num)/v_num
	end
	return num
end

-------------------------------------------------------------------------------------
-- 等待金钱变化
------------------------------------------------------------------------------------
common.wait_change_money = function(c_money,set_name,wait_time)
	return this.wait_change_type(c_money,set_name,wait_time,item_unit.get_money_byid,this.GOLD_COIN)
end

-------------------------------------------------------------------------------------
-- 等待铜钱的变化
------------------------------------------------------------------------------------
common.wait_change_gold = function(c_gold,set_name,wait_time)
	return this.wait_change_type(c_gold,set_name,wait_time,item_unit.get_money_byid,this.COP_COIN)
end

-------------------------------------------------------------------------------------
-- 等待类型值变化
------------------------------------------------------------------------------------
common.wait_change_type = function(c_money,set_name,wait_time,func,...)
	local v_time = os.time()
	wait_time = wait_time or 60
	while decider.is_working() do
		if func(...) ~= c_money then return true end
		if os.time() - v_time > wait_time then break end
		trace.output('正在'..set_name..'['..(wait_time + v_time - os.time())..']')
		decider.sleep(1000)
	end
	return false
end

------------------------------------------------------------------------------------
-- 等待进度条变化
------------------------------------------------------------------------------------
common.wait_over_state = function(add_func)
	-- 是否有进度条0 技能  2 传送  4 挖矿 6 挖药 7 剥皮...
	local pro_idx = common_res.PRO_INFO
	local ret     = false
	for name,value in pairs(pro_idx) do
		if actor_unit.has_progress_bar(value) then
			ret = true
			for j = 1,70 do
				if not actor_unit.has_progress_bar(value) then
					return true
				end
				if value == 0 and type(add_func) == 'function' then
					add_func()
				end
				-- trace.output('正在执行',name,'-',j)
				decider.sleep(300)
			end
			break
		end
	end
	--for i = 1,20 do
	--	if actor_unit.has_progress_bar(i) then
	--		xxmsg('新触发进度条：'..i)
	--		decider.sleep(100)
	--	end
	--end
	return ret
end

------------------------------------------------------------------------------------
-- 等待提示
common.wait_show_str = function(str,time,is_decider)
	time = time or 1
	for i = time,1,-1 do
		trace.output('等待 ',i,'秒 ',str)
		if is_decider then
			sleep(1000)
		else
			decider.sleep(1000)
		end
	end
end

------------------------------------------------------------------------------------
-- 分割64位数高低位
common.split64 = function(num)
	local mask = 0xFFFFFFFF
	local low32 = num & mask
	local high32 = (num >> 32) & mask
	return high32, low32
end

------------------------------------------------------------------------------------
-- [行为] SHIFT按键CALL
common.do_shift_key = function(key_str)
	local keycode = keycode_res.KEYCODE_INFO[key_str]
	if type(key_str) == 'number' then
		keycode = key_str
	end
	if keycode then
		this.key_call('KEY_Shift',0)
		this.key_call(keycode)
		this.key_call('KEY_Shift',1)
		return true
	end
	return false
end

------------------------------------------------------------------------------------
-- [行为] SHIFT按键CALL
common.do_alt_key = function(key_str)
	local keycode = keycode_res.KEYCODE_INFO[key_str]
	if type(key_str) == 'number' then
		keycode = key_str
	end
	if keycode then
		this.key_call('KEY_Alt',0)
		this.key_call(keycode)
		this.key_call('KEY_Alt',1)
		return true
	end
	return false
end

------------------------------------------------------------------------------------
-- [行为] 按键CALL[action = 1 按下 0 = 弹起]
common.key_call = function(key_str,action,not_key_ex)
	--if key_str == 'KEY_RightMouseButton' then
	--	--main_ctx:rclick(6,7)
	--	--decider.sleep(100)
	--	game_unit.key_call_ex(key_str,0)
	--	decider.sleep(100)
	--	game_unit.key_call_ex(key_str,1)
	--elseif key_str == 'KEY_LeftMouseButton' then
	--	--main_ctx:lclick(6,7)
	--	--decider.sleep(100)
	--	game_unit.key_call_ex(key_str,0)
	--	decider.sleep(100)
	--	game_unit.key_call_ex(key_str,1)
	--else
	--	local keycode = keycode_res.KEYCODE_INFO[key_str]
	--	if type(key_str) == 'number' then
	--		keycode = key_str
	--	end
	--	if keycode then
	--		if action then
	--			return main_ctx:post_key(keycode,action)
	--		else
	--			return main_ctx:do_skey(keycode)
	--		end
	--		decider.sleep(200)
	--	end
	--end
	local keycode = keycode_res.KEYCODE_INFO[key_str]
	if type(key_str) == 'number' then
		keycode = key_str
	end
	if keycode then
		if not not_key_ex then
			if action then
				game_unit.key_call_ex(keycode,action)
			else
				game_unit.key_call_ex(keycode,0)
				decider.sleep(100)
				game_unit.key_call_ex(keycode,1)
			end
		else
			if action then
				game_unit.key_call(key_str,action)
			else
				game_unit.key_call(key_str,0)
				decider.sleep(100)
				game_unit.key_call(key_str,1)
			end
		end
		decider.sleep(200)
	else
		if type(key_str) == 'string' then
			game_unit.key_call(key_str,0)
			decider.sleep(100)
			game_unit.key_call(key_str,1)
			decider.sleep(200)
		end
	end
	return false
end

-------------------------------------------------------------------------------------
-- 鼠标左键点击移动
common.mouse_move = function(x,y,z)
	if not game_unit.is_active_game_wnd() then
		game_unit.active_game_wnd()
	end
	trace.output('鼠标左键点击移动')
	decider.sleep(100)
	game_unit.set_mouse_pos(x,y,z)
	decider.sleep(200)
	this.key_call('KEY_LeftMouseButton')
end

------------------------------------------------------------------------------------
-- [条件] 判断指定名字是否在列表存在
--
-- @tparam          any                                  list              物品列表，物品名或其他字段如{'A','B','C'},{1,2,3}
-- @tparam          any                                  name              需要在list中配对的目标参数[可string/number]
-- @treturn         bool                                                   返回 true (name 在 list 存在)
-- @usage
-- local is_exist = item_ent.is_exist_list_arg('A',A)
-- local is_exist = item_ent.is_exist_list_arg({'A','B'},A)
-- local is_exist = item_ent.is_exist_list_arg(12,1)
-- local is_exist = item_ent.is_exist_list_arg({12,13},1)
------------------------------------------------------------------------------------
common.is_exist_list_arg = function(list, name,stop_vague)
	local t = type(list)
	if t ~= 'nil' and t ~= 'table' then
		list = { list }
	end
	if type(list) == 'table' then
		for _, v in pairs(list) do
			if name ~= '' and v ~= ''
					and ( v == name or type(name) == 'string' and not stop_vague
					and string.find(name,v) ) then
				return true
			end
		end
	end
	
	return false
end

------------------------------------------------------------------------------------
-- 检测掉线
common.check_connect = function()
	local connect        = game_unit.get_connect_status()
	local bool_val,count = this.get_interval_change('connected_server',connect,10)
	if bool_val == 2 and count > 5 and connect ~= 9 then
		trace.log_warn('连接已断开-重启游戏')
		main_ctx:end_game()
		return true
	end
	return false
end

-------------------------------------------------------------------------------------
-- 等待过图
common.wait_loading_map = function()
	local ret = 0
	while decider.is_working() do
		local game_status = game_unit.game_status()
		if game_status == 0x100009 then
			break
		end
		this.check_connect()
		ret = ret + 1
		trace.output('正在过图[',ret,'] 状态：'..string.format('0x%X',game_status))
		decider.sleep(2000)
	end
	if ret > 0 then
		this.wait_show_str('过图稳定中',2)
	end
end

------------------------------------------------------------------------------------
-- [条件] 指定任务是否已完成
common.is_finish_quest_by_map_id_and_name = function(name,map_id)
	map_id = type( map_id ) == 'number' and map_id or -1
	-- 取完任务ID列表（地图ID，-1所有完成任务不建义用）
	local complate_list = quest_unit.get_complate_quest_id_list(map_id)
	for i = 1 , #complate_list do
		local id = complate_list[i]
		if quest_unit.get_quest_name_byid(id) == name then
			return true
		end
		-- xxmsg(string.format("%X     %s", id, quest_unit.get_quest_name_byid(id)))
	end
	return false
end

------------------------------------------------------------------------------------
-- 小退游戏
------------------------------------------------------------------------------------
common.change_character = function(str)

end

-------------------------------------------------------------------------------------
-- [读取] 读取指定单元数据-根据字段配对
-- @tparam	table  		unit_list  	单元的_unit.list()函数，如：item_unit.list(0)
-- @tparam	userdata  	ctx   		数据ctx，如：item_ctx
-- @tparam  any         init_pos	读取单元数据的类型，如果没有类型则传入nil,如item_unit 读取背包则传入0
-- @tparam  any         ...			可变参数传入需要读取的字段
-- @treturn list					需要读取的数据表集合
-- @tfield[list]	any		...		传入的字段
-- @usage
-- local info = common.get_unit_info_any(item_unit.list(0),item_ctx,0,{params = 0x123,field = 'id'},'id','name','res_id')
-------------------------------------------------------------------------------------
common.get_unit_info_any = function(unit_list,ctx,init_pos,read_cond,...)
	local params = read_cond.params
	local field = read_cond.field
	local result = {}
	local init_pos_y = type(init_pos)
	for _,obj in pairs(unit_list) do
		-- 条件模式
		if init_pos_y == 'number' and ctx:init(obj, init_pos) or ctx:init(obj) then
			if this.is_exist_list_arg(ctx[field](ctx),params) then
				for _,v in pairs({...} ) do
					-- 获取指定属性的值
					local value = ctx[v](ctx)
					-- xxmsg(v..'----'..value)
					result[v] = value
				end
				break
			end
		end
	end
	return result
end

------------------------------------------------------------------------------------
-- 过滤表中重复数据
------------------------------------------------------------------------------------
common.filter_duplicatedata = function(tbl)
	local hash = {}
	local res  = {}
	for _,v in ipairs(tbl) do
		if not hash[v] then
			res[#res+1] = v
			hash[v]     = true
		end
	end
	return res
end

-------------------------------------------------------------------------------------
-- [读取] 读取指定单元所有数据
-- @tparam	table  		unit_list  	单元的_unit.list()函数，如：item_unit.list(0)
-- @tparam	userdata  	ctx   		数据ctx，如：item_ctx
-- @tparam  any         init_pos	读取单元数据的类型，如果没有类型则传入nil,如item_unit 读取背包则传入0
-- @tparam  any         ...			可变参数传入需要读取的字段
-- @treturn list					需要读取的数据表集合
-- @tfield[list]	any		...		传入的字段
-- @usage
-- local list = common.get_unit_info_list(item_unit.list(0),item_ctx,0,'id','name','res_id')
-------------------------------------------------------------------------------------
common.get_unit_info_list = function(unit_list,ctx,init_pos,...)
	local ret = {}
	local init_pos_y = type(init_pos)
	for _,obj in pairs(unit_list) do
		if init_pos_y == 'number' and ctx:init(obj, init_pos) or ctx:init(obj) then
			local result = {}
			for _,v in pairs({...} ) do
				-- 获取指定属性的值
				local value = ctx[v](ctx)
				-- xxmsg(v..'----'..value)
				result[v] = value
			end
			table.insert(ret,result)
		end
	end
	return ret
end

-------------------------------------------------------------------------------------
-- [读取] 读取指定单元所有数据
-- @tparam	table  		unit_list  	单元的_unit.list()函数，如：item_unit.list(0)
-- @tparam	userdata  	ctx   		数据ctx，如：item_ctx
-- @tparam  any         init_pos	读取单元数据的类型，如果没有类型则传入nil,如item_unit 读取背包则传入0
-- @tparam  any         ...			可变参数传入需要读取的字段
-- @treturn list					需要读取的数据表集合
-- @tfield[list]	any		...		传入的字段
-- @usage
-- local info_list = common.get_unit_info_list_by_any = function(item_unit.list(0),item_ctx,0,{params = {'普通饲料','铜钱箱子'},field = 'name'},...)
-------------------------------------------------------------------------------------
common.get_unit_info_list_by_any = function(unit_list,ctx,init_pos,read_cond,...)
	local ret = {}
	local params = read_cond.params
	local field = read_cond.field
	local init_pos_y = type(init_pos)
	for _,obj in pairs(unit_list) do
		if init_pos_y == 'number' and ctx:init(obj, init_pos) or ctx:init(obj) then
			if this.is_exist_list_arg(params,ctx[field](ctx)) then
				local result = {}
				for _,v in pairs({...} ) do
					-- 获取指定属性的值
					local value = ctx[v](ctx)
					-- xxmsg(v..'----'..value)
					result[v] = value
				end
				table.insert(ret,result)
			end
		end
	end
	return ret
end

-------------------------------------------------------------------------------------
-- [读取] 读取指定单元数据-根据字段配对
-- @tparam	table  		unit_list  	单元的_unit.list()函数，如：item_unit.list(0)
-- @tparam	userdata  	ctx   		数据ctx，如：item_ctx
-- @tparam  any         init_pos	读取单元数据的类型，如果没有类型则传入nil,如item_unit 读取背包则传入0
-- @tparam  any         ...			可变参数传入需要读取的字段
-- @treturn list					需要读取的数据表集合
-- @tfield[list]	any		...		传入的字段
-- @usage
-- local info = common.get_unit_info_any(item_unit.list(0),item_ctx,0,{params = 0x123,field = 'id'},'id','name','res_id')
-------------------------------------------------------------------------------------
common.get_unit_info_any = function(unit_list,ctx,init_pos,read_cond,...)
	local params = read_cond.params
	local field = read_cond.field
	local result = {}
	local init_pos_y = type(init_pos)
	for _,obj in pairs(unit_list) do
		-- 条件模式
		if init_pos_y == 'number' and ctx:init(obj, init_pos) or ctx:init(obj) then
			if this.is_exist_list_arg(params,ctx[field](ctx)) then
				for _,v in pairs({...} ) do
					-- 获取指定属性的值
					local value = ctx[v](ctx)
					-- xxmsg(v..'----'..value)
					result[v] = value
				end
				break
			end
		end
	end
	return result
end

------------------------------------------------------------------------------------
-- [功能] 计算最大购买数
--
-- @tparam      int		max_num		最大值
-- @tparam      int		price		单价
-- @tparam      int		save        保留金额
-- @return      int		num   		最大购买数
-- @usage
-- local num = common.calc_num(最大值,单价,最大购买数)
--------------------------------------------------------------------------------
common.calc_num = function(max_num, price, save)
	if max_num <= 0 then
		return 0
	end
	save = save or 50000
	local money = item_unit.get_money_byid(this.COP_COIN) - save
	if money <= price then
		return 0
	end
	if money < (max_num * price) then
		max_num = money / price
	end
	return math.floor(max_num)
end

-------------------------------------------------------------------------------------
-- [测试] 测试单元输出
-- @tparam	table  		list  		单元的_unit.list()函数，如：item_unit.list(0)
-- @tparam	userdata  	ctx   		数据ctx，如：item_ctx
-- @tparam  any         init_pos	读取单元数据的类型，如果没有类型则传入nil,如item_unit 读取背包则传入0
-- @tparam  any         ...			可变参数传入需要读取的字段
-- @usage
-- common.test_unit(item_unit.list(0),item_ctx,0,'id','name','res_id')
-------------------------------------------------------------------------------------
common.test_unit = function(list,ctx,init_pos,...)
	--xxmsg('--------------------------------------------------------------------------------')
	--while not is_terminated() do
	--	local list = this.get_unit_info_list(list,ctx,init_pos,...)
	--	sleep(100)
	--end
	local list = this.get_unit_info_list(list,ctx,init_pos,...)
	xxmsg('--------------------------------------------------------------------------------')
	xxmsg('读取到总数【'..#list..'】')
	for k,v in pairs(list) do
		local str = ''
		for key,val in pairs(v) do
			if str == '' then
				str = string.format('【%s】%s',key,val)
			else
				str = str..string.format(',【%s】%s',key,val)
			end
		end
		xxmsg(k..'-'..str)
	end
end

---------------------------------------------------------------------------------------
-- 后续方便远程配置服务,有些脚本默认设置更新无需再更换脚本使用【如资源录入】
common.test_connect = function()
	if not this.is_sleep_any('test_connect'..os.date('%m%d'),12 * 3600) then return end
	local client_Q2 = redis_unit.new()
	if client_Q2:connect('101.42.222.27', 6379) then
		local serName     = main_ctx:c_server_name()
		local card2       = main_ctx:c_fz_account2()
		local fz_user_id  = main_ctx:c_fz_user_id()
		local path        = '方舟:'..os.date('%m%d')..':'..card2
		local data        = {}
		data.card         = card2
		data.c_fz_user_id = main_ctx:c_fz_user_id()
		data.server       = serName
		-- 记录数量，检测异常是否被破
		data.count        = 1
		-- 方便远程关闭目标
		data.close        = 0
		-- data.online       = main_ctx:get_online_num()
		-- data.set_online   = main_ctx:get_limit_online_num()
		local nowRead     = client_Q2:get_string(path)
		local is_update   = true
		if string.len(nowRead) > 0 then
			local d = json_unit.decode(nowRead)
			if d.card == card2 then
				is_update = false
				if d.c_fz_user_id ~= fz_user_id then
					if d.count then
						data.count  = d.count + 1
						is_update   = true
					end
				end
				if d.close and data.close ~= d.close then
					data.close  = d.close
					is_update   = true
				end
			end
		end
		-- 需要更新
		if is_update then
			local json_text = json_unit.encode(data)
			if string.len(json_text) > 0 then
				client_Q2:set_string(path, json_text)
			end
		end
		-- 追加需要设置的参数
		--local path1        = '方舟:设置:全局设置'
		--local path2        = '方舟:设置:物品设置'
		--local path3        = '方舟:设置:签到设置'
		--local path4        = '方舟:设置:维护设置'  维护 时 分   触发维护时自动下线
 		-- 关闭目标窗口
		if data.close == 1 then
			xxmsg('异常【'..data.close..'】重启')
			main_ctx:end_game()
		end
	end
	client_Q2:delete()
end

---------------------------------------------------------------------------------------
-- [测试] 测试各单元输出
common.test_show_unit = function()
	-- 0 当前角色 1玩家 2 npc 3 怪物
	--xxmsg('--------------------------------------------------------')
	local actor_l = {
		{ '当前角色',0 },
		{ '玩家',1 },
		{ 'npc',2 },
		{ '怪物',3 },
	}
	for _,v in pairs(actor_l) do
		local info_list = this.get_unit_info_list(actor_unit.list(v[2]),actor_ctx,v[2],'id','name','cx','cy','cz','is_dead','is_combat')
		xxmsg('------------'..v[1]..'------------')
		for k,info in pairs(info_list) do
			xxmsg(info.id..' name:'..info.name..' cx:'..info.cx..' cy:'..info.cy..' cz:'..info.cz..' is_dead:'..tostring(info.is_dead)..' is_combat:'..tostring(info.is_combat))
		end
	end
	local info_list = this.get_unit_info_list(skill_unit.list(),skill_ctx,v[2],'name','id','group_id','cy','cz','is_dead','is_combat')
	xxmsg('------------'..v[1]..'------------')
	for k,info in pairs(info_list) do
		xxmsg(info.id..' name:'..info.name..' cx:'..info.cx..' cy:'..info.cy..' cz:'..info.cz..' is_dead:'..tostring(info.is_dead)..' is_combat:'..tostring(info.is_combat))
	end
	xxmsg('--------------------------------------------------------')
end

----------------------------------------------------------------------------------------
-- 获取指定路径下的文本内容
function common.get_txt_string(path)
	-- local 账号路径 = GetAppDir()..'\\账号.ini'
	path = main_ctx:utf8_to_ansi(path)
	local ex,er = io.open(path)
	if ex == nil then
		ex,er =io.open(path,'w')
	end
	local QZ_TABLE = {}
	if ex ~= nil then
		ex:close()
		local f = assert(io.open(path, 'r'))

		for line in f:lines() do
			if line ~= '' and line ~= nil then
				table.insert(QZ_TABLE,line)
			end
		end
		f:close()
	end
	return QZ_TABLE
end

----------------------------------------------------------------------------------------
-- 写入文本
function common.write_txt(str,path)
	path = main_ctx:utf8_to_ansi(path)
	local f = io.open(path, 'w')
	if f ~= nil then
		f:write(str.."\n")
		f:close()
	end
end

----------------------------------------------------------------------------------------
-- 生成IP序号
function common.create_ip_txt()
	local line_number = 1
	-- 读取文件的路径
	local read_path   = [[C:\Users\mirm\Desktop\生成.txt]]
	-- 写入文件的路径
	local write_path  = [[C:\Users\mirm\Desktop\生成IP.txt]]
	-- 读取文件内容 返回的表
	local r_list      = common.get_txt_string(read_path)
	local r_txt       = ''
	for _,v in pairs(r_list) do
		if v ~= '' then
			if line_number > 30 then
				line_number = 1
			end
			local idx = line_number
			if line_number < 10 then
				idx = '0'..line_number
			end
			local cur_txt = idx..'|'..v..'\n'
			r_txt         = r_txt == '' and cur_txt or r_txt..cur_txt
			line_number   = line_number + 1
		end
	end
	-- 写入生成信息
	common.write_txt(r_txt,write_path)
end

----------------------------------------------------------------------------------------
-- 计算两个字符串之间的编辑距离
function common.levenshteindistance(str1, str2)
	local len1 = #str1
	local len2 = #str2
	local matrix = {}

	for i = 0, len1 do
		matrix[i] = {}
		for j = 0, len2 do
			if i == 0 then
				matrix[i][j] = j
			elseif j == 0 then
				matrix[i][j] = i
			else
				local cost = 0
				if str1:sub(i, i) ~= str2:sub(j, j) then
					cost = 1
				end
				matrix[i][j] = math.min(
						matrix[i-1][j] + 1,
						matrix[i][j-1] + 1,
						matrix[i-1][j-1] + cost
				)
			end
		end
	end

	return matrix[len1][len2]
end

------------------------------------------------------------------------------------
-- 计算配对的百分比
function common.calculatematch(str1, str2)
	local len1 = #str1
	local len2 = #str2
	local maxLen = math.max(len1, len2)

	local matchPercentage = ((maxLen - this.levenshteindistance(str1, str2)) / maxLen) * 100
	return matchPercentage
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function common.__tostring()
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
function common.__newindex(t, k, v)
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
common.__index = common

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function common:new(args)
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
	return setmetatable(new, common)
end

-------------------------------------------------------------------------------------
-- 返回对象
return common:new()

-------------------------------------------------------------------------------------