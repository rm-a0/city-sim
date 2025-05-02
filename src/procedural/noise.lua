-- procedural/noise.lua
local noise = {}

-- Gradient vectors (8 directions)
local grad_vectors = {
    {1,1}, {-1,1}, {1,-1}, {-1,-1},
    {1,0}, {-1,0}, {0,1}, {0,-1}
}

-- Fade function (smootherstep)
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

-- Linear interpolation
local function lerp(a, b, t)
    return a + t * (b - a)
end

-- Dot product of gradient vector with offset
local function grad(hash, x, y)
    local g = grad_vectors[(hash % #grad_vectors) + 1]
    return g[1] * x + g[2] * y
end

-- Permutation table
local perm = {}
do
    local p = {}
    for i = 0, 255 do p[i] = i end

    math.randomseed(42)
    for i = 255, 1, -1 do
        local j = math.random(i)
        p[i], p[j] = p[j], p[i]
    end

    for i = 0, 255 do
        perm[i] = p[i]
        perm[i + 256] = p[i]
    end
end

-- Hash function
local function hash(x, y)
    return perm[(perm[x % 256] + y) % 256]
end

-- Core Perlin noise
function noise.perlin(x, y)
    local x0 = math.floor(x)
    local y0 = math.floor(y)
    local x_rel = x - x0
    local y_rel = y - y0

    local u = fade(x_rel)
    local v = fade(y_rel)

    local aa = hash(x0, y0)
    local ab = hash(x0, y0 + 1)
    local ba = hash(x0 + 1, y0)
    local bb = hash(x0 + 1, y0 + 1)

    local grad_aa = grad(aa, x_rel, y_rel)
    local grad_ba = grad(ba, x_rel - 1, y_rel)
    local grad_ab = grad(ab, x_rel, y_rel - 1)
    local grad_bb = grad(bb, x_rel - 1, y_rel - 1)

    local lerp_x1 = lerp(grad_aa, grad_ba, u)
    local lerp_x2 = lerp(grad_ab, grad_bb, u)

    return lerp(lerp_x1, lerp_x2, v)
end

return noise