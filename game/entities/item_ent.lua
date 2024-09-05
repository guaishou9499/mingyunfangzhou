------------------------------------------------------------------------------------
-- game/entities/item_ent.lua
--
-- 这个模块主要是项目内物品相关功能操作。
--
-- @module      item_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local item_ent = import('game/entities/item_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class item_ent
local item_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION     = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-03-22 - Initial release',
    -- 模块名称
    MODULE_NAME = 'item_ent module',
    -- 只读模式
    READ_ONLY   = false,
}

-- 自身单元
local this         = item_ent
-- 日志模块
local trace        = import('base/trace')
-- 决策模块
local decider      = decider
---@type common
local common       = common
local pairs        = pairs
local table        = table
local ipairs       = ipairs
local setmetatable = setmetatable
local string       = string
local math         = math
local item_unit    = item_unit
local local_player = local_player
local actor_unit   = actor_unit
local ui_unit      = ui_unit
local dungeon_unit = dungeon_unit
local import       = import
---@type item_res
local item_res     = import('game/resources/item_res')
local equip_res    = import('game/resources/equip_res')
local map_res      = import('game/resources/map_res')
local dungeon_res  = import('game/resources/dungeon_res')
---@type ui_ent
local ui_ent       = import('game/entities/ui_ent')
-- 设置分解或者破坏时间
local set_info     = {}
------------------------------------------------------------------------------------
-- [事件]预载函数(重载脚本时)
------------------------------------------------------------------------------------
item_ent.super_preload = function()

end

------------------------------------------------------------------------------------
-- [行为] 自动分解装备
------------------------------------------------------------------------------------
item_ent.decompose_equip = function(filter)
    local is_use = this.get_bag_is_use()
    if not filter and ( is_use < 80 ) then
        return
    end
    -- 是否关闭背包   = false
    local close_bag   = false
    local dec_marble  = { 1,2 }
    for _,v in pairs(dec_marble) do
        -- 是否分解
        local decompose = false
        local str       = ''
        local item_list = item_ent.get_item_info(0)
        for i = 1, #item_list do
            local item_info = item_list[i]
            local dec,close = this.is_decompose_equip(item_info,v)
            if close then
                close_bag = true
            end
            if dec then
                decompose = true
                if str == '' then
                    str = item_info.name
                else
                    str = item_info.name..','..str
                end
            end
        end
        if decompose then
            xxxmsg(3,'分解:'..str)
            item_unit.confirm_decompose()
            decider.sleep(1000)
        end
    end
    -- 删除物品
    this.auto_del_item()
    -- 分解物品
    this.deco_item()
    if close_bag then
        ui_ent.auto_sort_bag()
        ui_ent.close_bag()
        ui_ent.close_ui()
    end
end

------------------------------------------------------------------------------------
-- [行为] 自动使用药水
------------------------------------------------------------------------------------
item_ent.auto_use_hp = function()
    -- 当前血量低于70%
    if  local_player:hp()/local_player:max_hp() >= 0.7 then
        return
    end
    local loss_hp = local_player:max_hp() - local_player:hp()
    if loss_hp < 600 then  loss_hp = 600 end
    local hp_name_list = item_ent.can_use_hp_list(loss_hp)
    local item_info = item_ent.get_item_info()
    local use = false
    for i = 1, #hp_name_list do
        local hp_name = hp_name_list[i]
        for j = 1, #item_info do
            if hp_name == item_info[j].name then
                if item_unit.get_item_cooldown(item_info[j].res_id) == 0  then
                    item_unit.use_item(item_info[j].pos)
                    use = true
                    xxmsg('使用：'..hp_name)
                    decider.sleep(500)
                    break
                end
            end
        end
        if use then
            break
        end
    end
end

------------------------------------------------------------------------------------
-- [行为] 使用药水区间
------------------------------------------------------------------------------------
item_ent.use_hp_name = function()
    local hp_name = '普通治疗药水'
    local player_level = local_player:level()
    if player_level >= 50 then
        local equip_prop_level = item_unit.get_equip_prop_level()
        if equip_prop_level >= 1400 then
            hp_name = '神秘治疗药水', 41216
        elseif equip_prop_level >= 1200 then
            hp_name = '星光治疗药水', 23344
        elseif equip_prop_level >= 1000 then
            hp_name = '祝福治愈药水', 15264
        elseif equip_prop_level >= 900 then
            hp_name = '净化治愈药水', 13960
        elseif equip_prop_level >= 700 then
            hp_name = '守护治愈药水', 10584
        elseif equip_prop_level >= 500 then
            hp_name = '神圣治愈药水', 8832
        else
            hp_name = '强化治疗药水', 4312
        end
    elseif player_level >= 48 then
        hp_name = '强化治疗药水', 4312
    elseif player_level >= 37 then
        hp_name = '达人治疗药水', 2608
    elseif player_level >= 26 then
        hp_name = '名人治疗药水', 1592
    elseif player_level >= 18 then
        hp_name = '高级治疗药水', 968
    else
        hp_name = '普通治疗药水', 768
    end
    return hp_name
end

-------------------------------------------------------------------------------------
-- [行为] 自动加血[触发血量百分比]
item_ent.auto_use_hp_ex = function(trigger_hp_pro)
    if dungeon_res.is_in_stars_guard() then
        return false,'在星辰副本中不可用'
    end
    if common.is_sleep_any('自动加血',1) then
        -- 默认触发比为80
        trigger_hp_pro = trigger_hp_pro or 80
        -- 如果在副本中 则为 92
        if actor_unit.is_dungeon_map() then
            trigger_hp_pro = trigger_hp_pro < 90 and 90 or trigger_hp_pro
        end
        local cur_hp   = local_player:hp() * 100 / local_player:max_hp()
        if cur_hp >= trigger_hp_pro then return false end
        -- 如果血量低于15 直接使用恢复比血药[需要设置到快捷]
        if cur_hp < 15 then
            --local n_name   = item_res.HP_REGAIN
            --for _,v in pairs(n_name) do
            --    local info = this.get_item_info_by_name(v.name)
            --    if not table.is_empty(info) and info.num > 0 and item_unit.get_item_cooldown(info.res_id) == 0 then
            --        item_unit.use_item(info.pos)
            --        return true
            --    end
            --end
        end
        local list     = this.get_can_add_list()
        local count    = #list
        -- 向下兼容1
        count          = count > 2 and 2 or 1
        for _,v in pairs(list) do
            local info = this.get_item_info_by_name(v.name)
            if not table.is_empty(info) and info.num > 0 and item_unit.get_item_cooldown(info.res_id) == 0 then
                -- xxmsg(info.name.. ' '.. info.pos)
                item_unit.use_item(info.pos)
                -- 按键F1
                --  common.key_call('KEY_F1')
                return true
            end
        end
    end
    return false
end

------------------------------------------------------------------------------------
-- [行为] 自动使用物品[非箱子 药品累]
------------------------------------------------------------------------------------
item_ent.auto_use_item = function()
    if actor_unit.is_dungeon_map() and not map_res.is_in_islet() and actor_unit.map_name() ~= '特里希温' then
        return
    end
    -- 获取当前装备评分
    local prop_level    = item_unit.get_equip_prop_level()
    for i = 1,2 do
        local need_use  = item_res.NEED_USE_ITEM
        local item_info = this.get_item_info(0)
        for _, v in pairs(item_info) do
            local c_use = false
            if common.is_exist_list_arg(need_use,v.name) then
                c_use = true
            end
            if string.find(v.name, '卡牌') and not string.find(v.name, '卡牌包') then
                c_use = true
            end
            if string.find(v.name,'共鸣') and dungeon_unit.get_fatigue_value() >= 50 then
                c_use = false
            end
            -- 使用失败
            if common.get_key_table('use_error_'..v.name) and os.time() - common.get_key_table('use_error_'..v.name) < 3600 then
                c_use = false
            end
            local trap_power = item_res.OPEN_NEED_POWER[v.name]
            if trap_power and prop_level < trap_power then
                c_use = false
            end
            if c_use and local_player:hp() > 0 then
                if item_unit.get_item_cooldown(v.res_id) == 0 then
                    -- 首先打开箱子
                    common.wait_loading_map()
                    ui_ent.esc_cinema()
                    if ui_ent.open_bag() then
                        for i = 1,v.num do
                            if not decider.is_working() then
                                break
                            end
                            if string.find(v.name,'共鸣') and dungeon_unit.get_fatigue_value() >= 50 then
                                break
                            end
                            trace.output('使用：', v.name)
                            item_unit.use_item(v.pos)
                            decider.sleep(500)
                            if item_unit.has_bs_item_wnd() then
                                item_unit.receive_all()
                                decider.sleep(1000)
                            elseif item_unit.has_bs_select_wnd() then  	-- 选择类箱子物品
                                local sel_info = item_res.SEL_ITEM[v.name]
                                if not table.is_empty(sel_info) then
                                    if local_player:level() >= sel_info.level and item_unit.get_equip_prop_level() >= sel_info.prop_level then
                                        decider.sleep(1000)
                                        local res_id = item_res.get_res_id_by_box_name_and_sel_name(v.name,sel_info.sel_name)
                                        trace.output('选择（'..sel_info.sel_name..'）')
                                        item_unit.receive_select_item(res_id)
                                        decider.sleep(1000)
                                    end
                                end
                            end
                            for i = 1,2 do
                                if ui_unit.has_dialog() then
                                    decider.sleep(500)
                                    ui_unit.confirm_dialog(true)
                                    decider.sleep(1000)
                                end
                            end
                            decider.sleep(200)
                            common.wait_over_state()
                            -- 物品使用失败记录
                            if this.get_item_num_by_name(v.name,0,true) == v.num then
                                common.set_key_table('use_error_'..v.name,os.time())
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    ui_ent.close_bag()
end

------------------------------------------------------------------------------------
-- [行为] 分解指定物品列表
------------------------------------------------------------------------------------
item_ent.deco_item = function()
    -- item_res.is_can_deco_by_name
    local close_bag
    local item_list = item_ent.get_item_info(0)
    for i = 1, #item_list do
        local item_info = item_list[i]
        if item_res.is_can_deco_by_name(item_info.name) then
            if ui_ent.open_bag() then
                if ui_ent.open_deco() then
                    close_bag = true
                    item_unit.set_decompose(item_info.pos)
                    set_info[item_info.id] = os.time()
                    decider.sleep(500)
                end
            end
        end
    end
    if close_bag then
        trace.output('分解指定物品')
        item_unit.confirm_decompose()
        decider.sleep(1000)
        ui_ent.close_bag()
        ui_ent.close_ui()
    end
end

------------------------------------------------------------------------------------
-- [行为] 删除物品
item_ent.auto_del_item = function()
    local close_bag
    local item_list = item_ent.get_item_info(0)
    for i = 1, #item_list do
        local item_info = item_list[i]
        if this.is_need_del_item_by_item_info(item_info) then
            if ui_ent.open_bag() then
                close_bag = true
                trace.output('删除：',item_info.name)
                item_unit.del_item(item_info.id)
                decider.sleep(500)
            end
        end
    end
    if close_bag then
        ui_ent.close_bag()
    end
end

------------------------------------------------------------------------------------
-- [行为] 使用指定物品
------------------------------------------------------------------------------------
item_ent.use_item_by_name = function(name)
    local info = this.get_item_info_by_name(name, 0)
    if not table.is_empty(info) and item_unit.get_item_cooldown(info.res_id) == 0 then
        --  xxmsg( item_unit.get_item_cooldown(info.res_id) )
        if ui_ent.open_bag() then
            trace.output('使用：', name)
            item_unit.use_item(info.pos)
            decider.sleep(1000)
            if item_unit.has_bs_item_wnd() then
                item_unit.receive_all()
                decider.sleep(500)
            end
            common.wait_over_state()
            ui_ent.close_bag()
        end
    end
end

------------------------------------------------------------------------------------
-- [行为] 打开存在指定物品的箱子
item_ent.open_box_by_sel_name = function(sel_name,need_num)
    local list = item_res.get_box_info_by_sel_name(sel_name)
    for _,box_name in pairs(list) do
        local num = item_ent.get_item_num_by_name(sel_name,nil,true)
        if num >= need_num then
            break
        end
        this.use_item_box_by_name_and_sel_name(box_name,sel_name,need_num)
    end
end

------------------------------------------------------------------------------------
-- [行为] 使用指定选择箱子,选择目标,数量
------------------------------------------------------------------------------------
item_ent.use_item_box_by_name_and_sel_name = function(box_name,sel_name,need_num)
    local res_id = item_res.get_res_id_by_box_name_and_sel_name(box_name,sel_name)
    if res_id == 0 then
        return false
    end
    local prop_level = item_unit.get_equip_prop_level()
    local trap_power = item_res.OPEN_NEED_POWER[box_name]
    if trap_power and prop_level < trap_power then
        return false
    end
    local ret    = false
    local info = this.get_item_info_by_name(box_name, 0)
    if not table.is_empty(info) then
        if ui_ent.open_bag() then
            for i = 1,info.num do
                local num = item_ent.get_item_num_by_name(sel_name,nil,true)
                if num >= need_num then
                    break
                end
                trace.output('打开：', box_name)
                item_unit.use_item(info.pos)
                decider.sleep(1000)
                if item_unit.has_bs_item_wnd() then
                    item_unit.receive_all()
                    decider.sleep(1000)
                elseif item_unit.has_bs_select_wnd() then  	-- 选择类箱子物品
                    trace.output('选择：',sel_name)
                    ret = true
                    -- 	领取 选择的物品资源ID
                    item_unit.receive_select_item(res_id)
                    decider.sleep(1000)
                end
                for i = 1,2 do
                    if ui_unit.has_dialog() then
                        decider.sleep(500)
                        ui_unit.confirm_dialog(true)
                        decider.sleep(1000)
                    end
                end
                common.wait_over_state()
            end
        end
    end
    return ret
end

------------------------------------------------------------------------------------
-- [条件] 指定物是否可分解
item_ent.is_decompose_equip = function(item_info,dec_marble)
    if set_info[item_info.id] then
        if os.time() - set_info[item_info.id] < 3600 * 24 then
            return false,false
        end
    end
    if item_info.type ~= 1 or item_info.par == '其他' then
        -- xxmsg(item_info.name .. '不是装备')
        return false,false
    end

    -- 人物等级 小于 装备使用等级 返回
    if local_player:level() < item_info.equippable_level then
        -- 如果是 最高评分 则返回
        -- 获取背包装备评分最高的装备
        local bag_equip = this.get_bast_equip_by_par(item_info.par, true)
        if not table.is_empty(bag_equip) then
            if bag_equip.id == item_info.id then
                return false,false
            end
        end
    end

    -- 比较能力石
    if not table.is_empty(item_info.marble) then
        -- 标记是否需使用,获取背包最佳能力石
        local can_use,bag_marble = item_ent.get_best_can_use_marble_info()
        if can_use and not table.is_empty(bag_marble) and bag_marble.id == item_info.id then
            return false,false
        end
    end

    -- 当前装备部位
    if not ui_ent.open_bag() then
        return false,false
    end

    -- item_ent.get_bag_is_use()
    if item_info.trade_level == 0 or item_info.trade_level < 250 then -- or item_ent.get_bag_is_use() >= 90
        trace.output('破坏：',item_info.name)
        item_unit.del_item(item_info.id)
        decider.sleep(500)
        set_info[item_info.id] = os.time()
        return false,true
    end

    local is_marble = table.is_empty(item_info.marble)
    if dec_marble == 1 and is_marble or dec_marble == 2 and not is_marble or item_res.is_can_deco_by_name(item_info.name) then
        -- xxmsg(item_info.pos..' '..item_info.name..' '..tostring(dec_marble))
        if ui_ent.open_deco() then
            item_unit.set_decompose(item_info.pos)
            set_info[item_info.id] = os.time()
            decider.sleep(500)
            return true,true
        end
    end
    return false,false
end

------------------------------------------------------------------------------------
-- [条件] 删除指定物品
------------------------------------------------------------------------------------
item_ent.is_need_del_item_by_item_info = function(item_info)
    -- 删除多余的药品
    local list     = this.get_can_add_list()
    local del_idx  = 3
    if list[1].name then
        if this.get_item_num_by_name(list[1].name,nil,true) > 80 then
            del_idx  = 2
        end
    end
    for i = 2,#list do
        if i >= del_idx then
            if list[i].name == item_info.name then
                return true
            end
        end
    end
    if item_info.name == '陈旧的伐木工具（斧头）' then
        -- 获取身上生活工具品质,工具数量
        local _,body_num = item_ent.get_max_quality_life_info_by_pos(1,2)

        if body_num > 0 then
            return true
        end
    end
    -- 需要删除的生活工具
    local g_pos = equip_res.get_life_pos_by_name(item_info.name)
    if g_pos ~= -1 and item_info.max_durability == 0 then
        return true
    end
    -- 配置设置的需要删除物
    if item_res.is_can_del_by_name(item_info.name) then
        return true
    end

    return false
end

------------------------------------------------------------------------------------
-- [条件] 判断装备是否需要维修
------------------------------------------------------------------------------------
item_ent.is_need_repair_equip = function(trigger_num,trigger_dur)
    -- 触发修理最低耐久
    trigger_dur   = trigger_dur or 0.3
    -- 除非修理最低装备数量
    trigger_num   = trigger_num or 1
    local cur_num = 0
    local item_obj = item_unit:new()
    for pos = 0, 5 do
        local obj = item_unit.get_item_ptr_bypos(1, pos)
        if item_obj:init(obj) then
            if item_obj:durability() / item_obj:max_durability() < trigger_dur or item_obj:durability() == 0 then
                cur_num = cur_num + 1
            end
        end
    end
    item_obj:delete()
    return cur_num >= trigger_num
end

------------------------------------------------------------------------------------
-- [读取] 获取自己能使用的药品区间
------------------------------------------------------------------------------------
item_ent.can_use_hp_list = function(loss_hp)
    local hp_list = item_res.HP_ITEM
    local level = local_player:level()
    local equip_prop_level = item_unit.get_equip_prop_level()
    local can_use_list = {}
    for i = 1, #hp_list do
        local add = true
        -- 增加血量超过损失血量
        if hp_list[i].add_hp > loss_hp then
            add = false
        end
        -- 玩家等级小于使用等级
        if add and level < hp_list[i].level then
            add = false
        end
        -- 玩家装等小于使用装等
        if add and hp_list[i].prop_level and equip_prop_level <  hp_list[i].prop_level then
            add = false
        end
        if add then
            table.insert(can_use_list,  hp_list[i].name)
        end
    end
    return can_use_list
end

------------------------------------------------------------------------------------
-- [读取] 获取最佳可用能力石
item_ent.get_best_can_use_marble_info = function()
    -- 获取背包最佳能力石
    local bag_marble  = this.get_best_marble_in_bag()
    -- 获取身上最佳能力石
    local body_marble = this.get_best_marble_in_body()
    -- 标记是否需使用
    local can_use = false
    -- 比较能力石头
    if table.is_empty(body_marble) then
        if not table.is_empty(bag_marble) then
            can_use = true
        end
    else
        if not table.is_empty(bag_marble) then
            -- 身上装备评分等级 小于 背包评分等级
            if math.floor(body_marble.trade_level) < math.floor(bag_marble.trade_level) then
                can_use = true
            end
        end
    end
    return can_use,bag_marble
end

------------------------------------------------------------------------------------
-- [读取] 获取身上最佳能力石信息
item_ent.get_best_marble_in_body = function()
    local body_marble = {}
    -- 获取身上能力石信息
    local item_list  = this.get_item_marble_list(1)
    for _,v in pairs(item_list) do
        if not table.is_empty(v) and not table.is_empty(v.marble) then
            body_marble = v
            break
        end
    end
    return body_marble
end

------------------------------------------------------------------------------------
-- [读取] 获取背包最佳能力石信息
--             -- 是否加工完毕
--            xxmsg(#bag_marble.marble..' '..bag_marble.trade_level..' '..item_unit.get_equip_prop_level()..' '..tostring(bag_marble.is_need_process))
--            for _,v1 in pairs(bag_marble.marble) do
--                xxmsg(string.format("        主序号：%02d  刻印数:%02d   是否刻印满:%-6s", v1.main_idx, v1.engraving_num, v1.is_engraving_full))
--                if  v1.is_engraving_full then
--                    -- 需要加工
--                    local engraving_info = v1.engraving_info
--                    for _,v2 in pairs(engraving_info) do
--                        xxmsg(v2.engraving_idx..' '..v2.engraving_status)
--                    end
--                end
--            end
------------------------------------------------------------------------------------
item_ent.get_best_marble_in_bag = function()
    -- 获取背包最佳能力石
    local item_list  = item_ent.get_item_marble_list(0)
    local bag_marble = {}
    -- 获取当前装备评分
    local prop_level = item_unit.get_equip_prop_level()
    for _,v in pairs(item_list) do
        if not table.is_empty(v) and not table.is_empty(v.marble) and prop_level >= v.trade_level then
            bag_marble = v
            break
        end
    end
    return bag_marble
end

------------------------------------------------------------------------------------
-- [读取] 获取能力石[评分等级从高到低][ 默认读取0 背包 ]
item_ent.get_item_marble_list = function(bag_type)
    bag_type        = bag_type or 0 -- 默认背包
    local list      = {}
    local item_info = item_ent.get_item_info(bag_type)
    for _,v in pairs(item_info) do
        if not table.is_empty(v) and not table.is_empty(v.marble) then
            -- 是否加工完毕
            local is_need_process = false
            -- 遍历能力石每个序列下的刻印信息
            for _,v1 in pairs(v.marble) do
                if not  v1.is_engraving_full then
                    -- 需要加工
                    is_need_process = true
                end
            end
            -- 标记是否需要加工
            v.is_need_process = is_need_process
            table.insert(list,v)
        end
    end
    table.sort(list,function(a, b) return a.trade_level > b.trade_level  end)
    return list
end

------------------------------------------------------------------------------------
-- [读取] 获取背包装备评分最高的装备[部位]
item_ent.get_bast_equip_by_par = function(par, filter_level)
    -- 0 背包 1 身上装备
    local ret_t = {}
    local bast_equip_level = 0
    local list = item_unit.list(0)
    local item_obj = item_unit:new()
    local my_level = not filter_level and local_player:level() or 99999
    for _, obj in pairs(list) do
        if item_obj:init(obj) and item_obj:type() == 1 and my_level >= item_obj:equippable_level() then
            local equip_name = item_obj:name()
            if par == this.get_equip_par_by_name(equip_name) then
                local equip_level = item_obj:level()
                if equip_level >= bast_equip_level then
                    ret_t = {
                        obj = obj,
                        res_ptr = item_obj:res_ptr(),
                        id = item_obj:id(),
                        res_id = item_obj:res_id(),
                        pos = item_obj:pos(),
                        type = 1,
                        num = item_obj:num(),
                        quality = item_obj:quality(),
                        level = equip_level,
                        durability = item_obj:durability(),
                        max_durability = item_obj:max_durability(),
                        equippable_level = item_obj:equippable_level(), -- 使用等级
                        name = equip_name,
                        equip_level = item_obj:equip_level(),
                        trade_level = item_obj:trade_level(),
                    }
                    bast_equip_level = equip_level
                end
            end
        end
    end
    item_obj:delete()
    return ret_t
end

-------------------------------------------------------------------------------------
-- [读取] 获取可以加血的药品信息
item_ent.get_can_add_list = function()
    local list             = {}
    -- 自身当前等级
    local level            = local_player:level()
    -- 当前装备评分等级
    local equip_prop_level = item_unit.get_equip_prop_level()
    for _,v in pairs(item_res.HP_ITEM) do
        local prop_level   = v.prop_level or 1
        if level >= v.level and equip_prop_level >= prop_level then
            table.insert(list,v)
        end
    end
    if not table.is_empty(list) then
        table.sort(list,function(a, b) return a.level > b.level end)
        return list
    end
    return { { level = 1, money = 6, add_hp = 600, name = '初级治疗药水' } }
end

------------------------------------------------------------------------------------
-- [读取] 根据装备名称 获取对应指定的部位
item_ent.get_equip_par_by_name = function(equip_name)
    return equip_res.get_equip_par_by_name(equip_name)
end

------------------------------------------------------------------------------------
-- [读取] 获取身上指定位置装备评分 pos
------------------------------------------------------------------------------------
item_ent.get_equip_level_by_pos = function(pos)
    -- 0 背包 1 身上装备
    local ret_n = 0
    local item_obj = item_unit:new()
    local obj = item_unit.get_item_ptr_bypos(1, pos)
    if item_obj:init(obj) then
        ret_n = item_obj:level()
    end
    item_obj:delete()
    return ret_n
end

------------------------------------------------------------------------------------
-- [读取] 获取指定位置强化装备信息[默认读取0 背包]
------------------------------------------------------------------------------------
item_ent.get_enhance_equip_info = function(pos,bag_type)
    bag_type         = bag_type or 1
    local equip_info = {}
    local item_obj   = item_unit:new()
    local obj        = item_unit.get_item_ptr_bypos(bag_type, pos)
    if item_obj:init(obj) then
        equip_info = {
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
        }
    end
    item_obj:delete()
    return equip_info
end

------------------------------------------------------------------------------------
-- [读取] 获取已使用的背包格子数
item_ent.get_bag_is_use = function()
    return #item_unit.list(0)
end

------------------------------------------------------------------------------------
-- [读取] 获取品质最高的生活装备信息
item_ent.get_max_quality_life_info_by_pos = function(pos,bag_type)
    local info = this.get_item_info(bag_type)
    local list = {}
    for _,v in pairs(info) do
        local g_pos = equip_res.get_life_pos_by_name(v.name)
        if g_pos == pos and v.durability > 0 then
            table.insert(list,v)
        end
    end
    if not table.is_empty(list) then
        table.sort(list,function(a, b) return a.quality > b.quality end)
        return list[1],#list
    end
    return {},0
end

------------------------------------------------------------------------------------
-- [读取] 根据物品名或多个物品名取物品所有数量
--
-- @tparam          any                                name                  物品名/{物品名1,物品名2,...}
-- @tparam          any                                pos_type              读取物品源[ 0 背包  1 身上 ] 默认背包
-- @tparam          bool                               stop_vague            是否停用模糊搜索
-- @treturn         number                                                   物品所有数量
-- @usage
-- local item_num = item_ent.get_item_num_by_name('A')
-- local item_num = item_ent.get_item_num_by_name({A,B})
------------------------------------------------------------------------------------
item_ent.get_item_num_by_name = function(name, pos_type,stop_vague)
    local item_list = this.get_item_list_by_list_name(name, pos_type,stop_vague)
    local num = 0
    for _, v in pairs(item_list) do
        num = num + v.num
    end
    return num
end

------------------------------------------------------------------------------------
-- [读取] 根据资源ID或多个资源ID取物品所有数量
--
-- @tparam          any                                res_id                物品资源ID/{物品资源ID1,物品资源ID2,...}
-- @tparam          any                                pos_type              读取物品源[ 0 背包  1 身上 2 生活 ] 默认背包
-- @treturn         number                                                   物品所有数量
-- @usage
-- local item_num = item_ent.get_item_num_by_res_id(0x123)
-- local item_num = item_ent.get_item_num_by_res_id({0x123,0x124})
------------------------------------------------------------------------------------
item_ent.get_item_num_by_res_id = function(res_id, pos_type)
    local item_list = this.get_item_list_by_list_res_id(res_id, pos_type)
    local num = 0
    for _, v in pairs(item_list) do
        num = num + v.num
    end
    return num
end

------------------------------------------------------------------------------------
-- [读取] 根据资源ID取物品ID
--
-- @tparam          number                     res_id                物品资源ID
-- @tparam          any                        pos_type              读取物品源[ 0 背包  1 身上  2 生活] 默认背包
-- @treturn         number                                           物品ID
-- @usage
-- local item_id = item_ent.get_item_id_by_res_id(0x123)
------------------------------------------------------------------------------------
item_ent.get_item_id_by_res_id = function(res_id, pos_type)
    local item_info = this.get_item_info_by_res_id(res_id, pos_type)
    return not table.is_empty(item_info) and item_info.id or 0
end

------------------------------------------------------------------------------------
-- [读取] 根据物品名取物品ID
--
-- @tparam          string                     name                物品名称
-- @tparam          any                        pos_type            读取物品源[ 0 背包  1 身上 2 生活 ] 默认背包
-- @treturn         number                                         物品ID
-- @usage
-- local item_id = item_ent.get_item_id_by_name('物品名称')
------------------------------------------------------------------------------------
item_ent.get_item_id_by_name = function(name, pos_type)
    local item_info = this.get_item_info_by_name(name, pos_type)
    return not table.is_empty(item_info) and item_info.id or 0
end

------------------------------------------------------------------------------------
-- [读取] 根据物品名取物品位置
--
-- @tparam          string                     name                物品名称
-- @tparam          any                        pos_type            读取物品源[ 0 背包  1 身上 2 生活 ] 默认背包
-- @treturn         number                                         物品ID
-- @usage
-- local item_id = item_ent.get_item_id_by_name('物品名称')
------------------------------------------------------------------------------------
item_ent.get_item_pos_by_name = function(name, pos_type)
    local item_info = this.get_item_info_by_name(name, pos_type)
    return not table.is_empty(item_info) and item_info.pos or -1
end

------------------------------------------------------------------------------------
-- [读取] 根据物品名取资源ID
--
-- @tparam          string                     name                物品名称
-- @tparam          any                        pos_type            读取物品源[ 0 背包  1 身上 2 生活 ] 默认背包
-- @treturn         number                                         物品资源ID
-- @usage
-- local res_id = item_ent.get_item_res_id_by_name('物品名称')
------------------------------------------------------------------------------------
item_ent.get_item_res_id_by_name = function(name, pos_type)
    local item_info = this.get_item_info_by_name(name, pos_type)
    return not table.is_empty(item_info) and item_info.res_id or 0
end

------------------------------------------------------------------------------------
-- [读取] 根据物品名取物品信息
--
-- @tparam          string                     name                物品名称
-- @tparam          any                        pos_type            读取物品源[ 0 背包  1 身上 2 生活 ] 默认背包
-- @treturn         table                                          返回包含物品信息表
-- @usage
-- local item_info = item_ent.get_item_info_by_name('物品名称')
------------------------------------------------------------------------------------
item_ent.get_item_info_by_name = function(name, pos_type)
    return this.get_item_info_by_any(name, 'name', pos_type)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品资源ID取物品信息
--
-- @tparam          number                     res_id                物品资源ID
-- @tparam          any                        pos_type              读取物品源[ 0 背包  1 身上 2 生活 ] 默认背包
-- @treturn         table                                            返回包含物品信息表
-- @usage
-- local item_info = item_ent.get_item_info_by_res_id(0x123)
--
------------------------------------------------------------------------------------
item_ent.get_item_info_by_res_id = function(res_id, pos_type)
    return item_ent.get_item_info_by_any(res_id, 'res_id', pos_type)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品ID取物品信息
--
-- @tparam          number                     id                    物品ID
-- @tparam          any                        pos_type              读取物品源[ 0 背包  1 身上 2 生活 ] 默认背包
-- @treturn         table                                            返回包含物品信息表
-- @usage
-- local item_info = item_ent.get_item_info_by_id(0x123)
------------------------------------------------------------------------------------
item_ent.get_item_info_by_id = function(id, pos_type)
    return item_ent.get_item_info_by_any(id, 'id', pos_type)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品名或者物品名表-返回多个物品信息的表
--
-- @tparam          any                        item_list_name          需要配对的物品名或物品名表
-- @tparam          number                     pos_type                读取位置【0背包 1身上 2 生活】默认0
-- @treturn         table                                              返回多个物品信息的表
-- @usage
-- local item_list = item_ent.get_item_list_by_list_name(item_list_name, pos_type)
-- 字段属性从item_ent.get_item_list_by_list_any 通用函数中取出
------------------------------------------------------------------------------------
item_ent.get_item_list_by_list_name = function(item_list_name, pos_type,stop_vague)
    return this.get_item_list_by_list_any(item_list_name, 'name', pos_type,stop_vague)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品ID或物品ID表-返回多个物品信息的表
--
-- @tparam          any                        item_list_id            需要配对的物品ID或物品ID表
-- @tparam          number                     pos_type                读取位置【0背包 1身上 2 生活】默认0
-- @treturn         table                                              返回多个物品信息的表
-- @usage
-- local item_list = item_ent.get_item_list_by_list_id(item_list_id, pos_type)
-- 字段属性从item_ent.get_item_list_by_list_any 通用函数中取出
------------------------------------------------------------------------------------
item_ent.get_item_list_by_list_id = function(item_list_id, pos_type)
    return this.get_item_list_by_list_any(item_list_id, 'id', pos_type)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品资源ID或者资源ID表-返回多个物品信息的表
--
-- @tparam          any                        item_list_res_id        需要配对的物品资源ID或者资源ID表
-- @tparam          number                     pos_type                读取位置【0背包 1身上 2 生活】默认0
-- @treturn         table                                              返回多个物品信息的表
-- @usage
-- local item_list = item_ent.get_item_list_by_list_res_id(item_list_res_id, pos_type)
-- 字段属性从item_ent.get_item_list_by_list_any 通用函数中取出
------------------------------------------------------------------------------------
item_ent.get_item_list_by_list_res_id = function(item_list_res_id, pos_type)
    return this.get_item_list_by_list_any(item_list_res_id, 'res_id', pos_type)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品任意字段或多个字段值返回包含物品信息的所有物品表
--
-- @tparam              any                      args             物品任意字段:名字，资源 或{名字,名字,..},{id1,id2,..}..等
-- @tparam              string                   any_key          物品属性值(字段)
-- @tparam              number                   pos_type         读取位置【0背包 1身上】默认0
-- @tparam              bool                     stop_vague       是否不使用模糊搜索
-- @treturn             list                                      返回包含物品信息的所有物品表 包括
-- @tfield[table]       number                   obj              物品实例对象
-- @tfield[table]       string                   name             物品名称
-- @tfield[table]       number                   res_ptr          物品资源指针
-- @tfield[table]       number                   id               物品ID
-- @tfield[table]       number                   res_id           物品资源ID
-- @tfield[table]       number                   pos              物品位置
-- @tfield[table]       number                   type             物品类型
-- @tfield[table]       number                   num              物品数量
-- @tfield[table]       number                   quality          物品品质
-- @tfield[table]       number                   level            物品等级
-- @tfield[table]       number                   durability       装备耐久
-- @tfield[table]       number                   max_durability   装备最大耐久
-- @tfield[table]       number                   equip_level      装备等级
-- @tfield[table]       number                   trade_level      评分等级
-- @tfield[table]       number                   equippable_level 使用等级
-- @usage
-- local item_list = item_ent.get_item_list_by_list_any('生命药水（小）', 'name', 0)
-- local item_list = item_ent.get_item_list_by_list_any({'生命药水（小）','生命药水（大）'}, 'name', 0)
-- local item_list = item_ent.get_item_list_by_list_any(0x123, 'id', 0)
-- local item_list = item_ent.get_item_list_by_list_any({0x123,0x1234}, 'id', 0)
------------------------------------------------------------------------------------
item_ent.get_item_list_by_list_any = function(args, any_key, pos_type,stop_vague)
    pos_type = pos_type or 0
    local r_tab = {}
    local list = item_unit.list(pos_type)
    local item_obj = item_unit:new()
    for _, obj in ipairs(list) do
        if item_obj:init(obj) then
            -- 获取指定属性的值
            local _any = item_obj[any_key](item_obj)
            local num = item_obj:num()
            if num > 0 then
                -- 当前对象 是否需获取的目标
                if common.is_exist_list_arg(args, _any,stop_vague) then
                    local name   = item_obj:name()
                    local marble = {}
                    -- 是否为能力石
                    if item_obj:is_marble() then
                        local main_type_num = item_obj:get_marble_main_type_num() --  总类型数
                        for i = 0, main_type_num - 1 do
                            local info = {}
                            local engraving_num = item_obj:get_engraving_num(i) -- 能力石序号取刻印总数（0开始。）
                            -- 主序号
                            info.main_idx          = i
                            -- 刻印条总数
                            info.engraving_num     = engraving_num
                            -- 是否刻印满
                            info.is_engraving_full = item_obj:is_engraving_full(i)
                            -- 当前序号下对应刻印状态
                            local engraving_info = {}
                            for j = 0, engraving_num - 1 do
                                local engraving_status          = item_obj:get_engraving_status(i, j)
                                -- 当前刻印序号下当前刻印idx
                                engraving_info.engraving_idx    = j
                                -- 能力石刻印状态(主序号012， 刻印序号0开始紫0到7) (反回0未刻印1 成功 2 失败)
                                engraving_info.engraving_status = engraving_status
                            end
                            -- 当前序号下对应刻印状态
                            info.engraving_info = engraving_info
                            table.insert(marble,info)
                        end
                    end
                    local result = {
                        -- 物品实例对象
                        obj              = obj,
                        -- 物品名称
                        name             = name,
                        -- 物品资源指针
                        res_ptr          = item_obj:res_ptr(),
                        -- 物品ID
                        id               = item_obj:id(),
                        -- 物品资源ID
                        res_id           = item_obj:res_id(),
                        -- 物品位置
                        pos              = item_obj:pos(),
                        -- 物品类型
                        type             = item_obj:type(),
                        -- 物品数量
                        num              = num,
                        -- 装备品质
                        quality          = item_obj:quality(),
                        -- 物品等级
                        level            = item_obj:level(),
                        -- 当前耐久
                        durability       = item_obj:durability(),
                        -- 最大耐久
                        max_durability   = item_obj:max_durability(),
                        -- 装备等级
                        equip_level      = item_obj:equip_level(),
                        -- 评分等级
                        trade_level      = item_obj:trade_level(),
                        -- 使用等级
                        equippable_level = item_obj:equippable_level(),
                        -- 装备使用部位
                        par              = this.get_equip_par_by_name(name),
                        -- 能力石信息
                        marble           = marble
                    }
                    if result.trade_level == 0 and name == '优异的飞翔之石' then
                        result.trade_level = 250
                        -- 标记不可删除
                        result.can_not_del = true
                    end
                    table.insert(r_tab, result)
                end
            end
        end
    end
    item_obj:delete()
    return r_tab
end

------------------------------------------------------------------------------------
-- [读取] 根据物品任意字段值返回物品信息表
--
-- @tparam              any                      args             物品任意字段:名字，资源 或{名字,名字,..},{id1,id2,..}..等
-- @tparam              string                   any_key          物品属性值(字段)
-- @tparam              number                   pos_type         读取位置【0背包 1身上 2 生活】默认0
-- @treturn             table                                     返回包含所有物品信息的table
-- @tfield[table]       number                   obj              物品实例对象
-- @tfield[table]       string                   name             物品名称
-- @tfield[table]       number                   res_ptr          物品资源指针
-- @tfield[table]       number                   id               物品ID
-- @tfield[table]       number                   res_id           物品资源ID
-- @tfield[table]       number                   pos              物品位置
-- @tfield[table]       number                   type             物品类型
-- @tfield[table]       number                   num              物品数量
-- @tfield[table]       number                   quality          物品品质
-- @tfield[table]       number                   level            物品等级
-- @tfield[table]       number                   durability       装备耐久
-- @tfield[table]       number                   max_durability   装备最大耐久
-- @tfield[table]       number                   equip_level      装备等级
-- @tfield[table]       number                   trade_level      交易限制等级
-- @tfield[table]       number                   equippable_level 使用等级
-- @usage
-- local item_info = item_ent.get_item_info_by_any('生命药水', 'name', 0)
-- local item_info = item_ent.get_item_info_by_any(0x123, 'id', 0)
------------------------------------------------------------------------------------
item_ent.get_item_info_by_any = function(args, any_key, pos_type)
    pos_type       = pos_type or 0
    local result   = {}
    local item_obj = item_unit:new()
    local list     = item_unit.list(pos_type)
    for _, obj in ipairs(list) do
        if item_obj:init(obj) then
            -- 获取指定属性的值
            local _any = item_obj[any_key](item_obj)
            local num  = item_obj:num()
            local name = item_obj:name()
            -- 配对目标值
            if args == _any and num > 0 then
                local marble = {}
                -- 是否为能力石
                if item_obj:is_marble() then
                    local main_type_num = item_obj:get_marble_main_type_num() --  总类型数
                    for i = 0, main_type_num - 1 do
                        local info = {}
                        local engraving_num = item_obj:get_engraving_num(i) -- 能力石序号取刻印总数（0开始。）
                        -- 主序号
                        info.main_idx          = i
                        -- 刻印条总数
                        info.engraving_num     = engraving_num
                        -- 是否刻印满
                        info.is_engraving_full = item_obj:is_engraving_full(i)
                        -- 当前序号下对应刻印状态
                        local engraving_info = {}
                        for j = 0, engraving_num - 1 do
                            local engraving_status          = item_obj:get_engraving_status(i, j)
                            -- 当前刻印序号下当前刻印idx
                            engraving_info.engraving_idx    = j
                            -- 能力石刻印状态(主序号012， 刻印序号0开始紫0到7) (反回0未刻印1 成功 2 失败)
                            engraving_info.engraving_status = engraving_status
                        end
                        -- 当前序号下对应刻印状态
                        info.engraving_info = engraving_info
                        table.insert(marble,info)
                    end
                end

                result = {
                    -- 物品实例对象
                    obj              = obj,
                    -- 物品名称
                    name             = name,
                    -- 物品资源指针
                    res_ptr          = item_obj:res_ptr(),
                    -- 物品ID
                    id               = item_obj:id(),
                    -- 物品资源ID
                    res_id           = item_obj:res_id(),
                    -- 物品位置
                    pos              = item_obj:pos(),
                    -- 物品类型
                    type             = item_obj:type(),
                    -- 物品数量
                    num              = num,
                    -- 装备品质
                    quality          = item_obj:quality(),
                    -- 物品等级
                    level            = item_obj:level(),
                    -- 当前耐久
                    durability       = item_obj:durability(),
                    -- 最大耐久
                    max_durability   = item_obj:max_durability(),
                    -- 装备等级
                    equip_level      = item_obj:equip_level(),
                    -- 评分等级
                    trade_level      = item_obj:trade_level(),
                    -- 使用等级
                    equippable_level = item_obj:equippable_level(),
                    -- 装备使用部位
                    par              = this.get_equip_par_by_name(name),
                    -- 能力石信息
                    marble           = marble
                }
                if result.trade_level == 0 and name == '优异的飞翔之石' then
                    result.trade_level = 250
                    -- 标记不可删除
                    result.can_not_del = true
                end
                break
            end
        end
    end
    item_obj:delete()
    return result
end

------------------------------------------------------------------------------------
-- [读取] 获取背包所有物品
--
-- @tparam              number                   bag_type         读取位置【0背包 1身上 2 生活】默认0
-- @treturn             table                                     返回包含所有物品信息的table
-- @tfield[table]       number                   obj              物品实例对象
-- @tfield[table]       string                   name             物品名称
-- @tfield[table]       number                   res_ptr          物品资源指针
-- @tfield[table]       number                   id               物品ID
-- @tfield[table]       number                   res_id           物品资源ID
-- @tfield[table]       number                   pos              物品位置
-- @tfield[table]       number                   type             物品类型
-- @tfield[table]       number                   num              物品数量
-- @tfield[table]       number                   quality          物品品质
-- @tfield[table]       number                   level            物品等级
-- @tfield[table]       number                   durability       装备耐久
-- @tfield[table]       number                   max_durability   装备最大耐久
-- @tfield[table]       number                   equip_level      装备等级
-- @tfield[table]       number                   trade_level      评分等级
-- @tfield[table]       number                   equippable_level 使用等级
-- @usage
-- local item_info = item_ent.get_item_info(bag_type)
------------------------------------------------------------------------------------
item_ent.get_item_info = function(bag_type)
    local ret_t    = {}
    bag_type       = bag_type or 0
    local list     = item_unit.list(bag_type)
    local item_obj = item_unit:new()
    for _, obj in pairs(list) do
        if item_obj:init(obj) then
            local name = item_obj:name()
            local num  = item_obj:num()
            if num > 0 then
                local marble = {}
                -- 是否为能力石
                if item_obj:is_marble() then
                    local main_type_num  = item_obj:get_marble_main_type_num() --  总类型数
                    for i = 0, main_type_num - 1 do
                        local info = {}
                        local engraving_num = item_obj:get_engraving_num(i) -- 能力石序号取刻印总数（0开始。）
                        -- 主序号
                        info.main_idx          = i
                        -- 刻印条总数
                        info.engraving_num     = engraving_num
                        -- 是否刻印满
                        info.is_engraving_full = item_obj:is_engraving_full(i)
                        -- 当前序号下对应刻印状态
                        local engraving_info   = {}
                        for j = 0, engraving_num - 1 do
                            local ret                       = {}
                            local engraving_status          = item_obj:get_engraving_status(i, j)
                            -- 当前刻印序号下当前刻印idx
                            ret.engraving_idx    = j
                            -- 能力石刻印状态(主序号012， 刻印序号0开始紫0到7) (反回0未刻印1 成功 2 失败)
                            ret.engraving_status = engraving_status
                            table.insert(engraving_info,ret)
                        end
                        -- 当前序号下对应刻印状态
                        info.engraving_info = engraving_info
                        table.insert(marble,info)
                    end
                end
                local result = {
                    -- 物品实例对象
                    obj              = obj,
                    -- 物品名称
                    name             = name,
                    -- 物品资源指针
                    res_ptr          = item_obj:res_ptr(),
                    -- 物品ID
                    id               = item_obj:id(),
                    -- 物品资源ID
                    res_id           = item_obj:res_id(),
                    -- 物品位置
                    pos              = item_obj:pos(),
                    -- 物品类型
                    type             = item_obj:type(),
                    -- 物品数量
                    num              = num,
                    -- 装备品质
                    quality          = item_obj:quality(),
                    -- 物品等级
                    level            = item_obj:level(),
                    -- 当前耐久
                    durability       = item_obj:durability(),
                    -- 最大耐久
                    max_durability   = item_obj:max_durability(),
                    -- 装备等级
                    equip_level      = item_obj:equip_level(),
                    -- 评分等级
                    trade_level      = item_obj:trade_level(),
                    -- 使用等级
                    equippable_level = item_obj:equippable_level(),
                    -- 装备使用部位
                    par              = this.get_equip_par_by_name(name),
                    -- 刻印信息
                    marble           = marble,

                }
                if result.trade_level == 0 and name == '优异的飞翔之石' then
                    result.trade_level = 250
                    -- 标记不可删除
                    result.can_not_del = true
                end
                table.insert(ret_t, result)
            end
        end
    end
    item_obj:delete()
    return ret_t
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function item_ent.__tostring()
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
item_ent.__newindex = function(t, k, v)
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
item_ent.__index = item_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function item_ent:new(args)
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
    return setmetatable(new, item_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return item_ent:new()

-------------------------------------------------------------------------------------