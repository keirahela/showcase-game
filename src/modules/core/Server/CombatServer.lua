local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService('Players')
--[=[
	@class CombatServer
]=]
local Types = require("../Shared/CombatConfig/Types")
local CombatEvent = ReplicatedStorage.Remotes.CombatEvent
local CombatFunction = ReplicatedStorage.Remotes.CombatFunction
local DeltaCompressEvent = ReplicatedStorage.Remotes.DeltaCompress
local require = require(script.Parent.loader).load(script)
local maid = require("Maid")
local DeltaCompress = require("DeltaCompress")

local CombatServer = {}
CombatServer.ServiceName = "CombatServer"

local function onPlayerAdded(self,player:Player)

	local newmaid = maid.new() :: Types.Maid
	self.Handler[player] = {
		State = "Idle",
		CurrentAction = nil,
		maid = newmaid
	}
	newmaid:GiveTask(
		player.CharacterAdded:Connect(function(Character)
			local HRP = Character:WaitForChild("HumanoidRootPart") :: Part
			table.insert(self.CastWhitelist, HRP)
		end)
	)
	newmaid:GiveTask(
		player.CharacterRemoving:Connect(function(oldChar)
			local HumanoidRootPart = oldChar.HumanoidRootPart
			local Index = table.find(self.CastWhitelist,HumanoidRootPart)
			if not Index then warn("ERROR BRO SOMETHING WRONg :/")
				return
			end
			table.remove(self.CastWhitelist,Index)
		end)
	)
end
local function onPlayerRemoving(self,player)
	self.Handler[player].maid:DoCleaning()
	self.Handler[player] = nil
end

function CombatServer.Init(self, serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	
	self._maid = maid.new()
	
	self = {
		["Handler"] = {},
		["Methods"] = {
			["Combat"] = {
				M1 = CombatServer.Verify,
				M2 = CombatServer.Verify,
				Critical = CombatServer.Verify,
			},
			["Special"] = {
				["Grip"] = CombatServer.Grip,
				["Dash"] = CombatServer.Dash
			}
		},
		["CastWhitelist"] = {}
	}
	
	for k,v in Players:GetPlayers() do
		onPlayerAdded(self, v)
	end
	
	self._maid:GiveTask(Players.PlayerAdded:Connect(function(player)
		onPlayerAdded(self, player)
	end))
	
	self._maid:GiveTask(Players.PlayerRemoving:Connect(function(player)
		onPlayerRemoving(self, player)
	end))

	self._maid:GiveTask(CombatEvent.OnServerEvent:Connect(function(player,Category,callName, ...)
		local method = self["Methods"][Category][callName]
		if not method then
			error(`Method not found for {Category}/{callName}`)
		end
		--CurrentAction : thread?,--task.spawn(Methods.Combat[Action])
		self.Handler[player]["CurrentAction"] = task.spawn(method , self, player, callName, ...)
	end))
	
	self._maid:GiveTask(DeltaCompressEvent.OnServerEvent:Connect(function(player, newState)
		self["Handler"][player]["State"] = DeltaCompress.applyImmutable(self["Handler"][player]["State"], newState )
	end))
	
	return self
end


function CombatServer:Destroy()
	if self._maid then
		self._maid:Destroy()
		self._maid = nil
	end
	
	for player, handler in pairs(self.Handler) do
		if handler.maid then
			handler.maid:DoCleaning()
		end
		if handler.CurrentAction then
			task.cancel(handler.CurrentAction)
		end
	end
	
	self._serviceBag = nil
end

local OverlapParameters = OverlapParams.new()
OverlapParameters.FilterType = Enum.RaycastFilterType.Include

function CombatServer.Verify(self , player , callName , ... )
	OverlapParameters.FilterDescendantsInstances = self.CastWhitelist
	local position,radius,check = ...
	if math.abs ((check-position).Magnitude) <= radius then
		local results = workspace:GetPartBoundsInRadius(position,radius,OverlapParameters)
		for i,Part in results do
			local Character = Part.Parent
			local HitPlayer = Players:GetPlayerFromCharacter(Character)
			if not( HitPlayer and HitPlayer ~= player ) then continue end
			local PlayerState = self.Handler[HitPlayer]["State"]
			if PlayerState == "Blocking" then continue end
			
			xpcall(function()
				CombatFunction:InvokeClient(HitPlayer, .7 , 0 , 5)
			end, function(err) print(err) end)
		end	
	end
end



return CombatServer
