--!strict
local fs = require("@lune/fs")
local text = require("@utilities/text")
local array = require("@utilities/array")
local input = text.strip(fs.readFile("input.txt"))

-- solution code...
type InstructionBase = {
	index: number,
	text: string,
}
type MultiplicationInstruction = InstructionBase & {
	kind: "mul",
	operands: {
		x: number,
		y: number,
	},
}
type ToggleInstruction = InstructionBase & {
	kind: "toggle",
	enabled: boolean,
}
type Instruction = MultiplicationInstruction | ToggleInstruction
local regex = {
	multiplication = "mul%(%d+,%d+%)",
	toggleOn = "do()",
	toggleOff = "don't()",
}
local instructions: { Instruction } = {}
local totalInput = ""
for _, line in input:split("\n") do
	totalInput ..= line
end

local function findInstructionFrom<T>(
	textInput: string,
	pattern: string,
	plain: boolean,
	startPosition: number,
	mapper: (start: number, stop: number) -> T
): (T?, number?)
	local start, stop

	start, stop = textInput:find(pattern, startPosition, plain)
	if start and stop then
		return mapper(start, stop), stop
	end
	return
end

local function findInstructions<T>(pattern: string, plain: boolean, mapper: (start: number, stop: number) -> T)
	local parsedInstruction, searchStartIndex: number? = nil, 1
	repeat
		parsedInstruction, searchStartIndex =
			findInstructionFrom(totalInput, pattern, plain, searchStartIndex :: number, mapper)
		if parsedInstruction then
			table.insert(instructions, (parsedInstruction :: unknown) :: Instruction)
		end
	until parsedInstruction == nil
end

local function getSumOfProducts(multiplicationInstructions: { MultiplicationInstruction }): number
	return array.sum(array.crossProduct(
		array.map(multiplicationInstructions, function(i)
			return i.operands.x
		end),
		array.map(multiplicationInstructions, function(i)
			return i.operands.y
		end)
	))
end

findInstructions(regex.multiplication, false, function(start, stop)
	local raw = totalInput:sub(start, stop)
	local _, _, x, y = raw:find("(%d+),(%d+)")
	local instruction: MultiplicationInstruction = {
		kind = "mul" :: "mul",
		text = raw,
		index = start,
		operands = {
			x = tonumber(x) :: number,
			y = tonumber(y) :: number,
		},
	}
	return instruction, stop
end)
findInstructions(regex.toggleOn, true, function(start, stop)
	local instruction: ToggleInstruction =
		{ kind = "toggle" :: "toggle", text = totalInput:sub(start, stop), index = start, enabled = true }
	return instruction, stop
end)
findInstructions(regex.toggleOff, true, function(start, stop)
	local instruction: ToggleInstruction =
		{ kind = "toggle" :: "toggle", text = totalInput:sub(start, stop), index = start, enabled = false }
	return instruction, stop
end)

table.sort(instructions, function(i1, i2)
	return i1.index < i2.index
end)

local justMultiplicationInstructions = array.filter(instructions, function(i)
	return (i :: any).operands ~= nil
end) :: { MultiplicationInstruction }

local sumOfProducts = getSumOfProducts(justMultiplicationInstructions)
print(sumOfProducts)

fs.writeFile("output-1.txt", tostring(sumOfProducts))

local enabled = true
local filteredInstructions = {}
for _, instruction in instructions do
	if instruction.kind == "toggle" then
		enabled = instruction.enabled
	elseif instruction.kind == "mul" and enabled then
		table.insert(filteredInstructions, instruction :: MultiplicationInstruction)
	end
end

local sumOfFilteredProducts = getSumOfProducts(filteredInstructions)
print(sumOfFilteredProducts)

fs.writeFile("output-2.txt", tostring(sumOfFilteredProducts))
