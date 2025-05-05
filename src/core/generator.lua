-- core/generator.lua
local noise = require("procedural.noise")
local voronoi = require("procedural.voronoi")
local poisson = require("procedural.poisson")
local algorithms = require("utils.algorithm")

local Generator = {}
Generator.__index = Generator

function Generator.new()
    return setmetatable({}, Generator)
end

function Generator:generateTopology(city)
    for x = 1, city.width do
        for y = 1, city.height do
            local n = (noise.perlin(x * 0.1, y * 0.1) + 1)/2
            if n < 0.2 then
                city:SetTile(x, y, "depth01")
            elseif n < 0.3 then
                city:SetTile(x, y, "depth02")
            elseif n < 0.4 then
                city:SetTile(x, y, "depth03")
            elseif n < 0.5 then
                city:SetTile(x, y, "depth04")
            elseif n < 0.6 then
                city:SetTile(x, y, "depth05")
            elseif n < 0.7 then
                city:SetTile(x, y, "depth06")
            else
                city:SetTile(x, y, "depth07")
            end
        end
    end
end

function Generator:processLakeTiles(city)
    local groups = algorithms.floodFill(self.lakeTiles, city.width, city.height)

    for _, group in ipairs(groups) do
        -- Choose center of mass
        local sumX, sumY = 0, 0
        for _, pt in ipairs(group) do
            sumX = sumX + pt.x
            sumY = sumY + pt.y
        end
        local cx = math.floor(sumX / #group)
        local cy = math.floor(sumY / #group)

        table.insert(self.lakes, {x = cx, y = cy})
    end
end

function Generator:generateLakes(city)
    self.lakes = {}
    self.lakeTiles = {}

    for x = 1, city.width do
        for y = 1, city.height do
            local n = (noise.perlin(x * 0.1, y * 0.1) + 1)/2
            if n < 0.2 then
                city:SetTile(x, y, "water")
                table.insert(self.lakeTiles, {x = x, y = y})
            end
        end
    end
    self:processLakeTiles(city)
end

function Generator:generateRivers(city)
    for i = 1, #self.lakes do
        if (i + 1) > #self.lakes then break end
        local path = algorithms.aStar.run(self.lakes[i], self.lakes[i+1], algorithms.aStar.wavyHeuristic, city.grid)
        if not  path then break end
        for _, pt in ipairs(path) do
            city:SetTile(pt.x, pt.y, "water")
        end
    end
end

local function generateSeeds(width, height)
    local zoneTypes = {
        { type = "residential", frequency = 0.5 },
        { type = "commercial",  frequency = 0.45 },
        { type = "industrial",  frequency = 0.05 },
    }

    local radius = 8
    local rawPoints = poisson.sample(width, height, radius)

    -- Build a weighted list of types
    local weightedList = {}
    for _, zone in ipairs(zoneTypes) do
        local count = math.floor(zone.frequency * 100)
        for i = 1, count do
            table.insert(weightedList, zone.type)
        end
    end

    local seeds = {}
    for i, pt in ipairs(rawPoints) do
        local zoneType = weightedList[math.random(#weightedList)]
        table.insert(seeds, {
            x = math.floor(pt.x),
            y = math.floor(pt.y),
            type = zoneType
        })
    end

    return seeds
end

function Generator:generateCityZones(city)
    local seeds = generateSeeds(city.width, city.height)
    local zoneMap = voronoi.zones(city.width, city.height, seeds)

    for x = 1, city.width do
        for y = 1, city.height do
            local tile = city:GetTile(x, y)
            if tile.type == "empty" then
                city:SetTile(x, y, zoneMap[x][y])
            end
        end
    end
end

return Generator