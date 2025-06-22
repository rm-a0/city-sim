-- tiles/tileFactory.lua
local tileFactory = {}
local tile = require("tiles.tile")

-- Load tile types
tileFactory.types = {
	empty = require("tiles.tileTypes.empty"),
	residential = require("tiles.tileTypes.residential"),
	commercial = require("tiles.tileTypes.commercial"),
	industrial = require("tiles.tileTypes.industrial"),
	water = require("tiles.tileTypes.water"),
	mainRoad = require("tiles.tileTypes.mainRoad"),
	secondaryRoad = require("tiles.tileTypes.secondaryRoad"),
	defaultBuilding = require("tiles.tileTypes.defaultBuilding"),
	-- topology tiles
	depth01 = require("tiles.tileTypes.depth01"),
	depth02 = require("tiles.tileTypes.depth02"),
	depth03 = require("tiles.tileTypes.depth03"),
	depth04 = require("tiles.tileTypes.depth04"),
	depth05 = require("tiles.tileTypes.depth05"),
	depth06 = require("tiles.tileTypes.depth06"),
	depth07 = require("tiles.tileTypes.depth07"),
}

-- Create a new tile instance
function tileFactory.new(type)
	local typeDef = tileFactory.types[type]
	if not typeDef then
		error("Unknown tile type: " .. tostring(type))
	end
	return tile.new(type, typeDef)
end

return tileFactory
