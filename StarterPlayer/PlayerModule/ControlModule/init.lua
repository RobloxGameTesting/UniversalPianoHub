local ControlModule = {}
ControlModule.__index = ControlModule

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local StarterPlayer = game:GetService("StarterPlayer")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local VRService = game:GetService("VRService")
local ContextActionService = game:GetService("ContextActionService")

local CommonUtils = require(script.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local userFlag = flagUtil.getUserFlag("UserVRFixCameraCloseArticulation")
local v = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
	or flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationDGA")
local userFlag2 = flagUtil.getUserFlag("UserPlayerScriptsBindActivateOnIAS")
local v2 = flagUtil.getUserFlag("UserPlayerScriptsPlayerControlState2")
	or flagUtil.getUserFlag("UserPlayerScriptsPlayerControlState2GA")
local userFlag3 = flagUtil.getUserFlag("UserPlayerScriptsTaskDeferSimulation")
local userFlag4 = flagUtil.getUserFlag("UserPlayerScriptsFixSAuthRenderStepMove")
local userFlag5 = flagUtil.getUserFlag("UserPlayerScriptsSupportMicroGamepad")
local userFlag6 = flagUtil.getUserFlag("UserAbilitiesUserInterfaceA")
local userFlag7 = flagUtil.getUserFlag("UserAbilitiesUserInterfaceC")
local userFlag8 = flagUtil.getUserFlag("UserPSUseBindToAnimation")
local userFlag9 = flagUtil.getUserFlag("UserServerAuthorityDontSetAutoRotate")
local userFlag10 = flagUtil.getUserFlag("UserPlayerModuleEngineAPI")
local userFlag11 = flagUtil.getUserFlag("UserControlModuleDisabledUpdate")

local v3 = { SERVER_AUTHORITY_CHANGED = "SERVER_AUTHORITY_CHANGED" }

local ActionController = require(script:WaitForChild("ActionController"))
local InputReplication

if v or v2 then
	InputReplication = require(script:WaitForChild("InputReplication"))
else
	InputReplication = nil
end

local InputSlots

if v then
	InputSlots = require(script:WaitForChild("InputSlots"))
else
	InputSlots = nil
end

local DynamicThumbstick

if RunService:IsClient() then
	DynamicThumbstick = require(script:WaitForChild("DynamicThumbstick"))
else
	DynamicThumbstick = nil
end

local ClassicThumbstick = require(script:WaitForChild("ClassicThumbstick"))

local ClickToMoveController = require(script:WaitForChild("ClickToMoveController"))
local TouchJump = require(script:WaitForChild("TouchJump"))
local TouchAbilities

if v then
	TouchAbilities = require(script:WaitForChild("TouchAbilities"))
else
	TouchAbilities = nil
end

local AbilitiesOverflowMenu

if v then
	AbilitiesOverflowMenu = require(script:WaitForChild("AbilitiesOverflowMenu"))
else
	AbilitiesOverflowMenu = nil
end

local AbilitiesKeybindBar

if v then
	AbilitiesKeybindBar = require(script:WaitForChild("AbilitiesKeybindBar"))
else
	AbilitiesKeybindBar = nil
end

local VehicleController = require(script:WaitForChild("VehicleController"))
local AvatarAbilitiesInterface, v4

if v then
	AvatarAbilitiesInterface = require(script:WaitForChild("AvatarAbilitiesInterface"))
	v4 = AvatarAbilitiesInterface.get(Players.LocalPlayer)
else
	v4 = nil
	AvatarAbilitiesInterface = nil
end

local cameraRotationAction = script.Parent:WaitForChild("InputContexts"):WaitForChild("CameraContext"):WaitForChild("CameraRotationAction")

local value = Enum.ContextActionPriority.Medium.Value

local vrFirstPersonState = CommonUtils.get("VRFirstPersonState")

local v5 = {
	[Enum.TouchMovementMode.DPad] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.DPad] = DynamicThumbstick,
	[Enum.TouchMovementMode.Thumbpad] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.Thumbpad] = DynamicThumbstick,
	[Enum.TouchMovementMode.Thumbstick] = ClassicThumbstick,
	[Enum.DevTouchMovementMode.Thumbstick] = ClassicThumbstick,
	[Enum.TouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
	[Enum.TouchMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.DevTouchMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.TouchMovementMode.Default] = DynamicThumbstick,
	[Enum.ComputerMovementMode.Default] = ActionController,
	[Enum.ComputerMovementMode.KeyboardMouse] = ActionController,
	[Enum.DevComputerMovementMode.KeyboardMouse] = ActionController,
	[Enum.DevComputerMovementMode.Scriptable] = nil,
	[Enum.ComputerMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.DevComputerMovementMode.ClickToMove] = ClickToMoveController
}

function ControlModule.new()
	local object = setmetatable({}, ControlModule)

	if RunService:IsServer() then
		return object
	end

	object.controllers = {}

	object.activeControlModule = nil
	object.activeController = nil
	object.touchJumpController = nil
	object.touchAbilitiesController = nil
	object.abilitiesOverflowController = nil
	object.abilitiesKeybindBarController = nil
	object.moveFunction = Players.LocalPlayer.Move
	object.humanoid = nil
	object.controlsEnabled = true
	object.enabled = false

	object.humanoidSeatedConn = nil
	object.vehicleController = nil

	object.touchControlFrame = nil
	object.abilitiesGui = nil
	object.abilitiesFrame = nil
	object.currentTorsoAngle = 0

	object.inputMoveVector = Vector3.new(0, 0, 0)

	object.renderedRotationOverride = nil

	object.vehicleController = VehicleController.new()

	if not userFlag10 then
		Players.LocalPlayer.CharacterAdded:Connect(function(character)
			object:OnCharacterAdded(character)
		end)
		Players.LocalPlayer.CharacterRemoving:Connect(function(character)
			object:OnCharacterRemoving(character)
		end)

		if Players.LocalPlayer.Character then
			object:OnCharacterAdded(Players.LocalPlayer.Character)
		end
	end

	UserGameSettings:GetPropertyChangedSignal("TouchMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)
	Players.LocalPlayer:GetPropertyChangedSignal("DevTouchMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)

	UserGameSettings:GetPropertyChangedSignal("ComputerMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)
	Players.LocalPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)

	if v then
		v4:GetEnabledChangedSignal():Connect(function()
			object:UpdateAbilitiesControllers()
		end)
	end

	object.playerGui = nil
	object.touchGui = nil
	object.playerGuiAddedConn = nil

	GuiService:GetPropertyChangedSignal("TouchControlsEnabled"):Connect(function()
		object:UpdateMovementMode()
		object:UpdateActiveControlModuleEnabled()
	end)

	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		object:UpdateMovementMode()
	end)

	object.playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not object.playerGui then
		object.playerGuiAddedConn = Players.LocalPlayer.ChildAdded:Connect(function(playerGui)
			if playerGui:IsA("PlayerGui") then
				object.playerGui = playerGui
				object.playerGuiAddedConn:Disconnect()
				object.playerGuiAddedConn = nil
				object:UpdateMovementMode()

				if v then
					object:UpdateAbilitiesControllers()
				end
			end
		end)
	end

	if userFlag2 then
		ContextActionService:BindActivate(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)
	end

	return object
end

local function _fireCustomInputs(localPlayer)
	assert(not userFlag11)
	local inputContexts = localPlayer:FindFirstChild("InputContexts")

	if inputContexts == nil then
		return
	end

	local characterContext = inputContexts:FindFirstChild("CharacterContext")

	if characterContext == nil then
		return
	end

	local rotationAction = characterContext:FindFirstChild("RotationAction")

	local rotationScriptableBinding = rotationAction and rotationAction:FindFirstChild("RotationScriptableBinding")

	if rotationScriptableBinding then
		rotationScriptableBinding:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
	end
end

function ControlModule:restoreSimulatedRotation()
	local renderedRotationOverride = self.renderedRotationOverride

	if renderedRotationOverride == nil then
		return
	end

	if renderedRotationOverride.rootPart.Parent ~= nil then
		renderedRotationOverride.rootPart.CFrame = CFrame.new(renderedRotationOverride.rootPart.CFrame.Position) * renderedRotationOverride.simulatedRotation
	end

	self.renderedRotationOverride = nil
end

function ControlModule:applyRenderedRotation()
	local currentCamera = Workspace.CurrentCamera
	local humanoid = self.humanoid
	local rootPart = humanoid and humanoid.RootPart

	if
		currentCamera == nil
		or rootPart == nil
		or humanoid.Sit
		or humanoid.SeatPart ~= nil
		or rootPart:IsGrounded()
		or humanoid:GetState() == Enum.HumanoidStateType.Swimming
	then
		return
	end

	local lookVector = currentCamera.CFrame.LookVector
	local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector3.Magnitude < 0.001 then
		return
	end

	if self.renderedRotationOverride ~= nil and self.renderedRotationOverride.rootPart ~= rootPart then
		self:restoreSimulatedRotation()
	end

	if self.renderedRotationOverride == nil then
		self.renderedRotationOverride = {
			rootPart = rootPart,
			simulatedRotation = rootPart.CFrame.Rotation
		}
	end

	local position = rootPart.CFrame.Position
	rootPart.CFrame = CFrame.lookAt(position, position + vector3)
end

local function _cloneInputs(parent) -- 1 equivalent call inferred from this helper
	local clone = StarterPlayer.PlayerModule.InputContexts:Clone()
	clone.CharacterContext.Enabled = true
	clone.CameraContext.Enabled = true
	clone.Parent = parent
end

function ControlModule:InitializeServerAuthority()
	if RunService:IsServer() then
		if v then
			for k, v6 in Players:GetPlayers() do
				InputReplication.CloneInputsIfAbsent(v6)
			end

			Players.PlayerAdded:Connect(InputReplication.CloneInputsIfAbsent)
		else
			for k, v6 in Players:GetPlayers() do
				_cloneInputs(v6) -- inferred equivalent call
			end

			Players.PlayerAdded:Connect(_cloneInputs)
		end

		if v2 then
			for k, v6 in Players:GetPlayers() do
				InputReplication.createPlayerControlState(v6)
			end

			Players.PlayerAdded:Connect(InputReplication.createPlayerControlState)
		end

		if v and userFlag3 then
			for k, v6 in Players:GetPlayers() do
				AvatarAbilitiesInterface.get(v6)
			end

			Players.PlayerAdded:Connect(function(player)
				AvatarAbilitiesInterface.get(player)
			end)
		end

		if userFlag8 then
			RunService:BindToAnimation(function(p)
				for k, v6 in Players:GetPlayers() do
					self:ProcessInputs(v6, p)
				end
			end, Enum.StepFrequency.Hz60)
		else
			RunService:BindToSimulation(function(p)
				for k, v6 in Players:GetPlayers() do
					self:ProcessInputs(v6, p)
				end
			end, Enum.StepFrequency.Hz60)
		end
	else
		if v2 then
			InputReplication.watchForPlayerControlState(Players.LocalPlayer)
		end

		if userFlag9 then
			RunService.PreAnimation:Connect(function()
				self:restoreSimulatedRotation()
			end)
		end

		RunService:BindToRenderStep("CameraInput", Enum.RenderPriority.Last.Value, function()
			if not userFlag11 then
				if v2 then
					InputReplication.writeInputToCS(Players.LocalPlayer, self)
				elseif v then
					InputReplication.FireCustomInputs(Players.LocalPlayer)
				else
					_fireCustomInputs(Players.LocalPlayer)
				end
			end

			if
				userFlag9
				and UserGameSettings.RotationType == Enum.RotationType.CameraRelative
				and not (v and v4:isEnabled())
			then
				self:applyRenderedRotation()
			end
		end)

		if userFlag8 then
			RunService:BindToAnimation(function(p)
				self:ProcessInputs(Players.LocalPlayer, p)
			end, Enum.StepFrequency.Hz60)
		else
			RunService:BindToSimulation(function(p)
				self:ProcessInputs(Players.LocalPlayer, p)
			end, Enum.StepFrequency.Hz60)
		end
	end

	if self.data and self.data.eventBus then
		self.data.isServerAuthority = true
		self.data.eventBus:publish("SERVER_AUTHORITY_CHANGED", true)
	end
end

local function NormalizeAngle(p) -- 4 equivalent calls inferred from this helper
	local angle = (p + 12.566370614359172) % 6.283185307179586

	if angle > 3.141592653589793 then
		angle -= 6.283185307179586
	end

	return angle
end

local function AverageAngle(p, p2) -- 1 equivalent call inferred from this helper
	return NormalizeAngle(p + NormalizeAngle(p2 - p) / 2) -- inferred equivalent call
end

function ControlModule:GetEstimatedVRTorsoFrame()
	local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local eulerAnglesYXZ, v6, v7 = userCFrame:ToEulerAnglesYXZ()
	local currentTorsoAngle = -v6

	if
		VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand)
		and VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand)
	then
		local userCFrame2 = VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)
		local userCFrame3 = VRService:GetUserCFrame(Enum.UserCFrame.RightHand)

		local v8 = userCFrame.Position - userCFrame2.Position
		local v9 = userCFrame.Position - userCFrame3.Position
		local averageAngle = AverageAngle(-math.atan2(v8.X, v8.Z), -math.atan2(v9.X, v9.Z)) -- inferred equivalent call

		local angle = NormalizeAngle(currentTorsoAngle - self.currentTorsoAngle) -- inferred equivalent call
		local v10
		local angle2 = NormalizeAngle(averageAngle - self.currentTorsoAngle) -- inferred equivalent call

		if angle2 > -1.5707963267948966 then
			v10 = angle2 < 1.5707963267948966
		else
			v10 = false
		end

		if not v10 then
			angle2 = angle
		end

		local v11 = math.min(angle2, angle)
		local v12 = math.max(angle2, angle)

		local v13 = 0

		if v11 > 0 then
			v13 = v11
		elseif v12 < 0 then
			v13 = v12
		end

		self.currentTorsoAngle = v13 + self.currentTorsoAngle
	else
		self.currentTorsoAngle = currentTorsoAngle
	end

	return CFrame.new(userCFrame.Position) * CFrame.fromEulerAnglesYXZ(0, -self.currentTorsoAngle, 0)
end

function ControlModule.GetActiveController(p)
	return p.activeController
end

function ControlModule:UpdateAbilitiesControllers()
	local v6 = self.enabled and self.touchControlFrame

	if v6 then
		if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
			v6 = self.activeControlModule == ClickToMoveController
				or self.activeControlModule == ClassicThumbstick
				or self.activeControlModule == DynamicThumbstick
		else
			v6 = false
		end
	end

	local v7 = v6 and not v4:isEnabled()
	local v8 = v6 and v4:isEnabled()

	if v7 then
		if not self.controllers[TouchJump] then
			self.controllers[TouchJump] = TouchJump.new(self.data)
		end

		self.touchJumpController = self.controllers[TouchJump]
		self.touchJumpController:Enable(true, self.touchControlFrame)
	elseif self.touchJumpController then
		if v8 then
			self.touchJumpController:Destroy()
			self.controllers[TouchJump] = nil
			self.touchJumpController = nil
		else
			self.touchJumpController:Enable(false)
		end
	end

	if v8 then
		if not self.controllers[TouchAbilities] then
			self.controllers[TouchAbilities] = TouchAbilities.new(self.touchControlFrame)
		end

		self.touchAbilitiesController = self.controllers[TouchAbilities]
		self.touchAbilitiesController:Enable(true)
	elseif self.touchAbilitiesController then
		if v7 then
			self.touchAbilitiesController:Destroy()
			self.controllers[TouchAbilities] = nil
			self.touchAbilitiesController = nil
		else
			self.touchAbilitiesController:Enable(false)
		end
	end

	if self.enabled and userFlag6 and userFlag7 and v4:isEnabled() then
		if not self.abilitiesGui then
			self:CreateAbilitiesGuiContainer()
		end

		if self.abilitiesGui then
			if not self.controllers[AbilitiesOverflowMenu] then
				self.controllers[AbilitiesOverflowMenu] = AbilitiesOverflowMenu.new(self.abilitiesFrame)
			end

			self.abilitiesOverflowController = self.controllers[AbilitiesOverflowMenu]
			self.abilitiesOverflowController:Enable(true)

			if AbilitiesKeybindBar then
				if not self.controllers[AbilitiesKeybindBar] then
					self.controllers[AbilitiesKeybindBar] = AbilitiesKeybindBar.new(self.abilitiesGui)
				end

				self.abilitiesKeybindBarController = self.controllers[AbilitiesKeybindBar]
				self.abilitiesKeybindBarController:Enable(true)
			end

			self.abilitiesGui.Enabled = true
		end
	else
		if self.abilitiesOverflowController then
			self.abilitiesOverflowController:Enable(false)
		end

		if self.abilitiesKeybindBarController then
			self.abilitiesKeybindBarController:Enable(false)
		end

		if self.abilitiesGui then
			self.abilitiesGui.Enabled = false
		end
	end
end

function ControlModule:UpdateActiveControlModuleEnabled()
	local function fn()
		if v then
			self.enabled = false
		end

		self.activeController:Enable(false)

		if v then
			self:UpdateAbilitiesControllers()
		elseif self.touchJumpController then
			self.touchJumpController:Enable(false)
		end

		if self.moveFunction and not (v and v4:isEnabled()) then
			self.moveFunction(Players.LocalPlayer, Vector3.new(0, 0, 0), true)
		end
	end

	local function fn2()
		if v then
			self.enabled = true
			self:UpdateAbilitiesControllers()
		elseif
			self.touchControlFrame
			and UserInputService.PreferredInput == Enum.PreferredInput.Touch
			and (self.activeControlModule == ClickToMoveController or self.activeControlModule == ClassicThumbstick or self.activeControlModule == DynamicThumbstick)
		then
			if not self.controllers[TouchJump] then
				self.controllers[TouchJump] = TouchJump.new(self.data)
			end

			self.touchJumpController = self.controllers[TouchJump]
			self.touchJumpController:Enable(true, self.touchControlFrame)
		elseif self.touchJumpController then
			self.touchJumpController:Enable(false)
		end

		if self.activeControlModule == ClickToMoveController then
			self.activeController:Enable(
				true,
				Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.UserChoice,
				self.touchJumpController
			)
		elseif self.touchControlFrame then
			self.activeController:Enable(true, self.touchControlFrame)
		else
			self.activeController:Enable(true)
		end
	end

	if not self.activeController then
		return
	end

	if not self.controlsEnabled then
		fn()
	elseif
		GuiService.TouchControlsEnabled
		or UserInputService.PreferredInput ~= Enum.PreferredInput.Touch
		or self.activeControlModule ~= ClickToMoveController
		and self.activeControlModule ~= ClassicThumbstick
		and self.activeControlModule ~= DynamicThumbstick
	then
		fn2()
	else
		fn()
	end
end

function ControlModule:Enable(flag: boolean?)
	if userFlag11 then
		warn("ControlModule:Enable() and ControlModule:Disable() are deprecated and will be removed soon; set require(\"@rbx/PlayerModule\").ControlModule.Enabled instead")

		return
	end

	local controlsEnabled = flag == nil or flag

	if self.controlsEnabled == controlsEnabled then
		return
	end

	self.controlsEnabled = controlsEnabled

	if not self.activeController then
		return
	end

	self:UpdateActiveControlModuleEnabled()
end

function ControlModule:Disable()
	self:Enable(false)
end

function ControlModule:SelectComputerMovementModule()
	local v6 = false

	if userFlag5 then
		pcall(function()
			v6 = UserInputService.PreferredInput == Enum.PreferredInput.MicroGamepad
		end)
	end

	if
		UserInputService.PreferredInput ~= Enum.PreferredInput.KeyboardAndMouse
		and UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad
		and not v6
	then
		return nil, false
	end

	local v7 = ActionController
	local devComputerMovementMode = Players.LocalPlayer.DevComputerMovementMode

	if devComputerMovementMode == Enum.DevComputerMovementMode.UserChoice then
		if UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove then
			v7 = ClickToMoveController
		end
	else
		v7 = v5[devComputerMovementMode]

		if not v7 and devComputerMovementMode ~= Enum.DevComputerMovementMode.Scriptable then
			warn("No character control module is associated with DevComputerMovementMode ", devComputerMovementMode)
		end
	end

	if v7 then
		return v7, true
	end

	if devComputerMovementMode == Enum.DevComputerMovementMode.Scriptable then
		return nil, true
	end

	return nil, false
end

function ControlModule:SelectTouchModule()
	local devTouchMovementMode = Players.LocalPlayer.DevTouchMovementMode
	local v6

	if devTouchMovementMode == Enum.DevTouchMovementMode.UserChoice then
		v6 = v5[UserGameSettings.TouchMovementMode]

		return v6, true
	end

	if devTouchMovementMode == Enum.DevTouchMovementMode.Scriptable then
		return nil, true
	end

	v6 = v5[devTouchMovementMode]

	return v6, true
end

function ControlModule:calculateRawMoveVector(object, vector3: Vector3)
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return vector3
	end

	local cframe = currentCamera.CFrame

	if VRService.VREnabled and object.RootPart then
		local estimatedVRTorsoFrame = self:GetEstimatedVRTorsoFrame()

		if (currentCamera.Focus.Position - cframe.Position).Magnitude < 3 then
			cframe *= estimatedVRTorsoFrame
		else
			cframe = currentCamera.CFrame * (estimatedVRTorsoFrame.Rotation + estimatedVRTorsoFrame.Position * currentCamera.HeadScale)
		end
	end

	if object:GetState() == Enum.HumanoidStateType.Swimming then
		if not VRService.VREnabled then
			return cframe:VectorToWorldSpace(vector3)
		end

		local vector3_2 = Vector3.new(vector3.X, 0, vector3.Z)

		if vector3_2.Magnitude < 0.01 then
			return Vector3.new(0, 0, 0)
		end

		local v6 = not (cameraRotationAction and cameraRotationAction.Enabled) and 0
			or -cameraRotationAction:GetState().Y / 2.31

		local v7 = math.atan2(-vector3_2.X, -vector3_2.Z)
		local eulerAnglesYXZ, v8, v9 = cframe:ToEulerAnglesYXZ()
		local v10 = v7 + v8
		return CFrame.fromEulerAnglesYXZ(v6, v10, 0).LookVector
	else
		local components, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16 = cframe:GetComponents()

		if v13 < 1 and v13 > -1 then
			v8 = v16
		else
			v10 = -v9 * math.sign(v13)
		end

		local v17 = math.sqrt(v8 * v8 + v10 * v10)
		return (Vector3.new((v8 * vector3.X + v10 * vector3.Z) / v17, 0, (v8 * vector3.Z - v10 * vector3.X) / v17))
	end
end

function ControlModule:initialize(p)
	self.data = p

	self:UpdateMovementMode()

	if not userFlag10 then
		ActionController.initializeActions(self.data)
	end

	if v then
		InputSlots.setupSlotActions(self.data.engineInterface.player, self.data.isServerAuthority, self.data.eventBus)
	end
end

function ControlModule:Update(data, p)
	assert(data.engineInterface.player)

	local controlModule = data.controlModule
	local controlModule2 = data.playerModule.ControlModule
	local engineInterface = data.engineInterface

	if userFlag10 then
		local humanoid = engineInterface.humanoid

		if engineInterface.characterChanged then
			self:OnCharacterChanged(humanoid)
		end

		if not (userFlag11 or humanoid) then
			return
		end
	else
		assert(engineInterface.character)

		if not (userFlag11 or self.humanoid) then
			return
		end
	end

	local enabled = controlModule2.Enabled

	if userFlag11 then
		controlModule.enabled = enabled

		if enabled == self.controlsEnabled then
			if not enabled then
				return
			end
		else
			self.controlsEnabled = enabled
			self:UpdateActiveControlModuleEnabled()
		end
	end

	if enabled then
		if userFlag11 and not self.humanoid then
			return
		end

		ActionController.initializeActions(data)

		if userFlag11 and not (controlModule.actions.MoveAction and controlModule.actions.JumpAction) then
			return
		end

		if self.activeController and self.activeController.enabled and self.humanoid then
			ActionController.update(data)

			self:GetClickToMoveController():Update(data, p)

			local vector3 = Vector3.new(controlModule.moveVector.X, 0, -controlModule.moveVector.Y)

			if self.vehicleController then
				local v6
				vector3, v6 = self.vehicleController:Update(vector3, true)
				_ = v6
			end

			local rawMoveVector = self:calculateRawMoveVector(self.humanoid, vector3)

			self.inputMoveVector = rawMoveVector

			if VRService.VREnabled then
				rawMoveVector = self:updateVRMoveVector(rawMoveVector)
			end

			controlModule.worldMoveVector = rawMoveVector
			self:characterMove(data)
		end
	else
		controlModule.isJumping = false
		controlModule.moveVector = Vector2.new()
		controlModule.worldMoveVector = Vector3.new()
		ActionController.update(data)
		self.inputMoveVector = Vector3.new()

		if self.vehicleController then
			self.vehicleController:Update(Vector3.new(), true)
		end

		self:characterMove(data)
	end
end

function ControlModule:characterMove(p)
	if userFlag11 and not self.humanoid then
		return
	end

	local controlModule = p.controlModule

	if v2 then
		if not p.isServerAuthority then
			if v and v4:isEnabled() then
				if not userFlag11 then
					InputReplication.writeInputToCS(Players.LocalPlayer, self)
				end
			else
				self.moveFunction(Players.LocalPlayer, controlModule.worldMoveVector, false)
				self.humanoid.Jump = controlModule.isJumping
			end
		end
	elseif not (userFlag4 and p.isServerAuthority or v and v4:isEnabled()) then
		self.moveFunction(Players.LocalPlayer, controlModule.worldMoveVector, false)

		self.humanoid.Jump = controlModule.isJumping
	end
end

function ControlModule:updateVRMoveVector(p)
	local currentCamera = workspace.CurrentCamera

	local v6 = currentCamera.Focus.Position - currentCamera.CFrame.Position
	local v7

	if userFlag then
		v7 = vrFirstPersonState.inFirstPerson
	else
		v7 = v6.Magnitude < 5
	end

	if p.Magnitude ~= 0 or not v7 or not VRService.AvatarGestures or not self.humanoid or self.humanoid.Sit then
		return p
	end

	local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local v8 = userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale

	local v9 = -0.7 * self.humanoid.RootPart.Size.Y / 2
	local v10 = (currentCamera.CFrame * v8 * CFrame.new(0, v9, 0)).Position - self.humanoid.RootPart.CFrame.Position
	local vector3 = Vector3.new(v10.x, 0, v10.z)

	if
		userFlag
		and (currentCamera.Focus.Position - currentCamera.CFrame.Position).Magnitude > math.max(4 * currentCamera.HeadScale, 1)
	then
		return p
	end

	return vector3
end

function ControlModule:OnHumanoidSeated(flag: boolean, vehicleSeat)
	if flag then
		if vehicleSeat and vehicleSeat:IsA("VehicleSeat") then
			if not self.vehicleController then
				self.vehicleController = self.vehicleController.new()
			end

			self.vehicleController:Enable(true, vehicleSeat)
		end
	elseif self.vehicleController then
		self.vehicleController:Enable(false, vehicleSeat)
	end
end

if userFlag10 then
	function ControlModule:OnCharacterChanged(humanoid)
		self.humanoid = humanoid
		self:UpdateMovementMode()

		if not humanoid then
			return
		end

		if self.humanoidSeatedConn then
			self.humanoidSeatedConn:Disconnect()
			self.humanoidSeatedConn = nil
		end

		self.humanoidSeatedConn = humanoid.Seated:Connect(function(p, p2)
			self:OnHumanoidSeated(p, p2)
		end)
	end
else
	function ControlModule:OnCharacterAdded(instance)
		self.humanoid = instance:FindFirstChildOfClass("Humanoid")

		while not self.humanoid do
			instance.ChildAdded:wait()
			self.humanoid = instance:FindFirstChildOfClass("Humanoid")
		end

		if self.humanoidSeatedConn then
			self.humanoidSeatedConn:Disconnect()
			self.humanoidSeatedConn = nil
		end

		self.humanoidSeatedConn = self.humanoid.Seated:Connect(function(p, p2)
			self:OnHumanoidSeated(p, p2)
		end)

		self:UpdateMovementMode()
	end

	function ControlModule:OnCharacterRemoving(p)
		self.humanoid = nil

		self:UpdateMovementMode()
	end
end

function ControlModule:UpdateTouchGuiVisibility()
	local v6 = self.humanoid
		and GuiService.TouchControlsEnabled
		and UserInputService.PreferredInput == Enum.PreferredInput.Touch

	if v6 and not self.touchGui then
		self:CreateTouchGuiContainer()
	end

	if self.touchGui then
		self.touchGui.Enabled = v6 and true or false
	end
end

function ControlModule:SwitchToController(activeControlModule)
	if activeControlModule then
		if not self.controllers[activeControlModule] then
			self.controllers[activeControlModule] = activeControlModule.new(self.data)
		end

		if self.activeController ~= self.controllers[activeControlModule] then
			if self.activeController then
				self.activeController:Enable(false)
			end

			self.activeController = self.controllers[activeControlModule]
			self.activeControlModule = activeControlModule

			self:UpdateActiveControlModuleEnabled()
		end
	else
		if self.activeController then
			self.activeController:Enable(false)
		end

		self.activeController = nil
		self.activeControlModule = nil
	end
end

function ControlModule:UpdateMovementMode()
	self:UpdateTouchGuiVisibility()

	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		local touchModule, v6 = self:SelectTouchModule()

		if v6 and self.touchControlFrame then
			self:SwitchToController(touchModule)
		end
	else
		self:SwitchToController((self:SelectComputerMovementModule()))
	end
end

function ControlModule:CreateTouchGuiContainer()
	if not self.playerGui then
		return
	end

	if self.touchGui then
		self.touchGui:Destroy()
	end

	self.touchGui = Instance.new("ScreenGui")
	self.touchGui.Name = "TouchGui"
	self.touchGui.ResetOnSpawn = false
	self.touchGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	if v and userFlag7 then
		self.touchGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	end

	self.touchGui.ClipToDeviceSafeArea = false

	self.touchControlFrame = Instance.new("Frame")
	self.touchControlFrame.Name = "TouchControlFrame"
	self.touchControlFrame.Size = UDim2.new(1, 0, 1, 0)
	self.touchControlFrame.BackgroundTransparency = 1
	self.touchControlFrame.Parent = self.touchGui

	self.touchGui.Parent = self.playerGui
end

function ControlModule:CreateAbilitiesGuiContainer()
	if not self.playerGui then
		return
	end

	if self.abilitiesGui then
		self.abilitiesGui:Destroy()
	end

	self.abilitiesGui = Instance.new("ScreenGui")
	self.abilitiesGui.Name = "AbilitiesGui"
	self.abilitiesGui.ResetOnSpawn = false
	self.abilitiesGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.abilitiesGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	self.abilitiesGui.ClipToDeviceSafeArea = false

	self.abilitiesFrame = Instance.new("Frame")
	self.abilitiesFrame.Name = "AbilitiesFrame"
	self.abilitiesFrame.Size = UDim2.new(1, 0, 1, 0)
	self.abilitiesFrame.BackgroundTransparency = 1
	self.abilitiesFrame.Parent = self.abilitiesGui

	self.abilitiesGui.Parent = self.playerGui
end

function ControlModule:GetClickToMoveController()
	if not self.controllers[ClickToMoveController] then
		self.controllers[ClickToMoveController] = ClickToMoveController.new()
	end

	return self.controllers[ClickToMoveController]
end

function ControlModule:ProcessInputs(player, p: number)
	if v then
		if not AvatarAbilitiesInterface.get(player):isEnabled() then
			if v2 then
				InputReplication.processPCSInputs(player)
			else
				InputReplication.SendInputToHumanoidForServerAuth(player)
			end
		end
	else
		if v2 then
			InputReplication.processPCSInputs(player)
			return
		end

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

		local moveAction = characterContext.MoveAction
		local rotationAction = characterContext.RotationAction
		local jumpAction = characterContext.JumpAction

		local function isValidInput2D(vector2: Vector2): boolean -- 1 equivalent call inferred from this helper
			return vector2.X == vector2.X and vector2.Y == vector2.Y and vector2.X ~= 1e999 and vector2.Y ~= 1e999
		end

		local function isValidInput3D(vector: Vector3): boolean -- 1 equivalent call inferred from this helper
			return vector.X == vector.X
				and vector.Y == vector.Y
				and vector.Z == vector.Z
				and vector.X ~= 1e999
				and vector.Y ~= 1e999
				and vector.Z ~= 1e999
		end

		local v6

		if moveAction == nil then
			v6 = Vector2.new(0, 0)
		else
			v6 = moveAction:GetState()
		end

		local vector = player:GetCameraState().CFrame.LookVector

		if isValidInput2D(v6) and isValidInput3D(vector) and vector.Magnitude > 0 then -- inferred equivalent call
			if humanoid:GetState() ~= Enum.HumanoidStateType.Swimming then
				vector = Vector3.new(vector.X, 0, vector.Z).Unit
			end

			local unit = vector:Cross(Vector3.new(0, 1, 0)).Unit

			humanoid:Move(vector * v6.Y + unit * v6.X)

			if rotationAction:GetState() then
				humanoid.AutoRotate = false

				if
					humanoid.SeatPart == nil
					and humanoid.RootPart ~= nil
					and not (humanoid.Sit or humanoid.RootPart:IsGrounded())
				then
					humanoid.RootPart.CFrame = CFrame.new(
						humanoid.RootPart.CFrame.Position,
						humanoid.RootPart.CFrame.Position + vector
					)
				end
			else
				humanoid.AutoRotate = true
			end
		end

		humanoid.Jump = jumpAction ~= nil and jumpAction:GetState()
	end
end

if RunService:IsClient() then
	return ControlModule.new()
end

return ControlModule