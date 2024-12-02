--!strict
local fs = require("@lune/fs")
local text = require("@utilities/text")
local array = require("@utilities/array")

local input = text.strip(fs.readFile("input.txt"))

-- solution code...
local leftList: { number } = {}
local rightList: { number } = {}
for _, line in input:split("\n") do
	local _, _, leftPart, rightPart = line:find("(%d+)%s+(%d+)")
	local left = tonumber(leftPart) :: number
	local right = tonumber(rightPart) :: number
	table.insert(leftList, left)
	table.insert(rightList, right)
end

-- sort both lists
local sortAscending = function(one: number, two: number): boolean
	return one < two
end
table.sort(leftList, sortAscending)
table.sort(rightList, sortAscending)

local differences = array.map(leftList, function(leftValue, index)
	return math.abs(leftValue - rightList[index])
end)
local sumOfDifferences = array.sum(differences)
print(sumOfDifferences)

fs.writeFile("output-1.txt", tostring(sumOfDifferences))

local occurrencesInRight = {}
array.map(rightList, function(value: number, _index: number)
	if occurrencesInRight[value] == nil then
		occurrencesInRight[value] = 0
	end
	occurrencesInRight[value] += 1
	return value
end)

local similarity = array.sum(array.map(leftList, function(value: number, _index: number)
	return value * (if occurrencesInRight[value] then occurrencesInRight[value] else 0)
end))
print(similarity)

fs.writeFile("output-2.txt", tostring(similarity))
