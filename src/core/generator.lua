-- core/generator.lua
local noise = require("procedural.noise")
local voronoi = require("procedural.voronoi")
local poisson = require("procedural.poisson")

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
            elseif n < 0.2 then
                city:SetTile(x, y, "depth02")
            elseif n < 0.35 then
                city:SetTile(x, y, "depth03")
            elseif n < 0.5 then
                city:SetTile(x, y, "depth04")
            elseif n < 0.65 then
                city:SetTile(x, y, "depth05")
            elseif n < 0.8 then
                city:SetTile(x, y, "depth06")
            else
                city:SetTile(x, y, "depth07")
            end
        end
    end
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
    -- TODO later
end

local function generateSeeds(width, height)
    local zoneTypes = {
        { type = "residential", frequency = 0.5 },
        { type = "commercial",  frequency = 0.45 },
        { type = "industrial",  frequency = 0.05 },
    }

    local radius = 4
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