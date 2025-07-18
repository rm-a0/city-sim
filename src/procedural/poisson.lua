-- procedural/poisson.lua
local poisson = {}

-- Get distance between two points
local function dist2(p1, p2)
	local dx = p1.x - p2.x
	local dy = p1.y - p2.y
	return dx * dx + dy * dy
end

function poisson.sampleDefault(width, height, radius, k)
	local cellSize = radius / math.sqrt(2)
	local gridWidth = math.ceil(width / cellSize)
	local gridHeight = math.ceil(height / cellSize)

	local grid = {}
	for i = 1, gridWidth * gridHeight do
		grid[i] = false
	end

	local function gridIndex(x, y)
		return math.floor(x / cellSize) + 1 + gridWidth * math.floor(y / cellSize)
	end

	local points = {}
	local active = {}

	local function addPoint(pt)
		table.insert(points, pt)
		table.insert(active, pt)
		grid[gridIndex(pt.x, pt.y)] = pt
	end

	addPoint({ x = math.random() * width, y = math.random() * height })

	while #active > 0 do
		local i = math.random(#active)
		local point = active[i]
		local found = false

		for n = 1, k or 30 do
			local angle = math.random() * 2 * math.pi
			local r = radius * (1 + math.random())
			local nx = point.x + math.cos(angle) * r
			local ny = point.y + math.sin(angle) * r

			if nx >= 0 and nx < width and ny >= 0 and ny < height then
				local good = true
				local gx = math.floor(nx / cellSize)
				local gy = math.floor(ny / cellSize)

				for dx = -2, 2 do
					for dy = -2, 2 do
						local neighbor = grid[(gx + dx) + 1 + gridWidth * (gy + dy)]
						if neighbor and dist2(neighbor, { x = nx, y = ny }) < radius * radius then
							good = false
						end
					end
				end

				if good then
					addPoint({ x = nx, y = ny })
					found = true
				end
			end
		end

		if not found then
			table.remove(active, i)
		end
	end

	return points
end

function poisson.sampleGrid(width, height, radius, jitter)
	jitter = jitter or 0.5
	local cellSize = radius
	local gridWidth = math.floor(width / cellSize)
	local gridHeight = math.floor(height / cellSize)

	local grid = {}
	for i = 1, gridWidth * gridHeight do
		grid[i] = false
	end

	local function gridIndex(x, y)
		return math.floor(x / cellSize) + 1 + gridWidth * math.floor(y / cellSize)
	end

	local points = {}

	for gx = 0, gridWidth - 1 do
		for gy = 0, gridHeight - 1 do
			local baseX = (gx + 0.5) * cellSize
			local baseY = (gy + 0.5) * cellSize

			local jitterX = (math.random() - 0.5) * cellSize * jitter
			local jitterY = (math.random() - 0.5) * cellSize * jitter
			local nx = baseX + jitterX
			local ny = baseY + jitterY

			if nx >= 0 and nx < width and ny >= 0 and ny < height then
				local good = true
				for dx = -1, 1 do
					for dy = -1, 1 do
						if dx == 0 and dy == 0 then
							goto continue
						end
						local neighborIdx = (gx + dx) + 1 + gridWidth * (gy + dy)
						if neighborIdx >= 1 and neighborIdx <= #grid then
							local neighbor = grid[neighborIdx]
							if neighbor and dist2(neighbor, { x = nx, y = ny }) < radius * radius then
								good = false
								break
							end
						end
						::continue::
					end
					if not good then
						break
					end
				end

				if good then
					local pt = { x = nx, y = ny }
					table.insert(points, pt)
					grid[gridIndex(nx, ny)] = pt
				end
			end
		end
	end

	return points
end

return poisson
