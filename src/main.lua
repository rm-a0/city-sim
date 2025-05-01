-- main.lua
local city = require("core.city")
local generator = require("core.generator")
local draw = require("render.draw")

local _city
local _generator
local tileSize = 10

function love.load()
    _city = city.new(100, 100)
    _generator = generator.new()
    _generator:generateLayerOne(_city)

    _city:SetTile(5, 5, "residential")
    _city:SetTile(6, 6, "commercial")
end

function love.draw()
    draw.grid(_city, tileSize)
end