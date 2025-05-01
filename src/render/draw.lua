-- render/draw.lua
local draw = {}
local tileSize = 5

function draw.grid(grid)
    for x = 1, #grid do
        for y = 1, #grid[1] do
            if grid[x][y].type == "residential" then
                love.graphics.setColor(0, 1, 0)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.rectangle("fill", (x-1)*tileSize, (y-1)*tileSize, tileSize, tileSize)
        end
    end
end

return draw