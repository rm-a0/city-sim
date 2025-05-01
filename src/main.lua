-- main.lua
local city = require("core.city")
local draw = require("render.draw")

function love.load()
    city.init(100, 100)

    local grid = city.getGrid()
    grid[5][5] = { type = "residential", traffic = 0 }
end

function love.draw()
    draw.grid(city.getGrid())
end