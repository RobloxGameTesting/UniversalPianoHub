local Players = game:GetService("Players")
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local v = AvatarAbilitiesInterface.get(Players.LocalPlayer)
local InputSlots = require(script.Parent:WaitForChild("InputSlots"))
local AbilityButton = require(script.Parent:WaitForChild("AbilityButton"))
local userFlag = CommonUtils.get("FlagUtil").getUserFlag("UserAbilitiesUserInterfaceA")

local v2 = {
	{
		small = { 72, 60, 60 },
		large = { 92, 112, 112 }
	},
	{
		small = { 44, 132, 132 },
		large = { 56, 200, 200 }
	},
	{
		small = { 44, 132, 16 },
		large = { 56, 200, 60 }
	},
	{
		small = { 44, 16, 132 },
		large = { 56, 60, 200 }
	},
	{
		small = { 44, 156, 74 },
		large = { 56, 228, 130 }
	},
	{
		small = { 44, 74, 156 },
		large = { 56, 130, 228 }
	},
	{
		small = { 44, 16, 16 },
		large = { 56, 60, 60 }
	}
}

local TouchAbilities = {}
TouchAbilities.__index = TouchAbilities

function TouchAbilities.new(parentUIFrame)
	local self = setmetatable({}, TouchAbilities)

	self.parentUIFrame = parentUIFrame
	self.managedButtons = {}
	self.connections = {}

	self.created = false
	self.enabled = false
	self.enabledChangedEvent = Instance.new("BindableEvent")

	return self
end

function TouchAbilities:Enable(enabled)
	if self.enabled == enabled then
		return
	end

	self.enabled = enabled

	if enabled and not self.created then
		self:Create()
		self.created = true
	end

	self.enabledChangedEvent:Fire()
end

function TouchAbilities:Create()
	if not self.parentUIFrame then
		return
	end

	local function CreateButtons()
		for _, managedButton in self.managedButtons do
			managedButton:Destroy()
		end

		self.managedButtons = {}

		if v:isEnabled() then
			local slotMap = InputSlots.GetSlotMap()

			for k, slot in slotMap do
				local actionInSlot = InputSlots.GetActionInSlot(k)

				if not (slot and actionInSlot and k <= #v2 and (userFlag or k == 1)) then
					continue
				end

				local abilityConfig = v:GetAbilityConfig(slot)
				table.insert(
					self.managedButtons,
					AbilityButton.create(self, slot, abilityConfig, actionInSlot, v2[k], false)
				)
			end
		end
	end

	CreateButtons()
	table.insert(self.connections, InputSlots.GetSlotMapChangedSignal():Connect(CreateButtons))
	table.insert(self.connections, v:GetEnabledChangedSignal():Connect(CreateButtons))
end

function TouchAbilities:Destroy()
	for _, connection in self.connections do
		connection:Disconnect()
	end

	self.connections = {}

	for _, managedButton in self.managedButtons do
		managedButton:Destroy()
	end

	self.managedButtons = {}
	self.enabledChangedEvent:Destroy()
	self.created = false
	self.enabled = false
end

return TouchAbilities