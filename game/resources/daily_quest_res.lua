------------------------------------------------------------------------------------
-- game/resources/daily_quest_res.lua
--
-- 日常任务资源
--
-- @module      daily_quest_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local daily_quest_res = import('game/resources/daily_quest_res')
------------------------------------------------------------------------------------
---@class daily_quest_res
-- 日常任务资源单元
local daily_quest_res = {
    -- 需要执行的日常
    NEEDS_EXECUTE = {

    },
    -- 每日日常设置
    EVERY_DAY_QUEST = {
        -------------------------------------------------------------------------------------------------
        ['卡丹大殿堂的驱魔仪式'] = { is_open = false,need_finish_task = '',finish_map = -1,idx = 1,power = 0,max_power = 600 },-- 每日日常 [[卢特兰西部]] 3个突破
        ['想抹掉岁月的痕迹'] = { is_open = false,need_finish_task = '',finish_map = -1,idx = 2,power = 0 },                  -- 每日日常  [[托托银发岛]] 3个突破
        ['像风一样快捷'] = { is_open = true,need_finish_task = '',finish_map = -1,idx = 3,power = 0 },                       -- 每日日常  [[海上乐园佩托]] 4个突破
        ['一杯缤纷果汁的悠闲时光'] = { is_open = true,need_finish_task = '',finish_map = -1,idx = 4,power = 0 },              -- 每日日常  [[海上乐园佩托]]  星辰之息
        ['回原来位置'] = { is_open = true,need_finish_task = '',finish_map = -1,idx = 5,power = 500 },                      -- 每日日常 艾尔菲斯 [[休沙尔]] 4个突破

        ['不安的内心'] = { is_open = true,need_finish_task = '',finish_map = -1,idx = 6,power = 0 },                        -- 每日日常 你家在哪儿？ [[安亿谷]] 3个突破
        ['时间静止的狼'] = { is_open = true,need_finish_task = '',finish_map = -1,idx = 7,power = 500 },                    -- 每日日常 艾尔菲斯 [[休沙尔]] 无
        ['冰封的记忆'] = { is_open = true,need_finish_task = '',finish_map = -1,idx = 8,power = 500 },                      -- 每日日常 艾尔菲斯 [[休沙尔]]  星辰之息
        ['度日如年']= { is_open = true,need_finish_task = '',finish_map = -1,idx = 9,power = 250 },                        -- 每日日常 [[海上乐园佩托]]   碎片
        -- 托托克 关乎人生的考试 无
        -- 自由岛  考古学家的请求 星辰之息  XXXXXX
        -- 黑牙驻地  灭虫  4个突破        XXXXXX
    },
}

-- 自身模块
local this = daily_quest_res

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return daily_quest_res

-------------------------------------------------------------------------------------