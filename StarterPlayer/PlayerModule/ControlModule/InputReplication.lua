local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local v = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
	or flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationDGA")
local userFlag = flagUtil.getUserFlag("UserControlModuleDisabledUpdate")
local StarterPlayer = game:GetService("StarterPlayer")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local Workspace = game:GetService("Workspace")
local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local userFlag2 = flagUtil.getUserFlag("UserAbilitiesUserInterfaceB")
local v2 = userFlag2 and "ControlState" or "PlayerControlState"
local InputReplication = {}
InputReplication.__index = InputReplication

function InputReplication._calculatePlayerInputValues(player)
	local character = player.Character

	if character == nil then
		return Vector3.new(0, 0, 0), Vector3.new(0, 0, 1), false
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return Vector3.new(0, 0, 0), Vector3.new(0, 0, 1), false
	end

	local inputContexts = player:FindFirstChild("InputContexts")

	if inputContexts == nil then
		return Vector3.new(0, 0, 0), Vector3.new(0, 0, 1), false
	end

	local characterContext = inputContexts:FindFirstChild("CharacterContext")

	if characterContext == nil then
		return Vector3.new(0, 0, 0), Vector3.new(0, 0, 1), false
	end

	local moveAction = characterContext.MoveAction
	local rotationAction = characterContext:FindFirstChild("RotationAction")
	local v3

	if rotationAction == nil then
		v3 = false
	else
		v3 = rotationAction:GetState()
	end

	local function isValidInput2D(vector2: Vector2): boolean
		return vector2.X == vector2.X and vector2.Y == vector2.Y and vector2.X ~= 1e999 and vector2.Y ~= 1e999
	end

	local function isValidInput3D(vector3: Vector3): boolean
		return vector3.X == vector3.X
			and vector3.Y == vector3.Y
			and vector3.Z == vector3.Z
			and vector3.X ~= 1e999
			and vector3.Y ~= 1e999
			and vector3.Z ~= 1e999
	end

	local v4

	if moveAction == nil then
		v4 = Vector2.new(0, 0)
	else
		v4 = moveAction:GetState()
	end

	local vector = player:GetCameraState().CFrame.LookVector

	if
		v4.X ~= v4.X
		or v4.Y ~= v4.Y
		or v4.X == 1e999
		or v4.Y == 1e999
		or vector.X ~= vector.X
		or vector.Y ~= vector.Y
		or vector.Z ~= vector.Z
		or vector.X == 1e999
		or vector.Y == 1e999
		or vector.Z == 1e999
		or not (vector.Magnitude > 0)
	then
		return Vector3.new(0, 0, 0), Vector3.new(0, 0, 1), false
	end

	if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Swimming then
		vector = Vector3.new(vector.X, 0, vector.Z).Unit
	end

	local unit = vector:Cross(Vector3.new(0, 1, 0)).Unit

	return vector * v4.Y + unit * v4.X, vector, v3
end

function InputReplication.CloneInputsIfAbsent(parent)
	if parent:FindFirstChild("InputContexts") then
		return
	end

	local clone = StarterPlayer.PlayerModule.InputContexts:Clone()
	clone.CharacterContext.Enabled = true
	clone.CameraContext.Enabled = true
	clone.Parent = parent
end

function InputReplication.FireCustomInputs(instance)
	local inputContexts = instance:FindFirstChild("InputContexts")

	if not inputContexts then
		return
	end

	local characterContext = inputContexts:FindFirstChild("CharacterContext")

	if not (characterContext and inputContexts:FindFirstChild("CameraContext")) then
		return
	end

	local rotationAction = characterContext:FindFirstChild("RotationAction")

	local rotationScriptableBinding = rotationAction and rotationAction:FindFirstChild("RotationScriptableBinding")

	if rotationScriptableBinding then
		rotationScriptableBinding:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
	end
end

function InputReplication.SendInputToCCLCharacter(instance)
	if not instance then
		return
	end

	local v3 = AvatarAbilitiesInterface.get(instance)
	local inputContexts = instance:FindFirstChild("InputContexts")

	if not inputContexts then
		return
	end

	local characterContext = inputContexts:FindFirstChild("CharacterContext")

	if not characterContext then
		return
	end

	for _, v4 in v3:GetAbilities() do
		local child = characterContext:FindFirstChild(v4 .. "Action")

		if child then
			v3:SendInput(v4, child:GetState())
		end
	end

	local playerInputValues, v4, v5 = InputReplication._calculatePlayerInputValues(instance)
	v3:SendInput("Move", playerInputValues)
	v3:SendInput("CameraLookDirection", v4)
	v3:SendInput("CameraRelativeRotation", v5)
end

function InputReplication.SendInputToHumanoidForServerAuth(player)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	local inputContexts = player:FindFirstChild("InputContexts")

	if inputContexts == nil then
		return
	end

	local characterContext = inputContexts:FindFirstChild("CharacterContext")

	if characterContext == nil then
		return
	end

	local jumpAction = characterContext.JumpAction

	local playerInputValues, v3, v4 = InputReplication._calculatePlayerInputValues(player)
	humanoid:Move(playerInputValues)
	humanoid.AutoRotate = not v4

	if
		v4
		and humanoid.SeatPart == nil
		and humanoid.RootPart ~= nil
		and not (humanoid.Sit or humanoid.RootPart:IsGrounded())
	then
		humanoid.RootPart.CFrame = CFrame.new(humanoid.RootPart.CFrame.Position, humanoid.RootPart.CFrame.Position + v3)
	end

	humanoid.Jump = jumpAction ~= nil and jumpAction:GetState()
end

function InputReplication.setupPlayerControlState(object)
	object:AddVector3Field("Move", Vector3.new(0, 0, 0), 1)
	object:AddBoolField("Jump", false)
	object:AddBoolField("RotateToLookDirection", false)
	object:AddUnitVector3Field("LookDirection", Vector3.new(0, 0, 1))
end

function InputReplication.watchForPlayerControlState(player)
	local function watchCharacter(instance)
		local function onPCSAdded(instance2)
			if instance2:IsA(v2) then
				InputReplication.setupPlayerControlState(instance2)
			end
		end
		local firstChildOfClass = instance:FindFirstChildOfClass(v2)

		if firstChildOfClass then
			InputReplication.setupPlayerControlState(firstChildOfClass)
		end

		instance.ChildAdded:Connect(onPCSAdded)
	end

	if player.Character then
		local character = player.Character

		local function onPCSAdded(instance)
			if instance:IsA(v2) then
				InputReplication.setupPlayerControlState(instance)
			end
		end
		local firstChildOfClass = character:FindFirstChildOfClass(v2)

		if firstChildOfClass then
			InputReplication.setupPlayerControlState(firstChildOfClass)
		end

		character.ChildAdded:Connect(onPCSAdded)
	end

	player.CharacterAdded:Connect(watchCharacter)
end

function InputReplication.createPlayerControlState(owner)
	local function createForCharacter(parent)
		if userFlag2 then
			if parent:FindFirstChildOfClass(v2) then
				return
			end
		elseif parent:FindFirstChild(v2) then
			return
		end

		local instance = Instance.new(v2)
		instance.Owner = owner
		instance.Parent = parent
		InputReplication.setupPlayerControlState(instance)
	end

	if owner.Character then
		local character = owner.Character
		local instance

		if userFlag2 then
			if not character:FindFirstChildOfClass(v2) then
				instance = Instance.new(v2)
				instance.Owner = owner
				instance.Parent = character
				InputReplication.setupPlayerControlState(instance)
			end
		elseif not character:FindFirstChild(v2) then
			instance = Instance.new(v2)
			instance.Owner = owner
			instance.Parent = character
			InputReplication.setupPlayerControlState(instance)
		end
	end

	owner.CharacterAdded:Connect(createForCharacter)
end

function InputReplication.writeInputToCS(player, p)
	assert(not userFlag)
	local data = p.data

	local character = player.Character

	if not character then
		return
	end

	local v3

	if userFlag2 then
		v3 = character:FindFirstChildOfClass(v2)
	else
		v3 = character:FindFirstChild(v2)
	end

	if not (v3 and p.humanoid) then
		return
	end

	local isJumping = data.controlModule.isJumping
	local worldMoveVector = data.controlModule.worldMoveVector

	local rotateToLookDirection = UserGameSettings.RotationType == Enum.RotationType.CameraRelative
	local lookVector = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.LookVector or Vector3.new(0, 0, 1)
	local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
	local v4 = {
		Move = worldMoveVector,
		RotateToLookDirection = rotateToLookDirection,
		LookDirection = not (vector3.Magnitude > 0.001) and Vector3.new(0, 0, 1) or vector3.Unit
	}

	if not (v and AvatarAbilitiesInterface.get(player):isEnabled()) then
		v4.Jump = isJumping
	end

	v3:UpdateFields(v4)
end

function InputReplication.processPCSInputs(player)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	local v3

	if userFlag2 then
		v3 = character:FindFirstChildOfClass(v2)
	else
		v3 = character:FindFirstChild(v2)
	end

	if v3 == nil then
		return
	end

	local state = v3:GetState()
	local move = state.Move
	local jump = state.Jump
	local rotateToLookDirection = state.RotateToLookDirection
	local lookDirection = state.LookDirection

	if move then
		humanoid:Move(move)
	end

	humanoid.AutoRotate = not rotateToLookDirection

	if
		rotateToLookDirection
		and lookDirection ~= nil
		and humanoid.RootPart ~= nil
		and not humanoid.Sit
		and humanoid.SeatPart == nil
		and not humanoid.RootPart:IsGrounded()
	then
		humanoid.RootPart.CFrame = CFrame.new(
			humanoid.RootPart.CFrame.Position,
			humanoid.RootPart.CFrame.Position + lookDirection
		)
	end

	humanoid.Jump = jump or false
end

return InputReplication