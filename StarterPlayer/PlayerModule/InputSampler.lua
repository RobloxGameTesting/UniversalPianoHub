local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local CommonUtils = require(script.Parent:WaitForChild("CommonUtils"))
require(script.Parent.Types)

local flagUtil = CommonUtils.get("FlagUtil")
local v = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
	or flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationDGA")
local v2 = flagUtil.getUserFlag("UserPlayerScriptsPlayerControlState2")
	or flagUtil.getUserFlag("UserPlayerScriptsPlayerControlState2GA")
local userFlag = flagUtil.getUserFlag("UserAbilitiesUserInterfaceB")
local userFlag2 = flagUtil.getUserFlag("UserControlModuleDisabledUpdate")
local userFlag3 = flagUtil.getUserFlag("UserPlayerModuleEngineAPI")

local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("ControlModule"):WaitForChild("AvatarAbilitiesInterface"))
local v3

if v then
	v3 = AvatarAbilitiesInterface.get(Players.LocalPlayer)
else
	v3 = nil
end

local v4 = userFlag and "ControlState" or "PlayerControlState"
local InputSampler = {}
InputSampler.__index = InputSampler

function InputSampler.new()
	return (setmetatable({
		controlData = { enabled = true, isJumping = false, worldMoveVector = Vector3.new(0, 0, 0) }
	}, InputSampler))
end

function InputSampler.Update(p, data)
	if not userFlag2 then
		return
	end

	local player = data.engineInterface.player

	if not player then
		return
	end

	if v2 then
		local character

		if userFlag3 then
			character = data.engineInterface.character
		else
			character = player.Character
		end

		if not character then
			return
		end

		local v5

		if userFlag then
			v5 = character:FindFirstChildOfClass(v4)
		else
			v5 = character:FindFirstChild(v4)
		end

		if not v5 then
			return
		end

		local v6

		if userFlag3 then
			v6 = data.engineInterface.humanoid
		else
			v6 = character:FindFirstChildOfClass("Humanoid")
		end

		if not v6 then
			return
		end

		local rotateToLookDirection = UserGameSettings.RotationType == Enum.RotationType.CameraRelative
		local lookVector = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.LookVector or Vector3.new(0, 0, 1)
		local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
		local v7 = {
			RotateToLookDirection = rotateToLookDirection,
			LookDirection = not (vector3.Magnitude > 0.001) and Vector3.new(0, 0, 1) or vector3.Unit
		}

		if data.controlModule.enabled or p.controlData.enabled then
			v7.Move = data.controlModule.worldMoveVector

			if not (v3 and v3:isEnabled()) then
				v7.Jump = data.controlModule.isJumping
			end
		end

		p.controlData.enabled = data.controlModule.enabled
		p.controlData.isJumping = data.controlModule.isJumping
		p.controlData.worldMoveVector = data.controlModule.worldMoveVector

		v5:UpdateFields(v7)
	elseif data.isServerAuthority then
		local inputContexts = player:FindFirstChild("InputContexts")

		if not inputContexts then
			return
		end

		local characterContext = inputContexts:FindFirstChild("CharacterContext")

		if not characterContext then
			return
		end

		local rotationAction = characterContext:FindFirstChild("RotationAction")

		local rotationScriptableBinding = rotationAction and rotationAction:FindFirstChild("RotationScriptableBinding")

		if rotationScriptableBinding then
			rotationScriptableBinding:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
		end
	end
end

return InputSampler