------------------------------------------------------------------------------------
-- game/resources/actor_res.lua
--
--
--
-- @module      actor_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local actor_res = import('game/resources/actor_res')
------------------------------------------------------------------------------------
local actor_unit = actor_unit
local actor_res  = {
    -- 过滤不攻击的对象
    FILTER_MONSTER = {
        '火魔军团','创造之蛋','花兔','仇影','托托格','3管锯齿炮塔','移动的锯齿刃炮塔','白兵检查用途怪物','白后检查专用怪物','木桶配重','皮纳塔' --'陆下人技术员的残影','陆下人矿工的残影','陆下人士兵的残影'
    },
    -- 路障缆删[移动时攻击的目标]
    PALISADE_MON = {
        { name = '',type = 2,res_id = 0 } ,     -- 所有怪物
        { name = '',type = 7,res_id = 0x4F0E }, -- 障碍物
        { name = '',type = 7,res_id = 0x4F0F }, -- 障碍物
        { name = '',type = 7,res_id = 0x13AF7 },-- 障碍物
        { name = '',type = 7,res_id = 0x13CE0 },-- 障碍物
        { name = '',type = 7,res_id = 0x138E5 },-- 障碍物
        { name = '',type = 7,res_id = 0x138E6 },-- 障碍物
        { name = '',type = 7,res_id = 0x1ADD0 },-- 障碍物

    },
    -- 不需过滤类型7的对象RES_ID【类型7的 状态判断无效时使用】
    NOT_FILTER_TYPE_7 = {
        0x50EE,0x520C,0x5281,0x50DF,
        0x13AF6,0x142B1,0x142B0,0x1443A,
        0x1444B,0x14502,0x1ADB5,0x1AFB9,
        0x11702,0x117BF,0xBFFD,0xC005,
        0xC00D,0xC015,0xC015,0x1B465,
        0x1B464,0x1B202,0x1B2D1,0x1B217,0x1B218,0x1B219,
        0x1B2F9,0x1B3B8,0x7A5A,0x7A59,0X1BBD0,0x1C85E,0x7BA26,
        0x1BCCA, 0x1C2F9, 0x1C8A8, 0x1C8B0,0x1BD00,0x1C2E7,0x1C8AA,
        0x1C8AD,0x1C8AE,0x1C8AF,0x1ABD3,0x7AB8 ,0x11691,0xEC37,0xEC38,0xEC39,0xEC3A,0xEC3B
    },
    -- type_seven_status = 1 才读取的目标资源对象
    CAN_READ_TYPE_SEVEN = {
        [0x1AA9B] = true
    },
    -- is_valid 为 true 才攻击的对象资源ID
    CAN_KILL_VALID = {
        0xC022,0xC021,0x1B464,0x11691,0xEC37,0xEC38,0xEC39,0xEC3A,0xEC3B,0x5281,0x50DF,0x1ABD3
    },
    -- 可正常攻击 命令却返回异常false的 怪物名称
    CAN_ATT_ERROR_M = {
        '愤怒骑士幽灵'
    },
    -- 需要按键H的对象名称
    NEED_CALL_H = {
        ['巨型蠕虫'] = true,
        ['修赫里特'] = true,
        ['巴尔坦'] = true,
        ['红色男爵艾迪'] = true
    },
    -- 获取可攻击的最低血量的怪物
    HP_MONSTER = {
        ['科学家杰伊'] = 300,
        ['科学家艾斯'] = 300,
    },
    -- 需要增加高度的怪物
    NEED_ADD_KILL_H = {
        ['指挥官索尔'] = 500,
        [0x1C7F8] = 500,
    },
    -- 移动时需要独立设置攻击距离的地图【移动时攻击怪物或者障碍物体】
    NEED_MOVE_KILL = {
        ['卢特兰王陵'] = { search_dis = 800,attack_dis = 650 },
        ['托托克体内'] = { search_dis = 800,attack_dis = 650 },
        ['满月古宅'] = { search_dis = 500,attack_dis = 500 },
        ['艾伯利亚古遗迹'] = { search_dis = 700,attack_dis = 650 },
    },
    -- 需要使用觉醒技能攻击怪物
    NEED_UNIQUE_SKILL = {
        ['叛变的纳克逊'] = true,
        ['梦幻军团骑士'] = true,
        ['梦幻军团王后'] = true,
        ['阿布莱修德'] = true,
        ['迷宫守卫'] = true,
        ['沼泽怪物'] = true,
        ['佩德里克'] = true,
        ['塞克利亚高阶圣疗师'] = true,
        ['被混沌蚕食的泽佩托'] = true,
        ['混沌塞卡'] = true,
        ['灵魂收获者詹迪克'] = true,
        ['衰落的塔加图斯'] = true,
        ['纳瓒'] = true,
        ['尼格拉斯'] = true,
        ['魅惑指挥官奇兹拉'] = true,
        ['蠕虫头部'] = true,
        ['黑暗军团阿玛乌斯'] = true,
        ['太阳核控制魔像'] = true,
        ['贝克鲁泽'] = true,
        ['萨尔顿'] = true,
        ['阿盖伦'] = true,
        ['灾祸军团长伊利亚坎'] = true,
        ['阿尔比恩'] = true,
    },
    -- 需要原地复活的地图【有些地图需要原地时使用 默然 2 】
    NEED_RISE_M = {
        ['黑玫瑰圣疗殿堂'] = true,
        ['圣疗殿堂地下'] = true,
        ['克拉提尔之心'] = true,
        ['艾尔盖茨'] = true,
        ['托托克体内'] = true,
        ['艾希曼研究所'] = true,
        ['卢特兰王陵'] = true,
        ['艾伯利亚古遗迹'] = true,
        ['陆下人浮雕'] = true,
        ['灰色记忆铁武坊'] = true,
        ['傲慢方舟'] = true,
        ['黑雨平原'] = true,
        ['绝妙的制造厂'] = true,
        ['伊娜斯峭壁'] = true,
        ['娜斯卡温泉'] = true,
        ['奥莱赫井'] = true,
        ['暗影圣疗院'] = true,
        ['废墟古城'] = true,
        ['梦幻宫殿'] = true,
    },
    -- 复活完成后无需等待的地图
    NOT_WAIT_TIME_M = {
        ['混沌地牢'] = true,
    },
    -- 打怪距离的配置【有些怪物需要缩短距离】
    NEED_SET_DIS = {
        ['愤怒骑士幽灵'] = 350
    },
    -- 打怪时点击鼠标移动的怪物
    NEED_MOUSE_M = {
        ['兹尔甘'] = true,
        [0x50F0] = true,
        ['蠕虫头部'] = true,
    },
    -- 采集类型的定义
    GATHER_TYPE = {
        6,8
    },
    -- 可获得特殊状态的道具[]
    NEED_STATUS  = {
        { name = '凯尔皮温',res_id = 0,type = 13,get_status = 16 }, -- 战马
        { name = '',res_id = 0x13886,type = 9,get_status = 2 }, -- 灯笼
        { name = '',res_id = 0x100217,type = 13,get_status = 16 }, -- 机甲
        { name = '重装行者',res_id = 0,type = 13,get_status = 16 }, -- 机甲
    },
    -- 宝箱信息
    CHEST_INFO   = {
        { res_id = 0x138A0,type = 6,type_seven_status = 1 },
        { res_id = 0xEC86,type = 6,type_seven_status = 1 },
        { res_id = 0x2F58,type = 6,type_seven_status = 1 },
        { res_id = 0x1BC87,type = 6,type_seven_status = 1 },
        { name   = '继承星辰护卫意志',type = 6,type_seven_status = 1 },
        { name   = '金块',type = 4,type_seven_status = 1 },
        { res_id = 0x1ACAA,type = 6,type_seven_status = 1 },
        { res_id = 0x8016,type = 6,type_seven_status = 1 },
    },

}

-- 自身模块
local this = actor_res

-------------------------------------------------------------------------------------
-- [条件]是否需要按H的对象
actor_res.need_key_h = function(name)
    return this.NEED_CALL_H[name]
end

-------------------------------------------------------------------------------------
-- [读取] 获取需要增加击杀的高度
actor_res.get_need_add_kill_h = function(name,res_id)
    return this.NEED_ADD_KILL_H[name] or this.NEED_ADD_KILL_H[res_id] or 0
end

-------------------------------------------------------------------------------------
-- [条件]是否需要复活的地图
actor_res.need_stay_rise = function()
    local map_name = actor_unit.map_name()
    return this.NEED_RISE_M[map_name]
end

-------------------------------------------------------------------------------------
-- [条件]复活完无需等待的地图
actor_res.not_wait_time_m = function()
    local map_name = actor_unit.map_name()
    return this.NOT_WAIT_TIME_M[map_name]
end
-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return actor_res

-------------------------------------------------------------------------------------