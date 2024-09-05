------------------------------------------------------------------------------------
-- game/resources/user_set_res.lua
--
--
--
-- @module      user_set_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local user_set_res = import('game/resources/user_set_res')
------------------------------------------------------------------------------------
-- 用户设置资源
local user_set_res = {
    GLOBAL_SET = {
        { session = '*************主线设置*************', key = '开启主线', value = 1 },
        { session = '*************主线设置*************', key = '角色数量', value = 1 },
        { session = '*************主线设置*************', key = '主角序号', value = 2 },
        { session = '*************主线设置*************', key = '开启支线', value = 0 },
        { session = '*************主线设置*************', key = '全部角色执主线', value = 0 },
        { session = '*************主线设置*************', key = '轮刷周任务出金', value = 1 },

        { session = '*************副本设置*************', key = '开启混沌地牢', value = 1 },
        { session = '*************副本设置*************', key = '开启讨伐星辰', value = 1 },
        { session = '*************副本设置*************', key = '阿吉罗斯之尾', value = 0 },
        { session = '*************副本设置*************', key = '苏醒的魔兽', value = 0 },
        { session = '*************副本设置*************', key = '赤之结界', value = 0 },
        { session = '*************副本设置*************', key = '燕之结界', value = 0 },
        { session = '*************副本设置*************', key = '咒灵洞穴', value = 0 },
        { session = '*************副本设置*************', key = '海掠者巢穴', value = 0 },
        { session = '*************副本设置*************', key = '萨维拉洞穴', value = 0 },
        { session = '*************副本设置*************', key = '光辉山脊', value = 0 },
        { session = '*************副本设置*************', key = '灰锤矿山', value = 0 },
        --
        { session = '*************挂机设置*************', key = '野外挂机', value = 0 },
        { session = '*************挂机设置*************', key = '挂机时长', value = 11 },
        { session = '*************挂机设置*************', key = '休息间隔', value = 0.5 },
        { session = '*************挂机设置*************', key = '休息时长', value = 0.1 },
        { session = '*************挂机设置*************', key = '选择坐标', value = 1 },

        { session = '*************日常设置*************', key = '每日可做次数', value = 3 },

        { session = '*************切换设置*************', key = '完成切换下线', value = 0 },
        { session = '*************切换设置*************', key = '指定登录序号', value = 0 },

        { session = '*************生活设置*************', key = '选择采集序号', value = 0 },
        { session = '*************生活设置*************', key = '选择采矿序号', value = 0 },
        { session = '*************生活设置*************', key = '选择伐木序号', value = 0 },
        { session = '*************生活设置*************', key = '选择钓鱼序号', value = 0 },
        { session = '*************生活设置*************', key = '选择考古序号', value = 0 },

        { session = '*************邮寄设置*************', key = '收件人', value = '收件人' },
        { session = '*************邮寄设置*************', key = '邮件标题', value = 'nothing' },
        { session = '*************邮寄设置*************', key = '邮件内容', value = 'nothing' },
        { session = '*************邮寄设置*************', key = '邮寄类型', value = 0 },
        { session = '*************邮寄设置*************', key = '邮寄物品', value = '物品1,物品2' },
        { session = '*************邮寄设置*************', key = '触发邮寄金币数', value = 1000 },
        { session = '*************邮寄设置*************', key = '邮寄保留金币数', value = 20 },
        { session = '*************邮寄设置*************', key = '单次邮寄金限额', value = 0 },

        { session = '*************交易行设置*************', key = '开启上架', value = 1 },

    }
}

-- 自身模块
local this = user_set_res

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return user_set_res

-------------------------------------------------------------------------------------