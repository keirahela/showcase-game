--[=[
	@class GameServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local _ServiceBag = require("ServiceBag")

local GameServiceClient = {}
GameServiceClient.ServiceName = "GameServiceClient"

function GameServiceClient:Init(serviceBag: _ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrServiceClient"))

	-- Internal
	self._serviceBag:GetService(require("GameTranslator"))

	self._serviceBag:GetService(require("TestClient"))
end

return GameServiceClient