--[=[
	@class TestClient
]=]
local require = require(script.Parent.loader).load(script)

local _ServiceBag = require("ServiceBag")

local TestClient = {}
TestClient.ServiceName = "TestClient"

function TestClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrService"))

	-- Internal
	self._serviceBag:GetService(require("GameTranslator"))
	
	print("TestClient initialized")
end

return TestClient 