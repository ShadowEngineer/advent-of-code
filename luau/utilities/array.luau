--!strict
--[=[
	Utilities for array operations.
]=]
local Array = {}

--[=[
	Finds the smallest value in the given array.
	Values should support the `<` operation.
]=]
function Array.min(array: { number }): number
	if #array == 0 then
		error("empty array!")
	elseif #array == 1 then
		return array[1]
	else
		local smallest = array[1]
		for index = 2, #array, 1 do
			if array[index] < smallest then
				smallest = array[index]
			end
		end
		return smallest
	end
end

--[=[
	Finds the minimum value in the array based on a reducer function that, for each item returns a number to use in the mininmum calculation.
]=]
function Array.minValue<V>(array: { V }, reducer: (value: V) -> number): V
	if #array == 0 then
		error("empty array!")
	elseif #array == 1 then
		return array[1]
	else
		local smallest = array[1]
		for index = 2, #array, 1 do
			if reducer(array[index]) < reducer(smallest) then
				smallest = array[index]
			end
		end
		return smallest
	end
end

--[=[
	Finds the largest number in the given array.
]=]
function Array.max(array: { number }): number
	if #array == 0 then
		error("empty array!")
	elseif #array == 1 then
		return array[1]
	else
		local largest = array[1]
		for index = 2, #array, 1 do
			if array[index] > largest then
				largest = array[index]
			end
		end
		return largest
	end
end

--[=[
	Finds the maximum value in the array based on a reducer function that, for each item returns a number to use in the maximum calculation.
]=]
function Array.maxValue<V>(array: { V }, reducer: (V) -> number): V
	if #array == 0 then
		error("empty array!")
	elseif #array == 1 then
		return array[1]
	else
		local largest = array[1]
		for index = 2, #array, 1 do
			if reducer(array[index]) > reducer(largest) then
				largest = array[index]
			end
		end
		return largest
	end
end

--[=[
	Sums together all elements of a given array.
	Elements should support the `+` operation.
	TODO: make generic when type extending becomes a thing, or better support for metatable types also becomes a thing
]=]
function Array.sum(array: { number }): number
	if #array == 0 then
		return 0
	elseif #array == 1 then
		assert(typeof(array[1]) == "number", `array element 1 is not a number`)
		return array[1]
	else
		local sum = 0
		for _, value in ipairs(array) do
			sum += value
		end
		return sum
	end
end

--[=[
	Multiplies together all the elements of the given array.
	Elements should support the `*` operation.
	TODO: make generic when type extending becomes a thing, or better support for metatable types also becomes a thing
]=]
function Array.product(array: { number }): number
	if #array == 0 then
		return 1
	elseif #array == 1 then
		assert(typeof(array[1]) == "number", `array element 1 is not a number`)
		return array[1]
	else
		local product = 1
		for _, value in ipairs(array) do
			product *= value
		end
		return product
	end
end

--[=[
	Appends an element to the end of an array.
]=]
function Array.append<T>(array: { T }, value: T): { T }
	local newArray = table.clone(array)
	table.insert(newArray, value)
	return newArray
end

--[=[
	Removes the last element from the end of the array.
]=]
function Array.pop<T>(array: { T }): T
	return Array.tail(array, 1)[1]
end

--[=[
	Extracts the first n elements of the array, clamping the result to the array size.
]=]
function Array.head<T>(array: { T }, size: number): { T }
	size = math.min(size, #array)

	local newArray = {}
	for index = 1, size do
		newArray[index] = array[index]
	end
	return newArray
end

--[=[
	Extracts the last n elements of the array, clamping the result to the array size.
]=]
function Array.tail<T>(array: { T }, size: number): { T }
	size = math.min(size, #array)

	local newArray = {}
	for index = 1, size do
		local realIndex = #array - size + index
		newArray[index] = array[realIndex]
	end
	return newArray
end

--[=[
	Removes the value from the array, returning a new array with the remaining values.
]=]
function Array.removeValue<T>(array: { T }, target: T): { T }
	if #array == 0 then
		return {}
	end

	local new = {}
	local offset = 0
	for index, value in ipairs(array) do
		if value == target and offset == 0 then
			offset = 1
			continue
		end
		new[index - offset] = value
	end
	return new
end

--[=[
	Removes all instances of the value from the array, returning a new array with the remaining values.
]=]
function Array.removeAll<T>(array: { T }, target: T): { T }
	if #array == 0 then
		return {}
	end

	local new = {}
	local offset = 0
	for index, value in ipairs(array) do
		if value == target then
			offset += 1
			continue
		end
		new[index - offset] = value
	end
	return new
end

--[=[
	Maps all the values of the array by a given mapper function, optionally remapping the indices.
]=]
function Array.map<VOld, VNew>(array: { VOld }, mapValue: (value: VOld, index: number) -> (VNew, number?)): { VNew }
	if #array == 0 then
		return {}
	end

	local newArray = {}

	for index, item in ipairs(array) do
		local newValue, newIndex = mapValue(item, index)
		local indexToUse = index
		if newIndex then
			indexToUse = newIndex
		end

		newArray[indexToUse] = newValue
	end

	return newArray
end

--[=[
    Filters the array for all the values that pass the predicate.
]=]
function Array.filter<T>(array: { T }, predicate: (value: T) -> boolean): { T }
	if #array == 0 then
		return {}
	end

	local newArray = {}
	for _, value in ipairs(array) do
		if predicate(value) then
			table.insert(newArray, value)
		end
	end

	return newArray
end

--[=[
    Predicates if an array contains a given value.
]=]
function Array.contains<T>(array: { T }, value: T): boolean
	if #array == 0 then
		return false
	end

	for _, arrayValue in ipairs(array) do
		if arrayValue == value then
			return true
		end
	end

	return false
end

--[=[
    Predicates if an array contains any of the values in the filter.
]=]
function Array.containsAnyOf<T>(array: { T }, values: { T }): boolean
	if #array == 0 or #values == 0 then
		return false
	end

	for _, value in ipairs(values) do
		if Array.contains(array, value) then
			return true
		end
	end

	return false
end

return Array
