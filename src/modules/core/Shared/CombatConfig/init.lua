local s = nil

return s or function(HideUpValue)
	s = HideUpValue({
		MAX_SWING_COUNT = 5,
		SWING_IDLE_RESET = 2, -- if player doesnt swing for x seconds, swing count resets
		PERFECT_BLOCK_DURATION = 0.3,
	},false)
	return s
end