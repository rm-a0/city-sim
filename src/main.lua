-- main.lua
local city = require("core.city")
local generator = require("core.generator")
local draw = require("render.draw")

local _city
local _generator
local tileSize = 10
local step = 1
local time = 0
local delay = 0.5

function love.load()
    _city = city.new(500, 500)
    _generator = generator.new()
end

function love.update(dt)
    time = time + dt
    if time > delay then
        if step == 1 then
            _generator:generateLakes(_city)
        elseif step == 2 then
            _generator:generateRivers(_city)
        elseif step == 3 then
            _generator:generateCityZones(_city)
        end
        step = step + 1
        time = 0
    end
end

function love.draw()
    draw.grid(_city, tileSize)
end