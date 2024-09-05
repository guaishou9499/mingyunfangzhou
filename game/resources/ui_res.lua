------------------------------------------------------------------------------------
-- game/resources/ui_res.lua
--
--
--
-- @module      ui_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local ui_res = import('game/resources/ui_res')
------------------------------------------------------------------------------------
local daily_unit = daily_unit
local ui_unit    = ui_unit
local ui_res = {
    NEED_CLOSE = {
        ['签到'] = { parent = 'attendanceWnd',child = '' },
        -- ['消息'] = { parent = 'safeModeWnd',child = 'closeBtn' },
        ['消息UI'] = { parent = 'ingameWebEventWnd',child = 'closeBtn' },
        ['功能菜单'] = { parent = 'exitMenuWindow',child = '' },
        ['乐普'] = { parent = 'musicWnd',child = '' },
        ['任务日志'] = { parent = 'W_questjournal',child = '' },
        ['升级技能'] = { parent = 'skillBookNewWnd',child = '' },
        ['玩法目录'] = { parent = '',child = '',func = ui_unit.is_open_play_dir_wnd },
        ['日常窗口'] = { parent = '',child = '',func = daily_unit.is_open_daily_wnd },
        ['任务提示'] = { parent = 'W_QuestProp',child = 'QuestPropWndContent' },
        ['道具分解'] = { parent = 'itemDisassembleWnd',child = 'closeBtn' },
        ['讨伐MVP'] = { parent = 'mvpResultFrame',child = '' },
        -- ['讨伐播报'] = { parent = 'voiceChatFrame',child = '' },
        --     道具分解 UI
        --     0000000108273C4C [00000000F020B890] [00000001BE58F700] [00000000FDBDE470] HWND[00000025] TYPE[00000002] VISIBLE[00000001] itemDisassembleWnd
        --     00000000D3B9D240     ItemDisassembleWndContent
        --     00000000DCB19CE0     closeBtn
    },
}

-- 自身模块
local this = ui_res

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return ui_res

-------------------------------------------------------------------------------------