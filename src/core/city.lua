-- core/city.lua
local city = {}
local grid = {}

function city.init(width, height)
    grid = {}
    for x = 1, width do
        grid[x] = {}
        for y = 1, height do
            grid[x][y] = { type = "empty", traffic = 0 }
        end
    end
end

function city.getGrid()
    return grid
end

return city