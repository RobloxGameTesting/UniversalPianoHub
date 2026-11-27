local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserExcludeNonCollidableForPathfinding")
end)

local v = success and result

local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserClickToMoveSupportAgentCanClimb2")
end)

local v2 = success2 and result2

local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")

local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")

local userFlag = flagUtil.getUserFlag("UserRaycastUpdateAPI2")
local userFlag2 = flagUtil.getUserFlag("UserPSIASClickToMoveRelaxTeleport")
local userFlag3 = flagUtil.getUserFlag("UserPlayerScriptsRefactor2")
local userFlag4 = flagUtil.getUserFlag("UserDoubleJumpButtonFix")

local characterContext = script.Parent.Parent:WaitForChild("InputContexts"):WaitForChild("CharacterContext")
local clickToMoveAction = characterContext:WaitForChild("ClickToMoveAction")
local clickToMovePositionAction = characterContext:WaitForChild("ClickToMovePositionAction")

local showPath = true
local failureAnimationEnabled = true
local useDirectPath = false

local v3 = 1
local unreachableWaypointTimeout = 8

local LocalPlayer = Players.LocalPlayer

local ClickToMoveDisplay = require(script.Parent:WaitForChild("ClickToMoveDisplay"))

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local v4 = {}

if not userFlag then
	local function FindCharacterAncestor(parent)
		if not parent then
			return
		end

		local humanoid = parent:FindFirstChildOfClass("Humanoid")

		if humanoid then
			return parent, humanoid
		end

		return FindCharacterAncestor(parent.Parent)
	end
	v4.FindCharacterAncestor = FindCharacterAncestor
	local function Raycast(p, flag: boolean, parts)
		local parts2 = parts or {}
		local part, v5, v6, v7 = Workspace:FindPartOnRayWithIgnoreList(p, parts2)

		if not part then
			return nil, nil
		end

		if not flag or part.CanCollide ~= false then
			return part, v5, v6, v7
		end

		local v8

		if part then
			v8 = part:FindFirstChildOfClass("Humanoid")

			if not v8 then
				local _
				_, v8 = FindCharacterAncestor(part.Parent)
			end
		end

		if v8 == nil then
			table.insert(parts2, part)
			return Raycast(p, flag, parts2)
		end

		return part, v5, v6, v7
	end

	v4.Raycast = Raycast
end

local v5 = {}
local function findPlayerHumanoid(localPlayer) -- 2 equivalent calls inferred from this helper
	local character = localPlayer and localPlayer.Character

	if not character then
		return
	end

	local v6 = v5[localPlayer]

	if v6 and v6.Parent == character then
		return v6
	end

	v5[localPlayer] = nil
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		v5[localPlayer] = humanoid
	end

	return humanoid
end

local ignoreList = nil
local ignoredPartsTag = nil

local connection = nil
local connection2 = nil

local function GetCharacter() -- 4 equivalent calls inferred from this helper
	return LocalPlayer and LocalPlayer.Character
end

local function UpdateIgnoreTag(p)
	if p == ignoredPartsTag then
		return
	end

	if connection then
		connection:Disconnect()
		connection = nil
	end

	if connection2 then
		connection2:Disconnect()
		connection2 = nil
	end

	ignoredPartsTag = p
	ignoreList = { GetCharacter() } -- inferred equivalent call

	if ignoredPartsTag ~= nil then
		local tagged = CollectionService:GetTagged(ignoredPartsTag)

		for _, v6 in ipairs(tagged) do
			table.insert(ignoreList, v6)
		end

		connection = CollectionService:GetInstanceAddedSignal(ignoredPartsTag):Connect(function(p2)
			table.insert(ignoreList, p2)
		end)
		connection2 = CollectionService:GetInstanceRemovedSignal(ignoredPartsTag):Connect(function(p2)
			for i = 1, #ignoreList do
				if ignoreList[i] == p2 then
					ignoreList[i] = ignoreList[#ignoreList]
					table.remove(ignoreList)
					break
				end
			end
		end)
	end
end

local function getIgnoreList() -- 4 equivalent calls inferred from this helper
	if ignoreList then
		return ignoreList
	end

	ignoreList = {}
	assert(ignoreList, "")
	table.insert(ignoreList, GetCharacter()) -- inferred equivalent call
	return ignoreList
end

local function minV(vector3: Vector3, vector3_2: Vector3) -- 1 equivalent call inferred from this helper
	return (Vector3.new(
		math.min(vector3.X, vector3_2.X),
		math.min(vector3.Y, vector3_2.Y),
		(math.min(vector3.Z, vector3_2.Z))
	))
end

local function maxV(data, data2) -- 1 equivalent call inferred from this helper
	return (Vector3.new(math.max(data.X, data2.X), math.max(data.Y, data2.Y), (math.max(data.Z, data2.Z))))
end

local function getCollidableExtentsSize(folder)
	if folder == nil or folder.PrimaryPart == nil then
		return
	end

	assert(folder, "")
	assert(folder.PrimaryPart, "")
	local inverse = folder.PrimaryPart.CFrame:Inverse()
	local v6 = Vector3.new(1e999, 1e999, 1e999)
	local v7 = Vector3.new(-1e999, -1e999, -1e999)

	for _, part in pairs(folder:GetDescendants()) do
		if not (part:IsA("BasePart") and part.CanCollide) then
			continue
		end

		local v8 = inverse * part.CFrame
		local vector3 = Vector3.new(part.Size.X / 2, part.Size.Y / 2, part.Size.Z / 2)
		local v9 = {
			Vector3.new(vector3.X, vector3.Y, vector3.Z),
			Vector3.new(vector3.X, vector3.Y, -vector3.Z),
			Vector3.new(vector3.X, -vector3.Y, vector3.Z),
			Vector3.new(vector3.X, -vector3.Y, -vector3.Z),
			Vector3.new(-vector3.X, vector3.Y, vector3.Z),
			Vector3.new(-vector3.X, vector3.Y, -vector3.Z),
			Vector3.new(-vector3.X, -vector3.Y, vector3.Z),
			(Vector3.new(-vector3.X, -vector3.Y, -vector3.Z))
		}

		for _, v10 in ipairs(v9) do
			local v11 = v8 * v10
			v6 = minV(v6, v11) -- inferred equivalent call
			v7 = maxV(v7, v11) -- inferred equivalent call
		end
	end

	local v8 = v7 - v6
	return if not (v8.X < 0 or v8.Y < 0 or v8.Z < 0) then v8 else nil
end

local function Pather(p, targetSurfaceNormal, directPath: boolean?)
	local class = {}
	local directPath2

	if directPath == nil then
		directPath2 = useDirectPath
		directPath = true
	else
		directPath2 = directPath
	end

	class.Cancelled = false
	class.Started = false

	class.Finished = Instance.new("BindableEvent")
	class.PathFailed = Instance.new("BindableEvent")

	class.PathComputing = false
	class.PathComputed = false

	class.OriginalTargetPoint = p
	class.TargetPoint = p
	class.TargetSurfaceNormal = targetSurfaceNormal

	class.DiedConn = nil
	class.SeatedConn = nil
	class.BlockedConn = nil
	class.TeleportedConn = nil

	class.CurrentPoint = 0

	class.HumanoidOffsetFromPath = Vector3.new(0, 0, 0)

	class.CurrentWaypointPosition = nil
	class.CurrentWaypointPlaneNormal = Vector3.new(0, 0, 0)
	class.CurrentWaypointPlaneDistance = 0
	class.CurrentWaypointNeedsJump = false

	class.CurrentHumanoidPosition = Vector3.new(0, 0, 0)
	class.CurrentHumanoidVelocity = 0

	class.NextActionMoveDirection = Vector3.new(0, 0, 0)
	class.NextActionJump = false

	class.Timeout = 0
	class.Humanoid = findPlayerHumanoid(LocalPlayer) -- inferred equivalent call
	class.OriginPoint = nil
	class.AgentCanFollowPath = false
	class.DirectPath = false
	class.DirectPathRiseFirst = false

	class.stopTraverseFunc = nil
	class.setPointFunc = nil
	class.pointList = nil

	local rootPart = class.Humanoid and class.Humanoid.RootPart

	if rootPart then
		class.OriginPoint = rootPart.CFrame.Position

		local agentRadius = 2
		local agentHeight = 5
		local agentCanJump = true

		local seatPart = class.Humanoid.SeatPart

		if seatPart and seatPart:IsA("VehicleSeat") then
			local model = seatPart:FindFirstAncestorOfClass("Model")

			if model then
				local primaryPart = model.PrimaryPart
				model.PrimaryPart = seatPart

				if directPath then
					local extentsSize = model:GetExtentsSize()
					agentRadius = v3 * 0.5 * math.sqrt(extentsSize.X * extentsSize.X + extentsSize.Z * extentsSize.Z)
					agentHeight = v3 * extentsSize.Y

					class.AgentCanFollowPath = true
					class.DirectPath = directPath
					agentCanJump = false
				end

				model.PrimaryPart = primaryPart
			end
		else
			local v6 = nil

			if v then
				local character = GetCharacter() -- inferred equivalent call

				if character ~= nil then
					v6 = getCollidableExtentsSize(character)
				end
			end

			if v6 == nil then
				v6 = GetCharacter():GetExtentsSize() -- inferred equivalent call
			end

			assert(v6, "")
			agentRadius = v3 * 0.5 * math.sqrt(v6.X * v6.X + v6.Z * v6.Z)
			agentHeight = v3 * v6.Y
			agentCanJump = class.Humanoid.JumpPower > 0
			class.AgentCanFollowPath = true
			class.DirectPath = directPath2
			class.DirectPathRiseFirst = class.Humanoid.Sit
		end

		if v2 then
			class.pathResult = PathfindingService:CreatePath({
				AgentRadius = agentRadius,
				AgentHeight = agentHeight,
				AgentCanJump = agentCanJump,
				AgentCanClimb = true
			})
		else
			class.pathResult = PathfindingService:CreatePath({
				AgentRadius = agentRadius,
				AgentHeight = agentHeight,
				AgentCanJump = agentCanJump
			})
		end
	end

	function class:Cleanup()
		if class.stopTraverseFunc then
			class.stopTraverseFunc()
			class.stopTraverseFunc = nil
		end

		if class.BlockedConn then
			class.BlockedConn:Disconnect()
			class.BlockedConn = nil
		end

		if class.DiedConn then
			class.DiedConn:Disconnect()
			class.DiedConn = nil
		end

		if class.SeatedConn then
			class.SeatedConn:Disconnect()
			class.SeatedConn = nil
		end

		if class.TeleportedConn then
			class.TeleportedConn:Disconnect()
			class.TeleportedConn = nil
		end

		class.Started = false
	end

	function class:Cancel()
		class.Cancelled = true
		class:Cleanup()
	end

	function class:IsActive()
		return class.AgentCanFollowPath and class.Started and not class.Cancelled
	end

	function class:OnPathInterrupted()
		class.Cancelled = true
		class:OnPointReached(false)
	end

	function class:ComputePath()
		if class.OriginPoint then
			if class.PathComputed or class.PathComputing then
				return
			end

			class.PathComputing = true

			if class.AgentCanFollowPath then
				if class.DirectPath then
					class.pointList = {
						PathWaypoint.new(class.OriginPoint, Enum.PathWaypointAction.Walk),
						PathWaypoint.new(
							class.TargetPoint,
							class.DirectPathRiseFirst and Enum.PathWaypointAction.Jump or Enum.PathWaypointAction.Walk
						)
					}

					class.PathComputed = true
				else
					class.pathResult:ComputeAsync(class.OriginPoint, class.TargetPoint)
					class.pointList = class.pathResult:GetWaypoints()
					class.BlockedConn = class.pathResult.Blocked:Connect(function(p2)
						class:OnPathBlocked(p2)
					end)
					class.PathComputed = class.pathResult.Status == Enum.PathStatus.Success
				end
			end

			class.PathComputing = false
		end
	end

	function class:IsValidPath()
		class:ComputePath()
		return class.PathComputed and class.AgentCanFollowPath
	end

	class.Recomputing = false
	function class:OnPathBlocked(p2)
		if not (class.CurrentPoint <= p2) or class.Recomputing then
			return
		end

		class.Recomputing = true

		if class.stopTraverseFunc then
			class.stopTraverseFunc()
			class.stopTraverseFunc = nil
		end

		class.OriginPoint = class.Humanoid.RootPart.CFrame.Position

		class.pathResult:ComputeAsync(class.OriginPoint, class.TargetPoint)
		class.pointList = class.pathResult:GetWaypoints()

		if #class.pointList > 0 then
			class.HumanoidOffsetFromPath = class.pointList[1].Position - class.OriginPoint
		end

		class.PathComputed = class.pathResult.Status == Enum.PathStatus.Success

		if showPath then
			local pathDisplay, setPointFunc = ClickToMoveDisplay.CreatePathDisplay(class.pointList)
			class.stopTraverseFunc = pathDisplay
			class.setPointFunc = setPointFunc
		end

		if class.PathComputed then
			class.CurrentPoint = 1
			class:OnPointReached(true)
		else
			class.PathFailed:Fire()
			class:Cleanup()
		end

		class.Recomputing = false
	end

	function class:OnRenderStepped(p2: number)
		if class.Started and not class.Cancelled then
			class.Timeout += p2
			local timeout = class.Timeout

			if unreachableWaypointTimeout < timeout then
				class:OnPointReached(false)
				return
			end

			class.CurrentHumanoidPosition = class.Humanoid.RootPart.Position + class.HumanoidOffsetFromPath
			class.CurrentHumanoidVelocity = class.Humanoid.RootPart.Velocity

			while class.Started and class:IsCurrentWaypointReached() do
				class:OnPointReached(true)
			end

			if class.Started then
				class.NextActionMoveDirection = class.CurrentWaypointPosition - class.CurrentHumanoidPosition

				if class.NextActionMoveDirection.Magnitude > 1e-6 then
					class.NextActionMoveDirection = class.NextActionMoveDirection.Unit
				else
					class.NextActionMoveDirection = Vector3.new(0, 0, 0)
				end

				if class.CurrentWaypointNeedsJump then
					class.NextActionJump = true
					class.CurrentWaypointNeedsJump = false
				else
					class.NextActionJump = false
				end
			end
		end
	end

	function class:IsCurrentWaypointReached()
		local v6 = class.CurrentWaypointPlaneNormal == Vector3.new(0, 0, 0)
			or class.CurrentWaypointPlaneNormal:Dot(class.CurrentHumanoidPosition) - class.CurrentWaypointPlaneDistance < math.max(
				1,
				0.0625 * -class.CurrentWaypointPlaneNormal:Dot(class.CurrentHumanoidVelocity)
			)

		if v6 then
			class.CurrentWaypointPosition = nil
			class.CurrentWaypointPlaneNormal = Vector3.new(0, 0, 0)
			class.CurrentWaypointPlaneDistance = 0
		end

		return v6
	end

	function class:OnPointReached(p2)
		if p2 and not class.Cancelled then
			if class.setPointFunc then
				class.setPointFunc(class.CurrentPoint)
			end

			local v6 = class.CurrentPoint + 1

			if #class.pointList < v6 then
				if class.stopTraverseFunc then
					class.stopTraverseFunc()
				end

				class.Finished:Fire()
				class:Cleanup()
			else
				local point = class.pointList[class.CurrentPoint]
				local point2 = class.pointList[v6]

				local state = class.Humanoid:GetState()

				if
					state == Enum.HumanoidStateType.FallingDown
					or state == Enum.HumanoidStateType.Freefall
					or state == Enum.HumanoidStateType.Jumping
				then
					local v7 = point2.Action == Enum.PathWaypointAction.Jump

					if not v7 and class.CurrentPoint > 1 then
						local point3 = class.pointList[class.CurrentPoint - 1]

						local v8 = point.Position - point3.Position
						local v9 = point2.Position - point.Position

						v7 = Vector2.new(v8.x, v8.z).Unit:Dot(Vector2.new(v9.x, v9.z).Unit) < 0.996
					end

					if v7 then
						class.Humanoid.FreeFalling:Wait()

						wait(0.1)
					end
				end

				class:MoveToNextWayPoint(point, point2, v6)
			end
		else
			class.PathFailed:Fire()
			class:Cleanup()
		end
	end

	function class:MoveToNextWayPoint(p2, data, currentPoint: number)
		class.CurrentWaypointPlaneNormal = p2.Position - data.Position

		if not v2 or data.Label ~= "Climb" then
			class.CurrentWaypointPlaneNormal = Vector3.new(
				class.CurrentWaypointPlaneNormal.X,
				0,
				class.CurrentWaypointPlaneNormal.Z
			)
		end

		if class.CurrentWaypointPlaneNormal.Magnitude > 1e-6 then
			class.CurrentWaypointPlaneNormal = class.CurrentWaypointPlaneNormal.Unit
			class.CurrentWaypointPlaneDistance = class.CurrentWaypointPlaneNormal:Dot(data.Position)
		else
			class.CurrentWaypointPlaneNormal = Vector3.new(0, 0, 0)
			class.CurrentWaypointPlaneDistance = 0
		end

		class.CurrentWaypointNeedsJump = data.Action == Enum.PathWaypointAction.Jump

		class.CurrentWaypointPosition = data.Position

		class.CurrentPoint = currentPoint

		class.Timeout = 0
	end

	function class:Start(p2)
		if not class.AgentCanFollowPath then
			class.PathFailed:Fire()
			return
		end

		if class.Started then
			return
		end

		class.Started = true

		ClickToMoveDisplay.CancelFailureAnimation()

		if showPath and (p2 == nil or p2) then
			local pathDisplay, setPointFunc = ClickToMoveDisplay.CreatePathDisplay(
				class.pointList,
				class.OriginalTargetPoint
			)
			class.stopTraverseFunc = pathDisplay
			class.setPointFunc = setPointFunc
		end

		if #class.pointList > 0 then
			class.HumanoidOffsetFromPath = Vector3.new(0, class.pointList[1].Position.Y - class.OriginPoint.Y, 0)

			class.CurrentHumanoidPosition = class.Humanoid.RootPart.Position + class.HumanoidOffsetFromPath
			class.CurrentHumanoidVelocity = class.Humanoid.RootPart.Velocity

			class.SeatedConn = class.Humanoid.Seated:Connect(function(_, _)
				class:OnPathInterrupted()
			end)
			class.DiedConn = class.Humanoid.Died:Connect(function()
				class:OnPathInterrupted()
			end)

			if userFlag2 then
				class.lastPosition = class.Humanoid.RootPart.CFrame.Position
				class.TeleportedConn = class.Humanoid.RootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
					local position = class.Humanoid.RootPart.CFrame.Position
					local magnitude = (position - class.lastPosition).Magnitude
					class.lastPosition = position

					if class.Humanoid.WalkSpeed < magnitude then
						class:OnPathInterrupted()
					end
				end)
			else
				class.TeleportedConn = class.Humanoid.RootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
					class:OnPathInterrupted()
				end)
			end

			class.CurrentPoint = 1
			class:OnPointReached(true)
		else
			class.PathFailed:Fire()

			if class.stopTraverseFunc then
				class.stopTraverseFunc()
			end
		end
	end

	local v6 = class.TargetPoint + class.TargetSurfaceNormal * 1.5

	if userFlag then
		raycastParams.FilterDescendantsInstances = getIgnoreList() -- inferred equivalent call
		local raycastResult = Workspace:Raycast(v6, -Vector3.new(0, 50, 0), raycastParams)

		if raycastResult then
			class.TargetPoint = raycastResult.Position
		end
	else
		local part, targetPoint = Workspace:FindPartOnRayWithIgnoreList(
			Ray.new(v6, Vector3.new(0, -50, 0)),
			getIgnoreList() -- inferred equivalent call
		)

		if part then
			class.TargetPoint = targetPoint
		end
	end

	class:ComputePath()

	return class
end

local function CheckAlive(): boolean -- 1 equivalent call inferred from this helper
	local playerHumanoid = findPlayerHumanoid(LocalPlayer) -- inferred equivalent call
	return playerHumanoid ~= nil and playerHumanoid.Health > 0
end

local function GetEquippedTool(instance)
	if instance ~= nil then
		for _, tool in pairs(instance:GetChildren()) do
			if tool:IsA("Tool") then
				return tool
			end
		end
	end
end

local function DisconnectEvent(connection3) -- 10 equivalent calls inferred from this helper
	if connection3 then
		connection3:Disconnect()
	end
end

local function calculateLocalMoveVector(nextActionMoveDirection: Vector3)
	local vector3 = Vector3.new(nextActionMoveDirection.X, 0, nextActionMoveDirection.Z)

	if vector3.Magnitude < 1e-6 then
		return Vector2.zero
	end

	local unit = vector3.Unit
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return Vector2.new(unit.X, -unit.Z)
	end

	local _, v6, _ = currentCamera.CFrame:ToEulerAnglesYXZ()
	local vectorToObjectSpace = CFrame.Angles(0, v6, 0):VectorToObjectSpace(unit)
	return Vector2.new(vectorToObjectSpace.X, -vectorToObjectSpace.Z)
end

local ClickToMoveController = {}
ClickToMoveController.__index = ClickToMoveController

function ClickToMoveController.new(_)
	local self = setmetatable({}, ClickToMoveController)

	self.mouse2DownTime = tick()
	self.mouse2DownPos = Vector2.new()
	self.mouse2UpTime = tick()

	self.humanoidDiedConn = nil
	self.characterChildAddedConn = nil
	self.onCharacterAddedConn = nil
	self.characterChildRemovedConn = nil
	self.renderSteppedConn = nil
	self.menuOpenedConnection = nil
	self.preferredInputChangedConnection = nil

	if not userFlag4 then
		self.jumpEnabled = true
	end

	self.clickPressedConn = nil
	self.clickReleasedConn = nil
	self.shouldCleanupPath = false
	self.lastPatherJumped = false
	self.data = nil

	self.running = false

	return self
end

local v6 = nil

local eventConnection = nil
local eventConnection2 = nil

function ClickToMoveController:CleanupPath()
	if v6 then
		v6:Cancel()
		v6 = nil
	end

	if eventConnection then
		eventConnection:Disconnect()
		eventConnection = nil
	end

	if eventConnection2 then
		eventConnection2:Disconnect()
		eventConnection2 = nil
	end

	self.shouldCleanupPath = true
end

function ClickToMoveController:HandleMoveTo(object, p, p2, p3, p4)
	self.shouldCleanupPath = false

	if v6 then
		self:CleanupPath()
	end

	v6 = object
	object:Start(p4)

	eventConnection = object.Finished.Event:Connect(function()
		self:CleanupPath()

		local v7 = p2 and GetEquippedTool(p3)

		if v7 then
			v7:Activate()
		end
	end)
	eventConnection2 = object.PathFailed.Event:Connect(function()
		self:CleanupPath()

		if p4 == nil or p4 then
			local v7 = failureAnimationEnabled

			if v7 then
				v7 = not (v6 and v6:IsActive())
			end

			if v7 then
				ClickToMoveDisplay.PlayFailureAnimation()
			end

			ClickToMoveDisplay.DisplayFailureWaypoint(p)
		end
	end)
end

function ClickToMoveController:ShowPathFailedFeedback(p)
	if v6 and v6:IsActive() then
		v6:Cancel()
	end

	if failureAnimationEnabled then
		ClickToMoveDisplay.PlayFailureAnimation()
	end

	ClickToMoveDisplay.DisplayFailureWaypoint(p)
end

function ClickToMoveController:OnTap(list, vector3: Vector3?)
	local currentCamera = Workspace.CurrentCamera
	local character = LocalPlayer.Character

	if not CheckAlive() then -- inferred equivalent call
		return
	end

	if #list == 1 or vector3 then
		if currentCamera then
			local screenPointToRay = currentCamera:ScreenPointToRay(list[1].X, list[1].Y)

			if userFlag then
				local v7 = nil
				local parents = getIgnoreList() or {} -- inferred equivalent call
				local raycastResult

				repeat
					local flag = true
					raycastParams.FilterDescendantsInstances = parents
					raycastResult = Workspace:Raycast(
						screenPointToRay.Origin,
						screenPointToRay.Direction * 1000,
						raycastParams
					)

					if raycastResult then
						local v8 = raycastResult.Instance

						if not v8.CanCollide then
							local humanoid, parent

							while true do
								humanoid = v8:FindFirstChildOfClass("Humanoid")

								parent = v8.Parent

								if humanoid or not parent then
									break
								end

								v8 = parent
							end

							if humanoid or not parent then
								v7 = v8
							else
								table.insert(parents, parent)
								flag = false
								v7 = nil
							end
						end
					end
				until flag

				if not (raycastResult and character) then
					return
				end

				local v8 = raycastResult.Position

				if vector3 then
					v8 = vector3
					v7 = nil
				end

				self:CleanupPath()
				local pather = Pather(v8, raycastResult.Normal)

				if pather:IsValidPath() then
					self:HandleMoveTo(pather, v8, v7, character)
					return
				end

				pather:Cleanup()

				self:ShowPathFailedFeedback(v8)
			else
				local ray = Ray.new(screenPointToRay.Origin, screenPointToRay.Direction * 1000)
				local v7, v8, v9 = v4.Raycast(ray, true, getIgnoreList()) -- inferred equivalent call

				local characterAncestor, _ = v4.FindCharacterAncestor(v7)

				if vector3 then
					v8 = vector3
					characterAncestor = nil
				end

				if v8 and character then
					self:CleanupPath()
					local pather = Pather(v8, v9)

					if pather:IsValidPath() then
						self:HandleMoveTo(pather, v8, characterAncestor, character)
						return
					end

					pather:Cleanup()

					self:ShowPathFailedFeedback(v8)
				end
			end
		end
	else
		local v7 = #list >= 2 and currentCamera and GetEquippedTool(character)

		if v7 then
			v7:Activate()
		end
	end
end

function ClickToMoveController:DisconnectEvents()
	DisconnectEvent(self.humanoidDiedConn) -- inferred equivalent call
	DisconnectEvent(self.characterChildAddedConn) -- inferred equivalent call
	DisconnectEvent(self.onCharacterAddedConn) -- inferred equivalent call
	DisconnectEvent(self.renderSteppedConn) -- inferred equivalent call
	DisconnectEvent(self.characterChildRemovedConn) -- inferred equivalent call
	DisconnectEvent(self.menuOpenedConnection) -- inferred equivalent call
	DisconnectEvent(self.preferredInputChangedConnection) -- inferred equivalent call
	DisconnectEvent(self.clickPressedConn) -- inferred equivalent call
	DisconnectEvent(self.clickReleasedConn) -- inferred equivalent call
end

function ClickToMoveController:OnPreferredInputChanged()
	local character = LocalPlayer.Character

	if character then
		local manualActivationOnly = UserInputService.PreferredInput == Enum.PreferredInput.Touch

		for _, tool in pairs(character:GetChildren()) do
			if tool:IsA("Tool") then
				tool.ManualActivationOnly = manualActivationOnly
			end
		end
	end
end

function ClickToMoveController:OnCharacterAdded(instance)
	self:DisconnectEvents()

	self.clickPressedConn = clickToMoveAction.Pressed:Connect(function()
		local guiInset, _ = GuiService:GetGuiInset()
		local state = clickToMovePositionAction:GetState()

		if state.X == -1 and state.Y == -1 then
			return
		end

		local vector2

		if userFlag3 then
			local min = GuiService:GetInsetArea(Enum.ScreenInsets.None).Min
			vector2 = Vector2.new(state.X + min.X, state.Y + min.Y)
		else
			vector2 = Vector2.new(state.X - guiInset.X, state.Y - guiInset.Y)
		end

		self.mouse2DownPos = vector2
		self.mouse2DownTime = tick()
	end)

	self.clickReleasedConn = clickToMoveAction.Released:Connect(function()
		self.mouse2UpTime = tick()
		local mouse2DownPos = self.mouse2DownPos

		if not (self.data and self.data.controlModule.actions.MoveAction) then
			return
		end

		local v7 = v6 or self.data.controlModule.actions.MoveAction:GetState().Magnitude <= 0

		if self.mouse2UpTime - self.mouse2DownTime < 0.25 and v7 then
			self:OnTap({ mouse2DownPos })
		end
	end)

	self.menuOpenedConnection = GuiService.MenuOpened:Connect(function()
		self:CleanupPath()
	end)

	local function OnCharacterChildAdded(child)
		if UserInputService.PreferredInput == Enum.PreferredInput.Touch and child:IsA("Tool") then
			child.ManualActivationOnly = true
		end

		if child:IsA("Humanoid") then
			DisconnectEvent(self.humanoidDiedConn) -- inferred equivalent call
			self.humanoidDiedConn = child.Died:Connect(function() end)
		end
	end

	self.characterChildAddedConn = instance.ChildAdded:Connect(function(child)
		OnCharacterChildAdded(child)
	end)
	self.characterChildRemovedConn = instance.ChildRemoved:Connect(function(tool)
		if UserInputService.PreferredInput == Enum.PreferredInput.Touch and tool:IsA("Tool") then
			tool.ManualActivationOnly = false
		end
	end)

	for _, child in pairs(instance:GetChildren()) do
		OnCharacterChildAdded(child)
	end

	self.preferredInputChangedConnection = UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		self:OnPreferredInputChanged()
	end)
end

function ClickToMoveController:Start()
	self:Enable(true)
end

function ClickToMoveController:Stop()
	self:Enable(false)
end

function ClickToMoveController:Enable(enabled: boolean, flag: boolean, touchJumpController)
	if enabled then
		if not self.running then
			if LocalPlayer.Character then
				self:OnCharacterAdded(LocalPlayer.Character)
			end

			self.onCharacterAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)
				self:OnCharacterAdded(character)
			end)
			self.running = true
		end

		if not userFlag4 then
			self.touchJumpController = touchJumpController

			if self.touchJumpController then
				self.touchJumpController:Enable(self.jumpEnabled)
			end
		end
	else
		if self.running then
			self:DisconnectEvents()
			self:CleanupPath()

			if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
				local character = LocalPlayer.Character

				if character then
					for _, tool in pairs(character:GetChildren()) do
						if tool:IsA("Tool") then
							tool.ManualActivationOnly = false
						end
					end
				end
			end

			self.running = false
		end

		if not userFlag4 then
			if self.touchJumpController and not self.jumpEnabled then
				self.touchJumpController:Enable(true)
			end

			self.touchJumpController = nil
		end
	end

	clickToMoveAction.Enabled = enabled
	clickToMovePositionAction.Enabled = enabled

	self.wasdEnabled = enabled and flag or false
	self.enabled = enabled
end

function ClickToMoveController:Update(p, p2)
	assert(p.controlModule.actions.MoveAction)
	assert(p.controlModule.actions.JumpAction)

	if not self.data then
		self.data = p
	end

	local v7 = v6

	if v7 then
		v7:OnRenderStepped(p2)

		if v6 and v6 == v7 then
			local moveVector = calculateLocalMoveVector(v7.NextActionMoveDirection)
			local clickToMoveScriptableBinding = p.controlModule.actions.MoveAction:FindFirstChild("ClickToMoveScriptableBinding")

			if clickToMoveScriptableBinding then
				clickToMoveScriptableBinding:Fire(moveVector)
			end

			p.controlModule.moveVector = moveVector

			if v7.NextActionJump then
				local clickToMoveScriptableBinding2 = p.controlModule.actions.JumpAction:GetState() ~= true
					and p.controlModule.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

				if clickToMoveScriptableBinding2 then
					clickToMoveScriptableBinding2:Fire(true)
				end

				self.lastPatherJumped = true
				p.controlModule.isJumping = true
			elseif self.lastPatherJumped then
				local clickToMoveScriptableBinding2 = p.controlModule.actions.JumpAction:GetState() == true
					and p.controlModule.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

				if clickToMoveScriptableBinding2 then
					clickToMoveScriptableBinding2:Fire(false)
				end

				self.lastPatherJumped = false
				p.controlModule.isJumping = false
			end
		elseif self.lastPatherJumped then
			local clickToMoveScriptableBinding = p.controlModule.actions.JumpAction:GetState() == true
				and p.controlModule.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

			if clickToMoveScriptableBinding then
				clickToMoveScriptableBinding:Fire(false)
			end

			self.lastPatherJumped = false
		end
	end

	if self.shouldCleanupPath then
		self.shouldCleanupPath = false
		local clickToMoveScriptableBinding = p.controlModule.actions.MoveAction:FindFirstChild("ClickToMoveScriptableBinding")

		if clickToMoveScriptableBinding then
			clickToMoveScriptableBinding:Fire(Vector2.zero)
		end

		p.controlModule.moveVector = Vector2.zero
		self.lastPatherJumped = false
		local clickToMoveScriptableBinding2 = p.controlModule.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

		if clickToMoveScriptableBinding2 then
			clickToMoveScriptableBinding2:Fire(false)
		end

		p.controlModule.isJumping = false
	end
end

function ClickToMoveController.SetShowPath(_, p)
	showPath = p
end

function ClickToMoveController.GetShowPath(_)
	return showPath
end

function ClickToMoveController.SetWaypointTexture(_, p)
	ClickToMoveDisplay.SetWaypointTexture(p)
end

function ClickToMoveController.GetWaypointTexture(_)
	return ClickToMoveDisplay.GetWaypointTexture()
end

function ClickToMoveController.SetWaypointRadius(_, p)
	ClickToMoveDisplay.SetWaypointRadius(p)
end

function ClickToMoveController.GetWaypointRadius(_)
	return ClickToMoveDisplay.GetWaypointRadius()
end

function ClickToMoveController.SetEndWaypointTexture(_, p)
	ClickToMoveDisplay.SetEndWaypointTexture(p)
end

function ClickToMoveController.GetEndWaypointTexture(_)
	return ClickToMoveDisplay.GetEndWaypointTexture()
end

function ClickToMoveController.SetWaypointsAlwaysOnTop(_, p)
	ClickToMoveDisplay.SetWaypointsAlwaysOnTop(p)
end

function ClickToMoveController.GetWaypointsAlwaysOnTop(_)
	return ClickToMoveDisplay.GetWaypointsAlwaysOnTop()
end

function ClickToMoveController.SetFailureAnimationEnabled(_, p)
	failureAnimationEnabled = p
end

function ClickToMoveController.GetFailureAnimationEnabled(_)
	return failureAnimationEnabled
end

function ClickToMoveController.SetIgnoredPartsTag(_, p)
	UpdateIgnoreTag(p)
end

function ClickToMoveController.GetIgnoredPartsTag(_)
	return ignoredPartsTag
end

function ClickToMoveController.SetUseDirectPath(_, p)
	useDirectPath = p
end

function ClickToMoveController.GetUseDirectPath(_)
	return useDirectPath
end

function ClickToMoveController.SetAgentSizeIncreaseFactor(_, p: number)
	v3 = p / 100 + 1
end

function ClickToMoveController.GetAgentSizeIncreaseFactor(_)
	return (v3 - 1) * 100
end

function ClickToMoveController.SetUnreachableWaypointTimeout(_, p)
	unreachableWaypointTimeout = p
end

function ClickToMoveController.GetUnreachableWaypointTimeout(_)
	return unreachableWaypointTimeout
end

if not userFlag4 then
	function ClickToMoveController:SetUserJumpEnabled(jumpEnabled)
		self.jumpEnabled = jumpEnabled

		if self.touchJumpController then
			self.touchJumpController:Enable(jumpEnabled)
		end
	end

	function ClickToMoveController.GetUserJumpEnabled(p)
		return p.jumpEnabled
	end
end

function ClickToMoveController:MoveTo(p, p2, p3): boolean
	local character = LocalPlayer.Character

	if character == nil then
		return false
	end

	local pather = Pather(p, Vector3.new(0, 1, 0), p3)

	if pather and pather:IsValidPath() then
		self:HandleMoveTo(pather, p, nil, character, p2)
		return true
	end

	return false
end

return ClickToMoveController