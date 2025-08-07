local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require("../../../Shared/CombatConfig/Types")
local LocalPlayer = Players.LocalPlayer

local require = require("../../loader").load(script)

local CharacterUtils = require("CharacterUtils")

local HideUpValue = require("HideUpValue")
local Config = require("Config")
Config = typeof(Config) == "function" and Config(HideUpValue) or Config

return function(self : Types.CombatClient)
	local HumanoidRootPart = CharacterUtils.getAlivePlayerRootPart(LocalPlayer)
	local Humanoid = CharacterUtils.getPlayerHumanoid(LocalPlayer)

	assert(Humanoid,"Could not find humanoid for player.")
	assert(HumanoidRootPart,"Could not find humanoid root part for player.")

	self.changeState(self, "Idle")
	Humanoid.WalkSpeed = Config:_get("Block").DefaultWalkSpeed
end