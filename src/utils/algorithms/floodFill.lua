-- utils/algorithms/floodFill.lua
local function floodFill(points, width, height)
    local visited = {}
    local groups = {}

    local function key(x, y) return x .. "," .. y end

    local pointMap = {}
    for _, pt in ipairs(points) do
        pointMap[key(pt.x, pt.y)] = true
    end

    for _, pt in ipairs(points) do
        local k = key(pt.x, pt.y)
        if not visited[k] then
            local group = {}
            local queue = {pt}
            visited[k] = true

            while #queue > 0 do
                local current = table.remove(queue)
                table.insert(group, current)

                for _, dir in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
                    local nx, ny = current.x + dir[1], current.y + dir[2]
                    local nk = key(nx, ny)
                    if pointMap[nk] and not visited[nk] then
                        visited[nk] = true
                        table.insert(queue, {x = nx, y = ny})
                    end
                end
            end

            table.insert(groups, group)
        end
    end

    return groups
end

return floodFill