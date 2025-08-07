local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require("../../../Shared/CombatConfig/Types")
local LocalPlayer = Players.LocalPlayer

local require = require("../../loader").load(script)

local CharacterUtils = require("CharacterUtils")

local HideUpValue = require("HideUpValue")
local Config = require("Config")
Config = typeof(Config) == "function" and Config(HideUpValue) or Config

local CombatConfig = require("CombatConfig")
CombatConfig = typeof(CombatConfig) == "function" and CombatConfig(HideUpValue) or CombatConfig

local CombatEvent = ReplicatedStorage.Remotes.CombatEvent

local OverlapParam = OverlapParams.new()
OverlapParam.FilterType = Enum.RaycastFilterType.Include

return function(self : Types.CombatClient)
	local HumanoidRootPart = CharacterUtils.getAlivePlayerRootPart(LocalPlayer) -- BRO STOP USING PASCALCASE ITS SO BAD
	local Humanoid = CharacterUtils.getPlayerHumanoid(LocalPlayer)

	assert(Humanoid,"Could not find humanoid for player.")
	assert(HumanoidRootPart,"Could not find humanoid root part for player.")

	self.changeState(self, "Attacking")
	local HRP_CFrame = HumanoidRootPart.CFrame

	OverlapParam.FilterDescendantsInstances = self.Cast.Whitelist
	local SpatialResult = workspace:GetPartBoundsInRadius(HRP_CFrame.Position, 6, OverlapParam)
	for k,v in SpatialResult do
		CombatEvent:FireServer("Combat", "M1", HRP_CFrame.Position, 6, v.Position)
		-- On Server -> Raycast arg[4]-arg[2].Unit * arg[3] for auth
	end

	self.currentHitString = self.currentHitString % CombatConfig:_get("MAX_SWING_COUNT") + 1

	local currentHit = self.currentHitString

	if self.currentHitStringReset then
		task.cancel(self.currentHitStringReset)
		self.currentHitStringReset = nil
	end

	self.currentHitStringReset = task.delay(CombatConfig:_get("SWING_IDLE_RESET"), function()
		print(`player didnt swing for {CombatConfig:_get("SWING_IDLE_RESET")} seconds, resetting to 1`)
		self.currentHitString = 1
	end)

	Humanoid.WalkSpeed = Config:_get("M1").WalkSpeed

	task.delay(Config:_get("M1").Duration,function()
		self.changeState(self, "Idle")
		Humanoid.WalkSpeed = 16
	end)
end