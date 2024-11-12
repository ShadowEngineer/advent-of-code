local vector = require("vector")

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
	__index: GridImpl,
}
export type Grid = typeof(setmetatable({} :: GridObj<any>, {} :: GridImpl))

local function validateDimension(dimension: Dimension, max: Dimension)
	assert(dimension.x > 0 and dimension.x <= max.x, `given X {dimension.x} is out of bounds ({max.x})`)
	assert(dimension.y > 0 and dimension.y <= max.y, `given Y {dimension.y} is out of bounds ({max.y})`)
end

local Grid = {}
Grid.__index = Grid

function Grid.new(size: Dimension): Grid
	return setmetatable({
		_grid = {},
		Size = size,
	}, Grid)
end

function Grid:Set<T>(point: Dimension, value: SetValue<T>)
	validateDimension(point, self.Size)
	self:_set(point, value)
end

function Grid:_set<T>(point: Dimension, valueToSet: SetValue<T>)
	if self._grid[point.x] == nil then
		rawset(self._grid, point.x, {})
	end

	if typeof(valueToSet) == "function" then
		local oldValue = rawget(self._grid[point.x], point.y)
		local makeNewValue: SetFunction<T> = valueToSet
		rawset(self._grid[point.x], point.y, makeNewValue(oldValue))
	else
		rawset(self._grid[point.x], point.y, valueToSet)
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

return Grid
