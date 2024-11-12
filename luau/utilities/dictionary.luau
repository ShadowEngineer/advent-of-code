local Dictionary = {}

function Dictionary.sum<K, number>(dict: { [K]: number }): number
	local sum = 0
	for _key, value in dict do
		sum += value
	end

	return sum
end

return Dictionary
