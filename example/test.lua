-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   core
-- @email:    88888@qq.com 
-- @date:     2022-08-10
-- @module:   test
-- @describe: 示例代码模块
-- @version:  v1.0
--

local VERSION = '20220810' -- version history at end of file
local AUTHOR_NOTE = "-[20220810]-"

local test = {  
	VERSION      = VERSION,
	AUTHOR_NOTE  = AUTHOR_NOTE,
}

local this = test
local config_client = import('base/config')
local actor = import('game/actor')
local skill = import('game/skill')

test.test = function()
    hook_unit.enable_mouse_screen_pos(true)
    while not is_terminated() do
        xxmsg(123)
        local actor_info = actor.get_actor_info(1000)
        xxmsg(456)
        if not table_is_empty(actor_info) then 
            skill.auto_skill(actor_info.cx, actor_info.cy, actor_info.cz)
        end
        xxmsg("over")
        sleep(1000)
    end
    hook_unit.enable_mouse_screen_pos(false)
end


-------------------------------------------------------------------------------------
-- 实例化新对象
function test.__tostring()
    return "lostark test package"
 end

 test.__index = test

function test:new(args)
   local new = { }

   if args then
      for key, val in pairs(args) do
         new[key] = val
      end
   end

   -- 设置元表
   return setmetatable(new, test)
end

-------------------------------------------------------------------------------------
-- 返回对象
return test:new()

-------------------------------------------------------------------------------------