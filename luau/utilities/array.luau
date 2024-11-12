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
	Sums together all elements of a given array.
	Elements should support the `+` operation.
]=]
function Array.sum<T>(array: { T }): T | number
	if #array == 0 then
		return 0
	elseif #array == 1 then
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
]=]
function Array.product<T>(array: { T }): T | number
	if #array == 0 then
		return 1
	elseif #array == 1 then
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
	Removes the value from the array, returning a new array with the remaining values.
]=]
function Array.removeValue<T>(array: { T }, target: T): { T }
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

return Array
