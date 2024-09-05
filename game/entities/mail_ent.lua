local VERSION     = '20211031' -- version history at end of file
local AUTHOR_NOTE = "-[20211031]-"
---@class mail_ent
local mail_ent = {
    VERSION         = VERSION,
    AUTHOR_NOTE     = AUTHOR_NOTE,

}
local this         = mail_ent
local decider      = decider
local actor_unit   = actor_unit
local trace        = trace
local common       = common
local mail_unit    = mail_unit
local item_unit    = item_unit
local table        = table
local pairs        = pairs
local setmetatable = setmetatable
---@type item_ent
local item_ent     = import('game/entities/item_ent')
---@type shop_ent
local shop_ent     = import('game/entities/shop_ent')
---@type user_set_ent
local user_set_ent = import('game/entities/user_set_ent')
local utils        = import('base/utils')
------------------------------------------------------------------------------------
-- [行为] 领取邮件
------------------------------------------------------------------------------------
function mail_ent.get_mail()
    local get_num = 0
    while decider.is_working() do
        -- 副本中退出
        if actor_unit.is_dungeon_map() and actor_unit.map_name() ~= '特里希温' then
            break
        end
        -- 没有邮件退出
        if not mail_unit.has_quick_mail() then
            break
        end
        -- 判断邮箱是否打开
        if not mail_unit.is_open_quick_mail_read_wnd() or get_num > 10 then
            trace.output('打开邮箱')
            -- 打开邮箱
            mail_unit.open_quick_mail_read_wnd()
            decider.sleep(3000)
            get_num = 1
        else
            trace.output('领取邮件['..get_num..']')
            -- 领取邮件
            mail_unit.receive_quick_mail(0)
            decider.sleep(500)
            get_num = get_num + 1
        end
    end
end

-------------------------------------------------------------------------------------
-- [行为] 邮寄    命令问题：无法邮寄物品 与 金币
mail_ent.execute_send_mail = function()
    -- 收件人
    local receive_name = user_set_ent['收件人']                    -- 提取参数
    if receive_name == '' or receive_name == '' then
        return false,'未设置收件人'
    end
    -- 邮件标题
    local mail_title   = user_set_ent['邮件标题']                  -- 提取参数
    -- 邮件内容
    local mail_details = user_set_ent['邮件内容']                  -- 提取参数
    -- 邮寄类型[0快递 1普通]
    local mail_type    = user_set_ent['邮寄类型']                  -- 提取参数
    --------------------------------------------------------------------------------------------------------------------
    -- 是否触发邮寄
    -- 需邮寄物品列表
    local send_item    = utils.split_string(user_set_ent['邮寄物品'], ',')   -- 提取参数
    -- 触发邮寄金币数
    local trigger_gold = user_set_ent['触发邮寄金币数'] or 1000
    -- 保留金币数
    local retain_gold  = user_set_ent['邮寄保留金币数'] or 20
    -- 单次邮寄金币限额
    local limit_gold   = user_set_ent['单次邮寄金限额'] or 0
    -- 获取可邮金币数
    local send_gold    = item_unit.get_money_byid(2) - retain_gold

    send_gold          = send_gold > limit_gold and limit_gold or send_gold
    -- 保存邮件物品位置列
    local send_pos     = {}
    -- 获取邮寄物品
    for _,name in pairs(send_item) do
        if name and name ~= '' then
            local info  = item_ent.get_item_info_by_name(name,0)
            if not table.is_empty(info) then
                table.insert(send_pos,info.pos)
            end
        end
    end
    if send_gold < trigger_gold and table.is_empty(send_pos) then
        return false,'可邮金币数未达到触发金币['..send_gold..'/'..trigger_gold..'],未找到可邮物品'
    end
    --------------------------------------------------------------------------------------------------------------------
    -- 移动到邮寄NPC
    local map_name        = actor_unit.map_name()
    local is_suc,npc_name = shop_ent.move_to_shop_npc(map_name,'邮件')
    if is_suc then
        -- 打开邮件窗口
        if shop_ent.open_mail_wnd(npc_name) then
            -- 发送邮件信息
            if mail_unit.get_select_mail_wnd_type() ~= 2 then
                trace.output('选择发送页')
                decider.sleep(2000)
                -- 选择邮件Group 类型（0 收件列表，1发件列表，2 邮件发送页）
                mail_unit.select_mail_group(2)
                decider.sleep(2000)
            end
            if mail_unit.get_select_mail_wnd_type() == 2 then
                trace.output('发送邮件')
                local cur_gold = item_unit.get_money_byid(2)
                decider.sleep(2000)
                mail_unit.send_mail(receive_name, mail_title,mail_details,mail_type,send_gold,0,send_pos)
                common.wait_change_money(cur_gold,'邮寄',30)
            end
        end
    end
    shop_ent.close_mail_wnd()
end

-------------------------------------------------------------------------------------
-- 实例化新对象

function mail_ent.__tostring()
    return "FZ mail package"
end

mail_ent.__index = mail_ent

function mail_ent:new(args)
    local new = { }

    if args then
        for key, val in pairs(args) do
            new[key] = val
        end
    end

    -- 设置元表
    return setmetatable(new, mail_ent)
end

-------------------------------------------------------------------------------------
-- 返回对象
return mail_ent:new()

-------------------------------------------------------------------------------------