--[=[
	@class GameServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local GameServiceClient = {}
GameServiceClient.ServiceName = "GameServiceClient"

function GameServiceClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External

	--Internal
	self._serviceBag:GetService(require("GameBindersClient"))
	self._serviceBag:GetService(require("GameTranslator")) -- :GetService probably
	self._serviceBag:GetService(require("CombatClient"))
end

return GameServiceClient