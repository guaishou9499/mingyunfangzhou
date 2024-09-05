local VERSION = '20211031' -- version history at end of file
local AUTHOR_NOTE = "-[20211031]-"
---@class shop_ent
local shop_ent = {
    VERSION     = VERSION,
    AUTHOR_NOTE = AUTHOR_NOTE,
}
local this         = shop_ent
local decider      = decider
local shop_unit    = shop_unit
local actor_unit   = actor_unit
local shop_ctx     = shop_ctx
local local_player = local_player
local item_unit    = item_unit
local mail_unit    = mail_unit
local quest_unit   = quest_unit
local table        = table
local pairs        = pairs
local math         = math
local trace = trace
---@type shop_res
local shop_res = import('game/resources/shop_res')
---@type item_res
local item_res = import('game/resources/item_res')
---@type item_ent
local item_ent = import('game/entities/item_ent')
---@type actor_ent
local actor_ent = import('game/entities/actor_ent')
---@type map_ent
local map_ent = import('game/entities/map_ent')
---@type equip_res
local equip_res = import('game/resources/equip_res')
---@type map_res
local map_res = import('game/resources/map_res')
---@type common
local common = import('game/entities/common')
---@type exchange_ent
local exchange_ent = import('game/entities/exchange_ent')
---@type ui_ent
local ui_ent       = import('game/entities/ui_ent')
--item_unit.get_pocket_item_num_by_res_id(0x43852E5)
------------------------------------------------------------------------------------
-- [行为] 购买金币
------------------------------------------------------------------------------------
function shop_ent.buy_gold(can_buy_func)
    -- 是否可购买
    if can_buy_func and not can_buy_func() then
        return
    end
    -- 最小兑换积分
    local min_jf   = 500
    -- 当前地图信息
    local map_name = actor_unit.map_name()
    -- 判断信物数量
    if item_unit.get_pocket_item_num_by_res_id(0x43852E5) < min_jf then
        return
    end
    -- 最近的商人信息
    local main_city = map_res.get_main_city(map_name)
    if main_city == '' then
        return false
    end
    local merchant_info = shop_res.MERCHANT_NPC[main_city]
    if table.is_empty(merchant_info) then
        return false
    end
    local npc_list_info = merchant_info['金币商店']
    if table.is_empty(npc_list_info) then
        return false
    end
    local npc_info = npc_list_info[1]
    local map_id = map_ent.get_map_id_by_map_name(main_city)
    if not npc_info.active_name or not map_ent.is_active_by_map_id_and_transfer_name(map_id,npc_info.active_name)  then
        return
    end
    while decider.is_working() do
        -- npc坐标
        local npc_cx = npc_info.npc_pos.x
        local npc_cy = npc_info.npc_pos.y
        local npc_cz = npc_info.npc_pos.z
        if item_unit.get_pocket_item_num_by_res_id(0x43852E5) < min_jf then
            break
        end
        if local_player:dist_xy(npc_cx, npc_cy) < 300 then
            if shop_unit.is_open_barter_shop() then
                local buy_name = ''
                local xinwu = item_unit.get_pocket_item_num_by_res_id(0x43852E5)
                if xinwu >= 500 then
                    buy_name = '巨大的金币箱子'
                elseif xinwu >= 200 then
                    buy_name = '小金库'
                elseif xinwu >= 80 then
                    buy_name = '丰厚的金币袋子'
                end
                -- 通过商品名字获取商品信息
                local potion_info = this.get_goods_info_by_any(buy_name, 'name')
                if not table.is_empty(potion_info) then
                    trace.output('购买【' .. buy_name .. '】')
                   xxxmsg(2,'购买【' .. buy_name .. '】')
                    -- 添加购买
                    shop_unit.buy_barter_item(potion_info.idx, 1)
                    decider.sleep(2000)
                end
            else
                -- 打开NPC出售窗口
                this.open_barter_shop(npc_info.npc_name)
            end
        else
            map_ent.move_curr_map_to(main_city, '', npc_cx, npc_cy, npc_cz, 300)
        end
        decider.sleep(1000)
    end
    shop_ent.close_barter_shop_wnd()
end

------------------------------------------------------------------------------------
-- [行为] 兑换指定物品
------------------------------------------------------------------------------------
function shop_ent.buy_barter_item(map_name,shop_type,item_name,buy_num)
    map_name = map_name or actor_unit.map_name()
    while decider.is_working() do
        -- 读取指定地图的商店NPC资源记录
        local shop_list = shop_res.MERCHANT_NPC[map_name]
        -- 没有资源退出
        if table.is_empty(shop_list) then break end
        -- 读取指定类型的NPC资源
        local info_list = shop_list[shop_type]
        -- 没有指定类型的NPC资源退出
        if table.is_empty(info_list) then
            break
        end
        -- 选择第一个序号的目标资源
        local info      = info_list[1]
        -- 获取兑换的限制数据
        local sell_item = info.sell_item
        -- 设置货币默认ID
        local money_id  = 1
        -- 设置可以购买的最大数量
        local can_buy   = 9999
        -- 设置所需消耗量
        local money     = 1
        if not table.is_empty(sell_item) then
            local name_sell = sell_item[item_name]
            if not table.is_empty(name_sell) then
                -- 此物品对应的所需货币ID
                money_id = name_sell.money_id or money_id
                -- 此物品限制购买数
                can_buy  = name_sell.can_buy or can_buy
                -- 此物品所需货币数量
                money    = name_sell.money
            end
        end
        -- 获取货币数量
        local c_gold      = item_unit.get_money_byid(money_id)
        -- 计算当前货币可兑换最大数量
        local can_buy_num = math.floor(c_gold/money)
        -- 退出兑换
        if can_buy_num <= 0 then
            break
        end
        -- 当前货币可兑数量大于限制数时
        if can_buy_num > can_buy then
            can_buy_num = can_buy
        end
        -- 背包指定物品信息
        local item_num = item_ent.get_item_num_by_name(item_name,nil,true)
        -- 计算可兑换数
        local need_buy = buy_num - item_num
        -- 需要兑换数大于可兑时，设置需要购买为可兑数
        if need_buy > can_buy_num then
            need_buy = can_buy_num
        end
        -- 退出兑换
        if need_buy <= 0 then
            break
        end
        -- 移动到指定位置
        if map_ent.move_to(map_name, info.scene_map_name, info.npc_pos.x, info.npc_pos.y, info.npc_pos.z, 200) then
            if this.open_barter_shop(info.npc_name) then
                -- 通过商品名字获取商品信息
                local potion_info = this.get_goods_info_by_any(item_name, 'name')
                if not table.is_empty(potion_info) then
                    trace.output('兑【' .. potion_info.name .. '】')
                    shop_unit.buy_barter_item(potion_info.idx, need_buy)
                    decider.sleep(2000)
                    common.wait_change_gold(c_gold,'兑换【' .. potion_info.name .. '】')
                end
            end
        end
        decider.sleep(1000)
    end
end

------------------------------------------------------------------------------------
-- [行为] 自动加工佩戴能力石
shop_ent.auto_process_use_marble = function()
    if local_player:level() < 50 then return false end
    -- 在地牢时退出
    if actor_unit.is_dungeon_map() then return false end
    -- 标记是否需使用,获取背包最佳能力石
    local can_use,bag_marble = item_ent.get_best_can_use_marble_info()
    -- 需要使用能力石
    if can_use then
        -- 检测是否需要加工
        if bag_marble.is_need_process then
            -- 去加工装备
            if this.move_to_process_marble() then
                bag_marble  = item_ent.get_best_marble_in_bag()
            end
        end
        -- 无需加工时佩戴
        if not bag_marble.is_need_process then
            local check_close = false
            this.close_marble_wnd()
            if ui_ent.open_bag() then
                trace.output('装备：',bag_marble.name)
                check_close = true
                item_unit.move_item(0,bag_marble.pos,1,11)
                decider.sleep(1000)
            end
        end
    end
end

------------------------------------------------------------------------------------
-- [行为] 自动购买需要的装备
------------------------------------------------------------------------------------
function shop_ent.auto_buy_equip()
    local map_name = actor_unit.map_name()
    local shop_list = equip_res.EQUIP_SHOP[map_name]
    if table.is_empty(shop_list) then
        return
    end
    local equip_merchant_list = shop_list['武器商人']
    local my_level = local_player:level()
    for i = 1, #equip_merchant_list do
        local can_sell_item = equip_merchant_list[i].sell_item
        local map_id = map_ent.get_map_id_by_map_name(map_name)
        for k, v in pairs(can_sell_item) do
            local buy = true
            if not v.active_name or not map_ent.is_active_by_map_id_and_transfer_name(map_id,v.active_name)  then
                buy = false
            end
            -- 角色等级小于装备等级
            if buy and my_level < v.ues_level then
                buy = false
            end
            -- 角色身上铜钱低于装备价格
            if buy and item_unit.get_money_byid(1) < v.money then
                buy = false
            end
            -- 当前装备装分高于商店装备
            if buy and item_ent.get_equip_level_by_pos(v.pos) >= v.equip_level then
                buy = false
            end
            if buy then
                this.buy_equip(map_name, equip_merchant_list[i], v.idx, k)
            end
        end
        this.close_shop_wnd()
    end
end

------------------------------------------------------------------------------------
-- [行为] 自动购买装备
------------------------------------------------------------------------------------
function shop_ent.buy_equip(map_name, merchant_info, idx, equip_name)
    while decider.is_working() do
        local equip_info = item_ent.get_item_info_by_name(equip_name, 0)
        if not table.is_empty(equip_info) then
            break
        end
        if map_name == actor_unit.map_name() then
            if local_player:dist_xy(merchant_info.npc_pos.x, merchant_info.npc_pos.y) < 300 then
                if shop_unit.is_open_shoping() then
                    -- 通过商品名字获取商品信息
                    local potion_info = this.get_goods_info_by_any(idx, 'idx')
                    if not table.is_empty(potion_info) then
                        trace.output('购买【' .. potion_info.name .. '】')
                        xxmsg('购买【' .. potion_info.name .. '】')
                        local c_gold = item_unit.get_money_byid(1)
                        -- 添加购买
                        shop_unit.add_buy_item(potion_info.idx, 1)
                        decider.sleep(2000)
                        -- 确认购买
                        shop_unit.confirm_buy_item()
                        decider.sleep(2000)
                        common.wait_change_gold(c_gold,'购买【' .. potion_info.name .. '】')
                    end
                else
                    -- 打开NPC出售窗口
                    this.open_shop_wnd(merchant_info.npc_name)
                end
            else
                map_ent.move_curr_map_to(map_name, merchant_info.scene_map_name, merchant_info.npc_pos.x, merchant_info.npc_pos.y, merchant_info.npc_pos.z, 500)
            end
        else
            map_ent.move_to_map(map_name)
        end
        decider.sleep(1000)
    end
end

------------------------------------------------------------------------------------
-- [行为] 购买指定物品
------------------------------------------------------------------------------------
function shop_ent.buy_item(map_name,shop_type,item_name,buy_num,trigger_num)
    map_name = map_name or actor_unit.map_name()
    local is_close = false
    while decider.is_working() do
        local shop_list = shop_res.MERCHANT_NPC[map_name]
        if table.is_empty(shop_list) then break end
        local info_list = shop_list[shop_type]
        if table.is_empty(info_list) then break end
        -- 背包指定物品信息
        local item_num = item_ent.get_item_num_by_name(item_name,nil,true)
        if trigger_num then
            if item_num > trigger_num then break end
        end
        local need_buy = buy_num - item_num
        if need_buy <= 0 then
            break
        end
        local info     = info_list[1]
        if map_ent.move_to(map_name, info.scene_map_name, info.npc_pos.x, info.npc_pos.y, info.npc_pos.z, 200) then
            if shop_unit.is_open_shoping() then
                is_close = true
                -- 通过商品名字获取商品信息
                local potion_info = this.get_goods_info_by_any(item_name, 'name')
                if not table.is_empty(potion_info) then
                    trace.output('购买【' .. potion_info.name .. '】')
                    local c_gold = item_unit.get_money_byid(1)
                    -- 添加购买
                    shop_unit.add_buy_item(potion_info.idx, need_buy)
                    decider.sleep(2000)
                    -- 确认购买
                    shop_unit.confirm_buy_item()
                    decider.sleep(2000)
                    common.wait_change_gold(c_gold,'购买【' .. potion_info.name .. '】')
                end
            else
                -- 打开NPC出售窗口
                this.open_shop_wnd(info.npc_name)
            end
        end
        decider.sleep(1000)
    end
    if is_close then
        this.close_shop_wnd()
    end
end

------------------------------------------------------------------------------------
-- [行为] 维修装备
------------------------------------------------------------------------------------
shop_ent.repair_equip = function()
    -- 当前地图信息
    local map_name = actor_unit.map_name()
    -- 当前地图最近的修理工
    local npc_info = this.get_near_my_repair_info(map_name)

    if table.is_empty(npc_info) then
        return
    end

    while decider.is_working() do
        -- 判断是否有装备需要维修
        if not shop_ent.can_repair_equip() then
            break
        end
        -- npc坐标
        local npc_cx = npc_info.npc_pos.x
        local npc_cy = npc_info.npc_pos.y
        local npc_cz = npc_info.npc_pos.z
        if local_player:dist_xy(npc_cx, npc_cy) < 330 then
            if shop_unit.is_open_repair_wnd() then
                local c_gold = item_unit.get_money_byid(1)
                shop_unit.repair_all_equip()
                decider.sleep(2000)
                common.wait_change_gold(c_gold,'维修装备')
            else
                -- 加拍卖行
                exchange_ent.exchange()
                -- 打开NPC维修窗口
                this.open_repair_wnd(npc_info.npc_name)
            end
        else
            map_ent.move_curr_map_to(map_name, npc_info.scene_map, npc_cx, npc_cy, npc_cz, 300)
        end
        decider.sleep(1000)
    end
    shop_ent.close_repair_wnd()
end

------------------------------------------------------------------------------------
-- [行为] 购买药水
------------------------------------------------------------------------------------
function shop_ent.buy_potion()
    -- 当前地图信息
    local map_name = actor_unit.map_name()
    -- 购买药品名
    local hp_name = this.get_can_by_potion_by_map(map_name)
    if hp_name == '' then
        return
    end
    -- 最近的商人信息
    local npc_info = this.get_near_my_potion_info(hp_name, map_name)
    if table.is_empty(npc_info) then
        return
    end
    while decider.is_working() do
        -- npc坐标
        local npc_cx = npc_info.npc_pos.x
        local npc_cy = npc_info.npc_pos.y
        local npc_cz = npc_info.npc_pos.z
        local need_b = 100
        if hp_name == '初级治疗药水' then
            need_b = 50
        end
        -- 购买药品数量
        local buy_num = need_b - item_ent.get_item_num_by_name(hp_name,nil,true)
        -- xxmsg(need_b..' '.. item_ent.get_item_num_by_name(hp_name, 0))
        -- 药品单价
        local money = item_res.POTION_MONEY[hp_name].money
        -- xxmsg(hp_name..' '..buy_num..' '..money..' '..item_unit.get_money_byid(1))
        -- 可购买数量
        local can_buy_num = this.calc_num(buy_num, money)
        -- 判断可购买数量小于50退出
        if can_buy_num < 50 then
            break
        end
        map_ent.move_curr_map_to(map_name, '', npc_cx, npc_cy, npc_cz, 320)
        if local_player:dist_xy(npc_cx, npc_cy) < 320 then
            if this.open_shop_wnd(npc_info.npc_name) then
                -- 通过商品名字获取商品信息
                local potion_info = this.get_goods_info_by_any(hp_name, 'name')
                if not table.is_empty(potion_info) then
                    trace.output('购买【' .. can_buy_num .. '个【' .. hp_name .. '】')
                    xxxmsg(2,'购买【' .. can_buy_num .. '个【' .. hp_name .. '】')
                    -- 添加购买
                    shop_unit.add_buy_item(potion_info.idx, can_buy_num)
                    decider.sleep(2000)
                    local c_gold = item_unit.get_money_byid(1)
                    -- 确认购买
                    shop_unit.confirm_buy_item()
                    decider.sleep(2000)
                    common.wait_change_gold(c_gold,'购买【' .. hp_name .. '】')
                end
            end
        end
        decider.sleep(1000)
    end
    shop_ent.close_shop_wnd()
end

------------------------------------------------------------------------------------
-- [行为] 强化装备
------------------------------------------------------------------------------------
shop_ent.move_to_enhance_equip = function()
    local map_name  = actor_unit.map_name()

    -- 获取最近的强化商人
    local main_city = map_res.get_main_city(map_name)
    if main_city == '' then
        return false
    end
    local merchant_info = shop_res.MERCHANT_NPC[main_city]
    if table.is_empty(merchant_info) then
        return false
    end
    local npc_list_info = merchant_info['装备精炼']
    if table.is_empty(npc_list_info) then
        return false
    end
    local npc_info      = merchant_info['装备精炼'][1]

    local map_id        = map_ent.get_map_id_by_map_name(main_city)
    if not npc_info.active_name or not map_ent.is_active_by_map_id_and_transfer_name(map_id,npc_info.active_name)  then
        return false
    end
    while decider.is_working() do
        local equip_info = this.have_can_enhance_equip_info()

        -- 没有可强化时退出
        if table.is_empty(equip_info) then
            break
        end
        -- npc坐标
        local npc_cx = npc_info.npc_pos.x
        local npc_cy = npc_info.npc_pos.y
        local npc_cz = npc_info.npc_pos.z
        -- 移动到指定位置
        if map_ent.move_to(main_city, npc_info.scene_map, npc_cx, npc_cy, npc_cz, 250) then
            if this.open_enhance_wnd(npc_info.npc_name) then
                this.enhance_equip(equip_info)
            end
        end
        decider.sleep(1000)
    end
    this.close_enhance_wnd()
end

------------------------------------------------------------------------------------
-- [行为] 强化指定部位装备
------------------------------------------------------------------------------------
shop_ent.enhance_equip = function(equip_info)
    if table.is_empty(equip_info) then
        return false
    end
    -- 精炼装备
    if equip_info.up_need_exp == 0 then
        -- 强化成功率
        local rate           = equip_info.equip_enchance_rate / 100
        -- 消耗星辰数量
        local need_stars_num = 0
        if rate < 70 then
            -- 获取每个强化石提升的几率
            need_stars_num = math.floor((70 - rate) / (equip_info.enchance_stuff_rate / 100))
            local curr_stars_num = 0
            if equip_info.jie == 2 then
                curr_stars_num = item_ent.get_item_num_by_name({ '星辰之息', '星辰之息(绑定)' }, 0,true)
            elseif equip_info.jie == 3 then
                curr_stars_num = item_ent.get_item_num_by_name({ '太阳之恩典', '太阳之恩典(绑定)', '太阳之祝福', '太阳之祝福(绑定)', '太阳之庇佑', '太阳之庇佑(绑定)' }, 0,true)
            end
            if need_stars_num > curr_stars_num then
                need_stars_num = curr_stars_num
            end
        end
        local c_gold = item_unit.get_money_byid(1)
        local str    = string.format('强化[%s]>到%s>消耗星辰-%s个', equip_info.name, equip_info.equip_enchance_lv + 1, need_stars_num)
        trace.output(str)
        item_unit.equip_enchance(equip_info.id, need_stars_num, 1)
        decider.sleep(2000)
        common.wait_change_gold(c_gold,'【' .. str .. '】')
    else
        -- xxmsg(equip_info.name..' equip_info.up_need_exp:'..equip_info.up_need_exp)
        local need_id = equip_info.jie == 3 and 14 or 13
        -- 成长装备
        local c_gold = item_unit.get_money_byid(need_id)
        local str = string.format('成长[%s]>使用碎片%s个', equip_info.name, equip_info.up_need_exp)
        trace.output(str)
        item_unit.equip_stage(equip_info.id, equip_info.up_need_exp, 1)
        decider.sleep(2000)
        common.wait_change_type(c_gold,str,30,item_unit.get_money_byid,need_id)
    end
end

------------------------------------------------------------------------------------
-- [行为] 加工能力石
------------------------------------------------------------------------------------
shop_ent.move_to_process_marble = function()
    local map_name = actor_unit.map_name()
    -- 获取最近的加工商人
    local main_city = map_res.get_main_city(map_name)
    if main_city == '' then
        return false
    end
    local merchant_info = shop_res.MERCHANT_NPC[main_city]
    if table.is_empty(merchant_info) then
        return false
    end
    local npc_list_info = merchant_info['能力石加工']
    if table.is_empty(npc_list_info) then
        return false
    end

    local npc_info = merchant_info['能力石加工'][1]
    local map_id = map_ent.get_map_id_by_map_name(main_city)

    if not npc_info.active_name or not map_ent.is_active_by_map_id_and_transfer_name(map_id,npc_info.active_name)  then
        return false
    end

    while decider.is_working() do
        local bag_marble  = item_ent.get_best_marble_in_bag()

        if table.is_empty(bag_marble) then
            return false
        end
        -- 无需加工
        if not bag_marble.is_need_process then
            return true
        end
        -- 银币不足2万退出
        if item_unit.get_money_byid(1) < 20000 then
            return false
        end
        -- npc坐标
        local npc_cx = npc_info.npc_pos.x
        local npc_cy = npc_info.npc_pos.y
        local npc_cz = npc_info.npc_pos.z
        if main_city == actor_unit.map_name() then
            if local_player:dist_xy(npc_cx, npc_cy) < 300 then
                -- 检测是否打开能力石加工窗口
                if item_unit.get_marble_wnd() ~= 0 then
                    for _,v1 in pairs(bag_marble.marble) do
                        xxmsg(string.format("        主序号：%02d  刻印数:%02d   是否刻印满:%-6s", v1.main_idx, v1.engraving_num, v1.is_engraving_full))
                        if not v1.is_engraving_full then
                            local engraving_info = v1.engraving_info
                            for _,v2 in pairs(engraving_info) do
                                -- 需要加工序列
                                if v2.engraving_status == 0 then
                                    trace.output('正在加工.'..v1.main_idx)
                                    item_unit.marble_growup(bag_marble.id, v1.main_idx)
                                    decider.sleep(1000)
                                end
                            end
                        end
                    end
                else
                    -- 打开能力石加工窗口
                    this.open_marble_wnd(npc_info.npc_name)
                end
            else
                this.close_marble_wnd()
                map_ent.move_curr_map_to(main_city, npc_info.scene_map, npc_cx, npc_cy, npc_cz, 100)
            end
        else
            map_ent.move_to_map(main_city)
        end
        decider.sleep(1000)
    end
    this.close_marble_wnd()
    return false
end

------------------------------------------------------------------------------------
-- [行为] 关闭NPC强化窗口
------------------------------------------------------------------------------------
shop_ent.close_enhance_wnd = function()
    return this.close_npc_wnd(item_unit.is_open_item_build_up_wnd,'NPC强化')
end

------------------------------------------------------------------------------------
-- [行为] 关闭NPC维修窗口
------------------------------------------------------------------------------------
shop_ent.close_repair_wnd = function()
    return this.close_npc_wnd(shop_unit.is_open_repair_wnd,'NPC维修')
end

------------------------------------------------------------------------------------
-- [行为] 关闭NPC出售窗口
------------------------------------------------------------------------------------
shop_ent.close_shop_wnd = function()
    return this.close_npc_wnd(shop_unit.is_open_shoping,'NPC出售')
end

------------------------------------------------------------------------------------
-- [行为] 关闭NPC兑换窗口
------------------------------------------------------------------------------------
shop_ent.close_barter_shop_wnd = function()
    return this.close_npc_wnd(shop_unit.is_open_barter_shop,'NPC兑换')
end

------------------------------------------------------------------------------------
-- [行为] 关闭能力石加工窗口
------------------------------------------------------------------------------------
shop_ent.close_marble_wnd = function()
    return this.close_npc_wnd(item_unit.get_marble_wnd,'能力石加工')
end

------------------------------------------------------------------------------------
-- [行为] 关闭邮寄窗口
------------------------------------------------------------------------------------
shop_ent.close_mail_wnd = function()
    return this.close_npc_wnd(mail_unit.get_mail_wnd,'邮件')
end

------------------------------------------------------------------------------------
-- [行为] 打开NPC强化窗口
------------------------------------------------------------------------------------
shop_ent.open_enhance_wnd = function(npc_name)
    return this.open_npc_need_wnd(npc_name,item_unit.is_open_item_build_up_wnd,'NPC强化')
end

------------------------------------------------------------------------------------
-- [行为] 打开NPC能力加工窗口
------------------------------------------------------------------------------------
shop_ent.open_marble_wnd = function(npc_name)
    return this.open_npc_need_wnd(npc_name,item_unit.get_marble_wnd,'能力加工')
end

------------------------------------------------------------------------------------
-- [行为] 打开NPC维修窗口
------------------------------------------------------------------------------------
shop_ent.open_repair_wnd = function(npc_name)
    return this.open_npc_need_wnd(npc_name,shop_unit.is_open_repair_wnd,'NPC维修')
end

------------------------------------------------------------------------------------
-- [行为] 打开NPC出售窗口
------------------------------------------------------------------------------------
shop_ent.open_shop_wnd = function(npc_name)
    return this.open_npc_need_wnd(npc_name,shop_unit.is_open_shoping,'NPC出售')
end

------------------------------------------------------------------------------------
-- [行为] 打开NPC兑换窗口
------------------------------------------------------------------------------------
shop_ent.open_barter_shop = function(npc_name)
    return this.open_npc_need_wnd(npc_name,shop_unit.is_open_barter_shop,'NPC兑换')
end

------------------------------------------------------------------------------------
-- [行为] 打开NPC快递窗口
------------------------------------------------------------------------------------
shop_ent.open_mail_wnd = function(npc_name)
    return this.open_npc_need_wnd(npc_name,mail_unit.get_mail_wnd,'邮件')
end


------------------------------------------------------------------------------------
-- [行为] 打开NPC所需窗口
------------------------------------------------------------------------------------
shop_ent.open_npc_need_wnd = function(npc_name,is_open_func,show_str)
    local idx    = 0
    local k_dis  = 200
    while decider.is_working() do
        if is_open_func() and is_open_func() ~= 0 then
            return true
        end
        local npc_info = actor_ent.get_actor_info_by_name(npc_name, 3)
        if table.is_empty(npc_info) then
            break
        end
        local w_time = 1000
        if npc_info.dist > 400 then
            k_dis = 150
        end
        if not map_ent.move_to_kill_actor(nil,k_dis) then
            if npc_info.dist > 300 then
                if not common.is_move() then
                    common.auto_move(npc_info.cx,npc_info.cy,npc_info.cz)
                end
            else
                actor_unit.npc_talk(npc_info.id, 1)
                trace.output('打开'..show_str..'窗口')
                local is_talk = false
                for i = 1, 10 do
                    -- xxmsg('get_cur_talk_npc_id:'..string.format('%X',actor_unit.get_cur_talk_npc_id()))
                    if is_open_func() and is_open_func() ~= 0 then
                        return true
                    end
                    decider.sleep(1000)
                    local list   = quest_unit.get_npc_quest_list_by_resid(npc_info.res_id)
                    if actor_unit.get_cur_talk_npc_id() ~= 0 and #list > 0 then
                        is_talk = true
                        common.do_shift_key('KEY_G')
                        common.key_call('KEY_G')
                        common.key_call('KEY_G')
                        common.key_call('KEY_G')
                        decider.sleep(1000)
                        ui_ent.exist_npc_talk()
                        decider.sleep(500)
                        break
                    end
                end
                -- 未打开  检测是否被攻击
                if not is_talk and ( not is_open_func() or is_open_func() == 0 ) then
                    idx = idx + 1
                    -- 检测附近怪物数量
                    local actor_num = actor_ent.get_actor_num_by_pos(nil,nil,nil,900,2)
                    if actor_num > 0 then
                        k_dis = 900
                    end
                end
            end
        else
            w_time = 100
        end
        if idx >= 10 then
            break
        end
        decider.sleep(1000)
    end
    return false
end

------------------------------------------------------------------------------------
-- [行为] 关闭NPC窗口
------------------------------------------------------------------------------------
shop_ent.close_npc_wnd = function(is_open_func,show_str)
    while decider.is_working() do
        if not is_open_func() or is_open_func() == 0 then
            break
        end
        trace.output('关闭'..show_str..'窗口')
        decider.sleep(1000)
        common.key_call('KEY_Esc')
        decider.sleep(1000)
        for i = 1, 10 do
            if not is_open_func() or is_open_func() == 0 then
                break
            end
            decider.sleep(1000)
        end
        decider.sleep(1000)
    end
end

------------------------------------------------------------------------------------
-- [判断] 判断装备是否可强化
------------------------------------------------------------------------------------
function shop_ent.can_enhance_equip(item_obj, pos,need_level)
    -- 判断装备品阶
    local level       = item_obj:level()
    -- 当前装备强化等级
    local enchance_lv = item_obj:equip_enchance_lv()
    if enchance_lv >= need_level then
        return false
    end

    local jie = 0
    if level >= 1250 then
        jie = 3
    elseif level >= 500 then
        jie = 2
    end
    -- 获取装备强化信息
    local enhance_equip_info = {}
    if pos == 0 then
        enhance_equip_info = equip_res.WEAPON_ENHANCE[jie] or {}
    else
        enhance_equip_info = equip_res.ARMOR_ENHANCE[jie] or {}
    end
    if table.is_empty(enhance_equip_info) then
        return false
    end
    -- 获取当前强化等级所需物品
    local enhance_need_items = enhance_equip_info[math.floor( enchance_lv )] or {}
    -- 无资源记录
    if table.is_empty(enhance_need_items) then
        return false
    end
    -- 获取强化时需要的成长碎片
    local need_enhance_chip_num = 0
    -- 获取强化成长碎片当前数量
    local have_enhance_chip_num = 0
    -- 判断身上强化需要的
    for _,v in pairs(enhance_need_items) do
        local item_num = 0
        local need_name = { v.name, v.name .. '(绑定)' }--is_bind
        if v.is_bind then
            need_name = { v.name .. '(绑定)' }--is_bind
        end
        if not table.is_empty(v.add_name) then
            local a_name = {}
            for _,name in pairs(v.add_name) do
                table.insert(a_name,v.name ..name)
            end
            need_name = a_name
        end
        if v.type == '材料' then
            item_num = item_ent.get_item_num_by_name(need_name,nil,true)
        elseif v.type == '货币' then
            item_num = item_unit.get_money_byid(v.money_id)
            if v.money_id == 14 or v.money_id == 13 then
                need_enhance_chip_num = v.num
                have_enhance_chip_num = item_num
            end
        end
        if item_num < v.num and not v.money_id then
            for _,name in pairs(need_name) do
                item_ent.open_box_by_sel_name( name,v.num )
            end
            item_num = item_ent.get_item_num_by_name(need_name,nil,true)
        end

        -- 存在一个条件未满足就退出
        if item_num < v.num then
            return false
        end
    end

    -- 判断强化需要的碎片
    if item_obj:up_need_exp() + need_enhance_chip_num > have_enhance_chip_num then
        return false
    end
    -- 消耗的银币大于身上持有
    if item_obj:up_need_exp() * 4 > item_unit.get_money_byid(1) then
        return false
    end

    return true,jie
end

------------------------------------------------------------------------------------
-- [判断] 判断是否有可强化的装备
------------------------------------------------------------------------------------
function shop_ent.have_can_enhance_equip_info()
    -- 保存可强化装备
    local equip_info = {}
    local item_obj   = item_unit:new()
    -- 设置最高强化等级
    local enhance_lv = 15
    -- 计算平均等级
    for i = 1,enhance_lv do
        local is_get = false
        -- 只取非武器的平均等级
        for pos = 1, 5 do
            local obj = item_unit.get_item_ptr_bypos(1, pos)
            if item_obj:init(obj) then
                if item_obj:equip_enchance_lv() < i then
                    enhance_lv = i
                    is_get = true
                    break
                end
            end
        end
        if is_get then break end
    end
    -- xxmsg('enhance_lv '..enhance_lv)
    -- 取可强化的装备信息
    for pos = 0, 5 do
        local obj   = item_unit.get_item_ptr_bypos(1, pos)
        local en_lv = pos ~= 0 and enhance_lv or 15
        -- xxmsg(pos..' en_lv'..en_lv)
        if item_obj:init(obj) then
            if this.can_enhance_equip(item_obj, pos,en_lv) then
                local level             = item_obj:level()
                equip_info = {
                    -- 装备位置
                    pos                 = pos,
                    -- 装备名字
                    name                = item_obj:name(),
                    -- 装备id
                    id                  = item_obj:id(),
                    -- 装备装分
                    level               = item_obj:level(),
                    -- 精练下一级需要总成长经验
                    equip_up_exp        = item_obj:equip_up_exp(),
                    -- 当前精练所需要经验
                    up_need_exp         = item_obj:up_need_exp(),
                    -- 精练等级
                    equip_enchance_lv   = item_obj:equip_enchance_lv(),
                    -- 精练辅助材料单个增加成功率（星辰之息）（除以一百为看到的）
                    enchance_stuff_rate = item_obj:enchance_stuff_rate(),
                    -- 精练基础 成功率 （除以一百为看到的）
                    equip_enchance_rate = item_obj:equip_enchance_rate(),
                    -- 当前总的成长经验（前面所有等级总各）
                    equip_enchance_exp  = item_obj:equip_enchance_exp(),
                    -- 装备品阶
                    jie                 = level >= 1250 and 3 or level >= 500 and 2 or 0
                }
                break
            end
        end
    end
    item_obj:delete()
    return equip_info
end

------------------------------------------------------------------------------------
-- [判断] 判断装备是否可以维修
------------------------------------------------------------------------------------
function shop_ent.can_repair_equip()
    local repair = false
    local item_obj = item_unit:new()
    for pos = 0, 5 do
        local obj = item_unit.get_item_ptr_bypos(1, pos)
        if item_obj:init(obj) then
            if item_obj:durability() / item_obj:max_durability() < 0.3 then
                repair = true
                break
            end
        end
    end
    item_obj:delete()
    return repair
end

------------------------------------------------------------------------------------
-- [读取] 获取最近的商人信息
------------------------------------------------------------------------------------
function shop_ent.get_near_my_repair_info(map_name)
    local npc_info = {}
    if not shop_res.MERCHANT_NPC[map_name] then
        return npc_info
    end
    local shop_info = shop_res.MERCHANT_NPC[map_name]['维修工']
    if not shop_info then
        return npc_info
    end
    local dist = 0
    local map_id = map_ent.get_map_id_by_map_name(map_name)
    if #shop_info > 1 then
        for i = 1, #shop_info do
            if shop_info[i].active_name and map_ent.is_active_by_map_id_and_transfer_name(map_id,shop_info[i].active_name)  then
                if not shop_info[i].scene_map then
                    if dist == 0 then
                        dist = local_player:dist_xy(shop_info[i].npc_pos.x, shop_info[i].npc_pos.y)
                        npc_info = shop_info[i]
                    elseif dist > local_player:dist_xy(shop_info[i].npc_pos.x, shop_info[i].npc_pos.y) then
                        npc_info = shop_info[i]
                    end
                else
                    if shop_info[i].scene_map == actor_unit.get_cur_scene_map_name() then
                        npc_info = shop_info[i]
                        break
                    end
                end
            end
        end
    else
        -- xxmsg(shop_info[1].active_name..' '..tostring(map_ent.is_active_by_map_id_and_transfer_name(map_id,shop_info[1].active_name)))
        if shop_info[1].active_name and map_ent.is_active_by_map_id_and_transfer_name(map_id,shop_info[1].active_name)  then
            npc_info = shop_info[1]
        end
    end
    return npc_info
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
shop_ent.calc_num = function(max_num, price, save)
    if max_num <= 0 then
        return 0
    end
    save = save or 1000
    local money = item_unit.get_money_byid(1) - save
    if money <= price then
        return 0
    end
    if money < (max_num * price) then
        max_num = money / price
    end
    return math.floor(max_num)
end

------------------------------------------------------------------------------------
-- [读取] 获取当前地图可以购买的最好药品
------------------------------------------------------------------------------------
function shop_ent.get_can_by_potion_by_map(map_name)
    local potion = ''
    -- 获取可购买的药品列表
    local hp_name_list = this.can_use_hp_name()
    if table.is_empty(hp_name_list) then
        return potion
    end
    -- 获取当前地图商人信息
    local map_merchant_data = shop_res.MERCHANT_NPC[map_name]
    if table.is_empty(map_merchant_data) then
        return potion
    end
    -- 获取当前地图药水商人信息
    local potion_merchant_list = map_merchant_data['药水商人']
    if table.is_empty(potion_merchant_list) then
        return potion
    end
    local map_id = map_ent.get_map_id_by_map_name(map_name)
    -- 获取当前地图可以购买的最好药品
    for i = 1, #hp_name_list do
        for j = 1, #potion_merchant_list do
            if potion_merchant_list[j].sell_item[hp_name_list[i]] then
                local active_name = potion_merchant_list[j].active_name
                if active_name and map_ent.is_active_by_map_id_and_transfer_name(map_id, active_name)  then
                    local is_read = true
                    if map_id == 10211 and not map_ent.is_active_by_map_id_and_transfer_name(10211,'罗格希尔哨所') then
                        is_read = false
                    end
                    if is_read then
                        potion = hp_name_list[i]
                        break
                    end
                end
            end
        end
        if potion ~= '' then
            break
        end
    end
    -- 判断是否有比之更高级的药水
    for i = 1, #hp_name_list do
        if hp_name_list[i] == potion then
            break
        end
        if item_ent.get_item_num_by_name(hp_name_list[i], 0,true) > 50 then
            potion = ''
            break
        end
    end
    return potion
end

------------------------------------------------------------------------------------
-- [读取] 获取最近的商人信息
------------------------------------------------------------------------------------
function shop_ent.get_near_my_potion_info(hp_name, map_name)
    local shop_info = shop_res.MERCHANT_NPC[map_name]['药水商人']
    local dist = 0
    local npc_info = {}
    local map_id = map_ent.get_map_id_by_map_name(map_name)
    if #shop_info > 1 then
        for i = 1, #shop_info do
            if shop_info[i].active_name and map_ent.is_active_by_map_id_and_transfer_name(map_id, shop_info[i].active_name)  then
                --如果出售
                if shop_info[i].sell_item[hp_name] then
                    if dist == 0 then
                        dist = local_player:dist_xy(shop_info[i].npc_pos.x, shop_info[i].npc_pos.y)
                        npc_info = shop_info[i]
                    elseif dist > local_player:dist_xy(shop_info[i].npc_pos.x, shop_info[i].npc_pos.y) then
                        npc_info = shop_info[i]
                    end
                end
            end
        end
    else
        if shop_info[1].active_name and map_ent.is_active_by_map_id_and_transfer_name(map_id, shop_info[1].active_name)  then
            npc_info = shop_info[1]
        end
    end
    return npc_info
end

------------------------------------------------------------------------------------
-- [读取] 获取自己能使用的药品区间
------------------------------------------------------------------------------------
shop_ent.can_use_hp_name = function()
    local ret_t   = {}
    local hp_list = item_res.HP_ITEM
    local level   = local_player:level()
    local equip_prop_level = item_unit.get_equip_prop_level()
    for i = 1, #hp_list do
        local add = true
        -- 玩家等级小于使用等级
        if add and level < hp_list[i].level then
            add = false
        end
        -- 玩家装等小于使用装等
        if add and hp_list[i].prop_level and equip_prop_level < hp_list[i].prop_level then
            add = false
        end
        if add then
            table.insert(ret_t, hp_list[i].name)
        end
    end
    return ret_t
end

----------------------------------------------------------------------------------------
-- 通过商品名字获取商品信息
shop_ent.get_goods_info_by_any = function(args, any_key)
    local result = {}
    local list = shop_unit.list()
    for _, obj in ipairs(list) do
        if shop_ctx:init(obj) then
            local _any = shop_ctx[any_key](shop_ctx)
            if args == _any then
                result = {
                    -- 商品指针
                    obj = obj,
                    -- 商品资源
                    res_ptr = shop_ctx:res_ptr(),
                    -- 商品资源ID
                    res_id = shop_ctx:res_id(),
                    -- 商品序号
                    idx = shop_ctx:idx(), -- 主要用于购买
                    -- 商品价格
                    price = shop_ctx:price(),
                    -- 商品名字
                    name = shop_ctx:name()
                }
                break
            end
        end
    end
    return result
end

------------------------------------------------------------------------------------
-- [读取] 获取强化装备信息
------------------------------------------------------------------------------------
function shop_ent.get_enhance_equip_info(pos)
    local equip_info = {}
    local item_obj = item_unit:new()
    local obj = item_unit.get_item_ptr_bypos(1, pos)
    if item_obj:init(obj) then
        equip_info = {
            -- 装备名字
            name = item_obj:name(),
            -- 装备id
            id = item_obj:id(),
            -- 装备装分
            level = item_obj:level(),
            -- 精练下一级需要总成长经验
            equip_up_exp = item_obj:equip_up_exp(),
            -- 当前精练所需要经验
            up_need_exp = item_obj:up_need_exp(),
            -- 精练等级
            equip_enchance_lv = item_obj:equip_enchance_lv(),
            -- 精练辅助材料单个增加成功率（星辰之息）（除以一百为看到的）
            enchance_stuff_rate = item_obj:enchance_stuff_rate(),
            -- 精练基础 成功率 （除以一百为看到的）
            equip_enchance_rate = item_obj:equip_enchance_rate(),
            -- 当前总的成长经验（前面所有等级总各）
            equip_enchance_exp = item_obj:equip_enchance_exp(),
        }
    end
    item_obj:delete()
    return equip_info
end

------------------------------------------------------------------------------------
-- [行为] 移动到指定类型NPC
------------------------------------------------------------------------------------
function shop_ent.move_to_shop_npc(map_name,shop_type)
    map_name = map_name or actor_unit.map_name()
    while decider.is_working() do
        -- 读取指定地图的商店NPC资源记录
        local shop_list = shop_res.MERCHANT_NPC[map_name]
        -- 没有资源退出
        if table.is_empty(shop_list) then
            return false,map_name..'-地图没有任何资源'
        end
        -- 读取指定类型的NPC资源
        local info_list = shop_list[shop_type]
        -- 没有指定类型的NPC资源退出
        if table.is_empty(info_list) then
            return false,map_name..'-地图没有设置【'..shop_type..'】'
        end
        -- 选择第一个序号的目标资源
        local info      = info_list[1]
        -- 移动到指定位置
        if map_ent.move_to(map_name, info.scene_map_name, info.npc_pos.x, info.npc_pos.y, info.npc_pos.z, 200) then
            return true,info.npc_name
        end
        decider.sleep(1000)
    end
    return false,'未能移动到指定'..shop_type
end

-------------------------------------------------------------------------------------
-- 实例化新对象

function shop_ent.__tostring()
    return "FZ shop_ent package"
end

shop_ent.__index = shop_ent

function shop_ent:new(args)
    local new = { }

    if args then
        for key, val in pairs(args) do
            new[key] = val
        end
    end

    -- 设置元表
    return setmetatable(new, shop_ent)
end

-------------------------------------------------------------------------------------
-- 返回对象
return shop_ent:new()

-------------------------------------------------------------------------------------