--[=[
	@class TestService
]=]
local require = require(script.Parent.loader).load(script)

local _ServiceBag = require("ServiceBag")

local TestService = {}
TestService.ServiceName = "TestService"

function TestService:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrService"))

	-- Internal
	self._serviceBag:GetService(require("GameTranslator"))
	
	print("TestService initialized")
end

return TestService 