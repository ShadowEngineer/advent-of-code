local fs = require("@lune/fs")
local text = require("../../../utilities/text")
local input = text.strip(fs.readFile("input.txt"))

-- solution code...
print(input)

fs.writeFile("output-1.txt", "solution1")
fs.writeFile("output-2.txt", "solution2")
