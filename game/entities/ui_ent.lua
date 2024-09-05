------------------------------------------------------------------------------------
-- game/entities/ui_ent.lua
--
-- 关闭UI单元
--
-- @module      ui_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local ui_ent = import('game/entities/ui_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class ui_ent
local ui_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION        = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE    = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME    = 'ui_ent module',
    -- 只读模式
    READ_ONLY      = false,
}

-- 实例对象
local this         = ui_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local common       = common
local pairs        = pairs
local setmetatable = setmetatable
local ui_unit      = ui_unit
local game_unit    = game_unit
local item_unit    = item_unit
local import       = import
local ship_unit    = ship_unit
local ui_res       = import('game/resources/ui_res')

------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function ui_ent.super_preload()
    --local inventoryWnd = ui_unit.get_parent_widget('inventoryWnd', true)
    --if inventoryWnd ~= 0 then  -- 结束专职
    --    xxmsg('inventoryWnd:'..inventoryWnd)
    --    local mainBag = ui_unit.get_child_widget(inventoryWnd, 'mainBag')
    --    xxmsg('mainBag '..mainBag)
    --end
end

-- 0000000108273760 [00000000FE0A4930] [0000000042731840] [00000000F59DF7F0] HWND[0000001A] TYPE[00000002] VISIBLE[00000001] inventoryWnd
--     00000000F59CEB90     titleBtn
--     00000000F59BE980     topBtn
--     00000000F576FC80     form_inventory1
--    [0000000042732C80] [00000001732E9200] [00000000F59BEF60] bt_disassembly
--local anchorFrame = ui_unit.get_parent_widget('inventoryWnd', true)
--local titleBtn = ui_unit.get_child_widget(anchorFrame, 'titleBtn')
--local bt_disassembly = ui_unit.get_child_widget(titleBtn, 'bt_disassembly') -- 入港
--
--000000011E3F3CC4 [0000000025DA20E0] [0000000068B86A60] [00000002575C3130] HWND[000000A8] TYPE[00000002] VISIBLE[00000001] dungeonEntranceWnd
--     0000000252572510     closeBtn
--    [000000018C548680] [00000000D786B400] [00000002579C1000] DungeonEntranceWndContent
--    [000000018C5492E0] [00000000D7863600] [00000001AF1F3D70] conditionBtn

--
--local anchorFrame = ui_unit.get_parent_widget('anchorFrame', true)
--local rightContent = ui_unit.get_child_widget(anchorFrame, 'rightContent')
--local moveBtn = ui_unit.get_child_widget(rightContent, 'moveBtn') -- 入港
--
--local anchorFrame = ui_unit.get_parent_widget('anchorFrame', true)
--local rightContent = ui_unit.get_child_widget(anchorFrame, 'rightContent')
--local startBtn = ui_unit.get_child_widget(rightContent, 'startBtn') -- 出港
--
--local anchorFrame = ui_unit.get_parent_widget('anchorFrame', true)
--local centerContent = ui_unit.get_child_widget(anchorFrame, 'centerContent')
--local repairBtn_bottom = ui_unit.get_child_widget(centerContent, 'repairBtn_bottom') --修理耐久度 打开

--00000001DAA61CF8 [00000000418EFB70] [000000017FD56D00] [0000000237210AE0] HWND[00000091] TYPE[00000002] VISIBLE[00000001] raidProcessor
--     00000002085AC6B0     replayBtn
--     00000001E9EC0570     exitBtn
--     00000002245CC730     stopBtn
--    [00000001E724F700] [000000017FD51200] [00000002245CC730] stopBtn
--    [00000001E7242C80] [000000017FD53B00] [00000001E9EC0570] exitBtn
--    [00000001E72492E0] [000000017FD53A00] [00000002085AC6B0] replayBtn
------------------------------------------------------------------------------------
-- [行为] 退出讨伐
ui_ent.exist_stars = function()
    local anchorFrame    = ui_unit.get_parent_widget('raidProcessor', true)
    if anchorFrame == 0 then return end
    local centerContent  = ui_unit.get_child_widget(anchorFrame, 'exitBtn')
    if centerContent ~= 0 then
        trace.output('退出讨伐.')
        decider.sleep(1000)
        ui_unit.do_click(centerContent)
        decider.sleep(1000)
        for i = 1,2 do
            if ui_unit.has_dialog() then
                decider.sleep(500)
                ui_unit.confirm_dialog(true)
                decider.sleep(1000)
            end
        end
        decider.sleep(2000)
    end
end

------------------------------------------------------------------------------------
-- [行为] 领取星辰道具
ui_ent.get_all_item_in_stars = function()
    local anchorFrame    = ui_unit.get_parent_widget('practiceBattleItemWnd', true)
    if anchorFrame == 0 then return end
    local centerContent  = ui_unit.get_child_widget(anchorFrame, 'PracticeBattleItemWndContent')
    local bt_disassembly = ui_unit.get_child_widget(centerContent, 'getAllBtn')
    if bt_disassembly ~= 0 then
        trace.output('领取星辰道具.')
        ui_unit.do_click(bt_disassembly)
        decider.sleep(1000)
        for i = 1,2 do
            if ui_unit.has_dialog() then
                decider.sleep(500)
                ui_unit.confirm_dialog(true)
                decider.sleep(1000)
            end
        end
    end
end

------------------------------------------------------------------------------------
-- [行为] 修理船耐
ui_ent.repair_ship = function()
    local anchorFrame    = ui_unit.get_parent_widget('anchorFrame', true)
    if anchorFrame == 0 then return end
    local centerContent  = ui_unit.get_child_widget(anchorFrame, 'centerContent')
    local bt_disassembly = ship_unit.get_cur_ship_durable() == 0 and ui_unit.get_child_widget(centerContent, 'repairBtn') or ui_unit.get_child_widget(centerContent, 'repairBtn_bottom')
    if bt_disassembly ~= 0 then
        trace.output('修理船耐.')
        ui_unit.do_click(bt_disassembly)
        decider.sleep(1000)
        for i = 1,2 do
            if ui_unit.has_dialog() then
                decider.sleep(500)
                ui_unit.confirm_dialog(true)
                decider.sleep(1000)
            end
        end
    end
end

------------------------------------------------------------------------------------
-- [行为] 打开分解
ui_ent.open_deco = function()
    while decider.is_working() do
        -- 背包未打开 退出
        if not this.is_open_bag() then
           break
        end
        -- 分解窗口是否打开
        if ui_ent.is_open_deco() then
            return true
        end
        if not ship_unit.is_in_ocean() and not ship_unit.is_open_anchor_frame() then
            local anchorFrame    = ui_unit.get_parent_widget('inventoryWnd', true)
            local titleBtn       = ui_unit.get_child_widget(anchorFrame, 'form_inventory1')
            local bt_disassembly = ui_unit.get_child_widget(titleBtn, 'bt_disassembly') -- 打开分解UI
            if bt_disassembly == 0 then
                break
            end
            trace.output('打开分解背包')
            ui_unit.do_click(bt_disassembly)
        else
            break
        end
        decider.sleep(1000)
    end
    return false
end

------------------------------------------------------------------------------------
-- [行为] 打开背包
ui_ent.open_bag = function()
    while decider.is_working() do
        if this.is_open_bag() then
            return true
        end
        -- 强化窗口打开
        if item_unit.is_open_item_build_up_wnd() then
            common.key_call('KEY_Esc')
        end
        if not ship_unit.is_in_ocean() and not ship_unit.is_open_anchor_frame() then
            this.esc_cinema()
            trace.output('打开背包')
            common.key_call('KEY_I')
        else
            break
        end
        decider.sleep(1000)
    end
    return false
end

------------------------------------------------------------------------------------
-- [行为] 关闭背包
ui_ent.close_bag = function()
    this.check_safe()
    while decider.is_working() do
        if not this.is_open_bag() then
            return false
        end
        trace.output('关闭背包')
        common.key_call('KEY_Esc')
        decider.sleep(1000)
    end
    return true
end

------------------------------------------------------------------------------------
-- [条件] 背包是否打开
ui_ent.is_open_bag = function()
    local bag_ui = ui_unit.get_parent_widget('inventoryWnd', true)
    if bag_ui ~= 0 then  --
        return true
    end
    return false
end

------------------------------------------------------------------------------------
-- [条件] 分解是否打开
ui_ent.is_open_deco = function()
    local bag_ui = ui_unit.get_parent_widget('itemDisassembleWnd', true)
    if bag_ui ~= 0 then  --
        return true
    end
    return false
end

------------------------------------------------------------------------------------
-- [条件] 角色死亡UI是否开启
ui_ent.is_find_deadSceneWnd = function()
    local bag_ui = ui_unit.get_parent_widget('deadSceneWnd', true)
    if bag_ui ~= 0 then
        return true
    end
    return false
end

------------------------------------------------------------------------------------
-- [行为] 整理背包
ui_ent.auto_sort_bag = function()
    local anchorFrame    = ui_unit.get_parent_widget('inventoryWnd', true)
    if anchorFrame == 0 then return end
    local titleBtn       = ui_unit.get_child_widget(anchorFrame, 'form_inventory1')
    local bt_disassembly = ui_unit.get_child_widget(titleBtn, 'bt_autosort')
    if bt_disassembly ~= 0 then
        trace.output('整理背包.')
        ui_unit.do_click(bt_disassembly)
        decider.sleep(1000)
    end
end

------------------------------------------------------------------------------------
-- [行为] 接取任务[采集类对话]
ui_ent.accept_task = function()
    local questSummaryWnd = ui_unit.get_parent_widget('questSummaryWnd', true)
    local rightContent = ui_unit.get_child_widget(questSummaryWnd, 'QuestSummaryWndContent')
    local accept_btn = ui_unit.get_child_widget(rightContent, 'accept_btn')
    if accept_btn ~= 0 then
        ui_unit.do_click(accept_btn)
    end
end

------------------------------------------------------------------------------------
-- [行为] 退出NPC对话
ui_ent.exist_npc_talk = function()
    local interactionMainFrame = ui_unit.get_parent_widget('interactionMainFrame', true)
    local closeBtnMc           = ui_unit.get_child_widget(interactionMainFrame, 'closeBtnMc')
    local bt_close             = ui_unit.get_child_widget(closeBtnMc, 'Bt_close')
    if bt_close ~= 0 then
        -- trace.output('退出对话')
        ui_unit.do_click(bt_close)
        decider.sleep(2000)
    end
end

------------------------------------------------------------------------------------
-- [行为] 跳过动画
ui_ent.esc_cinema = function()
    this.close_ui()
    this.check_safe()
    while decider.is_working() do
        if not game_unit.has_plot() then
            break
        end
        trace.output('动画中..')
        if common.is_sleep_any('跳过动画_esc_cinema',2) then
            -- 按键ESC
            common.key_call('KEY_Esc')
        end
        decider.sleep(1000)
    end
    local exitMenuWindow = ui_unit.get_parent_widget('exitMenuWindow', true)
    if exitMenuWindow ~= 0 then
        common.key_call('KEY_Esc')
        decider.sleep(1000)
    end
end

------------------------------------------------------------------------------------
-- 检测安全模式状态
ui_ent.check_safe = function()
    while decider.is_working() do
        if ui_unit.has_dialog() then
            trace.output('关闭弹窗.')
            ui_unit.confirm_dialog(true)
            decider.sleep(1000)
        end
        local captionFrame = ui_unit.get_parent_widget('safeModeWnd', true)
        if captionFrame == 0 then
            return
        end
        local closeBtn     = ui_unit.get_child_widget(captionFrame, 'closeBtn')
        if closeBtn == 0 then
            return
        end
        local count = common.get_key_table('ui_check_safe') or 0
        if count < 3 then
            common.key_call('KEY_Esc')
            common.set_key_table('ui_check_safe',count + 1)
        else
            trace.output('需要解除安全模式...')
        end
        decider.sleep(1000)
    end
end

------------------------------------------------------------------------------------
-- 关闭UI
ui_ent.close_ui = function()
    while decider.is_working() do
        if ui_unit.has_dialog() then
            trace.output('关闭弹窗.')
            ui_unit.confirm_dialog(true)
            decider.sleep(1000)
        end
        local ui_list = ui_res.NEED_CLOSE
        local need_close = false
        for ui_name,v in pairs(ui_list) do
            if v.func and v.func() then
                need_close = true
            else
                local captionFrame = ui_unit.get_parent_widget(v.parent, true)
                if captionFrame ~= 0 then
                    if v.child and v.child ~= '' then
                        local child = ui_unit.get_child_widget(captionFrame, v.child)
                        if child ~= 0 then
                            need_close = true
                        end
                    else
                        need_close = true
                    end
                end
            end
            if need_close then
                trace.output('关闭'..ui_name..'页面..')
                decider.sleep(500)
                common.key_call('KEY_Esc')
                decider.sleep(1000)
                break
            end
        end
        if not need_close then
            return
        end
        decider.sleep(1000)
    end
end
------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function ui_ent.__tostring()
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
function ui_ent.__newindex(t, k, v)
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
ui_ent.__index = ui_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function ui_ent:new(args)
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
    return setmetatable(new, ui_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return ui_ent:new()

-------------------------------------------------------------------------------------
