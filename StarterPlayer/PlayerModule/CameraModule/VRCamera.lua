local Players = game:GetService("Players")
local VRService = game:GetService("VRService")

require(script.Parent:WaitForChild("CameraInput"))
require(script.Parent:WaitForChild("CameraUtils"))
local VRCameraTeleportDetector = require(script.Parent:WaitForChild("VRCameraTeleportDetector"))
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")

local userFlag = flagUtil.getUserFlag("UserVRRecenterOnExternalTeleport")
local userFlag2 = flagUtil.getUserFlag("UserVRSkipOcclusionInFirstPerson")
local userFlag3 = flagUtil.getUserFlag("UserFixVRImmersionAutoRotate")

local VRBaseCamera = require(script.Parent:WaitForChild("VRBaseCamera"))
local object = setmetatable({}, VRBaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(VRBaseCamera.new(), object)

	self.lastUpdate = tick()
	self.focusOffset = CFrame.new()
	self:Reset()

	self.controlModule = require(script.Parent.Parent:WaitForChild("ControlModule"))
	self.savedAutoRotate = true
	self.autoRotateOverridden = false

	return self
end

function object:Reset()
	self.needsReset = true
	self.needsBlackout = true
	self.motionDetTime = 0
	self.blackOutTimer = 0
	self.lastCameraResetPosition = nil
	VRBaseCamera.Reset(self)
end

function object:Update(value)
	local currentCamera = workspace.CurrentCamera
	local cframe = currentCamera.CFrame
	local lastCameraFocus = currentCamera.Focus

	local localPlayer = Players.LocalPlayer

	if self.lastUpdate == nil or value > 1 then
		self.lastCameraTransform = nil
	end

	self:UpdateFadeFromBlack(value)

	local lastSubjectPosition = self.lastSubjectPosition
	local subjectPosition = self:GetSubjectPosition()

	if self.needsBlackout then
		self:StartFadeFromBlack()

		local v = math.clamp(value, 0.0001, 0.1)
		self.blackOutTimer += v

		if self.blackOutTimer > 0.1 and game:IsLoaded() then
			self.needsBlackout = false
			self.needsReset = true
		end
	end

	if subjectPosition and localPlayer and currentCamera then
		local vrFocus = self:GetVRFocus(subjectPosition, value)

		if userFlag2 then
			self.skipOcclusion = self:IsInFirstPerson()
				and localPlayer.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam
		end

		if self:IsInFirstPerson() then
			if VRService.AvatarGestures then
				cframe, lastCameraFocus = self:UpdateImmersionCamera(
					value,
					cframe,
					vrFocus,
					lastSubjectPosition,
					subjectPosition
				)
			else
				cframe, lastCameraFocus = self:UpdateFirstPersonTransform(
					value,
					cframe,
					vrFocus,
					lastSubjectPosition,
					subjectPosition
				)
			end
		elseif VRService.ThirdPersonFollowCamEnabled then
			cframe, lastCameraFocus = self:UpdateThirdPersonFollowTransform(
				value,
				cframe,
				vrFocus,
				lastSubjectPosition,
				subjectPosition
			)
		else
			cframe, lastCameraFocus = self:UpdateThirdPersonComfortTransform(
				value,
				cframe,
				vrFocus,
				lastSubjectPosition,
				subjectPosition
			)
		end

		self.lastCameraTransform = cframe
		self.lastCameraFocus = lastCameraFocus
	end

	self.lastUpdate = tick()
	return cframe, lastCameraFocus
end

function object.GetAvatarFeetWorldYValue(_)
	local cameraSubject = workspace.CurrentCamera.CameraSubject

	if not cameraSubject then
		return nil
	end

	if cameraSubject:IsA("Humanoid") and cameraSubject.RootPart then
		local rootPart = cameraSubject.RootPart
		return rootPart.Position.Y - rootPart.Size.Y / 2 - cameraSubject.HipHeight
	end

	return nil
end

function object:UpdateFirstPersonTransform(p, _, p2, _, _)
	if self.needsReset then
		self:StartFadeFromBlack()
		self.needsReset = false
	end

	local position = p2.Position
	local cameraLookVector = self:GetCameraLookVector()
	local unit = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit

	local rotation = self:getRotation(p)

	local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(unit, Vector2.new(rotation, 0))
	return CFrame.new(position - 0.5 * newLookVectorFromArg, position), p2
end

function object:UpdateImmersionCamera(p, _, _, p2, data)
	local v = self:GetSubjectCFrame()
	local currentCamera = workspace.CurrentCamera

	local character = Players.LocalPlayer.Character
	local humanoid = self:GetHumanoid()

	if not humanoid then
		return currentCamera.CFrame, currentCamera.Focus
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return currentCamera.CFrame, currentCamera.Focus
	end

	local prevSubjStep

	if userFlag then
		prevSubjStep = not p2 and 0 or Vector3.new(data.X - p2.X, 0, data.Z - p2.Z).Magnitude
	end

	self.characterOrientation = humanoidRootPart:FindFirstChild("CharacterAlignOrientation")

	if not self.characterOrientation then
		local rootAttachment = humanoidRootPart:FindFirstChild("RootAttachment")

		if not rootAttachment then
			return
		end

		self.characterOrientation = Instance.new("AlignOrientation")
		self.characterOrientation.Name = "CharacterAlignOrientation"
		self.characterOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		self.characterOrientation.Attachment0 = rootAttachment
		self.characterOrientation.RigidityEnabled = true
		self.characterOrientation.Parent = humanoidRootPart
	end

	if self.characterOrientation.Enabled == false then
		self.characterOrientation.Enabled = true
	end

	if self.needsReset then
		self.needsReset = false

		if userFlag3 then
			self:updateImmersionAutoRotate()
		else
			self.savedAutoRotate = humanoid.AutoRotate
			humanoid.AutoRotate = false
		end

		if userFlag then
			VRService:RecenterUserHeadCFrame()
			self.lastTeleportRecenter = tick()
		end

		self:StartFadeFromBlack()
	elseif not humanoid.Sit then
		local estimatedVRTorsoFrame = self.controlModule:GetEstimatedVRTorsoFrame()
		self.characterOrientation.CFrame = currentCamera.CFrame * estimatedVRTorsoFrame

		if self.controlModule.inputMoveVector.Magnitude > 0 then
			self.motionDetTime = 0.1
		end

		if self.controlModule.inputMoveVector.Magnitude > 0 or self.motionDetTime > 0 then
			self.motionDetTime -= p

			local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
			local v2 = userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale

			local humanoidRootPart2 = character.HumanoidRootPart
			local v3 = -0.7 * humanoidRootPart2.Size.Y / 2
			local v4 = currentCamera.CFrame * v2 * CFrame.new(0, v3, 0)
			local lookVector = humanoidRootPart2.CFrame.LookVector
			local v5 = data - (v4 - Vector3.new(lookVector.X, 0, lookVector.Z).Unit * humanoidRootPart2.Size.Y * 0.125).Position + currentCamera.CFrame.Position

			local vector3 = Vector3.new(v5.X, data.Y, v5.Z)

			v = currentCamera.CFrame.Rotation + vector3
		elseif
			userFlag
			and VRCameraTeleportDetector.shouldRecenter(
				self.prevSubjStep,
				prevSubjStep,
				self.lastTeleportRecenter,
				tick()
			)
		then
			local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
			local v2 = userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale

			local humanoidRootPart2 = character.HumanoidRootPart
			local v3 = -0.7 * humanoidRootPart2.Size.Y / 2
			local v4 = currentCamera.CFrame * v2 * CFrame.new(0, v3, 0)
			local lookVector = humanoidRootPart2.CFrame.LookVector
			local v5 = data - (v4 - Vector3.new(lookVector.X, 0, lookVector.Z).Unit * humanoidRootPart2.Size.Y * 0.125).Position + currentCamera.CFrame.Position
			local vector3 = Vector3.new(v5.X, data.Y, v5.Z)
			v = currentCamera.CFrame.Rotation + vector3

			VRService:RecenterUserHeadCFrame()
			self:StartFadeFromBlack()
			self.lastTeleportRecenter = tick()
		else
			v = currentCamera.CFrame.Rotation + Vector3.new(
				currentCamera.CFrame.Position.X,
				data.Y,
				currentCamera.CFrame.Position.Z
			)
		end

		local rotation = self:getRotation(p)

		if math.abs(rotation) > 0 then
			local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
			local cframe = userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale
			local v2 = v * cframe

			v = CFrame.new(v2.Position) * CFrame.Angles(0, -math.rad(rotation * 90), 0) * v2.Rotation * cframe:Inverse()
		end
	end

	if userFlag then
		self.prevSubjStep = prevSubjStep
	end

	return v, v * CFrame.new(0, 0, -0.5)
end

function object:UpdateThirdPersonComfortTransform(p, p2, cframe, p3, lastCameraResetPosition)
	local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
	local v = cameraToSubjectDistance < 0.5 and 0.5 or cameraToSubjectDistance

	if p3 == nil or self.lastCameraFocus == nil then
		return p2, cframe
	end

	local v2 = p3 - lastCameraResetPosition
	local inputMoveVector = self.controlModule.inputMoveVector

	local v3 = v2.magnitude > 0.01 or inputMoveVector.magnitude > 0.01

	if v3 then
		self.motionDetTime = 0.1
	end

	self.motionDetTime -= p

	if (self.motionDetTime > 0 or v3) and not self.needsReset then
		local lastCameraFocus = self.lastCameraFocus

		self.VRCameraFocusFrozen = true
		return p2, lastCameraFocus
	else
		local v4 = self.lastCameraResetPosition == nil
			or (lastCameraResetPosition - self.lastCameraResetPosition).Magnitude > 1

		local rotation = self:getRotation(p)

		if math.abs(rotation) > 0 then
			local objectSpace = cframe:ToObjectSpace(p2)
			p2 = cframe * CFrame.Angles(0, -rotation, 0) * objectSpace
		end

		if not (self.VRCameraFocusFrozen and v4 or self.needsReset) then
			return p2, cframe
		end

		VRService:RecenterUserHeadCFrame()

		self.VRCameraFocusFrozen = false
		self.needsReset = false
		self.lastCameraResetPosition = lastCameraResetPosition

		self:ResetZoom()
		self:StartFadeFromBlack()

		local humanoid = self:GetHumanoid()
		local lookVector = humanoid.Torso and humanoid.Torso.CFrame.lookVector or Vector3.new(1, 0, 0)

		local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
		local v5 = cframe.Position - vector3 * v

		local vector3_2 = Vector3.new(cframe.Position.X, v5.Y, cframe.Position.Z)

		p2 = CFrame.new(v5, vector3_2)

		return p2, cframe
	end
end

function object:UpdateThirdPersonFollowTransform(p, _, _, p2, p3)
	local currentCamera = workspace.CurrentCamera
	local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
	local vrFocus = self:GetVRFocus(p3, p)

	if self.needsReset then
		self.needsReset = false

		VRService:RecenterUserHeadCFrame()
		self:ResetZoom()
		self:StartFadeFromBlack()
	end

	if self.recentered then
		local subjectCFrame = self:GetSubjectCFrame()

		if not subjectCFrame then
			return currentCamera.CFrame, currentCamera.Focus
		end

		local v = vrFocus * subjectCFrame.Rotation * CFrame.new(0, 0, cameraToSubjectDistance)

		self.focusOffset = vrFocus:ToObjectSpace(v)

		self.recentered = false
		return v, vrFocus
	else
		local selected = vrFocus:ToWorldSpace(self.focusOffset)

		local v = p2 - p3
		local controlModule = self.controlModule
		local inputMoveVector = controlModule.inputMoveVector

		if v.magnitude > 0.01 or inputMoveVector.magnitude > 0 then
			local estimatedVRTorsoFrame = controlModule:GetEstimatedVRTorsoFrame()

			local v2 = estimatedVRTorsoFrame.Rotation + estimatedVRTorsoFrame.Position * currentCamera.HeadScale
			local v3 = currentCamera.CFrame * v2
			local lookVector = v3.LookVector

			local v4 = Vector3.new(lookVector.X, 0, lookVector.Z).Unit * cameraToSubjectDistance
			local v5 = vrFocus.Position - v4

			selected = selected:Lerp(
				CFrame.new(currentCamera.CFrame.Position + v5 - v3.Position) * selected.Rotation,
				0.01
			)
		end

		local rotation = self:getRotation(p)

		if math.abs(rotation) > 0 then
			local objectSpace = vrFocus:ToObjectSpace(selected)
			selected = vrFocus * CFrame.Angles(0, -rotation, 0) * objectSpace
		end

		self.focusOffset = vrFocus:ToObjectSpace(selected)

		return selected, selected * CFrame.new(0, 0, -cameraToSubjectDistance)
	end
end

function object:updateImmersionAutoRotate()
	local humanoid = self:GetHumanoid()

	if not humanoid then
		return
	end

	if self:IsInFirstPerson() and VRService.AvatarGestures then
		if not self.autoRotateOverridden then
			self.savedAutoRotate = humanoid.AutoRotate
			self.autoRotateOverridden = true
		end

		humanoid.AutoRotate = false
	elseif self.autoRotateOverridden then
		humanoid.AutoRotate = self.savedAutoRotate
		self.autoRotateOverridden = false
	end
end

function object:OnEnabledChanged()
	VRBaseCamera.OnEnabledChanged(self)

	if not userFlag3 then
		return
	end

	if self.enabled then
		if not self.avatarGesturesChangedConn then
			self.avatarGesturesChangedConn = VRService:GetPropertyChangedSignal("AvatarGestures"):Connect(function()
				self:updateImmersionAutoRotate()
			end)
		end
	elseif self.avatarGesturesChangedConn then
		self.avatarGesturesChangedConn:Disconnect()
		self.avatarGesturesChangedConn = nil
	end
end

function object:LeaveFirstPerson()
	VRBaseCamera.LeaveFirstPerson(self)

	self.needsReset = true

	if self.VRBlur then
		self.VRBlur.Visible = false
	end

	if self.characterOrientation then
		self.characterOrientation.Enabled = false
	end

	if userFlag3 then
		self:updateImmersionAutoRotate()
		return
	end

	local humanoid = self:GetHumanoid()

	if humanoid then
		humanoid.AutoRotate = self.savedAutoRotate
	end
end

return object