return function(data)
	local u = data.U
	local f = data.F
	local audio = data.Audio
	local lay = data.Lay
	local glyph = data.Glyph
	local viewport = data.viewport
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local loadNotice = Instance.new("ScreenGui")
	loadNotice.Name = "LoadNotice"
	loadNotice.IgnoreGuiInset = true
	loadNotice.ScreenInsets = Enum.ScreenInsets.None
	loadNotice.ResetOnSpawn = false
	loadNotice.DisplayOrder = 20
	loadNotice.Enabled = false
	loadNotice.Parent = playerGui

	local notice = Instance.new("Frame")
	notice.Name = "Notice"
	notice.AnchorPoint = Vector2.new(1, 1)
	notice.Size = UDim2.fromOffset(270, 0)
	notice.AutomaticSize = Enum.AutomaticSize.Y
	notice.BorderSizePixel = 0
	notice.Parent = loadNotice
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = notice
	local uiCorner = Instance.new("UICorner", notice)
	uiCorner.CornerRadius = UDim.new(0, 10)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = notice
	local uiPadding = Instance.new("UIPadding")
	local udim = UDim.new(0, 9)
	local udim2 = UDim.new(0, 10)
	uiPadding.PaddingTop = udim
	uiPadding.PaddingBottom = udim2
	local udim3 = UDim.new(0, 12)
	local udim4 = UDim.new(0, 12)
	uiPadding.PaddingLeft = udim3
	uiPadding.PaddingRight = udim4
	uiPadding.Parent = notice

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(14, 14)
	frame.Position = UDim2.fromOffset(0, 2)
	frame.BackgroundTransparency = 1
	frame.Parent = notice
	local uiCorner_2 = Instance.new("UICorner", frame)
	uiCorner_2.CornerRadius = UDim.new(1, 0)
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 2
	uiStroke2.Parent = frame
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6, 0.85),
		NumberSequenceKeypoint.new(1, 1)
	})
	uiGradient.Parent = uiStroke2

	local frame2 = Instance.new("Frame")
	frame2.BackgroundTransparency = 1
	frame2.Position = UDim2.fromOffset(24, 0)
	frame2.Size = UDim2.new(1, -24, 0, 0)
	frame2.AutomaticSize = Enum.AutomaticSize.Y
	frame2.Parent = notice
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 2)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = frame2
	local function label(p: string, layoutOrder: number)
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.FontFace = glyph.nativeFont(p)
		textLabel.TextSize = glyph.nativeSize(p)
		textLabel.TextWrapped = true
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Size = UDim2.new(1, 0, 0, 0)
		textLabel.AutomaticSize = Enum.AutomaticSize.Y
		textLabel.LayoutOrder = layoutOrder
		textLabel.Parent = frame2
		return textLabel
	end

	local v = label("s600_14_08", 1)
	local v2 = label("s400_12_8", 2)

	local function paint() -- 1 equivalent call inferred from this helper
		local th = lay.TH
		notice.BackgroundColor3 = th.panel2.c
		notice.BackgroundTransparency = 0
		uiStroke.Color = th.brass.c
		uiStroke.Transparency = 0.45
		uiStroke2.Color = th.brass.c
		v.TextColor3 = th.ink.c
		v2.TextColor3 = th.muted.c
	end

	local function names(list) -- 2 equivalent calls inferred from this helper
		if #list <= 3 then
			return table.concat(list, ", ")
		end

		return list[1] .. ", " .. list[2] .. " and " .. #list - 2 .. " more"
	end

	local function keysRect()
		local guiObject = u.kb and u.kb.inst

		if not guiObject then
			return nil
		end

		while guiObject and guiObject:IsA("GuiObject") do
			if not guiObject.Visible then
				return nil
			end

			guiObject = guiObject.Parent
		end

		local minY = 1e999
		local maxValue = -1e999
		local maxValue2 = -1e999

		for _, v3 in u.kb.kids or {} do
			local inst = v3.inst

			if not (v3 ~= u.stage and inst and inst.Visible and inst.AbsoluteSize.Y > 1) then
				continue
			end

			minY = math.min(minY, inst.AbsolutePosition.Y)
			maxValue = math.max(maxValue, inst.AbsolutePosition.Y + inst.AbsoluteSize.Y)
			maxValue2 = math.max(maxValue2, inst.AbsolutePosition.X + inst.AbsoluteSize.X)
		end

		if minY == 1e999 then
			return nil
		end

		return maxValue2, minY, maxValue
	end

	local v3 = {}
	local v4 = false
	RunService.RenderStepped:Connect(function(dt)
		if v4 then
			frame.Rotation = (frame.Rotation + dt * 300) % 360
		end
	end)

	local function update()
		local pending, v5 = audio.pending()
		local now = os.clock()
		local v6 = {}

		for _, v7 in v5 do
			v3[v7] = v3[v7] or now

			if now - v3[v7] < 12 then
				table.insert(v6, v7)
			end
		end

		local enabled

		if #pending > 0 or #v6 > 0 then
			enabled = not f.vrOn
		else
			enabled = false
		end

		local v7, v8, v9

		if enabled then
			v7, v8, v9 = keysRect()

			if not v7 then
				enabled = false
			end
		end

		if enabled ~= v4 then
			v4 = enabled
			loadNotice.Enabled = enabled
		end

		if not enabled then
			return
		end

		paint() -- inferred equivalent call

		if #pending > 0 then
			v.Text = "Not all pianos are loaded yet"
			v2.Text = "Loading " .. names(pending) .. ". Until then some notes may be silent." -- inferred equivalent call
			frame.Visible = true
		else
			v.Text = "Some pianos couldn't load"
			v2.Text = names(v6) .. " didn't load. Rejoin the game to try again." -- inferred equivalent call
			frame.Visible = false
		end

		frame2.Position = UDim2.fromOffset(frame.Visible and 24 or 0, 0)
		frame2.Size = UDim2.new(1, frame.Visible and -24 or 0, 0, 0)
		local _, _, scale = viewport()
		uiScale.Scale = scale

		local v10 = v7 - loadNotice.AbsolutePosition.X
		local v11 = v8 - loadNotice.AbsolutePosition.Y
		local v12 = v9 - loadNotice.AbsolutePosition.Y

		if f.touchUI then
			notice.Position = UDim2.fromOffset(math.floor(v10 - 8 * scale), (math.floor(v11 - 8 * scale)))
		else
			notice.Position = UDim2.fromOffset(math.floor(v10 - 10 * scale), (math.floor(v12 - 10 * scale)))
		end
	end

	task.spawn(function()
		while true do
			local success, result = pcall(update)

			if not success then
				warn("LoadNotice: " .. tostring(result))
			end

			task.wait(0.3)
		end
	end)
end