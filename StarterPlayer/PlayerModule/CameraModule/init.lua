local CameraModule = {}
CameraModule.__index = CameraModule

local v = {
	"CameraMinZoomDistance",
	"CameraMaxZoomDistance",
	"CameraMode",
	"DevCameraOcclusionMode",
	"DevComputerCameraMode",
	"DevTouchCameraMode",
	"DevComputerMovementMode",
	"DevTouchMovementMode",
	"DevEnableMouseLock"
}

local v2 = {
	"ComputerCameraMovementMode",
	"ComputerMovementMode",
	"ControlMode",
	"GamepadCameraSensitivity",
	"MouseSensitivity",
	"RotationType",
	"TouchCameraMovementMode",
	"TouchMovementMode"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local CommonUtils = require(script.Parent:WaitForChild("CommonUtils"))
local connectionUtil = CommonUtils.get("ConnectionUtil")
local flagUtil = CommonUtils.get("FlagUtil")

local CameraUtils = require(script:WaitForChild("CameraUtils"))
require(script:WaitForChild("CameraInput"))

local ClassicCamera = require(script:WaitForChild("ClassicCamera"))
local OrbitalCamera = require(script:WaitForChild("OrbitalCamera"))
local LegacyCamera = require(script:WaitForChild("LegacyCamera"))
local VehicleCamera = require(script:WaitForChild("VehicleCamera"))

local VRCamera = require(script:WaitForChild("VRCamera"))
local VRVehicleCamera = require(script:WaitForChild("VRVehicleCamera"))

local Invisicam = require(script:WaitForChild("Invisicam"))
local Poppercam = require(script:WaitForChild("Poppercam"))

local TransparencyController = require(script:WaitForChild("TransparencyController"))
local MouseLockController = require(script:WaitForChild("MouseLockController"))

local v3 = {}
local activeOcclusionModules = {}

if not Players.LocalPlayer then
	return {}
end

assert(Players.LocalPlayer, "Strict typing check")

local PlayerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")

PlayerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Default)
PlayerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Follow)
PlayerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Classic)

PlayerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Default)
PlayerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Follow)
PlayerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Classic)
PlayerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.CameraToggle)

local userFlag = flagUtil.getUserFlag("UserPlayerConnectionMemoryLeak")
local userFlag2 = flagUtil.getUserFlag("UserPSFixCameraControllerReset")
local userFlag3 = flagUtil.getUserFlag("UserPlayerModuleEngineAPI")
local userFlag4 = flagUtil.getUserFlag("UserVRFixCameraCloseArticulation")

local vrFirstPersonState = CommonUtils.get("VRFirstPersonState")

function CameraModule.new()
	local v4 = { activeTransparencyController = TransparencyController.new(), connectionUtil = 0 }
	local connectionUtil2

	if userFlag then
		connectionUtil2 = connectionUtil.new()
	end

	v4.connectionUtil = connectionUtil2
	local object = setmetatable(v4, CameraModule)

	object.activeCameraController = nil
	object.activeOcclusionModule = nil
	object.activeMouseLockController = nil

	object.currentComputerCameraMovementMode = nil

	object.cameraSubjectChangedConn = nil
	object.cameraTypeChangedConn = nil

	if not userFlag3 then
		for _, v5 in pairs(Players:GetPlayers()) do
			object:OnPlayerAdded(v5)
		end

		Players.PlayerAdded:Connect(function(player)
			object:OnPlayerAdded(player)
		end)

		if userFlag then
			Players.PlayerRemoving:Connect(function(player)
				object:OnPlayerRemoving(player)
			end)
		end
	end

	object.activeTransparencyController:Enable(true)

	object.activeMouseLockController = MouseLockController.new()
	assert(object.activeMouseLockController, "Strict typing check")

	local bindableToggleEvent = object.activeMouseLockController:GetBindableToggleEvent()

	if bindableToggleEvent then
		bindableToggleEvent:Connect(function()
			object:OnMouseLockToggled()
		end)
	end

	object:ActivateCameraController()
	object:ActivateOcclusionModule(Players.LocalPlayer.DevCameraOcclusionMode)
	object:OnCurrentCameraChanged()

	for _, propertyName in pairs(v) do
		Players.LocalPlayer:GetPropertyChangedSignal(propertyName):Connect(function()
			object:OnLocalPlayerCameraPropertyChanged(propertyName)
		end)
	end

	for _, propertyName in pairs(v2) do
		UserGameSettings:GetPropertyChangedSignal(propertyName):Connect(function()
			object:OnUserGameSettingsPropertyChanged(propertyName)
		end)
	end

	game.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		object:OnCurrentCameraChanged()
	end)
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		object:OnPreferredInputChanged()
	end)

	return object
end

function CameraModule:GetCameraMovementModeFromSettings()
	if Players.LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
		return CameraUtils.ConvertCameraModeEnumToStandard(Enum.ComputerCameraMovementMode.Classic)
	end

	local selected, v4

	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		selected = CameraUtils.ConvertCameraModeEnumToStandard(Players.LocalPlayer.DevTouchCameraMode)
		v4 = CameraUtils.ConvertCameraModeEnumToStandard(UserGameSettings.TouchCameraMovementMode)
	else
		selected = CameraUtils.ConvertCameraModeEnumToStandard(Players.LocalPlayer.DevComputerCameraMode)
		v4 = CameraUtils.ConvertCameraModeEnumToStandard(UserGameSettings.ComputerCameraMovementMode)
	end

	if selected == Enum.DevComputerCameraMovementMode.UserChoice then
		return v4
	end

	return selected
end

function CameraModule:ActivateOcclusionModule(occlusionMode)
	local v4

	if occlusionMode == Enum.DevCameraOcclusionMode.Zoom then
		v4 = Poppercam
	elseif occlusionMode == Enum.DevCameraOcclusionMode.Invisicam then
		v4 = Invisicam
	else
		warn("CameraScript ActivateOcclusionModule called with unsupported mode")
		return
	end

	self.occlusionMode = occlusionMode

	if self.activeOcclusionModule and self.activeOcclusionModule:GetOcclusionMode() == occlusionMode then
		if not self.activeOcclusionModule:GetEnabled() then
			self.activeOcclusionModule:Enable(true)
		end
	else
		local activeOcclusionModule = self.activeOcclusionModule

		self.activeOcclusionModule = activeOcclusionModules[v4]

		if not self.activeOcclusionModule then
			self.activeOcclusionModule = v4.new()

			if self.activeOcclusionModule then
				activeOcclusionModules[v4] = self.activeOcclusionModule
			end
		end

		if self.activeOcclusionModule then
			if self.activeOcclusionModule:GetOcclusionMode() ~= occlusionMode then
				warn(
					"CameraScript ActivateOcclusionModule mismatch: ",
					self.activeOcclusionModule:GetOcclusionMode(),
					"~=",
					occlusionMode
				)
			end

			if activeOcclusionModule then
				if activeOcclusionModule == self.activeOcclusionModule then
					warn("CameraScript ActivateOcclusionModule failure to detect already running correct module")
				else
					activeOcclusionModule:Enable(false)
				end
			end

			if occlusionMode == Enum.DevCameraOcclusionMode.Invisicam then
				if Players.LocalPlayer.Character then
					self.activeOcclusionModule:CharacterAdded(Players.LocalPlayer.Character, Players.LocalPlayer)
				end
			else
				for _, v5 in pairs(Players:GetPlayers()) do
					if v5 and v5.Character then
						self.activeOcclusionModule:CharacterAdded(v5.Character, v5)
					end
				end

				self.activeOcclusionModule:OnCameraSubjectChanged(game.Workspace.CurrentCamera.CameraSubject)
			end

			self.activeOcclusionModule:Enable(true)
		end
	end
end

function CameraModule:ShouldUseVehicleCamera()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return false
	end

	local cameraType = currentCamera.CameraType
	local cameraSubject = currentCamera.CameraSubject

	local v4 = cameraType == Enum.CameraType.Custom or cameraType == Enum.CameraType.Follow
	local v5 = cameraSubject and cameraSubject:IsA("VehicleSeat") or false
	local v6 = self.occlusionMode ~= Enum.DevCameraOcclusionMode.Invisicam

	return v5 and v4 and v6
end

function CameraModule:ActivateCameraController()
	local cameraType = workspace.CurrentCamera.CameraType
	local v4 = self:GetCameraMovementModeFromSettings()
	local v5 = nil

	if cameraType == Enum.CameraType.Scriptable then
		if self.activeCameraController then
			self.activeCameraController:Enable(false)
			self.activeCameraController = nil
		end
	else
		if cameraType == Enum.CameraType.Custom then
			v4 = self:GetCameraMovementModeFromSettings()
		elseif cameraType == Enum.CameraType.Track then
			v4 = Enum.ComputerCameraMovementMode.Classic
		elseif cameraType == Enum.CameraType.Follow then
			v4 = Enum.ComputerCameraMovementMode.Follow
		elseif cameraType == Enum.CameraType.Orbital then
			v4 = Enum.ComputerCameraMovementMode.Orbital
		elseif
			cameraType == Enum.CameraType.Attach
			or cameraType == Enum.CameraType.Watch
			or cameraType == Enum.CameraType.Fixed
		then
			v5 = LegacyCamera
		else
			warn("CameraScript encountered an unhandled Camera.CameraType value: ", cameraType)
		end

		if not v5 then
			if VRService.VREnabled then
				v5 = VRCamera
			elseif
				v4 == Enum.ComputerCameraMovementMode.Classic
				or v4 == Enum.ComputerCameraMovementMode.Follow
				or v4 == Enum.ComputerCameraMovementMode.Default
				or v4 == Enum.ComputerCameraMovementMode.CameraToggle
			then
				v5 = ClassicCamera
			elseif v4 == Enum.ComputerCameraMovementMode.Orbital then
				v5 = OrbitalCamera
			else
				warn("ActivateCameraController did not select a module.")
				return
			end
		end

		if self:ShouldUseVehicleCamera() then
			if VRService.VREnabled then
				v5 = VRVehicleCamera
			else
				v5 = VehicleCamera
			end
		end

		local activeCameraController

		if v3[v5] then
			activeCameraController = v3[v5]

			if userFlag2 then
				if activeCameraController.Reset and self.activeCameraController ~= activeCameraController then
					activeCameraController:Reset()
				end
			elseif activeCameraController.Reset then
				activeCameraController:Reset()
			end
		else
			activeCameraController = v5.new()
			v3[v5] = activeCameraController
		end

		if self.activeCameraController then
			if self.activeCameraController == activeCameraController then
				if not self.activeCameraController:GetEnabled() then
					self.activeCameraController:Enable(true)
				end
			else
				if activeCameraController.HandleSubjectDistance then
					activeCameraController:HandleSubjectDistance(self.activeCameraController)
				end

				self.activeCameraController:Enable(false)
				self.activeCameraController = activeCameraController
				self.activeCameraController:Enable(true)
			end
		elseif activeCameraController ~= nil then
			self.activeCameraController = activeCameraController
			assert(self.activeCameraController, "Strict typing check")

			self.activeCameraController:Enable(true)
		end

		if self.activeCameraController then
			self.activeCameraController:SetCameraMovementMode(v4)

			self.activeCameraController:SetCameraType(cameraType)
		end
	end
end

function CameraModule:OnCameraSubjectChanged()
	local currentCamera = workspace.CurrentCamera
	local cameraSubject

	if currentCamera then
		cameraSubject = currentCamera.CameraSubject
	end

	if self.activeTransparencyController then
		self.activeTransparencyController:SetSubject(cameraSubject)
	end

	if self.activeOcclusionModule then
		self.activeOcclusionModule:OnCameraSubjectChanged(cameraSubject)
	end

	self:ActivateCameraController()
end

function CameraModule:OnCameraTypeChanged(p)
	if p == Enum.CameraType.Scriptable and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		CameraUtils.restoreMouseBehavior()
	end

	self:ActivateCameraController()
end

function CameraModule:OnCurrentCameraChanged()
	local currentCamera = game.Workspace.CurrentCamera

	if not currentCamera then
		return
	end

	if self.cameraSubjectChangedConn then
		self.cameraSubjectChangedConn:Disconnect()
	end

	if self.cameraTypeChangedConn then
		self.cameraTypeChangedConn:Disconnect()
	end

	self.cameraSubjectChangedConn = currentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
		self:OnCameraSubjectChanged()
	end)

	self.cameraTypeChangedConn = currentCamera:GetPropertyChangedSignal("CameraType"):Connect(function()
		self:OnCameraTypeChanged(currentCamera.CameraType)
	end)

	self:OnCameraSubjectChanged()
	self:OnCameraTypeChanged(currentCamera.CameraType)
end

function CameraModule:OnLocalPlayerCameraPropertyChanged(p: string)
	if p == "CameraMode" then
		if Players.LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
			if not self.activeCameraController or self.activeCameraController:GetModuleName() ~= "ClassicCamera" then
				self:ActivateCameraController()
			end

			if self.activeCameraController then
				self.activeCameraController:UpdateForDistancePropertyChange()
			end
		elseif Players.LocalPlayer.CameraMode == Enum.CameraMode.Classic then
			self:ActivateCameraController()
		else
			warn("Unhandled value for property player.CameraMode: ", Players.LocalPlayer.CameraMode)
		end
	elseif p == "DevComputerCameraMode" or p == "DevTouchCameraMode" then
		self:ActivateCameraController()
	elseif p == "DevCameraOcclusionMode" then
		self:ActivateOcclusionModule(Players.LocalPlayer.DevCameraOcclusionMode)
	elseif p == "CameraMinZoomDistance" or p == "CameraMaxZoomDistance" then
		if self.activeCameraController then
			self.activeCameraController:UpdateForDistancePropertyChange()
		end
	elseif p == "DevTouchMovementMode" then
		return
	elseif p == "DevComputerMovementMode" then
		return
	end
end

function CameraModule:OnUserGameSettingsPropertyChanged(p: string)
	if p == "ComputerCameraMovementMode" then
		self:ActivateCameraController()
	end
end

function CameraModule:OnPreferredInputChanged()
	self:ActivateCameraController()
end

function CameraModule:Update(p, p2)
	if self.activeCameraController then
		self.activeCameraController:UpdateMouseBehavior()

		local cframe, focus = self.activeCameraController:Update(p2)

		if userFlag4 and VRService.VREnabled and self.activeCameraController.IsInFirstPerson then
			vrFirstPersonState.inFirstPerson = self.activeCameraController:IsInFirstPerson()
		end

		local currentCamera = game.Workspace.CurrentCamera

		if self.activeOcclusionModule and not self.activeCameraController.skipOcclusion then
			cframe, focus = self.activeOcclusionModule:Update(p2, cframe, focus, p)
		end

		currentCamera.CFrame = cframe
		currentCamera.Focus = focus

		if self.activeTransparencyController then
			self.activeTransparencyController:Update(p2)
		end
	elseif userFlag4 and VRService.VREnabled then
		vrFirstPersonState.inFirstPerson = false
	end
end

if not userFlag3 then
	function CameraModule:OnCharacterAdded(p, p2)
		if self.activeOcclusionModule then
			self.activeOcclusionModule:CharacterAdded(p, p2)
		end
	end

	function CameraModule:OnCharacterRemoving(p, p2)
		if self.activeOcclusionModule then
			self.activeOcclusionModule:CharacterRemoving(p, p2)
		end
	end

	function CameraModule:OnPlayerAdded(data)
		if userFlag then
			if self.connectionUtil then
				self.connectionUtil:trackConnection(
					`{data.UserId}CharacterAdded`,
					data.CharacterAdded:Connect(function(character)
						self:OnCharacterAdded(character, data)
					end)
				)

				self.connectionUtil:trackConnection(
					`{data.UserId}CharacterRemoving`,
					data.CharacterRemoving:Connect(function(character)
						self:OnCharacterRemoving(character, data)
					end)
				)
			end
		else
			data.CharacterAdded:Connect(function(character)
				self:OnCharacterAdded(character, data)
			end)
			data.CharacterRemoving:Connect(function(character)
				self:OnCharacterRemoving(character, data)
			end)
		end
	end

	function CameraModule:OnPlayerRemoving(p)
		if self.connectionUtil then
			self.connectionUtil:disconnect(`{p.UserId}CharacterAdded`)
			self.connectionUtil:disconnect(`{p.UserId}CharacterRemoving`)
		end
	end
end

function CameraModule:OnMouseLockToggled()
	if self.activeMouseLockController then
		local isMouseLocked = self.activeMouseLockController:GetIsMouseLocked()
		local mouseLockOffset = self.activeMouseLockController:GetMouseLockOffset()

		if self.activeCameraController then
			self.activeCameraController:SetIsMouseLocked(isMouseLocked)
			self.activeCameraController:SetMouseLockOffset(mouseLockOffset)
		end
	end
end

if RunService:IsClient() then
	return CameraModule.new()
end

return CameraModule