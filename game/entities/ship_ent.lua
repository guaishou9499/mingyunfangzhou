------------------------------------------------------------------------------------
-- game/entities/ship_ent.lua
--
-- 实体示例
--
-- @module      ship_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local ship_ent = import('game/entities/ship_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class ship_ent
local ship_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE             = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME             = 'ship_ent module',
    -- 只读模式
    READ_ONLY               = false,
}

-- 实例对象
local this         = ship_ent
-- 日志模块
local trace        = trace
local common       = common
-- 决策模块
local decider      = decider
local setmetatable = setmetatable
local pairs        = pairs
local rawset       = rawset
local ipairs       = ipairs
local table        = table
local import       = import
local ship_ctx     = ship_ctx
local ship_unit    = ship_unit
local ship_res     = import('game/resources/ship_res')
---@type ui_ent
local ui_ent       = import('game/entities/ui_ent')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function ship_ent.super_preload()

end

------------------------------------------------------------------------------------
-- [行为] 修理船
ship_ent.require_ship = function()
    if common.is_sleep_any('检测修理船',15) then
        xxmsg('船耐：'..ship_unit.get_cur_ship_durable()..' '..ship_unit.get_cur_ship_max_durable())
        if ship_unit.get_cur_ship_durable() < ship_unit.get_cur_ship_max_durable() then
            -- 关闭前置UI
            ui_ent.close_ui()
            if not ship_unit.is_open_anchor_frame() then
                common.key_call('KEY_Z')
                decider.sleep(2000)
            end
            if ship_unit.is_open_anchor_frame() then
                trace.output('修理船只')
                ui_ent.repair_ship()
                -- ship_unit.repair_cur_ship()
                decider.sleep(2000)
            end
        end
    end
end

------------------------------------------------------------------------------------
-- [行为] 选择指定船
ship_ent.sel_ship_by_name = function(name)
    local info    = this.get_ship_info_by_any(name,'name')
    if table.is_empty(info) then
        info = this.get_all_ship_info()
        if not table.is_empty(info) then
            info = info[1]
        end
    end
    if not table.is_empty(info) and not info.is_select then
        if not ship_unit.is_open_anchor_frame() then
            common.key_call('KEY_Z')
            decider.sleep(2000)
        end
        if ship_unit.is_open_anchor_frame() then
            trace.output('选择船：',info.name)
            ship_unit.select_ship(info.id)
            decider.sleep(2000)
        end
    end
    this.sel_ship_in_crew()
end

------------------------------------------------------------------------------------
-- [行为] 选择船员
ship_ent.sel_ship_in_crew = function(sel_name)
    -- 标记已选船员数
    local ok_sel_n  = 0
    -- 获取船员信息
    local crew_info = this.get_all_ship_crew()
    -- 标记是否卸载船员
    local up_crew   = sel_name and true or false
    -- 检测指定船员是否已配置
    for _,v in pairs(crew_info) do
        if v.sel_ship_idx ~= -1 then
            if v.name == sel_name then
                -- 指定船员已选择
                up_crew = false
            end
            ok_sel_n = ok_sel_n + 1
        end
    end
    -- 检测是否卸载船员
    if up_crew then
        if not ship_unit.is_open_anchor_frame() then
            common.key_call('KEY_Z')
            decider.sleep(2000)
        end
        for _,v in pairs(crew_info) do
            if v.sel_ship_idx ~= -1 then
                trace.output('卸载船员【',v.name,'】')
                ship_unit.unload_crew(v.id)
                decider.sleep(2000)
                ok_sel_n = ok_sel_n - 1
            end
        end
    end
    -- 检测选择船员
    if ok_sel_n < 2 then
        if not ship_unit.is_open_anchor_frame() then
            common.key_call('KEY_Z')
            decider.sleep(2000)
        end
        crew_info     = this.get_all_ship_crew()
        local can_sel = {}
        -- 优先选择指定船员
        for _,v in pairs(crew_info) do
            if v.sel_ship_idx == -1 and ( sel_name == v.name ) then
                table.insert(can_sel,{ id = v.id,name = v.name })
                ok_sel_n = ok_sel_n + 1
                break
            end
        end
        -- 获取当前选择船
        local ship_id   = ship_unit.get_cur_select_ship_id()  -- 停靠 界面才能读取
        local ship_name = ''
        -- 获取当前选择船名称
        local info      = ship_ent.get_ship_info_by_any(ship_id,'id')
        if not table.is_empty(info) then
            ship_name = info.name
        end
        -- 选择其他船员
        for _,v in pairs(crew_info) do
            local is_read = true
            if v.name == '奥胡' and ship_name ~= '埃斯托克' and ship_name ~= '' then
                is_read = false
            end
            if is_read and v.sel_ship_idx == -1 and ( sel_name ~= v.name ) and ok_sel_n < 2 then
                table.insert(can_sel,{ id = v.id,name = v.name })
                ok_sel_n = ok_sel_n + 1
            end
        end
        -- 配备船员
        for _,v in pairs(can_sel) do
            -- 配备船员(当前选择船) 配备的时候注意里面好像有个专用船员
            trace.output('配备船员【',v.name,'】')
            ship_unit.equip_crew(v.id)
            ok_sel_n = ok_sel_n + 1
            decider.sleep(2000)
        end
    end
end

------------------------------------------------------------------------------------
-- [读取] 获取所有船员的信息
ship_ent.get_all_ship_crew = function()
    local r_list = {}
    local list = ship_unit.crew_list()
    for _, id in ipairs(list) do
        local result = {
            id           = id,
            sel_ship_idx = ship_unit.get_crew_equip_idx(id),
            name         = ship_unit.get_crew_name(id)
        }
        table.insert(r_list,result)
    end
    return r_list
end

------------------------------------------------------------------------------------
-- [读取] 获取所有船的信息
ship_ent.get_all_ship_info = function()
    local r_list = {}
    local list = ship_unit.list()
    for _, obj in ipairs(list) do
        if ship_ctx:init(obj) then
            local name   = ship_ctx:name()
            local ship_i = ship_res.ship_info[name]
            local result = {
                -- 对象
                obj         = obj,
                -- 船名称
                name        = name,
                -- ID
                id          = ship_ctx:id(),
                -- 耐久度
                durable     = ship_ctx:durable(),
                -- 最大耐久
                max_durable = ship_ctx:max_durable(),
                -- 是否选择
                is_select   = ship_ctx:is_select(),

                ship_idx    = ship_i and ship_i.idx or -1
            }
            table.insert(r_list,result)
        end
    end
    if not table.is_empty(r_list) then
        -- 按最大耐久排序
        table.sort(r_list,function(a, b) return a.max_durable > b.max_durable end)
    end
    return r_list
end

------------------------------------------------------------------------------------
-- [读取] 获取指定属性值指定KEY的信息
ship_ent.get_ship_info_by_any = function(args, any_key)
    local result = {}
    local list = ship_unit.list()
    for _, obj in ipairs(list) do
        if ship_ctx:init(obj) then
            -- 获取指定属性的值
            local _any = ship_ctx[any_key](ship_ctx)
            -- 配对目标值
            if args == _any then
                local name   = ship_ctx:name()
                local ship_i = ship_res.ship_info[name]
                result = {
                    -- 对象
                    obj         = obj,
                    -- 船名称
                    name        = name,
                    -- ID
                    id          = ship_ctx:id(),
                    -- 耐久度
                    durable     = ship_ctx:durable(),
                    -- 最大耐久
                    max_durable = ship_ctx:max_durable(),
                    -- 是否选择
                    is_select   = ship_ctx:is_select(),

                    ship_idx    = ship_i and ship_i.idx or -1
                }
                break
            end
        end
    end
    return result
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function ship_ent.__tostring()
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
function ship_ent.__newindex(t, k, v)
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
ship_ent.__index = ship_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function ship_ent:new(args)
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
    return setmetatable(new, ship_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return ship_ent:new()

-------------------------------------------------------------------------------------
