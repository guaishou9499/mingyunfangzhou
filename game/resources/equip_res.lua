-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   equip_res
-- @describe: 装备资源
-- @version:  v1.0
-- local equip_res = import('game/resources/equip_res')
-------------------------------------------------------------------------------------
local string = string
local pairs  = pairs
-- 物品资源
---@class equip_res
local equip_res = {
    -- 强化护甲
    -- 1  银币
    -- 2  金币
    -- 6  复活羽毛
    -- 8  裂缝碎片
    -- 10 海略者硬币
    -- 13 和谐碎片
    -- 14 荣誉碎片
    -- 15 交易牌

    -- 武器精炼
    WEAPON_ENHANCE = {
        [3] = {
            [0] = {
                { name = '破坏石结晶', num = 310, type = '材料' },
                { name = '伟大荣誉突破石', num = 10, type = '材料',is_bind = true },
                { name = '荣誉碎片',add_name = {'袋子（大）','袋子（中）'}, num = 200, type = '货币', money_id = 14 },
                { name = '银币', num = 6500, type = '货币', money_id = 1 },

            },
            [1] = {
                { name = '破坏石结晶', num = 310, type = '材料' },
                { name = '伟大荣誉突破石', num = 10, type = '材料',is_bind = true },
                { name = '荣誉碎片',add_name = {'袋子（大）','袋子（中）'}, num = 200, type = '货币', money_id = 14 },
                { name = '银币', num = 9030, type = '货币', money_id = 1 },
            },
            [2] = {
                { name = '破坏石结晶', num = 310, type = '材料' },
                { name = '伟大荣誉突破石', num = 11, type = '材料',is_bind = true },
                { name = '荣誉碎片',add_name = {'袋子（大）','袋子（中）'}, num = 200, type = '货币', money_id = 14 },
                { name = '银币', num = 11560, type = '货币', money_id = 1 },
            },
            [3] = {
                { name = '破坏石结晶', num = 380, type = '材料' },
                { name = '伟大荣誉突破石', num = 11, type = '材料',is_bind = true },
                { name = '荣誉碎片',add_name = {'袋子（大）','袋子（中）'}, num = 200, type = '货币', money_id = 14 },
                { name = '银币', num = 14080, type = '货币', money_id = 1 },
            },
        },
        [2] = {
            [0] = {
                { name = '破坏石碎片', num = 260, type = '材料' },
                { name = '和谐突破石', num = 7, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 150, type = '货币', money_id = 13 },
                { name = '银币', num = 2400, type = '货币', money_id = 1 },
            },
            [1] = {
                { name = '破坏石碎片', num = 280, type = '材料' },
                { name = '和谐突破石', num = 7, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 165, type = '货币', money_id = 13 },
                { name = '银币', num = 2700, type = '货币', money_id = 1 },
            },
            [2] = {
                { name = '破坏石碎片', num = 290, type = '材料' },
                { name = '和谐突破石', num = 7, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 180, type = '货币', money_id = 13 },
                { name = '银币', num = 2900, type = '货币', money_id = 1 },
            },
            [3] = {
                { name = '破坏石碎片', num = 310, type = '材料' },
                { name = '和谐突破石', num = 8, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 195, type = '货币', money_id = 13 },
                { name = '银币', num = 3200, type = '货币', money_id = 1 },
            },
            [4] = {
                { name = '破坏石碎片', num = 330, type = '材料' },
                { name = '和谐突破石', num = 8, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 210, type = '货币', money_id = 13 },
                { name = '银币', num = 3500, type = '货币', money_id = 1 },
            },
            [5] = {
                { name = '破坏石碎片', num = 340, type = '材料' },
                { name = '和谐突破石', num = 8, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 225, type = '货币', money_id = 13 },
                { name = '银币', num = 3800, type = '货币', money_id = 1 },
            },
            [6] = {
                { name = '破坏石碎片', num = 360, type = '材料' },
                { name = '和谐突破石', num = 8, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 240, type = '货币', money_id = 13 },
                { name = '银币', num = 4000, type = '货币', money_id = 1 },
            },
            [7] = {
                { name = '破坏石碎片', num = 380, type = '材料' },
                { name = '和谐突破石', num = 10, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 255, type = '货币', money_id = 13 },
                { name = '银币', num = 4300, type = '货币', money_id = 1 },
            },
            [8] = {
                { name = '破坏石碎片', num = 390, type = '材料' },
                { name = '和谐突破石', num = 10, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 270, type = '货币', money_id = 13 },
                { name = '银币', num = 4600, type = '货币', money_id = 1 },
            },
            [9] = {
                { name = '破坏石碎片', num = 410, type = '材料' },
                { name = '和谐突破石', num = 11, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 285, type = '货币', money_id = 13 },
                { name = '银币', num = 4800, type = '货币', money_id = 1 },
            },
            [10] = {
                { name = '破坏石碎片', num = 420, type = '材料' },
                { name = '和谐突破石', num = 11, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 300, type = '货币', money_id = 13 },
                { name = '银币', num = 5100, type = '货币', money_id = 1 },
            },
            [11] = {
                { name = '破坏石碎片', num = 440, type = '材料' },
                { name = '和谐突破石', num = 12, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 315, type = '货币', money_id = 13 },
                { name = '银币', num = 5400, type = '货币', money_id = 1 },
            },

            [12] = {
                { name = '破坏石碎片', num = 460, type = '材料' },
                { name = '和谐突破石', num = 13, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 330, type = '货币', money_id = 13 },
                { name = '银币', num = 5700, type = '货币', money_id = 1 },
            },
            [13] = {
                { name = '破坏石碎片', num = 470, type = '材料' },
                { name = '和谐突破石', num = 14, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 345, type = '货币', money_id = 13 },
                { name = '银币', num = 5900, type = '货币', money_id = 1 },
            },
            [14] = {
                { name = '破坏石碎片', num = 490, type = '材料' },
                { name = '和谐突破石', num = 15, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 360, type = '货币', money_id = 13 },
                { name = '银币', num = 630, type = '货币', money_id = 1 },
            },

        },
    },

    -- 防具精炼
    ARMOR_ENHANCE = {
        [3] = {
            [0] = {
                { name = '守护石结晶', num = 190, type = '材料' },
                { name = '伟大荣誉突破石', num = 6, type = '材料',is_bind = true },
                { name = '荣誉碎片',add_name = {'袋子（大）','袋子（中）'}, num = 120, type = '货币', money_id = 14 },
                { name = '银币', num = 3900, type = '货币', money_id = 1 },
            },
            [1] = {
                { name = '守护石结晶', num = 190, type = '材料' },
                { name = '伟大荣誉突破石', num = 6, type = '材料',is_bind = true },
                { name = '荣誉碎片',add_name = {'袋子（大）','袋子（中）'}, num = 120, type = '货币', money_id = 14 },
                { name = '银币', num = 5740, type = '货币', money_id = 1 },
            },
            [2] = {
                { name = '守护石结晶', num = 190, type = '材料' },
                { name = '伟大荣誉突破石', num = 7, type = '材料',is_bind = true },
                { name = '荣誉碎片',add_name = {'袋子（大）','袋子（中）'}, num = 120, type = '货币', money_id = 14 },
                { name = '银币', num = 7570, type = '货币', money_id = 1 },
            },
            [3] = {
                { name = '守护石结晶', num = 230, type = '材料' },
                { name = '伟大荣誉突破石', num = 7, type = '材料',is_bind = true },
                { name = '荣誉碎片',add_name = {'袋子（大）','袋子（中）'}, num = 120, type = '货币', money_id = 14 },
                { name = '银币', num = 9410, type = '货币', money_id = 1 },

            },
        },
        [2] = {
            [0] = {
                { name = '守护石碎片', num = 160, type = '材料' },
                { name = '和谐突破石', num = 4, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 90, type = '货币', money_id = 13 },
                { name = '银币', num = 1440, type = '货币', money_id = 1 },
            },
            [1] = {
                { name = '守护石碎片', num = 170, type = '材料' },
                { name = '和谐突破石', num = 4, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 100, type = '货币', money_id = 13 },
                { name = '银币', num = 1600, type = '货币', money_id = 1 },
            },
            [2] = {
                { name = '守护石碎片', num = 175, type = '材料' },
                { name = '和谐突破石', num = 4, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 110, type = '货币', money_id = 13 },
                { name = '银币', num = 1770, type = '货币', money_id = 1 },
            },
            [3] = {
                { name = '守护石碎片', num = 190, type = '材料' },
                { name = '和谐突破石', num = 5, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 120, type = '货币', money_id = 13 },
                { name = '银币', num = 1930, type = '货币', money_id = 1 },
            },
            [4] = {
                { name = '守护石碎片', num = 200, type = '材料' },
                { name = '和谐突破石', num = 5, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 130, type = '货币', money_id = 13 },
                { name = '银币', num = 2090, type = '货币', money_id = 1 },
            },
            [5] = {
                { name = '守护石碎片', num = 205, type = '材料' },
                { name = '和谐突破石', num = 5, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 135, type = '货币', money_id = 13 },
                { name = '银币', num = 2250, type = '货币', money_id = 1 },
            },
            [6] = {
                { name = '守护石碎片', num = 220, type = '材料' },
                { name = '和谐突破石', num = 5, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 145, type = '货币', money_id = 13 },
                { name = '银币', num = 2420, type = '货币', money_id = 1 },
            },
            [7] = {
                { name = '守护石碎片', num = 230, type = '材料' },
                { name = '和谐突破石', num = 6, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 155, type = '货币', money_id = 13 },
                { name = '银币', num = 2580, type = '货币', money_id = 1 },
            },
            [8] = {
                { name = '守护石碎片', num = 235, type = '材料' },
                { name = '和谐突破石', num = 6, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 165, type = '货币', money_id = 13 },
                { name = '银币', num = 2740, type = '货币', money_id = 1 },
            },
            [9] = {
                { name = '守护石碎片', num = 250, type = '材料' },
                { name = '和谐突破石', num = 7, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 175, type = '货币', money_id = 13 },
                { name = '银币', num = 2910, type = '货币', money_id = 1 },
            },
            [10] = {
                { name = '守护石碎片', num = 255, type = '材料' },
                { name = '和谐突破石', num = 7, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 180, type = '货币', money_id = 13 },
                { name = '银币', num = 3070, type = '货币', money_id = 1 },
            },
            [11] = {
                { name = '守护石碎片', num = 265, type = '材料' },
                { name = '和谐突破石', num = 8, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 190, type = '货币', money_id = 13 },
                { name = '银币', num = 3230, type = '货币', money_id = 1 },
            },
            [12] = {
                { name = '守护石碎片', num = 280, type = '材料' },
                { name = '和谐突破石', num = 8, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 200, type = '货币', money_id = 13 },
                { name = '银币', num = 3390, type = '货币', money_id = 1 },
            },
            [13] = {
                { name = '守护石碎片', num = 285, type = '材料' },
                { name = '和谐突破石', num = 9, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 210, type = '货币', money_id = 13 },
                { name = '银币', num = 3560, type = '货币', money_id = 1 },
            },
            [14] = {
                { name = '守护石碎片', num = 295, type = '材料' },
                { name = '和谐突破石', num = 9, type = '材料',is_bind = true },
                { name = '和谐碎片',add_name = {'袋子（大）','袋子（中）'}, num = 220, type = '货币', money_id = 13 },
                { name = '银币', num = 3720, type = '货币', money_id = 1 },
            },
        },
    },
    EQUIP_SHOP = {
        ['莱恩哈特'] = {
            ['武器商人'] = {
                [1] = {
                    active_name = '莱恩哈特',
                    scene_map_name = '艾尔拉拉的装备商店',
                    npc_name = '艾尔拉拉',
                    npc_pos = { x = 7660.0, y = 9688.0, z = -18015.0 },
                    sell_item = {
                        ['光荣狮子肩饰'] = { idx = 11.0, money = 1000.0, name = '光荣狮子肩饰', equip_level = 75, ues_level = 11,pos = 5 },
                    },
                },
            },

        },
        ['国境地带'] = {
            ['武器商人'] = {
                [1] = {
                    active_name = '瑞格里亚圣疗院',
                    npc_name = '舒米特',
                    npc_pos = { x = 12033.0, y = 15150.0, z = 547.88427734375 },
                    sell_item = {
                        ['强悍士兵长法杖'] = { idx = 26.0, money = 1700.0, name = '强悍士兵长法杖', equip_level = 80, ues_level = 14 ,pos = 0 },
                        ['神圣的祝福上装'] = { idx = 11.0, money = 2800.0, name = '神圣的祝福上装', equip_level = 100, ues_level = 16 ,pos = 2 },
                    },
                },
            },
        },
        ['萨兰德丘陵'] = {
            ['武器商人'] = {
                [1] = {
                    active_name = '盐场',
                    npc_name = '威赫姆',
                    npc_pos = { x = 758.0, y = 7176.0, z = 515.53326416016 },
                    sell_item = {
                        ['光佑长法杖'] = { idx = 26.0, money = 3600.0, name = '光佑长法杖', equip_level = 120, ues_level = 0,pos = 0 },
                        ['平静的沙子肩饰'] = { idx = 11.0, money = 3600.0, name = '平静的沙子肩饰', equip_level = 110, ues_level = 18 ,pos = 5 },
                    },
                },
                [2] = {
                    active_name = '流民营地',
                    npc_name = '阿尔明',
                    npc_pos = { x = 19313.0, y = 28479.0, z = 509.0 },
                    sell_item = {
                        ['破碎的沙滩下装'] = { idx = 11.0, money = 3600.0, name = '破碎的沙滩下装', equip_level = 110, ues_level = 18 ,pos = 3 },
                    },
                },


            },
        },
        ['奥兹霍丘陵'] = {
            ['武器商人'] = {
                [1] = {
                    active_name = '奥兹霍集结地',
                    npc_name = '埃杜尔',
                    npc_pos = { x = -150.0, y = 1861.0, z = 511.25305175781 },
                    sell_item = {
                        ['赤色遗迹手套'] = { idx = 11.0, money = 4300.0, name = '赤色遗迹手套',equip_level = 120, ues_level = 20 ,pos = 4 },
                    },
                },
            },
        },
        ['扎格拉斯山'] = {
            ['武器商人'] = {
                [1] = {
                    active_name = '扎格拉斯要塞',
                    npc_name = '瓦尔特',
                    npc_pos = { x = 14552.0, y = 12530.0, z = 2048.0 },
                    sell_item = {
                        ['险峻森林头饰'] = { idx = 11.0, money = 4800.0, name = '险峻森林头饰' ,equip_level = 130, ues_level = 22 ,pos = 1 },
                        ['沙漠之光长法杖'] = { idx = 26.0, money = 5700.0, name = '沙漠之光长法杖' ,equip_level = 140, ues_level = 0 ,pos = 0 },
                    },
                },
            },
        },
        ['雷科巴'] = {
            ['武器商人'] = {
                [1] = {
                    active_name = '雷科巴',
                    npc_name = '休勒克',
                    npc_pos = { x = 12202.0, y = 13153.0, z = 1021.0 },
                    sell_item = {
                        ['平静的湖水上装'] = { idx = 11.0, money = 5100.0, name = '平静的湖水上装' ,equip_level = 130, ues_level = 22 ,pos = 2 },
                    },
                },
            },
        },
        ['激战平原'] = {
            ['武器商人'] = {
                [1] = {
                    active_name = '前方哨所',
                    npc_name = '亨德林',
                    npc_pos = { x = 6207.0, y = 5748.0, z = 2048.0 },
                    sell_item = {
                        ['坚强斗志肩饰'] = { idx = 11.0, money = 6400.0, name = '坚强斗志肩饰',equip_level = 145, ues_level = 25,pos = 5 },
                        ['净化光明长法杖'] = { idx = 26.0, money = 9400.0, name = '净化光明长法杖' ,equip_level = 165, ues_level = 0,pos = 0 },
                    },
                },
            },
        },
        ['梨木之地'] = {
            ['武器商人'] = {
                [1] = {
                    active_name = '马戏团营地',
                    npc_name = '观察者塞任',
                    npc_pos = { x = -1849.0, y = -10412.0, z = 1023.9998779297 },
                    sell_item = {
                        ['东部骑士团下装'] = { idx = 11.0, money = 7400.0, name = '东部骑士团下装' ,equip_level = 170, ues_level = 30 ,pos = 3 },
                    },
                },
            },
        },
        ['伯雷亚领地'] = {
            ['武器商人'] = {
                [1] = {
                    active_name = '伯雷亚城',
                    npc_name = '瓦尔林',
                    npc_pos = { x = -27916.0, y = -15350.0, z = 832.0 },
                    sell_item = {
                        ['伯雷亚骑士团肩饰'] = { idx = 11.0, money = 12000.0, name = '伯雷亚骑士团肩饰' ,equip_level = 185, ues_level = 33 ,pos = 2 },
                        ['播撒祝福长法杖'] = { idx = 26.0, money = 10600.0, name = '播撒祝福长法杖' ,equip_level = 190, ues_level = 0 ,pos = 0 },
                    },
                },
            },
        },
        ['鬃波港'] = {
            ['武器商人'] = {
                [1] = {
                    active_name = '鬃波港',
                    npc_name = '德鲁尼',
                    npc_pos = { x = 5909.0, y = 8867.0, z = 256.0 },
                    sell_item = {
                        ['鬃波骑士团手套'] = { idx = 11.0, money = 13500.0, name = '鬃波骑士团手套' ,equip_level = 205, ues_level = 37,pos = 4 },
                        ['初始光明长法杖'] = { idx = 26.0, money = 18200.0, name = '初始光明长法杖' ,equip_level = 220, ues_level = 0 ,pos = 0 },
                    },
                },
            },
        },
    } ,
    -- 生活工具
    LIFE_INFO = {
        { name = '采集工具',pos = 0 },
        { name = '伐木工具',pos = 1 },
        { name = '采矿工具',pos = 2 },
        { name = '狩猎工具',pos = 3 },
        { name = '钓鱼工具',pos = 4 },
        { name = '考古工具',pos = 5 },
    },
    -- 人物装备位置 名称定义
    BODY_EUQIP = {
        { pos = 0,par = '武器'},
        { pos = 1,par = '头饰'},
        { pos = 2,par = '上装'},
        { pos = 3,par = '下装'},
        { pos = 4,par = '手套'},
        { pos = 5,par = '肩饰'},
        { pos = 6,par = '项链'},
        { pos = 7,par = '耳环'},
        { pos = 8,par = '耳环'},
        { pos = 9,par = '戒指'},
        { pos = 10,par = '戒指'},
        { pos = 11,par = '飞翔之石'},
    },
    -- 定义装备所对应的所需名称
    EQUIP_PAR_INFO = {
        ['武器'] = { '法杖','弓弩' },
        ['头饰'] = { '头饰','帽子','头巾' },
        ['上装'] = { '上装','长袍' },
        ['下装'] = { '下装','裤子' },
        ['手套'] = { '手套','' },
        ['肩饰'] = { '肩饰','肩甲','斗篷' },
        ['项链'] = { '项链','' },
        ['耳环'] = { '耳环','' },
        ['戒指'] = { '戒指','之戒' },
        ['飞翔之石'] = { '飞翔之石','' },
    },
}
local this = equip_res

-------------------------------------------------------------------------------------
-- [读取] 获取指定工具名对应装备位置
equip_res.get_life_pos_by_name = function(name)
    local info = this.LIFE_INFO
    for _,v in pairs(info) do
        if v.name == name or string.find(name,v.name) then
            return v.pos
        end
    end
    return -1
end

------------------------------------------------------------------------------------
-- [读取] 根据装备名称 获取对应指定的部位
equip_res.get_equip_par_by_name = function(equip_name)
    local info = this.EQUIP_PAR_INFO
    for par_name,v in pairs(info) do
        for _,v2 in pairs(v) do
            if v2 and v2 ~= '' and string.find(equip_name,v2) then
                 return par_name
            end
        end
    end
    return '其他'
end

-------------------------------------------------------------------------------------
-- 返回对象
return equip_res

-------------------------------------------------------------------------------------