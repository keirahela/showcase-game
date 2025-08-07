--[=[
	@class GameBindersClient
]=]

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local GameBindersClient = {}
GameBindersClient.ServiceName = "GameBindersClient"

function GameBindersClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- Add client binders here
end

return GameBindersClient
