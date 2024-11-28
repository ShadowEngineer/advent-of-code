local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check

local array = require("@utilities/array")

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
end
