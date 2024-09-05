-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   util
-- @email:    88888@qq.com 
-- @date:     2021-07-05
-- @module:   example
-- @describe: 杂类函数
-- @version:  v1.0
--

local VERSION = '20210705' -- version history at end of file
local AUTHOR_NOTE = "-[20210705]-"

local util = {  
	VERSION      = VERSION,
	AUTHOR_NOTE  = AUTHOR_NOTE,
}

local this = util

-------------------------------------------------------------------------------------
-- 判断列是否为空
function util:table_is_empty(t)
	local ret_b = false

	if t == nil then 
		ret_b = true
	elseif next(t) == nil then
		ret_b = true
	end

	return ret_b
end

-------------------------------------------------------------------------------------
-- 生成随机字符串
function util:get_random(n)
	if n == nil then
	   n = 8
	end
	local t = {
		"0","1","2","3","4","5","6","7","8","9",
		"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
		"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
	} 
	math.randomseed(os.time())   
	local s = ""
	for i = 1, n do
		s = s .. t[math.random(#t)]        
	end
	
	return s
 end

-------------------------------------------------------------------------------------
-- 生成随机字符串
function util:get_random_ex()
	local t1 = {	--前缀
		"赵","钱","孙","李","周","吴","郑","王","冯","陈","褚","卫","蒋","沈","韩","杨","朱","秦","尤","许",
		"何","吕","施","张","孔","曹","严","华","金","魏","陶","姜","戚","谢","邹","喻","柏","水","窦","章",
		"云","苏","潘","葛","奚","范","彭","郎","鲁","韦","昌","马","苗","凤","花","方","俞","任","袁","柳",
		"酆","鲍","史","唐","费","廉","岑","薛","雷","贺","倪","汤",'绝','公','孙','圣','金','木','水','火',
	}

	local t = {		--后缀
		"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
		"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
		'1','2','3','4','5','6','7','8','9','0'
	}

	local name_num   = math.random(5,8) -- 名字总长度 随机 5-8 个字符
	local q_name_num = math.random(2,5) -- 前缀名称 2 - 5 个字符
	local h_name_num = name_num - q_name_num    -- 后缀名称 总长度 - 前缀占位
	local s1 = ""
	for i = 1, q_name_num do
		s1 = s1 .. t1[math.random(1,#t1)]
	end
	local s = ""
	for i = 1, h_name_num do
		s = s .. t[math.random(1,#t)]
	end
	return s1..s
end

 -------------------------------------------------------------------------------------
-- 实例化新对象

function util.__tostring()
    return "util module"
 end

 util.__index = util

function util:new(args)
   local new = { }

   if args then
      for key, val in pairs(args) do
         new[key] = val
      end
   end

   -- 设置元表
   return setmetatable(new, util)
end

-------------------------------------------------------------------------------------
-- 返回对象
return util:new()

-------------------------------------------------------------------------------------