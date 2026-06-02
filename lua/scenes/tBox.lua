local fonts    = require "lua.default.fonts"
local states   = require "lua.default.states"
local settings = require "lua.default.settings"
local ui       = require "lua.ui"
local tools    = require "lua.tools"

local tBox     = {
    graph = {
        ui.newTBox("enter value here", fonts.main, 10, 40, 320, 40, function(str)
            -- might be buggy
            local o = (#str <= 3) and 0 or 1
            if tools.hexeval(str, 1, o) and tools.hexeval(str, 2 + o, o) and tools.hexeval(str, 3 + (o + (1 - o)), o) then
                settings.bgcol = str
                print("-- changed bg. color (str: " .. str .. ") -- ")
            end
        end, 20, true, "#333", "FFF", "#fff", "#aaa", true, "#aaa"),
        ui.newTBox("see console logs for results", fonts.main, 10, 90, 320, 40, function(str)
            if type(tonumber(str)) == "number" then
                print("result: " .. 20 + tonumber(str) .. " (str: " .. str .. " + 20)")
            else
                print("## str value is not a number (str: " .. tostring(str) .. ", type: " .. type(str) .. ") ##")
            end
        end, 20, true, "#333", "FFF", "#fff", "#aaa", true, "#aaa")
    },
}

return tBox
