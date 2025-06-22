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

	local parentList = type(typeDef.parent) == "table" and typeDef.parent or { typeDef.parent }

	for _, parentType in ipairs(parentList) do
		if currentTile.type == parentType then
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
	love.graphics.rectangle("fill", (x - 1) * tileSize, (y - 1) * tileSize, tileSize, tileSize)
end

return tile
