local bencoder = {
	boolType = {
		["0"] = false,
		["1"] = true,
		[true] = "1",
		[false] = "0"
	}
}

type validTable = { [string | number | boolean] : string | number | boolean }
type validTypes = string | number | boolean | validTable

function getTableType(t : validTable)
	local index = 1

	for i, _ in t do
		if i ~= index then
			return "d"
		end

		index += 1
	end

	return "l"
end

function bencoder:encode(unencodedValue : validTypes): string
	local valueType = typeof(unencodedValue)

	if valueType == "string" then
		local stringLength = tostring(string.len(unencodedValue :: string)) 
		return stringLength..":"..unencodedValue :: string
	elseif valueType == "number" then
		return "i"..tostring(unencodedValue).."e"
	elseif valueType == "boolean" then
		return "b"..self.boolType[unencodedValue].."e"
	elseif valueType == "table" then
		local encodedString = getTableType(unencodedValue :: validTable)

		for key, value in unencodedValue :: validTable do
			local encodedKey = ""
			local encodedValue = self:encode(value)

			if string.sub(encodedString, 1, 1) == "d" then
				encodedKey = self:encode(key)
			end

			encodedString = encodedString..encodedKey..encodedValue
		end

		return encodedString.."e"
	else
		error("Argument #1 must be either string / number / boolean / validTable, got ", valueType)
	end
end

function bencoder:decode(encodedString : string, returnRemainingString : boolean?): validTypes
	assert(typeof(encodedString) == "string", "Argument #1 must be a string, got "..typeof(encodedString))

	local startCharacter = string.sub(encodedString, 1, 1)
	local decodedString, remainingString

	returnRemainingString = returnRemainingString or false

	if tonumber(startCharacter) then
		local firstColonIndex = string.find(encodedString, ":")

		assert(firstColonIndex, "The following string was incorrectly encoded: "..encodedString)

		local stringLength = tonumber(string.sub(encodedString, 1, firstColonIndex - 1))
		local stringStart = firstColonIndex + 1
		local stringEnd = firstColonIndex + stringLength

		decodedString, remainingString = string.sub(encodedString, stringStart, stringEnd), string.sub(encodedString, stringEnd + 1)
	elseif startCharacter == "i" then
		local stringEnd = string.find(encodedString, "e")
		local number = tonumber(string.sub(encodedString, 2, stringEnd - 1))

		assert(number, "The following number was incorrectly encoded: "..encodedString)

		decodedString, remainingString = number, string.sub(encodedString, stringEnd + 1)
	elseif startCharacter == "b" then
		local stringEnd = string.find(encodedString, "e")
		local bool = self.boolType[string.sub(encodedString, 2, stringEnd - 1)]

		assert(bool ~= nil, "The following boolean was incorrectly encoded: "..encodedString)

		decodedString, remainingString = bool, string.sub(encodedString, stringEnd + 1)
	elseif startCharacter == "l" then
		local array = {}

		remainingString = string.sub(encodedString, 2)

		while string.sub(remainingString, 1, 1) ~= "e" do
			local decodedValue, newRemainingString = table.unpack(self:decode(remainingString, true))

			table.insert(array, decodedValue)
			remainingString = newRemainingString or ""
		end

		decodedString, remainingString = array, string.sub(remainingString, 2)
	elseif startCharacter == "d" then
		local dictionary = {}

		remainingString = string.sub(encodedString, 2)

		while string.sub(remainingString, 1, 1) ~= "e" do
			local decodedKey, newRemainingString1 = table.unpack(self:decode(remainingString, true))
			local decodedValue, newRemainingString2 = table.unpack(self:decode(newRemainingString1, true))

			dictionary[decodedKey] = decodedValue
			remainingString = newRemainingString2 or ""
		end

		decodedString, remainingString = dictionary, string.sub(remainingString, 2)
	else
		error("Expected valid data type (string / number / boolean / table), got "..encodedString)
	end

	if returnRemainingString then
		return {
			decodedString,
			remainingString
		}
	else
		return decodedString
	end
end

return bencoder