local fs = require("@lune/fs")
local array = require("@utilities/array")
local input = fs.readFile("input.txt")

-- solution code...
local totalWrappingPaper = 0
local totalRibbon = 0
for _, line in input:split("\n") do
	if line:len() < 2 then -- for final newline ignorance
		continue
	end

	local components = line:split("x")
	local length = tonumber(components[1]) :: number
	local width = tonumber(components[2]) :: number
	local height = tonumber(components[3]) :: number

	-- ribbon
	local allSides = { length, width, height }

	local twoSmallestSides = array.removeValue(allSides, array.max(allSides))
	local ribbonToWrap = 2 * array.sum(twoSmallestSides)
	local ribbonForBow = array.product(allSides)
	totalRibbon += ribbonToWrap + ribbonForBow

	-- wrapping paper
	local side1 = length * width
	local side2 = width * height
	local side3 = height * length

	local smallestSideArea = array.min({ side1, side2, side3 })
	local boxSurfaceArea = 2 * (side1 + side2 + side3)
	local surfaceArea = smallestSideArea + boxSurfaceArea
	totalWrappingPaper += surfaceArea
end

fs.writeFile("output-1.txt", tostring(totalWrappingPaper))
fs.writeFile("output-2.txt", tostring(totalRibbon))
