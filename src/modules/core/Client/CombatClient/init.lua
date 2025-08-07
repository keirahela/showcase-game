--[=[
	README:
		This combat client is intended for optimized clientside hurtbox/hitbox
		
		Using ECS design for this module , we can easily add movesets with ease
		
		Hitboxes are authorised on 
		
	@class CombatClient
]=]
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require("../Shared/CombatConfig/Types")
local Actions = require("@self/Actions")

local CombatEvent = ReplicatedStorage.Remotes.CombatEvent
local CombatFunction = ReplicatedStorage.Remotes.CombatFunction
local DeltaCompressEvent = ReplicatedStorage.Remotes.DeltaCompress

local require = require(script.Parent.loader).load(script)

local HideUpValue = require("HideUpValue")
local Config = require("Config")
Config = typeof(Config) == "function" and Config(HideUpValue) or Config

local CombatConfig = require("CombatConfig")
CombatConfig = typeof(CombatConfig) == "function" and CombatConfig(HideUpValue) or CombatConfig


local InputClient = require("InputClient")
local DebounceClient = require("DebounceClient")

local Maid = require("Maid")
local CharacterUtils = require("CharacterUtils")
local DeltaCompress = require("DeltaCompress")

local ServiceBag = require("ServiceBag")


local CombatClient = {}
CombatClient.ServiceName = "CombatClient"

local function OnPlayerAdded(self, player)
	if player == LocalPlayer then return end
	table.insert(
		self.Cast.Whitelist,
		(player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
	)
	-- Subscribe to characteradded to renew whitelist if a palyer resets
	player.CharacterAdded:Connect(function(char)
		table.insert(
			self.Cast.Whitelist,
			(player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
		)
	end)
	player.CharacterRemoving:Connect(function(char)
		local index = table.find(self.Cast.Whitelist,char.HumanoidRootPart)
		if index then
			table.remove(self.Cast.Whitelist,index)
		end
	end)
end

function CombatClient.Init(self, serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	
	self._maid = Maid.new()
	
	self = {
		["_serviceBag"] = assert(serviceBag, "No serviceBag"),
		["Inputs"] = {
			["Combat"] = {
				["M1"] = Enum.UserInputType.MouseButton1,
				["M2"] = Enum.UserInputType.MouseButton2,
				["Critical"] = Enum.KeyCode.R,
				["Block"] = Enum.KeyCode.F
			},
			["Special"] = {
				["Dash"] = Enum.KeyCode.Q,
				["Grip"] = Enum.KeyCode.G
			}
		},
		["Actions"] = {
			["Combat"] = {
				["M1"] = Actions.getAction("M1"),
				["M2"] = Actions.getAction("M2"),
				["Critical"] = Actions.getAction("Critical"),
				["Block"] = Actions.getAction("Block"),
			},
			["Special"] = {
				["Dash"] = Actions.getAction("Dash"),
				["Grip"] = Actions.getAction("Grip")
			}
		},
		["Cleanup"] = {
			["Combat"] = {
				["Block"] = Actions.getAction("ReleaseBlock")
			}
		},-- idk im not a cleaning person :/
		["Debounces"] = {
			["Combat"] = {
				M1 = nil,
				M2 = nil,
				Critical = nil,
				Block = nil
			},
			["Special"] = {
				Dash = nil,
				Grip = nil
			}
		},
		["changeState"] = CombatClient.changeState,
		["Requests"] = {}, -- Threads for InvokeServer
		["State"] = "Idle",
		["Cast"] = {
			["Whitelist"] = {}
		},
		["currentHitString"] = 1,
		["currentHitStringReset"] = nil,
	}

	for k,v in Players:GetPlayers() do
		task.spawn(OnPlayerAdded,self, v)
	end
	
	self._maid:GiveTask(Players.ChildAdded:Connect(function(player) 
		OnPlayerAdded(self,player) 
	end))

	InputClient.connectInputs(self)

	CombatFunction.OnClientInvoke = function(HitDuration, HitSpeed , damage)
		local Humanoid = CharacterUtils.getAlivePlayerHumanoid(Players.LocalPlayer)
		Humanoid.WalkSpeed = HitSpeed

		task.delay(HitDuration,function()
			Humanoid.WalkSpeed = 16
		end)

		CombatClient.Receive(damage)
	end

	return self:: Types.CombatClient
end

function CombatClient:Destroy()
	if self._maid then
		self._maid:Destroy()
		self._maid = nil
	end
	
	if self.currentHitStringReset then
		task.cancel(self.currentHitStringReset)
		self.currentHitStringReset = nil
	end
	
	for _, request in pairs(self.Requests) do
		if request then
			task.cancel(request)
		end
	end
	
	self._serviceBag = nil
end

local EligibleTypes = {
	["string"] = true,
	["boolean"] = true,
	["CFrame"] = true,
	["Vector3"] = true,
	["Vector2"] = true,
	["table"] = true
}
local function copyDeep(obj, visited)
	visited = visited or {}
	if not EligibleTypes[typeof(obj)] then
		return nil
	end
	if type(obj) ~= "table" then
		return obj
	end
	if visited[obj] then
		return nil
	end
	visited[obj] = true
	local copy = {}
	for key, value in pairs(obj) do
		local a = copyDeep(key,visited)
		if not a then
			continue
		end
		copy[a] = copyDeep(value, visited)
	end
	visited[obj] = nil
	return copy
end

function CombatClient.changeState(self: Types.CombatClient, newState: Types.State)
	local old = self.State
	self.State = newState
	DeltaCompressEvent:FireServer( DeltaCompress.diffImmutable(old,newState) )
end

-- From Server
function CombatClient.Receive(Damage:number)
	local Humanoid : Humanoid? = CharacterUtils.getPlayerHumanoid(LocalPlayer)
	assert(Humanoid,"Could not find humanoid for player.")

	Humanoid:TakeDamage(Damage)
	return true
end

return CombatClient