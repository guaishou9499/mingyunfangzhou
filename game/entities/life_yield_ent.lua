------------------------------------------------------------------------------------
-- game/entities/life_yield_ent.lua
--
-- 实体示例
--
-- @module      life_yield_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local life_yield_ent = import('game/entities/life_yield_ent')
------------------------------------------------------------------------------------
-- 模块定义
---@class life_yield_ent
local life_yield_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION          = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE      = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME      = 'life_yield_ent module',
    -- 只读模式
    READ_ONLY        = false,
    -- 坐标设置生成路径
    POS_PATH         = '方舟:机器[%s]:坐标设置:%s坐标',
    -- 是否本地配置
    IS_LOCAL_INI     = true,
    -- 本地配置时的生成名
    INI_NAME         = '%s坐标.ini',
    -- 连接服务器
    CONNECT_OBJ      = nil,
    -- 需要准备的工具数
    NEED_LIFE_NUM    = 5,
}

-- 实例对象
local this           = life_yield_ent
-- 日志模块
local trace          = trace
-- 决策模块
local decider        = decider
local common         = common
local math           = math
local rawset         = rawset
local os             = os
local tonumber       = tonumber
local pairs          = pairs
local table          = table
local setmetatable   = setmetatable
local string         = string
local local_player   = local_player
local actor_unit     = actor_unit
local skill_unit     = skill_unit
local import         = import
---@type redis_ent
local redis_ent      = import('game/entities/redis_ent')
---@type map_ent
local map_ent        = import('game/entities/map_ent')
---@type actor_ent
local actor_ent      = import('game/entities/actor_ent')
---@type item_ent
local item_ent       = import('game/entities/item_ent')
---@type skill_ent
local skill_ent      = import('game/entities/skill_ent')
---@type vehicle_ent
local vehicle_ent    = import('game/entities/vehicle_ent')
---@type equip_ent
local equip_ent      = import('game/entities/equip_ent')
---@type equip_res
local equip_res      = import('game/resources/equip_res')
---@type life_yield_res
local life_yield_res = import('game/resources/life_yield_res')
---@type shop_ent
local shop_ent       = import('game/entities/shop_ent')
---@type user_set_ent
local user_set_ent   = import('game/entities/user_set_ent')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function life_yield_ent.super_preload()

end

------------------------------------------------------------------------------------
-- [条件] 是否去做生活产出
life_yield_ent.is_can_do_life = function()
    -- 没有开启时
    if user_set_ent['选择采集序号'] == 0
            and user_set_ent['选择采矿序号'] == 0
            and user_set_ent['选择伐木序号'] == 0
            and user_set_ent['选择考古序号'] == 0
            and user_set_ent['选择钓鱼序号'] == 0 then
        return false,'没有开启生活产出'
    end
    -- 生命气息不足时
    if skill_unit.get_life_energy() < 80 then
        return false,'生命气息不足80'
    end

    return true
end

------------------------------------------------------------------------------------
-- [行为] 去指定点做生活产出
life_yield_ent.auto_do_life = function(key,sel_idx)
    -- 获取当前生活类型 目标采集资源
    local life_gather = life_yield_res.get_life_obj(key)
    while decider.is_working() do
        --  当前执行序号
        local cur_idx  = 1
        local data_pos = this.get_life_pos_list(key,sel_idx)
        if not table.is_empty(data_pos) then
            local best_dis = math.huge
            for i = 1,#data_pos do
                local data = data_pos[i]
                -- 相同地图时
                if actor_unit.map_id() == data.map_id then
                    -- 获取距离当前目标点的坐标
                    local cur_dist = local_player:dist_xy(data.x,data.y)
                    if cur_dist < best_dis then
                        best_dis = cur_dist
                        cur_idx  = i
                    end
                end
            end
            -- 设置加血
            local local_use_hp = function()
                item_ent.auto_use_hp_ex(60)
            end
            -- 节点等于最后节点时重置
            if cur_idx == #data_pos then
                cur_idx = 1
            end
            -- 从最近执行点开始执行生活操作
            for i = cur_idx,#data_pos do
                -- 标记保存等待开始时间
                local tab_info = {}
                while decider.is_working() do
                    local w_time    = 1000
                    local data      = data_pos[i]
                    local pos_idx   = data.pos_idx
                    local map_id,x,y,z,r,line,life_lv,time = data.map_id,data.x,data.y,data.z,data.r,data.line,data.life_lv,data.time
                    -- 地图ID转地图名称
                    local map_name  = map_ent.get_map_name_by_map_id(map_id)
                    -- 标记生活技能等级
                    local g_life_lv = life_yield_res.get_life_lv_by_name(key)
                    if g_life_lv > life_lv and life_lv ~= 0 then
                        -- 当前生活技能等级 大于 配置的等级
                        trace.output('技能等级['..key..']大于配置等级')
                        break
                    end
                    --------------------------------------------------------------------------------------------------------
                    -- 获取当前生活目标工具对应位置
                    local g_pos      = equip_res.get_life_pos_by_name(key..'工具')
                    -- 获取最高品质生活工具,工具总数量
                    local info,num   = item_ent.get_max_quality_life_info_by_pos(g_pos,2)
                    -- 获取身上生活工具品质,工具数量
                    local _,body_num = item_ent.get_max_quality_life_info_by_pos(g_pos,1)
                    --------------------------------------------------------------------------------------------------------
                    -- 购买指定生活工具【背包内工具小于指定数量时】
                    if num + body_num < this.NEED_LIFE_NUM then
                        shop_ent.buy_item(nil,'生活工具',key..'工具',this.NEED_LIFE_NUM)
                    end
                    --------------------------------------------------------------------------------------------------------
                    -- 更换指定生活工具【身上工具没有耐久时】
                    if table.is_empty(info) or not table.is_empty(info) and info.durability == 0 then
                        equip_ent.auto_use_life_equip()
                    end
                    --------------------------------------------------------------------------------------------------------
                    -- 修理生活工具【没有可更换的工具,耐久为0时】
                    if table.is_empty(info) then
                        trace.output('没有可用的工具['..key..']')
                        break
                    end
                    if info.durability == 0 then
                        trace.output('工具耐久已耗完['..key..']')
                        break
                    end
                    --------------------------------------------------------------------------------------------------------
                    -- 寻路到指定地图
                    map_ent.move_to_map(map_name)
                    -- 切换线路
                    if line then

                    end
                    -- 检测血量
                    local_use_hp()
                    -- 检测自身100 范围内的是否存在怪物
                    if not map_ent.move_to_kill_actor(nil,100) then
                        -- 获取采集目标,沿路最近
                        local gather_data = this.go_to_do_life(life_gather,local_use_hp,key)
                        if table.is_empty(gather_data) then
                            if local_player:dist_xy(x,y) > 200 then
                                trace.output('移到[POS:'..pos_idx..']')
                                local actor_num = actor_ent.get_actor_num_by_pos(nil,nil,nil,600,2)
                                vehicle_ent.auto_riding_vehicle(actor_num,x,y)
                                if not common.is_move() then
                                    common.auto_move(x,y,z)
                                end
                            else
                                if time == 0 then
                                    break
                                end
                                -- 检测 切换下一坐标,检测是否等待
                                if not tab_info[map_id..pos_idx..line] then
                                    tab_info[map_id..pos_idx..line] = os.time()
                                else
                                    local wait_time = os.time() - tab_info[map_id..pos_idx..line]
                                    if wait_time >= time * 3600 then
                                        tab_info[map_id..pos_idx..line] = false
                                        break
                                    end
                                    trace.output('此点等待：',time * 3600 - wait_time)
                                end
                            end
                        else
                            -- 距离采集点小于200码时检测估计怪物
                            if local_player:dist_xy(gather_data.cx,gather_data.cy) < 200 then
                                -- 检测 600范围内的是否存在怪物
                                local best_info = actor_ent.get_nearest_self_actor_info_by_rad_pos('',gather_data.cx,gather_data.cy,600,2,200)
                                if not table.is_empty(best_info) then
                                    w_time = 100
                                    skill_ent.auto_skill(best_info.cx, best_info.cy, best_info.cz,local_use_hp,best_info.id)
                                end
                            end
                        end
                    else
                        w_time = 100
                    end
                    decider.sleep(w_time)
                end
            end
            trace.output('没有可操作目标')
        else
            trace.output('没有录入坐标')
        end
        decider.sleep(1000)
    end
end

------------------------------------------------------------------------------------
-- [行为] 去指定点做生活产出
-- @tparam can_gather   table      采集  伐木  采矿 可采资源
-- @tparam local_use_hp function   如果为函数 则执行此函数
-- @tparam life_key     生活产出类型 采集  伐木  采矿 钓鱼 考古
life_yield_ent.go_to_do_life = function(can_gather,local_use_hp,life_key)
    if life_key == '钓鱼' then

    else
        -- can_gather = { { name = '',type = 6,res_id = 0 },} -- 所有怪物
        if table.is_empty(can_gather) then
            trace.output('未设置：',life_key,' 目标资源')
        else
            -- 读取自身范围内的目标
            local self_r,s_all_list  = actor_ent.get_actor_info_list_by_rad_pos_and_list(can_gather,local_player:cx(),local_player:cy(),1000)
            if not table.is_empty(self_r) then
                if not self_r.can_gather then
                    for _,v in pairs(s_all_list) do
                        if v.can_gather then
                            self_r = v
                            break
                        end
                    end
                end
                if local_player:dist_xy(self_r.cx,self_r.cy) > 150 then
                    if not common.is_move() then
                        common.auto_move(self_r.cx,self_r.cy,self_r.cz)
                    end
                else
                    if life_key == '考古' then
                        trace.output('考古-',self_r.name)


                    elseif life_key == '狩猎' then
                        trace.output('狩猎-',self_r.name)


                    else
                        trace.output('采-',self_r.name)
                        actor_unit.gather_talk(self_r.obj)

                    end
                    common.wait_over_state(local_use_hp)
                end
                return self_r
            end
        end
    end
    return {}
end

------------------------------------------------------------------------------------
-- [读取] 执行生活获取坐标
-- key:采矿 采集 伐木 钓鱼 考古...
-- sel_idx:对应选择的坐标集序列 采集-1
-- local data = life_yield_ent.get_life_pos_list('植物采集',2)
life_yield_ent.get_life_pos_list = function(key,sel_idx)
    -- 保存坐标数据
    local data      = this.get_cache_life_pos_list(key,sel_idx)
    local num       = #data
    local new_data  = {}
    for i = 1,num do
        -- 取表中pos.坐标
        if not table.is_empty(data[i]) then--
            --  MAP：扎格拉斯山,MID：10811,X：22685,Y：20752,Z：2559,NLV：1,MLV：100,R：100,LINE：1,LV：0,TIME：0
            local map_id,x,y,z,min_lv,max_lv,r,line,life_lv,time = table.unpack(data[i].pos)
            local result  = {
                pos_idx       = data[i].idx,
                -- 获取地图ID
                map_id        = map_id  and tonumber(map_id)   or 0,
                -- 获取坐标x
                x             = x       and tonumber(x)        or 0,
                -- 获取坐标y
                y             = y       and tonumber(y)        or 0,
                -- 获取坐标z
                z             = z       and tonumber(z)        or 0,
                -- 获取范围
                r             = r       and tonumber(r)        or 50,
                -- 获取线路
                line          = line    and tonumber(line)     or 0,
                -- 生活技能最低等级
                life_lv       = life_lv and tonumber(life_lv)  or 0,
                -- 当前点等待时间
                time          = time    and tonumber(time)     or 0,
            }
            table.insert(new_data,result)
        end
    end
    return new_data
end

------------------------------------------------------------------------------------
-- [读取] 获取生活坐标,延迟刷新[默认60 秒]
life_yield_ent.get_cache_life_pos_list = function(key,sel_idx,time_out)
    time_out = time_out or 60
    return common.get_cache_result_ex(key,this.get_pos_all,time_out,key,sel_idx)
end

------------------------------------------------------------------------------------
-- [读取] 读取所有坐标
life_yield_ent.get_pos_all = function(key,sel_idx)
    local num       = 10
    local data      = {}
    local line_path = not this.IS_LOCAL_INI and string.format(this.POS_PATH,redis_ent.computer_id,key) or string.format(this.INI_NAME,key)

    for i = 1,num do
        local value = redis_ent.get_string_redis_ini_ex(line_path,key..'-'..sel_idx,i,this.CONNECT_OBJ,this.IS_LOCAL_INI)
        if value ~= '' then
            local data1 = {}
            data1.idx = i
            data1.pos = this.get_split_pos(value)
            -- 将分割后的坐标保存到DATA
            table.insert(data,data1)
        end
    end
    return data
end

------------------------------------------------------------------------------------
-- [读取] 读取可选坐标列表[根据等级段]
life_yield_ent.get_can_use_pos_data = function(key,sel_idx)
    local level     = local_player:level()
    local data      = this.get_pos_all(key,sel_idx)
    -- 标记生活技能等级
    local g_life_lv = life_yield_res.get_life_lv_by_name(key)
    local can_data = {}
    for i = 1,#data do
        local map_id,x,y,z,min_lv,max_lv,life_lv = table.unpack(data[i].pos)
        if level >= tonumber(min_lv) and level < tonumber(max_lv) and g_life_lv >= tonumber(life_lv) then
            table.insert(can_data,data[i])
        end
    end
    if not table.is_empty(can_data) then
        table.sort(can_data,function(a, b) return a.idx < b.idx end)
    end
    return can_data
end

------------------------------------------------------------------------------------
-- [读取] 分割坐标,返回坐标数据表
life_yield_ent.get_split_pos = function(pos_str)
    local data = {}
    for k in string.gmatch(pos_str,'-?%d+') do
        table.insert(data,k)
    end
    return data
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function life_yield_ent.__tostring()
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
function life_yield_ent.__newindex(t, k, v)
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
life_yield_ent.__index = life_yield_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function life_yield_ent:new(args)
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
    return setmetatable(new, life_yield_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return life_yield_ent:new()

-------------------------------------------------------------------------------------
