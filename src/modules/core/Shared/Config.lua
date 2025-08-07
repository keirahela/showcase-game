
local s = nil


return s or function(HideUpValue)
	s = HideUpValue({
		["Dash"] =  {
			Velocity = 25,
			Duration = .5
		},
		["M1"] = {
			WalkSpeed = 8,
			Duration = .2,
			Cooldown = .1,
			Endlag = 1
		},
		["M2"] = {
			WalkSpeed = 0,
			Duration = 0.2,
			Cooldown = 15
		},
		["Block"] = {
			WalkSpeed = 6,
			DefaultWalkSpeed = 16,
			Duration = nil,
			Cooldown = .75,
		},
		["Critical"] = {
			WalkSpeed = 0,
			Duration = 0.5,
			Cooldown = 2
		},
		["Grip"] = {
			WalkSpeed = 0,
			Duration = 5,
			Cooldown = 5
		}

	},false)
	return s
end
