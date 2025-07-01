-- core/city.lua
local tileFactory = require("tiles.tileFactory")

local City = {}
City.__index = City

function City.new(width, height)
	local city = setmetatable({}, City)
	city.width = width
	city.height = height
	city.grid = {}
	for x = 1, width do
		city.grid[x] = {}
		for y = 1, height do
			city.grid[x][y] = tileFactory.new("empty")
		end
	end
	return city
end

-- Set Tile in the City grid
function City:SetTile(x, y, type)
	if not x or not y then
		return
	end

	if x < 1 or x > self.width or y < 1 or y > self.height then
		return
	end

	local newTile = tileFactory.new(type)

	if not newTile:CanPlace(self.grid[x][y]) then
		return
	end

	self.grid[x][y] = newTile
end

-- Get Tile from the City grid
function City:GetTile(x, y)
	if x < 1 or x > self.width or y < 1 or y > self.height then
		return nil
	end
	return self.grid[x][y]
end

return City
