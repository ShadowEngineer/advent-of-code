--!strict
local Dictionary = {}

function Dictionary.keys<K>(dict: { [K]: any }): { K }
	local keys = {}
	for key in dict do
		table.insert(keys, key)
	end
	return keys
end

function Dictionary.values<V>(dict: { [any]: V }): { V }
	local values = {}
	for _, value in dict do
		table.insert(values, value)
	end
	return values
end

function Dictionary.sum<K>(dict: { [K]: number }): number
	local sum = 0
	for _key, value in dict do
		sum += value
	end

	return sum
end

return Dictionary
