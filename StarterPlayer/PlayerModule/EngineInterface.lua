local Players = game:GetService("Players")

require(script.Parent:WaitForChild("CommonUtils"))

require(script.Parent.Types)

local EngineInterface = {}

function EngineInterface.update(p)
	local engineInterface = p.engineInterface

	local localPlayer = Players.LocalPlayer
	local character

	if localPlayer then
		character = localPlayer.Character
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if
		localPlayer ~= engineInterface.player
		or character ~= engineInterface.character
		or humanoid ~= engineInterface.humanoid
	then
		engineInterface.player = localPlayer
		engineInterface.character = character
		engineInterface.humanoid = humanoid
		engineInterface.characterChanged = true
	end
end

function EngineInterface.cleanDirty(p)
	p.engineInterface.characterChanged = false
end

return EngineInterface