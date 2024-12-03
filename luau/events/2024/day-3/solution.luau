--!strict
local fs = require("@lune/fs")
local text = require("@utilities/text")
local array = require("@utilities/array")
local input = text.strip(fs.readFile("input.txt"))

-- solution code...
local leftOperands = {}
local rightOperands = {}
for _, line in input:split("\n") do
	for instruction in line:gmatch("mul%(%d+,%d+%)") do
		local _, _, x, y = instruction:find("(%d+),(%d+)")
		table.insert(leftOperands, tonumber(x) :: number)
		table.insert(rightOperands, tonumber(y) :: number)
	end
end

local sumOfProducts = array.sum(array.crossProduct(leftOperands, rightOperands))
print(sumOfProducts)

fs.writeFile("output-1.txt", tostring(sumOfProducts))
fs.writeFile("output-2.txt", "solution2")
