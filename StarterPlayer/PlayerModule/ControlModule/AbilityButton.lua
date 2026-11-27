local Players = game:GetService("Players")
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local userFlag = CommonUtils.get("FlagUtil").getUserFlag("UserAbilitiesUserInterfaceD")
local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local v = AvatarAbilitiesInterface.get(Players.LocalPlayer)

return {
	create = function(data, p, data2, parent, p2, p3, p4)
		local image = "rbxassetid://76895455502876"
		local buttonInvalidAssetId = nil
		local v2 = false
		local v3 = false
		local image2 = not data2.ButtonAssetId and "rbxassetid://136780077406114" or data2.ButtonAssetId

		if data2.ButtonPressedAssetId then
			image = data2.ButtonPressedAssetId
		end

		if data2.ButtonInvalidAssetId then
			buttonInvalidAssetId = data2.ButtonInvalidAssetId
		end

		local imageButton = Instance.new("ImageButton")
		imageButton.Name = p .. "Button"
		imageButton.Visible = false
		imageButton.BackgroundTransparency = 1
		imageButton.Image = image2
		imageButton.Parent = data.parentUIFrame

		for _, inputBinding in parent:GetChildren() do
			if string.find(inputBinding.Name, "Touch") and inputBinding:IsA("InputBinding") then
				inputBinding.UIButton = imageButton
				break
			end
		end

		local function ResizeButton()
			local small = math.min(data.parentUIFrame.AbsoluteSize.x, data.parentUIFrame.AbsoluteSize.y) <= 500
				and p2.small
				or p2.large

			local v4 = small[1]
			local v5 = small[2]
			local v6 = small[3]

			local v7 = -v5 - v4

			imageButton.Size = UDim2.new(0, v4, 0, v4)

			if p3 then
				imageButton.Position = UDim2.new(1, v7, 0, v6)
				return
			end

			local v8 = -v6 - v4
			imageButton.Position = UDim2.new(1, v7, 1, v8)
		end

		ResizeButton()

		local connections = {}
		table.insert(connections, data.parentUIFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeButton))

		local function UpdateButtonState()
			if imageButton.Parent == nil then
				return
			end

			if userFlag then
				local abilityUIState = v:GetAbilityUIState(p)
				local v4 = v2 or v3
				local v5 = abilityUIState == 0
				imageButton.Visible = data.enabled and parent.Enabled and (p4 or not v5)

				if imageButton.Visible then
					if abilityUIState == 1 or v5 then
						if buttonInvalidAssetId then
							imageButton.Image = buttonInvalidAssetId
							imageButton.ImageTransparency = 0
						else
							imageButton.Image = image2
							imageButton.ImageTransparency = 0.6
						end
					else
						if abilityUIState == 3 or v4 then
							imageButton.Image = image
						else
							imageButton.Image = image2
						end

						imageButton.ImageTransparency = 0
					end
				end
			else
				local abilityValid = v:GetAbilityValid(p)
				local abilityActive = v:GetAbilityActive(p)
				local v4 = v2 or v3
				imageButton.Visible = data.enabled and parent.Enabled

				if imageButton.Visible then
					if abilityActive or v4 and abilityValid then
						imageButton.Image = image
						imageButton.ImageTransparency = 0
					elseif abilityValid then
						imageButton.Image = image2
						imageButton.ImageTransparency = 0
					elseif buttonInvalidAssetId then
						imageButton.Image = buttonInvalidAssetId
						imageButton.ImageTransparency = 0
					else
						imageButton.Image = image2
						imageButton.ImageTransparency = 0.6
					end
				end
			end
		end
		UpdateButtonState()

		local function FireSelectionActivation(p5) -- 1 equivalent call inferred from this helper
			local selectionActivateBinding = parent:FindFirstChild("SelectionActivateBinding")

			if not selectionActivateBinding then
				selectionActivateBinding = Instance.new("InputBinding")
				selectionActivateBinding.Name = "SelectionActivateBinding"
				selectionActivateBinding.Type = Enum.InputBindingType.Scriptable
				selectionActivateBinding.Parent = parent
			end

			selectionActivateBinding:Fire(p5)
		end

		imageButton.MouseButton1Down:Connect(function()
			v2 = true
			UpdateButtonState()
		end)

		imageButton.MouseButton1Up:Connect(function()
			v2 = false
			UpdateButtonState()
		end)

		imageButton.MouseLeave:Connect(function()
			v2 = false
			UpdateButtonState()
		end)

		if userFlag then
			table.insert(connections, v:GetAbilityUIStateChangedSignal(p):Connect(UpdateButtonState))
		else
			table.insert(connections, v:GetAbilityActiveChangedSignal(p):Connect(UpdateButtonState))

			table.insert(connections, v:GetAbilityValidChangedSignal(p):Connect(UpdateButtonState))
		end

		table.insert(connections, data.enabledChangedEvent.Event:Connect(UpdateButtonState))
		table.insert(connections, parent:GetPropertyChangedSignal("Enabled"):Connect(UpdateButtonState))

		imageButton.Destroying:Connect(function()
			for _, connection in connections do
				connection:Disconnect()
			end

			table.clear(connections)
		end)

		local v4 = { instance = imageButton }

		function v4:Destroy()
			imageButton:Destroy()
		end

		function v4.SetSelectionPressed(_, p5)
			if v3 == p5 then
				return
			end

			v3 = p5
			FireSelectionActivation(p5) -- inferred equivalent call
			UpdateButtonState()
		end

		return v4
	end
}