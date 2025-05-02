-- main.lua
local city = require("core.city")
local generator = require("core.generator")
local draw = require("render.draw")

local _city
local _generator
local tileSize = 10

function love.load()
    _city = city.new(1000, 1000)
    _generator = generator.new()
    _generator:generateLakes(_city)
    _generator:generateRivers(_city)
    _generator:generateCityZones(_city)
end

function love.draw()
    draw.grid(_city, tileSize)
end