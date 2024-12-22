--!strict
local Text = {}

function Text.strip(text: string): string
	return text:gsub("^%s+", ""):gsub("%s+$", "")
end

function Text.countAnyTokensOf(text: string, tokens: { string }): { [string]: number }
	local counter = {}

	for _, token in tokens do
		counter[token] = 0
		for _ in text:gmatch(token) do
			counter[token] += 1
		end
	end

	return counter
end

function Text.countAnyCharactersOf(text: string, characters: { string }): { [string]: number }
	local counter = {}

	for _, targetCharacter in characters do
		counter[targetCharacter] = 0
		for _, character in text:split("") do
			if character == targetCharacter then
				counter[targetCharacter] += 1
			end
		end
	end

	return counter
end

function Text.join(components: { string }): string
	local result = ""
	for _, component in components do
		result ..= component
	end
	return result
end

return Text
