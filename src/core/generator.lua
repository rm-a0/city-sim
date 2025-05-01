-- core/generator.lua
local Generator = {}
Generator.__index = Generator

function Generator.new()
    return setmetatable({}, Generator)
end

function Generator:generateLayerOne(city)
    print("TODO")
end

function Generator:generateLayerTwo(city)
    
end

return Generator