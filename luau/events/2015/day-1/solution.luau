local fs = require("@lune/fs")
local input = fs.readFile("input.txt")

-- solution code...
local sum = 0
local basementLevel
for index, character in input:split("") do
	if character == "(" then
		sum += 1
	elseif character == ")" then
		sum -= 1
	end

	if sum == -1 and basementLevel == nil then
		basementLevel = index
	end
end
fs.writeFile("output-1.txt", tostring(sum))
fs.writeFile("output-2.txt", tostring(basementLevel))
