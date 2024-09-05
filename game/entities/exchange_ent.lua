------------------------------------------------------------------------------------
-- game/entities/exchange_ent.lua
--
-- 关闭UI单元
--
-- @module      exchange_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local exchange_ent = import('game/entities/exchange_ent')
------------------------------------------------------------------------------------
local main_ctx = main_ctx
-- 模块定义
---@class exchange_ent
local exchange_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME = 'exchange_ent module',
    -- 只读模式
    READ_ONLY = false,
    -- 临时物价
    TEMPORARY_PRICE_PATH = '方舟:数据记录:服务器:' .. main_ctx:c_server_name() .. ':共享:临时物价:',
    -- 临时物价超时
    TEMPORARY_PRICE_TIME_OUT = 6 * 3600,
    -- 保留收集-最大单价限制
    MAX_PRICE_FOR_COLLECT = 5
}

-- 实例对象
local this = exchange_ent
-- 日志模块
local trace = trace
-- 决策模块
local decider = decider
local common = common
local pairs = pairs
local setmetatable = setmetatable
local item_unit = item_unit
local ui_unit = ui_unit
local exchange_unit = exchange_unit
local exchange_ctx = exchange_ctx
local import = import
---@type item_ent
local item_ent = import('game/entities/item_ent')
---@type item_res
local item_res = import('game/resources/item_res')
---@type map_res
local map_res = import('game/resources/map_res')
---@type user_set_ent
local user_set_ent = import('game/entities/user_set_ent')

local exchange_res = import('game/resources/exchange_res')
local ui_ent = import('game/entities/ui_ent')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function exchange_ent.super_preload()

end

function exchange_ent.get_item_price(item_name)
    local price = 0
    local search_num = exchange_unit.get_trade_search_item_num()
    for j = 0, search_num - 1 do
        if exchange_unit.get_trade_search_item_name(j) == item_name then
            price = exchange_unit.get_trade_search_item_price(j)
            break
        end
    end
    return price
end

function exchange_ent.get_item_tip(price)
    local tip = -1
    local tip_res = exchange_res.TIP
    for _, v in pairs(tip_res) do
        if price >= v[1] and price <= v[2] then
            tip = _
            break
        end
    end
    return tip
end

--------------------------------------------------------------------------------
-- [行为] 交易行通用功能(外部使用)
--
-- @tparam      table       res_id      购买物品res_id(不购买物品不用设置参数)
-- @tparam      integer     level       物品等级(不购买物品不用设置参数)
-- @treturn
-- @usage
-- exchange_ent.exchange(res_id,物品等级)
--------------------------------------------------------------------------------
exchange_ent.exchange = function()
    if user_set_ent['开启上架'] ~= 1 then
        return false,'没有开启上架'
    end
    local item_info = item_ent.get_item_info(0)
    for i = 1, #item_info do
        local item_name = item_info[i].name
        local item_num = item_info[i].num
        local item_id = item_info[i].id
        local sell_item = exchange_res.SELL_ITEM[item_name]
        if sell_item and item_num >= sell_item.num then
            exchange_ent.exchange_item(item_name, item_num, item_id, sell_item.kun)
            decider.sleep(1000)
            exchange_ent.close_exchange_ui()
        end
    end
    exchange_ent.close_exchange_ui()
end

exchange_ent.exchange_item = function(item_name, item_num, item_id, kun)
    local sell_item_num = item_num
    if kun then
        sell_item_num = math.floor(item_num / 10)
    end
    if sell_item_num <= 0 then
        xxmsg('物品数量低于1个')
        return false, '物品数量低于1个'
    end

    if exchange_ent.open_exchange_ui() and exchange_ent.change_exchange0() and exchange_ent.trade_change_group2() then
        if exchange_unit.get_trade_sell_num() >= 10 then
            xxmsg('已上架物品数量大于10个')
            return false, '已上架物品数量大于10个'
        end
    else
        xxmsg('打开失败')
    end
    xxmsg('---------------')
    -- 打开交易行
    if exchange_ent.open_exchange_ui() and exchange_ent.change_exchange0() and exchange_ent.trade_change_group0() then
        -- 搜索物品
        exchange_unit.trade_search_item(item_name)
        decider.sleep(4000)
        -- 获取物品价格
        local price = exchange_ent.get_item_price(item_name)
        if price <= 0 then
            xxmsg('未获取到物品价格')
            return false, '未获取到物品价格'
        end
        -- 小费
        local tip = exchange_ent.get_item_tip(price)
        if tip == -1 then
            xxmsg('未获取到物品上架价格')
            return false, '未获取到物品上架价格'
        end

        local my_money = item_unit.get_money_byid(2)
        if my_money < tip * sell_item_num then
            if my_money > tip then
                sell_item_num = math.floor(my_money / tip)
            else
                sell_item_num = 0
            end
        end
        if sell_item_num <= 0 then
            xxmsg('物品数量低于1个')
            return false, '物品数量低于1个'
        end
        exchange_unit.open_trade_up_wnd()
        decider.sleep(1000)
        if exchange_unit.trade_up_wnd_is_open() then
            exchange_unit.trade_up_item(item_id, price, sell_item_num, 0)
            decider.sleep(1000)
            for i = 1, 10 do
                if my_money ~= item_unit.get_money_byid(2) then
                    break
                end
                decider.sleep(1000)
            end
            if ui_unit.has_dialog() then
                ui_unit.confirm_dialog(true)
                decider.sleep(1000)
            end
        end
    else
        xxmsg('3.打开失败')
    end
end

-- 打开交易行窗口
exchange_ent.open_exchange_ui = function()
    local open = false
    local num = 0
    while decider.is_working() do
        if exchange_unit.get_exchange_shop_wnd() ~= 0 then
            xxmsg('1.打开交易行窗口')
            open = true
            break
        end
        if num >= 3 then
            break
        end
        ui_ent.esc_cinema()
        common.do_alt_key(89)
        decider.sleep(1000)
        num = num + 1
        for i = 1, 10 do
            if exchange_unit.get_exchange_shop_wnd() ~= 0 then
                break
            end
            decider.sleep(500)
        end
        decider.sleep(1000)
    end
    return open
end

-- 关闭交易行窗口
exchange_ent.close_exchange_ui = function()
    local close = false
    while decider.is_working() do
        if exchange_unit.get_exchange_shop_wnd() == 0 then
            close = true
            break
        end
        common.key_call('KEY_Esc')
        for i = 1, 10 do
            if exchange_unit.get_exchange_shop_wnd() == 0 then
                break
            end
            decider.sleep(500)
        end
        decider.sleep(1000)
    end
    return close
end

exchange_ent.change_exchange0 = function()
    local open = false
    local num = 0
    while decider.is_working() do
        if exchange_unit.get_exchang_sel_group() == 0 then
            xxmsg('2.打开交易行窗口')
            open = true
            break
        end
        if exchange_unit.get_exchange_shop_wnd() == 0 then
            break
        end
        exchange_unit.change_exchange(0)
        if num >= 3 then
            break
        end
        decider.sleep(1000)
    end
    return open
end

exchange_ent.trade_change_group0 = function()
    local open = false
    local num = 0
    while decider.is_working() do
        if exchange_unit.get_trade_select_group_idx() == 0 then
            xxmsg('3.打开交易行窗口')
            open = true
            break
        end
        if exchange_unit.get_exchange_shop_wnd() == 0 then
            break
        end
        if exchange_unit.get_exchang_sel_group() ~= 0 then
            break
        end
        exchange_unit.trade_change_group(0)

        if num >= 3 then
            break
        end
        decider.sleep(1000)
    end
    return open
end

exchange_ent.trade_change_group2 = function()
    local open = false
    local num = 0
    while decider.is_working() do
        if exchange_unit.get_trade_select_group_idx() == 2 then
            open = true
            break
        end
        if exchange_unit.get_exchange_shop_wnd() == 0 then
            break
        end
        if exchange_unit.get_exchang_sel_group() ~= 0 then
            break
        end
        exchange_unit.trade_change_group(2)
        if num >= 3 then
            break
        end
        decider.sleep(1000)
    end
    return open
end

------------------------------------------------------------------------------------
-- [行为] 上架物品
--
-- @tparam      table       item_info       物品信息
-- @tparam      integer     level           物品等级
-- @treturn     boolean
-- @usage
-- exchange_ent.up_item(物品信息,物品等级)
------------------------------------------------------------------------------------
exchange_ent.up_item = function()

end

------------------------------------------------------------------------------------
-- [行为] 通过物品信息上架物品
--
-- @tparam      table       item_info       物品信息
-- @tparam      boolean     is_equip        是否装备
-- @tparam      integer     level           物品等级
-- @treturn     boolean
-- @usage
-- exchange_ent.get_item_info_up_item(物品信息,是否装备,物品等级)
------------------------------------------------------------------------------------
function exchange_ent.get_item_info_up_item(item_info, is_equip, level)

end

------------------------------------------------------------------------------------
-- [条件] 是否存在可出售物品
exchange_ent.is_exist_sale_item = function()

end

------------------------------------------------------------------------------------
-- [行为] 查找物品单价
exchange_ent.get_price_search_name = function(item_info, is_equip, level)

end

------------------------------------------------------------------------------------
-- [行为] 结算交易行
--
-- @treturn     boolean
-- @usage
-- exchange_ent.calcul_gold()
------------------------------------------------------------------------------------
function exchange_ent.calcul_gold()

end

------------------------------------------------------------------------------------
-- 计算出售总价
exchange_ent.calculate_sale_price = function(p_price, num)

end

------------------------------------------------------------------------------------
-- [条件] 判断是否可结算
--
-- @treturn     boolean
-- @usage
-- exchange_ent.settlement()
------------------------------------------------------------------------------------
exchange_ent.settlement = function()

end

------------------------------------------------------------------------------------
-- [条件] 判断物品是否需要下架
--
-- @treturn     boolean
-- @usage
-- exchange_ent.take_down()
------------------------------------------------------------------------------------
exchange_ent.take_down = function()

end

------------------------------------------------------------------------------------
-- [读取] 获取物品价格信息表
--
-- @tparam      integer     res_id              物品信息
-- @tparam      integer     level               物品等级
-- @treturn     t
-- @tfield[t]   integer     obj                 物品实例对象
-- @tfield[t]   integer     id                  物品ID
-- @tfield[t]   integer     sale_player_id      卖家Id
-- @tfield[t]   integer     res_ptr             物品资源指针
-- @tfield[t]   integer     total_price         总价
-- @tfield[t]   integer     num                 物品数量
-- @tfield[t]   integer     price               单价
-- @tfield[t]   integer     expire_time         到期时间
-- @usage
-- local info = exchange_ent.get_item_min_price(物品信息,物品等级)
-- print_r(info)
------------------------------------------------------------------------------------
exchange_ent.get_item_min_price = function(item_info, is_equip, level)

end

------------------------------------------------------------------------------------
-- [读取] 获取交易行当前页面的物品信息
--
-- @treturn     t
-- @tfield[t]    integer    obj                 物品实例对象
-- @tfield[t]    integer    id                  物品ID
-- @tfield[t]    integer    sale_player_id      卖家Id
-- @tfield[t]    integer    res_ptr             物品资源指针
-- @tfield[t]    integer    total_price         总价
-- @tfield[t]    integer    num                 物品数量
-- @tfield[t]    integer    price               单价
-- @tfield[t]    integer    expire_time         到期时间
-- @usage
-- local info = exchange_ent.exchange_item_info()
-- print_r(info)
------------------------------------------------------------------------------------
function exchange_ent.exchange_item_info()

end

------------------------------------------------------------------------------------
-- [读取] 获取正在出售的信息
--
-- @treturn     t
-- @tfield[t]    integer    obj                 物品实例对象
-- @tfield[t]    integer    id                  物品ID
-- @tfield[t]    integer    sale_player_id      卖家Id
-- @tfield[t]    integer    res_ptr             物品资源指针
-- @tfield[t]    integer    total_price         总价
-- @tfield[t]    integer    num                 物品数量
-- @tfield[t]    integer    price               单价
-- @tfield[t]    integer    expire_time         到期时间
-- @usage
-- local info = exchange_ent.get_sell_list()
-- print_r(info)
------------------------------------------------------------------------------------
exchange_ent.get_sell_list = function()

end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function exchange_ent.__tostring()
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
function exchange_ent.__newindex(t, k, v)
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
exchange_ent.__index = exchange_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function exchange_ent:new(args)
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
    return setmetatable(new, exchange_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return exchange_ent:new()

-------------------------------------------------------------------------------------
