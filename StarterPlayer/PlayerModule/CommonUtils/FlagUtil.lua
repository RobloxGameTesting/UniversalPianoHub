local FlagUtil = {}

function FlagUtil.getUserFlag(p)
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled(p)
	end)

	return success and result
end

return FlagUtil