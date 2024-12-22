--!strict
local stdio = require("@lune/stdio")
local vector = require("vector")
local text = require("text")

type Dimension = vector.Vector2D<number>
type SetFunction<T> = (oldValue: T) -> T
type SetValue<T> = T | SetFunction<T>

type GridObj<T> = {
	--[=[
		Size of the grid.
		Values cannot be set outside this range.
	]=]
	Size: Dimension,
	_grid: { { T } },
}
type GridImpl = {
	Set: <T>(self: Grid, point: Dimension, value: SetValue<T>) -> (),
	SetRange: <T>(self: Grid, from: Dimension, to: Dimension, value: SetValue<T>) -> (),
	Get: <T>(self: Grid, from: Dimension) -> T,
	GetLine: <T>(self: Grid, from: Dimension, dimension: vector.Direction, length: number) -> { T },
	--[=[
		@private
		Sets a point without checks, used internally.
	]=]
	_set: <T>(self: Grid, point: Dimension, value: SetValue<T>) -> (),
	--[=[
		@private
		Sets a whole rectangular range of points to the given value.
	]=]
	_setRange: <T>(self: Grid, from: Dimension, to: Dimension, value: SetValue<T>) -> (),
	_get: <T>(self: Grid, from: Dimension) -> T,
	__index: GridImpl,
	__tostring: (self: Grid) -> string,
	__iter: (self: Grid) -> () -> (number?, number?, any?),
}
export type Grid = typeof(setmetatable({} :: GridObj<any>, {} :: GridImpl))

local function validateDimension(dimension: Dimension, max: Dimension)
	assert(dimension.x > 0 and dimension.x <= max.x, `given X {dimension.x} is out of bounds ({max.x})`)
	assert(dimension.y > 0 and dimension.y <= max.y, `given Y {dimension.y} is out of bounds ({max.y})`)
end

local Grid = {}
Grid.__index = Grid
Grid.__tostring = function(self: Grid): string
	local output = `Grid[{self.Size.x},{self.Size.y}]\n`

	local function formatGridValue(value: any): string
		if typeof(value) == "boolean" then
			return `{stdio.color("purple")}{if value then "T" else "F"}{stdio.color("reset")}`
		else
			return tostring(value)
		end
	end

	for _y, row in self._grid do
		for _x, value in row do
			output ..= formatGridValue(value)
		end
		output ..= "\n"
	end

	return output
end
Grid.__iter = function(self: Grid)
	local index = 0
	return function(): (number?, number?, any?)
		if index >= self.Size.x * self.Size.y then
			return
		end

		local x = (index % self.Size.x) + 1
		local y = math.floor(index / self.Size.y) + 1

		index += 1

		return x, y, self._grid[y][x]
	end
end

function Grid.new(size: Dimension): Grid
	return setmetatable({
		_grid = {},
		Size = size,
	}, Grid)
end

function Grid.from2DArray<T>(gridLikeArray: { { T } }): Grid
	-- validating that all the lines are the same length
	local establishedLength
	for y, row in gridLikeArray do
		if establishedLength == nil then
			establishedLength = #row
			continue
		end

		assert(establishedLength == #row, `row lengths <{establishedLength}> from 1 and <{#row}> from {y} do not match`)
	end

	return setmetatable({
		_grid = gridLikeArray,
		Size = { x = establishedLength, y = #gridLikeArray },
	}, Grid)
end

function Grid.fromTextLines(textLines: string): Grid
	local lines = text.strip(textLines):split("\n")

	local characters: { { string } } = {}
	for row, line in lines do
		characters[row] = {}
		for _, character in text.strip(line):split("") do
			table.insert(characters[row], character)
		end
	end

	return Grid.from2DArray(characters)
end

function Grid:Set<T>(point: Dimension, value: SetValue<T>)
	validateDimension(point, self.Size)
	self:_set(point, value)
end

function Grid:_set<T>(point: Dimension, valueToSet: SetValue<T>)
	if self._grid[point.y] == nil then
		rawset(self._grid, point.y, {})
	end

	if typeof(valueToSet) == "function" then
		local oldValue = self:_get(point)
		local makeNewValue: SetFunction<T> = valueToSet
		rawset(self._grid[point.y], point.x, makeNewValue(oldValue))
	else
		rawset(self._grid[point.y], point.x, valueToSet)
	end
end

function Grid:SetRange<T>(from: Dimension, to: Dimension, value: SetValue<T>)
	validateDimension(from, self.Size)
	validateDimension(to, self.Size)

	self:_setRange(from, to, value)
end

function Grid:_setRange<T>(from: Dimension, to: Dimension, value: SetValue<T>)
	for x = from.x, to.x, 1 do
		for y = from.y, to.y, 1 do
			self:_set({ x = x, y = y }, value)
		end
	end
end

function Grid:Get<T>(from: Dimension): T
	validateDimension(from, self.Size)
	return self:_get(from)
end

function Grid:_get<T>(from: Dimension): T
	return rawget(self._grid[from.y], from.x)
end

function Grid:GetLine<T>(from: Dimension, direction: vector.Direction, length: number): { T }
	validateDimension(from, self.Size)

	local to = vector.getDestination(from, direction, length - 1)
	validateDimension(to, self.Size)

	local values: { T } = {}
	local incrementor = vector.getVectorFromDirection(direction)

	local start = from
	for _ = 1, length do
		table.insert(values, self:_get(start))
		start = vector.add2D(start, incrementor)
	end

	return values
end

return Grid
