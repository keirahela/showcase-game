local ContextActionService = game:GetService("ContextActionService")
local Types = require("../Shared/CombatConfig/Types")

local require = require(script.Parent.loader).load(script)
local HideUpValue = require("HideUpValue")
local Config = require("Config")
Config = typeof(Config) == "function" and Config(HideUpValue) or Config

local DebounceClient = require("DebounceClient")

local function bindInput(self : Types.CombatClient, name: string, callback: (self: Types.CombatClient) -> (), input: Enum.KeyCode | Enum.UserInputType, category: string, cleanupCallback: (self: Types.CombatClient) -> ()?)
	assert(Config:_get(name), `{name} : config or config duration doesn't exist`)

	ContextActionService:BindAction(name, function(actionName,UserInputState,InputObject)

		if UserInputState == Enum.UserInputState.Begin then
			if self.State ~= "Idle" then
				return
			end

			if DebounceClient.isOnDebounce(self, name, self.Debounces[category]) then
				warn(`{name} is on debounce`)
				return
			end

			DebounceClient.applyCooldown(self, name, self.Debounces[category], Config:_get(name).Cooldown or 0)
			callback(self)
		elseif UserInputState == Enum.UserInputState.End then
			if cleanupCallback then
				cleanupCallback(self)
			end
		end
	end, false, input)
end

local function connectInputs(self)
	assert(self.Inputs and typeof(self.Inputs) == "table", `self.Inputs has to be a table`)
	assert(self.Actions and typeof(self.Actions) == "table", `self.Actions has to be a table`)

	for currentInput,inputType in self.Inputs do
		if not self.Actions[currentInput] then
			continue
		end

		for actionName,input: Enum.KeyCode | Enum.UserInputType in inputType do
			local success, result = pcall(function()
				return self.Cleanup[currentInput][actionName]
			end)

			bindInput(self, actionName, self.Actions[currentInput][actionName], input, currentInput, success and result or nil)
		end
	end
end

return {
	bindInput = bindInput,
	connectInputs = connectInputs
}