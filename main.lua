local lk, lw, le, lg = love.keyboard, love.window, love.event, love.graphics
local ls             = love.system
local fonts          = require "lua.default.fonts"
local settings       = require "lua.default.settings"
local states         = require "lua.default.states"
local tBox           = require "lua.scenes.tBox"
local debug          = require "lua.debug"
local graph          = require "lua.graph"
local ui             = require "lua.ui"
local tools          = require "lua.tools"

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
    if k == "f11" or lk.isDown("lalt", "ralt") and lk.isDown("return") then
        lw.setFullscreen((not lw.getFullscreen()) and true or false)
    end
    debug.keys(k)
    ui.keyTBox(tBox[states.scene], k)
end

function love.textinput(t)
    ui.inpTBox(tBox[states.scene], t)
end

function love.update(dt)
    ui.updTBox(tBox[states.scene], dt)
    ui.updTextInfo(states.tinfo, dt)
end

function love.draw()
    lg.setColor(tools.hexrgb(settings.bgcol))
    lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())
    graph.draw(states.points, states.xoff, states.yoff, states.gScale)
    ui.drwTBox(tBox[states.scene])
    ui.drwTextInfo(states.tinfo)
    if states.isDebug then
        debug.sDraw()
    end

    local status, p = ls.getPowerInfo()
    if settings.showtime then
        local off = (not p) and 14 or 42
        lg.push()
        lg.translate(7, 0)
        if p then
            lg.setColor(tools.hexrgb((status == "charging") and "#AEF73A" or (p <= 20) and "#F56E6E" or "#999"))
            lg.push()
            lg.translate(lg.getWidth() - 38, lg.getHeight() - 20)
            -- lg.scale(1 * (lg.getWidth() / settings.width), 1 * (lg.getHeight() / settings.height))
            lg.rectangle("line", 0, 0, 22, 10)
            lg.rectangle("fill", 0, 0, 22 * p / 100, 10)
            lg.pop()
            lg.setColor(1, 1, 1, 1)
            lg.printf(p, fonts.othr, lg.getWidth() - 40, lg.getHeight() - 20, 30, "center")
        end
        lg.setColor(1, 1, 1, 1)
        lg.printf(os.date("%H:%M"), fonts.othr, 0, lg.getHeight() - 20, lg.getWidth() - off, "right")
        lg.pop()
    end
end
