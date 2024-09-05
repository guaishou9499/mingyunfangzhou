------------------------------------------------------------------------------------
-- game/resources/test_res.lua
--
--
--
-- @module      测试单元模块
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local test_res = import('game/resources/test_res')
------------------------------------------------------------------------------------
-- 测试单元模块
local test_res = {
    -- 测试读取单元
    test_info = {
        -- 读取类 对应的模块---- 目标信息 配对是否准确[属性单元必须配对字段]
        ['actor_unit'] = {
            -- type:对应的读取类型  suited：配对数据   func：需要额外执行的函数
            ['角色'] = {
                -- 对应单元的读取类型[可选参数]
                type         = 1,
                -- init实例的方法名,默认init,需要指定可设置名  如：init_raid....
                init         = nil,
                -- 属性特定标记配对[通过当前需要配对的值才能检测 suited]
                filed_suited = { name = '神一样的小嗨', },
                -- 配对字段
                suited       = { name = '神一样的小嗨',res_id = 205 },
                -- 需要额外执行的函数
                func         = { { func = actor_unit.map_id,value = 11314,param = {  },name = 'map_id' }, },--
                -- 配对数据最小数
                unit_min_num = 1,
                -- 当前单元的列表信息
                unit_list    = actor_unit.list,
                -- 当前单元的数据结构
                unit_ctx     = actor_ctx,
            },

        },
        ['quest_unit'] = {
            -- type:对应的读取类型  suited：配对数据   func：需要额外执行的函数
            ['当前任务'] = {
                -- 对应单元的读取类型[可选参数,实际单元类型区分中的引用]
                type         = 0,
                -- init实例的方法名,默认init,需要指定可设置名  如：init_raid....
                init         = nil,
                -- 属性特定标记配对[通过当前需要配对的值才能检测 suited]
                filed_suited = { name = '寻找方舟', },
                -- 配对字段[需要配对输出的数据]
                suited       = { name = '寻找方舟',branch_num = 2,map_name = '特里希温',id = 0x0044AA21,idx = 1,status = 0 },
                -- 额外分支字段[此字段属某一属性数量下对应的其他输出]
                other_suited = {
                    -- 分支读取操作[当前分支属性  对应  数量]
                    special  = { 'branch_num' },
                    -- 当前分支下需要读取的属性
                    suited   = {
                        branch_name     = '<FONT color=\'#FF973A\'>寻找</FONT>方舟',
                        tar_type        = 23,
                        cur_tar_num     = 5,
                        cur_tar_max_num = 7,
                        target_status   = 1
                    },
                },
                -- 需要额外执行的函数
                func         = nil,
                -- 配对数据最小数
                unit_min_num = 1,
                -- 当前单元的列表信息
                unit_list    = quest_unit.list,
                -- 当前单元的数据结构
                unit_ctx     = quest_ctx,
            },

        },

        -- 行为类 对应的模块---- 目标信息


    }
}

-- 自身模块
local this = test_res

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return test_res

-------------------------------------------------------------------------------------