local fs = require("@lune/fs")
local input = fs.readFile("input.txt")

-- solution code...
type Input = ">" | "^" | "v" | "<"
local taskMode: "one" | "two" = "two" -- which task you're solving
local houses = { ["0-0"] = 2 }
local santa = { x = 0, y = 0 }
local roboSanta = { x = 0, y = 0 }

local function coordToHouse(coordinate: { x: number, y: number }): string
	return `{coordinate.x}-{coordinate.y}`
end

-- building house grid from eggnog-infused elf radio calls
for index, direction: Input in (input:split("") :: any) :: { Input } do
	local agent = if taskMode == "two" and index % 2 == 0 then roboSanta else santa
	if direction == "<" then
		agent.x -= 1
	elseif direction == ">" then
		agent.x += 1
	elseif direction == "^" then
		agent.y += 1
	elseif direction == "v" then
		agent.y -= 1
	end

	local house = coordToHouse(agent)
	if houses[house] == nil then
		houses[house] = 1
	else
		houses[house] += 1
	end
end

-- finding how many houses were visited
local totalHousesWithMoreThan1 = 0
for _ in houses do
	totalHousesWithMoreThan1 += 1
end
fs.writeFile(`output-{if taskMode == "one" then 1 else 2}.txt`, tostring(totalHousesWithMoreThan1))
