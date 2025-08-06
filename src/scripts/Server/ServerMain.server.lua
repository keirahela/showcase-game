--[[
	@class ServerMain
]]
local ServerScriptService = game:GetService("ServerScriptService")

local loader = ServerScriptService.Game:FindFirstChild("LoaderUtils", true).Parent
local require = require(loader).bootstrapGame(ServerScriptService.Game)

local serviceBag = require("ServiceBag").new()
serviceBag:GetService(require("GameService"))
serviceBag:Init()
serviceBag:Start()