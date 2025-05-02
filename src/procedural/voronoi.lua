-- procedural/voronoi.lua
local voronoi = {}

-- Generate zones using voronoi diargam
function voronoi.zones(width, height, seeds)
    local zones = {}

    for x = 1, width do
        zones[x] = {}
        for y = 1, height do
            local nearest = nil
            local minDist = math.huge
            for _, seed in ipairs(seeds) do
                local dist = math.abs(seed.x - x) + math.abs(seed.y - y)
                if dist < minDist then
                    minDist = dist
                    nearest = seed
                end
            end
            zones[x][y] = nearest.type
        end
    end

    return zones
end

return voronoi