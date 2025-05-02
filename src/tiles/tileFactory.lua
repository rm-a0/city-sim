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