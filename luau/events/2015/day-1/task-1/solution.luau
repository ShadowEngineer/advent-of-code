local fs = require("@lune/fs")
local input = fs.readFile("events/2015/day-1/input.txt")

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
fs.writeFile("events/2015/day-1/task-1/output.txt", tostring(sum))
fs.writeFile("events/2015/day-1/task-2/output.txt", tostring(basementLevel))
