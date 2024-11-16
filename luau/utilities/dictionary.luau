--!strict
local Dictionary = {}

--[=[
	Returns an array of elements, representing the dictionary's keys.
]=]
function Dictionary.keys<K>(dict: { [K]: any }): { K }
	local keys = {}
	for key in dict do
		table.insert(keys, key)
	end
	return keys
end

--[=[
	Returns an array of elements, representing the dictionary's values.
]=]
function Dictionary.values<V>(dict: { [any]: V }): { V }
	local values = {}
	for _, value in dict do
		table.insert(values, value)
	end
	return values
end

--[=[
	Sums all elements of the dictionary, if they are numeric.
]=]
function Dictionary.sum<K>(dict: { [K]: number }): number
	local sum = 0
	for _key, value in dict do
		sum += value
	end

	return sum
end

function Dictionary.map<KOld, VOld, KNew, VNew>(dict: { [KOld]: VOld }, map: (VOld, KOld) -> (VNew, KNew?)): { [KNew | KOld]: VNew }
	local newDictionary = {}

	for key, value in dict do
		local newValue, newKey = map(value, key)
		local keyToUse = if newKey then newKey else key
		newDictionary[keyToUse] = newValue
	end

	return newDictionary
end

return Dictionary
