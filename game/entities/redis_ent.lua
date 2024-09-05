------------------------------------------------------------------------------------
-- 本模块为 redis读写 相关功能操作
--
-- game/entities/redis_ent.lua
--
-- @module      redis_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local redis_ent = import('game/entities/redis_ent')
------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table        = table
local pairs        = pairs
local tonumber     = tonumber
local string       = string
local type         = type
local rawset       = rawset
local os           = os
local json_unit    = json_unit
local main_ctx     = main_ctx
local ini_unit     = ini_unit
local ini_ctx      = ini_ctx
local redis_unit   = redis_unit
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
-- 全局设置
local settings     = settings
local common       = common
local import       = import

-- 模块定义
---@class redis_ent
local redis_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION        = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE    = '2023-03-22 - Initial release',
    -- 模块名称
    MODULE_NAME    = 'redis_ent module',
    -- 只读模式
    READ_ONLY      = false,
}

-- 实例对象
local this         = redis_ent
local configer     = import('base/configer')
------------------------------------------------------------------------------------
--默认机器ID
this.computer_id   = 1
--默认redis对象列表
this.redis_obj     = {
    ['转金服务'] = { connect_obj = nil,connect_ip = '127.0.0.1',port = 6379,open = false },
    ['组队服务'] = { connect_obj = nil,connect_ip = '127.0.0.1',port = 6379,open = false },
}

------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
--
-- @local
------------------------------------------------------------------------------------
redis_ent.super_preload = function()

end

--------------------------------------------------------------------------------
-- 连接redis设置
--
-- @usage
-- local bool = redis_ent.connect_redis()
--------------------------------------------------------------------------------
redis_ent.connect_redis = function()
    --设置/读取本机ID和连接IP
    local computer_id = configer.get_profile('本机设置.ini', '*************连接设置*************', '机器ID')
    if computer_id == '' then
        configer.set_profile('本机设置.ini', '*************连接设置*************', '机器ID', '1')
        this.computer_id = 1
    else
        this.computer_id = tonumber(computer_id)
    end
    -- 遍历连接列表
    for k,v in pairs(this.redis_obj) do
        if v.open then
            local connect_ip = configer.get_profile('本机设置.ini', '*************连接设置*************', k..'连接IP')
            if connect_ip == '' then
                configer.set_profile('本机设置.ini', '*************连接设置*************', k..'连接IP', v.connect_ip)
            else
                this.redis_obj[k].connect_ip = connect_ip
            end
        end
    end
end

--------------------------------------------------------------------------------
-- 连接redis
-- @tparam       string     server_name     设置连接的服务名
--------------------------------------------------------------------------------
redis_ent.connect = function(server_name)
    local obj = this.redis_obj[server_name]
    if obj and obj.open then
        if not obj.connect_obj then
            obj.connect_obj = redis_unit:new()
            if obj.connect_obj:connect(obj.connect_ip, obj.port) then
                trace.log_debug('连接成功-','['..server_name..']-',obj.connect_ip)
            end
            this.redis_obj[server_name] = obj
        end
    end
end

--------------------------------------------------------------------------------
-- 向redis设置指定路径下的数据(string格式)
--
-- @tparam       string     path        路径
-- @tparam       string     session     区块
-- @tparam       string     key         键
-- @tparam       string     value       值
-- @tparam       userdata   obj         对象[暂未使用]
-- @treturn      bool
-- @usage
-- local bool = redis_ent.set_string_redis_ini('路径',区块,键,值)
--------------------------------------------------------------------------------
redis_ent.set_string_redis_ini = function(path, session, key, value, obj)
    if obj then
    
    end
    local str = main_ctx:redis_get_string(path)
    local session_key = key
    if session ~= nil then
        session_key = session .. ':' .. key
    end
    local ini_obj = ini_unit:new()
    local ret = false
    if ini_obj:parse(str) then
        local r = ini_obj:get_string(session_key)
        if r ~= value then
            ini_obj:set_string(session_key, value)
            local new_string = ini_obj:to_string()
            ret = main_ctx:redis_set_string(path, new_string)
        end
    end
    ini_obj:delete()
    return ret
end

--------------------------------------------------------------------------------
-- 向REDIS或本地配置 写入数据
redis_ent.set_string_redis_ini_ex = function(path, session, key, value, obj,is_local_ini)
    if is_local_ini then
        return configer.set_profile(path, session, key, value)
    end
    return this.set_string_redis_ini(path, session, key, value, obj)
end

--------------------------------------------------------------------------------
-- 向redis或者本地ini 获取指定路径下的数据(string格式)
--
-- @tparam       string     path         路径
-- @tparam       string     session      区块
-- @tparam       string     key          键
-- @tparam       userdata   obj          对象[暂未使用]
-- @tparam       bool       is_local_ini 是否写入本地ini
-- @treturn      string
-- @usage
-- local str = redis_ent.get_string_redis_ini('路径','区块','键')
--------------------------------------------------------------------------------
redis_ent.get_string_redis_ini_ex = function(path, session, key, obj,is_local_ini)
    if is_local_ini then
        return configer.get_profile(path, session, key)
    end
    return this.get_string_redis_ini(path, session, key, obj)
end

--------------------------------------------------------------------------------
-- 向redis获取指定路径下的数据(string格式)
--
-- @tparam       string     path        路径
-- @tparam       string     session     区块
-- @tparam       string     key         键
-- @tparam       userdata   obj         对象[暂未使用]
-- @treturn      string
-- @usage
-- local str = redis_ent.get_string_redis_ini('路径','区块','键')
--------------------------------------------------------------------------------
redis_ent.get_string_redis_ini = function(path, session, key, obj)
    if obj then
    
    end
    local str = main_ctx:redis_get_string(path)
    local session_key = key
    if session ~= nil then
        session_key = session .. ':' .. key
    end
    local ini_obj = ini_unit:new()
    local str_r = ''
    if ini_obj:parse(str) then
        str_r = ini_obj:get_string(session_key)
    end
    ini_obj:delete()
    return str_r
end

--------------------------------------------------------------------------------
-- 向redis获取指定路径下的数据(json格式)
--
-- @tparam       string     path    路径
-- @tparam       userdata   obj     对象[暂未使用]
-- @treturn      table
-- @usage
-- local table = redis_ent.get_json_redis_by_path('路径', 对象)
--------------------------------------------------------------------------------
redis_ent.get_json_redis_by_path = function(path, obj)
    local ret = {}
    local json_text = main_ctx:redis_get_string(path)
    if obj then
        json_text = '??????????'
    end
    if json_text == 'null' or json_text == '' then
        return {}
    end
    if string.len(json_text) > 0 then
        ret = json_unit.decode(json_text)
    end
    return ret
end

--------------------------------------------------------------------------------
-- 向redis设置指定路径下的数据(json格式)
--
-- @tparam       string     path    路径
-- @tparam       table      data    写入数据
-- @tparam       userdata   obj     对象[暂未使用]
-- @treturn      table
-- @usage
-- local table = redis_ent.set_json_redis_by_path_and_data('路径',写入数据,对象)
--------------------------------------------------------------------------------
redis_ent.set_json_redis_by_path_and_data = function(path, data, obj)
    if path == nil or path == '' then
        return {}
    end
    if obj then
    
    end
    local nowRead = main_ctx:redis_get_string(path)
    if data == '' then
        if nowRead ~= 'null' then
            local xx = main_ctx:redis_set_string(path, 'null')
        end
        return {}
    end
    local json_text = json_unit.encode(data)
    if string.len(json_text) > 0 then
        local xx = main_ctx:redis_set_string(path, json_text)
        return xx
    end
    return false
end

--------------------------------------------------------------------------------
-- 向redis指定路径下的数据增加或修改
--
-- @tparam       string     path     路径
-- @tparam       table      data     写入数据
-- @tparam       userdata   obj      对象[暂未使用]
-- @treturn      bool
-- @usage
-- local bool = redis_ent.update_data_to_redis('路径',写入数据)
--------------------------------------------------------------------------------
redis_ent.update_data_to_redis = function(path, data,obj)
    local data_r = ''
    -- 标记是否更新
    local is_update = true
    if type(data) == 'table' then
        data_r = data
        local data2 = this.get_json_redis_by_path(path,obj)
        if not table.is_empty(data2) then
            for key, val in pairs(data2) do
                local setVal = val
                for key1, val1 in pairs(data) do
                    if key == key1 then
                        is_update = val ~= val1 or false
                        setVal = val1
                        break
                    end
                end
                data_r[key] = setVal
            end
        end
    end
    return is_update and this.set_json_redis_by_path_and_data(path, data_r,obj) or false
end

-------------------------------------------------------------------------------------
-- [写入] 向指定路径下写入表 返回新增后的总数据[路径下的表需与t相同]
-- @tparam       string     path    路径
-- @tparam       table      t       写入的表
-- @treturn      table              更新后的表
-------------------------------------------------------------------------------------
redis_ent.set_table = function(path,t,obj)
    local is_update = false
    local data      = this.get_json_redis_by_path(path,obj)
    for k,v in pairs(t) do
        if type(k) ~= 'number' then
            local val = v
            local old = false
            for k1,v1 in pairs(data) do
                if k == k1 then
                    val = v1
                    old = true
                    break
                end
            end
            data[k]   = val
            if not old then
                is_update = true
            end
        else
            local is_insert = true
            for k1,v1 in pairs(data) do
                if v1 == v then
                    is_insert = false
                    break
                end
            end
            if is_insert then
                table.insert(data,v)
                is_update = true
            end
        end
    end
    if is_update then
        this.set_json_redis_by_path(path,data,obj)
    end
    return data
end

-------------------------------------------------------------------------------------
-- [读取] 在redis路径下 对应键值对应下 table的可写序号[单table操作]
--
-- @tparam       any        args        指定key下需要配对的参数
-- @tparam       string     key         json中的字段key
-- @tparam       string     path        路径
-- @tparam       number     max_line    可写最大数据量[表][默认60]
-- @tparam       number     time_out    超时时间[默认600秒]
-- @tparam       userdata   obj         其他连接对象[为nil时G控制台设置的IP]
-- @treturn      number     idx         在表中的序号
-- @treturn      table      data        当前路径下的表
-- @treturn      string     path        路径
-------------------------------------------------------------------------------------
redis_ent.get_idx_and_data_in_table_by_key_and_path = function(args,key,path,max_line,time_out,obj)
    local data = this.get_json_redis_by_path(path,obj)
    local idx  = 0
    max_line   = max_line or 60
    time_out   = time_out or 600
    -- 移除超时
    for i = #data,1,-1 do
        if not table.is_empty(data[i]) then
            if  data[i].time and os.time() - data[i].time > time_out or data[i].day and data[i].day ~= os.date('%m%d')  then
                table.remove(data,i)
            end
        end
    end
    -- 配对键值
    for k,v in pairs(data) do
        if v[key] == args then
            idx = k
            break
        end
    end
    -- 当前记录 不能超过50条
    if idx == 0 then
        if #data >= max_line then
            return -1,data,path
        end
    end
    return idx,data,path
end

------------------------------------------------------------------------------------
-- 向redis路径， 键值对应 配对table 内 写入数据 table[单table操作]
--
-- @tparam       any        data_w      需要写入的数据
-- @tparam       any        args        指定key下需要配对的参数
-- @tparam       string     key         json中的字段key
-- @tparam       string     path        路径
-- @tparam       number     max_line    可写最大数据量[表]
-- @tparam       number     time_out    超时时间[默认600秒]
-- @tparam       userdata   obj         其他连接对象[为nil时G控制台设置的IP]
------------------------------------------------------------------------------------
redis_ent.set_data_in_table = function(data_w,args,key,path,max_line,time_out,obj)
    local idx,data = this.get_idx_and_data_in_table_by_key_and_path(args,key,path,max_line,time_out,obj)
    if idx == 0 then
        table.insert(data,data_w)
    elseif idx > 0 then
        local data1  = data[idx]
        for k,v in pairs(data_w) do
            data1[k] = v
        end
        data[idx]    = data1
    end
    if not table.is_empty(data) then
        this.set_json_redis_by_path_and_data(path,data,obj)
        return true
    end
    return false
end

------------------------------------------------------------------------------------
-- 清除指定路径下的节点的数据[单table操作]
--
-- @tparam       any        args        指定key下需要配对的参数
-- @tparam       string     key         json中的字段key
-- @tparam       string     path        路径
-- @tparam       userdata   obj         其他连接对象[为nil时G控制台设置的IP]
------------------------------------------------------------------------------------
redis_ent.clear_data_in_table = function(args,key,path,obj)
    local idx,data = this.get_idx_and_data_in_table_by_key_and_path(args,key,path,obj)
    if idx > 0 and not table.is_empty(data) then
        table.remove(data,idx)
        this.set_json_redis_by_path_and_data(path,data,obj)
    end
end

-------------------------------------------------------------------------------------------------------------
-- 获取指定redis路径下可写位置,可扩展路径序号[对应路径下多个序号组成]
--
-- @tparam       any        key_args         指定key下需要配对的参数
-- @tparam       string     key_name         json中的字段key
-- @tparam       string     path             路径
-- @tparam       number     time_out         超时时间[默认600秒]
-- @tparam       number     max_t            可写批次[默认 10]
-- @tparam       number     max_data         当前批次可写最大[默认 40]
-- @tparam       userdata   obj              其他连接对象[为nil时G控制台设置的IP]
-- @treturn      number     idx              在表中的序号
-- @treturn      number     idx2             当前表的批次
-- @treturn      table      ret_data         当前路径批次下的表
-- @treturn      bool       is_exist         返回是否存在数据
-------------------------------------------------------------------------------------------------------------
redis_ent.get_idx_in_redis_table_list_path = function(key_args,key_name,path,time_out,max_t,max_data,obj)
    local name     = key_args
    -- 当前与角色名配对的key名
    key_name       = key_name or 'name'
    -- 当前路径下最大可设的路径数
    max_t          = max_t or 10
    -- 超时的时间
    time_out       = time_out or 600
    -- json中最大可写数
    max_data       = max_data or 40
    -- 保存当前redis路径下序号
    local idx      = 0
    -- 保存当前redis路径序号内表的序号
    local idx2     = 0
    -- 是否存在数据
    local is_exist = false
    -- 返回当前路径下数据
    local data     = {}
    local ret_data = {}
    local f_idx    = 0
    local f_idx2   = 0
    local f_data   = {}
    -- 遍历获取所有数据
    for i = 1,max_t do
        local path = path..i
        local data1 = this.get_json_redis_by_path(path,obj)
        table.insert(data,data1)
    end
    -- 配对数据,销毁过期数据
    for i = 1,#data do
        local data1 = data[i]
        -- 移除超时
        for j = #data1,1,-1 do
            if not table.is_empty(data1[j]) then
                if  data1[j].time and os.time() - data1[j].time > time_out
                        or data1[j].day and data1[j].day ~= os.date('%m%d')  then
                    table.remove(data1,j)
                end
            end
        end
        -- 配对名称
        for k,v in pairs(data1) do
            if v[key_name] == name then
                if idx == 0 then
                    idx      = i
                    idx2     = k
                    is_exist = true
                else
                    table.remove(data1,k)
                end
            end
        end
        -- 保存自身数据
        if idx ~= 0 and table.is_empty(ret_data) then
            ret_data = data1
        end
        if f_idx2 == 0 and f_idx == 0 then
            if #data1 < max_data then
                f_idx = i
                f_data= data1
            end
        end
    end
    if f_idx ~= 0 and idx == 0 then
        idx  = f_idx
        idx2 = 0
        ret_data = f_data
    end
    return idx,idx2,ret_data,is_exist
end

-------------------------------------------------------------------------------------------------------------
-- 向指定路径下写入表 可扩展路径序号[对应路径下多个序号组成]
--
-- @tparam       any        data_w           需要写入的数据
-- @tparam       any        key_args         指定key下需要配对的参数
-- @tparam       string     key_name         json中的字段key
-- @tparam       string     path             路径
-- @tparam       number     time_out         超时时间[默认600秒]
-- @tparam       number     max_t            可写批次[默认 10]
-- @tparam       number     max_data         当前批次可写最大[默认 40]
-- @tparam       userdata   obj              其他连接对象[为nil时G控制台设置的IP]
-------------------------------------------------------------------------------------------------------------
redis_ent.set_data_in_redis_table_list_path = function(data_w,key_args,key_name,path,time_out,max_t,max_data,obj)
    local idx,idx2,data  = this.get_idx_in_redis_table_list_path(key_args,key_name,path,time_out,max_t,max_data,obj)
    if idx ~= 0 then
        if idx2 == 0 then
            table.insert(data,data_w)
        elseif idx2 > 0 then
            local data1  = data[idx2]
            for k,v in pairs(data_w) do
                data1[k] = v
            end
            data[idx2]   = data1
        end
        if not table.is_empty(data) then
            this.set_json_redis_by_path_and_data(path..idx,data,obj)
        end
    end
end

-------------------------------------------------------------------------------------------------------------
-- 清除数据
-- @tparam       any        key_args         指定key下需要配对的参数
-- @tparam       string     key_name         json中的字段key
-- @tparam       string     path             路径
-- @tparam       number     time_out         超时时间[默认600秒]
-- @tparam       number     max_t            可写批次[默认 10]
-- @tparam       number     max_data         当前批次可写最大[默认 40]
-- @tparam       userdata   obj              其他连接对象[为nil时G控制台设置的IP]
-------------------------------------------------------------------------------------------------------------
redis_ent.clear_data_in_table_list = function(key_args,key_name,path,time_out,max_t,max_data,obj)
    local idx,idx2,data,is_exist = this.get_idx_in_redis_table_list_path(key_args,key_name,path,time_out,max_t,max_data,obj)
    if idx ~= 0 and is_exist then
        if idx2 > 0 then
            table.remove(data,idx2)
            this.set_json_redis_by_path_and_data(path..idx,data,obj)
        end
    end
end

-------------------------------------------------------------------------------------------------------------
-- 获取指定redis路径下可写位置,可扩展路径序号[队伍,队员,名字,name,path,队伍最大记录数,队员最大数,超时,可生成最大列表数]
--
-- @tparam       string     session          当前表中的块节点
-- @tparam       string     key              当前表中的块节点下的节点
-- @tparam       any        key_args         当前表中的块节点下的节点指定key下需要配对的参数
-- @tparam       string     key_name         json中的字段key
-- @tparam       string     path             路径
-- @tparam       number     session_num      最大块数[默认10]
-- @tparam       number     key_num          块下最大字段[默认10]
-- @tparam       number     time_out         超时时间[默认600秒]
-- @tparam       number     max_t            可写批次[默认 10]
-- @tparam       userdata   obj              其他连接对象[为nil时G控制台设置的IP]
-- @treturn      number     path_idx         当前路径下的批次序号
-- @treturn      number     session_idx      当前块的序号
-- @treturn      number     key_idx          当前字段的序号
-- @treturn      table      ret_data         当前路径下的所有数据
-- @treturn      bool       is_exist         记录是否存在
-------------------------------------------------------------------------------------------------------------
redis_ent.get_idx_in_redis_table_list_path_session_key = function(session,key,key_args,key_name,path,session_num,key_num,time_out,max_t,obj)
    local name         = key_args
    -- 当前与角色名配对的key名
    key_name           = key_name or 'name'
    -- 当前路径下最大可设的路径数
    max_t              = max_t or 10
    -- 超时的时间
    time_out           = time_out or 600
    -- 当前表可写总序号
    session_num        = session_num or 10
    -- 最底层表可写总数
    key_num            = key_num or 10
    -- 保存当前redis路径下序号
    local path_idx     = 0
    -- 保存当前redis路径序号内session的序号
    local session_idx  = 0
    -- 保存当前redis路径序号内key的序号
    local key_idx      = 0
    -- 保存自身数据
    local ret_data     = {}
    -- 返回当前路径下数据
    local data         = {}
    -- 保存是否存在自身记录
    local is_exist     = false
    -- 保存可选最佳位置
    local f_path_idx   = 0
    local f_session_idx= 0
    local f_key_idx    = 0
    local f_ret_data   = {}
    -- 遍历获取所有数据
    for i = 1,max_t do
        local path = path..i
        local data1 = this.get_json_redis_by_path(path,obj)
        table.insert(data,data1)
    end
    -- 遍历配对,销毁过期数据
    for i = 1,#data do
        local data1 = data[i]
        for j = 1,session_num do
            local data2 = data1[session..'-'..j]
            if not table.is_empty(data2) then
                for k = 1,key_num do
                    local v = data2[key..k]
                    if not table.is_empty(v) then
                        -- 配对指定KEY
                        if v[key_name] == name then
                            if path_idx == 0 then
                                path_idx    = i
                                session_idx = j
                                key_idx     = k
                                is_exist    = true
                                break
                            else
                                -- 清除重复的数据
                                data1[session..'-'..j][key..k] = nil
                            end
                        end
                        -- 清除超时记录
                        if path_idx ~= 0 then
                            if  v.time and os.time() - v.time > time_out
                                    or v.day and v.day ~= os.date('%m%d')  then
                                data1[session..'-'..j][key..k] = nil
                            end
                        end
                    end
                end
            end
        end
        data[i] = data1
        if path_idx ~= 0 and table.is_empty(ret_data) then
            ret_data = data1
        end
    end
    -- 获取一个可选位置
    if path_idx == 0 then
        for i = 1,#data do
            local data1 = data[i]
            for j = 1,session_num do
                local data2 = data1[session..'-'..j]
                if not table.is_empty(data2) then
                    for k = 1,key_num do
                        if table.is_empty(data2[key..k]) then
                            path_idx    = i
                            session_idx = j
                            key_idx     = k
                            ret_data    = data1
                            break
                        end
                    end
                else
                    if f_path_idx == 0 then
                        f_path_idx    = i
                        f_session_idx = j
                        f_key_idx     = 1
                        f_ret_data    = data1
                    end
                end
                if path_idx ~= 0 then break end
            end
            if path_idx ~= 0 then ret_data = data1 break end
        end
    end
    if path_idx == 0 and f_path_idx ~= 0 then
        path_idx    = f_path_idx
        session_idx = f_session_idx
        key_idx     = f_key_idx
        ret_data    = f_ret_data
    end
    return path_idx,session_idx,key_idx,ret_data,is_exist
end

-------------------------------------------------------------------------------------------------------------
-- 向指定路径下写入表 可扩展路径序号
--
-- @tparam       any        data_w           需要写入的数据
-- @tparam       string     session          当前表中的块节点
-- @tparam       string     key              当前表中的块节点下的节点
-- @tparam       any        key_args         当前表中的块节点下的节点指定key下需要配对的参数
-- @tparam       string     key_name         json中的字段key
-- @tparam       string     path             路径
-- @tparam       number     session_num      最大块数[默认10]
-- @tparam       number     key_num          块下最大字段[默认10]
-- @tparam       number     time_out         超时时间[默认600秒]
-- @tparam       number     max_t            可写批次[默认 10]
-- @tparam       userdata   obj              其他连接对象[为nil时G控制台设置的IP]
-------------------------------------------------------------------------------------------------------------
redis_ent.set_data_in_redis_table_list_path_session_key = function(data_w,session,key,key_args,key_name,path,session_num,key_num,time_out,max_t,obj)
    local path_idx,session_idx,key_idx,data  = this.get_idx_in_redis_table_list_path_session_key(session,key,key_args,key_name,path,session_num,key_num,time_out,max_t,obj)
    if path_idx ~= 0 then
        local session_key = session..'-'..session_idx
        if not data[session_key] then
            data[session_key] = {}
        end
        if not data[session_key][key..key_idx] then
            data[session_key][key..key_idx] = {}
        end
        local data1  = data[session_key][key..key_idx]
        for k,v in pairs(data_w) do
            data1[k] = v
        end
        data[session_key][key..key_idx]   = data1
        if not table.is_empty(data) then
            this.set_json_redis_by_path_and_data(path..path_idx,data,obj)
        end
    end
end

-------------------------------------------------------------------------------------------------------------
-- 清除指定路径下的记录
--
-- @tparam       string     session          当前表中的块节点
-- @tparam       string     key              当前表中的块节点下的节点
-- @tparam       any        key_args         当前表中的块节点下的节点指定key下需要配对的参数
-- @tparam       string     key_name         json中的字段key
-- @tparam       string     path             路径
-- @tparam       number     session_num      最大块数[默认10]
-- @tparam       number     key_num          块下最大字段[默认10]
-- @tparam       number     time_out         超时时间[默认600秒]
-- @tparam       number     max_t            可写批次[默认 10]
-- @tparam       userdata   obj              其他连接对象[为nil时G控制台设置的IP]
-------------------------------------------------------------------------------------------------------------
redis_ent.clear_data_in_table_list_path_session_key = function(session,key,key_args,key_name,path,session_num,key_num,time_out,max_t,obj)
    local path_idx,session_idx,key_idx,data,is_exist  = this.get_idx_in_redis_table_list_path_session_key(session,key,key_args,key_name,path,session_num,key_num,time_out,max_t,obj)
    if path_idx ~= 0 and is_exist then
        data = this.get_json_redis_by_path(path..path_idx,obj)
        if data[session..session_idx] then
            if data[session..session_idx][key..key_idx] then
                data[session..session_idx][key..key_idx] = nil
                this.set_json_redis_by_path_and_data(path..path_idx,data,obj)
            end
        end
    end
end

------------------------------------------------------------------------------------
-- [内部] 防止动态修改(this.READ_ONLY值控制)
--
-- @local
-- @tparam       table     t                被修改的表
-- @tparam       any       k                要修改的键
-- @tparam       any       v                要修改的值
------------------------------------------------------------------------------------
redis_ent.__newindex = function(t, k, v)
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
redis_ent.__index = redis_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function redis_ent:new(args)
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
    return setmetatable(new, redis_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return redis_ent:new()

-------------------------------------------------------------------------------------