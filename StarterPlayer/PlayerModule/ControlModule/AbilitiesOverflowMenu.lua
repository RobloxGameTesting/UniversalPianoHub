local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local connectionUtil = CommonUtils.get("ConnectionUtil")
local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local v = AvatarAbilitiesInterface.get(Players.LocalPlayer)
local InputSlots = require(script.Parent:WaitForChild("InputSlots"))
local AbilityButton = require(script.Parent:WaitForChild("AbilityButton"))

local v2 = { 28, 44 }
local v3 = { 36, 56 }
local v4 = { 16, 12 }
local v5 = { 16, 12 }

local function IsPortrait(): boolean -- 2 equivalent calls inferred from this helper
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		return playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait
	end

	return false
end

local AbilitiesOverflowMenu = {}
AbilitiesOverflowMenu.__index = AbilitiesOverflowMenu

function AbilitiesOverflowMenu.new(parentUIFrame)
	local self = setmetatable({}, AbilitiesOverflowMenu)

	self.parentUIFrame = parentUIFrame
	self.managedButtons = {}

	self.created = false
	self.enabled = false
	self.enabledChangedEvent = Instance.new("BindableEvent")

	self.selectionMode = false
	self.selectedVisibleSlot = 1
	self.numVisibleSlots = 0
	self.abilityButtonsByVisibleSlot = {}
	self.selectionRing = nil
	self.activeActionSlot = nil
	self.activeButton = nil
	self.scrollHighlightDirection = "none"
	self.connections = connectionUtil.new()
	self.inputFolder = nil
	self.navContext = nil

	return self
end

function AbilitiesOverflowMenu:Enable(enabled)
	if self.enabled == enabled then
		return
	end

	self.enabled = enabled

	if enabled and not self.created then
		self:Create()
		self.created = true
	end

	if not enabled then
		self:ExitSelectionMode()
	end

	if self.created then
		self:UpdateInputMode()
	end

	self.enabledChangedEvent:Fire()
end

function AbilitiesOverflowMenu:CreateOverflowScrollButton(p: string)
	local scrollButton = Instance.new("ImageButton")
	scrollButton.Name = "ScrollButton"
	scrollButton.BackgroundTransparency = 1
	scrollButton.Image = "rbxassetid://120193229129639"
	scrollButton.PressedImage = "rbxassetid://122643389561468"
	scrollButton.Parent = self.parentUIFrame

	local function ResizeButton()
		local v6 = math.min(self.parentUIFrame.AbsoluteSize.x, self.parentUIFrame.AbsoluteSize.y)
		local portrait = IsPortrait() -- inferred equivalent call
		local v7 = v6 <= 500
		local v8 = v7 and v2 or v3
		local v9 = v7 and v4 or v5
		local v10 = v8[1]
		local v11 = v8[2]
		local v12 = v9[1]
		local v13 = v9[2]

		local v14 = 0.5 * (v11 - v10)

		local numOverflowSlots = InputSlots.GetNumOverflowSlots()
		local v15 = numOverflowSlots * (v7 and 44 or 56) + (numOverflowSlots + 1) * (v7 and 8 or 10)

		scrollButton.Size = UDim2.new(0, v10, 0, v11)

		if p == "previous" then
			if portrait then
				scrollButton.Position = UDim2.new(1, -v12 - v11 + v14, 0, v13 + v10 + v15 - v14)

				scrollButton.Rotation = 270
			else
				scrollButton.Position = UDim2.new(1, -v12 - 2 * v10 - v15, 0, v13)
				scrollButton.Rotation = 0
			end
		elseif portrait then
			scrollButton.Position = UDim2.new(1, -v12 - v11 + v14, 0, v13 - v14)
			scrollButton.Rotation = 90
		else
			scrollButton.Position = UDim2.new(1, -v12 - v10, 0, v13)
			scrollButton.Rotation = 180
		end
	end

	ResizeButton()

	local v6 = connectionUtil.new()
	v6:trackConnection(
		"ParentResize",
		self.parentUIFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeButton)
	)

	scrollButton.Activated:Connect(function()
		if p == "previous" then
			InputSlots.setOverflowScrollIndex(InputSlots.getOverflowScrollIndex() + 1)
		else
			InputSlots.setOverflowScrollIndex(InputSlots.getOverflowScrollIndex() - 1)
		end
	end)

	scrollButton.Destroying:Connect(function()
		v6:disconnectAll()
	end)

	scrollButton.Selectable = false

	if AbilitiesOverflowMenu.IsGamepad() then
		scrollButton.Active = false
		scrollButton.AutoButtonColor = false
	end

	return scrollButton
end

function AbilitiesOverflowMenu:SetScrollHighlight(scrollHighlightDirection: string)
	if self.scrollHighlightDirection == scrollHighlightDirection then
		return
	end

	self.scrollHighlightDirection = scrollHighlightDirection

	if self.created then
		self:CreateButtons()
	end
end

function AbilitiesOverflowMenu:GetScrollDirectionForMove(p: string): string
	if not self.selectionMode or self.activeActionSlot or p == "none" then
		return "none"
	end

	local v6 = p == "previous" and 1 or -1
	local v7 = math.max(0, #InputSlots.GetAbilitiesInOverflow() - InputSlots.GetNumOverflowSlots())
	local overflowScrollIndex = InputSlots.getOverflowScrollIndex()
	local v8 = self.selectedVisibleSlot + v6

	if v8 < 1 and overflowScrollIndex > 0 then
		return "next"
	end

	if self.numVisibleSlots < v8 and overflowScrollIndex < v7 then
		return "previous"
	end

	return "none"
end

function AbilitiesOverflowMenu.IsGamepad(): boolean
	return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

function AbilitiesOverflowMenu.IsKeyboardMouse(): boolean
	return UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
end

function AbilitiesOverflowMenu.SupportsSelection()
	return AbilitiesOverflowMenu.IsGamepad() or AbilitiesOverflowMenu.IsKeyboardMouse()
end

function AbilitiesOverflowMenu:EnsureSelectionRing()
	if self.selectionRing then
		return
	end

	local selectionRing = Instance.new("Frame")
	selectionRing.Name = "SelectionRing"
	selectionRing.BackgroundTransparency = 1
	selectionRing.Size = UDim2.new(1, 8, 1, 8)
	selectionRing.Position = UDim2.new(0, -4, 0, -4)

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = selectionRing

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 3
	uiStroke.Color = Color3.new(1, 1, 1)
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = selectionRing

	self.selectionRing = selectionRing
end

function AbilitiesOverflowMenu:EnsureInputObjects()
	if self.inputFolder then
		return
	end

	local abilitiesOverflowInput = script:FindFirstChild("AbilitiesOverflowInput")

	if abilitiesOverflowInput then
		abilitiesOverflowInput:Destroy()
	end

	local abilitiesOverflowInput2 = Instance.new("Folder")
	abilitiesOverflowInput2.Name = "AbilitiesOverflowInput"

	local abilitiesOverflowNavContext = Instance.new("InputContext")
	abilitiesOverflowNavContext.Name = "AbilitiesOverflowNavContext"
	abilitiesOverflowNavContext.Priority = 500
	abilitiesOverflowNavContext.Sink = true
	abilitiesOverflowNavContext.Enabled = false
	abilitiesOverflowNavContext.Parent = abilitiesOverflowInput2

	local function createNavAction(name, items)
		local inputAction = Instance.new("InputAction")
		inputAction.Name = name
		inputAction.Type = Enum.InputActionType.Bool
		inputAction.Parent = abilitiesOverflowNavContext

		for k, item in items do
			local inputBinding = Instance.new("InputBinding")
			inputBinding.Name = "Binding" .. k
			inputBinding.KeyCode = item
			inputBinding.Parent = inputAction
		end

		return inputAction
	end

	local navAction = createNavAction("NavPreviousAction", {
		Enum.KeyCode.ButtonL1,
		Enum.KeyCode.DPadLeft,
		Enum.KeyCode.Left
	})
	self.connections:trackConnection("NavPrevious", navAction.StateChanged:Connect(function(p)
		if p then
			self:SetScrollHighlight(self:GetScrollDirectionForMove("previous"))
			return
		end

		self:SetScrollHighlight("none")
		self:MoveSelection("previous")
	end))

	local navAction2 = createNavAction("NavNextAction", {
		Enum.KeyCode.ButtonR1,
		Enum.KeyCode.DPadRight,
		Enum.KeyCode.Right
	})
	self.connections:trackConnection("NavNext", navAction2.StateChanged:Connect(function(p)
		if p then
			self:SetScrollHighlight(self:GetScrollDirectionForMove("next"))
			return
		end

		self:SetScrollHighlight("none")
		self:MoveSelection("next")
	end))

	local navAction3 = createNavAction("ExitAction", { Enum.KeyCode.ButtonB })
	self.connections:trackConnection("Exit", navAction3.Pressed:Connect(function()
		self:ExitSelectionMode()
	end))

	local navAction4 = createNavAction("ActivateAction", {
		Enum.KeyCode.ButtonA,
		Enum.KeyCode.Return,
		Enum.KeyCode.KeypadEnter
	})
	self.connections:trackConnection("Activate", navAction4.StateChanged:Connect(function(p)
		if p then
			self.activeActionSlot = self.selectedVisibleSlot
			self.activeButton = self.abilityButtonsByVisibleSlot[self.activeActionSlot]

			if self.activeButton then
				self.activeButton:SetSelectionPressed(true)
			end
		elseif self.activeActionSlot then
			self:ExitSelectionMode()
		end
	end))

	createNavAction("AbilitySinkAction", {
		Enum.KeyCode.ButtonX,
		Enum.KeyCode.ButtonY,
		Enum.KeyCode.ButtonL2,
		Enum.KeyCode.ButtonR2,
		Enum.KeyCode.DPadDown
	})

	abilitiesOverflowInput2.Parent = script

	self.inputFolder = abilitiesOverflowInput2
	self.navContext = abilitiesOverflowNavContext
end

function AbilitiesOverflowMenu:UpdateInputMode()
	if not self.parentUIFrame then
		return
	end

	if AbilitiesOverflowMenu.SupportsSelection() then
		self:EnsureInputObjects()

		if not self.enabled and self.selectionMode then
			self:ExitSelectionMode()
		end
	elseif self.selectionMode then
		self:ExitSelectionMode()
	end

	self.parentUIFrame.Visible = true
end

function AbilitiesOverflowMenu:EnterSelectionMode()
	if
		self.selectionMode
		or not (AbilitiesOverflowMenu.SupportsSelection() and self.enabled)
		or self.numVisibleSlots <= 0
	then
		return
	end

	self.selectionMode = true

	if self.navContext then
		self.navContext.Enabled = true
	end

	self.parentUIFrame.Visible = true
	self.selectedVisibleSlot = math.clamp(self.selectedVisibleSlot, 1, self.numVisibleSlots)
	self:RefreshSelection()
end

function AbilitiesOverflowMenu:ExitSelectionMode()
	self.selectionMode = false

	if self.navContext then
		self.navContext.Enabled = false
	end

	if self.scrollHighlightDirection ~= "none" then
		self.scrollHighlightDirection = "none"

		if self.created then
			self:CreateButtons()
		end
	end

	if self.activeButton then
		self.activeButton:SetSelectionPressed(false)
		self.activeButton = nil
	end

	self.activeActionSlot = nil

	if self.selectionRing then
		self.selectionRing.Parent = nil
	end
end

function AbilitiesOverflowMenu:MoveSelection(p: string)
	if not self.selectionMode or self.activeActionSlot or p == "none" then
		return
	end

	local v6 = p == "previous" and 1 or -1

	local v7 = math.max(0, #InputSlots.GetAbilitiesInOverflow() - InputSlots.GetNumOverflowSlots())
	local overflowScrollIndex = InputSlots.getOverflowScrollIndex()

	local selectedVisibleSlot = self.selectedVisibleSlot + v6

	if selectedVisibleSlot < 1 then
		if overflowScrollIndex > 0 then
			self.selectedVisibleSlot = 1
			InputSlots.setOverflowScrollIndex(overflowScrollIndex - 1)
		end
	elseif self.numVisibleSlots < selectedVisibleSlot then
		if overflowScrollIndex < v7 then
			self.selectedVisibleSlot = self.numVisibleSlots
			InputSlots.setOverflowScrollIndex(overflowScrollIndex + 1)
		end
	else
		self.selectedVisibleSlot = selectedVisibleSlot
	end

	self:RefreshSelection()
end

function AbilitiesOverflowMenu:RefreshSelection()
	if not (AbilitiesOverflowMenu.SupportsSelection() and self.selectionMode) or self.numVisibleSlots <= 0 then
		return
	end

	self.selectedVisibleSlot = math.clamp(self.selectedVisibleSlot, 1, self.numVisibleSlots)
	local abilityButton = self.abilityButtonsByVisibleSlot[self.selectedVisibleSlot]

	if abilityButton then
		self:EnsureSelectionRing()
		self.selectionRing.Parent = abilityButton.instance
		self.selectionRing.Visible = true
	end
end

function AbilitiesOverflowMenu:Teardown()
	self.connections:disconnectAll()

	self.created = false

	self:ExitSelectionMode()

	if self.inputFolder then
		self.inputFolder:Destroy()
		self.inputFolder = nil
		self.navContext = nil
	end

	if self.selectionRing then
		self.selectionRing:Destroy()
		self.selectionRing = nil
	end
end

function AbilitiesOverflowMenu:CreateButtons()
	if self.selectionRing then
		self.selectionRing.Parent = nil
	end

	for _, managedButton in self.managedButtons do
		managedButton:Destroy()
	end

	self.managedButtons = {}
	self.abilityButtonsByVisibleSlot = {}
	self.numVisibleSlots = 0

	if not v:isEnabled() then
		return
	end

	local abilitiesInOverflow = InputSlots.GetAbilitiesInOverflow()
	local v6 = math.min(#abilitiesInOverflow, InputSlots.GetNumOverflowSlots())

	local v7 = nil
	local v8 = nil
	local v9, v10

	if #abilitiesInOverflow > InputSlots.GetNumOverflowSlots() then
		local overflowScrollIndex = InputSlots.getOverflowScrollIndex()
		local v11 = #abilitiesInOverflow - InputSlots.GetNumOverflowSlots()

		if overflowScrollIndex > 0 then
			v8 = self:CreateOverflowScrollButton("next")
			table.insert(self.managedButtons, v8)
		end

		if overflowScrollIndex < v11 then
			v7 = self:CreateOverflowScrollButton("previous")
			table.insert(self.managedButtons, v7)
		end

		v9 = v2[1] + 8
		v10 = v3[1] + 10
	else
		v9 = 0
		v10 = 0
	end

	if self.scrollHighlightDirection == "previous" and v7 then
		v7.Image = "rbxassetid://122643389561468"
	elseif self.scrollHighlightDirection == "next" and v8 then
		v8.Image = "rbxassetid://122643389561468"
	end

	for i = 1, v6 do
		local v11 = abilitiesInOverflow[i + InputSlots.getOverflowScrollIndex()]
		local overflowAction = InputSlots.GetOverflowAction(i)

		if not (v11 and overflowAction) then
			continue
		end

		local abilityConfig = v:GetAbilityConfig(v11)
		local portrait = IsPortrait() -- inferred equivalent call
		local v12

		if portrait then
			v12 = {
				small = { 44, v4[1], v4[2] + v9 + (i - 1) * 52 },
				large = { 56, v5[1], v5[2] + v10 + (i - 1) * 66 }
			}
		else
			v12 = {
				small = { 44, v4[1] + v9 + (i - 1) * 52, v4[2] },
				large = { 56, v5[1] + v10 + (i - 1) * 66, v5[2] }
			}
		end

		local activeButton = AbilityButton.create(self, v11, abilityConfig, overflowAction, v12, true, true)
		table.insert(self.managedButtons, activeButton)
		self.abilityButtonsByVisibleSlot[i] = activeButton
		self.numVisibleSlots = i

		if i ~= self.activeActionSlot then
			continue
		end

		self.activeButton = activeButton
		activeButton:SetSelectionPressed(true)
	end

	self.parentUIFrame.Visible = true

	if self.selectionMode then
		if self.numVisibleSlots <= 0 then
			self:ExitSelectionMode()
		elseif AbilitiesOverflowMenu.SupportsSelection() then
			self:RefreshSelection()
		end
	end
end

function AbilitiesOverflowMenu:Create()
	if not self.parentUIFrame then
		return
	end

	self:CreateButtons()

	self.connections:trackConnection("SlotMapChanged", InputSlots.GetSlotMapChangedSignal():Connect(function()
		self:CreateButtons()
		self.selectedVisibleSlot = self.numVisibleSlots
		self:RefreshSelection()
	end))

	self.connections:trackConnection("AbilitiesEnabledChanged", v:GetEnabledChangedSignal():Connect(function()
		self:CreateButtons()
	end))

	self.connections:trackConnection("ScrollIndexChanged", InputSlots.getScrollIndexChangedEvent():Connect(function()
		self:CreateButtons()
	end))

	self.connections:trackConnection(
		"PreferredInput",
		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			self:UpdateInputMode()
			self:CreateButtons()
		end)
	)

	self.connections:trackConnection("InputBegan", UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not self.enabled then
			return
		end

		if
			(not AbilitiesOverflowMenu.IsGamepad() or input.KeyCode ~= Enum.KeyCode.DPadUp)
			and (not AbilitiesOverflowMenu.IsKeyboardMouse() or input.KeyCode ~= Enum.KeyCode.M)
		then
			return
		end

		if self.selectionMode then
			self:ExitSelectionMode()
		else
			self:EnterSelectionMode()
		end
	end))

	self.connections:trackConnection("MenuOpened", GuiService.MenuOpened:Connect(function()
		if self.selectionMode then
			self:ExitSelectionMode()
		end
	end))

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 5)

	if playerGui then
		self.connections:trackConnection(
			"ScreenOrientation",
			playerGui:GetPropertyChangedSignal("CurrentScreenOrientation"):Connect(function()
				self:CreateButtons()
			end)
		)
	end

	self.parentUIFrame.Destroying:Connect(function()
		self:Teardown()
	end)

	self:UpdateInputMode()
end

return AbilitiesOverflowMenu