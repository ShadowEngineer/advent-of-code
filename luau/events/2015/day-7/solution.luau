local fs = require("@lune/fs")
local text = require("../../../utilities/text")
local input = text.strip(fs.readFile("input.txt"))

type Instruction = {}

-- solution code...
local instructions = {}

local function decodeInstruction(line: string): Instruction
	-- either it's LARG OP RARG -> WIRE
	-- or it's NUMBER -> WIRE
	-- if we check for NUMBER first, we'll know if it's right
	local _, _, current, wire1 = line:find("^(%d+) %-> (%a+)$")
	if current then
		print(current, wire1)
	else
		local _, _, leftArg, operation, rightArg, wire2 = line:find("^(.+) (%u+) (.+) %-> (%a+)")
		print(leftArg, operation, rightArg, wire2)
	end
	return {}
end

for _, line in input:split("\n") do
	local instruction = decodeInstruction(line)
end

fs.writeFile("output-1.txt", "solution1")
fs.writeFile("output-2.txt", "solution2")
