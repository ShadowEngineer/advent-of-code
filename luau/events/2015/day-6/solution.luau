local fs = require("@lune/fs")

local text = require("@utilities/text")
local vector = require("@utilities/vector")
local grid = require("@utilities/grid")

local input = fs.readFile("input.txt")

type Point = vector.Vector2D<number>
type Command = "turn on" | "turn off" | "toggle"

-- solution code...
input = text.strip(input)
local houseLights = grid.new({ x = 1000, y = 1000 })

for _, line in input:split("\n") do
	local _, _, commandString, startX, startY, stopX, stopY = line:find("(.+) (%d+),(%d+) through (%d+),(%d+)")
	local command: Command = commandString :: Command
	local start: Point = { x = tonumber(startX) :: number + 1, y = tonumber(startY) :: number + 1 }
	local stop: Point = { x = tonumber(stopX) :: number + 1, y = tonumber(stopY) :: number + 1 }

	if command == "turn on" then
		houseLights:SetRange(start, stop, function(oldValue: number?)
			return if oldValue then oldValue + 1 else 1
		end)
	elseif command == "turn off" then
		houseLights:SetRange(start, stop, function(oldValue: number?)
			return math.max(if oldValue then oldValue - 1 else 0, 0)
		end)
	else
		houseLights:SetRange(start, stop, function(oldValue: number?)
			return if oldValue then oldValue + 2 else 2
		end)
	end
end

local numberOfLightsTurnedOn = 0
local totalBrightness = 0
for x = 1, 1000, 1 do
	for y = 1, 1000, 1 do
		local rowExists = houseLights._grid[x] ~= nil
		local cellValue = if rowExists then houseLights._grid[x][y] else nil
		local cellExists = cellValue ~= nil
		if rowExists and cellExists and cellValue > 0 then
			numberOfLightsTurnedOn += 1 -- not correct, turn these into booleans to get answer to 1st question
			totalBrightness += houseLights._grid[x][y]
		end
	end
end

fs.writeFile("output-1.txt", tostring(numberOfLightsTurnedOn))
fs.writeFile("output-2.txt", tostring(totalBrightness))
