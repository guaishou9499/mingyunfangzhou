------------------------------------------------------------------------------------
-- game/resources/dungeon_res.lua
--
--
--
-- @module      dungeon_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local dungeon_res = import('game/resources/dungeon_res')
local actor_unit  = actor_unit
local pairs       = pairs
------------------------------------------------------------------------------------
---@class dungeon_res
local dungeon_res = {
    -- 混沌地牢
    CHAOS_INFO = {
        { finish_task = '艾达琳的请求',task_map_id = 11102,min_power = 250,can_do = '贝隆北部的共鸣1阶段' },
        { finish_task = '艾达琳的请求',task_map_id = 11102,min_power = 500,can_do = '贝隆北部的共鸣2阶段' },
        { finish_task = '艾达琳的请求',task_map_id = 11102,min_power = 545,can_do = '贝隆北部的共鸣3阶段' },
        { finish_task = '艾达琳的请求',task_map_id = 11102,min_power = 595,can_do = '贝隆北部的共鸣4阶段' },

        { finish_task = '拉迪切',task_map_id = 10101,min_power = 635,can_do = '洛恒戴尔的幻影1阶段' },
        { finish_task = '拉迪切',task_map_id = 10101,min_power = 680,can_do = '洛恒戴尔的幻影2阶段' },
        { finish_task = '拉迪切',task_map_id = 10101,min_power = 725,can_do = '洛恒戴尔的幻影3阶段' },
        { finish_task = '拉迪切',task_map_id = 10101,min_power = 765,can_do = '洛恒戴尔的幻影4阶段' },

        { finish_task = '伟大的报告',task_map_id = -1,min_power = 805,can_do = '永恩的大地第1阶段' },
        { finish_task = '伟大的报告',task_map_id = -1,min_power = 845,can_do = '永恩的大地第2阶段' },
        { finish_task = '伟大的报告',task_map_id = -1,min_power = 885,can_do = '永恩的大地第3阶段' },
        { finish_task = '伟大的报告',task_map_id = -1,min_power = 925,can_do = '永恩的大地第4阶段' },

        { finish_task = '遗书',task_map_id = -1,min_power = 960,can_do = '费顿的阴影1阶段' },
        { finish_task = '遗书',task_map_id = -1,min_power = 995,can_do = '费顿的阴影2阶段' },
        { finish_task = '遗书',task_map_id = -1,min_power = 1030,can_do = '费顿的阴影3阶段' },
        { finish_task = '遗书',task_map_id = -1,min_power = 1065,can_do = '费顿的阴影4阶段' },

        { finish_task = '庆典与选择',task_map_id = -1,min_power = 1100,can_do = '帕普妮卡之星1阶段' },
        { finish_task = '庆典与选择',task_map_id = -1,min_power = 1295,can_do = '帕普妮卡之星2阶段' },
        { finish_task = '庆典与选择',task_map_id = -1,min_power = 1325,can_do = '帕普妮卡之月1阶段' },
        { finish_task = '庆典与选择',task_map_id = -1,min_power = 1340,can_do = '帕普妮卡之月2阶段' },
        { finish_task = '庆典与选择',task_map_id = -1,min_power = 1355,can_do = '帕普妮卡之月3阶段' },
        { finish_task = '庆典与选择',task_map_id = -1,min_power = 1370,can_do = '帕普妮卡之日1阶段' },
        { finish_task = '庆典与选择',task_map_id = -1,min_power = 1385,can_do = '帕普妮卡之日2阶段' },
        { finish_task = '庆典与选择',task_map_id = -1,min_power = 1400,can_do = '帕普妮卡之日3阶段' },
    },

    -- 星辰讨伐信息
    STARS_INFO = {
        { min_power = 500.0,can_do = '乌尼尔',is_open = true,main_idx = 0,sub_idx = 0,map_id = 30803,boss_name = '乌尼尔',gather_x = 8469,gather_y = 9744 },
        { min_power = 500.0,can_do = '卢莫卢斯',is_open = false,main_idx = 0,sub_idx = 1,map_id = 30802,boss_name = '卢莫卢斯',gather_x = -5830,gather_y = -2193 },
        { min_power = 500.0,can_do = '冰之雷齐奥洛斯',is_open = false,main_idx = 0,sub_idx = 2,map_id = 30801,boss_name = '冰之雷齐奥洛斯',gather_x = 5200,gather_y = 3600 },
        { min_power = 500.0,can_do = '贝尔图斯',is_open = false,main_idx = 0,sub_idx = 3,map_id = 30801,boss_name = '贝尔图斯',gather_x = 5200,gather_y = 3600 },
        { min_power = 635.0,can_do = '克罗马尼姆',is_open = false,main_idx = 1,sub_idx = 0,map_id = 30805,boss_name = '克罗马尼姆',gather_x = 2657,gather_y = 742 },
        { min_power = 635.0,can_do = '纳克拉塞纳',is_open = false,main_idx = 1,sub_idx = 1,map_id = 30805,boss_name = '纳克拉塞纳',gather_x = 2657,gather_y = 742 },

        { min_power = 635.0,can_do = '金焰妖狐',is_open = false,main_idx = 1,sub_idx = 2,map_id = 30804,boss_name = '金焰妖狐',gather_x = 15027,gather_y = 3898 },
        { min_power = 635.0,can_do = '代达罗斯',is_open = false,main_idx = 1,sub_idx = 3,map_id = 0,boss_name = '代达罗斯',gather_x = 5200,gather_y = 3600 },
        { min_power = 805.0,can_do = '暗之雷齐奥洛斯',is_open = false,main_idx = 2,sub_idx = 0,map_id = 0,boss_name = '暗之雷齐奥洛斯',gather_x = 5200,gather_y = 3600 },
        { min_power = 805.0,can_do = '赫尔盖亚',is_open = false,main_idx = 2,sub_idx = 1,map_id = 0,boss_name = '赫尔盖亚',gather_x = 5200,gather_y = 3600 },
        { min_power = 805.0,can_do = '卡尔本图斯',is_open = false,main_idx = 2,sub_idx = 2,map_id = 0,boss_name = '卡尔本图斯',gather_x = 5200,gather_y = 3600 },
        { min_power = 805.0,can_do = '阿卡忒斯',is_open = false,main_idx = 2,sub_idx = 3,map_id = 0,boss_name = '阿卡忒斯',gather_x = 5200,gather_y = 3600 },
        { min_power = 960.0,can_do = '酷寒之赫尔盖亚',is_open = false,main_idx = 3,sub_idx = 0,map_id = 30801,boss_name = '酷寒之赫尔盖亚',gather_x = 5200,gather_y = 3600 },
        { min_power = 960.0,can_do = '熔岩之克罗马尼姆',is_open = false,main_idx = 3,sub_idx = 1,map_id = 0,boss_name = '熔岩之克罗马尼姆',gather_x = 5200,gather_y = 3600 },
        { min_power = 960.0,can_do = '雷巴诺斯',is_open = false,main_idx = 3,sub_idx = 2,map_id = 0,boss_name = '雷巴诺斯',gather_x = 5200,gather_y = 3600 },
        { min_power = 960.0,can_do = '埃尔伯哈斯蒂',is_open = false,main_idx = 3,sub_idx = 3,map_id = 0,boss_name = '埃尔伯哈斯蒂',gather_x = 5200,gather_y = 3600 },
        { min_power = 1270.0,can_do = '重甲之纳克拉塞纳',is_open = true,main_idx = 4,sub_idx = 0,map_id = 30803,boss_name = '重甲之纳克拉塞纳',gather_x = 8469,gather_y = 9744 },
        { min_power = 1250.0,can_do = '伊格莱西翁',is_open = false,main_idx = 4,sub_idx = 1,map_id = 0,boss_name = '伊格莱西翁' },
        { min_power = 1250.0,can_do = '暗夜妖狐',is_open = false,main_idx = 4,sub_idx = 2,map_id = 0,boss_name = '暗夜妖狐' },
        { min_power = 1250.0,can_do = '贝尔加努斯',is_open = false,main_idx = 4,sub_idx = 3,map_id = 0,boss_name = '贝尔加努斯' },
        { min_power = 1415.0,can_do = '德斯卡鲁达',is_open = false,main_idx = 5,sub_idx = 0,map_id = 0,boss_name = '德斯卡鲁达' },
    },

    -- 混沌周常任务列表
    DAILY_QUEST_LIST = {
        '[混沌地牢]突破1阶段以上！（开拓）',
        '[混沌地牢]突破1阶段以上！（繁荣）',
        '[混沌地牢]突破1阶段以上！（成长）'
    },
    -- 星辰周长任务列表
    DAILY_STARS_QUEST_LIST = {
        '[讨伐星辰护卫]收集星辰护卫意志！（发展）',
        '[讨伐星辰护卫]收集星辰护卫意志！（开拓）'
    },
}

-- 自身模块
local this = dungeon_res

-------------------------------------------------------------------------------------
-- [条件] 是否在讨伐星辰地图
dungeon_res.is_in_stars_guard = function()
    local cur_map =  actor_unit.map_id()
    for _,v in pairs(this.STARS_INFO) do
        if v.map_id == cur_map and cur_map ~= 0 then
            return true
        end
    end
    return false
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return dungeon_res

-------------------------------------------------------------------------------------