local lerp = require "lua.lerp"
local lg = love.graphics
local tools = {}
local string = string

---substring/truncation with fallback string
---@param str string
---@param i number
---@param j number
---@param def string
---@return string
local function sub(str, i, j, def)
    return (string.len(string.sub(str, i, j)) > 0) and string.sub(str, i, j) or def
end

---converts hex to rgb values
---@param hex string | number -- ex. "#123", "#112233ff", "123", 112233ff
---@param long boolean | nil -- true for long range (0-255), or short (0-1)
---@return table -- table struct: [1] = r, [2] = g, [3] = b, [4] = a
function tools.hexrgb(hex, long)
    local hex = hex
    if type(hex) == "number" then
        hex = tostring(hex)
    else
        if type(hex) ~= "string" then
            error("hex value must be string/number (hex: " .. tostring(hex) .. ", type: " .. type(hex) .. ")", 1)
        end
    end
    local h, div = (string.sub(hex, 1, 1) == "#") and 1 or 0, (long) and 1 or 255
    local r, g, b, a
    if string.len(hex) <= 3 + h then
        r, g, b, a = string.rep(sub(hex, 1 + h, 1 + h, "ff"), 2), string.rep(sub(hex, 2 + h, 2 + h, "ff"), 2),
            string.rep(sub(hex, 3 + h, 3 + h, "ff"), 2), "ff"
    else
        r, g, b, a = sub(hex, 1 + h, 2 + h, "ff"), sub(hex, 3 + h, 4 + h, "ff"), sub(hex, 5 + h, 6 + h, "ff"),
            sub(hex, 7 + h, 8 + h, "ff")
    end
    local r1, g1, b1, a1 = tonumber(r, 16) / div, tonumber(g, 16) / div, tonumber(b, 16) / div, tonumber(a, 16) / div
    return { r1, g1, b1, a1 }
end

---evaluate hex string values
---@param str string -- hex value to evaluate
---@param offset number -- first string offset, defaults to 1 if nil
---@param lenoff number | nil -- length from offset, defaults to 1 if nil
---@return boolean
function tools.hexeval(str, offset, lenoff)
    local o = (type(offset) == "number") and offset or 1
    local l = (type(lenoff) == "number") and lenoff or 0
    if type(tonumber(string.sub(str, o, l), 16)) ~= "number" then
        return false
    end
    return true
end

---interpolates between two colors
---@param col1 string | number | table
---@param col2 string | number | table
---@param t number
function tools.colLerp(col1, col2, t)
    ---@format disable
    local col1, col2 = (type(col1) == "string") and tools.hexrgb(col1) or col1, (type(col2) == "string") and tools.hexrgb(col2) or col2
    lg.setColor(lerp.linear(col1[1], col2[1], t), lerp.linear(col1[2], col2[2], t), lerp.linear(col1[3], col2[3], t), lerp.linear(col1[4], col2[4], t))
end

---aabb bounding box collision detection
---@param x1 number
---@param y1 number
---@param w1 number
---@param h1 number
---@param x2 number
---@param y2 number
---@param w2 number
---@param h2 number
---@return boolean
function tools.bound(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2
end

return tools
