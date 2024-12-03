--!strict
local fs = require("@lune/fs")
local text = require("@utilities/text")
local array = require("@utilities/array")
local operations = require("@utilities/operations")
local input = text.strip(fs.readFile("input.txt"))

-- solution code...
type Reading = { number }
local function isSafe(reading: Reading): boolean
	local differences = {}
	for index = 2, #reading do
		local lastValue = reading[index - 1]
		local thisValue = reading[index]
		table.insert(differences, lastValue - thisValue)
	end

	local positiveDifferences = math.abs(array.sum(array.map(differences, math.sign)))
	if positiveDifferences ~= #differences then
		return false
	end

	local outOfBoundsDifferences = array.filter(differences, function(value)
		return math.abs(value) < 1 or math.abs(value) > 3
	end)

	if #outOfBoundsDifferences > 0 then
		return false
	end

	return true
end

local function isSafeWithProblemDampener(reading: Reading): (boolean, { number })
	if isSafe(reading) then
		return true, {}
	end

	local toleratedResults = array.map(reading, function(_value, index)
		return isSafe(array.removeIndex(reading, index))
	end)
	local toleratedSafe = array.contains(toleratedResults, true)
	local badResults = array.filter(reading, function(_value, index)
		return toleratedResults[index]
	end)
	return toleratedSafe, badResults
end

local safeReadings = array.map(input:split("\n"), function(report)
	local reading = array.map(report:split(" "), operations.Map.toNumber) :: Reading
	local dampenedSafe, badValues = isSafeWithProblemDampener(reading)
	return {
		report = report,
		safe = isSafe(reading),
		dampenedSafe = dampenedSafe,
		badValues = badValues,
	}
end)

local numberOfSafeReadings = #array.filter(safeReadings, function(entry)
	return entry.safe
end)

print(numberOfSafeReadings)

fs.writeFile("output-1.txt", tostring(numberOfSafeReadings))

local numberOfDampenedSafeReadings = #array.filter(safeReadings, function(entry)
	return entry.dampenedSafe
end)

print(numberOfDampenedSafeReadings)

fs.writeFile("output-2.txt", tostring(numberOfDampenedSafeReadings))
