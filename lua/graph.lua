local graph = {}
local lg = love.graphics
local tools = require "lua.tools"
local settings = require "lua.default.settings"

local function drawPoints(v, scale) -- ? maybe
    local bezier = love.math.newBezierCurve(v)
    love.graphics.line(bezier:render())
    bezier:scale(scale)
end

---draws graphs on table as bezier curves (?)
---@param tab table
function graph.draw(tab, xoff, yoff, scale)
    lg.push()
    lg.translate(xoff, yoff)
    lg.setColor(tools.hexrgb(settings.graphcol))
    lg.line(0, 0, lg.getWidth(), 0)
    lg.line(0, 0, 0, lg.getHeight())
    for i = 1, #tab do
        local gr = tab[i]
        drawPoints(gr, scale)
    end
    lg.pop()
end

return graph
