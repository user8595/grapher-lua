local fonts    = require "lua.default.fonts"
local states   = require "lua.default.states"
local settings = require "lua.default.settings"
local ui       = require "lua.ui"
local tools    = require "lua.tools"
local lg       = love.graphics

local btn      = lg.newImage("/assets/img/btns-32x16.png")
local qd       = {
    confirm = lg.newQuad(16, 0, 16, 16, btn:getDimensions()),
    cancel = lg.newQuad(0, 0, 16, 16, btn:getDimensions())
}
btn:setFilter("nearest", "nearest")

-- rendering order is last to first (?)
local tBox = {
    graph = {
        ui.newTBox("enter value here", fonts.main, 10, 40, 320, 80, function(str, tb)
            -- test
            local o = (#str <= 3) and 1 or 2
            local h = (string.sub(str, 1, 1) == "#") and 1 or 0
            -- only first character though
            if tools.hexeval(str, 1 + h, o + h) then
                settings.bgcol = str
                print("-- changed bg. color (str: " .. str .. ") -- ")
            end
            tb.str = ""
        end, 20, true, "#987", "#000", "#000", "#fff", "#ddd", {
            { function(str, tb)
                local o = (#str <= 3) and 1 or 2
                if tools.hexeval(str, 1, o) then
                    settings.bgcol = str
                    print("-- changed bg. color (str: " .. str .. ") -- ")
                end
                tb.str = ""
            end, "#999", "#aaa", "#888", btn, qd.confirm }
        }, -40),
        ui.newTBox("enter coordinates (x pos only)", fonts.main, 10, 128, 320, 40, function(str, tb)
            -- how regex
            if type(tonumber(str)) == "number" then
                local num = tonumber(str)
                table.insert(states.points,
                    ---@diagnostic disable-next-line
                    { num, love.math.random(0, num), love.math.random(love.math.random(0, num), love.math.random(0, num)),
                        ---@diagnostic disable-next-line
                        love.math.random(love.math.random(0, num), love.math.random(0, num)), love.math.random(
                        ---@diagnostic disable-next-line
                        love.math.random(0, num), love.math.random(0, num)), love.math.random(love.math.random(0, num), love.math.random(0, num)) })
                print("-- inserted values to line --")
            end
            tb.str = ""
        end, 20, false, "#987", "#000", "#000", "#fff", "#ddd", {
            { function(str, tb)
                tb.str = ""
            end, "#BD3A29", "#C24635", "#751E12", btn, qd.cancel },
            { function(str, tb)
                -- still a test

                tb.str = ""
            end, "#999", "#aaa", "#888", btn, qd.confirm },
        })
    },
}

return tBox
