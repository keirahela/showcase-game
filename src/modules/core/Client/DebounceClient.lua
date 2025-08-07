local RunService = game:GetService("RunService")
local Types = require("../Shared/CombatConfig/Types")

local require = require(script.Parent.loader).load(script)

local HideUpValue = require("HideUpValue")
local Config = require("Config")
Config = typeof(Config) == "function" and Config(HideUpValue) or Config

local CombatConfig = require("CombatConfig")
CombatConfig = typeof(CombatConfig) == "function" and CombatConfig(HideUpValue) or CombatConfig

local function isOnDebounce(self: Types.CombatClient, name: string, category: {}): boolean
	local debounceEndTime = category[name]

	if debounceEndTime == nil then
		return false
	end

	if tick() >= debounceEndTime then
		category[name] = nil
		return false
	end

	return true
end

local function applyCooldown(self: Types.CombatClient, name: string, category: {}, cooldown: number)
	cooldown = (name == "M1" and self.currentHitString == CombatConfig:_get("MAX_SWING_COUNT")) and Config:_get(name).Endlag or cooldown

	local cooldown_endtime = tick() + cooldown
	category[name] = cooldown_endtime

	local connection

	connection = RunService.Heartbeat:Connect(function()
		local currentTime = tick()

		if currentTime >= cooldown_endtime then
			category[name] = nil
			connection:Disconnect()
		end
	end)
end

return {
	applyCooldown = applyCooldown,
	isOnDebounce = isOnDebounce
}