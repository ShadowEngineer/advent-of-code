local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local net = require("@lune/net")
local process = require("@lune/process")

-- getting input
print(`Welcome to the {stdio.color("yellow")}Luau AoC{stdio.color("reset")} scaffolder!`)
print("Pick your options:")

local years: { string } = {}
for year = 2015, 2024, 1 do
	table.insert(years, tostring(year))
end
local year = stdio.prompt("select", "Year?", years)

local days: { string } = {}
for day = 1, 25, 1 do
	table.insert(days, `Day {day}`)
end

local day = stdio.prompt("select", "Day?", days)

-- making new directory
print("Generating...")
local newPath = `events/{years[year]}/day-{day}`
if not fs.isDir(newPath) then
	fs.writeDir(newPath)
end

-- templating new directory
local templateFolder = `template`
for _, file in fs.readDir(templateFolder) do
	local fullFileName = `{process.cwd}/{templateFolder}/{file}`
	local newFullFileName = `{newPath}/{file}`
	fs.copy(fullFileName, newFullFileName, true)
end

-- getting env contents
if not fs.isFile(".env") then
	error("no .env! can't fetch input data!")
end

local aocCookie = fs.readFile(".env"):split("\n")[1]:split("=")[2]

-- getting input
local response = net.request({
	url = `https://adventofcode.com/{years[year]}/day/{day}/input`,
	headers = { ["Cookie"] = `session={aocCookie}` },
})

if response.ok then
	fs.writeFile(`{newPath}/input.txt`, response.body)
else
	print(
		`[{stdio.color("red")}{response.statusCode}/{response.statusMessage}{stdio.color("reset")}] Can't fetch input! Your cookie is probably bad...`
	)
end
