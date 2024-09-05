------------------------------------------------------------------------------------
-- game/entities/test_ent.lua
--
-- 实体示例
--
-- @module      test_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local test_ent = import('game/entities/test_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class test_ent
local test_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE             = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME             = 'test_ent module',
    -- 只读模式
    READ_ONLY               = false,
}

-- 实例对象
local this         = test_ent
local setmetatable = setmetatable
local pairs        = pairs
local type         = type
local string       = string
local table        = table
local rawset       = rawset
local test_res     = import('game/resources/test_res')

local test_info    = test_res.test_info

------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function test_ent.super_preload()

end

----------------------------------------------------------------------------------------
-- 测试单元输出【行为】
function test_ent.test_mail_unit()
    -- 达到执行条件  执行动作函数   检测动作是否成功执行
    -- 打开交易UI：UI是否打开【条件 手动开启 或 命令开启】 执行打开交易行【行为函数】 成功标记【输出需要的结果.数量变化，铜钱变化等】
    -- 上架：上架前打开UI【条件 交易行是否打开】 执行上架【行为函数】 成功标记【输出需要的结果.数量变化，铜钱变化等】
    -- 查询：查询前打开UI【条件 交易行是否打开】 执行查询【行为函数】 成功标记【输出需要的结果】
    -- 下架：下架前打开UI【条件 交易行是否打开】 执行下架【行为函数】 成功标记【输出需要的结果，指定物增加】
    local action = {
        ['自定义动作名'] = {
            -- 执行条件
            pre_condition = {
                ['执行开关'] = false,
                ['执行条件'] = {
                    -- 需要手动操作的条件 则放在一个循环体

                    -- 无需手动操作的条件 则直接执行
                    {

                    },
                },
            },

            -- 执行功能函数
            execute      = {
                ['函数对象'] = mail_unit,   -- 函数对象名称  函数指针名
                ['函数名称'] = 'send_mail', -- 函数对象下的函数名称 string
                -- 1.存在固定的参数
                ['所需参数'] = { 'girl', '标题','类容',0,5,0,{ 0,1 } },
                -- 2.非固定的参数[不存在固定参数时触发]
                ['动态参数'] = {
                    { func = nil,param = {} },-- 函数指针,参数,每个返回值为单个参数
                },
            },

            -- 检测是否成功
            compare = {
                -- 条件的组合
                {
                    -- 结束成功的标记 存在单个条件  或 多个条件
                    ['函数对象'] = item_unit, -- 函数对象名称  函数指针名
                    ['函数名称'] = 'get_money_byid', -- 函数对象下的函数名称 string
                    ['所需参数'] = { 1 },  -- 函数所需要的参数,当前函数下所需参数
                    ['目标比值'] = nil,    -- 成功所要达到的比值
                    --
                },
            },
        },
    }
end

---------------------------------------------------------------------------------------------------------
-- 测试单元输出【读取】
test_ent.show_unit_info_list = function()
    for unit_name,v in pairs(test_info) do
        xxmsg('---------------------------------------------------------------------------------------------------------')
        xxmsg('                              ['..unit_name..'单元]                                                    ')
        xxmsg('---------------------------------------------------------------------------------------------------------')
        for tig_name,info in pairs(v) do
            -- 属性特定标记配对
            local filed_suited = info.filed_suited
            -- 这是一个函数,读取单元列表数据
            local unit_list    = info.unit_list(info.type)
            -- 获取匹配属性
            local suited       = info.suited
            -- 函数命令配对
            local func         = info.func
            -- 配对数据最小数
            local unit_min_num = info.unit_min_num or 1
            xxmsg('['..tig_name..']：属性           目标值          实际值            结果')
            if #unit_list < unit_min_num then
                -- 输出数据不足 当前 函数可能存在异常
                xxxmsg(3,string.format(":%-15s    %-15s     %-15s    %-15s",unit_name..'.list',unit_min_num,#unit_list,'异常'))
            end
            -- 额外分支字段[此字段属某一属性数量下对应的其他输出]
            local other_suited = info.other_suited
            -- 标记是否成功配对数据
            local suited_succ  = false
            -- 标记是否所有实例失败
            local init_error   = true
            -- init实例的方法名,默认init,需要指定可设置名  如：init_raid....
            local init         = info.init or 'init'
            -- 遍历需要配对输出的属性
            for filed_name,value in pairs(suited) do
                for _,obj in pairs(unit_list) do
                    -- 实例对象是否获取
                    local init_status = info.unit_ctx[init](info.unit_ctx,obj)
                    if init_status then
                        -- 正常实例对象
                        init_error = false
                        -- 首次标记目标属性 与 值的配对
                        local is_suited_succ = false
                        -- 遍历需要匹配的属性【属性特定标记配对】
                        for filed_suited_name,value1 in pairs( filed_suited ) do
                            if info.unit_ctx[filed_suited_name](info.unit_ctx) == value1 then
                                is_suited_succ = true
                                break
                            end
                        end
                        -- 配对成功,输出需要输出的字段
                        if is_suited_succ then
                            suited_succ = true
                            local filed_value = info.unit_ctx[filed_name](info.unit_ctx)
                            -- 配对成功,输出结果
                            if value == filed_value then
                                xxxmsg(2,string.format(":%-15s    %-15s     %-15s    %-15s",filed_name,value,filed_value,'成功'))
                            else
                                xxxmsg(4,string.format(":%-15s    %-15s     %-15s    %-15s",filed_name,value,filed_value,'失败'))
                            end
                            -- 其他分支对应下的配对
                            if not table.is_empty(other_suited) then
                                local special = other_suited.special
                                -- 配对分支的数据
                                for _,name in pairs(special) do
                                    if name == filed_name then
                                        local r_value = info.unit_ctx[filed_name](info.unit_ctx)
                                        if type(r_value) == 'number' then
                                            for i = 0,r_value - 1 do
                                                local suited2 = other_suited.suited
                                                if not table.is_empty(suited2) then
                                                    for s_name,s_value in pairs(suited2) do
                                                        local _value = info.unit_ctx[s_name](info.unit_ctx,i)
                                                        if _value == s_value then
                                                            xxxmsg(2,string.format(":%-15s    %-15s     %-15s    %-15s",s_name,s_value,_value,'成功'))
                                                        else
                                                            xxxmsg(4,string.format(":%-15s    %-15s     %-15s    %-15s",s_name,s_value,_value,'失败'))
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            -- 输出函数命令的配对
            if type(func) == 'table'and not table.is_empty(func) then
                for _,value in pairs(func) do
                    if type(value.func) == 'function' then
                        -- 获取函数名
                        local s_name    = value.name or this.get_func_name(value.func)
                        -- 获取实际值
                        local get_value = value.func(table.unpack(value.param))
                        -- 配对数据
                        if get_value == value.value then
                            xxxmsg(2,string.format(":%-15s    %-15s     %-15s    %-15s",s_name,value.value,get_value,'成功'))
                        else
                            xxxmsg(4,string.format(":%-15s    %-15s     %-15s    %-15s",s_name,value.value,get_value,'失败'))
                        end
                    end
                end
            end
            -- 实例失败 输出消息
            if init_error then
                xxxmsg(4,':'..init..'()                              输出：异常')
            end
            if not suited_succ then
                for filed_suited_name,value in pairs( filed_suited ) do
                    xxxmsg(3,':'..filed_suited_name..'               需配对的数据【'..value..'】不存在')
                end
            end
        end
    end
    xxmsg('-------------------------------------------------------------------------------------------------------------')
end

------------------------------------------------------------------------------------
-- 获取指定函数对象对应函数名称
test_ent.get_func_name = function(func)
    for k,v in pairs(_G) do
        if type(v) == "function" and v == func then
            return k
        end
    end
    return nil
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function test_ent.__tostring()
    return this.MODULE_NAME
end

------------------------------------------------------------------------------------
-- [内部] 防止动态修改(this.READ_ONLY值控制)
--
-- @local
-- @tparam       table     t                被修改的表
-- @tparam       any       k                要修改的键
-- @tparam       any       v                要修改的值
------------------------------------------------------------------------------------
function test_ent.__newindex(t, k, v)
    if this.READ_ONLY then
        error('attempt to modify read-only table')
        return
    end
    rawset(t, k, v)
end

------------------------------------------------------------------------------------
-- [内部] 设置item的__index元方法指向自身
--
-- @local
------------------------------------------------------------------------------------
test_ent.__index = test_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function test_ent:new(args)
    local new = {}
    -- 预载函数(重载脚本时)
    if this.super_preload then
        this.super_preload()
    end
    -- 将args中的键值对复制到新实例中
    if args then
        for key, val in pairs(args) do
            new[key] = val
        end
    end
    -- 设置元表
    return setmetatable(new, test_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return test_ent:new()

-------------------------------------------------------------------------------------
