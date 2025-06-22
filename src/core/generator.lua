-- core/generator.lua
local noise = require("procedural.noise")
local voronoi = require("procedural.voronoi")
local poisson = require("procedural.poisson")
local algorithms = require("utils.algorithm")

local Generator = {}
Generator.__index = Generator

function Generator.new()
	return setmetatable({}, Generator)
end

function Generator:generateTopology(city)
	for x = 1, city.width do
		for y = 1, city.height do
			local n = (noise.perlin(x * 0.1, y * 0.1) + 1) / 2
			if n < 0.2 then
				city:SetTile(x, y, "depth01")
			elseif n < 0.3 then
				city:SetTile(x, y, "depth02")
			elseif n < 0.4 then
				city:SetTile(x, y, "depth03")
			elseif n < 0.5 then
				city:SetTile(x, y, "depth04")
			elseif n < 0.6 then
				city:SetTile(x, y, "depth05")
			elseif n < 0.7 then
				city:SetTile(x, y, "depth06")
			else
				city:SetTile(x, y, "depth07")
			end
		end
	end
end

function Generator:processLakeTiles(city)
	local groups = algorithms.floodFill(self.lakeTiles, city.width, city.height)

	for _, group in ipairs(groups) do
		local sumX, sumY = 0, 0
		for _, pt in ipairs(group) do
			sumX = sumX + pt.x
			sumY = sumY + pt.y
		end
		local cx = math.floor(sumX / #group)
		local cy = math.floor(sumY / #group)

		table.insert(self.lakes, { x = cx, y = cy })
	end
end

function Generator:generateLakes(city)
	self.lakes = {}
	self.lakeTiles = {}

	for x = 1, city.width do
		for y = 1, city.height do
			local n = (noise.perlin(x * 0.1, y * 0.1) + 1) / 2
			if n < 0.25 then
				city:SetTile(x, y, "water")
				table.insert(self.lakeTiles, { x = x, y = y })
			end
		end
	end
	self:processLakeTiles(city)
end

function Generator:generateRiverChains(city)
	if not self.lakes or #self.lakes < 2 then
		self.riverChains = {}
		return
	end

	local edgeThreshold = 8
	local minChainLength = 3
	local maxChainLength = 10
	local maxChains = math.floor(#self.lakes / 2)
	local minPairDistance = 5
	local riverChains = {}
	local usedLakes = {}

	local function copyTable(tbl)
		local copy = {}
		for k, v in pairs(tbl) do
			copy[k] = v
		end
		return copy
	end

	local function isNearEdge(lake)
		return lake.x <= edgeThreshold
			or lake.x >= city.width - edgeThreshold
			or lake.y <= edgeThreshold
			or lake.y >= city.height - edgeThreshold
	end

	local function getEdgePoint(lake)
		local minDist = math.huge
		local edgePoint = nil
		local edges = {
			{ x = 1, y = lake.y },
			{ x = city.width, y = lake.y },
			{ x = lake.x, y = 1 },
			{ x = lake.x, y = city.height },
		}
		for _, pt in ipairs(edges) do
			local dist = math.sqrt((lake.x - pt.x) ^ 2 + (lake.y - pt.y) ^ 2)
			if dist < minDist then
				minDist = dist
				edgePoint = pt
			end
		end
		return edgePoint
	end

	local function distance(lake1, lake2)
		return math.sqrt((lake1.x - lake2.x) ^ 2 + (lake1.y - lake2.y) ^ 2)
	end

	local function findNextLake(current, exclude)
		local bestLake = nil
		local bestScore = math.huge
		local bestIndex = nil

		for i, lake in ipairs(self.lakes) do
			if not exclude[i] then
				local dist = distance(current, lake)
				if dist >= minPairDistance then
					local dx, dy = math.abs(current.x - lake.x), math.abs(current.y - lake.y)
					local alignmentScore = math.min(dx, dy)
					local score = dist + alignmentScore * 0.5
					if score < bestScore then
						bestScore = score
						bestLake = lake
						bestIndex = i
					end
				end
			end
		end

		return bestLake, bestIndex
	end

	while #riverChains < maxChains and #usedLakes < #self.lakes do
		local chain = {}
		local chainLength = math.random(minChainLength, maxChainLength)
		local currentIndex = nil
		local exclude = copyTable(usedLakes)

		local availableLakes = {}
		for i = 1, #self.lakes do
			if not usedLakes[i] then
				table.insert(availableLakes, i)
			end
		end
		if #availableLakes == 0 then
			break
		end
		currentIndex = availableLakes[math.random(#availableLakes)]
		table.insert(chain, self.lakes[currentIndex])
		exclude[currentIndex] = true

		for i = 2, chainLength do
			local nextLake, nextIndex = findNextLake(chain[#chain], exclude)
			if nextLake then
				table.insert(chain, nextLake)
				exclude[nextIndex] = true
			else
				break
			end
		end

		local lastLake = chain[#chain]
		if not isNearEdge(lastLake) then
			local edgePoint = getEdgePoint(lastLake)
			table.insert(chain, edgePoint)
		end

		if #chain >= minChainLength then
			table.insert(riverChains, chain)
			for i, lake in ipairs(chain) do
				for j, origLake in ipairs(self.lakes) do
					if lake.x == origLake.x and lake.y == origLake.y then
						usedLakes[j] = true
					end
				end
			end
		end
	end

	self.riverChains = riverChains
end

function Generator:postProcessRivers(city, paths)
	local minRiverLength = 5
	local mergeThreshold = 3

	local function distance(pt1, pt2)
		return math.sqrt((pt1.x - pt2.x) ^ 2 + (pt1.y - pt2.y) ^ 2)
	end

	local function getEdgePoint(pt)
		local minDist = math.huge
		local edgePoint = nil
		local edges = {
			{ x = 1, y = pt.y },
			{ x = city.width, y = pt.y },
			{ x = pt.x, y = 1 },
			{ x = pt.x, y = city.height },
		}
		for _, edge in ipairs(edges) do
			local dist = distance(pt, edge)
			if dist < minDist then
				minDist = dist
				edgePoint = edge
			end
		end
		return edgePoint
	end

	local function smoothPath(path, amplitude, frequency, phaseShift)
		for i = 2, #path - 1 do
			local x = path[i].x
			local startX = path[1].x
			local endX = path[#path].x
			local expectedY = path[1].y + amplitude * math.sin(frequency * (x - endX) + phaseShift)
			expectedY = math.max(1, math.min(city.height, math.floor(expectedY + 0.5)))
			path[i].y = expectedY
		end
		return path
	end

	-- Step 1: Remove short rivers
	local filteredPaths = {}
	for _, path in ipairs(paths) do
		if #path >= minRiverLength then
			table.insert(filteredPaths, path)
		end
	end

	local mergedPaths = {}
	local tileMap = {}
	for _, path in ipairs(filteredPaths) do
		local isMerged = false
		for _, pt in ipairs(path) do
			local key = pt.x .. "," .. pt.y
			tileMap[key] = (tileMap[key] or 0) + 1
			if tileMap[key] > 1 then
				isMerged = true
			end
		end
		if not isMerged then
			table.insert(mergedPaths, path)
		else
			for _, pt in ipairs(path) do
				city:SetTile(pt.x, pt.y, "water")
				city:SetTile(pt.x + 1, pt.y + 1, "water")
			end
		end
	end

	for _, path in ipairs(mergedPaths) do
		local lastPoint = path[#path]
		if not (lastPoint.x == 1 or lastPoint.x == city.width or lastPoint.y == 1 or lastPoint.y == city.height) then
			local edgePoint = getEdgePoint(lastPoint)
			local extension = algorithms.aStar.run(lastPoint, edgePoint, algorithms.aStar.wavyHeuristic, city.grid)
			if extension then
				for j = 2, #extension do
					table.insert(path, extension[j])
				end
			end
		end
	end

	for i, path in ipairs(mergedPaths) do
		local distance = distance(path[1], path[#path])
		local baseAmplitude = distance * 0.15
		baseAmplitude = math.min(baseAmplitude, 10)
		baseAmplitude = math.max(baseAmplitude, 2)
		local randomFactor = 0.8 + (math.random() * 0.4)
		local amplitude = baseAmplitude * randomFactor
		local frequency = 0.05
		local phaseShift = math.random() * 2 * math.pi
		mergedPaths[i] = smoothPath(path, amplitude, frequency, phaseShift)
	end

	for _, path in ipairs(mergedPaths) do
		for _, pt in ipairs(path) do
			city:SetTile(pt.x, pt.y, "water")
		end
	end
end

function Generator:generateRivers(city)
	self:generateRiverChains(city)
	local paths = {}
	for _, chain in ipairs(self.riverChains) do
		for i = 1, #chain - 1 do
			local path = algorithms.aStar.run(chain[i], chain[i + 1], algorithms.aStar.wavyHeuristic, city.grid)
			if path then
				table.insert(paths, path)
			end
		end
	end
	self:postProcessRivers(city, paths)
end

local function generateSeeds(width, height)
	local zoneTypes = {
		{ type = "residential", frequency = 0.5 },
		{ type = "commercial", frequency = 0.45 },
		{ type = "industrial", frequency = 0.05 },
	}

	local radius = 8
	local rawPoints = poisson.sampleDefault(width, height, radius)

	local weightedList = {}
	for _, zone in ipairs(zoneTypes) do
		local count = math.floor(zone.frequency * 100)
		for i = 1, count do
			table.insert(weightedList, zone.type)
		end
	end

	local seeds = {}
	for i, pt in ipairs(rawPoints) do
		local zoneType = weightedList[math.random(#weightedList)]
		table.insert(seeds, {
			x = math.floor(pt.x),
			y = math.floor(pt.y),
			type = zoneType,
		})
	end

	return seeds
end

function Generator:generateCityZones(city)
	local seeds = generateSeeds(city.width, city.height)
	local zoneMap = voronoi.zones(city.width, city.height, seeds)

	self.seeds = seeds
	self.zoneMap = zoneMap

	for x = 1, city.width do
		for y = 1, city.height do
			local tile = city:GetTile(x, y)
			if tile.type == "empty" then
				city:SetTile(x, y, zoneMap[x][y])
			end
		end
	end
end

function Generator:generateRoads(city)
	local allowedRoadZones = {
		["residential"] = true,
		["commercial"] = true,
	}

	for x = 1, city.width do
		for y = 1, city.height do
			local curr_tile = city:GetTile(x, y)

			if allowedRoadZones[curr_tile.type] then
				local neighbors = {
					{ tile = city:GetTile(x, y - 1), x = x, y = y - 1 },
					{ tile = city:GetTile(x, y + 1), x = x, y = y + 1 },
					{ tile = city:GetTile(x - 1, y), x = x - 1, y = y },
					{ tile = city:GetTile(x + 1, y), x = x + 1, y = y },
				}

				for _, neighbor in ipairs(neighbors) do
					if
						neighbor.tile
						and allowedRoadZones[neighbor.tile.type]
						and neighbor.tile.type ~= curr_tile.type
					then
						city:SetTile(x, y, "mainRoad")
						city:SetTile(neighbor.x, neighbor.y, "mainRoad")
						break
					end
				end
			end
		end
	end
end

function Generator:generateRoadsAndBridges(city)
	local rawPoints1 = poisson.sampleGrid(city.width, city.height, 6, 0.5)
	local residentialRoads = voronoi.roads(city.width, city.height, rawPoints1)
	local rawPoints2 = poisson.sampleDefault(city.width, city.height, 5)
	local commercialRoads = voronoi.roads(city.width, city.height, rawPoints2)

	for _, road in ipairs(residentialRoads) do
		local x, y = road.x, road.y
		local currTile = city:GetTile(x, y)
		if currTile and self.zoneMap[x][y] and self.zoneMap[x][y] == "residential" then
			if currTile.type == "residential" then
				city:SetTile(x, y, "secondaryRoad")
			elseif currTile.type == "water" then
				city:SetTile(x, y, "secondaryRoad")
			end
		end
	end

	for _, road in ipairs(commercialRoads) do
		local x, y = road.x, road.y
		local currTile = city:GetTile(x, y)
		if currTile and self.zoneMap[x][y] and self.zoneMap[x][y] == "commercial" then
			if currTile.type == "commercial" then
				city:SetTile(x, y, "secondaryRoad")
			elseif currTile.type == "water" then
				city:SetTile(x, y, "secondaryRoad")
			end
		end
	end
end

function Generator:generateBuildings(city)
	local buildings = poisson.sampleGrid(city.width, city.height, 1.5, 0.0000001)

	for _, building in ipairs(buildings) do
		local x, y = math.floor(building.x), math.floor(building.y)
		city:SetTile(x, y, "defaultBuilding")
	end
end

return Generator
