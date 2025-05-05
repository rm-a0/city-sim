-- utils/algorithm.lua
local floodFill = require("utils.algorithms.floodFill")
local aStar = require("utils.algorithms.aStar")

local algorithms = {}

algorithms.floodFill = floodFill
algorithms.aStar = aStar

return algorithms