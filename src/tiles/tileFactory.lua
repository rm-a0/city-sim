-- tiles/tileFactory.lua
local tileFactory = {}
local tile = require("tiles.tile")

-- Load tile types
tileFactory.types = {
    empty = require("tiles.empty"),
    residential = require("tiles.residential"),
    commercial = require("tiles.commercial"),
    industrial = require("tiles.industrial"),
    water = require("tiles.water"),
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