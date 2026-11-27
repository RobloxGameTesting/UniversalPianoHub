local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local v = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
	or flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationDGA")

local userFlag = flagUtil.getUserFlag("UserPlayerScriptsClassicThumbstickRenameUI")
local userFlag2 = flagUtil.getUserFlag("UserAbilitiesUserInterfaceC")
local userFlag3 = flagUtil.getUserFlag("UserPlayerScriptsResetDTTouchOnCreate")

local thumbstickAction = script.Parent.Parent:WaitForChild("InputContexts"):WaitForChild("TransformerContext"):WaitForChild("ThumbstickAction")

local vector2 = Vector2.new(-1, -1)

local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local v2

if v then
	v2 = AvatarAbilitiesInterface.get(Players.LocalPlayer)
else
	v2 = nil
end

local ActionController = require(script.Parent:WaitForChild("ActionController"))
local object = setmetatable({}, ActionController)
object.__index = object

function object.new(p)
	local self = setmetatable(ActionController.new(), object)

	self.data = p
	self.enabled = false

	self.isTouchActive = false
	self.isFollowStick = false

	self.thumbstickFrame = nil
	self.screenPos = nil
	self.stickImage = nil
	self.thumbstickSize = nil

	return self
end

local function setupThumbstickInput(p)
	for _, child in thumbstickAction:GetChildren() do
		if child.Name == "DynamicTouchBinding" or child.Name == "ClassicTouchBinding" then
			child:Destroy()
		end
	end

	local classicTouchBinding = Instance.new("InputBinding")
	classicTouchBinding.Name = "ClassicTouchBinding"
	classicTouchBinding.KeyCode = Enum.KeyCode.TouchPosition
	classicTouchBinding.UIModifier = p.thumbstickButton
	classicTouchBinding.Parent = thumbstickAction
end

local function enableThumbstickInput(object2, flag: boolean) -- 1 equivalent call inferred from this helper
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

function object:Enable(flag: boolean?, p)
	if flag == nil then
		return false
	end

	local enabled = flag and true or false

	if self.enabled == enabled then
		return true
	end

	ActionController.Enable(self, enabled)

	self.isJumping = false

	if enabled then
		if not self.thumbstickFrame then
			self:Create(p)
		end

		if userFlag3 then
			setupThumbstickInput(self)
		end

		self.thumbstickStateChangedConn = thumbstickAction.StateChanged:Connect(self.onStateChanged)
		thumbstickAction.Enabled = true

		self.thumbstickFrame.Visible = true
	else
		if userFlag3 then
		end

		enableThumbstickInput(self, false) -- inferred equivalent call
		self.thumbstickFrame.Visible = false
		self:OnInputEnded()
	end

	self.enabled = enabled
end

function object:OnInputEnded()
	self.isTouchActive = false
	self.thumbstickFrame.Position = self.screenPos
	self.stickImage.Position = UDim2.new(
		0,
		self.thumbstickFrame.Size.X.Offset / 2 - self.thumbstickSize / 4,
		0,
		self.thumbstickFrame.Size.Y.Offset / 2 - self.thumbstickSize / 4
	)

	local classicThumbstickScriptableBinding = self.data.controlModule.actions.MoveAction:FindFirstChild("ClassicThumbstickScriptableBinding")

	if classicThumbstickScriptableBinding then
		classicThumbstickScriptableBinding:Fire(Vector2.zero)
	end

	self.isJumping = false
	self.thumbstickFrame.Position = self.screenPos
end
function object:Create(parent)
	if self.thumbstickFrame then
		thumbstickAction.Enabled = false

		if self.thumbstickStateChangedConn then
			self.thumbstickStateChangedConn:Disconnect()
			self.thumbstickStateChangedConn = nil
		end

		self.thumbstickFrame:Destroy()
		self.thumbstickFrame = nil

		if self.absoluteSizeChangedConn then
			self.absoluteSizeChangedConn:Disconnect()
			self.absoluteSizeChangedConn = nil
		end

		if self.avatarAbilitiesEnabledChangedConn then
			self.avatarAbilitiesEnabledChangedConn:Disconnect()
			self.avatarAbilitiesEnabledChangedConn = nil
		end
	end

	self.thumbstickFrame = Instance.new("Frame")
	self.thumbstickFrame.Name = userFlag and "ClassicThumbstickFrame" or "ThumbstickFrame"

	self.thumbstickFrame.Active = true
	self.thumbstickFrame.Visible = false
	self.thumbstickFrame.BackgroundTransparency = 1

	local outerImage = Instance.new("ImageLabel")
	outerImage.Name = "OuterImage"
	outerImage.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
	outerImage.ImageRectOffset = Vector2.new()
	outerImage.ImageRectSize = Vector2.new(220, 220)
	outerImage.BackgroundTransparency = 1
	outerImage.Position = UDim2.new(0, 0, 0, 0)

	self.stickImage = Instance.new("ImageLabel")
	self.stickImage.Name = "StickImage"
	self.stickImage.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
	self.stickImage.ImageRectOffset = Vector2.new(220, 0)
	self.stickImage.ImageRectSize = Vector2.new(111, 111)
	self.stickImage.BackgroundTransparency = 1
	self.stickImage.ZIndex = 2

	local function ResizeThumbstick()
		local v3 = math.min(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) <= 500
		local v4

		if v then
			v4 = v2:isEnabled()
		else
			v4 = AvatarAbilitiesInterface.isEnabled()
		end

		if v4 then
			self.thumbstickSize = v3 and 72 or 120
			self.screenPos = UDim2.new(0, v3 and 64 or 100, 1, -self.thumbstickSize - (v3 and 64 or 112))
		else
			self.thumbstickSize = v3 and 70 or 120
			self.screenPos = v3 and UDim2.new(0, self.thumbstickSize / 2 - 10, 1, -self.thumbstickSize - 20)
				or UDim2.new(0, self.thumbstickSize / 2, 1, -self.thumbstickSize * 1.75)
		end

		self.thumbstickFrame.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
		self.thumbstickFrame.Position = self.screenPos
		outerImage.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
		self.stickImage.Size = UDim2.new(0, self.thumbstickSize / 2, 0, self.thumbstickSize / 2)
		self.stickImage.Position = UDim2.new(
			0,
			self.thumbstickSize / 2 - self.thumbstickSize / 4,
			0,
			self.thumbstickSize / 2 - self.thumbstickSize / 4
		)
	end

	ResizeThumbstick()
	self.absoluteSizeChangedConn = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeThumbstick)

	if v then
		self.avatarAbilitiesEnabledChangedConn = v2:GetEnabledChangedSignal():Connect(ResizeThumbstick)
	else
		self.avatarAbilitiesEnabledChangedConn = AvatarAbilitiesInterface.GetEnabledChangedSignal():Connect(ResizeThumbstick)
	end

	outerImage.Parent = self.thumbstickFrame
	self.stickImage.Parent = self.thumbstickFrame

	self.thumbstickButton = Instance.new("ImageButton")
	self.thumbstickButton.Name = "ClassicThumbstickUIModifier"
	self.thumbstickButton.BackgroundTransparency = 1
	self.thumbstickButton.ImageTransparency = 1
	self.thumbstickButton.AutoButtonColor = false
	self.thumbstickButton.Size = UDim2.new(1, 0, 1, 0)
	self.thumbstickButton.ZIndex = self.thumbstickFrame.ZIndex
	self.thumbstickButton.Visible = true
	self.thumbstickButton.Active = false
	self.thumbstickButton.Parent = self.thumbstickFrame

	if not userFlag3 then
		local classicTouchBinding = Instance.new("InputBinding")
		classicTouchBinding.Name = "ClassicTouchBinding"
		classicTouchBinding.KeyCode = Enum.KeyCode.TouchPosition
		classicTouchBinding.UIModifier = self.thumbstickButton
		classicTouchBinding.Parent = thumbstickAction
	end

	local vector2_2 = nil

	local function DoMove(vector2_3: Vector2)
		local v3 = vector2_3 / (self.thumbstickSize / 2)

		local magnitude = v3.magnitude
		local v4

		if magnitude < 0.05 then
			v4 = Vector2.new()
		else
			v4 = v3.unit * math.min(1, (magnitude - 0.05) / 0.95)
		end

		local vector2_4 = Vector2.new(v4.X, -v4.Y)
		local classicThumbstickScriptableBinding = self.data.controlModule.actions.MoveAction:FindFirstChild("ClassicThumbstickScriptableBinding")

		if classicThumbstickScriptableBinding then
			classicThumbstickScriptableBinding:Fire(vector2_4)
		end
	end

	local function MoveStick(vector3: Vector3)
		local v3 = Vector2.new(vector3.X - vector2_2.X, vector3.Y - vector2_2.Y)
		local magnitude = v3.magnitude
		local v4 = self.thumbstickFrame.AbsoluteSize.X / 2

		if self.isFollowStick and v4 < magnitude then
			local v5 = v3.unit * v4

			if userFlag2 then
				local absolutePosition = parent.AbsolutePosition
				self.thumbstickFrame.Position = UDim2.new(
					0,
					vector3.X - absolutePosition.X - self.thumbstickFrame.AbsoluteSize.X / 2 - v5.X,
					0,
					vector3.Y - absolutePosition.Y - self.thumbstickFrame.AbsoluteSize.Y / 2 - v5.Y
				)
			else
				self.thumbstickFrame.Position = UDim2.new(
					0,
					vector3.X - self.thumbstickFrame.AbsoluteSize.X / 2 - v5.X,
					0,
					vector3.Y - self.thumbstickFrame.AbsoluteSize.Y / 2 - v5.Y
				)
			end
		else
			local v5 = math.min(magnitude, v4)
			v3 = v3.unit * v5
		end

		self.stickImage.Position = UDim2.new(
			0,
			v3.X + self.stickImage.AbsoluteSize.X / 2,
			0,
			v3.Y + self.stickImage.AbsoluteSize.Y / 2
		)
	end

	function self.onStateChanged(vector2_3: Vector2)
		if vector2_3 == vector2 then
			if self.isTouchActive then
				self:OnInputEnded()
			end
		else
			local min = GuiService:GetInsetArea(Enum.ScreenInsets.None).Min
			local vector3 = Vector3.new(vector2_3.X + min.X, vector2_3.Y + min.Y, 0)

			if self.isTouchActive then
				vector2_2 = Vector2.new(
					self.thumbstickFrame.AbsolutePosition.X + self.thumbstickFrame.AbsoluteSize.X / 2,
					self.thumbstickFrame.AbsolutePosition.Y + self.thumbstickFrame.AbsoluteSize.Y / 2
				)

				DoMove(Vector2.new(vector3.X - vector2_2.X, vector3.Y - vector2_2.Y))
				MoveStick(vector3)
			else
				self.isTouchActive = true

				if userFlag2 then
					local absolutePosition = parent.AbsolutePosition
					self.thumbstickFrame.Position = UDim2.new(
						0,
						vector3.X - absolutePosition.X - self.thumbstickFrame.Size.X.Offset / 2,
						0,
						vector3.Y - absolutePosition.Y - self.thumbstickFrame.Size.Y.Offset / 2
					)
				else
					self.thumbstickFrame.Position = UDim2.new(
						0,
						vector3.X - self.thumbstickFrame.Size.X.Offset / 2,
						0,
						vector3.Y - self.thumbstickFrame.Size.Y.Offset / 2
					)
				end

				vector2_2 = Vector2.new(
					self.thumbstickFrame.AbsolutePosition.X + self.thumbstickFrame.AbsoluteSize.X / 2,
					self.thumbstickFrame.AbsolutePosition.Y + self.thumbstickFrame.AbsoluteSize.Y / 2
				)
			end
		end
	end

	GuiService.MenuOpened:Connect(function()
		if self.isTouchActive then
			self:OnInputEnded()
		end
	end)

	self.thumbstickFrame.Parent = parent
end
return object