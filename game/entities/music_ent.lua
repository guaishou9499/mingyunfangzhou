------------------------------------------------------------------------------------
-- game/entities/music_ent.lua
--
-- 乐谱单元
--
-- @module      music_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local music_ent = import('game/entities/music_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class music_ent
local music_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE             = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME             = 'music_ent module',
    -- 只读模式
    READ_ONLY               = false,
}

-- 实例对象
local this         = music_ent
-- 日志模块
local trace        = trace
local common       = common
-- 决策模块
local decider      = decider
local setmetatable = setmetatable
local pairs        = pairs
local rawset       = rawset
local music_unit   = music_unit
local ui_ent       = import('game/entities/ui_ent')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function music_ent.super_preload()

end

------------------------------------------------------------------------------------
-- [行为] 使用指定乐普
function music_ent.use_music_by_name(name,stop_check_move)
    if not stop_check_move and common.is_move() then
        return false
    end
    local music_id_list = music_unit.music_id_list()
    for i = 1, #music_id_list do
        local id = music_id_list[i]

        if name == music_unit.music_name_byid(id) and music_unit.music_cd_time(id) == 0 then --and music_unit.music_is_active(id)
            ui_ent.esc_cinema()
            -- 使用乐谱
            trace.output('使用：',name)
            music_unit.use_music(id)
            decider.sleep(1000)
            common.wait_over_state()
            decider.sleep(2000)
            common.wait_loading_map()
            return true
        end
    end
    return false
end

------------------------------------------------------------------------------------
-- [条件] 是否存在指定乐普
function music_ent.is_active_music(name)
    local music_id_list = music_unit.music_id_list()
    for _,id in pairs(music_id_list) do
        if name == music_unit.music_name_byid(id) and music_unit.music_is_active(id) then
            return id
        end
    end
    return false
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function music_ent.__tostring()
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
function music_ent.__newindex(t, k, v)
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
music_ent.__index = music_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function music_ent:new(args)
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
    return setmetatable(new, music_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return music_ent:new()

-------------------------------------------------------------------------------------
