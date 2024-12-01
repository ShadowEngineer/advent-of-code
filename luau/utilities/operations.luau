--[=[
    @class operations
    
    A module of just generic operation-functions.
    Very useful for passing into mappers or predicates.
]=]

local array = require("@utilities/array")

local Operation = {}

Operation.Predicate = {}

Operation.Predicate.is = function<T>(matcher: T): (T) -> boolean
	return function(value: T)
		return value == matcher
	end
end

-- selene:allow(unused_variable)
Operation.Predicate.everything = function(...: any): boolean
	return true
end
-- selene:allow(unused_variable)
Operation.Predicate.nothing = function(...: any): boolean
	return false
end

Operation.Predicate.isEven = function(value: number): boolean
	return value % 2 == 0
end

Operation.Predicate.isOdd = function(value: number): boolean
	return not Operation.Predicate.isEven(value)
end

Operation.Predicate.isNumber = function(value: any): boolean
	return tonumber(value) ~= nil
end

Operation.Predicate.isString = function(value: any): boolean
	return tostring(value) ~= nil
end

Operation.Predicate.isAnyOf = function<T>(filterList: { T }): (T) -> boolean
	return function(value: T): boolean
		return array.contains(filterList, value)
	end
end

Operation.Predicate.isSmallestIn = function(list: { number }): (any) -> boolean
	local smallest = array.min(list)
	return function(value: any): boolean
		return value == smallest
	end
end

Operation.Predicate.isLargestIn = function(list: { number }): (any) -> boolean
	local largest = array.max(list)
	return function(value: any): boolean
		return value == largest
	end
end

Operation.Map = {}

Operation.Map.multiplyBy = function(multiplier: number): (number) -> number
	return function(value: number): number
		return value * multiplier
	end
end

Operation.Map.square = function(value: number): number
	return value * value
end

Operation.Map.cube = function(value: number): number
	return value * value * value
end

Operation.Map.raiseToThePower = function(power: number): (number) -> number
	return function(value: number): number
		return math.pow(value, power)
	end
end

Operation.Map.toOne = function(): number
	return 1
end

Operation.Map.toNil = function(): nil
	return nil
end

Operation.Map.toItself = function<T>(value: T): T
	return value
end

return Operation
