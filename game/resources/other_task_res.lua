------------------------------------------------------------------------------------
-- game/resources/other_task_res.lua
--
--
--
-- @module      other_task_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local other_task_res = import('game/resources/other_task_res')
------------------------------------------------------------------------------------
-- 其他需要执行的任务设置 如 岛屿任务 等 暗影岛-白浪岛-金波岛-阿尔泰因 扑扑岛-海上乐园佩托-托托银发岛-睡歌岛-寂静岛-智慧岛 波莫纳岛-利贝海姆-泳装岛-小幸运岛-阿比钮俱乐部-恶徒岛-黄昏岛-希普诺斯之眼-洛恒戴尔 破碎冰河岛，梦幻岛，梦想海鸥岛，蓝风岛
---@class other_task_res
local other_task_res = {
    -- 任务需做数据 此处不设置 如果遇到任务被断 将不执行需要执行的任务
    -- ['分裂的小岛，一个传说'] = { idx = 1, map_id = 50054,need_task = '',need_task_map = 0,need_power = 635 },
    MUST_DO_TASK = {
        -- ['任务名称'] = 地图ID
        -- 白浪岛 没有访客的岛
        ['没有访客的岛'] = { map_id = 50054 },
        ['分裂的小岛，一个传说'] = { map_id = 50054 },

        -- 金波岛
        ['喂！醒醒！'] = { map_id = 50083 },
        ['收集商品'] ={ map_id = 50083 },

        -- 熊猫扑扑岛
        ['香味和鱼'] = { map_id = 50064 },
        ['熊猫喜欢竹子'] = { map_id = 50064 },

        -- 海上乐园佩托
        ['我的人生爱豆'] = { map_id = 50028 },
        ['未来在我们手中'] = { map_id = 50028 },
        ['老人与冰川']  = { map_id = 50028 },

        -- 破碎冰河岛
        ['沉默的序曲']  = { map_id = 50068,need_task = '老人与冰川',need_task_map = -1 },
        ['变革狂想曲']  = { map_id = 50068,need_task = '被污染的海洋',need_task_map = -1 },

        -- 阿尔泰因-斯特恩
        ['扭曲的理想']  = { map_id = 10401,need_task = '沉默的序曲',need_task_map = -1 },
        ['跟踪！寻找独家新闻']  = { map_id = 10401,need_task = '扭曲的理想',need_task_map = -1 },
        ['被污染的海洋']  = { map_id = 10401,need_task = '跟踪！寻找独家新闻',need_task_map = -1,not_read_npc = true,r_map_id = -1 },
        ['放弃会比较自在'] = { map_id = 10401,need_task = '变革狂想曲',need_task_map = -1,not_read_npc = true,r_map_id = -1 },
        ['实现正义'] = { map_id = 10401,need_task = '放弃会比较自在',need_task_map = -1 },

        -- 贫瘠通道
        ['寂静挽歌']  = { map_id = 10421 },

        -- 寂静岛 250
        ['谁在那里？']  = { map_id = 50050,type = 6,need_task = '寂静挽歌',need_task_map = -1 }, -- type 熟悉不为空时 为非NPC可接判断
        ['苦衷']  = { map_id = 50050,need_task = '谁在那里？',need_task_map = 50050 },
        ['强力石']  = { map_id = 50050,need_task = '苦衷',need_task_map = 50050 },
        ['复仇手到擒来'] = { map_id = 50050 },

        -- 睡歌岛 250
        ['妖精歌唱的森林'] = { map_id = 50006 },
        ['听到了你的声音'] = { map_id = 50006 },

        -- ['没关系的，妖精女士'] = { map_id = 50006 },
        -- 智慧岛[暂不开启 涉及时间进入的岛 睡歌岛]
        -- ['永不枯竭的智慧']  = { map_id = 50048,need_task = '复仇手到擒来',need_task_map = 50050 },
        -- ['图书馆内保持肃静']  = { map_id = 50048,need_task = '永不枯竭的智慧',need_task_map = 50048 },


        -- 黑牙驻地 250
        ['黑牙的家'] = { map_id = 50030 },
        ['抓老鼠'] = { map_id = 50030,need_task = '黑牙的家',need_task_map = -1,not_read_npc = true },
        ['散落的利刃和骸骨'] = { map_id = 50030,need_task = '黑牙的家',need_task_map = -1,not_read_npc = true },

        -- 波莫纳岛 250
        ['单身狗的呼喊']  = { map_id = 50040 },
        ['增长的手主人']  = { map_id = 50040 },
        ['闪耀而美丽']  = { map_id = 50040 },
        ['咨询爱情烦恼']  = { map_id = 50040,need_task = '增长的手主人',need_task_map = 50040 },
        ['恋人们的竖琴']  = { map_id = 50040 },

        -- 泳装岛 250
        ['令人不愉快的眼神']  = { map_id = 50020,need_task = '恋人们的竖琴',need_task_map = 50040,type = 6 },
        ['地上天堂']  = { map_id = 50020 },
        ['他们危险的魅力'] = { map_id = 50020 },

        -- 利贝海姆 250
        ['爱情亮绿灯'] = { map_id = 50043,need_task = '令人不愉快的眼神',need_task_map = 50020 },
        ['适合谈恋爱的日子'] = { map_id = 50043 },
        ['玫瑰、蜡烛还有'] = { map_id = 50043 },
        ['痛苦让人变得成熟'] = { map_id = 50043 },

        -- 冰封之海
        ['传说中的恋爱高手'] = { map_id = 10321 },

        -- 黄昏岛 635
        ['黎明的召唤'] = { map_id = 50089,need_power = 635,need_task = '[指引]向导：洛恒戴尔',need_task_map = -1 },
        ['黄昏的阴影'] = { map_id = 50089,need_power = 635 },
        ['黄昏的触摸'] = { map_id = 50089,need_power = 635 },
        ['黄昏之舞'] = { map_id = 50089,need_power = 635 },
        -- ['黄昏之爪'] = { map_id = 50089,need_power = 635 },--- 需要躲避探测 高难度

        -- 梦想海鸥岛 250
        ['前往海鸥岛']  = { map_id = 50067,type = 6 },
        ['罗台，我们一起玩']  = { map_id = 50067 },
        ['与罗台变亲近'] = { map_id = 50067 },
        ['与罗台练习飞行'] = { map_id = 50067 },
        ['罗台的梦'] = { map_id = 50067 },
        ['重回老本行'] = { map_id = 50067,need_task = '没关系的，妖精女士',need_task_map = 50006 }, -- 需要获得 森林小舞曲

        -- 托托银发岛 250
        ['故乡的音乐'] = { map_id = 50003 },
        ['岁月的无情'] = { map_id = 50003 },
        ['托托格的梦：温度'] = { map_id = 50003 },
        ['托托格的梦：香气'] = { map_id = 50003 },
        ['托托格的梦：创造'] = { map_id = 50003 },
        ['托托格的新梦想'] = { map_id = 50003,need_task = '痛苦让人变得成熟',need_task_map = 50043 },

        -- 蓝风岛 805
        ['即将逝去的马'] = { map_id = 50093,need_power = 805 },
        ['蓝风的鬃毛'] = { map_id = 50093,need_power = 805 },
        ['长满花朵的草原'] = { map_id = 50093,need_power = 805 },
        ['草原妖精'] = { map_id = 50093,need_power = 805 },

        -- 卡拉贾村
        ['被埋入黑土地的人'] = { map_id = -1,need_power = 960 },
        ['灰色命运'] = { map_id = -1,need_power = 960 },

        -- 特里希温 [特别任务]
        ['[觉醒]为了寻找新的力量'] = { map_id = -1,need_power = 500,special_task = true },
        ['[觉醒]意外的相遇'] = { map_id = -1,need_power = 500,special_task = true },
        ['[觉醒]可以感受到仙灵的地方'] = { map_id = -1,need_power = 500,special_task = true },
        ['[觉醒]魔法融合'] = { map_id = -1,need_power = 500,special_task = true },
        ['水滴仙灵的诞生'] = { map_id = -1,need_power = 500,special_task = true,need_task = '[觉醒]魔法融合',need_task_map = -1 },
        ['[觉醒]秩序的破坏者'] = { map_id = -1,need_power = 500,special_task = true },
        ['[觉醒]新的希望之光'] = { map_id = -1,need_power = 500,special_task = true },
        ['[觉醒]会继承的希望'] = { map_id = -1,need_power = 500,special_task = true },
    },
    -- 任务接取数据
    ACCEPT_TASK  = {
        -- 黑牙驻地
        ['黑牙的家'] = { { task_name = '黑牙的家',npc_name = '鲁利',npc_res_id = 0x4AB0,quest_id = 0x4CC0D5,map_name = '黑牙驻地',area_name = '',x = -1636, y = -15847, z = -69,kill_dis = 200 },},
        ['抓老鼠'] = { { task_name = '抓老鼠',npc_name = '鲁利',npc_res_id = 0x4AB0,quest_id = 0x4CC0D9,map_name = '黑牙驻地',area_name = '',x = -1633, y = -15852, z = -69,kill_dis = 200,not_read_npc = true,accept_type = 1 },},
        ['散落的利刃和骸骨'] = { { task_name = '散落的利刃和骸骨',npc_name = '鲁利',npc_res_id = 0x4AB0,quest_id = 0x4CC0D6,map_name = '黑牙驻地',area_name = '',x = -1605, y = -15840, z = -71,kill_dis = 200,not_read_npc = true },},
        -- 白浪岛
        ['没有访客的岛']  = { { task_name = '没有访客的岛',npc_name = '漂流少女艾玛',npc_res_id = 0x4B7D,quest_id = 0x4CDC2D,map_name = '白浪岛',area_name = '',x = 1628, y = 1837, z = 26,kill_dis = 200 },},
        ['分裂的小岛，一个传说']  = { { task_name = '分裂的小岛，一个传说',npc_name = '漂流少女艾玛',npc_res_id = 0x4B7D,quest_id = 0x4CDC2E,map_name = '白浪岛',area_name = '',x = 1630, y = 1822, z = 28,kill_dis = 200 },},

        -- 金波岛
        ['喂！醒醒！']  = { { task_name = '喂！醒醒！',npc_name = '故障的特-82',npc_res_id = 0x4D4F,quest_id = 0x4D8FDD,map_name = '金波岛',area_name = '',x = 10124, y = 10501, z = -769,kill_dis = 200 },},
        ['收集商品']  = { { task_name = '收集商品',npc_name = '特-82',npc_res_id = 0x4D50,quest_id = 0x4D8FDE,map_name = '金波岛',area_name = '',x = 10179, y = 10548, z = -766,kill_dis = 200 },},

        -- 熊猫扑扑岛
        ['香味和鱼']  = { { task_name = '香味和鱼',npc_name = '蝠翼毛绒',npc_res_id = 0xC464,quest_id = 0x4D45A6,map_name = '熊猫扑扑岛',area_name = '',x = 3350, y = 11633, z = 90,kill_dis = 200 },},
        ['熊猫喜欢竹子']  = { { task_name = '熊猫喜欢竹子',npc_name = '扑扑',npc_res_id = 0x4D1F,quest_id = 0x4D45A5,map_name = '熊猫扑扑岛',area_name = '',x = 10443, y = 11402, z = 1126,kill_dis = 200 },},

        -- 海上乐园佩托
        ['我的人生爱豆']  = { { task_name = '我的人生爱豆',npc_name = '达尼达尼',npc_res_id = 0x4C2C,quest_id = 0x4CB907,map_name = '海上乐园佩托',area_name = '',x = 31826, y = 4294, z = -170,kill_dis = 200 },},
        ['老人与冰川']  = { { task_name = '老人与冰川',npc_name = '记者马蒂亚斯',npc_res_id = 0x4CAA,quest_id = 0x4D5545,map_name = '海上乐园佩托',area_name = '',x = 32474, y = 2632, z = 83,kill_dis = 200 },},
        ['未来在我们手中']  = { { task_name = '未来在我们手中',npc_name = '竞猜师凯奇',npc_res_id = 0x4BA0,quest_id = 0x4CB908,map_name = '海上乐园佩托',area_name = '',x = 4726, y = 11942, z = 94,kill_dis = 200 },},

        -- 破碎冰河岛
        ['沉默的序曲']  = { { task_name = '沉默的序曲',npc_name = '莎莉',npc_res_id = 0x4CA9,quest_id = 0x4D5546,map_name = '破碎冰河岛',area_name = '',x = 2867, y = 8459, z = 261,kill_dis = 200 },},
        ['变革狂想曲']  = { { task_name = '变革狂想曲',npc_name = '埃尔克',npc_res_id = 0x4CA8,quest_id = 0x4D554A,map_name = '破碎冰河岛',area_name = '',x = 2585, y = 8256, z = 259,kill_dis = 200 },},

        -- 阿尔泰因-斯特恩
        ['扭曲的理想']  = { { task_name = '扭曲的理想',npc_name = '巴斯蒂安',npc_res_id = 0x466E,quest_id = 0x4D5547,map_name = '斯特恩',area_name = '公会堂',x = 10746, y = 48229, z = -12,kill_dis = 200 },},
        ['跟踪！寻找独家新闻']  = { { task_name = '跟踪！寻找独家新闻',npc_name = '局长菲利普·凯曼',npc_res_id = 0x4667,quest_id = 0x4D5548,map_name = '斯特恩',area_name = '诺伊霍泰报社',x = 30610, y = 39536, z = 57,kill_dis = 200 },},
        ['被污染的海洋']  = { { task_name = '被污染的海洋',npc_name = '萨莎',npc_res_id = 0x466F,quest_id = 0x4D5549,map_name = '斯特恩',area_name = '公会堂',x = 10373, y = 48684, z = -12,kill_dis = 200,not_read_npc = true },},
        ['放弃会比较自在']  = { { task_name = '放弃会比较自在',npc_name = '萨莎',npc_res_id = 0x466F,quest_id = 0x4D554B,map_name = '斯特恩',area_name = '公会堂',x = 10410, y = 48736, z = -12,kill_dis = 200,not_read_npc = true },},
        ['实现正义']  = { { task_name = '实现正义',npc_name = '巴斯蒂安',npc_res_id = 0x466E,quest_id = 0x4D554C,map_name = '斯特恩',area_name = '公会堂',x = 10798, y = 48276, z = -12,kill_dis = 200 },},

        -- 贫瘠通道
        ['寂静挽歌']  = { { task_name = '寂静挽歌',npc_name = '记者马蒂亚斯',npc_res_id = 0x4652,quest_id = 0x4D554D,map_name = '贫瘠通道',area_name = '',x = -19858, y = 5361, z = 770,kill_dis = 200 },},

        -- 寂静岛[采集接任务类型]
        ['谁在那里？']  = { { task_name = '谁在那里？',npc_name = '',type = 6,npc_res_id = 0x7B4AF,quest_id = 0x4D0EF5,map_name = '寂静岛',map_id = 50050,area_name = '', x = 9416, y = 2705, z = -82,kill_dis = 200 },},
        ['苦衷']  = { { task_name = '苦衷',npc_name = '传奇铁匠',npc_res_id = 0x4A4C,quest_id = 0x4D0EF6,map_name = '寂静岛',area_name = '',x = 6048, y = 9207, z = -66,kill_dis = 200 },},
        ['强力石']  = { { task_name = '强力石',npc_name = '传奇铁匠',npc_res_id = 0x4A4C,quest_id = 0x4D0EF7,map_name = '寂静岛',area_name = '',x = 6026, y = 9174, z = -66,kill_dis = 200 },},
        ['复仇手到擒来']  = { { task_name = '复仇手到擒来',npc_name = '传奇铁匠',npc_res_id = 0x4A4C,quest_id = 0x4D0EF8,map_name = '寂静岛',area_name = '',x = 5972, y = 9207, z = -63,kill_dis = 200 },},

        -- 智慧岛
        ['永不枯竭的智慧']  = { { task_name = '永不枯竭的智慧',npc_name = '密涅尔瓦',npc_res_id = 0x4A8C,quest_id = 0x4D0726,map_name = '智慧岛',area_name = '',x = 4035, y = 4822, z = -14208,kill_dis = 200 },},
        ['图书馆内保持肃静']  = { { task_name = '图书馆内保持肃静',npc_name = '密涅尔瓦',npc_res_id = 0x4A8C,quest_id = 0x4D0727,map_name = '智慧岛',area_name = '',x = 4150, y = 4865, z = -14208,kill_dis = 200 },},

        -- 波莫纳岛
        ['单身狗的呼喊']  = { { task_name = '单身狗的呼喊',npc_name = '孤独的莱利',npc_res_id = 0x4A97,quest_id = 0x4CE7E5,map_name = '波莫纳岛',area_name = '',x = 3491, y = 11761, z = 676,kill_dis = 200 },},
        ['咨询爱情烦恼']  = { { task_name = '咨询爱情烦恼',npc_name = '阿丽亚娜',npc_res_id = 0xC54E,quest_id = 0x4CE7EA,map_name = '波莫纳岛',area_name = '',x = 4489, y = 10582, z = 680,kill_dis = 200 },},
        ['增长的手主人']  = { { task_name = '增长的手主人',npc_name = '尼纳',npc_res_id = 0x4A9C,quest_id = 0x4CE7E6,map_name = '波莫纳岛',area_name = '',x = 4731, y = 8466, z = 679,kill_dis = 200 },},
        ['恋人们的竖琴']  = { { task_name = '恋人们的竖琴',npc_name = '阿丽亚娜',npc_res_id = 0xC54E,quest_id = 0x4CE7EB,map_name = '波莫纳岛',area_name = '',x = 4477, y = 10588, z = 682,kill_dis = 200 },},
        ['闪耀而美丽']  = { { task_name = '闪耀而美丽',npc_name = '尼纳',npc_res_id = 0x4A9C,quest_id = 0x4CE7E7,map_name = '波莫纳岛',area_name = '',x = 4705, y = 8492, z = 679,kill_dis = 200 },},
        ['适合谈恋爱的日子']  = { { task_name = '适合谈恋爱的日子',npc_name = '坠入爱河的亨利',npc_res_id = 0x4C00,quest_id = 0x4CF39E,map_name = '利贝海姆',area_name = '',x = 7518, y = 8766, z = 336,kill_dis = 200 },},

        -- 泳装岛
        ['令人不愉快的眼神']  = { { task_name = '令人不愉快的眼神',npc_name = '',type = 6,npc_res_id = 0x7A8FB,quest_id = 0x4C99C5,map_name = '泳装岛',map_id = 50020,area_name = '',x = 4379, y = 15815, z = 33,kill_dis = 200 },},
        ['地上天堂']  = { { task_name = '地上天堂',npc_name = '伊比沙',npc_res_id = 0x4D8D,quest_id = 0x4D9B95,map_name = '泳装岛',area_name = '',x = 5798, y = 17794, z = 34,kill_dis = 200 },},
        ['他们危险的魅力']  = { { task_name = '他们危险的魅力',npc_name = '英俊的罗纳德',npc_res_id = 0x4C02,quest_id = 0x4CF39F,map_name = '泳装岛',area_name = '',x = 5226, y = 17513, z = 34,kill_dis = 200 },},

        -- 利贝海姆
        ['爱情亮绿灯']  = { { task_name = '爱情亮绿灯',npc_name = '坠入爱河的亨利',npc_res_id = 0x4C00,quest_id = 0x4CF39D,map_name = '利贝海姆',area_name = '',x = 7497, y = 8758, z = 336,kill_dis = 200 },},
        ['玫瑰、蜡烛还有']  = { { task_name = '玫瑰、蜡烛还有',npc_name = '坠入爱河的亨利',npc_res_id = 0x4C00,quest_id = 0x4CF3A1,map_name = '利贝海姆',area_name = '',x = 7495, y = 8797, z = 333,kill_dis = 200 },},
        ['痛苦让人变得成熟']  = { { task_name = '痛苦让人变得成熟',npc_name = '坠入爱河的亨利',npc_res_id = 0x4C00,quest_id = 0x4CF3A2,map_name = '利贝海姆',area_name = '',x = 7524, y = 8878, z = 338,kill_dis = 200 },},

        -- 冰封之海
        ['传说中的恋爱高手']  = { { task_name = '传说中的恋爱高手',npc_name = '肌肉男马尔科',npc_res_id = 0x4C0A,quest_id = 0x4CF3A0,map_name = '冰封之海',area_name = '',x = -18835, y = 8306, z = -16,kill_dis = 200 },},

        -- 黄昏岛
        ['黎明的召唤'] = { { task_name = '黎明的召唤',npc_name = '修行圣疗师科伦巴',npc_res_id = 0x4E08,quest_id = 0x4DA74D,map_name = '黄昏岛',area_name = '',x = 4953, y = 5000, z = -142,r = 100,kill_dis = 200 },},
        -- ['黎明的召唤'] = { { task_name = '黎明的召唤',npc_name = '修行圣疗师科伦巴',npc_res_id = 0x4E08,quest_id = 0x4DA74D,map_name = '黄昏岛',area_name = '',x = 5010, y = 5074, z = -144,kill_dis = 200 },},
        ['黄昏的阴影'] = { { task_name = '黄昏的阴影',npc_name = '陌生的旅行者',npc_res_id = 0x4E04,quest_id = 0x4DA74E,map_name = '黄昏岛',area_name = '',x = -10216, y = -14312, z = -24441,kill_dis = 200 },},
        ['黄昏的触摸']  = { { task_name = '黄昏的触摸',npc_name = '陌生的旅行者',npc_res_id = 0x4E04,quest_id = 0x4DA74F,map_name = '黄昏岛',area_name = '',x = -10203, y = -14302, z = -24441,kill_dis = 200 },},
        ['黄昏之舞'] = { { task_name = '黄昏之舞',npc_name = '陌生的旅行者',npc_res_id = 0x4E04,quest_id = 0x4DA750,map_name = '黄昏岛',area_name = '',x = -10203, y = -14351, z = -24441,kill_dis = 200 },},
        ['黄昏之爪'] = { { task_name = '黄昏之爪',npc_name = '陌生的旅行者',npc_res_id = 0x4E04,quest_id = 0x4DA751,map_name = '黄昏岛',area_name = '',x = -10211, y = -14367, z = -24441,kill_dis = 200 },},

        -- 梦想海鸥岛
        ['前往海鸥岛']  = { { task_name = '前往海鸥岛',npc_name = '',type = 6,npc_res_id = 0x7BB61,quest_id = 0x4D515D,map_name = '梦想海鸥岛',map_id = 50067,area_name = '',x = 4917, y = 10065, z = -1,kill_dis = 200 },},
        ['罗台，我们一起玩'] = { { task_name = '罗台，我们一起玩',npc_name = '埃托',npc_res_id = 0x4CFC,quest_id = 0x4D515E,map_name = '梦想海鸥岛',area_name = '',x = 5008, y = 6118, z = 2,kill_dis = 200 },},
        ['与罗台变亲近'] = { { task_name = '与罗台变亲近',npc_name = '埃托',npc_res_id = 0x4CFC,quest_id = 0x4D515F,map_name = '梦想海鸥岛',area_name = '',x = 4974, y = 6087, z = 2,kill_dis = 200 },},
        ['与罗台练习飞行'] = { { task_name = '与罗台练习飞行',npc_name = '埃托',npc_res_id = 0x4CFC,quest_id = 0x4D5160,map_name = '梦想海鸥岛',area_name = '',x = 5021, y = 6123, z = 2,kill_dis = 200 },},
        ['罗台的梦'] = { { task_name = '罗台的梦',npc_name = '埃托',npc_res_id = 0x4CFC,quest_id = 0x4D5161,map_name = '梦想海鸥岛',area_name = '',x = 5005, y = 6154, z = 2,kill_dis = 200 },},
        ['重回老本行'] = { { task_name = '重回老本行',npc_name = '埃托',npc_res_id = 0x4CFD,quest_id = 0x4D5162,map_name = '梦想海鸥岛',area_name = '',x = 9135, y = 10869, z = 514,kill_dis = 200 },},

        -- 托托银发岛
        ['故乡的音乐'] = {
             { task_name = '故乡的音乐',npc_name = '托托长老',npc_res_id = 0x4AA8,quest_id = 0x004C5825,map_name = '托托银发岛',area_name = '',x = 6822.0, y = 14440.0, z = 15,kill_dis = 200 },
        },
        ['岁月的无情'] = {
            { task_name = '岁月的无情',npc_name = '托托长老',npc_res_id = 0x4AA8,quest_id = 0x004C5826,map_name = '托托银发岛',area_name = '',x = 6822.0, y = 14440.0, z = 15,kill_dis = 200 },
        },
        ['托托格的梦：温度'] = {
            { task_name = '托托格的梦：温度',npc_name = '托托长老',npc_res_id = 0x4AA8,quest_id = 0x004C575D,map_name = '托托银发岛',area_name = '',x = 6822.0, y = 14440.0, z = 15,kill_dis = 200 },
        },
        ['托托格的梦：香气'] = {
            { task_name = '托托格的梦：香气',npc_name = '托托长老',npc_res_id = 0x4AA8,quest_id = 0x004C575E,map_name = '托托银发岛',area_name = '',x = 6822.0, y = 14440.0, z = 15,kill_dis = 200 },
        },
        ['托托格的梦：创造'] = {
            { task_name = '托托格的梦：创造',npc_name = '托托长老',npc_res_id = 0x4AA8,quest_id = 0x004C575F,map_name = '托托银发岛',area_name = '',x = 6822.0, y = 14440.0, z = 15,kill_dis = 200 },
        },
        ['托托格的新梦想'] = {
            { task_name = '托托格的新梦想',npc_name = '托托长老',npc_res_id = 0x4AA8,quest_id = 0x004C5760,map_name = '托托银发岛',area_name = '',x = 6822.0, y = 14440.0, z = 15,kill_dis = 200 },
        },

        -- 睡歌岛
        ['妖精歌唱的森林'] = { { task_name = '妖精歌唱的森林',npc_name = '旅行者伊柯里斯',npc_res_id = 0x4BDA,quest_id = 0x4C6317,map_name = '睡歌岛',area_name = '',x = 9204, y = 2281, z = 194,kill_dis = 200 },},
        ['听到了你的声音'] = { { task_name = '听到了你的声音',npc_name = '躲藏的妖精',npc_res_id = 0x4BD7,quest_id = 0x4C6315,map_name = '睡歌岛',area_name = '',x = 7764, y = 4750, z = 201,kill_dis = 200 },},
        ['没关系的，妖精女士'] = { { task_name = '没关系的，妖精女士',npc_name = '躲藏的妖精',npc_res_id = 0x4BD8,quest_id = 0x4C6318,map_name = '睡歌岛',area_name = '',x = 4886, y = 5398, z = 230,kill_dis = 200 },},

        -- 暗影岛
        ['前往影之塔']  = { { task_name = '前往影之塔',npc_name = '佣兵队长杰尔丁',npc_res_id = 0x4C8A,quest_id = 0x4C9DB2,map_name = '暗影岛',area_name = '',x = 8761, y = 6901, z = 24,kill_dis = 200 },},

        -- 蓝风岛
        ['即将逝去的马']  = { { task_name = '即将逝去的马',npc_name = '萨那尔',npc_res_id = 0xC550,quest_id = 0x4DB6F1,map_name = '蓝风岛',area_name = '',x = 5273, y = 5989, z = 268,kill_dis = 200 },},
        ['蓝风的鬃毛']  = { { task_name = '蓝风的鬃毛',npc_name = '草原守卫圣疗师',npc_res_id = 0xC556,quest_id = 0x4DB6F2,map_name = '蓝风岛',area_name = '草原守卫的广场',x = 4164, y = 51004, z = 417,kill_dis = 200 },},
        ['长满花朵的草原']  = { { task_name = '长满花朵的草原',npc_name = '摩纳林',npc_res_id = 0xC518,quest_id = 0x4DB6ED,map_name = '蓝风岛',area_name = '',x = 6942, y = 6531, z = 308,kill_dis = 200 },},
        ['草原妖精']  = { { task_name = '草原妖精',npc_name = '阿洛奈',npc_res_id = 0xC51B,quest_id = 0x4DB6EE,map_name = '蓝风岛',area_name = '',x = 14978, y = 12491, z = 665,kill_dis = 200 },},

        -- 卡拉贾村
        ['被埋入黑土地的人'] = { { task_name = '被埋入黑土地的人',npc_name = '卡尔多',npc_res_id = 0xA029,quest_id = 0xDD3A7,map_name = '卡拉贾村',area_name = '阿贝斯塔总部',x = -448, y = -22585, z = 871,kill_dis = 200 },},
        -- 接取模式
        ['灰色命运'] = { { task_name = '灰色命运',npc_name = '卡尔多',npc_res_id = 0xA029,quest_id = 0xDD3A8,map_name = '卡拉贾村',area_name = '阿贝斯塔总部',x = -430, y = -22551, z = 871,kill_dis = 200,accept_type = 1 },},

        -- 特里希温
        ['[觉醒]为了寻找新的力量'] = { { task_name = '[觉醒]为了寻找新的力量',npc_name = '贝拉',npc_res_id = 0x2775,quest_id = 0x44AED1,map_name = '特里希温',area_name = '',x = 11077, y = 105, z = 25,kill_dis = 200 },},
        ['[觉醒]意外的相遇'] = { { task_name = '[觉醒]意外的相遇',npc_name = '普伦司令官列加亚斯',npc_res_id = 0x37A6,quest_id = 0x44AED2,map_name = '拉伊亚阶地',area_name = '',x = -5797, y = -10393, z = 1276,kill_dis = 200 },},
        ['[觉醒]可以感受到仙灵的地方'] = { { task_name = '[觉醒]可以感受到仙灵的地方',npc_name = '魔法师艾得',npc_res_id = 0x59AF,quest_id = 0x44AED3,map_name = '拉伊亚阶地',area_name = '',x = -12387, y = -22390, z = 1772,kill_dis = 200 },},
        ['[觉醒]魔法融合'] = { { task_name = '[觉醒]魔法融合',npc_name = '魔法师赛列尔',npc_res_id = 0x59B0,quest_id = 0x44AED4,map_name = '科罗克尼斯海岸',area_name = '',x = 21374, y = 45476, z = 589,kill_dis = 200 },},
        ['[觉醒]秩序的破坏者'] = { { task_name = '[觉醒]秩序的破坏者',npc_name = '普伦领导者扎西亚',npc_res_id = 0x37A5,quest_id = 0x44AED5,map_name = '拉伊亚阶地',area_name = '',x = -7860, y = -13844, z = 1451,kill_dis = 200,accept_type = 1 },},
        ['水滴仙灵的诞生'] = { { task_name = '水滴仙灵的诞生',npc_name = '普伦领导者扎西亚',npc_res_id = 0x37A5,quest_id = 0xC6FFF,map_name = '拉伊亚阶地',area_name = '',x = -7781, y = -13884, z = 1448,kill_dis = 200,accept_type = 1 },},
        ['[觉醒]新的希望之光'] = {
            { task_name = '[觉醒]新的希望之光',npc_name = '贝拉',npc_res_id = 0x2775,quest_id = 0x44AED9,map_name = '特里希温',area_name = '',x = 11047, y = 98, z = 25,kill_dis = 200 },
            { task_name = '[觉醒]新的希望之光',npc_name = '贝拉',npc_res_id = 0x2775,quest_id = 0x44AED9,map_name = '特里希温',area_name = '',x = 11055, y = 109, z = 27,kill_dis = 200 },
        },
        ['[觉醒]会继承的希望'] = { { task_name = '[觉醒]会继承的希望',npc_name = '贝拉',npc_res_id = 0x2775,quest_id = 0x44B1E7,map_name = '特里希温',area_name = '',x = 11038, y = 110, z = 25,kill_dis = 200 },},

    },
}

-- 自身模块
local this = other_task_res

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return other_task_res

-------------------------------------------------------------------------------------