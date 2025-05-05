-- utils/algorithms/aStar.lua
local noise = require("procedural.noise")
local aStar = {}

function aStar.wavyHeuristic(a, b)
    local dx = math.abs(a.x - b.x)
    local dy = math.abs(a.y - b.y)
    local base = dx + dy

    local noiseVal = noise.perlin(a.x * 0.1, a.y * 0.1) * 10  -- scale up impact
    return base + noiseVal
end

function aStar.manhattan(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y)
end

function aStar.run(start, goal, heuristic, grid)
    local open = {start}
    local closed = {}
    local cameFrom = {}

    local gScore = {}
    local fScore = {}

    local function nodeKey(n) return n.x .. "," .. n.y end

    local function initScores()
        for x = 1, #grid do
            for y = 1, #grid[1] do
                local key = x .. "," .. y
                gScore[key] = math.huge
                fScore[key] = math.huge
            end
        end
    end

    local function getLowestF()
        local lowest = nil
        for _, node in ipairs(open) do
            if lowest == nil or fScore[nodeKey(node)] < fScore[nodeKey(lowest)] then
                lowest = node
            end
        end
        return lowest
    end

    local function reconstructPath(current)
        local path = {current}
        while cameFrom[nodeKey(current)] do
            current = cameFrom[nodeKey(current)]
            table.insert(path, 1, current)
        end
        return path
    end

    local function removeFromOpen(dNode)
        for i, node in ipairs(open) do
            if node.x == dNode.x and node.y == dNode.y then
                table.remove(open, i)
                break
            end
        end
    end

    local function isGoal(node) return node.x == goal.x and node.y == goal.y end

    local function checkNeighbors(node)
        local neighbors = {
            {x=node.x+1, y=node.y},
            {x=node.x-1, y=node.y},
            {x=node.x, y=node.y+1},
            {x=node.x, y=node.y-1},
        }

        for _, neighbor in ipairs(neighbors) do
            if grid[neighbor.x] and grid[neighbor.x][neighbor.y] then
                local key = nodeKey(neighbor)
                if closed[key] then goto continue end
                local tenativeG = gScore[nodeKey(node)] + 1
                if tenativeG < gScore[key] then
                    cameFrom[key] = node
                    gScore[key] = tenativeG
                    fScore[key] = tenativeG + heuristic(neighbor, goal)

                    local inOpen = false
                    for _, n in ipairs(open) do
                        if n.x == neighbor.x and n.y == neighbor.y then
                            inOpen = true
                            break
                        end
                    end

                    if not inOpen then
                        table.insert(open, neighbor)
                    end
                end
            end
            ::continue::
        end
    end

    initScores()
    gScore[nodeKey(start)] = 0
    fScore[nodeKey(start)] = heuristic(start, goal)

    while #open > 0 do
        local current = getLowestF()

        if isGoal(current) then
            return reconstructPath(current)
        end

        removeFromOpen(current)
        closed[nodeKey(current)] = true
        checkNeighbors(current)
    end

    return nil
end

return aStar