local graph = {}
local lg = love.graphics
local tools = require "lua.tools"
local settings = require "lua.default.settings"

local function drawPoints() -- ? maybe
    
end

---draws graphs on table as bezier curves (?)
---@param tab table
function graph.draw(tab)
    lg.setColor(tools.hexrgb(settings.graphcol))
    for i = 1, #tab do
        local gr = tab[i]

    end
end

return graph