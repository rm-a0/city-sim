-- procedural/voronoi.lua
local voronoi = {}

-- Generate zones using voronoi diargam
function voronoi.zones(width, height, seeds)
	local zones = {}

	for x = 1, width do
		zones[x] = {}
		for y = 1, height do
			local nearest = nil
			local minDist = math.huge
			for _, seed in ipairs(seeds) do
				local dist = math.abs(seed.x - x) + math.abs(seed.y - y)
				if dist < minDist then
					minDist = dist
					nearest = seed
				end
			end
			zones[x][y] = nearest.type
		end
	end

	return zones
end

local function findEdges(width, height, zones)
	local edges = {}

	for x = 1, width do
		for y = 1, height do
			local curr = zones[x][y]
			local neighbors = {
				(y > 1) and zones[x][y - 1] or nil, -- up
				(y < height) and zones[x][y + 1] or nil, -- down
				(x > 1) and zones[x - 1][y] or nil, -- left
				(x < width) and zones[x + 1][y] or nil, -- right
			}

			for _, neighbor in ipairs(neighbors) do
				if neighbor and neighbor ~= -1 and neighbor ~= curr then
					zones[x][y] = -1
					table.insert(edges, { x = x, y = y })
					break
				end
			end
		end
	end

	return edges
end

function voronoi.roads(width, height, points)
	local zones = {}

	-- Initialize zones table
	for x = 1, width do
		zones[x] = {}
		for y = 1, height do
			local nearest = nil
			local minDist = math.huge
			for i, pt in ipairs(points) do
				if pt.x and pt.y and pt.x >= 1 and pt.x <= width and pt.y >= 1 and pt.y <= height then
					local dist = math.abs(pt.x - x) + math.abs(pt.y - y)
					if dist < minDist then
						minDist = dist
						nearest = i
					end
				end
			end
			zones[x][y] = nearest or 0
		end
	end

	local roads = findEdges(width, height, zones)
	return roads
end

return voronoi
