local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check

local array = require("@utilities/array")
local operations = require("@utilities/operations")

local toNil = operations.Map.toNil
local toItself = operations.Map.toItself
local isEven = operations.Predicate.isEven
local everything = operations.Predicate.everything
local nothing = operations.Predicate.nothing

return function()
	test.suite("array.min", function()
		test.case("works", function()
			check.equal(array.min({ 1, 2, 3 }), 1)
		end)

		test.case("works with one-item arrays", function()
			check.equal(array.min({ 69 }), 69)
		end)

		test.case("errors on empty arrays", function()
			check.should_error(function()
				return array.min({})
			end)
		end)
	end)

	test.suite("array.minValue", function()
		local allDifferent = { "hello", "world!", "my", "name", "is.", "jeff bezos" }
		local someSame = { "hello", "world", "my", "name", "is", "jeff bezos" }

		test.case("works", function()
			check.equal(array.minValue(allDifferent, string.len), "my")
		end)

		test.case("returns first value for arrays with multiple minima", function()
			check.equal(array.minValue(someSame, string.len), "my")
		end)

		test.case("errors on empty arrays", function()
			check.should_error(function()
				return array.minValue({}, string.len)
			end)
		end)
	end)

	test.suite("array.max", function()
		test.case("works", function()
			check.equal(array.max({ 1, 2, 3 }), 3)
		end)

		test.case("works with one-item arrays", function()
			check.equal(array.max({ 69 }), 69)
		end)

		test.case("errors on empty arrays", function()
			check.should_error(function()
				return array.max({})
			end)
		end)
	end)

	test.suite("array.maxValue", function()
		local allDifferent = { "hello", "world!", "my", "name", "is.", "jeff bezos" }
		local someSame = { "hello", "world", "my", "name", "is", "jeff" }

		test.case("works", function()
			check.equal(array.maxValue(allDifferent, string.len), "jeff bezos")
		end)

		test.case("returns first value for arrays with multiple maxima", function()
			check.equal(array.maxValue(someSame, string.len), "hello")
		end)

		test.case("errors on empty arrays", function()
			check.should_error(function()
				return array.maxValue({}, string.len)
			end)
		end)
	end)

	test.suite("array.sum", function()
		test.case("works", function()
			check.equal(array.sum({ 1, 2, 3 }), 6)
		end)

		test.case("returns 0 on empty array", function()
			check.equal(array.sum({}), 0)
		end)

		test.case("errors on non-numeric input", function()
			check.should_error(function()
				return array.sum({ ("one" :: unknown) :: number })
			end)
			check.should_error(function()
				return array.sum({
					("one" :: unknown) :: number,
					("two" :: unknown) :: number,
					("three" :: unknown) :: number,
				})
			end)
		end)
	end)

	test.suite("array.product", function()
		test.case("works", function()
			check.equal(array.product({ 1, 2, 3 }), 6)
		end)

		test.case("returns 1 on empty array", function()
			check.equal(array.product({}), 1)
		end)

		test.case("errors on non-numeric input", function()
			check.should_error(function()
				return array.product({ ("one" :: unknown) :: number })
			end)
			check.should_error(function()
				return array.product({
					("one" :: unknown) :: number,
					("two" :: unknown) :: number,
					("three" :: unknown) :: number,
				})
			end)
		end)
	end)

	test.suite("array.append", function()
		local data = { 1, 2, 3 }

		test.case("works", function()
			check.array.equal(array.append(data, 4), { 1, 2, 3, 4 })
		end)

		test.case("is immutable", function()
			local result = array.append(data, 4)
			check.falsy(result == data) -- reference-equality
		end)

		test.case("works with empty arrays", function()
			local emptyArray = {}
			local result = array.append(emptyArray, 1)

			check.array.equal(result, { 1 })
			check.falsy(result == emptyArray) -- immutability
		end)
	end)

	test.suite("array.removeValue", function()
		local data = { 1, 2, 3 }

		test.case("works", function()
			check.array.equal(array.removeValue(data, 2), { 1, 3 })
		end)

		test.case("is immutable", function()
			local result = array.removeValue(data, 2)
			check.falsy(result == data) -- reference-equality
		end)

		test.case("returns the same values when the input isn't in the array", function()
			local result = array.removeValue(data, 4)

			check.array.equal(result, data) -- value-equality
			check.falsy(result == data) -- reference-equality
		end)

		test.case("returns an empty array when the original array is empty", function()
			local emptyArray = {}
			local result = array.removeValue(emptyArray, 1)

			check.array.equal(result, emptyArray) -- value-equality
			check.falsy(result == emptyArray) -- reference-equality
		end)
	end)

	test.suite("array.removeValues", function()
		local data = { 1, 2, 3, 3, 4, 4, 4, 5 }

		test.case("works", function()
			check.array.equal(array.removeAll(data, 4), { 1, 2, 3, 3, 5 })
		end)

		test.case("is immutable", function()
			local result = array.removeAll(data, 3)
			check.falsy(result == data) -- reference-equality
		end)

		test.case("returns the same values when the input isn't in the array", function()
			local result = array.removeAll(data, 6)

			check.array.equal(result, data) -- value-equality
			check.falsy(result == data) -- reference-equality
		end)

		test.case("returns an empty array when the original array is empty", function()
			local emptyArray = {}
			local result = array.removeValue(emptyArray, 1)

			check.array.equal(result, emptyArray) -- value-equality
			check.falsy(result == emptyArray) -- reference-equality
		end)
	end)

	test.suite("array.map", function()
		local data = { 1, 4, 9 }

		test.case("works", function()
			check.array.equal(array.map(data, math.sqrt), { 1, 2, 3 })
		end)

		test.case("is immutable", function()
			check.falsy(array.map(data, toItself) == data)
		end)

		test.case("returns an empty array when mapper returns nil", function()
			local result = array.map(data, toNil)
			check.array.equal(result, {})
			check.equal(#result, 0)
		end)

		test.case("works with empty arrays", function()
			check.array.equal(array.map({}, toItself), {})
		end)
	end)

	test.suite("array.filter", function()
		local data = { 1, 2, 3, 4, 5 }

		test.case("works", function()
			check.array.equal(array.filter(data, isEven), { 2, 4 })
		end)

		test.case("is immutable", function()
			check.falsy(array.filter(data, everything) == data)
		end)

		test.case("returns an empty array when the filter passes nothing", function()
			local result = array.filter(data, nothing)
			check.array.equal(result, {})
			check.equal(#result, 0)
		end)

		test.case("works with empty arrays", function()
			check.array.equal(array.filter({}, everything), {})
		end)
	end)

	test.suite("array.contains", function()
		local data = { 1, 2, 3, 4, 5 }

		test.case("works", function()
			check.is_true(array.contains(data, 2))
			check.is_false(array.contains(data, 6))
		end)

		test.case("works with empty arrays", function()
			check.is_false(array.contains({}, 1))
		end)
	end)

	test.suite("array.containsAnyOf", function()
		local data = { 1, 2, 3, 4, 5 }

		test.case("works", function()
			check.is_true(array.containsAnyOf(data, { 2, 3 }))
			check.is_false(array.containsAnyOf(data, { 6, 7 }))
		end)

		test.case("works with empty arrays", function()
			check.is_false(array.containsAnyOf({}, { 1 }))
		end)
	end)
end
