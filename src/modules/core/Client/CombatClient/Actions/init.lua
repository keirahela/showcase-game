local function getAction(action: string)
	assert(script:FindFirstChild(action), `{action} not found in actions`)
	
	return require(script[action])
end

return {
	getAction = getAction
}