-- core/generator.lua
local noise = require("procedural.noise")

local Generator = {}
Generator.__index = Generator

function Generator.new()
    return setmetatable({}, Generator)
end

function Generator:generateLakes(city)
    for x = 1, city.width do
        for y = 1, city.height do
            local n = (noise.perlin(x * 0.1, y * 0.1) + 1)/2
            if n < 0.25 then
                city:SetTile(x, y, "water")
            end

        end
    end
end

function Generator:generateRivers(city)
    -- find bodies of water
    -- find path between them
end

function Generator:generateCityZones(city)
    
end

return Generator