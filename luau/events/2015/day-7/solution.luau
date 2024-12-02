local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local text = require("@utilities/text")
local input = text.strip(fs.readFile("input.txt"))

type Wire = string
type WireOrSignal = Wire | number
type InstructionBase = { line: string, value: number? }
type SignalKind = "signal"
type GateKind = "gate"
type ShiftKind = "shift"
type NotKind = "not"
type GateOperationName = "AND" | "OR"
type ShiftOperationName = "RSHIFT" | "LSHIFT"
type NotOperationName = "NOT"
type SignalToWire = InstructionBase & {
	kind: SignalKind,
	wire: Wire,
	signal: WireOrSignal,
}
type GateOperation = InstructionBase & {
	kind: GateKind,
	wire: Wire,
	operation: GateOperationName,
	argument: { left: WireOrSignal, right: WireOrSignal },
}
type ShiftOperation = InstructionBase & {
	kind: ShiftKind,
	wire: Wire,
	operation: ShiftOperationName,
	argument: { left: Wire, right: number },
}
type NotOperation = InstructionBase & {
	kind: NotKind,
	wire: Wire,
	operation: NotOperationName,
	argument: Wire,
}
type Instruction = SignalToWire | GateOperation | ShiftOperation | NotOperation

-- solution code...
local LOG = false
local regex = {
	signal = "^([%a%d]+) %-> (%a+)$",
	shift = "^(%a+) (%u+) (%d+) %-> (%a+)",
	negate = "^(NOT) (%a+) %-> (%a+)",
	gate = "^([%a%d]+) (%u+) ([%a%d]+) %-> (%a+)",
}
local function decodeInstruction(line: string): Instruction
	local matches = table.pack(line:find(regex.signal))
	if matches[3] ~= nil then
		local signalInstruction: SignalToWire = {
			line = line,
			kind = "signal" :: SignalKind, -- this is stupid, why is luau like this
			signal = if tonumber(matches[3]) then tonumber(matches[3]) :: number else matches[3] :: Wire,
			wire = matches[4] :: Wire,
		}
		return signalInstruction
	end

	matches = table.pack(line:find(regex.shift))
	if matches[3] ~= nil then
		local shiftInstruction: ShiftOperation = {
			line = line,
			kind = "shift" :: ShiftKind,
			wire = matches[6] :: Wire,
			operation = matches[4] :: ShiftOperationName,
			argument = { left = matches[3] :: Wire, right = tonumber(matches[5]) :: number },
		}
		return shiftInstruction
	end

	matches = table.pack(line:find(regex.negate))
	if matches[3] ~= nil then
		local notInstruction: NotOperation = {
			line = line,
			kind = "not" :: NotKind,
			wire = matches[5] :: Wire,
			operation = matches[3] :: NotOperationName,
			argument = matches[4] :: Wire,
		}
		return notInstruction
	end

	matches = table.pack(line:find(regex.gate))
	local gateInstruction: GateOperation = {
		line = line,
		kind = "gate" :: GateKind,
		wire = matches[6] :: Wire,
		operation = matches[4] :: GateOperationName,
		argument = {
			left = if tonumber(matches[3]) then tonumber(matches[3]) :: number else matches[3] :: Wire,
			right = if tonumber(matches[5]) then tonumber(matches[5]) :: number else matches[5] :: Wire,
		},
	}
	return gateInstruction
end

local wires = {}
for _, line in input:split("\n") do
	local instruction = decodeInstruction(text.strip(line))
	-- "Each wire can only get a signal from one source"
	-- in other words, this works because every wire only has one instruction that calculates its value
	wires[instruction.wire] = instruction
end

-- recursively solving from a
local function clampTo16Bits(number): number
	-- necessary since the library assumes 32-bit numbers instead of the given 16
	-- so we must erase the upper 16 bits
	return bit32.replace(number, 0, 16, 16)
end
local function calculateSignal(wire: Wire, level: number): number
	local function evaluateArgument(arg: WireOrSignal): number
		return if typeof(arg) == "string" then calculateSignal(arg, level + 1) else arg
	end

	if LOG then
		print(`{("  "):rep(level)}wire {stdio.color("red")}{wire}{stdio.color("reset")}`)
	end

	local instruction = wires[wire]
	if instruction.value then -- caching op
		return instruction.value
	end

	local valueToReturn
	if instruction.kind == "signal" then
		valueToReturn = evaluateArgument(instruction.signal)
	elseif instruction.kind == "shift" then
		local shiftOperation = bit32.rshift
		if instruction.operation == "LSHIFT" then
			shiftOperation = bit32.lshift
		end

		valueToReturn =
			shiftOperation(calculateSignal(instruction.argument.left, level + 1), instruction.argument.right)
	elseif instruction.kind == "not" then
		valueToReturn = bit32.bnot(calculateSignal(instruction.argument, level + 1))
	elseif instruction.kind == "gate" then
		local gateOperation = bit32.band
		if instruction.operation == "OR" then
			gateOperation = bit32.bor
		end

		local arg = instruction.argument
		local leftOperand = evaluateArgument(arg.left)
		local rightOperand = evaluateArgument(arg.right)

		valueToReturn = gateOperation(leftOperand, rightOperand)
	end

	if valueToReturn == nil then
		print(wire, instruction)
		error("we should never get here")
	end

	valueToReturn = clampTo16Bits(valueToReturn)

	-- caching
	if instruction.value == nil then
		(instruction :: InstructionBase).value = valueToReturn
	end

	return valueToReturn
end

for wire, instruction in wires do
	calculateSignal(wire, 0)
	if LOG then
		print(
			`{stdio.color("red")}{wire}{stdio.color("reset")}: {stdio.color("blue")}{instruction.value}{stdio.color(
				"reset"
			)}`
		)
	end
end
local signalAtWireA = calculateSignal("a", 0)
print(signalAtWireA)
fs.writeFile("output-1.txt", tostring(signalAtWireA))

for wire, instruction in wires do
	if wire == "b" then
		(instruction :: InstructionBase).value = signalAtWireA
	else
		(instruction :: InstructionBase).value = nil
	end
end

signalAtWireA = calculateSignal("a", 0)
print(signalAtWireA)
fs.writeFile("output-2.txt", tostring(signalAtWireA))
