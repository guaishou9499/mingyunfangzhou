------------------------------------------------------------------------------------
-- game/resources/sign_res.lua
--
--
-- 领取物品相关
-- @module      sign_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local sign_res = import('game/resources/sign_res')
------------------------------------------------------------------------------------
local sign_res = {
    -- 方舟通行证领取设置
    ARK_INFO = {
        -- 等级 = { 物品名称 = ''  领取序号 = 0 }
        [1] = { name = '恢复型战斗道具箱子',get_idx = 1 } ,
        [2] = { name = '英雄好感度自选箱子',get_idx = 0 } ,
        [3] = { name = '破坏石结晶袋子',get_idx = 1 } ,
        [4] = { name = '守护石结晶袋子',get_idx = 1 } ,
        [5] = { name = '方舟通行证特殊碎片自选箱子',get_idx = 0 } ,
        [6] = { name = '方舟通行证突破石自选箱子',get_idx = 1 } ,
        [7] = { name = '方舟通行证突破石自选箱子',get_idx = 1 } ,
        [8] = { name = '方舟通行证碎片自选箱子',get_idx = 1 } ,
        [9] = { name = '方舟通行证碎片自选箱子',get_idx = 1 } ,
        [10] = { name = '可尼宠物自选箱子',get_idx = 0 } ,
        [11] = { name = '货币箱子',get_idx = 1 } ,
        [12] = { name = '超大型战斗经验药水',get_idx = 1 } ,
        [13] = { name = '方舟通行证辅助材料自选箱子',get_idx = 1 } ,
        [14] = { name = '方舟通行证辅助材料自选箱子',get_idx = 1 } ,
        [15] = { name = '交易牌',get_idx = 0 } ,
        [16] = { name = '方舟通行证融合材料箱子',get_idx = 1 } ,
        [17] = { name = '方舟通行证融合材料箱子',get_idx = 1 } ,
        [18] = { name = '方舟通行证突破石自选箱子',get_idx = 1 } ,
        [19] = { name = '方舟通行证突破石自选箱子',get_idx = 1 } ,
        [20] = { name = '方舟通行证特殊融合材料箱子',get_idx = 0 } ,
        [21] = { name = '破坏石结晶袋子',get_idx = 1 } ,
        [22] = { name = '守护石结晶袋子',get_idx = 1 } ,
        [23] = { name = '方舟通行证融合材料箱子',get_idx = 1  },
        [24] = { name = '方舟通行证融合材料箱子',get_idx = 1 } ,
        [25] = { name = '方舟通行证特殊突破石自选箱子',get_idx = 0 } ,
        [26] = { name = '全体卡牌包',get_idx = 0 } ,
        [27] = { name = '3级宝石箱子',get_idx = 1 } ,
        [28] = { name = '方舟通行证碎片自选箱子',get_idx = 1 } ,
        [29] = { name = '方舟通行证碎片自选箱子',get_idx = 1 } ,
        [30] = { name = '传说卡牌包',get_idx = 0 } ,
    },
}

-- 自身模块
local this = sign_res

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return sign_res

-------------------------------------------------------------------------------------