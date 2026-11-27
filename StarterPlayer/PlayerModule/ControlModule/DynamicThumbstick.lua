local v = { 0.10999999999999999, 0.30000000000000004, 0.4, 0.5, 0.6, 0.7, 0.75 }

local v2 = { 0.55, 0.65, 0.7, 0.75, 0.8, 0.85, 0.875 }

local count = #v

local vector2 = Vector2.new(-1, -1)

local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local v3 = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
	or flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationDGA")
local userFlag = flagUtil.getUserFlag("UserAllowAbilityControlsBonus")
local userFlag2 = flagUtil.getUserFlag("UserDoubleJumpButtonFix")
local userFlag3 = flagUtil.getUserFlag("UserPlayerScriptsResetDTTouchOnCreate")

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local thumbstickAction = script.Parent.Parent:WaitForChild("InputContexts"):WaitForChild("TransformerContext"):WaitForChild("ThumbstickAction")

local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local v4

if v3 then
	v4 = AvatarAbilitiesInterface.get(Players.LocalPlayer)
else
	v4 = nil
end

local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local ActionController = require(script.Parent:WaitForChild("ActionController"))
local object = setmetatable({}, ActionController)
object.__index = object

function object.new(p)
	local self = setmetatable(ActionController.new(), object)

	self.data = p
	self.enabled = false

	self.isTouchActive = false
	self.moveTouchFirstChanged = false
	self.moveTouchStartPosition = nil

	self.startImage = nil
	self.endImage = nil
	self.endImageStroke = nil
	self.endImageCenter = nil
	self.middleImages = {}

	self.startImageFadeTween = nil
	self.endImageFadeTween = nil
	self.endImageCenterFadeTween = nil
	self.middleImageFadeTweens = {}

	self.isFirstTouch = true

	self.thumbstickFrame = nil

	self.onRenderSteppedConn = nil

	self.fadeInAndOutBalance = 0.5
	self.fadeInAndOutHalfDuration = 0.3
	self.hasFadedBackgroundInPortrait = false
	self.hasFadedBackgroundInLandscape = false

	self.tweenInAlphaStart = nil
	self.tweenOutAlphaStart = nil

	self.newStyle = false

	return self
end

function object:GetIsJumping()
	local isJumping = self.isJumping
	self.isJumping = false
	return isJumping
end

local function setupThumbstickInput(p)
	for _, child in thumbstickAction:GetChildren() do
		if child.Name == "DynamicTouchBinding" or child.Name == "ClassicTouchBinding" then
			child:Destroy()
		end
	end

	local dynamicTouchBinding = Instance.new("InputBinding")
	dynamicTouchBinding.Name = "DynamicTouchBinding"
	dynamicTouchBinding.KeyCode = Enum.KeyCode.TouchPosition
	dynamicTouchBinding.UIModifier = p.thumbstickButton
	dynamicTouchBinding.Parent = thumbstickAction
end

local function enableThumbstickInput(object2, flag: boolean) -- 3 equivalent calls inferred from this helper
	if flag then
		setupThumbstickInput(object2)
		object2.thumbstickStateChangedConn = thumbstickAction.StateChanged:Connect(object2.onStateChanged)
		thumbstickAction.Enabled = true
	else
		thumbstickAction.Enabled = false

		if object2.thumbstickStateChangedConn then
			object2.thumbstickStateChangedConn:Disconnect()
			object2.thumbstickStateChangedConn = nil
		end
	end
end

function object:Enable(flag: boolean?, p): nil | boolean
	if flag == nil then
		return false
	end

	local v5 = flag and true or false

	if self.enabled == v5 then
		return true
	end

	ActionController.Enable(self, v5)

	if v5 then
		if not self.thumbstickFrame then
			self:Create(p)

			if v3 and not self.avatarAbilitiesEnabledChangedConn then
				self.avatarAbilitiesEnabledChangedConn = v4:GetEnabledChangedSignal():Connect(function()
					if self.enabled then
						self:Create(p)

						if userFlag3 then
							enableThumbstickInput(self, true) -- inferred equivalent call
						else
							self.thumbstickStateChangedConn = thumbstickAction.StateChanged:Connect(self.onStateChanged)
							thumbstickAction.Enabled = true
						end

						self.thumbstickFrame.Visible = true
					end
				end)
			end
		end

		if userFlag3 then
			setupThumbstickInput(self)
		end

		self.thumbstickStateChangedConn = thumbstickAction.StateChanged:Connect(self.onStateChanged)
		thumbstickAction.Enabled = true
	else
		if userFlag3 then
		end

		enableThumbstickInput(self, false) -- inferred equivalent call
		self:OnInputEnded()
	end

	self.enabled = v5
	self.thumbstickFrame.Visible = v5
	return nil
end

function object:OnInputEnded()
	self.isTouchActive = false
	local dynamicThumbstickScriptableBinding = self.data.controlModule.actions.MoveAction:FindFirstChild("DynamicThumbstickScriptableBinding")

	if dynamicThumbstickScriptableBinding then
		dynamicThumbstickScriptableBinding:Fire(Vector2.zero)
	end

	self:FadeThumbstick(false)
end

function object:FadeThumbstick(flag: boolean?)
	if not flag and self.isTouchActive or self.isFirstTouch then
		return
	end

	if self.startImageFadeTween then
		self.startImageFadeTween:Cancel()
	end

	if self.endImageFadeTween then
		self.endImageFadeTween:Cancel()
	end

	if v3 and self.endImageCenterFadeTween then
		self.endImageCenterFadeTween:Cancel()
	end

	for i = 1, #self.middleImages do
		if self.middleImageFadeTweens[i] then
			self.middleImageFadeTweens[i]:Cancel()
		end
	end

	if flag then
		if v3 and self.newStyle then
			self.startImageFadeTween = TweenService:Create(self.startImage, tweenInfo, {
				BackgroundTransparency = 0.4
			})
			self.startImageFadeTween:Play()

			self.endImageFadeTween = TweenService:Create(self.endImageStroke, tweenInfo, {
				Transparency = 0
			})
			self.endImageFadeTween:Play()
			self.endImageCenterFadeTween = TweenService:Create(self.endImageCenter, tweenInfo, {
				BackgroundTransparency = 0
			})
			self.endImageCenterFadeTween:Play()
		else
			self.startImageFadeTween = TweenService:Create(self.startImage, tweenInfo, {
				ImageTransparency = 0
			})
			self.startImageFadeTween:Play()

			self.endImageFadeTween = TweenService:Create(self.endImage, tweenInfo, {
				ImageTransparency = 0.2
			})
			self.endImageFadeTween:Play()
		end

		for i = 1, #self.middleImages do
			if v3 and self.newStyle then
				self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], tweenInfo, {
					BackgroundTransparency = v2[i]
				})
			else
				self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], tweenInfo, {
					ImageTransparency = v[i]
				})
			end

			self.middleImageFadeTweens[i]:Play()
		end
	else
		if v3 and self.newStyle then
			self.startImageFadeTween = TweenService:Create(self.startImage, tweenInfo, {
				BackgroundTransparency = 1
			})
			self.startImageFadeTween:Play()

			self.endImageFadeTween = TweenService:Create(self.endImageStroke, tweenInfo, {
				Transparency = 1
			})
			self.endImageFadeTween:Play()
			self.endImageCenterFadeTween = TweenService:Create(self.endImageCenter, tweenInfo, {
				BackgroundTransparency = 1
			})
			self.endImageCenterFadeTween:Play()
		else
			self.startImageFadeTween = TweenService:Create(self.startImage, tweenInfo, {
				ImageTransparency = 1
			})
			self.startImageFadeTween:Play()

			self.endImageFadeTween = TweenService:Create(self.endImage, tweenInfo, {
				ImageTransparency = 1
			})
			self.endImageFadeTween:Play()
		end

		for i = 1, #self.middleImages do
			if v3 and self.newStyle then
				self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], tweenInfo, {
					BackgroundTransparency = 1
				})
			else
				self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], tweenInfo, {
					ImageTransparency = 1
				})
			end

			self.middleImageFadeTweens[i]:Play()
		end
	end
end

function object:FadeThumbstickFrame(p: number, fadeInAndOutBalance: number)
	self.fadeInAndOutHalfDuration = p * 0.5
	self.fadeInAndOutBalance = fadeInAndOutBalance
	self.tweenInAlphaStart = tick()
end

function object:DoFadeInBackground()
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local v5 = false

	if playerGui then
		if
			playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeLeft
			or playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeRight
		then
			v5 = self.hasFadedBackgroundInLandscape
			self.hasFadedBackgroundInLandscape = true
		elseif playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait then
			v5 = self.hasFadedBackgroundInPortrait
			self.hasFadedBackgroundInPortrait = true
		end
	end

	if not v5 then
		self.fadeInAndOutHalfDuration = 0.3
		self.fadeInAndOutBalance = 0.5
		self.tweenInAlphaStart = tick()
	end
end

function object:DoMove(vector2_2: Vector2)
	local v5

	if vector2_2.Magnitude < self.radiusOfDeadZone then
		v5 = Vector2.new()
	else
		v5 = vector2_2.Unit * (1 - math.max(0, (self.radiusOfMaxSpeed - vector2_2.Magnitude) / self.radiusOfMaxSpeed))
	end

	local vector2_3 = Vector2.new(v5.X, -v5.Y)
	local dynamicThumbstickScriptableBinding = self.data.controlModule.actions.MoveAction:FindFirstChild("DynamicThumbstickScriptableBinding")

	if dynamicThumbstickScriptableBinding then
		dynamicThumbstickScriptableBinding:Fire(vector2_3)
	end
end

function object:LayoutMiddleImages(vector3: Vector3, vector3_2: Vector3)
	local v5 = self.thumbstickSize / 2 + self.middleSize
	local v6 = vector3_2 - vector3
	local v7 = v6.Magnitude - self.thumbstickRingSize / 2 - self.middleSize
	local unit = v6.Unit

	local v8 = self.middleSpacing * count
	local v9 = self.middleSpacing

	if v8 < v7 then
		v9 = v7 / count
	end

	for i = 1, count do
		local middleImage = self.middleImages[i]
		local v10 = v5 + v9 * (i - 2)
		local v11 = v5 + v9 * (i - 1)

		if v10 < v7 then
			local v12 = vector3_2 - unit * v11
			local v13 = math.clamp(1 - (v11 - v7) / v9, 0, 1)

			middleImage.Visible = true
			middleImage.Position = UDim2.new(0, v12.X, 0, v12.Y)
			middleImage.Size = UDim2.new(0, self.middleSize * v13, 0, self.middleSize * v13)
		else
			middleImage.Visible = false
		end
	end
end

function object:MoveStick(p)
	local v5 = Vector2.new(self.moveTouchStartPosition.X, self.moveTouchStartPosition.Y) - self.thumbstickFrame.AbsolutePosition
	local v6 = Vector2.new(p.X, p.Y) - self.thumbstickFrame.AbsolutePosition
	self.endImage.Position = UDim2.new(0, v6.X, 0, v6.Y)
	self:LayoutMiddleImages(v5, v6)
end

function object:Create(parent)
	local IMAGE_ID = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"

	if self.thumbstickFrame then
		if userFlag3 then
		end

		enableThumbstickInput(self, false) -- inferred equivalent call
		self.thumbstickFrame:Destroy()
		self.thumbstickFrame = nil

		if self.onRenderSteppedConn then
			self.onRenderSteppedConn:Disconnect()
			self.onRenderSteppedConn = nil
		end

		if self.absoluteSizeChangedConn then
			self.absoluteSizeChangedConn:Disconnect()
			self.absoluteSizeChangedConn = nil
		end

		if not v3 and self.avatarAbilitiesEnabledChangedConn then
			self.avatarAbilitiesEnabledChangedConn:Disconnect()
			self.avatarAbilitiesEnabledChangedConn = nil
		end

		if v3 then
			if self.cameraChangedConn then
				self.cameraChangedConn:Disconnect()
				self.cameraChangedConn = nil
			end

			if self.currentCameraChangedConn then
				self.currentCameraChangedConn:Disconnect()
				self.currentCameraChangedConn = nil
			end

			if self.menuOpenedConnection then
				self.menuOpenedConnection:Disconnect()
				self.menuOpenedConnection = nil
			end

			if self.playerGuiChangedConn then
				self.playerGuiChangedConn:Disconnect()
				self.playerGuiChangedConn = nil
			end
		end
	end

	local function layoutThumbstickFrame(flag: boolean) -- 1 equivalent call inferred from this helper
		if flag then
			self.thumbstickFrame.Size = UDim2.new(1, 100, 0.4, 100)
			self.thumbstickFrame.Position = UDim2.new(0, -100, 0.6, 0)
		else
			self.thumbstickFrame.Size = UDim2.new(0.4, 100, 2 / 3, 100)
			self.thumbstickFrame.Position = UDim2.new(0, -100, 1 / 3, 0)
		end
	end

	self.newStyle = v3 and v4:isEnabled()

	self.thumbstickFrame = Instance.new("Frame")
	self.thumbstickFrame.BorderSizePixel = 0
	self.thumbstickFrame.Name = "DynamicThumbstickFrame"
	self.thumbstickFrame.Visible = false
	self.thumbstickFrame.BackgroundTransparency = 1
	self.thumbstickFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.thumbstickFrame.Active = false
	layoutThumbstickFrame(false) -- inferred equivalent call
	self.thumbstickButton = Instance.new("ImageButton")
	self.thumbstickButton.Name = "DynamicThumbstickUIModifier"
	self.thumbstickButton.BackgroundTransparency = 1
	self.thumbstickButton.ImageTransparency = 1
	self.thumbstickButton.AutoButtonColor = false
	self.thumbstickButton.Size = UDim2.new(1, 0, 1, 0)
	self.thumbstickButton.ZIndex = self.thumbstickFrame.ZIndex
	self.thumbstickButton.Visible = true
	self.thumbstickButton.Active = false
	self.thumbstickButton.Parent = self.thumbstickFrame

	if not userFlag3 then
		local dynamicTouchBinding

		if userFlag2 then
			dynamicTouchBinding = thumbstickAction:FindFirstChild("DynamicTouchBinding")
		end

		if not dynamicTouchBinding then
			dynamicTouchBinding = Instance.new("InputBinding")
			dynamicTouchBinding.Name = "DynamicTouchBinding"
			dynamicTouchBinding.KeyCode = Enum.KeyCode.TouchPosition
			dynamicTouchBinding.Parent = thumbstickAction
		end

		dynamicTouchBinding.UIModifier = self.thumbstickButton
	end

	if v3 and self.newStyle then
		self.startImage = Instance.new("Frame")
		self.startImage.Name = "ThumbstickStart"
		self.startImage.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
		self.startImage.BackgroundTransparency = 0.4
		self.startImage.AnchorPoint = Vector2.new(0.5, 0.5)
		self.startImage.ZIndex = 10
		self.startImage.Parent = self.thumbstickFrame

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0.5, 0)
		uiCorner.Parent = self.startImage

		self.endImage = Instance.new("Frame")
		self.endImage.Name = "ThumbstickEnd"
		self.endImage.BackgroundTransparency = 1
		self.endImage.AnchorPoint = Vector2.new(0.5, 0.5)
		self.endImage.ZIndex = 10
		self.endImage.Parent = self.thumbstickFrame

		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(0.5, 0)
		uiCorner2.Parent = self.endImage

		self.endImageStroke = Instance.new("UIStroke")
		self.endImageStroke.Thickness = userFlag2 and 1.5 or 2
		self.endImageStroke.Color = Color3.fromRGB(213, 215, 221)
		self.endImageStroke.Parent = self.endImage

		self.endImageCenter = Instance.new("Frame")
		self.endImageCenter.Name = "ThumbstickEndCenter"
		self.endImageCenter.BackgroundTransparency = 0
		self.endImageCenter.BackgroundColor3 = Color3.fromRGB(213, 215, 221)
		self.endImageCenter.AnchorPoint = Vector2.new(0.5, 0.5)
		self.endImageCenter.Size = UDim2.new(0.74, 0, 0.74, 0)
		self.endImageCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
		self.endImageCenter.ZIndex = 10
		self.endImageCenter.Parent = self.endImage

		local uiCorner3 = Instance.new("UICorner")
		uiCorner3.CornerRadius = UDim.new(0.5, 0)
		uiCorner3.Parent = self.endImageCenter

		for i = 1, count do
			self.middleImages[i] = Instance.new("Frame")
			self.middleImages[i].Name = "ThumbstickMiddle"
			self.middleImages[i].Visible = false
			self.middleImages[i].BackgroundTransparency = v2[i]
			self.middleImages[i].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			self.middleImages[i].AnchorPoint = Vector2.new(0.5, 0.5)
			self.middleImages[i].ZIndex = 9
			self.middleImages[i].Parent = self.thumbstickFrame

			local uiCorner4 = Instance.new("UICorner")
			uiCorner4.CornerRadius = UDim.new(0.5, 0)
			uiCorner4.Parent = self.middleImages[i]
		end
	else
		self.startImage = Instance.new("ImageLabel")
		self.startImage.Name = "ThumbstickStart"
		self.startImage.Visible = true
		self.startImage.BackgroundTransparency = 1
		self.startImage.Image = IMAGE_ID
		self.startImage.ImageRectOffset = Vector2.new(1, 1)
		self.startImage.ImageRectSize = Vector2.new(144, 144)
		self.startImage.ImageColor3 = Color3.new(0, 0, 0)
		self.startImage.AnchorPoint = Vector2.new(0.5, 0.5)
		self.startImage.ZIndex = 10
		self.startImage.Parent = self.thumbstickFrame

		self.endImage = Instance.new("ImageLabel")
		self.endImage.Name = "ThumbstickEnd"
		self.endImage.Visible = true
		self.endImage.BackgroundTransparency = 1
		self.endImage.Image = IMAGE_ID
		self.endImage.ImageRectOffset = Vector2.new(1, 1)
		self.endImage.ImageRectSize = Vector2.new(144, 144)
		self.endImage.AnchorPoint = Vector2.new(0.5, 0.5)
		self.endImage.ZIndex = 10
		self.endImage.Parent = self.thumbstickFrame

		for i = 1, count do
			self.middleImages[i] = Instance.new("ImageLabel")
			self.middleImages[i].Name = "ThumbstickMiddle"
			self.middleImages[i].Visible = false
			self.middleImages[i].BackgroundTransparency = 1
			self.middleImages[i].Image = IMAGE_ID
			self.middleImages[i].ImageRectOffset = Vector2.new(1, 1)
			self.middleImages[i].ImageRectSize = Vector2.new(144, 144)
			self.middleImages[i].ImageTransparency = v[i]
			self.middleImages[i].AnchorPoint = Vector2.new(0.5, 0.5)
			self.middleImages[i].ZIndex = 9
			self.middleImages[i].Parent = self.thumbstickFrame
		end
	end

	local function ResizeThumbstick()
		local absoluteSize = parent.AbsoluteSize
		local v5 = math.min(absoluteSize.X, absoluteSize.Y) > 500
		local v6

		if v3 then
			v6 = self.newStyle
		else
			v6 = AvatarAbilitiesInterface.isEnabled()
		end

		local v7 = userFlag and v6 and v5 and 60 / 37 or v5 and 2 or 1
		self.thumbstickSize = 45 * v7
		self.thumbstickRingSize = 20 * v7
		self.middleSize = 10 * v7
		self.middleSpacing = 14 * v7
		self.radiusOfDeadZone = 2 * v7
		self.radiusOfMaxSpeed = 20 * v7
		local v8 = 74 * v7

		if not v3 or self.isFirstTouch then
			if v6 then
				self.startImage.Position = UDim2.new(
					0,
					v8 * 0.5 + 100 + (v5 and 100 or 64),
					1,
					-v8 * 0.5 - 100 - (v5 and 112 or 64)
				)
			else
				self.startImage.Position = UDim2.new(
					0,
					self.thumbstickRingSize * 3.3 + 100,
					1,
					-self.thumbstickRingSize * 2.8 - 100
				)
			end

			self.startImage.Size = UDim2.new(0, v8, 0, v8)
		end

		self.endImage.Position = self.startImage.Position

		if v3 and self.newStyle then
			self.endImage.Size = UDim2.new(0, self.thumbstickSize * 0.6, 0, self.thumbstickSize * 0.6)
		else
			self.endImage.Size = UDim2.new(0, self.thumbstickSize * 0.8, 0, self.thumbstickSize * 0.8)
		end
	end

	ResizeThumbstick()
	self.absoluteSizeChangedConn = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeThumbstick)

	if not v3 then
		self.avatarAbilitiesEnabledChangedConn = AvatarAbilitiesInterface.GetEnabledChangedSignal():Connect(ResizeThumbstick)
	end

	local function onCurrentCameraChanged()
		if self.cameraChangedConn then
			self.cameraChangedConn:Disconnect()
			self.cameraChangedConn = nil
		end

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			local function onViewportSizeChanged() -- 1 equivalent call inferred from this helper
				local viewportSize = currentCamera.ViewportSize
				layoutThumbstickFrame(viewportSize.X < viewportSize.Y)
			end
			self.cameraChangedConn = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportSizeChanged)
			onViewportSizeChanged() -- inferred equivalent call
		end
	end
	self.currentCameraChangedConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCurrentCameraChanged)

	if workspace.CurrentCamera or v3 then
		onCurrentCameraChanged()
	end

	self.startImageFadeTween = nil
	self.endImageFadeTween = nil
	self.endImageCenterFadeTween = nil
	self.middleImageFadeTweens = {}

	if userFlag3 and self.isTouchActive then
		self:OnInputEnded()
	end

	self.moveTouchStartPosition = nil

	self.onRenderSteppedConn = RunService.RenderStepped:Connect(function()
		if self.tweenInAlphaStart == nil then
			if self.tweenOutAlphaStart ~= nil then
				local v5 = tick() - self.tweenOutAlphaStart
				local v6 = self.fadeInAndOutHalfDuration * 2 - self.fadeInAndOutHalfDuration * 2 * self.fadeInAndOutBalance
				self.thumbstickFrame.BackgroundTransparency = math.min(v5 / v6, 1) * 0.35 + 0.65

				if v6 < v5 then
					self.tweenOutAlphaStart = nil
				end
			end
		else
			local v5 = tick() - self.tweenInAlphaStart
			local v6 = self.fadeInAndOutHalfDuration * 2 * self.fadeInAndOutBalance
			self.thumbstickFrame.BackgroundTransparency = 1 - math.min(v5 / v6, 1) * 0.35

			if v6 < v5 then
				self.tweenOutAlphaStart = tick()
				self.tweenInAlphaStart = nil
			end
		end
	end)

	function self.onStateChanged(vector2_2: Vector2)
		if vector2_2 == vector2 then
			if self.isTouchActive then
				self:OnInputEnded()
			end
		else
			local min = GuiService:GetInsetArea(Enum.ScreenInsets.None).Min
			local vector3 = Vector3.new(vector2_2.X + min.X, vector2_2.Y + min.Y, 0)

			if self.isTouchActive then
				if self.moveTouchFirstChanged then
					self.moveTouchFirstChanged = false

					local vector2_3 = Vector2.new(
						self.moveTouchStartPosition.X - self.thumbstickFrame.AbsolutePosition.X,
						self.moveTouchStartPosition.Y - self.thumbstickFrame.AbsolutePosition.Y
					)

					self.startImage.Visible = true
					self.startImage.Position = UDim2.new(0, vector2_3.X, 0, vector2_3.Y)
					self.endImage.Visible = true
					self.endImage.Position = self.startImage.Position

					self:FadeThumbstick(true)
					self:MoveStick(self.moveTouchStartPosition)
				end

				local vector2_3 = Vector2.new(
					vector3.X - self.moveTouchStartPosition.X,
					vector3.Y - self.moveTouchStartPosition.Y
				)

				if vector2_3.Magnitude > 0 then
					self:DoMove(vector2_3)
					self:MoveStick(vector3)
				end
			else
				self.isTouchActive = true

				if self.isFirstTouch then
					self.isFirstTouch = false
					local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
					TweenService:Create(self.startImage, tweenInfo2, {
						Size = UDim2.new(0, 0, 0, 0)
					}):Play()

					if not (v3 and self.newStyle) then
						TweenService:Create(self.endImage, tweenInfo2, {
							Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize),
							ImageColor3 = Color3.new(0, 0, 0)
						}):Play()
					end
				end

				self.moveTouchStartPosition = vector3
				self.moveTouchFirstChanged = true

				self:DoFadeInBackground()
			end
		end
	end

	self.menuOpenedConnection = GuiService.MenuOpened:Connect(function()
		if self.isTouchActive then
			self:OnInputEnded()
		end
	end)

	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

	while not playerGui do
		LocalPlayer.ChildAdded:wait()
		playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	end

	local v5 = playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeLeft
		or playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeRight

	local function longShowBackground() -- 3 equivalent calls inferred from this helper
		self.fadeInAndOutHalfDuration = 2.5
		self.fadeInAndOutBalance = 0.05
		self.tweenInAlphaStart = tick()
	end

	self.playerGuiChangedConn = playerGui:GetPropertyChangedSignal("CurrentScreenOrientation"):Connect(function()
		if
			v5 and playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait
			or not v5 and playerGui.CurrentScreenOrientation ~= Enum.ScreenOrientation.Portrait
		then
			self.playerGuiChangedConn:Disconnect()
			longShowBackground() -- inferred equivalent call

			if v5 then
				self.hasFadedBackgroundInPortrait = true
			else
				self.hasFadedBackgroundInLandscape = true
			end
		end
	end)

	self.thumbstickFrame.Parent = parent

	if game:IsLoaded() then
		longShowBackground() -- inferred equivalent call
	else
		coroutine.wrap(function()
			game.Loaded:Wait()
			longShowBackground() -- inferred equivalent call
		end)()
	end
end

return object