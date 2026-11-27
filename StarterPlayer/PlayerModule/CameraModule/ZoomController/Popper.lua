local Players = game:GetService("Players")

local CommonUtils = require(script.Parent.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local cameraWrapper = CommonUtils.get("CameraWrapper")
local connectionUtil = CommonUtils.get("ConnectionUtil")

local userFlag = flagUtil.getUserFlag("UserRaycastUpdateAPI2")
local userFlag2 = flagUtil.getUserFlag("UserCurrentCameraUpdate2")
local userFlag3 = flagUtil.getUserFlag("UserPlayerConnectionMemoryLeak")
local v

if userFlag2 then
	v = cameraWrapper.new()
else
	v = nil
end

local v2

if userFlag2 then
	v2 = nil
else
	v2 = game.Workspace.CurrentCamera
end

if userFlag2 then
	v:Enable()
end

local min = math.min
local tan = math.tan
local rad = math.rad

local newRay = Ray.new

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = true
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true

local raycastParams2 = RaycastParams.new()
raycastParams2.IgnoreWater = true
raycastParams2.FilterType = Enum.RaycastFilterType.Include
local v3

if userFlag3 then
	v3 = connectionUtil.new()
else
	v3 = nil
end

local function getTotalTransparency(trussPart) -- 1 equivalent call inferred from this helper
	return 1 - (1 - trussPart.Transparency) * (1 - trussPart.LocalTransparencyModifier)
end

local function eraseFromEnd(list, p) -- 3 equivalent calls inferred from this helper
	for i = #list, p + 1, -1 do
		list[i] = nil
	end
end

local v4 = nil
local v5 = nil
local nearPlaneZ

if userFlag2 then
	local function updateProjection()
		local camera = v:getCamera()
		local v6 = rad(camera.FieldOfView)
		local viewportSize = camera.ViewportSize
		local v7 = viewportSize.X / viewportSize.Y

		v5 = tan(v6 / 2) * 2
		v4 = v7 * v5
	end

	v:Connect("FieldOfView", updateProjection)
	v:Connect("ViewportSize", updateProjection)
	local camera = v:getCamera()
	local fieldOfView = rad(camera.FieldOfView)
	local viewportSize = camera.ViewportSize
	local v6 = viewportSize.X / viewportSize.Y

	v5 = tan(fieldOfView / 2) * 2
	v4 = v6 * v5

	nearPlaneZ = v:getCamera().NearPlaneZ
	v:Connect("NearPlaneZ", function()
		nearPlaneZ = v:getCamera().NearPlaneZ
	end)
else
	local function updateProjection()
		local v6 = rad(v2.FieldOfView)
		local viewportSize = v2.ViewportSize
		local v7 = viewportSize.X / viewportSize.Y
		v5 = tan(v6 / 2) * 2
		v4 = v7 * v5
	end

	v2:GetPropertyChangedSignal("FieldOfView"):Connect(updateProjection)
	v2:GetPropertyChangedSignal("ViewportSize"):Connect(updateProjection)
	local fieldOfView = rad(v2.FieldOfView)
	local viewportSize = v2.ViewportSize
	local v6 = viewportSize.X / viewportSize.Y
	v5 = tan(fieldOfView / 2) * 2
	v4 = v6 * v5

	nearPlaneZ = v2.NearPlaneZ
	v2:GetPropertyChangedSignal("NearPlaneZ"):Connect(function()
		nearPlaneZ = v2.NearPlaneZ
	end)
end

local filterDescendantsInstances = {}

local v6 = {}

local function refreshIgnoreList() -- 4 equivalent calls inferred from this helper
	local v7 = 1
	filterDescendantsInstances = {}

	for _, v8 in pairs(v6) do
		filterDescendantsInstances[v7] = v8
		v7 += 1
	end
end

local function playerAdded(player)
	local function characterAdded(character) -- 1 equivalent call inferred from this helper
		v6[player] = character
		refreshIgnoreList() -- inferred equivalent call
	end
	local function characterRemoving()
		v6[player] = nil
		refreshIgnoreList() -- inferred equivalent call
	end

	if userFlag3 then
		v3:trackConnection(`{player.UserId}CharacterAdded`, player.CharacterAdded:Connect(characterAdded))

		v3:trackConnection(`{player.UserId}CharacterRemoving`, player.CharacterRemoving:Connect(characterRemoving))
	else
		player.CharacterAdded:Connect(characterAdded)
		player.CharacterRemoving:Connect(characterRemoving)
	end

	if player.Character then
		characterAdded(player.Character) -- inferred equivalent call
	end
end

local function playerRemoving(p)
	v6[p] = nil
	refreshIgnoreList() -- inferred equivalent call

	if userFlag3 then
		v3:disconnect(`{p.UserId}CharacterAdded`)
		v3:disconnect(`{p.UserId}CharacterRemoving`)
	end
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)

for _, v7 in ipairs(Players:GetPlayers()) do
	playerAdded(v7)
end

refreshIgnoreList() -- inferred equivalent call
local rootPart = nil
local v7 = nil

if userFlag2 then
	v:Connect("CameraSubject", function()
		local cameraSubject = v:getCamera().CameraSubject

		if cameraSubject and cameraSubject:IsA("Humanoid") then
			v7 = cameraSubject.RootPart
		elseif cameraSubject and cameraSubject:IsA("BasePart") then
			v7 = cameraSubject
		else
			v7 = nil
		end
	end)
else
	v2:GetPropertyChangedSignal("CameraSubject"):Connect(function()
		local cameraSubject = v2.CameraSubject

		if cameraSubject:IsA("Humanoid") then
			v7 = cameraSubject.RootPart
		elseif cameraSubject:IsA("BasePart") then
			v7 = cameraSubject
		else
			v7 = nil
		end
	end)
end

local function canOcclude(trussPart) -- 2 equivalent calls inferred from this helper
	local v8

	if getTotalTransparency(trussPart) < 0.25 then -- inferred equivalent call
		v8 = userFlag or trussPart.CanCollide

		if v8 then
			if rootPart == (trussPart:GetRootPart() or trussPart) then
				return false
			end

			return not trussPart:IsA("TrussPart")
		end
	else
		return false
	end

	return v8
end

local v8 = {
	Vector2.new(0.4, 0),
	Vector2.new(-0.4, 0),
	Vector2.new(0, -0.4),
	Vector2.new(0, 0.4),
	Vector2.new(0, 0.2)
}

local function getCollisionPoint(position, direction)
	if userFlag then
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances

		local raycastResult = workspace:Raycast(position, direction, raycastParams)

		if raycastResult then
			return raycastResult.Position, true
		end
	else
		local count = #filterDescendantsInstances

		repeat
			local part, v9 = workspace:FindPartOnRayWithIgnoreList(
				newRay(position, direction),
				filterDescendantsInstances,
				false,
				true
			)

			if part then
				if part.CanCollide then
					eraseFromEnd(filterDescendantsInstances, count) -- inferred equivalent call
					return v9, true
				end

				filterDescendantsInstances[#filterDescendantsInstances + 1] = part
			end
		until not part

		eraseFromEnd(filterDescendantsInstances, count) -- inferred equivalent call
	end

	return position + direction, false
end

local function queryPoint(p, p2, p3, origin)
	debug.profilebegin("queryPoint")

	local v9 = #filterDescendantsInstances

	local v10 = p3 + nearPlaneZ
	local v11 = p + p2 * v10

	local v12 = 1e999
	local v13 = 1e999

	local count = 0

	if userFlag then
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local v14 = p

		repeat
			local raycastResult = workspace:Raycast(v14, v11 - v14, raycastParams)

			if not raycastResult then
				break
			end

			count += 1

			local instance = raycastResult.Instance
			local position = raycastResult.Position
			local magnitude = (position - p).Magnitude

			if count >= 64 then
				v13 = magnitude
			elseif canOcclude(instance) then -- inferred equivalent call
				raycastParams2.FilterDescendantsInstances = { instance }

				if workspace:Raycast(v11, position - v11, raycastParams2) then
					local v15

					if origin then
						v15 = workspace:Raycast(origin, v11 - origin, raycastParams2)
							or workspace:Raycast(v11, origin - v11, raycastParams2)
					else
						v15 = false
					end

					if v15 then
						v13 = magnitude
					elseif v10 < v12 then
						v12 = magnitude
					end
				else
					v13 = magnitude
				end
			end

			raycastParams:AddToFilter(instance)
			v14 = position - p2 * 0.001
		until v13 < 1e999 or not instance
	else
		local v14 = p

		repeat
			local part, v15 = workspace:FindPartOnRayWithIgnoreList(
				newRay(v14, v11 - v14),
				filterDescendantsInstances,
				false,
				true
			)

			count += 1

			if part then
				local v16 = count >= 64

				if canOcclude(part) or v16 then -- inferred equivalent call
					local v17 = { part }
					local part2 = workspace:FindPartOnRayWithWhitelist(newRay(v11, v15 - v11), v17, true)

					local magnitude = (v15 - p).Magnitude

					if part2 and not v16 then
						local v18

						if origin then
							v18 = workspace:FindPartOnRayWithWhitelist(newRay(origin, v11 - origin), v17, true)
								or workspace:FindPartOnRayWithWhitelist(newRay(v11, origin - v11), v17, true)
						else
							v18 = false
						end

						if v18 then
							v13 = magnitude
						elseif v10 < v12 then
							v12 = magnitude
						end
					else
						v13 = magnitude
					end
				end

				filterDescendantsInstances[#filterDescendantsInstances + 1] = part
				v14 = v15 - p2 * 0.001
			end
		until v13 < 1e999 or not part

		eraseFromEnd(filterDescendantsInstances, v9) -- inferred equivalent call
	end

	debug.profileend()
	return v12 - nearPlaneZ, v13 - nearPlaneZ
end

local function queryViewport(data, p)
	debug.profilebegin("queryViewport")

	local position = data.Position
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v9 = -data.lookVector
	local v10

	if userFlag2 then
		v10 = v:getCamera()
	else
		v10 = v2
	end

	v2 = v10

	local viewportSize = v2.ViewportSize
	local v11 = 1e999
	local v12 = 1e999

	for i = 0, 1 do
		local v13 = rightVector * ((i - 0.5) * v4)

		for j = 0, 1 do
			local v14 = upVector * ((j - 0.5) * v5)

			local v15, v16 = queryPoint(
				position + nearPlaneZ * (v13 + v14),
				v9,
				p,
				v2:ViewportPointToRay(viewportSize.x * i, viewportSize.y * j).Origin
			)

			if v16 < v11 then
				v11 = v16
			end

			if v15 < v12 then
				v12 = v15
			end
		end
	end

	debug.profileend()

	return v12, v11
end

local function testPromotion(data, p, data2): boolean
	debug.profilebegin("testPromotion")

	local position = data.Position
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v9 = -data.lookVector

	debug.profilebegin("extrapolate")

	local magnitude = (getCollisionPoint(position, data2.posVelocity * 1.25) - position).Magnitude

	local magnitude2 = data2.posVelocity.magnitude

	for i = 0, min(1.25, data2.rotVelocity.magnitude + magnitude / magnitude2), 0.0625 do
		local extrapolate = data2.extrapolate(i)

		if p <= queryPoint(extrapolate.Position, -extrapolate.lookVector, p) then
			return false
		end
	end

	debug.profileend()

	debug.profilebegin("testOffsets")

	for _, v10 in ipairs(v8) do
		local collisionPoint = getCollisionPoint(position, rightVector * v10.x + upVector * v10.y)

		if queryPoint(collisionPoint, (position + v9 * p - collisionPoint).Unit, p) == 1e999 then
			return false
		end
	end

	debug.profileend()

	debug.profileend()
	return true
end

local function Popper(p, p2, p3)
	debug.profilebegin("popper")

	rootPart = v7 and v7:GetRootPart() or v7

	local v9, v10 = queryViewport(p, p2)

	if not (v10 < p2) then
		v10 = p2
	end

	if v9 < v10 and testPromotion(p, p2, p3) then
		v10 = v9
	end

	rootPart = nil

	debug.profileend()
	return v10
end

return Popper