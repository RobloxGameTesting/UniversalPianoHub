local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local ZoomController = require(script.Parent:WaitForChild("ZoomController"))
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
CommonUtils.get("FlagUtil")

local cameraGamepadResetAction = script.Parent.Parent:WaitForChild("InputContexts"):WaitForChild("CameraContext"):WaitForChild("CameraGamepadResetAction")

local BaseCamera = require(script.Parent:WaitForChild("BaseCamera"))
local object = setmetatable({}, BaseCamera)
object.__index = object

function object.new()
	local object2 = setmetatable(BaseCamera.new(), object)

	object2.gamepadZoomLevels = { 0, 7 }

	object2.headScale = 1

	object2:SetCameraToSubjectDistance(7)

	object2.VRFadeResetTimer = 0
	object2.VREdgeBlurTimer = 0

	object2.needsReset = true
	object2.recentered = false

	object2.gamepadResetConnection = cameraGamepadResetAction.Pressed:Connect(function()
		object2:GamepadReset()
	end)

	object2:Reset()

	return object2
end

function object:Reset()
	self.stepRotateTimeout = 0
end

function object.GetModuleName(_): string
	return "VRBaseCamera"
end

function object:GamepadZoomPress()
	BaseCamera.GamepadZoomPress(self)

	self:GamepadReset()
	self:ResetZoom()
end

function object:GamepadReset()
	self.stepRotateTimeout = 0
	self.needsReset = true
end

function object:ResetZoom()
	ZoomController.SetZoomParameters(self.currentSubjectDistance, 0)
	ZoomController.ReleaseSpring()
end

function object:OnEnabledChanged()
	BaseCamera.OnEnabledChanged(self)

	if self.enabled then
		cameraGamepadResetAction.Enabled = true

		self.thirdPersonOptionChanged = VRService:GetPropertyChangedSignal("ThirdPersonFollowCamEnabled"):Connect(function()
			self:Reset()
		end)

		self.vrRecentered = VRService.UserCFrameChanged:Connect(function(p, _)
			if p == Enum.UserCFrame.Floor then
				self.recentered = true
			end
		end)
	else
		if self.inFirstPerson then
			self:GamepadZoomPress()
		end

		if self.thirdPersonOptionChanged then
			self.thirdPersonOptionChanged:Disconnect()
			self.thirdPersonOptionChanged = nil
		end

		if self.vrRecentered then
			self.vrRecentered:Disconnect()
			self.vrRecentered = nil
		end

		if self.cameraHeadScaleChangedConn then
			self.cameraHeadScaleChangedConn:Disconnect()
			self.cameraHeadScaleChangedConn = nil
		end

		cameraGamepadResetAction.Enabled = false

		local vrFade = Lighting:FindFirstChild("VRFade")

		if vrFade then
			vrFade.Brightness = 0
		end
	end
end

function object:OnCurrentCameraChanged()
	BaseCamera.OnCurrentCameraChanged(self)

	if self.cameraHeadScaleChangedConn then
		self.cameraHeadScaleChangedConn:Disconnect()
		self.cameraHeadScaleChangedConn = nil
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		self.cameraHeadScaleChangedConn = currentCamera:GetPropertyChangedSignal("HeadScale"):Connect(function()
			self:OnHeadScaleChanged()
		end)
		self:OnHeadScaleChanged()
	end
end

function object:OnHeadScaleChanged()
	local headScale = workspace.CurrentCamera.HeadScale

	for k, gamepadZoomLevel in self.gamepadZoomLevels do
		self.gamepadZoomLevels[k] = gamepadZoomLevel * headScale / self.headScale
	end

	self:SetCameraToSubjectDistance(self:GetCameraToSubjectDistance() * headScale / self.headScale)
	self.headScale = headScale
end

function object:GetVRFocus(p, p2)
	local lastCameraFocus = self.lastCameraFocus or p

	self.cameraTranslationConstraints = Vector3.new(
		self.cameraTranslationConstraints.x,
		math.min(1, self.cameraTranslationConstraints.y + p2),
		self.cameraTranslationConstraints.z
	)

	local vector3 = Vector3.new(0, self:GetCameraHeight(), 0)
	return (CFrame.new(Vector3.new(p.x, lastCameraFocus.y, p.z):Lerp(p + vector3, self.cameraTranslationConstraints.y)))
end

function object:StartFadeFromBlack()
	if UserGameSettings.VignetteEnabled == false then
		return
	end

	local vrFade = Lighting:FindFirstChild("VRFade")

	if not vrFade then
		vrFade = Instance.new("ColorCorrectionEffect")
		vrFade.Name = "VRFade"
		vrFade.Parent = Lighting
	end

	vrFade.Brightness = -1
	self.VRFadeResetTimer = 0.1
end

function object:UpdateFadeFromBlack(p: number)
	local vrFade = Lighting:FindFirstChild("VRFade")

	if self.VRFadeResetTimer > 0 then
		self.VRFadeResetTimer = math.max(self.VRFadeResetTimer - p, 0)

		local vrFade2 = Lighting:FindFirstChild("VRFade")

		if vrFade2 and vrFade2.Brightness < 0 then
			vrFade2.Brightness = math.min(vrFade2.Brightness + p * 10, 0)
		end
	elseif vrFade then
		vrFade.Brightness = 0
	end
end

function object:StartVREdgeBlur(p, p2)
	if not p2 and UserGameSettings.VignetteEnabled == false then
		return
	end

	local vrBlurPart = workspace.CurrentCamera:FindFirstChild("VRBlurPart")

	if not vrBlurPart then
		vrBlurPart = Instance.new("Part")
		vrBlurPart.Name = "VRBlurPart"
		vrBlurPart.Parent = workspace.CurrentCamera
		vrBlurPart.CanTouch = false
		vrBlurPart.CanCollide = false
		vrBlurPart.CanQuery = false
		vrBlurPart.Anchored = true
		vrBlurPart.Size = Vector3.new(0.44, 0.47, 1)
		vrBlurPart.Transparency = 1
		vrBlurPart.CastShadow = false

		RunService.RenderStepped:Connect(function(_)
			local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)

			local v = workspace.CurrentCamera.CFrame * (CFrame.new(userCFrame.Position * workspace.CurrentCamera.HeadScale) * (userCFrame - userCFrame.Position))

			vrBlurPart.CFrame = v * CFrame.Angles(0, 3.141592653589793, 0) + v.LookVector * (1.05 * workspace.CurrentCamera.HeadScale)
			vrBlurPart.Size = Vector3.new(0.44, 0.47, 1) * workspace.CurrentCamera.HeadScale
		end)
	end

	local vrBlurScreen = p.PlayerGui:FindFirstChild("VRBlurScreen")
	local vrBlur

	if vrBlurScreen then
		vrBlur = vrBlurScreen:FindFirstChild("VRBlur")
	end

	if not vrBlur then
		vrBlurScreen = vrBlurScreen or Instance.new("SurfaceGui")

		vrBlurScreen.Name = "VRBlurScreen"
		vrBlurScreen.Parent = p.PlayerGui

		vrBlurScreen.Adornee = vrBlurPart

		vrBlur = Instance.new("ImageLabel")
		vrBlur.Name = "VRBlur"
		vrBlur.Parent = vrBlurScreen

		vrBlur.Image = "rbxasset://textures/ui/VR/edgeBlur.png"
		vrBlur.AnchorPoint = Vector2.new(0.5, 0.5)
		vrBlur.Position = UDim2.new(0.5, 0, 0.5, 0)

		local v = workspace.CurrentCamera.ViewportSize.X * 2.3 / 512
		local v2 = workspace.CurrentCamera.ViewportSize.Y * 2.3 / 512

		vrBlur.Size = UDim2.fromScale(v, v2)
		vrBlur.BackgroundTransparency = 1
		vrBlur.Active = true
		vrBlur.ScaleType = Enum.ScaleType.Stretch
	end

	vrBlur.Visible = true
	vrBlur.ImageTransparency = 0
	self.VREdgeBlurTimer = 0.14
end

function object:UpdateEdgeBlur(p, p2)
	local vrBlurScreen = p.PlayerGui:FindFirstChild("VRBlurScreen")
	local vrBlur

	if vrBlurScreen then
		vrBlur = vrBlurScreen:FindFirstChild("VRBlur")
	end

	if vrBlur then
		if self.VREdgeBlurTimer > 0 then
			self.VREdgeBlurTimer -= p2

			local vrBlurScreen2 = p.PlayerGui:FindFirstChild("VRBlurScreen")

			local vrBlur2 = vrBlurScreen2 and vrBlurScreen2:FindFirstChild("VRBlur")

			if vrBlur2 then
				vrBlur2.ImageTransparency = 1 - math.clamp(self.VREdgeBlurTimer, 0.01, 0.14) * 7.142857142857142
			end
		else
			vrBlur.Visible = false
		end
	end
end

function object:GetCameraHeight()
	if self.inFirstPerson then
		return 0
	end

	return 0.25881904510252074 * self.currentSubjectDistance
end

function object:GetSubjectCFrame()
	local subjectCFrame = BaseCamera.GetSubjectCFrame(self)
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject

	if not cameraSubject then
		return subjectCFrame
	end

	if
		cameraSubject:IsA("Humanoid")
		and cameraSubject:GetState() == Enum.HumanoidStateType.Dead
		and cameraSubject == self.lastSubject
	then
		subjectCFrame = self.lastSubjectCFrame
	end

	if subjectCFrame then
		self.lastSubjectCFrame = subjectCFrame
	end

	return subjectCFrame
end

function object:GetSubjectPosition()
	local lastSubjectPosition = BaseCamera.GetSubjectPosition(self)

	local currentCamera = game.Workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject

	if not cameraSubject then
		return nil
	end

	if cameraSubject:IsA("Humanoid") then
		if cameraSubject:GetState() == Enum.HumanoidStateType.Dead and cameraSubject == self.lastSubject then
			lastSubjectPosition = self.lastSubjectPosition
		end
	elseif cameraSubject:IsA("VehicleSeat") then
		lastSubjectPosition = cameraSubject.CFrame.Position + cameraSubject.CFrame:vectorToWorldSpace(Vector3.new(0, 4, 0))
	end

	self.lastSubjectPosition = lastSubjectPosition

	return lastSubjectPosition
end

function object:getRotation(p)
	local rotation = CameraInput.getRotation(p)

	if UserGameSettings.VRSmoothRotationEnabled then
		return rotation.X
	end

	if math.abs(rotation.X) > 0.03 then
		if self.stepRotateTimeout > 0 then
			self.stepRotateTimeout -= p
		end

		if self.stepRotateTimeout <= 0 then
			local v = (rotation.X < 0 and -1 or 1) * 0.5235987755982988
			self:StartFadeFromBlack()
			self.stepRotateTimeout = 0.25
			return v
		end
	elseif math.abs(rotation.X) < 0.02 then
		self.stepRotateTimeout = 0
	end

	return 0
end

function object.HandleSubjectDistance(object2, object3)
	if object3 and object3.IsInFirstPerson and object3:IsInFirstPerson() then
		object2:SetCameraToSubjectDistance(0)
	end
end

return object