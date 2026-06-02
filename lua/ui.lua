local ui = {}
local utf8 = require "utf8"
local lg, ls, lk, lm = love.graphics, love.system, love.keyboard, love.mouse
local tools = require "lua.tools"
local bound = tools.bound

---changes filter settings in fonts, initialize on love.load (use for objects with font param)
---@param tab table
---@param filter love.FilterMode
function ui.txtFilter(tab, filter)
    for i = 1, #tab do
        ---@type love.Font
        local txt = tab[i].font
        txt:setFilter(filter, filter)
    end
end

---creates new text box object as table value
---@param def string | nil -- empty state text
---@param font love.Font | nil
---@param x number
---@param y number
---@param w number
---@param h number
---@param func function -- should include arg. for text input
---@param pad number | nil
---@param clrConf boolean | nil
---@param col string | table
---@param colHover string | table
---@param bgCol string | table | nil
---@param bgHover string | table | nil
---@param useBtn boolean | nil
---@param btnCol string | table | nil
---@return table
function ui.newTBox(def, font, x, y, w, h, func, pad, clrConf, col, colHover, bgCol, bgHover, useBtn, btnCol)
    if type(func) ~= "function" then
        error("func argument must be function (expected function, got " .. type(func) .. ")", 1)
    end

    -- color conv.
    local cv = function(c, isbg)
        if not isbg then
            return (type(c) ~= "table") and tools.hexrgb(c) or c
        else
            return (type(c) ~= "nil") and (type(c) ~= "table") and tools.hexrgb(c) or c or tools.hexrgb("000")
        end
    end
    return {
        str = "",
        def = def,
        font = (type(font) ~= "nil") and font or lg.newFont(14),
        x = x,
        y = y,
        w = w,
        h = h,
        func = func,
        pad = (type(pad) ~= "nil") and pad or 0,
        clrConf = clrConf,
        col = cv(col),
        colHover = cv(colHover),
        bgCol = cv(bgCol, true),
        bgHover = cv(bgHover, true),
        --TODO: Add confirm/send-like button
        useBtn = useBtn,
        btnCol = cv(btnCol, true),
        -- edit state
        isEdit = false,
        selAll = false,
        -- hover alpha
        hv = 0,
        -- string length
        strlen = {},
        blink = 0
    }
end

---updates text box objects
---@param tab table
function ui.updTBox(tab, dt)
    local mx, my = lm.getPosition()
    for i = 1, #tab do
        local tb = tab[i]
        if bound(mx, my, 0, 0, tb.x, tb.y, tb.w + tb.pad, tb.h) and not tb.isEdit then
            if tb.hv < 1 then
                tb.hv = tb.hv + dt * 9
            else
                tb.hv = 1
            end
        else
            if tb.hv > 0 then
                tb.hv = tb.hv - dt * 9
            else
                tb.hv = 0
            end
        end
    end
end

---handles input events for text box
---@param tab table
function ui.inpTBox(tab, t)
    for i = 1, #tab do
        local tb = tab[i]
        if tb.isEdit then
            tb.str = tb.str .. t
        end
    end
end

---handles keypress events for text box
---@param k string
function ui.keyTBox(tab, k)
    for i = 1, #tab do
        local tb = tab[i]
        if tb.isEdit then
            if k == "up" or k == "down" or k == "left" or k == "right" then
                tb.selAll = false
            else
                if tb.selAll then
                    if not lk.isDown("lctrl", "rctrl") then
                        tb.str = ""
                        tb.selAll = false
                    end
                end
            end
            if k == "backspace" then
                local off = utf8.offset(tb.str, -1)
                if off then
                    tb.str = string.sub(tb.str, 1, off - 1)
                    if utf8.len(tb.str) <= 0 then
                        tb.selAll = false
                    end
                end
            end
            if k == "return" then
                tb.func(tb.str)
                if tb.clrConf then
                    tb.str = ""
                end
                tb.isEdit = false
            end

            if lk.isDown("lctrl", "rctrl") then
                if k == "a" then
                    if utf8.len(tb.str) > 0 then
                        local _, len = tb.font:getWrap(tb.str, tb.w - tb.pad)
                        tb.strlen = len
                        tb.selAll = true
                    end
                end
                if k == "c" then
                    if tb.selAll then
                        if tb.str then ls.setClipboardText(tb.str) end
                    end
                end
                if k == "v" then
                    if tb.selAll then
                        tb.strlen = {}
                        tb.str = ""
                        tb.selAll = false
                    end
                    tb.str = tb.str .. ls.getClipboardText()
                end
            end
        end
    end
end

---handles click events for text box
---@param tab any
function ui.clickTBox(tab, x, y, b)
    for i = 1, #tab do
        local tb = tab[i]
        if b == 1 then
            if bound(x, y, 0, 0, tb.x, tb.y, tb.w + tb.pad, tb.h) then
                tb.isEdit = (not tb.isEdit) and true or false
            else
                tb.isEdit = false
                tb.selAll = false
            end
        end
    end
end

---draws text box
---@param tab table
function ui.drwTBox(tab)
    for i = 1, #tab do
        local tb = tab[i]
        local str = (tb.isEdit) and tb.str .. "|" or (tb.str == "") and tb.def or tb.str
        lg.setColor(tb.bgCol)
        lg.rectangle("fill", tb.x, tb.y, tb.w + tb.pad, tb.h)
        lg.setColor(tb.bgHover[1], tb.bgHover[2], tb.bgHover[3], tb.hv)
        lg.rectangle("fill", tb.x, tb.y, tb.w + tb.pad, tb.h)
        if tb.selAll then
            local f = tb.font
            for i = 1, #tb.strlen do
                lg.setColor(tools.hexrgb("#9999ccaa"))
                lg.rectangle("fill", tb.x + tb.pad,
                    tb.y + (tb.h / 2 - tb.font:getHeight() / 2) + tb.font:getHeight() * (i - 1), f:getWidth(tb.strlen[i]),
                    tb.font:getHeight())
            end
        end
        lg.setColor(tb.col)
        if type(tb.font) ~= "nil" then
            lg.printf(str, tb.font, tb.x + tb.pad, tb.y + (tb.h / 2 - tb.font:getHeight() / 2), tb.w - tb.pad, "left")
        else
            lg.printf(str, tb.x + tb.pad, tb.y, tb.w - tb.pad, "left")
        end
    end
end

return ui
