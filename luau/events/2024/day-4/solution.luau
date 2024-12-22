--!strict
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")

local text = require("@utilities/text")
local grid = require("@utilities/grid")
local array = require("@utilities/array")
local vector = require("@utilities/vector")
local input = text.strip(fs.readFile("input.txt"))

-- solution code...
local wordGrid = grid.fromTextLines(input)
local wordGridDebug = grid.fromTextLines(input)
local targetWord = "XMAS"
local wordLength = targetWord:len()
local offset = wordLength - 1

local numberOfMatches = 0
for x, y, _value in wordGrid do
	local at = { x = x, y = y }
	local atRight = { x = x + offset, y = y }
	local atDown = { x = x, y = y + offset }
	local atDiagonal = { x = x + offset, y = y + offset }

	local inXBounds = x <= wordGrid.Size.x - offset
	local inYBounds = y <= wordGrid.Size.y - offset

	local matches: { { position: vector.Vector2D_N, direction: vector.Direction, match: string } } = {}

	if inXBounds then
		table.insert(
			matches,
			{ position = at, direction = "East", match = text.join(wordGrid:GetLine(at, "East", wordLength)) }
		)
		table.insert(
			matches,
			{ position = atRight, direction = "West", match = text.join(wordGrid:GetLine(atRight, "West", wordLength)) }
		)
	end

	if inYBounds then
		table.insert(
			matches,
			{ position = at, direction = "South", match = text.join(wordGrid:GetLine(at, "South", wordLength)) }
		)
		table.insert(
			matches,
			{ position = atDown, direction = "North", match = text.join(wordGrid:GetLine(atDown, "North", wordLength)) }
		)
	end

	if inXBounds and inYBounds then
		table.insert(
			matches,
			{ position = at, direction = "SouthEast", match = text.join(wordGrid:GetLine(at, "SouthEast", wordLength)) }
		)
		table.insert(matches, {
			position = atRight,
			direction = "SouthWest",
			match = text.join(wordGrid:GetLine(atRight, "SouthWest", wordLength)),
		})
		table.insert(matches, {
			position = atDown,
			direction = "NorthEast",
			match = text.join(wordGrid:GetLine(atDown, "NorthEast", wordLength)),
		})
		table.insert(matches, {
			position = atDiagonal,
			direction = "NorthWest",
			match = text.join(wordGrid:GetLine(atDiagonal, "NorthWest", wordLength)),
		})
	end

	numberOfMatches += #array.filter(matches, function(test, _index)
		if test.match == targetWord then
			wordGridDebug:Set(
				test.position,
				stdio.color("green") .. (wordGridDebug:Get(test.position) :: string) .. stdio.color("reset")
			)
			return true
		end

		return false
	end)
end

print(wordGridDebug)
print(numberOfMatches)

fs.writeFile("output-1.txt", tostring(numberOfMatches))
fs.writeFile("output-2.txt", "solution2")
