-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2023-02-14
-- @module:   modules
-- @describe: 模块列表(所有引用模块都从这个模块统一载入)
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
-- 公共模块
_G.common           = import('game/entities/common')
-- 回调模块
_G.call_back        = import('game/entities/callback')
-- 任务特别处理模块
_G.special_task_ent = import('game/entities/special_task_ent')
-------------------------------------------------------------------------------------
-- 功能模块
local module_list = {
   -- 登陆模块
   import('game/modules/login'),
   -- 任务模块
   import('game/modules/quest'),
   -- 副本模块-循环
   import('game/modules/dungeon_cir'),
   -- 副本模块-混沌
   import('game/modules/dungeon'),
   -- 副本模块-星辰
   import('game/modules/dungeon_stars_guard'),
   -- 日常模块
   import('game/modules/daily_quest'),
   -- 岛屿其他任务模块
   import('game/modules/other_task'),
   -- 挂机模块
   import('game/modules/hunt'),
   -- 切换模块
   import('game/modules/switch'),
}

-------------------------------------------------------------------------------------
-- 返回对象
return module_list

-------------------------------------------------------------------------------------