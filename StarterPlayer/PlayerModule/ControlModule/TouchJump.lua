local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))

local connectionUtil = CommonUtils.get("ConnectionUtil")
local characterUtil = CommonUtils.get("CharacterUtil")
local flagUtil = CommonUtils.get("FlagUtil")
local v = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
	or flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationDGA")
local userFlag = flagUtil.getUserFlag("UserPlayerScriptsRefactor1")
local userFlag2 = flagUtil.getUserFlag("UserPlayerScriptsFixTouchJumpVisibility")

game:GetService("Players")

local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))

local v2 = {
	"rbxasset://textures/ui/Input/JumpButtonRegular.png",
	"rbxasset://textures/ui/Input/JumpButtonPressed.png"
}

local _ = {
	HUMANOID_STATE_ENABLED_CHANGED = "HUMANOID_STATE_ENABLED_CHANGED",
	HUMANOID_JUMP_POWER = "HUMANOID_JUMP_POWER",
	HUMANOID_JUMP_HEIGHT = "HUMANOID_JUMP_HEIGHT",
	HUMANOID = "HUMANOID",
	ACTIONS_RELOADED = "ACTIONS_RELOADED"
}

local ActionController = require(script.Parent:WaitForChild("ActionController"))
local object = setmetatable({}, ActionController)
object.__index = object

function object.new(p)
	local object2 = setmetatable(ActionController.new(), object)

	object2.data = p
	object2._actionsReloadedConn = p.eventBus:subscribe("ACTIONS_RELOADED"):Connect(function()
		object2:Create()

		if userFlag2 and object2._active then
			object2._active = false
			object2:EnableButton(true)
		end
	end)

	object2.parentUIFrame = nil
	object2.jumpButton = nil

	object2.externallyEnabled = false
	object2._active = false
	object2._connectionUtil = connectionUtil.new()

	return object2
end

function object:_reset()
	if self.jumpButton then
		if v or not AvatarAbilitiesInterface.isEnabled() then
			self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		else
			self.jumpButton.Image = v2[1]
		end
	end
end

function object:EnableButton(active)
	if active == self._active then
		return
	end

	if active then
		if not self.jumpButton then
			self:Create()
		end

		self.jumpButton.Visible = true
	elseif self.jumpButton then
		self.jumpButton.Visible = false
	end

	self:_reset()
	self._active = active
end

function object:UpdateEnabled()
	local child = characterUtil.getChild("Humanoid", "Humanoid")

	if
		child
		and self.externallyEnabled
		and (child.UseJumpPower and child.JumpPower > 0 or not child.UseJumpPower and child.JumpHeight > 0)
		and child:GetStateEnabled(Enum.HumanoidStateType.Jumping)
	then
		self:EnableButton(true)
	else
		self:EnableButton(false)
	end
end

function object:_setupConfigurations()
	local function update() -- 2 equivalent calls inferred from this helper
		self:UpdateEnabled()
	end

	local v3 = characterUtil.onChild("Humanoid", "Humanoid", function(instance)
		update() -- inferred equivalent call
		self:_reset()
		self._connectionUtil:trackConnection(
			"HUMANOID_JUMP_POWER",
			instance:GetPropertyChangedSignal("JumpPower"):Connect(update)
		)

		self._connectionUtil:trackConnection(
			"HUMANOID_JUMP_HEIGHT",
			instance:GetPropertyChangedSignal("JumpHeight"):Connect(update)
		)

		self._connectionUtil:trackConnection(
			"HUMANOID_STATE_ENABLED_CHANGED",
			instance.StateEnabledChanged:Connect(function(p, p2)
				if p == Enum.HumanoidStateType.Jumping and p2 ~= self._active then
					update() -- inferred equivalent call
				end
			end)
		)
	end)
	self._connectionUtil:trackConnection("HUMANOID", v3)
end

function object:Enable(externallyEnabled, parentUIFrame)
	if parentUIFrame then
		self.parentUIFrame = parentUIFrame
	end

	if self.externallyEnabled == externallyEnabled then
		return
	end

	self.externallyEnabled = externallyEnabled
	ActionController.Enable(self, externallyEnabled)

	self:UpdateEnabled()

	if externallyEnabled then
		self:_setupConfigurations()
	else
		self._connectionUtil:disconnectAll()
	end
end

function object:Destroy()
	if self._actionsReloadedConn then
		self._actionsReloadedConn:Disconnect()
		self._actionsReloadedConn = nil
	end

	if self.jumpButton then
		self.jumpButton:Destroy()
		self.jumpButton = nil
	end

	if self.absoluteSizeChangedConn then
		self.absoluteSizeChangedConn:Disconnect()
		self.absoluteSizeChangedConn = nil
	end

	if self.avatarAbilitiesEnabledChangedConn then
		self.avatarAbilitiesEnabledChangedConn:Disconnect()
		self.avatarAbilitiesEnabledChangedConn = nil
	end

	self._connectionUtil:disconnectAll()
	self.externallyEnabled = false
	self._active = false
	self.parentUIFrame = nil
end

function object:Create()
	if not self.parentUIFrame then
		return
	end

	if self.jumpButton then
		self.jumpButton:Destroy()
		self.jumpButton = nil
	end

	if self.absoluteSizeChangedConn then
		self.absoluteSizeChangedConn:Disconnect()
		self.absoluteSizeChangedConn = nil
	end

	if not v and self.avatarAbilitiesEnabledChangedConn then
		self.avatarAbilitiesEnabledChangedConn:Disconnect()
		self.avatarAbilitiesEnabledChangedConn = nil
	end

	self.jumpButton = Instance.new("ImageButton")
	self.jumpButton.Name = "JumpButton"
	self.jumpButton.Visible = false
	self.jumpButton.BackgroundTransparency = 1

	if userFlag then
		self.jumpButton.ZIndex = 10
	end

	if v or not AvatarAbilitiesInterface.isEnabled() then
		self.jumpButton.Image = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"
		self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		self.jumpButton.ImageRectSize = Vector2.new(144, 144)
	else
		self.jumpButton.Image = v2[1]
	end

	local function ResizeJumpButton()
		local v3 = math.min(self.parentUIFrame.AbsoluteSize.x, self.parentUIFrame.AbsoluteSize.y) <= 500

		if v or not AvatarAbilitiesInterface.isEnabled() then
			local v4 = v3 and 70 or 120
			self.jumpButton.Image = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"
			self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
			self.jumpButton.ImageRectSize = Vector2.new(144, 144)
			self.jumpButton.Size = UDim2.new(0, v4, 0, v4)
			self.jumpButton.Position = v3 and UDim2.new(1, -(v4 * 1.5 - 10), 1, -v4 - 20)
				or UDim2.new(1, -(v4 * 1.5 - 10), 1, -v4 * 1.75)
		else
			local v4 = v3 and 72 or 120
			local v5 = -v4 - (v3 and 64 or 100)
			local v6 = -v4 - (v3 and 64 or 112)

			self.jumpButton.Image = v2[1]
			self.jumpButton.ImageRectOffset = Vector2.new(0, 0)
			self.jumpButton.ImageRectSize = Vector2.new(0, 0)
			self.jumpButton.Size = UDim2.new(0, v4, 0, v4)
			self.jumpButton.Position = UDim2.new(1, v5, 1, v6)
		end
	end

	ResizeJumpButton()
	self.absoluteSizeChangedConn = self.parentUIFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeJumpButton)

	if not v then
		self.avatarAbilitiesEnabledChangedConn = AvatarAbilitiesInterface.GetEnabledChangedSignal():Connect(ResizeJumpButton)
	end

	self.jumpButton.Parent = self.parentUIFrame

	if not self.data.controlModule.actions.JumpAction then
		return
	end

	local touchBinding = self.data.controlModule.actions.JumpAction:WaitForChild("TouchBinding")
	touchBinding.UIButton = self.jumpButton

	self.data.controlModule.actions.JumpAction.Pressed:Connect(function()
		if not self.jumpButton then
			return
		end

		if v or not AvatarAbilitiesInterface.isEnabled() then
			self.jumpButton.ImageRectOffset = Vector2.new(146, 146)
		else
			self.jumpButton.Image = v2[2]
		end
	end)

	self.data.controlModule.actions.JumpAction.Released:Connect(function()
		if not self.jumpButton then
			return
		end

		if v or not AvatarAbilitiesInterface.isEnabled() then
			self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		else
			self.jumpButton.Image = v2[1]
		end
	end)
end

return object