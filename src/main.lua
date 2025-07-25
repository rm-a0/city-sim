-- main.lua
local city = require("core.city")
local generator = require("core.generator")
local draw = require("render.draw")

local _city
local _generator

local tileSize = 8
local cityWidth = 400
local cityHeight = 300

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
			_generator:generateRoadsAndBridges(_city)
		elseif step == 6 then
			_generator:generateBuildings(_city)
		end
		step = step + 1
		time = 0
	end
end

function love.draw()
	draw.gridQuad(_city, tileSize)
	-- draw.gridHexa(_city, tileSize) -- not recommended very unreliable for not natural structures
end
