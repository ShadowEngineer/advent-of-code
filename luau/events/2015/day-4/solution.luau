local fs = require("@lune/fs")
local secretKey = fs.readFile("input.txt")

-- solution code...
secretKey = secretKey:gsub("\n", "")
local md5Hash = require("../../../libraries/luau-hashing/modules/md5")
local function getHash(counter: number)
	return md5Hash(`{secretKey}{counter}`)
end
local function isSolution(counter: number, zeros: number)
	return getHash(counter):match(`^{("0"):rep(zeros)}.+`)
end

-- task 1
local counter = 0
while not isSolution(counter, 5) do
	counter += 1
end
print(getHash(counter), counter)
fs.writeFile("output-1.txt", counter)

-- task 2
while not isSolution(counter, 6) do
	counter += 1
end

print(getHash(counter), counter)
fs.writeFile("output-2.txt", counter)
