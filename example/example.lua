-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   core
-- @email:    88888@qq.com 
-- @date:     2022-08-10
-- @module:   example
-- @describe: 示例代码模块
-- @version:  v1.0
--

local VERSION = '20220810' -- version history at end of file
local AUTHOR_NOTE = "-[20220810]-"
---@class example
local example = {  
	VERSION      = VERSION,
	AUTHOR_NOTE  = AUTHOR_NOTE,
}

local this = example
local config_client = import('base/config')

-------------------------------------------------------------------------------------
-- test_ui_unit
function example:test_ui_unit()
	ui_unit.debug(false)

	-- xxmsg(string.format('%X', game_unit.get_fix_object_byid(0x3EA)))
	-- xxmsg(string.format('%X', game_unit.get_fix_object_byid(0x3EB)))
	-- xxmsg(string.format('%X', game_unit.get_fix_object_byid(0x3EC)))
	--xxmsg(string.format('%X', game_unit.get_fix_object_byid(0x3ED)))
	-- xxmsg( login_unit.pre_create_char() )
	-- xxmsg( login_unit.select_class(0xC9) )
	--xxmsg( login_unit.verify_char_name('Douglaswwsrys') )

	--ui_unit.do_click(0x00015211A209A0)
	
	-- xxmsg( string.format('%X', ui_unit.get_parent_widget_byid(0x00000003, false)) )
	-- xxmsg( string.format('%X', ui_unit.get_parent_widget_byid(0x00000007, false)) )
	-- xxmsg( string.format('%X', ui_unit.get_parent_widget_byid(0x0000000D, false)) )

	-- local globalAccessTermsWnd = ui_unit.get_parent_widget('globalAccessTermsWnd', true)
	-- if globalAccessTermsWnd ~= 0 then
	-- 	local acceptButton = ui_unit.get_child_widget(globalAccessTermsWnd, 'acceptButton')
	-- 	if acceptButton ~= 0 then
	-- 		ui_unit.do_click(acceptButton)
	-- 	end
	-- end

	-- local loginServerSelectGroup = ui_unit.get_parent_widget('loginServerSelectGroup', true)
	-- xxmsg( string.format('loginServerSelectGroup: %X', loginServerSelectGroup) )

	-- local option_btn = ui_unit.get_child_widget(loginServerSelectGroup, 'option_btn')
	-- xxmsg( string.format('option_btn: %X', option_btn) )
	
	-- local join_btn = ui_unit.get_child_widget(loginServerSelectGroup, 'join_btn')
	-- xxmsg( string.format('join_btn: %X', join_btn) )
	
	-- if join_btn ~= 0 then
	-- 	--ui_unit.do_click(join_btn)
	-- end

	-- local characterSelectBottomFrame = ui_unit.get_parent_widget('characterSelectBottomFrame', true)
	-- local start_btn = ui_unit.get_child_widget(characterSelectBottomFrame, 'start_btn')
	-- xxmsg( string.format('start_btn: %X', start_btn) )

	-- if start_btn ~= 0 then
	-- 	--ui_unit.do_click(start_btn)
	-- end

	-- 序幕操作
	-- 是否在序幕中
	ui_unit.is_in_prologue()
	-- 点击跳过序幕
	ui_unit.click_exit_prologue()
	-- 检测退出序幕窗口
	ui_unit.is_in_prologue_skip()
	-- 确认退出序幕
	ui_unit.confirm_exit_prologue()

	-- 检测玩法目录
	-- ui_unit.is_open_play_dir_wnd()
	-- 打开玩法目录（alt + Q）
	-- main_ctx:do_alt_key(81)

	-- dialog对话框
	--ui_unit.has_dialog()
	-- --确认对话(false 取消)
	--ui_unit.confirm_dialog(true)
	
end

-------------------------------------------------------------------------------------
-- test_game_unit
function example:test_game_unit()
	xxmsg( game_unit.get_str_byname('sys.serverselect.dialog_preopen_title') )
	xxmsg( game_unit.get_str_byname('sys.serverselect.dialog_preopen_desc') )
	xxmsg( game_unit.get_str_byname('sys.serverselect.dialog_fullcharacter_desc') )
	-- 开启光标HOOK(打怪必用)
	hook_unit.enable_mouse_screen_pos(true)
	-- 关闭光标HOOk
	hook_unit.enable_mouse_screen_pos(false)
	-- 设置光标坐标（打怪时设怪物坐标） 
	game_unit.set_mouse_pos(x, y, z)
	-- 游戏按建CALL 0 按下 1起来
	game_unit.key_call('KEY_Q',0)
	-- 取连接状态
	game_unit.get_connect_status()
	-- 取游戏状态
	game_unit.game_status()
	-- 是否有剧情
	game_unit.has_plot()
	-- 检激窗口激活
	if not game_unit.is_active_game_wnd() then 
        xxmsg('激活游戏窗口')
        game_unit.active_game_wnd()
    end

end

-------------------------------------------------------------------------------------
-- test_raid_dun_unit
function example:test_raid_dun_unit()
	-- 需要打开星辰窗口才能正确读取
	local raid_list = dungeon_unit.raid_dun_list()
	xxmsg("星辰数量："..#raid_list)
	for i = 1, #raid_list do
		local obj = raid_list[i]
		if dungeon_ctx:init_raid(obj) then
			xxmsg(string.format("obj:%X   id:%08X   main_idx:%02d   sub_idx:%02d   equip_level:%05d  name:%s",
					obj,
					dungeon_ctx:raid_id(),
					dungeon_ctx:raid_main_idx(),
					dungeon_ctx:raid_sub_idx(),
					dungeon_ctx:equip_level(),
					dungeon_ctx:raid_name()
			))
			xxxmsg(2,'{ min_power = '..dungeon_ctx:equip_level()..',can_do = \''..dungeon_ctx:raid_name()..'\',is_open = true,main_idx = '..math.floor(dungeon_ctx:raid_main_idx())..',sub_idx = '..math.floor(dungeon_ctx:raid_sub_idx())..',map_id = 0 },')
		end
	end

	-- -- 取星辰护卫窗口
	-- dungeon_unit.get_raid_entrance_wnd()
	-- -- 从玩家目标打开星辰护卫窗口
	-- dungeon_unit.open_raid_entrance_wnd()
	-- -- 匹配队伍(匹配成功后用对话框确认进入)
	-- dungeon_unit.matching_raid(main_idx, sub_idx)
	-- -- 个人请求进入（话框确认进入）
	-- dungeon_unit.req_raid_raid(main_idx, sub_idx)

end

-------------------------------------------------------------------------------------
-- test_login_unit
function example:test_login_unit()
	--login_unit.debug()

	-- 服务器选择页面功能
	-- local config_server_name = main_ctx:c_server_name()
	-- xxmsg(config_server_name)
	-- -- 取服务器状态
	-- xxmsg(login_unit.get_server_status(config_server_name))
	-- -- 取服务服角色数
	-- xxmsg(login_unit.get_server_charnum(config_server_name))
	-- if game_unit.get_connect_status() == 3 then
	-- 	-- 连接服务器
	-- 	xxmsg(login_unit.login_game_server(config_server_name))
	-- 	sleep(5000)
	-- end

	-- 角色选择页面功能
	local char_count = login_unit.get_char_count()
	for i = 0, char_count -1
	do
		local temp = string.format('%X %04X %02u %s', 
			login_unit.get_charptr_byidx(i),
			login_unit.get_char_classid(i),
			login_unit.get_char_level(i),
			login_unit.get_char_name(i))
		xxmsg(temp)		
	end

	-- 进入游戏序号
	--xxmsg( login_unit.enter_game(0) )
	-- 打开创建
	--login_unit.pre_create_char()
	-- 选择职业(战士0x65 法师0xC9  格斗0x1D2, 射手：0x1F5  巫师0x259  潜伏者0x191)
	--login_unit.select_class(id)
	-- 效验名称
	--login_unit.verify_char_name(name)
	-- 创建 角色（"" 内部自动生成 ，有内容为传入名称）
	-- login_unit.create_character("")
end

-------------------------------------------------------------------------------------
-- test_actor_unit   1玩家 2怪 3NPC4地面物品 6任务采集物品
function example:test_actor_unit(actor_type)
	local list = actor_unit.list(actor_type)
	local actor_obj = actor_unit:new()
	if #list > 0 then
		xxmsg('类型'..actor_type..'----数量：'..#list..'***************************')
	end
	for i = 1, #list do 
		local obj = list[i]
		if actor_obj:init(obj) then 
			xxmsg(string.format("obj:%X  class:%-16s   id:%X   res_id:%X   level:%03d  hp[%06d-%06d]  battle:%-6s  dead:%-6s  pos[%0.1f, %0.1f, %0.1f] dist:%0.1f type7_status:%d  can_attack:%-6s  can_talk:%-6s is_valid:%s  name:%s",
			obj,
			actor_obj:cls_name(),
			actor_obj:id(),
			actor_obj:res_id(),    --类型6和 NPC 都有的 固困ID
			actor_obj:level(),
			actor_obj:hp(),
			actor_obj:max_hp(),
			actor_obj:is_battle(),
			actor_obj:is_dead(),
			actor_obj:cx(),
			actor_obj:cy(),
			actor_obj:cz(),
			actor_obj:dist(),
			actor_obj:type_seven_status(),
			--actor_obj:is_move(),
			--
			 actor_obj:monster_can_attack(), -- 怪物是否是可攻击状态
			-- actor_obj:can_gather()          -- 野外采集对象是否可采集
			 actor_obj:npc_can_talk(),
			actor_obj:is_valid(),actor_obj:name()   -- 类型6采集类是否有效的，，门之类的不能用这（门之类的用资源ID做静太资源 ）
		
			))
		end

	end
	actor_obj:delete()

	-- 寻路0 正常寻，1上电梯，2上船
	-- actor_unit.move_to(x, y, z,action)
	-- NPC 对话
	-- actor_unit.npc_talk(npc_id, 1)
	-- 取当前对话NPCID（可用于判断是否打开对话 像商 店好像也可以用）
	-- actor_unit.get_cur_talk_npc_id()
	-- 采集类对话
	--  actor_unit.gather_talk(对象)
	-- 三角色光点传送（对象列表类型为8）
	--  actor_unit.transfer_talk(对象)
	-- 是否有进度条0 技能  2 传送  4 挖矿 6 挖药 7 剥皮
	-- actor_unit.has_progress_bar(id)
	-- 捡物
	-- actor_unit.pick_item(id)
	-- 当前地图ID
	-- actor_unit.map_id()
	-- 当前地图名
	-- actor_unit.map_name()
	-- 当前区域 地图名
	-- actor_unit.sub_map_name()
	-- 当前小场景地图名
	-- actor_unit.get_cur_scene_map_name()
	-- 当前地图是否为地牢地图
	-- actor_unit.is_dungeon_map()
	-- 取当前远征等级
	-- actor_unit.get_expedition_level()
	-- 远征等级状态是否已领取
	-- actor_unit.is_receive_expedition_reward(level)
	-- 领取远征奖励
	-- actor_unit.get_expedition_reward(level)

	-- 职业选择
	-- 职业窗品是滞打开
	-- actor_unit.get_class_preview_canvas() ~= 0
	-- 体验职业（职业ID为创建 主职业ID 对应+ 1 2 3）
	-- actor_unit.preview_class(职业ID)
	-- 退出体验职业
	-- actor_unit.exit_prieview_class()
	-- 选择职业 （职业ID为创建 主职业ID 对应+ 1 2 3）
	-- actor_unit.select_class(职业ID)
	-- 复活（1 原地 2 复活点，  可原地次数 item_unit.get_money_byid(6)）
	-- actor_unit.rise_man(1)
	-- 小退游戏
	-- actor_unit.leave_game()

end

-------------------------------------------------------------------------------------
---材料背包
-- test_pocket_item
function example:test_pocket_item()
	local list = item_unit.pocket_item_list()
	xxmsg(string.format('物品数量%u', #list))
	for i = 1, #list do 
		local obj = list[i]
		if item_ctx:init_pocket_item_obj(obj) then 
			xxmsg(string.format("%X   res_id:%X    num:%06d    name:%s", 
				obj,
				item_ctx:pocket_item_res_id(),
				item_ctx:pocket_item_num(),
				item_ctx:name()

			))
		end

	end

	--材料背包物品资源ID取数量
	--item_unit.get_pocket_item_num_by_res_id(res_id)

end

-------------------------------------------------------------------------------------
-- test_item_unit 
function example:test_item_unit(item_type)
	local item_obj = item_unit:new()
	local list = item_unit.list(item_type)  -- 0 背包 1 身上装备 2生活装备（生活装备包背包ID0x15）
	xxmsg(string.format('物品数量%u', #list))
	for i = 1, #list do 
		local obj = list[i]
		if item_obj:init(obj) then 
			xxmsg(string.format('obj:%16X  res_ptr:%16X  id:%08X  res_id:%08X  pos:%03u  type:%03u  num:%04u  quality:%03u  level:%02u  durability:[%05u-%05u]  equip_level:%06d  trade_level:%06d    eq_pable_level:%02u  name:%s',
				obj,
				item_obj:res_ptr(),
				item_obj:id(),
				item_obj:res_id(),
				item_obj:pos(),
				item_obj:type(),
				item_obj:num(),
				item_obj:quality(),
				item_obj:level(),
				item_obj:durability(),
				item_obj:max_durability(),
				item_obj:equip_level(),
				item_obj:trade_level(),
				item_obj:equippable_level(), -- 使用等级
				item_obj:name()
			))
			-- 装备精练信息
			if item_type == 1 then 
				xxmsg(string.format('    精练数据  en_lv:%03d  cur_exp:%08d   up_exp:%08d   up_need_exp:%08d  up_rate:%05d    stuff_rate:%05d',
					item_obj:equip_enchance_lv(),		-- 精练等级
					item_obj:equip_enchance_exp(),		-- 当前总的成长经验（前面所有等级总各）
					item_obj:equip_up_exp(),			-- 精练下一级需要总成长经验
					item_obj:up_need_exp(),				-- 当前精练所需要经验
					item_obj:equip_enchance_rate(),		-- 精练基础 成功率 （除以一百为看到的）
					item_obj:enchance_stuff_rate()		-- 精练辅助材料单个增加成功率（星辰之息）（除以一百为看到的）
				))
			end

			if item_obj:is_marble() then   -- 是否为能力石 
				local main_type_num = item_obj:get_marble_main_type_num() --  总类型数
				xxmsg("能力石类型总数："..main_type_num)
				for i = 0, main_type_num - 1 do 
					local engraving_num = item_obj:get_engraving_num(i) -- 能力石序号取刻印总数（0开始。）
					xxmsg(string.format("        主序号：%02d  刻印数:%02d   是否刻印满:%-6s", i, engraving_num, item_obj:is_engraving_full(i)))
					for j = 0, engraving_num - 1 do 
						local engraving_status = item_obj:get_engraving_status(i, j)  -- 能力石刻印状态(主序号012， 刻印序号0开始紫0到7) (反回0未刻印1 成功 2 失败)
						xxmsg(string.format("            main_type:%02d    engraving_idx:%02d    engraving_status%02d",i, j, engraving_status ))
					end
				end
			end

		end

	end
	item_obj:delete()
	-- 背包ID = 0， 身上装备1  生活装备包背包ID 0x15
	--item_unit.move_item(开始背包ID,位置,目标背包ID,位置)
	-- 物品冷确时间（物品资源ID）
	--xxmsg(item_unit.get_item_cooldown(0x2E63E))
	-- 使用物品主要用于使用药书之类的
	--item_unit.use_item(3)
	-- 取金钱 1同2金
	-- item_unit.get_money_byid(id)
	-- 取指定位置物品指针
	-- item_unit.get_item_ptr_bypos(bagId, pos)
	-- 设置分解装备(item_pos) 把要分解的都添加完一步确认
	-- item_unit.set_decompose(0x9)
	-- item_unit.set_decompose(0xA)
	-- 确认分解装备
	-- item_unit.confirm_decompose()
	-- 删除物品（物品id）
	--item_unit.del_item(0x5C40000000098D3)
	-- 身上装备评分等级
	-- item_unit.get_equip_prop_level()

	-- 精练
	-- item_unit.equip_enchance(id, 星辰数量，背包ID)
	-- 成长（和谐碎片数量= item_unit.get_money_byid(13)）
	-- --item_unit.equip_stage(id, 成长数, 背包ID)
	-- 判断精练窗口是否打开
	-- item_unit.is_open_item_build_up_wnd()

	-- 箱子物品
	-- if item_unit.has_bs_item_wnd() then 
		-- 领取箱子物品
	-- 	item_unit.receive_all()
	-- end
	-- 选择类箱子物品
	-- if item_unit.has_bs_select_wnd() then 
	-- 	-- 领取 选择的物品资源ID
	-- 	item_unit.receive_select_item(0x3f0a361)
	-- end

	-- 取能力石强化窗口
	-- item_unit.get_marble_wnd()
	-- 能力石成功(序号有三条就是0 1 2 从上往下)
	-- item_unit.marble_growup(item_id, main_idx)


end

-------------------------------------------------------------------------------------
-- test_skill_unit
function example:test_skill_unit()
	local skill_obj = skill_unit:new()
	local list = skill_unit.list()
	xxmsg('技能数量：'..#list)
	for i = 1, #list do 
		local obj = list[i]
		if skill_obj:init(obj) then 
			xxmsg(string.format('obj:%16X  res:%16X  id:%08X  level:%02u  next_point:%04u mp:%04d  cd:%0.2f  name:%s',
				obj,
				skill_obj:res_ptr(),
				skill_obj:id(),
				skill_obj:level(),
				skill_obj:up_next_level_point(),  -- 升级所需点
				skill_obj:consume_mp(),
				skill_obj:cd_time(),
				skill_obj:name()
		))
		end
	end

	-- 快捷建技能ID
	for i = 0, 7 do 
		local id = skill_unit.get_quick_skill_id_byidx(i)
		xxmsg(string.format('id:%X   cd:%0.1f', id, skill_unit.get_cd_time_byid(id))) -- CD时间
	end

	-- 设置技能快捷(ID = 0 取消)
	-- skill_unit.set_skill_quick_slot(id, 0-7)
	-- 取当前技能配置序号
	-- skill_unit.get_skill_config_idx()
	-- 剩余技能点
	-- skill_unit.get_remain_point()
	-- 升级技能
	-- skill_unit.upgrade_skill(id, tar_level)

	-- 生活技能
	-- 生命气息
	-- skill_unit.get_life_energy()
	-- 生活技技能等级(01234567) 
	-- skill_unit.get_life_skill_lv(id)
	-- 生活技技能经验(01234567) 
	-- skill_unit.get_life_skill_exp(id)
	-- 生活技技能最大经验(01234567) 
	-- skill_unit.get_life_skill_max_exp(id)
end

-------------------------------------------------------------------------------------
-- 方舟通行证
function example:test_ark_pass_reward_unit()
	-- 取通行证等级
	 local ark_pass_level =  actor_unit.get_ark_pass_level()
	 for  i = 1, ark_pass_level do
	 	-- 判断对应等级通行证奖励是否领取
	 	if not actor_unit.ark_pass_reward_is_receive(i) then
			xxmsg(i)
	 		sleep(3000)
	 		-- 领取指定等级等通行证奖励(第一个奖是0，第二个是1)
	 		actor_unit.get_ark_pass_reward(i, 0)
	 	end
	 end
end

----------------------------------------------------------------------------------------
-- test_sign_unit
function example:test_sign_unit()
	xxmsg(sign_unit.get_sign_wnd())
	-- 取签道窗口
	if sign_unit.get_sign_wnd() == 0 then
		-- 打开签到窗
		sign_unit.open_sign_wnd()
	end

	sleep(3000)
	if  sign_unit.get_sign_wnd() ~= 0 then
		-- 取主签到类型数（目前只有1个）
		local sign_main_type_num = sign_unit.get_main_sign_type_num()
		for i = 0, sign_main_type_num - 1 do
			-- 序号取是否有可签到物品（目前只有1个）
			if sign_unit.can_sign_by_idx(i) then
				-- 序号领取所有签到（目前只有1个） 等以后加多类型签到的时候联系技术处理该命令
				sign_unit.click_get_all_reward(i)
				sleep(3000)
			end
		end
	end


	-- 热点签到
	for i = 0, 5 do
		--判断是否可领取(目前主ID是1， 序号0-5) 状态：0 可领取 3是没激活 1 已领取 -1 不存在的序号
		if sign_unit.get_hot_sign_status(1, i) == 0 then
			-- 领取热点签到(目前主ID是1， 序号0-5)
			sign_unit.get_hot_sign_reward(1, i)
			sleep(3000)
		end
	end

end

-------------------------------------------------------------------------------------
-- test_quest_unit
function example:test_quest_unit()
	local list  = quest_unit.list()
	xxmsg('任务数量：'..#list)
	for i = 1, #list do 
		local obj = list[i]
		if quest_ctx:init(obj) then 
			xxmsg(string.format('obj:%16X  id:%08X  idx:%02d  status:%02d  branch_num:%02d  map:%-20s  name:%s',
				obj,
				quest_ctx:id(),
				quest_ctx:idx(),
				quest_ctx:status(),
				quest_ctx:branch_num(),
				quest_ctx:map_name(),
				quest_ctx:name()
			))

			local branch_num = quest_ctx:branch_num()
			xxmsg(' 	分支数：'..branch_num)
			for i = 0, branch_num-1 do 
				xxmsg(string.format('		 tar_type:%d   tar_num:%04d - %04d   tar_status:%02d   branch_name:%s',
					quest_ctx:tar_type(i),
					quest_ctx:cur_tar_num(i),
					quest_ctx:cur_tar_max_num(i),
					quest_ctx:target_status(i),
					quest_ctx:branch_name(i)
			))
			--	local str2 = '[\''..quest_ctx:branch_name(i)..'\'] = {'
			end
		end
	end

	-- 取完任务ID列表（地图ID，-1所有完成任务不建义用）
	-- local complate_list = quest_unit.get_complate_quest_id_list(-1)
	-- for i = 1 , #complate_list do 
	-- 	local id = complate_list[i]
	-- 	xxmsg(string.format("%X     %s", id, quest_unit.get_quest_name_byid(id)))
	-- quest_unit['get_quest_name_byid'](quest_unit,id)
	-- end


	-- 接受任务
	--quest_unit.accept(id)
	-- 完成任务(奖励序号不选 的为-1  别的是1开始。。还是0)
	--quest_unit.complete(quest_id,reward_idx)
	-- 处理任务事件(出接或完成框 自动处理完成或接受，完成的必须是不选 奖励的)
	-- quest_unit.do_quest_event()
	-- 任务对话下一步(接受或完成没出来可以一直下一步)（打开对话，和判断在actor_unit单元）
	-- quest_unit.quest_talk_next()
	-- 当前任务对话的任务ID
	-- quest_unit.get_talk_quest_id()
	-- 当前任务对话状态(2接，3完成，4对话)
	-- quest_unit.get_talk_quest_status()
	-- 读取是否有接受和完成窗口(不等于0有窗口)
	-- quest_unit.get_quest_summary_wnd()
	-- 取指定NPC任务列表(使用方法如下)
	--quest_unit.get_npc_quest_list_by_resid(npc_res_id);


end

-- 分割64位数高低位
function split64(num)
    local mask = 0xFFFFFFFF 
    local low32 = num & mask  
    local high32 = (num >> 32) & mask  
    return high32, low32
end
-- 测式获取NPC任务 （后面主要用来盘支线任务可不可以接）
function example:test_get_npc_quest_list(npc_res_id)
	-- 取NPc上的任务(操作)
	local list  = quest_unit.get_npc_quest_list_by_resid(npc_res_id);
	for i = 1, #list do 
		local quest = list[i]
		-- type 2 接，3完成，4对话
		local quset_id, type = split64(quest)
		xxmsg(string.format("%08X    %d", quset_id, type))
	end

end

-------------------------------------------------------------------------------------
-- test_dungeon_unit 
function example:test_dungeon_unit()
	-- 该功能 用任务中的踩点副本
	-- 取进入副本窗口(问号副本)
	-- if dungeon_unit.get_solo_dun_enter_wnd()~= 0 then 
	-- --点击进入副本
	-- 	dungeon_unit.click_enter_dungeon()
	-- 	sleep(3000)
	-- --有门的任务副本窗品检测
	-- elseif dungeon_unit.get_dungeon_entrance_wnd() then 
	-- 	--点击进入
	-- 	xxmsg(dungeon_unit.click_bing_enter_btn())
	-- 	sleep(3000)
	-- end
	-- --确认进入副本对话框状态 (包括混沌)
	-- if dungeon_unit.get_dun_dialog_status() > 0 then 
	-- --确认进入副本
	-- 	dungeon_unit.confirm_enter_dungeon()
	-- end

	local list = dungeon_unit.list()
	for i = 1, #list do
		local obj = list[i]
		if dungeon_ctx:init(obj) then 
			xxmsg(string.format("obj:%X   main_id:%02d   sub_id:%02d  equip_level:%06d  name:%s  ",
				obj,
				dungeon_ctx:main_id(),
				dungeon_ctx:sub_id(),
				dungeon_ctx:equip_level(),
				dungeon_ctx:name()
		))
		end
	end

	-- 	取共鸣
	-- xxmsg(dungeon_unit.get_fatigue_value())
	-- 请求进入混沌（必须窗品打开）
	-- dungeon_unit.req_enter_dungeon(main_id, sub_id)
	-- 打开混沌窗（必须打开玩法目录）
	-- dungeon_unit.open_dungeon_wnd()
	-- 判断 混沌窗是否打开
	-- dungeon_unit.get_dungeon_wnd() ~=0
	-- 判断副本完成窗口
	-- dungeon_unit.has_result_norma_frame

	-- 测式打开混沌窗代码
	-- if dungeon_unit.get_dungeon_wnd()==0 then 
	-- 	if not ui_unit.is_open_play_dir_wnd() then 
	-- 		-- 打开玩法目录
	-- 		 main_ctx:do_alt_key(81)
	-- 		 sleep(3000)
	-- 	end

	-- 	if ui_unit.is_open_play_dir_wnd() then 
	-- 		-- 打开混沌窗
	-- 		dungeon_unit.open_dungeon_wnd()
	--    end

	-- end

	-- 判断副本是否结束 测式稳定性（）
	-- dungeon_unit.dungeon_is_over()

	-- 读取副本剩余时间
	-- dungeon_unit.get_dungeon_remaining_time()

end

-------------------------------------------------------------------------------------
-- test_map_unit
function example:test_map_unit(map_id)
	local transfer_list	= map_unit.get_transfer_list_by_mapid(map_id)
	xxmsg("传送点："..#transfer_list)
	for i = 1, #transfer_list do 
		local obj = transfer_list[i]
		xxmsg(obj)
		if map_ctx:init(obj) then 
			xxmsg(string.format("obj:%16X   res_ptr%16X   id:%08X   res_id:%08X    is_active:%-6s    name:%s ",
				obj,
				map_ctx:res_ptr(),
				map_ctx:id(),		-- 环境Id
				map_ctx:res_id(),   -- 传送使用id
				map_ctx:is_active(),-- 是否激活
				map_ctx:name()
		))
		end
	end

	-- 传送
	-- map_unit.transfer(res_id)
	-- 激活传送 该对象是环境6里面的对象可用资源ID匹配
	-- map_unit.active_transfer(obj)
end

----------------------------------------------------------------------------------------
-- test_emotes_unit  测式表情单元
function example:test_emotes_unit()
	-- 取表情ID列表
	local emotes_id_list = emotes_unit.emotes_id_list()
	for i = 1, #emotes_id_list do 
		local id = emotes_id_list[i]
		xxmsg(id.."----"..emotes_unit.get_emotes_name_byid(id))

	end
	-- 使用表情
	--emotes_unit.use_emotes(id)
end

----------------------------------------------------------------------------------------
-- test_music_unit  乐谱
function example:test_music_unit()
	local music_id_list = music_unit.music_id_list()	
	for i = 1, #music_id_list do 
		local id = music_id_list[i]
		xxmsg(string.format('id:%08X  cd_time:%0.1f  type:%d  is_active:%-6s name:%s',
			id,
			music_unit.music_cd_time(id),
			music_unit.music_type(id),    -- 类型三为副本类地图使用
			music_unit.music_is_active(id), -- 是否激活
			music_unit.music_name_byid(id)
	))
	end

	-- 使用乐谱
	--music_unit.use_music(id)
end

----------------------------------------------------------------------------------------
-- test_vehicle_unit    坐骑
function example:test_vehicle_unit()
	local list = vehicle_unit.list()
	xxmsg(#list)
	for i = 1, #list do 
		local obj = list[i]
		if vehicle_ctx:init(obj) then 
			xxmsg(string.format('obj:%16X   id:%08X   ride:%-6s   name:%s',
				obj,
				vehicle_ctx:id(),
				vehicle_ctx:is_ride(),
				vehicle_ctx:name()
		))
		end
	end
	-- 上下马
	-- vehicle_unit.riding(id)
	-- 是否骑行中
	-- vehicle_unit.is_riding()
	-- 当前骑马ID
	-- vehicle_unit.get_cur_riding_id()

end

----------------------------------------------------------------------------------------
-- test_shop_unit
function example:test_shop_unit()
	local list = shop_unit.list()
	xxmsg('数量：'..#list)
	for i = 1, #list do 
		local obj = list[i]
		if shop_ctx:init(obj) then 
			xxmsg(string.format('obj:%X  res_ptr %X  res_id:%08X    idx:%03d   price:%08d   name:%s',
					obj,
					shop_ctx:res_ptr(),
					shop_ctx:res_id(),
					shop_ctx:idx(),				-- 主要用于购买
					shop_ctx:price(),
					shop_ctx:name()
		))
		end
	end

	-- 判断修理窗是否打开(talk_npc 打开)
	-- shop_unit.is_open_repair_wnd()
	-- 修理所有装备
	-- shop_unit.repair_all_equip()
	-- 判断商店是否打开 talk_npc 打开
	-- shop_unit.is_open_shoping()
	-- 添加购买物品（可添加多样后 再确认购买）
	-- shop_unit.add_buy_item(idx, num)
	-- 确认购买
	-- shop_unit.confirm_buy_item()
	-- 添加出售物品(pos 为背包中的位置)
	-- shop_unit.add_sell_item(item_pos)
	-- 确认出售物品
	-- shop_unit.confirm_sell_item()

	-- 判断兑换商 
	-- shop_unit.is_open_barter_shop()
	-- 兑换商店购买
	-- shop_unit.buy_barter_item(id, num)

end

----------------------------------------------------------------------------------------
-- test_daily_quest  0日常  1周常 
function example:test_daily_quest(quest_type)
	local list = daily_unit.list(quest_type)
	for i = 1, #list do 
		local obj = list[i]
		if daily_ctx:init(obj) then 
			xxmsg(string.format('obj:%X   id:%08X   can_accept:%02d   is_accept:%02d    equip_level:%06d   map:%-20s   name:%s',
				obj,
				daily_ctx:id(),
				daily_ctx:can_accept(),		-- 可接		
				daily_ctx:is_accept(),		-- 已接（已接后在当前任务列表里有数据）
				daily_ctx:equip_level(),
				daily_ctx:map_name(),
				daily_ctx:name()
		
		
		))
		end
	end

	-- 接受任务
	--daily_unit.accept(id)
	-- 完成任务(idx 没有选择奖励为-1)
	--daily_unit.complate(id, idx)

	-- 打开日常窗口
	-- if not daily_unit.is_open_daily_wnd()  then 
	-- 	if not ui_unit.is_open_play_dir_wnd() then 
	-- 		-- 打开玩法目录
	-- 		 main_ctx:do_alt_key(81)
	-- 		 sleep(3000)
	-- 	end

	-- 	if ui_unit.is_open_play_dir_wnd() then 
	-- 		-- 打开日常窗口
	-- 		daily_unit.open_daily_wnd()
	--    end

	-- end

	-- 日常完成次数
	--daily_unit.get_daily_quest_complate_num()
	-- 日常最大次数
	--daily_unit.get_daily_quest_max_num()
	-- 周常完成次数
	--daily_unit.get_week_quest_complate_num()

	-------------------------------------------------------------------------------------
	-- 注以下命令除了领所要进入日常 窗口别的读取都不用

	-- 领取贡献奖励（从上往下0-4）
	--daily_unit.receive_reward(idx)
	-- 领取所有奖励
	--daily_unit.receive_all_reward()
	-- 取当前日常贡献点
	--daily_unit.get_contribute_point()
	-- 奖励是否已激活（0 - 4 注：这是的激活是贡献点达到，已领取后也为激活 ）
	--daily_unit.reward_is_active(idx)
	-- 奖励是否已领（0-4）
	--daily_unit.reward_is_receive(idx)
	-- 是否有可领取奖励
	--daily_unit.has_reward()

end

----------------------------------------------------------------------------------------
-- test_ship_unit
function example:test_ship_unit()
	local list = ship_unit.list()
	for i = 1, #list do 
		local obj = list[i]
		if ship_ctx:init(obj) then 
			xxmsg(string.format('obj:%X   res_ptr:%X    id:%08X   durable:[%05d  -  %05d], is_select:%-6s   name:%s',
			obj,
			ship_ctx:res_ptr(),
			ship_ctx:id(),
			ship_ctx:durable(),
			ship_ctx:max_durable(),
			ship_ctx:is_select(),  -- 停靠界面才能正常 
			ship_ctx:name()
		
		))
		end
	end
	xxmsg('当前船支耐久:'..ship_unit.get_cur_ship_durable()..' 最大耐久:'..ship_unit.get_cur_ship_max_durable()..' 船锚窗口:'..tostring(ship_unit.is_open_anchor_frame()))
	-- 入港
	-- ship_unit.ship_into_port()
	-- 出港
	-- ship_unit.ship_leave_potr()
	-- 选择船支
	-- ship_unit.select_ship(id)
	-- 修理船支
	-- ship_unit.repair_cur_ship()
	-- 当前选择船支
	-- ship_unit.get_cur_select_ship_id()  -- 停靠 界面才能读取
	-- 当前船支耐久
	-- ship_unit.get_cur_ship_durable()
	-- 当前船 只最大耐久
	-- ship_unit.get_cur_ship_max_durable()
	-- 停靠船锚窗口是否打开
	-- ship_unit.is_open_anchor_frame()
	-- 装备出港
	-- ship_unit.prepare_into_port()
	-- 是否船海中
	-- ship_unit.is_in_ocean()
	example:test_crew()
end

----------------------------------------------------------------------------------------
-- test_crew
function example:test_crew()
	local list = ship_unit.crew_list()
	for i = 1, #list do 
		local id = list[i]
		xxmsg(string.format("id:%8X   equip_idx:%02d   name:%s",
		id,
		ship_unit.get_crew_equip_idx(id),   -- 使用在当前选择船支的序号，-1 为未使用
		ship_unit.get_crew_name(id)
	
	))
	end

	-- 配备船员(当前选择船) 配备的时候注意里面好像有个专用船员
	-- ship_unit.equip_crew(crew_id)
	-- 卸载船员(当前选择船)
	-- ship_unit.unload_crew(crew_id)
	

end

----------------------------------------------------------------------------------------
-- test_pet_unit
function example:test_pet_unit()
	local list = pet_unit.list()
	
	xxmsg('宠物数：'..#list)
	for i = 1, #list do 
		local obj = list[i]
		
		if pet_ctx:init(obj) then 
			xxmsg(string.format('obj:%X    id%16X   is_summon:%-6s   name:%s',
				obj,
				pet_ctx:id(),
				pet_ctx:is_summon(),
				pet_ctx:name()
		
		))
		end
	end
	
	-- 召唤 宠物
	--pet_unit.summon(id)
	-- 当前召唤宠物ID
	--pet_unit.get_cur_summon_id()
end

----------------------------------------------------------------------------------------
-- test_exchange_trade
function example:test_exchange_trade()
	-- 交易行搜索
	exchange_unit.trade_search_item("破坏石碎片")
	sleep(4000)
	-- 取得搜索数量
	local search_num = exchange_unit.get_trade_search_item_num()
	for i = 0, search_num - 1 do 
		xxmsg(string.format('id:%16X  res_id:%08X    lowest_num:%08d   price:%08d  type:%02d   name:%s ',
		exchange_unit.get_trade_search_item_id(i),       -- id
		exchange_unit.get_trade_search_item_res_id(i),	 -- res_id
		exchange_unit.get_trade_search_item_lowest_num(i),-- 最低价数量
		exchange_unit.get_trade_search_item_price(i),	  -- 单价
		exchange_unit.get_trade_search_item_type(i),      -- 类型（购买要用）
		exchange_unit.get_trade_search_item_name(i)		  -- 名称
	))
	end

	xxmsg("---------------------交易行了出售列表-----------------------")
	-- 取出售数量
	local sell_num = exchange_unit.get_trade_sell_num()
	for i = 0, sell_num - 1 do 
		xxmsg(string.format('id:%16X  res_id:%08X    lowest_num:%08d   price:%08d  name:%s ',
		exchange_unit.get_trade_sell_item_id(i),       		-- id
		exchange_unit.get_trade_sell_item_res_id(i),	 	-- res_id
		exchange_unit.get_trade_sell_item_surplus_num(i),	--剩余数量
		exchange_unit.get_trade_sell_item_price(i),	  		-- 单价
		exchange_unit.get_trade_sell_item_name(i)		 	 -- 名称
	))
	end

	-- 交易行上架窗口
	--exchange_unit.open_trade_up_wnd()
	-- 交易行上架窗口是否打开
	--exchange_unit.trade_up_wnd_is_open()
	-- 交易行上架物品（要打开上架窗口）上架物品(数量单位实际（比如一捆 数量为10）， 时间类型 0 = 1天 1 = 3天  单价。。以捆为单为的就是捆的单价  个为单位的 为一个单价)
	--exchange_unit.trade_up_item(item_id, 单价, 数量, 时间类型)
	-- 交易行下架物品
	--exchange_unit.trade_down_item(id)
	-- 交易行购买物品(真实数量，以捆为单位 比如买一捆 数量为10)
	--exchange_unit.trade_buy_item(id, res_id, num , 商品类型,单价)
	-- 交易行选择页面（0搜索，1关注 2 我的交易 ）
	-- exchange_unit.get_trade_select_group_idx()
	-- 切换交易行选择页（0搜索，1关注 2 我的交易 ）
	-- cxchange_unit.trade_change_group(0-3)

	----------------------公用-------------------

	-- 取当有选择交易行类型（0交易行1拍卖行）
	--exchange_unit.get_exchang_sel_group()
	-- 切换交易行类型（0交易行1拍卖行）
	--exchange_unit.change_exchange(1)
	-- 取交易行窗口（该窗口是整个大交易行的窗口）
	--exchange_unit.get_exchange_shop_wnd（）

end

----------------------------------------------------------------------------------------
-- test_exchange_auction
function example:test_exchange_auction()
	-- 拍卖行搜索
	exchange_unit.auction_search_item("缘分弓弩")
	sleep(4000)
	-- 取得搜索列表
	local list = exchange_unit.auction_item_list()
	for i = 1, #list do
		
		xxmsg(string.format("id:%16X   res_id:%08X  lowest_price:%06d   now_price:%06d   %s",
		list[i].id,
		list[i].item_res_id,
		list[i].lowest_price,  -- 最低价
		list[i].now_price,     -- 最高价
		list[i].name
	))
	end

	xxmsg("--------------------------------出售列表-----------------------------------------")
	-- 取出售数量
	local sell_num = exchange_unit.get_auction_sell_item_num()
	for i = 0, sell_num-1 do 
		xxmsg(string.format('id:%16X  res_id:%08X    cur_price:%08d   max_price:%08d  name:%s ',
			exchange_unit.get_auction_sell_item_id(i),       		-- id
			exchange_unit.get_auction_sell_item_res_id(i),	 		-- res_id
			exchange_unit.get_auction_sell_item_cur_price(i),		--当前价
			exchange_unit.get_auction_sell_item_max_price(i),	 	-- 一口价
			exchange_unit.get_auction_sell_item_name(i)		 	 	-- 名称
		))
	end

	-- 检测上架窗口
	-- exchange_unit.auction_up_wnd_is_open()
	-- 打开上回窗口
	-- exchange_unit.auction_open_up_wnd()
	-- 拍卖行物品上架（时间类型0 一天 1 三天）
	-- exchange_unit.auction_up_item(item_id, 起拍价, 一口价, 时间类型)
	-- 拍卖行物品下架
	-- exchange_unit.auction_down_item(商品id)
	-- 拍卖行购买物品（竟拍价=最高价自动一口价购买）
	-- exchange_unit.auction_buy_item(商品id, 竟拍价格)
	-- 当前选择拍卖行group 序号（0搜索拍卖行开始从左往右0-5）
	-- excahgne_unit.get_cur_auction_grorp_idx()
	-- 切换拍卖行group（0搜索拍卖行开始从左往右0-5）
	-- exchange_unit.auction_change_group(0-5)

end

----------------------------------------------------------------------------------------
-- test_mail_unit
function example:test_mail_unit()
	-- 发送邮件（收件人, 标题 ，类容，类型（0快第，1普通）， 发送金币，收取金币，物品位置列表｛0，1，2｝）
	--mail_unit.send_mail("曾许人间·第一流", '标题','类容',0,5,0,{0,1})
	local action = {
		['自定义动作名'] = {
			-- 执行条件
			pre_condition = {
				['执行开关'] = false,
				['执行条件'] = {

				},
			},
			-- 执行功能函数
			execute      = {
				['函数对象'] = mail_unit, -- 函数对象名称  函数指针名
				['函数名称'] = 'send_mail', -- 函数对象下的函数名称 string
				['所需参数'] = { 'girl', '标题','类容',0,5,0,{ 0,1 } },
			},
			-- 检测是否成功
			compare = {
				['函数对象'] = item_unit, -- 函数对象名称  函数指针名
				['函数名称'] = 'get_money_byid', -- 函数对象下的函数名称 string
				['所需参数'] = { 1 },  -- 函数所需要的参数,当前函数下所需参数
			},
		},
	}
	-- 条件【达成】  动作所需参数  动作  条件【成功】

	-- 读取快递窗口（NPC）
	--mail_unit.get_mail_wnd()
	-- 当前选择Group类型（0 收件列表，1发件列表，2 邮件发送页）
	--mail_unit.get_select_mail_wnd_type()
	-- 选择邮件Group 类型（0 收件列表，1发件列表，2 邮件发送页）
	--mail_unit.select_mail_group()


	-- 是否有可领取邮件物品()
	--xxmsg(mail_unit.has_receive_mail())
	-- 取邮件数（普通和快递总数）
	--xxmsg(mail_unit.get_mail_num())
	--  领取全部邮件(一页最大七份 领取后自动删除)
	--xxmsg(mail_unit.get_all_mail())


	-- 是否有快递邮件
	-- if mail_unit.has_quick_mail() then 
		-- 快递邮件读取窗口是否打开
	-- 	if not  mail_unit.is_open_quick_mail_read_wnd() then 
			-- 打开快递邮读取窗
	-- 		mail_unit.open_quick_mail_read_wnd()	
	-- 		sleep(3000)
	-- 	end
	-- 领取快递邮件（一直0  里面带了自动删除 ）
	-- 	mail_unit.receive_quick_mail(0)
	-- end
end

----------------------------------------------------------------------------------------
-- test_all
function example:test_all()
		
end

-------------------------------------------------------------------------------------
-- 实例化新对象
function example.__tostring()
    return "lostark example package"
 end

example.__index = example

function example:new(args)
   local new = { }

   if args then
      for key, val in pairs(args) do
         new[key] = val
      end
   end

   -- 设置元表
   return setmetatable(new, example)
end

-------------------------------------------------------------------------------------
-- 返回对象
return example:new()

-------------------------------------------------------------------------------------