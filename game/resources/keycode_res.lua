------------------------------------------------------------------------------------
-- game/resources/keycode_res.lua
--
--
--
-- @module      键码资源
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local keycode_res = import('game/resources/keycode_res')
------------------------------------------------------------------------------------

local keycode_res = {
    KEYCODE_INFO = {
        ['KEY_LeftMouseButton'] = 1,
        ['KEY_RightMouseButton'] = 2,
        -- 字母和数字键的键码值(KeyCode)
        ['KEY_A'] = 65,
        ['KEY_B'] = 66,
        ['KEY_C'] = 67,
        ['KEY_D'] = 68,
        ['KEY_E'] = 69,
        ['KEY_F'] = 70,
        ['KEY_G'] = 71,
        ['KEY_H'] = 72,
        ['KEY_I'] = 73,
        ['KEY_J'] = 74,
        ['KEY_K'] = 75,
        ['KEY_L'] = 76,
        ['KEY_M'] = 77,
        ['KEY_N'] = 78,
        ['KEY_O'] = 79,
        ['KEY_P'] = 80,
        ['KEY_Q'] = 81,
        ['KEY_R'] = 82,
        ['KEY_S'] = 83,
        ['KEY_T'] = 84,
        ['KEY_U'] = 85,
        ['KEY_V'] = 86,
        ['KEY_W'] = 87,
        ['KEY_X'] = 88,
        ['KEY_Y'] = 89,
        ['KEY_Z'] = 90,
        ['KEY_0'] = 48,
        ['KEY_1'] = 49,
        ['KEY_2'] = 50,
        ['KEY_3'] = 51,
        ['KEY_4'] = 52,
        ['KEY_5'] = 53,
        ['KEY_6'] = 54,
        ['KEY_7'] = 55,
        ['KEY_8'] = 56,
        ['KEY_9'] = 57,
        -- 功能键键码值(KeyCode)
        ['KEY_F1'] = 112,
        ['KEY_F2'] = 113,
        ['KEY_F3'] = 114,
        ['KEY_F4'] = 115,
        ['KEY_F5'] = 116,
        ['KEY_F6'] = 117,
        ['KEY_F7'] = 118,
        ['KEY_F8'] = 119,
        ['KEY_F9'] = 120,
        ['KEY_F10'] = 121,
        ['KEY_F11'] = 122,
        ['KEY_F12'] = 123,
        -- 控制键键码值(KeyCode)
        ['KEY_BackSpace'] = 8,
        ['KEY_Tab']    = 9,
        ['KEY_Clear']  = 12,
        ['KEY_Enter']  = 13,
        ['KEY_Shift']  = 0xA0,--16
        ['KEY_Ctrl']   = 0xA2,--17
        ['KEY_Alt']    = 0xA4,--18
        ['KEY_Cape Lock'] = 20,
        ['KEY_Esc'] = 27,
        ['KEY_空格'] = 32,
        ['KEY_PageUp'] = 33,
        ['KEY_PageDown'] = 34,
        ['KEY_End'] = 35,
        ['KEY_Home'] = 36,
        ['KEY_LeftArrow'] = 37,
        ['KEY_UpArrow'] = 38,

    },
}

-- 自身模块
local this = keycode_res

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return keycode_res

-------------------------------------------------------------------------------------