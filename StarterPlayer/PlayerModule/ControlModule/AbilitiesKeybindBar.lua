local UserInputService = game:GetService("UserInputService")

local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local InputSlots = require(script.Parent:WaitForChild("InputSlots"))
local connectionUtil = CommonUtils.get("ConnectionUtil")

local DPadUp = Enum.KeyCode.DPadUp
local m = Enum.KeyCode.M

local color = Color3.fromRGB(18, 18, 21)

local BuilderSans = Enum.Font.BuilderSans

local color2 = Color3.fromRGB(247, 247, 248)

local BuilderSansBold = Enum.Font.BuilderSansBold

local color3 = Color3.fromRGB(247, 247, 248)
local color4 = Color3.fromRGB(18, 18, 21)

local set = {}

for _, v in {
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.ButtonL3,
	Enum.KeyCode.ButtonR3,
	Enum.KeyCode.ButtonStart,
	Enum.KeyCode.ButtonSelect,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight,
	Enum.KeyCode.DPadUp,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.Thumbstick1,
	Enum.KeyCode.Thumbstick2
} do
	set[v] = true
end

local set2 = {
	[Enum.KeyCode.ButtonCenter] = true,
	[Enum.KeyCode.ButtonUp] = true,
	[Enum.KeyCode.ButtonDown] = true,
	[Enum.KeyCode.ButtonLeft] = true,
	[Enum.KeyCode.ButtonRight] = true
}

local function actionKeyCode(child)
	for _, inputBinding in child:GetChildren() do
		if not inputBinding:IsA("InputBinding") then
			continue
		end

		local keyCode = inputBinding.KeyCode
		local v

		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			v = set[keyCode] == true
		elseif keyCode == Enum.KeyCode.None then
			v = false
		else
			v = not (set[keyCode] or set2[keyCode])
		end

		if v then
			return keyCode
		end
	end

	return nil
end

local function createEntryFrame(bar, name: string, layoutOrder: number)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.LayoutOrder = layoutOrder
	frame.Size = UDim2.new(0, 0, 0, 28)
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = bar

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingRight = UDim.new(0, 8)
	uiPadding.Parent = frame

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.Parent = frame

	return frame
end

local function createKeyIndicator(entryFrame, p, layoutOrder: number)
	if p and UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		local imageForKeyCode = UserInputService:GetImageForKeyCode(p)

		if imageForKeyCode ~= "" then
			local key = Instance.new("ImageLabel")
			key.Name = "Key"
			key.LayoutOrder = layoutOrder
			key.Size = UDim2.new(0, 24, 0, 24)
			key.BackgroundTransparency = 1
			key.Image = imageForKeyCode
			key.Parent = entryFrame
			return
		end
	end

	local text

	if p and p ~= Enum.KeyCode.None then
		text = UserInputService:GetStringForKeyCode(p, Enum.KeyCodeStringFormat.Abbreviated)

		if text:match("^%s*$") then
			text = p.Name
		end
	else
		text = "?"
	end

	local key = Instance.new("TextLabel")
	key.Name = "Key"
	key.LayoutOrder = layoutOrder
	key.AutomaticSize = Enum.AutomaticSize.XY
	key.Size = UDim2.new(0, 0, 0, 0)
	key.BackgroundColor3 = color3
	key.BackgroundTransparency = 0
	key.BorderSizePixel = 0
	key.Font = BuilderSansBold
	key.TextSize = 14
	key.TextColor3 = color4
	key.Text = text
	key.Parent = entryFrame

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 2)
	uiCorner.Parent = key

	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MinSize = Vector2.new(10, 10)
	uiSizeConstraint.Parent = key

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 5)
	uiPadding.PaddingRight = UDim.new(0, 5)
	uiPadding.PaddingTop = UDim.new(0, 1)
	uiPadding.PaddingBottom = UDim.new(0, 2)
	uiPadding.Parent = key
end

local function createLabel(entryFrame, text: string, layoutOrder: number)
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.LayoutOrder = layoutOrder
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 0, 28)
	label.BackgroundTransparency = 1
	label.Font = BuilderSans
	label.TextSize = 18
	label.TextColor3 = color2
	label.Text = text
	label.Parent = entryFrame

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, -0)
	uiPadding.PaddingBottom = UDim.new(0, 0)
	uiPadding.Parent = label
end

local AbilitiesKeybindBar = {}
AbilitiesKeybindBar.__index = AbilitiesKeybindBar

function AbilitiesKeybindBar.new(parent)
	local self = setmetatable({}, AbilitiesKeybindBar)

	self.parent = parent
	self.characterContext = nil
	self.created = false
	self.enabled = false
	self.bar = nil
	self.connections = connectionUtil.new()

	self.contextConnections = connectionUtil.new()

	return self
end

function AbilitiesKeybindBar:GetInputContextsParent()
	return script:FindFirstAncestor("PlayerModule")
end

function AbilitiesKeybindBar:ResolveCharacterContext()
	local inputContextsParent = self:GetInputContextsParent()
	local inputContexts = inputContextsParent and inputContextsParent:FindFirstChild("InputContexts")

	if inputContexts then
		return inputContexts:FindFirstChild("CharacterContext")
	end

	return nil
end

function AbilitiesKeybindBar:ResolveAndBind()
	self.connections:disconnect("ResolveWatcher")

	local characterContext = self:ResolveCharacterContext()

	if characterContext then
		self:BindCharacterContext(characterContext)
		return
	end

	local inputContextsParent = self:GetInputContextsParent()

	if not inputContextsParent then
		return
	end

	local function bindWhenCharacterContextReady(instance)
		local characterContext2 = instance:FindFirstChild("CharacterContext")

		if not characterContext2 then
			self.connections:trackConnection("ResolveWatcher", instance.ChildAdded:Connect(function(child)
				if child.Name == "CharacterContext" then
					self.connections:disconnect("ResolveWatcher")
					self:BindCharacterContext(child)
				end
			end))

			return
		end

		self.connections:disconnect("ResolveWatcher")
		self:BindCharacterContext(characterContext2)
	end

	local inputContexts = inputContextsParent:FindFirstChild("InputContexts")

	if inputContexts then
		bindWhenCharacterContextReady(inputContexts)
	else
		self.connections:trackConnection("ResolveWatcher", inputContextsParent.ChildAdded:Connect(function(child)
			if child.Name == "InputContexts" then
				bindWhenCharacterContextReady(child)
			end
		end))
	end
end

function AbilitiesKeybindBar:BindCharacterContext(characterContext)
	self.characterContext = characterContext

	self.contextConnections:disconnectAll()

	if characterContext then
		local function watchAction(instance)
			self.contextConnections:trackConnection(
				instance.Name .. "_Enabled",
				instance:GetPropertyChangedSignal("Enabled"):Connect(function()
					self:Rebuild()
				end)
			)

			self.contextConnections:trackConnection(
				instance.Name .. "_AttributeChanged",
				instance.AttributeChanged:Connect(function()
					self:Rebuild()
				end)
			)
		end

		for i = 1, InputSlots.GetNumAbilitySlots() do
			local child = characterContext:FindFirstChild("AbilityAction" .. i)

			if child then
				watchAction(child)
			end
		end

		self.contextConnections:trackConnection("ChildAdded", characterContext.ChildAdded:Connect(function(inputAction)
			if inputAction:IsA("InputAction") and string.match(inputAction.Name, "^AbilityAction%d+$") then
				watchAction(inputAction)
				self:Rebuild()
			end
		end))

		self.contextConnections:trackConnection(
			"ChildRemoved",
			characterContext.ChildRemoved:Connect(function(inputAction)
				if inputAction:IsA("InputAction") and string.match(inputAction.Name, "^AbilityAction%d+$") then
					self.contextConnections:disconnect(inputAction.Name .. "_Enabled")
					self.contextConnections:disconnect(inputAction.Name .. "_AttributeChanged")
					self:Rebuild()
				end
			end)
		)
	end

	self:Rebuild()
end

function AbilitiesKeybindBar:IsVisiblePlatform(): boolean
	local preferredInput = UserInputService.PreferredInput
	return preferredInput == Enum.PreferredInput.KeyboardAndMouse or preferredInput == Enum.PreferredInput.Gamepad
end

function AbilitiesKeybindBar:Enable(enabled: boolean)
	if self.enabled == enabled then
		return
	end

	self.enabled = enabled

	if enabled and not self.created then
		self:Create()
		self.created = true
	end

	self:Rebuild()
end

function AbilitiesKeybindBar:CreateEntry(layoutOrder: number, text: string, p)
	local entryFrame = createEntryFrame(self.bar, "Slot" .. layoutOrder, layoutOrder)

	createKeyIndicator(entryFrame, p, 1)
	createLabel(entryFrame, text, 2)
end

function AbilitiesKeybindBar:CreateActionEntry(name: string, layoutOrder: number, text: string, p)
	local entryFrame = createEntryFrame(self.bar, name, layoutOrder)

	createKeyIndicator(entryFrame, p, 1)
	createLabel(entryFrame, text, 2)
end

function AbilitiesKeybindBar:Rebuild()
	if not self.bar then
		return
	end

	for _, frame in self.bar:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	local characterContext = self.characterContext

	if not (self.enabled and self:IsVisiblePlatform() and characterContext) then
		self.bar.Visible = false
		return
	end

	local visible = false
	local preferredInput = UserInputService.PreferredInput

	if #InputSlots.GetAbilitiesInOverflow() > 0 then
		local v

		if preferredInput == Enum.PreferredInput.Gamepad then
			v = DPadUp
		elseif preferredInput == Enum.PreferredInput.KeyboardAndMouse then
			v = m
		end

		if v then
			self:CreateActionEntry("MoreActions", InputSlots.GetNumAbilitySlots() + 1, "More Actions", v)
			visible = true
		end
	end

	for i = 1, InputSlots.GetNumAbilitySlots() do
		local child = characterContext:FindFirstChild("AbilityAction" .. i)

		if not (child and child.Enabled) then
			continue
		end

		local displayName = child.DisplayName

		if not (type(displayName) == "string" and displayName ~= "") then
			continue
		end

		self:CreateEntry(i, displayName, actionKeyCode(child))
		visible = true
	end

	self.bar.Visible = visible
end

function AbilitiesKeybindBar:Create()
	if not self.parent then
		return
	end

	local abilityKeybindBar = Instance.new("Frame")
	abilityKeybindBar.Name = "AbilityKeybindBar"
	abilityKeybindBar.AnchorPoint = Vector2.new(1, 1)
	abilityKeybindBar.Position = UDim2.new(1, -17, 1, -17)
	abilityKeybindBar.Size = UDim2.new(0, 0, 0, 28)
	abilityKeybindBar.AutomaticSize = Enum.AutomaticSize.XY
	abilityKeybindBar.BackgroundColor3 = color
	abilityKeybindBar.BackgroundTransparency = 0.4
	abilityKeybindBar.BorderSizePixel = 0
	abilityKeybindBar.Visible = false
	abilityKeybindBar.Parent = self.parent
	self.bar = abilityKeybindBar

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = abilityKeybindBar

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 16)
	uiPadding.PaddingRight = UDim.new(0, 12)
	uiPadding.PaddingTop = UDim.new(0, 4)
	uiPadding.PaddingBottom = UDim.new(0, 4)
	uiPadding.Parent = abilityKeybindBar

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 8)
	uiListLayout.Parent = abilityKeybindBar

	self.connections:trackConnection(
		"PreferredInput",
		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			self:Rebuild()
		end)
	)

	self.connections:trackConnection("SlotMapChanged", InputSlots.GetSlotMapChangedSignal():Connect(function()
		self:Rebuild()
	end))

	self.connections:trackConnection("ParentDestroying", self.parent.Destroying:Connect(function()
		self:Teardown()
	end))

	self:ResolveAndBind()
end

function AbilitiesKeybindBar:Teardown()
	self.connections:disconnectAll()
	self.contextConnections:disconnectAll()

	if self.bar then
		self.bar:Destroy()
		self.bar = nil
	end

	self.created = false
end

return AbilitiesKeybindBar