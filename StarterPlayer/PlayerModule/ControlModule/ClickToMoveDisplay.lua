local ClickToMoveDisplay = {}

local waypointTexture = "rbxasset://textures/ui/traildot.png"
local endWaypointTexture = "rbxasset://textures/ui/waypoint.png"

local waypointsAlwaysOnTop = false

local udim = UDim2.new(0, 42, 0, 50)

local vector2 = Vector2.new(0, 0.5)
local vector2_2 = Vector2.new(0, 1)

local vector2_3 = Vector2.new(0, 0.5)
local vector2_4 = Vector2.new(0.1, 0.5)
local vector2_5 = Vector2.new(-0.1, 0.5)

local vector2_6 = Vector2.new(1.5, 1.5)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local userFlag = CommonUtils.get("FlagUtil").getUserFlag("UserRaycastUpdateAPI2")

local LocalPlayer = Players.LocalPlayer

local function CreateWaypointTemplates()
	local trailDot = Instance.new("Part")
	trailDot.Size = Vector3.new(1, 1, 1)
	trailDot.Anchored = true
	trailDot.CanCollide = false
	trailDot.Name = "TrailDot"
	trailDot.Transparency = 1
	local trailDotImage = Instance.new("ImageHandleAdornment")
	trailDotImage.Name = "TrailDotImage"
	trailDotImage.Size = vector2_6
	trailDotImage.SizeRelativeOffset = Vector3.new(0, 0, -0.1)
	trailDotImage.AlwaysOnTop = waypointsAlwaysOnTop
	trailDotImage.Image = waypointTexture
	trailDotImage.Adornee = trailDot
	trailDotImage.Parent = trailDot

	local endWaypoint = Instance.new("Part")
	endWaypoint.Size = Vector3.new(2, 2, 2)
	endWaypoint.Anchored = true
	endWaypoint.CanCollide = false
	endWaypoint.Name = "EndWaypoint"
	endWaypoint.Transparency = 1
	local trailDotImage2 = Instance.new("ImageHandleAdornment")
	trailDotImage2.Name = "TrailDotImage"
	trailDotImage2.Size = vector2_6
	trailDotImage2.SizeRelativeOffset = Vector3.new(0, 0, -0.1)
	trailDotImage2.AlwaysOnTop = waypointsAlwaysOnTop
	trailDotImage2.Image = waypointTexture
	trailDotImage2.Adornee = endWaypoint
	trailDotImage2.Parent = endWaypoint
	local endWaypointBillboard = Instance.new("BillboardGui")
	endWaypointBillboard.Name = "EndWaypointBillboard"
	endWaypointBillboard.Size = udim
	endWaypointBillboard.LightInfluence = 0
	endWaypointBillboard.SizeOffset = vector2
	endWaypointBillboard.AlwaysOnTop = true
	endWaypointBillboard.Adornee = endWaypoint
	endWaypointBillboard.Parent = endWaypoint
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = endWaypointTexture
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.new(1, 0, 1, 0)
	imageLabel.Parent = endWaypointBillboard

	local failureWaypoint = Instance.new("Part")
	failureWaypoint.Size = Vector3.new(2, 2, 2)
	failureWaypoint.Anchored = true
	failureWaypoint.CanCollide = false
	failureWaypoint.Name = "FailureWaypoint"
	failureWaypoint.Transparency = 1
	local trailDotImage3 = Instance.new("ImageHandleAdornment")
	trailDotImage3.Name = "TrailDotImage"
	trailDotImage3.Size = vector2_6
	trailDotImage3.SizeRelativeOffset = Vector3.new(0, 0, -0.1)
	trailDotImage3.AlwaysOnTop = waypointsAlwaysOnTop
	trailDotImage3.Image = waypointTexture
	trailDotImage3.Adornee = failureWaypoint
	trailDotImage3.Parent = failureWaypoint
	local failureWaypointBillboard = Instance.new("BillboardGui")
	failureWaypointBillboard.Name = "FailureWaypointBillboard"
	failureWaypointBillboard.Size = udim
	failureWaypointBillboard.LightInfluence = 0
	failureWaypointBillboard.SizeOffset = vector2_3
	failureWaypointBillboard.AlwaysOnTop = true
	failureWaypointBillboard.Adornee = failureWaypoint
	failureWaypointBillboard.Parent = failureWaypoint
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(0, 0, 0, 0)
	frame.Position = UDim2.new(0.5, 0, 1, 0)
	frame.Parent = failureWaypointBillboard
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Image = endWaypointTexture
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Position = UDim2.new(0, -udim.X.Offset / 2, 0, -udim.Y.Offset)
	imageLabel2.Size = udim
	imageLabel2.Parent = frame

	return trailDot, endWaypoint, failureWaypoint
end

local v, v2, v3 = CreateWaypointTemplates()

local function getTrailDotParent() -- 4 equivalent calls inferred from this helper
	local currentCamera = Workspace.CurrentCamera
	local clickToMoveDisplay = currentCamera:FindFirstChild("ClickToMoveDisplay")

	if not clickToMoveDisplay then
		clickToMoveDisplay = Instance.new("Model")
		clickToMoveDisplay.Name = "ClickToMoveDisplay"
		clickToMoveDisplay.Parent = currentCamera
	end

	return clickToMoveDisplay
end

local function placePathWaypoint(clone, vector3: Vector3)
	if userFlag then
		raycastParams.FilterDescendantsInstances = { Workspace.CurrentCamera, LocalPlayer.Character }
		local raycastResult = Workspace:Raycast(vector3 + Vector3.new(0, 2.5, 0), -Vector3.new(0, 10, 0), raycastParams)

		if raycastResult then
			clone.CFrame = CFrame.lookAlong(raycastResult.Position, raycastResult.Normal)
			clone.Parent = getTrailDotParent() -- inferred equivalent call
		end
	else
		local part, v4, v5 = Workspace:FindPartOnRayWithIgnoreList(
			Ray.new(vector3 + Vector3.new(0, 2.5, 0), Vector3.new(0, -10, 0)),
			{ Workspace.CurrentCamera, LocalPlayer.Character }
		)

		if part then
			clone.CFrame = CFrame.new(v4, v4 + v5)
			clone.Parent = getTrailDotParent() -- inferred equivalent call
		end
	end
end

local class = {}
class.__index = class

function class:Destroy()
	self.DisplayModel:Destroy()
end

function class:NewDisplayModel(p)
	local clone = v:Clone()
	placePathWaypoint(clone, p)
	return clone
end

function class.new(p, closestWayPoint)
	local self = setmetatable({}, class)

	self.DisplayModel = self:NewDisplayModel(p)
	self.ClosestWayPoint = closestWayPoint

	return self
end

local class2 = {}
class2.__index = class2

function class2:Destroy()
	self.Destroyed = true
	self.Tween:Cancel()
	self.DisplayModel:Destroy()
end

function class2:NewDisplayModel(p)
	local clone = v2:Clone()
	placePathWaypoint(clone, p)
	return clone
end

function class2:CreateTween()
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true)
	local tween = TweenService:Create(self.DisplayModel.EndWaypointBillboard, tweenInfo, {
		SizeOffset = vector2_2
	})

	tween:Play()
	return tween
end

function class2:TweenInFrom(vector3: Vector3)
	local v4 = vector3 - self.DisplayModel.Position
	self.DisplayModel.EndWaypointBillboard.StudsOffset = Vector3.new(0, v4.Y, 0)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	local tween = TweenService:Create(self.DisplayModel.EndWaypointBillboard, tweenInfo, {
		StudsOffset = Vector3.new(0, 0, 0)
	})
	tween:Play()
	return tween
end

function class2.new(vector3: Vector3, closestWayPoint: number?, vector3_2: Vector3?)
	local object = setmetatable({}, class2)

	object.DisplayModel = object:NewDisplayModel(vector3)
	object.Destroyed = false

	if vector3_2 and (vector3_2 - vector3).Magnitude > 5 then
		object.Tween = object:TweenInFrom(vector3_2)
		coroutine.wrap(function()
			object.Tween.Completed:Wait()

			if not object.Destroyed then
				object.Tween = object:CreateTween()
			end
		end)()
	else
		object.Tween = object:CreateTween()
	end

	object.ClosestWayPoint = closestWayPoint

	return object
end

local class3 = {}
class3.__index = class3

function class3:Hide()
	self.DisplayModel.Parent = nil
end

function class3:Destroy()
	self.DisplayModel:Destroy()
end

function class3:NewDisplayModel(p)
	local clone = v3:Clone()
	placePathWaypoint(clone, p)

	if userFlag then
		raycastParams.FilterDescendantsInstances = { Workspace.CurrentCamera, LocalPlayer.Character }

		local raycastResult = Workspace:Raycast(p + Vector3.new(0, 2.5, 0), -Vector3.new(0, 10, 0), raycastParams)

		if raycastResult then
			clone.CFrame = CFrame.lookAlong(raycastResult.Position, raycastResult.Normal)
			clone.Parent = getTrailDotParent() -- inferred equivalent call
			return clone
		end
	else
		local part, v4, v5 = Workspace:FindPartOnRayWithIgnoreList(
			Ray.new(p + Vector3.new(0, 2.5, 0), Vector3.new(0, -10, 0)),
			{ Workspace.CurrentCamera, LocalPlayer.Character }
		)

		if part then
			clone.CFrame = CFrame.new(v4, v4 + v5)
			clone.Parent = getTrailDotParent() -- inferred equivalent call
		end
	end

	return clone
end

function class3:RunFailureTween()
	wait(0.125)

	local tweenInfo = TweenInfo.new(0.0625, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self.DisplayModel.FailureWaypointBillboard, tweenInfo, {
		SizeOffset = vector2_4
	})

	tween:Play()

	TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame, tweenInfo, {
		Rotation = 10
	}):Play()

	tween.Completed:wait()

	local tweenInfo2 = TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 3, true)

	local tween2 = TweenService:Create(self.DisplayModel.FailureWaypointBillboard, tweenInfo2, {
		SizeOffset = vector2_5
	})

	tween2:Play()

	local tweenInfo3 = TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 3, true)

	TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame.ImageLabel, tweenInfo3, {
		ImageColor3 = Color3.new(0.75, 0.75, 0.75)
	}):Play()

	TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame, tweenInfo3, {
		Rotation = -10
	}):Play()

	tween2.Completed:wait()

	local tweenInfo4 = TweenInfo.new(0.0625, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween3 = TweenService:Create(self.DisplayModel.FailureWaypointBillboard, tweenInfo4, {
		SizeOffset = vector2_3
	})

	tween3:Play()

	TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame, tweenInfo4, {
		Rotation = 0
	}):Play()

	tween3.Completed:wait()

	wait(0.125)
end

function class3.new(p)
	local self = setmetatable({}, class3)

	self.DisplayModel = self:NewDisplayModel(p)

	return self
end

local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://2874840706"

local track = nil

local function getFailureAnimationTrack(playerHumanoid) -- 1 equivalent call inferred from this helper
	if playerHumanoid == nil then
		return track
	end

	track = playerHumanoid:LoadAnimation(animation)
	assert(track, "")
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = false
	return track
end

local function findPlayerHumanoid() -- 1 equivalent call inferred from this helper
	local character = LocalPlayer.Character

	if character then
		return character:FindFirstChildOfClass("Humanoid")
	end
end

local function createTrailDots(list, vector3: Vector3)
	local v4 = {}
	local v5 = 1

	for i = 1, #list - 1 do
		local v6 = (list[i].Position - list[#list].Position).Magnitude < 3
		local v7

		if i % 2 == 0 then
			v7 = not v6
		else
			v7 = false
		end

		if not v7 then
			continue
		end

		v4[v5] = class.new(list[i].Position, i)
		v5 += 1
	end

	table.insert(v4, (class2.new(list[#list].Position, #list, vector3)))

	local trailDots = {}
	local v6 = 1

	for i = #v4, 1, -1 do
		trailDots[v6] = v4[i]
		v6 += 1
	end

	return trailDots
end

local function getTrailDotScale(p: number, vector2_7: Vector2) -- 1 equivalent call inferred from this helper
	return vector2_7 * (math.clamp(p - 10, 0, 90) / 90 * 1.5 + 1)
end

local count = 0

function ClickToMoveDisplay.CreatePathDisplay(list, p)
	count += 1
	local trailDots = createTrailDots(list, p)

	local function removePathBeforePoint(p2)
		for i = #trailDots, 1, -1 do
			local trailDot = trailDots[i]

			if trailDot.ClosestWayPoint <= p2 then
				trailDot:Destroy()
				trailDots[i] = nil
			else
				break
			end
		end
	end

	local v4 = "ClickToMoveResizeTrail" .. count
	local function resizeTrailDots()
		if #trailDots == 0 then
			RunService:UnbindFromRenderStep(v4)
			return
		end

		local position = Workspace.CurrentCamera.CFrame.Position

		for i = 1, #trailDots do
			local trailDotImage = trailDots[i].DisplayModel:FindFirstChild("TrailDotImage")

			if trailDotImage then
				trailDotImage.Size = getTrailDotScale( -- inferred equivalent call
					(trailDots[i].DisplayModel.Position - position).Magnitude,
					vector2_6
				)
			end
		end
	end
	RunService:BindToRenderStep(v4, Enum.RenderPriority.Camera.Value - 1, resizeTrailDots)

	local function removePath()
		removePathBeforePoint(#list)
	end

	return removePath, removePathBeforePoint
end

local v4 = nil
function ClickToMoveDisplay.DisplayFailureWaypoint(p)
	if v4 then
		v4:Hide()
	end

	local v5 = class3.new(p)
	v4 = v5
	coroutine.wrap(function()
		v5:RunFailureTween()
		v5:Destroy()
		v5 = nil
	end)()
end

function ClickToMoveDisplay.CreateEndWaypoint(p)
	return class2.new(p)
end

function ClickToMoveDisplay.PlayFailureAnimation()
	local playerHumanoid = findPlayerHumanoid() -- inferred equivalent call

	if playerHumanoid then
		getFailureAnimationTrack(playerHumanoid):Play() -- inferred equivalent call
	end
end

function ClickToMoveDisplay.CancelFailureAnimation()
	if track ~= nil and track.IsPlaying then
		track:Stop()
	end
end

function ClickToMoveDisplay.SetWaypointTexture(p)
	waypointTexture = p
	v, v2, v3 = CreateWaypointTemplates()
end

function ClickToMoveDisplay.GetWaypointTexture()
	return waypointTexture
end

function ClickToMoveDisplay.SetWaypointRadius(p)
	vector2_6 = Vector2.new(p, p)
	v, v2, v3 = CreateWaypointTemplates()
end

function ClickToMoveDisplay.GetWaypointRadius()
	return vector2_6.X
end

function ClickToMoveDisplay.SetEndWaypointTexture(p)
	endWaypointTexture = p
	v, v2, v3 = CreateWaypointTemplates()
end

function ClickToMoveDisplay.GetEndWaypointTexture()
	return endWaypointTexture
end

function ClickToMoveDisplay.SetWaypointsAlwaysOnTop(p)
	waypointsAlwaysOnTop = p
	v, v2, v3 = CreateWaypointTemplates()
end

function ClickToMoveDisplay.GetWaypointsAlwaysOnTop()
	return waypointsAlwaysOnTop
end

return ClickToMoveDisplay