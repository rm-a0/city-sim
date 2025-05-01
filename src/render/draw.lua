-- render/draw.lua
local draw = {}

-- Render grid
function draw.grid(city, tileSize)
    for x = 1, city.width do
        for y = 1, city.height do
            local tile = city:GetTile(x, y)
            if tile then
                tile:Render2D(x, y, tileSize)
            end
        end
    end
end

return draw