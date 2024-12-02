--!strict
local fs = require("@lune/fs")
local text = require("@utilities/text")
local array = require("@utilities/array")
local elements = require("elements")
local input = text.strip(fs.readFile("input.txt"))

type Token = { character: string, quantity: number }
type Encoding = { Token }

type Element = string
type ElementEncoding = { Element }

-- solution code...
local function encode(sequence: string): Encoding
	local encoding: Encoding = {}
	local characters = sequence:split("")
	local current = characters[1]
	local repeats = 1
	for index = 2, #characters + 1, 1 do -- +1 so that we'd get nil at the end, and a "commit" into the encoding
		local character = characters[index]
		if current ~= character then
			table.insert(encoding, {
				character = current,
				quantity = repeats,
			})
			current = character
			repeats = 1
		else
			repeats += 1
		end
	end
	return encoding
end

local function decode(encoding: Encoding): string
	local result = ""
	for _, token in encoding do
		result ..= token.character:rep(token.quantity)
	end
	return result
end

local function iterateEncoding(encoding: Encoding): Encoding
	-- brute-forced, bad part 1 solution
	local result = ""
	for _, token in encoding do
		result ..= token.quantity .. token.character
	end
	return encode(result)
end

local function getElementEncodingLength(encoding: ElementEncoding): number
	local length = 0
	for _, element in encoding do
		length += elements.Elements[element].text:len()
	end
	return length
end

local function decodeElementFromText(str: string): ElementEncoding
	return { elements.ByText[str] }
end

local function iterateEncodingSmartly(encoding: ElementEncoding): ElementEncoding
	local newEncoding: ElementEncoding = {}
	for _, element in encoding do
		for _, mappedElement in elements.Elements[element].mapping do
			table.insert(newEncoding, mappedElement)
		end
	end
	return newEncoding
end

local function getEncodingLength(encoding: Encoding): number
	return array.sum(array.map(encoding, function(token)
		return token.quantity
	end))
end

print(input)

local SKIP_FIRST_PART = false
local iterations = 40
local encoding = encode(input)
local encodingSize = 0
if not SKIP_FIRST_PART then
	for iteration = 1, iterations, 1 do
		print(`Iteration: {iteration}`)
		encoding = iterateEncoding(encoding)
	end

	encodingSize = getEncodingLength(encoding)
	print(encodingSize)

	fs.writeFile("output-1.txt", tostring(encodingSize))
end

iterations = 50
local elementEncoding = decodeElementFromText(input)
print(elementEncoding)
for iteration = 1, iterations, 1 do
	print(`Iteration: {iteration}`)
	elementEncoding = iterateEncodingSmartly(elementEncoding)
end
encodingSize = getElementEncodingLength(elementEncoding)
print(encodingSize)
fs.writeFile("output-2.txt", tostring(encodingSize))
