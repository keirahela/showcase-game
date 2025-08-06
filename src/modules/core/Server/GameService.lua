--[=[
	@class GameService
]=]

local require = require(script.Parent.loader).load(script)

local _ServiceBag = require("ServiceBag")

local GameService = {}
GameService.ServiceName = "GameService"

function GameService:Init(serviceBag: _ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrService"))
	
	-- Internal
	self._serviceBag:GetService(require("GameTranslator"))

	self._serviceBag:GetService(require("TestService"))
end

return GameService