-- tiles/tile.lua
local tile = {}

-- Base Tile with metatable
local Tile = {}
Tile.__index = Tile

-- Create a new Tile instance
function tile.new(type, typeDef)
    local tile = setmetatable({}, Tile)
    tile.type = type
    tile.traffic = 0
    tile.typeDef = typeDef -- Stores color, parent, etc.
    return tile
end

-- Get tile type properties
function Tile:GetType()
    return self.typeDef or error("Unknown tile type: " .. tostring(self.type))
end

-- Check if tile can be placed on another tile
function Tile:CanPlace(currentTile)
    local typeDef = self:GetType()
    if not typeDef.parent then
        return true -- No parent requirement
    end
    if type(typeDef.parent) == "string" then
        return currentTile.type == typeDef.parent
    end
    for _, parentType in ipairs(typeDef.parent) do
        if parentType == currentTile.type then
            return true
        end
    end
    return false
end

-- Get rendering color for 2D visualization
function Tile:GetColor()
    return self:GetType().color
end

-- Render the tile in 2D
function Tile:Render2D(x, y, tileSize)
    love.graphics.setColor(self:GetColor())
    love.graphics.rectangle("fill", (x-1)*tileSize, (y-1)*tileSize, tileSize, tileSize)
end

return tile