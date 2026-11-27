local Players = game:GetService("Players")
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local v = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
	or flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationDGA")
local v2 = flagUtil.getUserFlag("UserPlayerScriptsPlayerControlState2")
	or flagUtil.getUserFlag("UserPlayerScriptsPlayerControlState2GA")
local userFlag = flagUtil.getUserFlag("UserPlayerScriptsTaskDeferSimulation")

local userFlag2 = flagUtil.getUserFlag("UserPlayerScriptsImportWaitForAbilitiesFolder")
local userFlag3 = flagUtil.getUserFlag("UserAbilitiesUserInterfaceD")
local fn

if userFlag2 then
	fn = nil
else
	local function waitForChildren(instance, list, duration: number?)
		if #list == 0 then
			return nil
		end

		for _, childName in list do
			local child = instance:FindFirstChild(childName)

			if child then
				return child
			end
		end

		local thread = coroutine.running()
		local v3 = nil
		local flag = false

		local function settle(child) -- 2 equivalent calls inferred from this helper
			if flag then
				return
			end

			flag = true
			v3 = child

			task.spawn(thread)
		end

		local childAddedConnection = instance.ChildAdded:Connect(function(child)
			if table.find(list, child.Name) then
				settle(child) -- inferred equivalent call
			end
		end)
		local thread2

		if duration then
			thread2 = task.delay(duration, function()
				settle(nil) -- inferred equivalent call
			end)
		end

		coroutine.yield()

		childAddedConnection:Disconnect()

		if thread2 and coroutine.status(thread2) == "suspended" then
			task.cancel(thread2)
		end

		return v3
	end

	fn = function(p, p2: number?)
		if not p then
			return nil
		end

		local v3

		if p2 then
			v3 = time() + p2
		else
			v3 = nil
		end

		local function getRemainingTime() -- 2 equivalent calls inferred from this helper
			if v3 then
				return (math.max(v3 - time(), 0))
			end

			return nil
		end

		local folder = waitForChildren(p, { "AbilityManagerActor", "Abilities" }, getRemainingTime()) -- inferred equivalent call

		if not folder then
			return nil
		end

		if folder.Name == "Abilities" then
			return if folder:IsA("Folder") then folder else nil
		else
			local remainingTime = getRemainingTime() -- inferred equivalent call
			local abilities

			if remainingTime then
				abilities = folder:WaitForChild("Abilities", remainingTime)
			else
				abilities = folder:WaitForChild("Abilities")
			end

			if abilities and abilities:IsA("Folder") then
				return abilities
			end

			return nil
		end
	end
end

if v then
	local class = {}
	class.__index = class

	local v3 = {}

	Players.PlayerRemoving:Connect(function(player)
		wait(1)
		local v4 = v3[player.UserId]

		if v4 then
			v4:destroy()
			v3[player.UserId] = nil
		end
	end)

	local function createAbilitiesByInputNameTable(instance)
		local configurationsByInputName = {}

		for _, configuration in instance:GetChildren() do
			if not configuration:IsA("Configuration") then
				continue
			end

			local inputName = configuration:GetAttribute("InputName")

			if inputName then
				configurationsByInputName[inputName] = configuration
			end
		end

		return configurationsByInputName
	end

	local function notifyAbilitiesChanged(instance, fn2)
		local childAddedConnection = instance.ChildAdded:Connect(function(configuration)
			if configuration:IsA("Configuration") then
				fn2(configuration, "added")
			end
		end)
		local childRemovedConnection = instance.ChildRemoved:Connect(function(configuration)
			if configuration:IsA("Configuration") then
				fn2(configuration, "removed")
			end
		end)
		return function()
			childAddedConnection:Disconnect()
			childRemovedConnection:Disconnect()
		end
	end

	function class._new(player)
		local object = setmetatable({}, class)

		object._player = player
		object._data = {}
		object._character = nil
		object._humanoid = nil
		object._enabledChangedEvent = Instance.new("BindableEvent")
		object._abilitiesChangedEvent = Instance.new("BindableEvent")
		object._evaluateStateMachineChangedConnection = nil
		object._abilityChangedEvents = {}
		object._abilityChangedConnections = {}

		object._abilitiesByInputName = {}
		object._disconnectAbilitiesChanged = nil

		if v2 and not userFlag then
			task.spawn(function()
				object._characterAddedConnection = player.CharacterAdded:Connect(function(character)
					object:_onCharacterAdded(character)
				end)
			end)
		else
			object._characterAddedConnection = player.CharacterAdded:Connect(function(character)
				object:_onCharacterAdded(character)
			end)
		end

		if player.Character then
			object:_onCharacterAdded(player.Character)
		end

		return object
	end

	local v4 = nil

	function class._avatarAbilities()
		if v4 then
			return v4
		end

		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local packages = ReplicatedStorage:FindFirstChild("Packages")
		local avatarAbilities

		if packages then
			avatarAbilities = packages:FindFirstChild("AvatarAbilities")
		end

		local v5

		if avatarAbilities then
			v5 = require(avatarAbilities)
		end

		v4 = v5

		if not v4 then
			local module = require("@rbx/AvatarAbilities")
			v4 = module
		end

		return v4
	end

	function class.get(p)
		if not p or p.UserId == 0 then
			return nil
		end

		local v5 = v3[p.UserId]

		if not v5 then
			v5 = class._new(p)
			v3[p.UserId] = v5
		end

		return v5
	end

	function class:_hookUpAbilityChangedEvent(p, p2)
		local ability = self._abilitiesByInputName[p]

		if not ability then
			return
		end

		local syncedState = ability:FindFirstChild("SyncedState")

		if not syncedState then
			return
		end

		if not self._abilityChangedConnections[p2] then
			self._abilityChangedConnections[p2] = {}
		end

		if self._abilityChangedConnections[p2][p] then
			self._abilityChangedConnections[p2][p]:Disconnect()
			self._abilityChangedConnections[p2][p] = nil
		end

		self._abilityChangedConnections[p2][p] = syncedState:GetAttributeChangedSignal(p2):Connect(function()
			self._abilityChangedEvents[p2][p]:Fire()
		end)
	end

	function class:_onCharacterAdded(character)
		self._humanoid = nil
		self._character = character
		self._abilitiesByInputName = {}
		self._data = {}

		if self._disconnectAbilitiesChanged then
			self._disconnectAbilitiesChanged()
			self._disconnectAbilitiesChanged = nil
		end

		for _, abilityChangedConnection in self._abilityChangedConnections do
			for _, connection in abilityChangedConnection do
				connection:Disconnect()
			end
		end

		self._abilityChangedConnections = {}

		if self._evaluateStateMachineChangedConnection then
			self._evaluateStateMachineChangedConnection:Disconnect()
			self._evaluateStateMachineChangedConnection = nil
		end

		if not self._character then
			return
		end

		local function isStale(): boolean -- 2 equivalent calls inferred from this helper
			return self._character ~= character
		end

		task.spawn(function()
			local v5

			if userFlag2 then
				v5 = self._avatarAbilities().waitForAbilitiesFolder(character)
			else
				v5 = fn(character)
			end

			if not v5 or isStale() then -- inferred equivalent call
				return
			end

			self._humanoid = character:FindFirstChildOfClass("Humanoid")

			while not self._humanoid do
				character.ChildAdded:Wait()

				if isStale() then -- inferred equivalent call
					return
				end

				self._humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			if self._evaluateStateMachineChangedConnection then
				self._evaluateStateMachineChangedConnection:Disconnect()
				self._evaluateStateMachineChangedConnection = nil
			end

			local function enabledChanged()
				if self._disconnectAbilitiesChanged then
					self._disconnectAbilitiesChanged()
					self._disconnectAbilitiesChanged = nil
				end

				if self:isEnabled() then
					self._disconnectAbilitiesChanged = notifyAbilitiesChanged(v5, function(instance, p)
						local inputName = instance:GetAttribute("InputName")

						if not inputName then
							return
						end

						if p == "added" then
							self._abilitiesByInputName[inputName] = instance

							for k, abilityChangedEvent in self._abilityChangedEvents do
								if abilityChangedEvent[inputName] then
									self:_hookUpAbilityChangedEvent(inputName, k)
								end
							end
						elseif self._abilitiesByInputName[inputName] == instance then
							self._abilitiesByInputName[inputName] = nil

							for _, abilityChangedConnection in self._abilityChangedConnections do
								local connection = abilityChangedConnection[inputName]

								if not connection then
									continue
								end

								connection:Disconnect()
								abilityChangedConnection[inputName] = nil
							end
						end

						self._abilitiesChangedEvent:Fire()
					end)

					self._abilitiesByInputName = createAbilitiesByInputNameTable(v5)
					self._abilitiesChangedEvent:Fire()

					for k, abilityChangedEvent in self._abilityChangedEvents do
						for k2, v6 in abilityChangedEvent do
							v6:Fire()
							self:_hookUpAbilityChangedEvent(k2, k)
						end
					end
				end

				self._enabledChangedEvent:Fire()
			end

			self._evaluateStateMachineChangedConnection = self._humanoid:GetPropertyChangedSignal("EvaluateStateMachine"):Connect(function()
				enabledChanged()
			end)
			enabledChanged()
		end)
	end

	function class:isEnabled(): boolean
		return self._humanoid ~= nil and not self._humanoid.EvaluateStateMachine
	end

	function class:GetEnabledChangedSignal()
		return self._enabledChangedEvent.Event
	end

	function class:SendInput(p, p2)
		if not self:isEnabled() then
			return
		end

		if p2 ~= self._data[p] then
			self._data[p] = p2
			self._avatarAbilities().setAbilityManagerCommand(self._character, p, p2)
		end
	end

	function class:GetAbilityAttribute(p, attributeName, p2)
		local ability = self._abilitiesByInputName[p]

		if not ability then
			return p2
		end

		local syncedState = ability:FindFirstChild("SyncedState")

		if not syncedState then
			return p2
		end

		local attribute = syncedState:GetAttribute(attributeName)
		return if attribute == nil then p2 else attribute
	end

	function class:GetAbilityAttributeChangedSignal(p, p2)
		if not self._abilityChangedEvents[p2] then
			self._abilityChangedEvents[p2] = {}
		end

		if self._abilityChangedEvents[p2][p] then
			return self._abilityChangedEvents[p2][p].Event
		end

		local bindableEvent = Instance.new("BindableEvent")
		self._abilityChangedEvents[p2][p] = bindableEvent

		self:_hookUpAbilityChangedEvent(p, p2)

		return bindableEvent.Event
	end

	function class:GetAbilityUIState(p)
		return self:GetAbilityAttribute(p, "UIState", nil)
	end

	function class:GetAbilityUIStateChangedSignal(p)
		return self:GetAbilityAttributeChangedSignal(p, "UIState")
	end

	if not userFlag3 then
		function class:GetAbilityActive(p)
			return self:GetAbilityAttribute(p, "Active", false)
		end

		function class:GetAbilityActiveChangedSignal(p)
			return self:GetAbilityAttributeChangedSignal(p, "Active")
		end

		function class:GetAbilityValid(p)
			return self:GetAbilityAttribute(p, "IsValid", true)
		end

		function class:GetAbilityValidChangedSignal(p)
			return self:GetAbilityAttributeChangedSignal(p, "IsValid")
		end
	end

	function class:GetAbilities()
		local abilities = {}

		for k in self._abilitiesByInputName do
			table.insert(abilities, k)
		end

		return abilities
	end

	function class:GetAbilitiesChangedSignal()
		return self._abilitiesChangedEvent.Event
	end

	function class:GetAbilityConfig(p)
		local v5 = { Slot = -1 }

		local ability = self._abilitiesByInputName[p]

		if not ability then
			return v5
		end

		local actionSlot = ability:GetAttribute("ActionSlot")

		if actionSlot then
			return {
				Slot = tonumber(actionSlot),
				ButtonAssetId = ability:GetAttribute("CustomIcon"),
				ButtonPressedAssetId = ability:GetAttribute("CustomIconActive"),
				ButtonInvalidAssetId = ability:GetAttribute("CustomIconInvalid")
			}
		end

		return v5
	end

	function class:destroy()
		if self._characterAddedConnection then
			self._characterAddedConnection:Disconnect()
			self._characterAddedConnection = nil
		end

		if self._evaluateStateMachineChangedConnection then
			self._evaluateStateMachineChangedConnection:Disconnect()
			self._evaluateStateMachineChangedConnection = nil
		end

		if self._disconnectAbilitiesChanged then
			self._disconnectAbilitiesChanged()
			self._disconnectAbilitiesChanged = nil
		end

		for _, abilityChangedConnection in self._abilityChangedConnections do
			for _, connection in abilityChangedConnection do
				connection:Disconnect()
			end
		end

		self._abilityChangedConnections = {}
	end

	return class
else
	local Players2 = game:GetService("Players")

	local abilityManagerActor = nil
	local humanoid = nil
	local bindableEvent = Instance.new("BindableEvent")
	local evaluateStateMachineChangedConnection = nil
	local flag = false

	local function characterAdded(character)
		abilityManagerActor = nil
		humanoid = nil

		if evaluateStateMachineChangedConnection then
			evaluateStateMachineChangedConnection:Disconnect()
			evaluateStateMachineChangedConnection = nil
		end

		if character then
			abilityManagerActor = character:FindFirstChild("AbilityManagerActor")
			humanoid = character:FindFirstChildOfClass("Humanoid")

			while not humanoid do
				character.ChildAdded:wait()
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			bindableEvent:Fire()

			evaluateStateMachineChangedConnection = humanoid:GetPropertyChangedSignal("EvaluateStateMachine"):Connect(function()
				bindableEvent:Fire()
			end)
		end
	end

	local function lazyInit() -- 2 equivalent calls inferred from this helper
		if flag then
			return
		end

		flag = true

		local localPlayer = Players2.LocalPlayer

		if localPlayer then
			localPlayer.characterAdded:Connect(characterAdded)

			if localPlayer.Character then
				characterAdded(localPlayer.Character)
			end
		end
	end

	return {
		isEnabled = function()
			lazyInit() -- inferred equivalent call
			return abilityManagerActor ~= nil and humanoid and not humanoid.EvaluateStateMachine
		end,
		GetEnabledChangedSignal = function()
			lazyInit() -- inferred equivalent call
			return bindableEvent.Event
		end
	}
end