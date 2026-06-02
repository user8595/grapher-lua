local lk, le, lg = love.keyboard, love.event, love.graphics
local fonts      = require "lua.default.fonts"
local settings   = require "lua.default.settings"
local states     = require "lua.default.states"
local tBox       = require "lua.scenes.tBox"
local debug      = require "lua.debug"
local graph      = require "lua.graph"
local ui         = require "lua.ui"
local tools      = require "lua.tools"
local points     = {}

function love.load()
    if arg[2] == "debug" then
        states.isDebug = true
    end
    ui.txtFilter(tBox[states.scene], "nearest")
end

function love.mousereleased(x, y, b, istouch)
    ui.clickTBox(tBox[states.scene], x, y, b)
end

function love.keypressed(k)
    if k == "escape" then
        le.quit(0)
    end
    if k == "f4" then
        states.isDebug = (not states.isDebug) and true or false
    end
    ui.keyTBox(tBox[states.scene], k)
end

function love.textinput(t)
    ui.inpTBox(tBox[states.scene], t)
end

function love.update(dt)
    ui.updTBox(tBox[states.scene], dt)
end

function love.draw()
    lg.setColor(tools.hexrgb(settings.bgcol))
    lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())
    graph.draw(points)
    ui.drwTBox(tBox[states.scene])
    if states.isDebug then
        debug.sDraw()
    end
end
