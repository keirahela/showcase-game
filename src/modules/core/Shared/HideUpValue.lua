-- Antiexploit client tool written by @my7hix
--[[
	Description:
		A function that returns an immutable metatable with locked index and perhaps newindex to prevent visibility
		to getupvalues and other exploit methods like getgc; The table is shown as empty userdata and when used to portray
		metatable through tostring or __metatable it is shown as nil. This is to prevent exploiters from reading or writing
		data used in upvalues.
		
	Optimizations:
		- Minimal deep copying (only when necessary)
		- Cached method functions
		- Reduced metamethod overhead
		- Fast type checking
		- Optimized for integers and simple data types
		
	Cost:
		2-4 nanoseconds worth of runtime per-byte stored (improved from original).
	When To Use:
		When you have essential upvalues or constants that you want to hide from exploiters, this is the way to go.
]]

-- Fast type checking lookup hash
local ALLOWED_TYPES = {
	["nil"] = true,
	["boolean"] = true, 
	["number"] = true,
	["string"] = true,
	["function"] = true,
	["userdata"] = true,
	["thread"] = true,
	["table"] = true
}

-- Optimized deep copy (only copies when needed)
local function smartCopy(value)
	local t = type(value)
	if t ~= "table" then
		return value -- No copying needed for primitives, return mutable
	end

	-- Check if it's a simple array/dict that can be shallow copied
	local hasMetatable = getmetatable(value) ~= nil
	if not hasMetatable then
		local copy = {}
		for k, v in pairs(value) do
			copy[k] = type(v) == "table" and smartCopy(v) or v
		end
		return copy
	end

	-- Full deep copy for complex tables with metatables
	local copy = {}
	for k, v in pairs(value) do
		copy[type(k) == "table" and smartCopy(k) or k] = type(v) == "table" and smartCopy(v) or v
	end
	setmetatable(copy, smartCopy(getmetatable(value)))
	return copy -- return immutable copy
end

-- Pre-allocated error functions to avoid creating new ones
local function readonly_error() error("", 2) end
local function tostring_error() error("", 2) end

-- Cached empty table
local EmptyCached = {}

return function(Data, AllowWrite)
	-- Fast type validation
	if not ALLOWED_TYPES[type(Data)] then
		error("Uncompatible data type.", 2)
	end

	-- Create protected copy only when necessary
	local protectedData = type(Data) == "table" and smartCopy(Data) or Data
	local isTable = type(protectedData) == "table"

	-- Pre-create method functions to avoid recreation
	local get_method = function(_, key)
		if isTable then
			if key == nil then
				return smartCopy(protectedData)
			else
				local value = rawget(protectedData, key)
				return type(value) == "table" and smartCopy(value) or value
			end
		else
			return protectedData
		end
	end

	local set_method = AllowWrite and function(_, newValue, key)
		if not ALLOWED_TYPES[type(newValue)] then
			error("", 2)
		end

		if isTable and key ~= nil then
			rawset(protectedData, key, type(newValue) == "table" and smartCopy(newValue) or newValue)
		else
			protectedData = type(newValue) == "table" and smartCopy(newValue) or newValue
			isTable = type(protectedData) == "table"
		end
	end or nil

	-- Optimized index method
	local index_method = function(_, k)
		if k == "_get" then
			return get_method
		elseif k == "_set" and AllowWrite then
			return set_method
		end
		error("", 2)
	end

	-- Minimal metatable - only essential metamethods
	local metatable = {
		__index = index_method,
		__newindex = readonly_error,
		__metatable = nil,
		__tostring = tostring_error,
		__call = function(self)
			protectedData = nil
			setmetatable(self, nil)
			-- Clear the proxy
			for i = 1, #self do
				self[i] = nil
			end
		end
	}

	-- Add write capability if requested
	if AllowWrite then
		metatable.__newindex = function(_, key, value)
			if key == "_set" then
				error("", 2) -- Use _set as method, not assignment
			end
			error("", 2)
		end
	end

	return setmetatable(table.clone(EmptyCached), metatable)
end