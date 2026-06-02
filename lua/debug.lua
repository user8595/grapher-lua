local debug = {}
local lt, lg = love.timer, love.graphics
local fonts = require "lua.default.fonts"
local states = require "lua.default.states"

function debug.sDraw()
    local w, h = lg.getDimensions()

    local s = string.format("%g FPS\n%gx%g", lt.getFPS(), w, h)
    local sR = string.format("scene: %s\n%gs dt", states.scene, lt.getDelta())

    lg.setColor(1, 1, 1, 1)
    lg.print(s, fonts.othr, 10, 10)
    lg.printf(sR, fonts.othr, 0, 10, w - 10, "right")
end

return debug
