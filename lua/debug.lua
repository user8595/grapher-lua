local debug  = {}
local lt, lg = love.timer, love.graphics
local tClear = require "lua.tClear"
local fonts  = require "lua.default.fonts"
local states = require "lua.default.states"
local tBox   = require "lua.scenes.tBox"

function debug.keys(k)
    if k == "0" then
        for i = 1, #tBox.graph do
            local tb = tBox.graph[i]
            if not tb.isEdit then
                tClear(tb.hist)
                tb.hidx = #tb.hist
            end
        end
    end
end

function debug.sDraw()
    local w, h = lg.getDimensions()
    local gcMem = collectgarbage("count")

    local s = string.format("%g FPS\n%gx%g", lt.getFPS(), w, h)
    local sR = string.format("scene: %s\n%gs dt\ngc: %.2f MB\ngfx: %g MB / %g drws\ndata: %g/%g\n-----\ntabid: %g", states.scene,
    lt.getDelta(), (gcMem * 1024) / 1048576, lg.getStats().texturememory / 1024 / 1024, lg.getStats().drawcalls,
        lg.getStats().images, lg.getStats().fonts, states.tabid)

    lg.setColor(1, 1, 1, 1)
    lg.print(s, fonts.othr, 10, 10)
    lg.printf(sR, fonts.othr, 0, 10, w - 10, "right")
end

return debug
