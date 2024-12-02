--!strict
local fs = require("@lune/fs")
local text = require("@utilities/text")
local graph = require("@utilities/graph")
local array = require("@utilities/array")
local dictionary = require("@utilities/dictionary")
local input = text.strip(fs.readFile("input.txt"))

type City = string

-- solution code...
local LOG = false
local cities = graph.new()
for _, line in input:split("\n") do
	local _, _, fromCity, toCity, distance = line:find("(%a+) to (%a+) = (%d+)")
	if not cities:HasNode(fromCity) then
		cities:AddNode(fromCity)
	end

	if not cities:HasNode(toCity) then
		cities:AddNode(toCity)
	end

	cities:ConnectNodesBothWays(fromCity, toCity, tonumber(distance))
end

if LOG then
	for city, vertex in cities.Vertices do
		print(`{city}:`)
		for edge, data in vertex.Edges do
			print(`    {edge}: {data.Direction} | {data.Weight}`)
		end
	end
end

-- every city is connected to every other city
-- there are 8 cities, with 7 connections each
-- therefore there will be 8 * 7 * 6 * 5... 8! = 40,320 possible paths
-- however since paths are all bidirectional, you could cut that in half, since each path will have a duplicate path going the other way
-- this is travelling salesman problem (NP hard), but modified so that you *don't* have to finish where you started
print(cities)

local function getReducerFunction(kind: "min" | "max"): typeof(array.minValue) -- same as array.maxValue
	return (if kind == "min" then array.minValue else array.maxValue) :: typeof(array.minValue)
end

local function depthFirstSearchPath(
	kind: "min" | "max",
	currentCity: City,
	currentPathLength: number,
	currentPath: { City },
	leftToExplore: { City }
): (number, { City })
	if #leftToExplore == 1 then
		local finalCity = leftToExplore[1]
		return currentPathLength + cities.Vertices[currentCity].Edges[finalCity].Weight :: number,
			array.append(currentPath, finalCity)
	end

	local reducerFunction = getReducerFunction(kind)

	local minimumPath = reducerFunction(
		array.map(leftToExplore, function(city)
			local distance, path = depthFirstSearchPath(
				kind,
				city,
				currentPathLength + cities.Vertices[currentCity].Edges[city].Weight :: number,
				array.append(currentPath, city),
				array.removeValue(leftToExplore, city)
			)

			return {
				distance = distance,
				path = path,
			}
		end),
		function(item)
			return item.distance
		end
	)

	return minimumPath.distance, minimumPath.path
end

local function findPath(kind: "min" | "max")
	local paths: { [City]: { length: number, path: { City } } } = {}
	for city in cities do
		local length, path =
			depthFirstSearchPath(kind, city, 0, { city }, array.removeValue(dictionary.keys(cities.Vertices), city))
		paths[city] = { length = length, path = path }
	end

	local path = getReducerFunction(kind)(dictionary.values(paths), function(item)
		return item.length
	end)
	return path
end

local shortestPath = findPath("min")
print(shortestPath)
fs.writeFile("output-1.txt", tostring(shortestPath.length))

local longestPath = findPath("max")
print(longestPath)
fs.writeFile("output-2.txt", tostring(longestPath.length))
