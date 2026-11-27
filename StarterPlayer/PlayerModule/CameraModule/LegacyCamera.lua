require(script.Parent:WaitForChild("CameraUtils"))
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))

local Players = game:GetService("Players")

local BaseCamera = require(script.Parent:WaitForChild("BaseCamera"))
local object = setmetatable({}, BaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(BaseCamera.new(), object)

	self.cameraType = Enum.CameraType.Fixed
	self.lastUpdate = tick()
	self.lastDistanceToSubject = nil

	return self
end

function object.GetModuleName(_): string
	return "LegacyCamera"
end

function object:Update(p: number)
	if not self.cameraType then
		return nil, nil
	end

	local now = tick()
	local v = now - self.lastUpdate
	local currentCamera = workspace.CurrentCamera
	local v2 = currentCamera.CFrame
	local v3 = currentCamera.Focus
	local localPlayer = Players.LocalPlayer
	local rotation = CameraInput.getRotation(p)

	if self.lastUpdate == nil or v > 1 then
		self.lastDistanceToSubject = nil
	end

	local subjectPosition = self:GetSubjectPosition()

	if self.cameraType == Enum.CameraType.Fixed then
		if subjectPosition and localPlayer and currentCamera then
			local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
			local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(nil, rotation)

			v3 = currentCamera.Focus

			v2 = CFrame.new(
				currentCamera.CFrame.Position,
				currentCamera.CFrame.Position + cameraToSubjectDistance * newLookVectorFromArg
			)
		end
	elseif self.cameraType == Enum.CameraType.Attach then
		local subjectCFrame = self:GetSubjectCFrame()
		local eulerAnglesYXZ = currentCamera.CFrame:ToEulerAnglesYXZ()
		local _, v4 = subjectCFrame:ToEulerAnglesYXZ()

		local v5 = math.clamp(eulerAnglesYXZ - rotation.Y, -1.3962634015954636, 1.3962634015954636)

		v3 = CFrame.new(subjectCFrame.Position) * CFrame.fromEulerAnglesYXZ(v5, v4, 0)
		v2 = v3 * CFrame.new(0, 0, self:StepZoom(p))
	else
		if self.cameraType ~= Enum.CameraType.Watch then
			return currentCamera.CFrame, currentCamera.Focus
		end

		if subjectPosition and localPlayer and currentCamera then
			local unit = nil

			if subjectPosition == currentCamera.CFrame.Position then
				warn("Camera cannot watch subject in same position as itself")
				return currentCamera.CFrame, currentCamera.Focus
			end

			local humanoid = self:GetHumanoid()

			if humanoid and humanoid.RootPart then
				local v4 = subjectPosition - currentCamera.CFrame.Position
				unit = v4.unit

				if self.lastDistanceToSubject and self.lastDistanceToSubject == self:GetCameraToSubjectDistance() then
					self:SetCameraToSubjectDistance(v4.magnitude)
				end
			end

			local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
			local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(unit, rotation)

			v3 = CFrame.new(subjectPosition)
			v2 = CFrame.new(subjectPosition - cameraToSubjectDistance * newLookVectorFromArg, subjectPosition)

			self.lastDistanceToSubject = cameraToSubjectDistance
		end
	end

	self.lastUpdate = now
	return v2, v3
end

return object