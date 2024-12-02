local fs = require("@lune/fs")
local input = fs.readFile("input.txt")

-- solution code...
local text = require("@utilities/text")
local dictionary = require("@utilities/dictionary")
local vowels = { "a", "e", "i", "o", "u" }
local invalidStrings = { "ab", "cd", "pq", "xy" }
local function isNice(line: string): boolean
	-- vowel check
	local numberOfVowels = dictionary.sum(text.countAnyCharactersOf(line, vowels))
	if numberOfVowels < 3 then
		return false
	end

	-- twice-letter check
	local twoLettersInARow = false
	local characters = line:split("")
	for index = 1, line:len() - 1, 1 do
		if characters[index] == characters[index + 1] then
			twoLettersInARow = true
			break
		end
	end

	if twoLettersInARow == false then
		return false
	end

	-- non-string check
	local invalidSum = dictionary.sum(text.countAnyTokensOf(line, invalidStrings))
	if invalidSum > 0 then
		return false
	end

	return true
end

local numberOfNiceStrings = 0
for _, line in text.strip(input):split("\n") do
	if isNice(line) then
		numberOfNiceStrings += 1
	end
end

print(numberOfNiceStrings)
fs.writeFile("output-1.txt", tostring(numberOfNiceStrings))

local function isNice2(line: string): boolean
	-- pair check
	local twoPairs = false
	local characters = line:split("")
	for index = 1, line:len() - 1, 1 do
		local pair = characters[index] .. characters[index + 1]
		for checkIndex = index + 2, line:len() - 1, 1 do
			local checkPair = characters[checkIndex] .. characters[checkIndex + 1]
			if pair == checkPair then
				twoPairs = true
				break
			end
		end

		if twoPairs then
			break
		end
	end

	if not twoPairs then
		return false
	end

	-- symmetric repeat check
	local symmetricCheck = false
	for index = 1, line:len() - 2, 1 do
		local firstCharacter = characters[index]
		local thirdCharacter = characters[index + 2]

		if thirdCharacter == firstCharacter then
			symmetricCheck = true
			break
		end
	end

	return symmetricCheck
end

local numberOfMoreNiceStrings = 0
for _, line in text.strip(input):split("\n") do
	if isNice2(line) then
		numberOfMoreNiceStrings += 1
	end
end
print(numberOfMoreNiceStrings)
fs.writeFile("output-2.txt", tostring(numberOfMoreNiceStrings))
