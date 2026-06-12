local ui = {}
local lg, ls, lk, lm = love.graphics, love.system, love.keyboard, love.mouse
local utf8 = require "utf8"
local tools = require "lua.tools"
local tClear = require "lua.tClear"
local states = require "lua.default.states"
local bound = tools.bound

-- color conv.
---@param c string | table
---@param isbg boolean | nil
local cv = function(c, isbg)
    if not isbg then
        return (type(c) ~= "table") and tools.hexrgb(c) or c
    else
        return (type(c) ~= "nil") and (type(c) ~= "table") and tools.hexrgb(c) or c or tools.hexrgb("000")
    end
end

---string length update
---@param tb table
local updstrlen = function(tb)
    local _, len = tb.font:getWrap(tb.str, tb.w - tb.pad)
    tb.strlen = len
    tb.i, tb.j = (tb.strlen) and utf8.offset(tb.strlen[#tb.strlen], -1) or 0, #tb.strlen
end

---input function for text box object
---@param tb table
---@param off number -- utf8.offset()
---@param t string
---@param islimit boolean | nil
local inputchar = function(tb, off, t, islimit)
    if islimit then
        --TODO: Implement proper text cutoff on pasting
        local tStr = tb.str .. t .. string.sub(tb.str, off + 1)
        local _, len = tb.font:getWrap(tStr, tb.w - tb.pad)
        local txtH = tb.font:getHeight() * #len
        if txtH < tb.h - tb.font:getHeight() / 2 then
            tb.str = tb.str .. t .. string.sub(tb.str, off + 1)
        end
    else
        tb.str = tb.str .. t .. string.sub(tb.str, off + 1)
    end
    updstrlen(tb)
end

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

---creates/returns new text box object as table value
---@param def string | nil -- empty state text
---@param font love.Font | nil -- font type
---@param x number -- x position
---@param y number -- y position
---@param w number -- text box width
---@param h number -- text box height
---@param func function -- function(str, tb)
---@param pad number | nil -- left & right padding size for text box
---@param useLimit boolean | nil -- limit character input to textbox width
---@param col string | table -- inactive text color
---@param colFill string | table -- active/editing text color
---@param bgCol string | table | nil -- background color
---@param bgHover string | table | nil -- background hover color
---@param btns table | nil -- structure: { {function(str, tb), col, colHover, active, icon, quad}, ... }
---@param btnsize number | nil -- adds/reduces button sizes, default is relative to text box height
---@return table -- see source code for usable values in returned table
function ui.newTBox(def, font, x, y, w, h, func, pad, useLimit, col, colFill, caretCol, bgCol, bgHover, btns, btnsize)
    if type(func) ~= "function" then
        error("func argument must be function (expected function, got " .. type(func) .. ")", 1)
    end

    if btns then
        for i = 1, #btns do
            local bt = btns[i]
            -- 6 index size if using quads
            if #bt >= 5 and #bt <= 6 then
                bt[2], bt[3], bt[4] = cv(bt[2]), cv(bt[3]), cv(bt[4])
                -- for lerp timer
                bt[#bt + 1] = 0
            else
                error("button table range must be 5 or 6 if using quads (index: " .. i .. ", range: " .. #bt .. ")", 1)
            end
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
        useLimit = useLimit,
        col = cv(col),
        colFill = cv(colFill),
        caretCol = cv(caretCol),
        ---@diagnostic disable-next-line
        bgCol = cv(bgCol, true),
        ---@diagnostic disable-next-line
        bgHover = cv(bgHover, true),
        btns = btns,
        btnsize = btnsize,
        -- edit state
        isEdit = false,
        selAll = false,

        --TODO: Make these actually work
        i = 0, -- current character in line
        j = 1, -- current line

        -- hover alpha
        hv = 0,
        -- string length
        strlen = {},

        --TODO: Implement undo/redo function?
        hist = {},
        hidx = 0,
        --TODO: Implement caret blinking
        blink = 0
    }
end

---updates text box objects
---@param tab table
---@param dt integer
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
        if tb.btns then
            for j = 1, #tb.btns do
                local btns = tb.btns[j]
                local s = (tb.btnsize) and tb.btnsize or 0
                local size = tb.h + s
                local x, y = (tb.x + tb.w + tb.pad) + ((size + (size / 8)) * (j - 1)) + (size / 8), tb.y

                if bound(mx, my, 0, 0, x, y, size, size) and not lm.isDown(1) then
                    if btns[#btns] < 1 then
                        btns[#btns] = btns[#btns] + dt * 9
                    end
                else
                    if btns[#btns] > 0 then
                        btns[#btns] = btns[#btns] - dt * 9
                    end
                end
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
            local off = (tb.str) and utf8.offset(tb.str, -1) or -1
            if tb.useLimit then
                inputchar(tb, off, t, true)
            else
                inputchar(tb, off, t)
            end
        end
    end
end

---handles keypress events for text box
---@param tab table
---@param k love.KeyConstant
function ui.keyTBox(tab, k)
    for i = 1, #tab do
        local tb = tab[i]
        -- tab-switching functionality
        if k == "tab" then
            -- if states.tabid > 0 then
            tb.selAll = false
            if i == states.tabid + 1 then
                tb.isEdit = true
                states.tabid = (states.tabid + 1 < #tab) and states.tabid + 1 or 0
                if states.tabid ~= 1 then
                    break
                else
                    tab[#tab].isEdit = false
                    break
                end
            else
                tb.isEdit = false
            end
            -- end
        end

        if tb.isEdit then
            if k ~= "capslock" and not lk.isDown("lshift", "rshift") and not lk.isDown("lalt", "ralt") then
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
            end
            if k == "backspace" then
                local off = utf8.offset(tb.str, -1)
                if off then
                    if tb.selAll then
                        tb.str = ""
                        tb.selAll = false
                    else
                        tb.str = string.sub(tb.str, 1, off - 1)
                    end
                    if utf8.len(tb.str) <= 0 then
                        tb.selAll = false
                    end
                end
            end

            if k == "return" then
                tb.func(tb.str, tb)
                tb.isEdit = false
            end

            if lk.isDown("lctrl", "rctrl") then
                if k == "a" then
                    if utf8.len(tb.str) > 0 then
                        tb.selAll = true
                    end
                end
                if k == "c" then
                    if tb.selAll then
                        if tb.str then ls.setClipboardText(tb.str) end
                    end
                end
                if k == "x" then
                    if tb.selAll then
                        if tb.str then ls.setClipboardText(tb.str) end
                        tClear(tb.strlen)
                        tb.str = ""
                        tb.selAll = false
                    end
                end
                if k == "v" then
                    local off = (tb.str) and utf8.offset(tb.str, -1) or -1
                    local paste = (ls.getClipboardText()) and ls.getClipboardText() or ""
                    if tb.selAll then
                        tClear(tb.strlen)
                        tb.str = ""
                        tb.selAll = false
                    end
                    inputchar(tb, off, paste, tb.useLimit)
                end
                if k == "z" then

                end
            end
            updstrlen(tb)
        end
    end

    if lk.isDown("lshift", "rshift") and states.tabid > 0 then
        for i = states.tabid + 1, #tab do
            local tb = tab[i]
            tb.isEdit = false
        end
    end
end

---handles click events for text box (use on love.mousereleased())
---@param tab any
function ui.clickTBox(tab, x, y, b)
    for i = #tab, 1, -1 do
        local tb = tab[i]
        if b == 1 then
            if bound(x, y, 0, 0, tb.x, tb.y, tb.w + tb.pad, tb.h) then
                states.tabid = i - 1
                tb.isEdit = (not tb.isEdit) and true or false
            else
                tb.isEdit = false
                tb.selAll = false
            end
        end

        if tb.btns then
            for j = 1, #tb.btns do
                local btns = tb.btns[j]
                local s = (tb.btnsize) and tb.btnsize or 0
                local size = tb.h + s
                local bx, by = (tb.x + tb.w + tb.pad) + ((size + (size / 8)) * (j - 1)) + (size / 8), tb.y
                if bound(x, y, 0, 0, bx, by, size, size) then
                    btns[1](tb.str, tb)
                    updstrlen(tb)
                end
            end
        end
    end
end

---draws text box
---@param tab table
function ui.drwTBox(tab)
    for i = 1, #tab do
        local tb = tab[i]
        local str = (tb.isEdit) and tb.str or (tb.str == "") and tb.def or tb.str
        ---@type love.Font
        local f = tb.font

        -- ## text box ##
        tools.colLerp(tb.bgCol, tb.bgHover, tb.hv)
        lg.rectangle("fill", tb.x, tb.y, tb.w + tb.pad, tb.h)
        if tb.selAll then
            for i = 1, #tb.strlen do
                lg.setColor(tools.hexrgb("#9999ccaa"))
                lg.rectangle("fill", tb.x + tb.pad,
                    tb.y + (f:getHeight() / 2) + f:getHeight() * (i - 1), f:getWidth(tb.strlen[i]),
                    f:getHeight())
            end
        end
        lg.setColor((tb.isEdit) and tb.colFill or (utf8.len(tb.str) == 0) and tb.col or tb.colFill)
        lg.printf(str, f, tb.x + tb.pad, tb.y + f:getHeight() / 2, tb.w - tb.pad, "left")
        lg.printf(tb.i .. ", " .. tb.j, f, tb.x, tb.y, tb.w, "left")
        if tb.isEdit then
            local str = (type(tb.strlen) ~= "nil") and tb.strlen[#tb.strlen] or ""
            local h = (#tb.strlen > 0) and tb.j - 1 or 0
            lg.setColor(tb.caretCol)
            lg.rectangle("fill", (tb.x + f:getWidth(str)) + tb.pad, tb.y + (f:getHeight() / 2) + (f:getHeight() * h), 2,
                f:getHeight())
        end

        -- ## buttons ##
        if tb.btns then
            for j = 1, #tb.btns do
                -- "overengineered"
                local btns = tb.btns[j]
                local mx, my = lm.getPosition()
                local col, colHover, active = btns[2], btns[3], btns[4]
                local icon = btns[5]

                local s = (tb.btnsize) and tb.btnsize or 0
                local size = tb.h + s
                local x, y = (tb.x + tb.w + tb.pad) + ((size + (size / 8)) * (j - 1)) + (size / 8), tb.y

                tools.colLerp((lm.isDown(1)) and (bound(mx, my, 0, 0, x, y, size, size)) and active or col or col,
                    colHover, btns[#btns])
                lg.rectangle("fill", x, y, size, size)
                lg.setColor(1, 1, 1, 1)
                if #btns >= 6 then
                    ---@type love.Quad
                    local qd = btns[6]
                    local _, _, w, h = qd:getViewport()
                    lg.draw(icon, qd, x, y, 0, (tb.h + s) / w, (tb.h + s) / h)
                else
                    if icon then
                        lg.draw(icon, x, y, 0)
                    end
                end
            end
        end
    end
end

---creates/returns button object as table value
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param bgCol string | table
---@param bgHover string | table
---@param func function
---@param col string | table
---@param colHover string | table
---@param str string | nil
---@param font love.Font | nil
---@param icon love.Image
---@param quad love.Quad
---@return table
function ui.newBtn(x, y, w, h, bgCol, bgHover, func, str, font, col, colHover, icon, quad)
    return {
        x = x,
        y = y,
        w = w,
        h = h,
        bgCol = bgCol,
        bgHover = bgHover,
        func = func,
        str = str,
        font = font,
        col = col,
        colHover = colHover,
        icon = icon,
        quad = quad
    }
end

function ui.updBtn(tab, dt)
    for i = 1, #tab do
        local btn = tab[i]
    end
end

function ui.clickBtn(tab, x, y, b)
    for i = 1, #tab do
        local btn = tab[i]
    end
end

function ui.drwBtn(tab)
    for i = 1, #tab do
        local btn = tab[i]
    end
end

function ui.adjBtnPos(tab, x, y)
    
end

function ui.adjTBox(tab, x, y)
    
end

---creates text info/effect to table
---@param tab table
---@param str string
---@param x number
---@param y number
---@param font love.Font
---@param col string | table
---@param limit number
---@param align love.AlignMode
---@param t number -- fade timer length/limit
---@param bgCol string | table | nil
function ui.newTextInfo(tab, str, x, y, font, col, limit, align, t, bgCol)
    table.insert(tab, {
        str = str,
        x = x,
        y = y,
        font = font,
        col = cv(col),
        limit = limit,
        align = align,
        t = t,
        ---@diagnostic disable-next-line
        bgCol = cv(bgCol, true),
        fadetimer = 0
    })
end

---updates text info/effect objects
---@param tab table
---@param dt number
function ui.updTextInfo(tab, dt)
    for i = #tab, 1, -1 do
        local ti = tab[i]
        if ti.fadetimer < ti.t then
            ti.fadetimer = ti.fadetimer + dt
        else
            ti.fadetimer = 0
            table.remove(tab, i)
        end
    end
end

---draws text info objs.
---@param tab table
function ui.drwTextInfo(tab)
    for i = 1, #tab do
        local ti = tab[i]
        -- terror instinct
        lg.printf(ti.str, ti.x, ti.y)
    end
end

return ui
