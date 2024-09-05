-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   test
-- @describe: 测试模块
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
---@class test
local test = {
    VERSION = '20211016.28',
    AUTHOR_NOTE = "-[test module - 20211016.28]-",
    MODULE_NAME = '测试模块',
}
local import          = import
-- 自身模块
local this            = test
-- 配置模块
local settings        = settings
-- 日志模块
local trace           = trace
-- 决策模块
local decider         = decider
local common          = common
local dungeon_res     = import('game/resources/dungeon_res')
local login_res       = import('game/resources/login_res')
---@type equip_ent
local equip_ent       = import('game/entities/equip_ent')
local actor_ent       = import('game/entities/actor_ent')
local helper          = import('base/helper')
---@type ui_ent
local ui_ent          = import('game/entities/ui_ent')
local item_res        = import('game/resources/item_res')
-- 任务单元
---@type quest_ent
local quest_ent       = import('game/entities/quest_ent')
---@type item_ent
local item_ent        = import('game/entities/item_ent')
---@type shop_ent
local shop_ent        = import('game/entities/shop_ent')
---@type map_ent
local map_ent         = import('game/entities/map_ent')
---@type pet_ent
local pet_ent         = import('game/entities/pet_ent')
-- 导入公用库
---@type example
local example         = import('example/example')
---@type ship_ent
local ship_ent        = import('game/entities/ship_ent')
local map_res         = import('game/resources/map_res')
---@type user_set_ent
local user_set_ent    = import('game/entities/user_set_ent')
---@type hunt_ent
local hunt_ent        = import('game/entities/hunt_ent')
---@type map_area_res
local map_area_res    = import('game/resources/map_area_res')
local quest_res       = import('game/resources/quest_res')
local utils           = import('base/utils')
---@type dungeon_ent
local dungeon_ent     = import('game/entities/dungeon_ent')
local configer        = import('base/configer')
---@type switch_user_ent
local switch_user_ent = import('game/entities/switch_user_ent')
---@type life_yield_ent
local life_yield_ent  = import('game/entities/life_yield_ent')
local daily_quest_ent = import('game/entities/daily_quest_ent')
local life_yield_res  = import('game/resources/life_yield_res')
---@type other_task_ent
local other_task_ent  = import('game/entities/other_task_ent')
---@type sign_ent
local sign_ent        = import('game/entities/sign_ent')
---@type music_ent
local music_ent       = import('game/entities/music_ent')
---@type test_ent
local test_ent        = import('game/entities/test_ent')
---@type mail_ent
local mail_ent        = import('game/entities/mail_ent')
---@type dungeon_stars_guard_ent
local dungeon_stars_guard_ent = import('game/entities/dungeon_stars_guard_ent')
-- 运行前置条件
this.eval_ifs = {
    -- [启用] 游戏状态列表
    yes_game_state = { login_res.STATUS_IN_GAME , login_res.STATUS_LOADING_MAP , login_res.STATUS_IN_GAME2 },
    -- [禁用] 游戏状态列表
    not_game_state = {},
    -- [启用] 配置开关列表
    yes_config     = {},
    -- [禁用] 配置开关列表
    not_config     = {},
    -- [时间] 模块超时设置(可选)
    time_out       = 0,
    -- [其它] 特殊情况才用(可选)
    is_working     = function()
        return true
    end,
    -- [其它] 功能函数条件(可选)
    is_execute     = function()
        return true
    end,
}

-- 轮循函数列表
test.poll_functions = {}

-- 坐标说明
-- 正上边扩展【x + 扩展值,y + 扩展值】
-- 左上边扩展【x + 扩展值,y】
-- 正左边扩展【x + 扩展值,y - 扩展值】
-- 左下边扩展【x ,y - 扩展值】
-- 正右边扩展【x - 扩展值,y + 扩展值】
-- 右上边扩展【x,y + 扩展值】
-- 正下边扩展【x - 扩展值,y - 扩展值】
-- 右下边扩展【x - 扩展值,y】

local show_task = '空' --黄昏之爪
-------------------------------------------------------------------------------------
-- 功能入口函数
test.entry = function()
    local polygon = {
        ['鬃波港'] = { x = 2745, y = 13285, z = -144 },--false
    }
    --common.key_call('KEY_D')
    --common.key_call('KEY_LeftMouseButton')
    --common.key_call('KEY_RightMouseButton')

    -- KEY_LeftMouseButton  KEY_RightMouseButton -- 鼠标左右键不点击
    -- music_unit.music_name_byid(id)    -- 读取为空
    -- map_unit.transfer(res_id)  -- 不能传送 .不确定是 返回的res_id问题还是此命令问题
    -- pet_ctx:is_summon()        -- 始终为假
    local util = import('base/util')
     xxmsg(util:get_random_ex())
    -- item_ent.auto_del_item()
    -- example:test_mail_unit()
   -- xxmsg(configer.get_user_profile_today_and_nextday_hour('副本记录', '讨伐星辰'..local_player:name()))
    local read_str = common.get_cache_result_ex('fb_讨伐星辰',configer.get_user_profile_today_and_nextday_hour,10,'副本记录', '讨伐星辰'..local_player:name())
    -- xxmsg('read_str:'..read_str)
    --obj:1ACAB89E0  class:EFSkeletalMeshActor_457   id:3704D249   res_id:93F99   level:000  hp[000000-000000]  battle:false   dead:false   pos[10445.0, 13651.0, 514.0] dist:44.2 type7_status:1  can_attack:false   can_talk:false  is_valid:false  name:
    -- mail_ent.execute_send_mail()
    --if ui_unit.has_dialog() then
    --    decider.sleep(500)
    --    ui_unit.confirm_dialog(true)
    --    decider.sleep(1000)
    --end
    -- dungeon_unit.open_raid_entrance_wnd()
    -- decider.sleep(50000)
    -- example:test_item_unit(0)
    -- example:test_skill_unit()
    -- main_ctx:post_key(89,1)
   --  helper.encrypt_and_pack()
   --  ui_unit.debug(false)

    --local anchorFrame = ui_unit.get_parent_widget('dungeonEntranceWnd', true)
    --local rightContent = ui_unit.get_child_widget(anchorFrame, 'closeBtn')
    --local moveBtn = 0x0000000269BE7050 --ui_unit.get_child_widget(rightContent, 'conditionBtn') -- 入港
    --xxmsg(anchorFrame..' '..rightContent..' '..moveBtn)
    --if moveBtn ~= 0 then
    --    ui_unit.do_click(moveBtn)
    --end
    --  dungeon_stars_guard_ent.start_stars_guard()
    -- ui_ent.repair_ship()
    -- item_ent.decompose_equip()
    -- ['银波湖'] = { x = 21395, y = 16986, z = 2692 },--false
    -- map_ent.check_move(21395,16986,2692)
    -- example:test_item_unit(0)
    -- example:test_shop_unit()
    -- item_ent.auto_use_item()
    -- shop_ent.move_to_enhance_equip()
    if not music_ent.is_active_music('共鸣之歌') then
    --    shop_ent.buy_barter_item('海上乐园佩托','物品交换','共鸣之歌',1)
    end


    -- example:test_shop_unit()
    -- test_ent.show_unit_info_list()
    -- item_ent.deco_item()
   -- xxmsg(map_ent.get_best_power_city())
   -- example:test_item_unit(0)
   -- item_ent.auto_use_item()


   -- xxmsg(anchorFrame..' /'..titleBtn..' '..bt_disassembly)

    --obj:        DF930000  id:004D0EF5  idx:01  status:01  branch_num:01  map:寂静岛             name:谁在那里？

    -- example:test_ship_unit()
    example:test_get_npc_quest_list(0x32C9)
    -- example:test_item_unit(0)

    --map_ent.move_curr_map_by_area_res(5341.0, 5042.0,-4068.73)
    -- sign_ent.execute_sign()
    -- ui_ent.auto_sort_bag()

    local list = item_res.get_box_info_by_sel_name('破坏石碎片(绑定)')
    for _,name in pairs(list) do
        xxmsg(_..'----'..name)
    end
    -- shop_ent.move_to_enhance_equip()
    xxmsg(string.format('0x%X',item_res.get_res_id_by_box_name_and_sel_name('守护石结晶袋子','守护石结晶(绑定)')))
    -- ui_unit.debug(false)
    -- example:test_ark_pass_reward_unit()
   -- ui_ent.close_ui()
    -- example:test_ship_unit()
    --['奥兹霍丘陵'] = { x = 12487.0, y = 11294.0, z = 1032 },--false
    -- example:test_daily_quest(1)
    user_set_ent.load_user_info()
     daily_quest_ent.receive_reward()

    --example:test_daily_quest(0)
    -- shop_ent.buy_item(nil,'杂货商人','苍天福袋',2)
    --xxmsg(other_task_ent.is_need_accept_task())
    xxmsg('is_finish_quest_by_map_id_and_name:'..tostring(quest_ent.is_finish_quest_by_map_id_and_name('冰封之海彼岸',11102)))
    xxmsg('日常完成次数:'..daily_unit.get_daily_quest_complate_num()..' 日常最大次数:'..daily_unit.get_daily_quest_max_num())
    xxmsg('周常完成次数:'..daily_unit.get_week_quest_complate_num())
    xxmsg('混沌剩余时间：'..dungeon_unit.get_dungeon_remaining_time()..' 生命气息:'..skill_unit.get_life_energy())

    -- common.key_call('KEY_F5')
    --item_ent.auto_use_item()

    -- item_ent.decompose_equip()
    --
    -- example:test_item_unit(2)
    --
    -- example:test_ship_unit()
    quest_ent.finish_task()
    print_pos(show_task)
    -- example:test_daily_quest(0)
    -- 执行生活产出
    -- life_yield_ent.auto_do_life('采矿',1)

    -- 生活技技能等级(01234567)
    xxmsg('生活技技能 采矿等级:'..life_yield_res.get_life_lv_by_name('采矿'))
    xxmsg('-----------------------')
    xxmsg('游戏连接状态：'..game_unit.get_connect_status())

    -- item_ent.use_item_by_name('陈旧的伐木工具（斧头）')
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
    -- example:test_dungeon_unit()

    -- example:test_daily_quest(1)
    xxmsg('人物状态：'..actor_unit.get_local_player_status())
   -- local interactionMainFrame = ui_unit.get_parent_widget('interactionMainFrame', true)
   -- if interactionMainFrame ~= 0 then  -- 结束专职
   --     xxmsg('interactionMainFrame:'..interactionMainFrame)
   --     local guideBookBtn = ui_unit.get_child_widget(interactionMainFrame, 'guideBookBtn')
   --     xxmsg('guideBookBtn '..guideBookBtn)
   --     --  ui_unit.do_click(guideBookBtn)
   -- end
    local level = actor_unit.get_expedition_level()
    if not actor_unit.is_receive_expedition_reward(level) then
    --    actor_unit.get_expedition_reward(level)

    end
    --['霜狱高原'] = { x = 6411.0, y = 29101.0, z = 3786 },--false00063E0D    2
    --['寂静岛'] = { x = 9416, y = 2705, z = -82 },--false
    --obj:        46610000  id:004D0EF5  idx:01  status:01  branch_num:01  map:寂静岛             name:谁在那里？
    --obj:1279D8010  class:EFNonPlayer_468    id:2AC812AB   res_id:4028   level:050  hp[006083-006083]  battle:false   dead:false   pos[6479.0, 28982.0, 3787.0]   dist:137.1   type7_status:0  true   is_valid:false  name:灰狼团罗姆利
    local other_task = { { task_name = '任务名称',npc_name = '希里安',npc_res_id = 0x32C9,quest_id = 0xC3964,map_name = '卢特兰城',area_name = '卢特兰王宫',x = 17838, y = -40, z = -14236,kill_dis = 200 },}
    -- quest_ent.accept_task(other_task)
    -- example:test_ship_unit()
    -- ship_ent.require_ship()
    -- example:test_item_unit(1)
   --   example:test_actor_unit(8)
    xxmsg(main_ctx:c_job())
    -- xxmsg(local_player:dist_xy(13796, 14468))
    -- actor_unit.move_to(local_player:cx() + 100,local_player:cy() ,local_player:cz(),0)


    -- dialog对话框
    --ui_unit.has_dialog()
    -- --确认对话(false 取消)
    --ui_unit.confirm_dialog(true)

    -- ['沉默巨人之森'] = { x = 8854.4345703125, y = 7895.927734375, z = -3428 },--false

 -- -- --
 -- -- -- -- 1487.0 - 1000, y = 9652     ---16467.0, y = 17793.0
 --map_ent.move_curr_map_by_area_res(-15900.0, 17793.0,6552)
 -- -- -- -- 20594.0, y = 5799.0
 -- -- -- map_ent.move_curr_map_by_area_res(22128.0, 5793.0,-4068.73)
 -- -- --  -- map_ent.move_to_lifter_go_up(0x10CE59,15,17146.6, 14555.0,2558,17863,14559,3585,3550)
 -- -- ---- map_ent.move_to_lifter_go_down(0x10CE59,15,17691.6, 14537.0,3585,16988,14559,2559,2570)
 -- -- ---- map_ent.check_moving_obj()

    --example:test_crew()
    --ship_ent.sel_ship_in_crew('埃施')
    -- ['大岩林'] = { x = 2589.0, y = 3931.0, z = -294 },--false vehicle_ent.auto_riding_vehicle(actor_num,cx,cy)
    -- map_ent.move_curr_map_by_area_res(2589.00,3931.00,-294.73)
    --  map_ent.move_curr_map_by_area_res(14830.00,6911.00,35.73)

    local s = { 0,2,3,4,5,6,7,8,9,10,11,12,13,14,15 ,16,17,18,19,20,21,22}
    for _,v in pairs(s) do
        example:test_actor_unit(v) -- 怪物
    end
    --
    --while decider.is_working() do
    --    -- map_ent.move_to_kill_actor(nil,1200)
    --    local str = '{ x = '..local_player:cx()..', y = '..local_player:cy()..' },--'..tostring(utils.is_point_in_polygon(local_player:cx(), local_player:cy(), polygon))
    --    xxmsg(str..' '..map_area_res.get_area_name()..' 战：'..tostring(actor_ent.is_battle()))
    --    decider.sleep(1000)
    --end
    --example:test_ship_unit()
    --example:test_crew()
    --ship_ent.sel_ship_by_name()

    example:test_quest_unit()
    local pos_path = {
        { x = 12961, y = 9837, z = 758,r = 300,kill_r = 300,['操作'] = { res_id = 0x1ADC8,type = 8,wait_to = {} },['击杀'] = {{ name = '',type = 2,res_id = 0 }},['区域'] = {} },--IDX = 0
        { x = 13074, y = 10328, z = 509,r = 300,kill_r = 300,['操作'] = { res_id = 0,type = 8,wait_to = {} },['击杀'] = {{ name = '',type = 2 },{ type = 2,res_id = 0x1ADB5 }},['区域'] = {} },--IDX = 0
        { x = 14004, y = 10421, z = 511,r = 300,kill_r = 1000,['操作'] = { res_id = 0,type = 8,wait_to = {} },['击杀'] = {{ name = '',type = 2 },{ type = 2,res_id = 0x1ADB5 }},['区域'] = {} },--IDX = 0
        { x = 14643, y = 10478, z = 511,r = 300,kill_r = 300,['操作'] = { res_id = 0,type = 8,wait_to = {} },['击杀'] = {{ name = '',type = 2,res_id = 0 }},['区域'] = {} },--IDX = 0
        { x = 15225, y = 11335, z = 511,r = 300,kill_r = 500,['操作'] = { res_id = 0,type = 8,wait_to = {} },['击杀'] = {{ name = '',type = 2,res_id = 0 }},['区域'] = {} },--IDX = 0
        { x = 16112, y = 10929, z = 511,r = 300,kill_r = 500,['操作'] = { res_id = 0,type = 8,wait_to = {} },['击杀'] = {{ name = '',type = 2,res_id = 0 }},['区域'] = {} },--IDX = 0
        { x = 16544, y = 9907, z = 511,r = 300,kill_r = 500,['操作'] = { res_id = 0,type = 8,wait_to = {} },['击杀'] = {{ name = '',type = 2,res_id = 0 }},['区域'] = {} },--IDX = 0
    }
   -- example:test_actor_unit(8) -- 怪物
   -- map_ent.execute_move_by_path(pos_path,pos_path[#pos_path].x,pos_path[#pos_path].y,pos_path[#pos_path].z,500)


    xxmsg('是否在航海中【'..tostring(ship_unit.is_in_ocean())..'】')

    xxmsg('是否在地牢:'..tostring(actor_unit.is_dungeon_map()))
    xxmsg('当前地图ID:'..actor_unit.map_id())
    xxmsg('当前地图名:'..actor_unit.map_name())
    xxmsg('当前区域 地图名:'..actor_unit.sub_map_name())
    xxmsg('当前小场景地图名:'..actor_unit.get_cur_scene_map_name())
    xxmsg('取当前远征等级:'..actor_unit.get_expedition_level())
    example:test_map_unit(actor_unit.map_id())

    while decider.is_working() do
    	-- common.mouse_move(-14938- 1000.0, -6616.0, 939.2,1)
    	--for i = 1,20 do
    	--	if actor_unit.has_progress_bar(i) then
    	--		xxmsg(i)
    	--	end
    	--end
    	xxmsg('[\''..actor_unit.map_name()..'\'] = { x = '..local_player:cx()..', y = '..local_player:cy()..', z = '..math.floor(local_player:cz())..' },--'..tostring(local_player:is_move())..'  '..map_area_res.get_area_name())

    	--xxmsg('game_status:'..string.format('0x%X',game_unit.game_status())..' get_connect_status:'..game_unit.get_connect_status())
    	sleep(100)
    end

    -- quest_ent.submit_task('圣疗师阿帕埃','光明留驻的村庄',0)
    -- xxmsg(quest_ent.get_quest_id_by_task_name('花的主人'))
    --		 tar_type:3   tar_num:0000 - 0001   tar_status:00   branch_name:向冒险家协会会长<FONT COLOR='#FF973A'>鲁汀</FONT>就石板碎片进行询问
    -- quest_ent.get_npc_quest_list(actor_ent.get_npc_res_id('涅莉亚'))
    -- ui_unit.debug(false)

end

function print_pos(show_task)
    local name = show_task and show_task ~= '' and show_task
    local x = math.floor(local_player:cx())
    local y = math.floor(local_player:cy())
    local z = math.floor(local_player:cz())
    local map_name = actor_unit.map_name()
    local map_id   = math.floor(actor_unit.map_id())
    xxmsg('---------遍历NPC任务-------------')
    -- 获取最近NPC信息
    local info_list = actor_ent.get_nearest_actor_info_list()
    for _,v in pairs(info_list) do
        if v.npc_can_talk and v.dist < 500 then
            local list   = quest_unit.get_npc_quest_list_by_resid(v.res_id)

            for i = 1, #list do
                local quest = list[i]
                -- type 2 接，3完成，4对话
                local id,q_type = common.split64(quest)
                 xxmsg(id..' '..q_type)
                if q_type == 2 then
                    local str2 = '= { { task_name = \'任务名称\',npc_name = \''..v.name..'\',npc_res_id = '..string.format('0x%X',v.res_id)..',quest_id = '..string.format('0x%X',id)..',map_name = \''..map_name..'\',area_name = \'\',x = '..x..', y = '..y..', z = '..z..',kill_dis = 200 },}'
                    xxxmsg(3,'other_task '..str2)
                    xxxmsg(3,'--------------------------------------------------------------------------------')
                    xxxmsg(3,'[\'任务名称\'] '..str2)
                end
            end
        end
    end
    xxmsg('---------任务信息----------------')
    show_quest(name,map_name,map_id,x,y,z)
    xxmsg('---------输出生活坐标-------------')
    local str = 'idx = MAP：'..map_name..',MID：'..map_id..',X：'..x..',Y：'..y..',Z：'..z..',NLV：1,MLV：100,R：100,LINE：1,LV：0,TIME：0'
    xxxmsg(2,str)
    xxmsg('---------输出挂机坐标-------------')
    local str = 'idx = MAP：'..map_name..',MID：'..map_id..',X：'..x..',Y：'..y..',Z：'..z..',NLV：1,MLV：100,R：100,LINE：1,TIME：0'
    xxxmsg(2,str)
    xxmsg('---------输出坐标1---------------')
    xxmsg('{ x = '..x..', y = '..y..' },')
    xxmsg('---------输出坐标2---------------')
    xxmsg('[\''..map_name..'\'] = { x = '..x..', y = '..y..', z = '..z..' },--'..tostring(local_player:is_move()))
    xxmsg('---------输出路径----------------')
    xxxmsg(2,'pos_path = {')
    xxxmsg(2,'--【说明】action:默认空为普通,1升降,2船,r:在当前节点读取操作物的范围,kill_r:自身寻路时的打怪范围,calc_z:怪物与自身的Z比值,wait_to:{x=0,y=0,z=0},wait_time:操作目标后的等待时间默认1秒')
    xxxmsg(2,' { x = '..x..', y = '..y..', z = '..z..',r = 300,kill_r = 300,[\'操作\'] = { res_id = 0,type = 8,wait_to = {} },[\'击杀\'] = {{ name = \'\',type = 2,res_id = 0 }},[\'区域\'] = {} },--IDX = 0')
    xxxmsg(2,'},')

    xxmsg('---------岛屿信息----------------')
    xxmsg('[\''..map_name..'\'] = {')
    xxmsg('[\'所属大陆\'] = \''..map_name..'\',')
    xxmsg('[\'地图ID\'] = '..map_id..',')
    xxmsg('[\'码头\'] = {')
    xxmsg('[\'进港\'] = {  x = '..x..', y = '..y..', z = '..z..',call = \'KEY_G\' },')
    xxmsg('[\'出港\'] = { x = '..x..', y = '..y..', z = '..z..',call = \'KEY_G\' },')
    xxmsg('},')
    xxmsg('},')

end

function show_quest(name,map_name,map_id,x,y,z)
    local list        = quest_unit.list()
    local info_list   = actor_ent.get_nearest_actor_info_list()
    local gather_info = actor_ent.get_nearest_gather_info_list()
    for j = 1, #list do
        local obj = list[j]
        if quest_ctx:init(obj) and ( not name or name and string.find(quest_ctx:name(),name) ) then
            if name then
                xxmsg('[\''..quest_ctx:name()..'\'] = {')
                xxmsg('[\'任务类型\']  = \'特殊\',')
            end
            local branch_num = quest_ctx:branch_num()
            for i = 0, branch_num-1 do
                xxxmsg(3,'[\"'..quest_ctx:branch_name(i)..'\"] = {')
                xxxmsg(3,'map_pos    = { map_name = \''..map_name..'\', map_id = '..map_id..', area_name = \'\' },')
                xxxmsg(3,'move_to    = { x = '..x..', y = '..y..', z = '..z..', r = 100 },')
                if info_list and info_list[1] and info_list[1].name then
                    if gather_info and gather_info.res_id and gather_info.dist < info_list[1].dist then
                        xxxmsg(3,'gather     = { { name = '..string.format('0x%X',gather_info.res_id)..',type = 6,read_r = 500 } }')
                    else
                        xxxmsg(3,'talk       = { npc_name = \''..info_list[1].name..'\', sel_idx = -1 },')
                    end
                else
                    if gather_info and gather_info.res_id then
                        xxxmsg(3,'gather     = { { name = '..string.format('0x%X',gather_info.res_id)..',type = 6,read_r = 500 } }')
                    end
                end
                xxxmsg(3,'},')
            end
            if name then
                xxmsg(' },')
            end
        end
    end
end
------------------------------------------------------------------------------------
-- 预载函数(重载脚本时)
test.super_preload = function()

end

-------------------------------------------------------------------------------------
-- 预载处理
test.preload = function()
    settings.log_level        = 2
    settings.log_type_channel = 3
    -- common.test_connect()
end

-------------------------------------------------------------------------------------
-- 模块超时处理
test.on_timeout = function()
    -- 非排队状态时超时-重启
    if not login_unit.is_waiting_game() then
        xxmsg('。。。。。登陆模块处理超时。。。。。')
        main_ctx:end_game()
    end
end

-------------------------------------------------------------------------------------
-- 定时调用入口
test.on_timer = function(timer_id)
    --xxmsg('login.on_timer -> '..timer_id)
end

-------------------------------------------------------------------------------------
-- 卸载处理
test.unload = function()
    --xxmsg('login.unload')
end

-------------------------------------------------------------------------------------
-- 实例化新对象

function test.__tostring()
    return this.MODULE_NAME
end

test.__index = test

function test:new(args)
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
    return setmetatable(new, test)
end

-------------------------------------------------------------------------------------
-- 返回对象
return test:new()

-------------------------------------------------------------------------------------