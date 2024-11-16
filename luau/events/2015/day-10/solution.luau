--!strict
local fs = require("@lune/fs")
local text = require("../../../utilities/text")
local array = require("../../../utilities/array")
local input = text.strip(fs.readFile("input.txt"))

type Token = { character: string, quantity: number }
type Encoding = { Token }

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

--[=[
	# steps
	1. for every entry
	2. generate a new entry with the CHARACTER set to the QUANTITY of the entry, and QUANTITY set to 1
	3. place it before the entry, setting the entry's quantity to 1
	4. iterate through again, and merge together adjacent entries with the same character, summing their quantities

	every time, the list length doubles at first, and then gets reduced by some small amount with the merges
	# case analysis
	let's practice encoding the simple case:
	- 1 encoded is
	```
	{{
		character: "1",
		quantity: 1
	}}
	```
	- which turns into 11, encoded is:
	```
	{{
		character: "1",
		quantity: 2
	}}
	```
	- which turns into 21, encoded is:
	```
	{
		{
			character: "2",
			quantity: 1
		},
		{
			character: "1",
			quantity: 1
		}
	}
	```
	- which turns into 1211, encoded is:
	```
	{
		{
			character: "1",
			quantity: 1
		},
		{
			character: "2",
			quantity: 1
		},
		{
			character: "1",
			quantity: 2
		}
	}
	```
]=]
local function iterateEncodingSmartly(encoding: Encoding): Encoding
	-- generating new tokens (duoubling array)
	local newEncoding: Encoding = {}
	for _, token in encoding do
		local newToken: Token = {
			character = tostring(token.quantity),
			quantity = 1,
		}
		local existingToken: Token = {
			character = token.character,
			quantity = 1,
		}
		table.insert(newEncoding, newToken)
		table.insert(newEncoding, existingToken)
	end

	-- removing duplicates
	if #newEncoding > 1 then
		local removed = 0
		local current = newEncoding[1]
		for index = 2, #newEncoding - removed, 1 do
			index = index - removed
			local token = newEncoding[index]
			if token == nil then
				break
			end

			if token.character == current.character then
				removed += 1
				current.quantity += (table.remove(newEncoding, index) :: Token).quantity
			else
				current = token
			end
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

local SKIP_FIRST_PART = true
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

iterations = 1
encoding = encode("312211322212221121123222112")
print(encoding)
for iteration = 1, iterations, 1 do
	local startTime = os.clock()
	print(`Iteration: {iteration}`)
	encoding = iterateEncodingSmartly(encoding)
	local difference = os.clock() - startTime
	print(
		`took {("%.3f"):format(difference)} seconds. Estimated {("%.3f"):format(difference * 1.303577269)}s for the next iteration`
	)
end
encodingSize = getEncodingLength(encoding)
fs.writeFile("output-2.txt", tostring(encodingSize))
