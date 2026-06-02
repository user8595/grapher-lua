local fonts  = require "lua.default.fonts"
local states = require "lua.default.states"
local ui     = require "lua.ui"

local tBox   = {
    graph = {
        ui.newTBox("enter value here", fonts.main, 10, 40, 320, 40, function(str)
            states.scene = str
        end, 20, true, "#333", "FFF", "#fff", "#aaa", true, "#aaa")
    },
}

return tBox
