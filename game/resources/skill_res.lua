-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   skill_res
-- @describe: 技能资源
-- @version:  v1.0
--
-------------------------------------------------------------------------------------
-- 物品资源
---@class skill_res
local skill_res = {
    -- 职业技能标记
    SKILL_JOB = {
        ['极寒召唤'] = { name = '魔法师',use_z = 90 },
        ['速射'] =  { name = '射手',use_z = 11 },
    },
    -- 大招信息
    SKILL_UNIQUE_INFO = {
        ['恩维丝卡的权能'] = { sel_attack = false,attack_dis = 100 },--魔法师
        ['真迹：泼墨山水'] = { sel_attack = false,attack_dis = 200 },--奶妈
        ['使者芬里尔'] = { sel_attack = false,attack_dis = 300 },    --射手
    },
    -- 技能升级,技能设置到快捷的资源
    SKILL_INFO = {
        ['旋风骤袭'] = { skill_level = 4, fenzhi = { 2 } ,use_idx = 1},
        ['爆裂炽焰'] = { skill_level = 10, fenzhi = { 2, 1, 1 } ,close_use = false,use_idx = 2 },
        ['法力结晶'] = { skill_level = 10, fenzhi = { 3, 1, 2 },use_idx = 3 },
        ['重力反转'] = { skill_level = 10, fenzhi = { 2, 3, 1 },attack_dis = 300,use_idx = 4 },
        ['燎原烈火'] = { skill_level = 4, fenzhi = { 2 },use_idx = 5 },
        ['寒冰箭'] = { skill_level = 10, fenzhi = { 3, 1, 1 } ,sel_attack = true,close_use = false,use_idx = 6 },
        ['末日'] = { skill_level = 10, fenzhi = { 1, 2, 1 },sel_attack = true,close_use = false,use_idx = 7 },
        ['天谴雷罚'] = { skill_level = 10, fenzhi = { 2, 1, 1 } ,sel_attack = true ,close_use = false,use_idx = 8 }, -- close_use = false 停用当前技能

        -- ['极寒召唤'] = { skill_level = 1, fenzhi = { 2, 1, 1 } ,close_use = true },
    },
    -- 快捷栏序号对应的KEY
    SKILL_QUICK = {
        [0] = { key = "KEY_Q" },
        [1] = { key = "KEY_W" },
        [2] = { key = "KEY_E" },
        [3] = { key = "KEY_R" },
        [4] = { key = "KEY_A" },
        [5] = { key = "KEY_S" },
        [6] = { key = "KEY_D" },
        [7] = { key = "KEY_F" },
        [8] = { key = "KEY_RightMouseButton" },
    },
    -- 获得状态后的技能
    STATUS_SKILL = {
        [2] = {
            { name = '激光',cd_time = 2,idx = 0 },
            { name = '净化之光',cd_time = 4,idx = 1 },
        },
        [16] = {
            { name = '突进',cd_time = 2,idx = 0 },
            { name = '跳跃',cd_time = 3,idx = 1 },
            { name = '轰炸',cd_time = 7,idx = 2,sel_attack = true }, --sel_attack = true  标识 技能  需要选择目标后释放
        },
        [64] = {
            { name = '宣布圣域',cd_time = 5 ,idx = 0},
            { name = '光明主宰',cd_time = 5 ,idx = 1},
            { name = '天使保佑',cd_time = 5 ,idx = 2},
        },
    },
}
local this = skill_res

-------------------------------------------------------------------------------------
-- 返回对象
return skill_res

-------------------------------------------------------------------------------------