--!nonstrict
local fs = require("@lune/fs")
local process = require("@lune/process")
local lune_console_reporter = require("@frktest/reporters/lune_console_reporter")
local frktest = require("@frktest/frktest")

local filter: string? = process.args[1]

local function passesFilter(fileName: string): boolean
	return if filter then fileName:match(filter) ~= nil else true
end
local function isTestFile(fileName: string): boolean
	return fileName:match("%a+.test.luau$") ~= nil
end

local function requireTestFiles(directoryPath: string)
	for _, file in fs.readDir(directoryPath) do
		local fileName = `{directoryPath}/{file}`
		if fs.isFile(fileName) and isTestFile(fileName) and passesFilter(fileName) then
			local testFile = require(`../{fileName}`) -- since we're 1 level down from root
			testFile()
		elseif fs.isDir(fileName) then
			requireTestFiles(fileName)
		end
	end
end

requireTestFiles("./events")
requireTestFiles("./utilities")

lune_console_reporter.init()
frktest.run()
