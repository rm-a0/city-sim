-- render/draw.lua
local draw = {}

-- Render grid
function draw.gridQuad(city, tileSize)
	for x = 1, city.width do
		for y = 1, city.height do
			local tile = city:GetTile(x, y)
			if tile then
				tile:RenderQuad(x, y, tileSize)
			end
		end
	end
end

-- Render hexgonal grid
function draw.gridHexa(city, tileSize)
	local hexWidth = tileSize * math.sqrt(3)
	local hexHeight = tileSize * 1.5
	local xOffset = hexWidth
	local yOffset = hexHeight * 0.75

	for x = 1, city.width do
		for y = 1, city.height do
			local tile = city:GetTile(x, y)
			if tile then
				local px = (x - 1) * xOffset
				local py = (y - 1) * yOffset
				if y % 2 == 0 then
					px = px + xOffset * 0.5
				end
				tile:RenderHexa(px, py, tileSize)
			end
		end
	end
end

return draw
