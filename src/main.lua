-- main.lua
local city = require("core.city")
local generator = require("core.generator")
local draw = require("render.draw")

local _city
local _generator

local tileSize = 5
local cityWidth = 300
local cityHeight = 200

local step = 1
local time = 0
local delay = 2

function love.load()
	love.window.setMode(
		cityWidth * tileSize,
		cityHeight * tileSize,
		{ resizable = true, minwidth = cityWidth, minheight = cityHeight }
	)
	_city = city.new(cityWidth, cityHeight)
	_generator = generator.new()
end

function love.update(dt)
	time = time + dt
	if time > delay then
		if step == 1 then
			-- _generator:generateTopology(_city)
			_generator:generateLakes(_city)
		elseif step == 2 then
			_generator:generateRivers(_city)
		elseif step == 3 then
			_generator:generateCityZones(_city)
		elseif step == 4 then
			_generator:generateRoads(_city)
		elseif step == 5 then
			-- generate buildings
		end
		step = step + 1
		time = 0
	end
end

function love.draw()
	draw.grid(_city, tileSize)
end

