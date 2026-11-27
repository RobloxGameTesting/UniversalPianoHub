game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
game:GetService("Players")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
game:GetService("VRService")
local GuiService = game:GetService("GuiService")

local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local userFlag = flagUtil.getUserFlag("UserPSTextboxResetCameraInput")
local userFlag2 = flagUtil.getUserFlag("UserPlayerScriptsSupportTVRemoteKeycodes")

local cameraContext = script.Parent.Parent:WaitForChild("InputContexts"):WaitForChild("CameraContext")

local cameraRotationAction = cameraContext:WaitForChild("CameraRotationAction")
local cameraZoomAction = cameraContext:WaitForChild("CameraZoomAction")

local gamepadBinding = cameraRotationAction:WaitForChild("GamepadBinding")
local microGamepadBinding

if userFlag2 then
	microGamepadBinding = cameraRotationAction:WaitForChild("MicroGamepadBinding")
else
	microGamepadBinding = nil
end

local mouseBinding = cameraRotationAction:WaitForChild("MouseBinding")
local trackpadBinding = cameraRotationAction:WaitForChild("TrackpadBinding")

local cameraToggleAction = cameraContext:WaitForChild("CameraToggleAction")
local cameraPanActiveAction = cameraContext:WaitForChild("CameraPanActiveAction")

local v = 1

local function updateCameraYInvert()
	local cameraYInvertValue = UserGameSettings:GetCameraYInvertValue()

	if cameraYInvertValue == v then
		return
	end

	v = cameraYInvertValue

	for _, inputBinding in cameraRotationAction:GetChildren() do
		if not inputBinding:IsA("InputBinding") then
			continue
		end

		local vector2Scale = inputBinding.Vector2Scale
		inputBinding.Vector2Scale = Vector2.new(vector2Scale.X, -vector2Scale.Y)
	end
end

local function updateGamepadCameraSensitivity() -- 1 equivalent call inferred from this helper
	gamepadBinding.Scale = UserGameSettings.GamepadCameraSensitivity

	if userFlag2 and microGamepadBinding then
		microGamepadBinding.Scale = UserGameSettings.GamepadCameraSensitivity
	end
end

local function updateMouseCameraSensitivity() -- 1 equivalent call inferred from this helper
	local mouseSensitivity = UserGameSettings.MouseSensitivity
	mouseBinding.Scale = mouseSensitivity
	trackpadBinding.Scale = mouseSensitivity
end

UserGameSettings:GetPropertyChangedSignal("GamepadCameraSensitivity"):Connect(updateGamepadCameraSensitivity)
updateGamepadCameraSensitivity() -- inferred equivalent call
UserGameSettings:GetPropertyChangedSignal("MouseSensitivity"):Connect(updateMouseCameraSensitivity)
updateMouseCameraSensitivity() -- inferred equivalent call
updateCameraYInvert()

local function adjustTouchPitchSensitivity(rotation: Vector2)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return rotation
	end

	local eulerAnglesYXZ = currentCamera.CFrame:ToEulerAnglesYXZ()

	if rotation.Y * eulerAnglesYXZ >= 0 then
		return rotation
	end

	local v2 = (1 - (math.abs(eulerAnglesYXZ) * 2 / 3.141592653589793) ^ 0.75) * 0.75 + 0.25

	return Vector2.new(1, v2) * rotation
end

local v2 = 0

local function incPanInputCount()
	v2 = math.max(0, v2 + 1)
end

local function decPanInputCount()
	v2 = math.max(0, v2 - 1)
end

local function resetPanInputCount() -- 1 equivalent call inferred from this helper
	v2 = 0
end

local CameraInput = {}

function CameraInput.getRotationActivated(): boolean
	return v2 > 0 or cameraRotationAction:GetState().Magnitude > 0
end

function CameraInput.getPanActivated(): boolean
	return v2 > 0
end

function CameraInput.getRotation(p)
	updateCameraYInvert()
	local rotation = cameraRotationAction:GetState() * p

	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		rotation = adjustTouchPitchSensitivity(rotation)
	end

	return rotation
end

function CameraInput.getZoomDelta(p)
	return cameraZoomAction:GetState() * p
end

cameraPanActiveAction.Pressed:Connect(incPanInputCount)
cameraPanActiveAction.Released:Connect(decPanInputCount)

local inputEnabled = false

function CameraInput.setInputEnabled(p)
	if inputEnabled == p then
		return
	end

	inputEnabled = p
	resetPanInputCount() -- inferred equivalent call

	if inputEnabled then
		cameraZoomAction.Enabled = true
		cameraRotationAction.Enabled = true

		cameraPanActiveAction.Enabled = true
	else
		cameraZoomAction.Enabled = false
		cameraRotationAction.Enabled = false

		cameraPanActiveAction.Enabled = false
	end
end

function CameraInput.getInputEnabled()
	return inputEnabled
end

UserInputService.WindowFocused:Connect(resetPanInputCount)
UserInputService.WindowFocusReleased:Connect(resetPanInputCount)
GuiService.MenuOpened:Connect(resetPanInputCount)

if userFlag then
	UserInputService.TextBoxFocusReleased:Connect(resetPanInputCount)
end

local holdPan = false
local togglePan = false
local lastTime = 0

function CameraInput.getHoldPan()
	return holdPan
end

function CameraInput.getTogglePan()
	return togglePan
end

function CameraInput.getPanning()
	return togglePan or holdPan
end

function CameraInput.setTogglePan(flag: boolean)
	togglePan = flag
end

local flag = false

cameraToggleAction.Pressed:Connect(function()
	holdPan = true
	lastTime = tick()
end)

cameraToggleAction.Released:Connect(function()
	holdPan = false

	if tick() - lastTime < 0.3 and (togglePan or UserInputService:GetMouseDelta().Magnitude < 2) then
		togglePan = not togglePan
	end
end)

function CameraInput.enableCameraToggleInput()
	if flag then
		return
	end

	flag = true

	holdPan = false
	togglePan = false

	cameraToggleAction.Enabled = true
end

function CameraInput.disableCameraToggleInput()
	if not flag then
		return
	end

	flag = false

	cameraToggleAction.Enabled = false
end

return CameraInput