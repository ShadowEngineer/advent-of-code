local fs = require("@lune/fs")
local text = require("../../../utilities/text")
local input = text.strip(fs.readFile("input.txt"))

-- solution code...
local pattern = {
	hex = "\\x%x%x",
	doubleQuote = '\\"',
	doubleBackSlash = "\\\\",
}
local LOG = false

local totalCodeCharacters = 0
local totalMemoryCharacters = 0
for _, line in input:split("\n") do
	line = text.strip(line)
	local codeCharacters = line:len()
	-- double quotes before double backslashes
	local memoryCharacters = line:gsub(pattern.hex, "~")
		:gsub(pattern.doubleQuote, '"')
		:gsub(pattern.doubleBackSlash, "\\")
		:len() - 2 -- for the extra quotes on the ends
	if LOG then
		print(
			("%02d - %02d = %02d: [%s]"):format(
				codeCharacters,
				memoryCharacters,
				codeCharacters - memoryCharacters,
				line
			)
		)
	end

	totalCodeCharacters += codeCharacters
	totalMemoryCharacters += memoryCharacters
end
local totalDifference = totalCodeCharacters - totalMemoryCharacters
print(totalDifference)
fs.writeFile("output-1.txt", totalDifference)
fs.writeFile("output-2.txt", "solution2")
