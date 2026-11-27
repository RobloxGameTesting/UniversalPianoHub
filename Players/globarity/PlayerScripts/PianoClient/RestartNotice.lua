return function(data)
	local u = data.U
	local f = data.F
	local lay = data.Lay
	local glyph = data.Glyph
	local viewport = data.viewport
	local vp = data.VP
	local Players = game:GetService("Players")
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local restartNotice = Instance.new("ScreenGui")
	restartNotice.Name = "RestartNotice"
	restartNotice.IgnoreGuiInset = true
	restartNotice.ScreenInsets = Enum.ScreenInsets.None
	restartNotice.ResetOnSpawn = false
	restartNotice.DisplayOrder = 21
	restartNotice.Enabled = false
	restartNotice.Parent = playerGui

	local notice = Instance.new("Frame")
	notice.Name = "Notice"
	notice.AnchorPoint = Vector2.new(0.5, 0)
	notice.Size = UDim2.new()
	notice.AutomaticSize = Enum.AutomaticSize.XY
	notice.BorderSizePixel = 0
	notice.Parent = restartNotice
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = notice
	local uiCorner = Instance.new("UICorner", notice)
	uiCorner.CornerRadius = UDim.new(1, 0)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = notice
	local uiPadding = Instance.new("UIPadding")
	local udim = UDim.new(0, 5)
	local udim2 = UDim.new(0, 7)
	uiPadding.PaddingTop = udim
	uiPadding.PaddingBottom = udim2
	local udim3 = UDim.new(0, 14)
	local udim4 = UDim.new(0, 14)
	uiPadding.PaddingLeft = udim3
	uiPadding.PaddingRight = udim4
	uiPadding.Parent = notice

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.RichText = true
	textLabel.FontFace = glyph.nativeFont("s500_13_6")
	textLabel.TextSize = glyph.nativeSize("s500_13_6")
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.Size = UDim2.new()
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.Parent = notice
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(420, 40)
	uiSizeConstraint.Parent = textLabel

	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0, 1)
	frame.Position = UDim2.new(0, 0, 1, 5)
	frame.Size = UDim2.new(1, 0, 0, 2)
	frame.Parent = notice
	local uiCorner_2 = Instance.new("UICorner", frame)
	uiCorner_2.CornerRadius = UDim.new(1, 0)

	local v = nil
	local v2 = 300
	local function fmt(p: number)
		local v3 = math.max(0, (math.ceil(p)))
		return string.format("%d:%02d", v3 // 60, v3 % 60)
	end

	local function esc(value: string) -- 2 equivalent calls inferred from this helper
		return (string.gsub(string.gsub(string.gsub(value, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"))
	end

	local function now()
		local success, result = pcall(function()
			return workspace:GetServerTimeNow()
		end)

		if success then
			return result
		end

		return (os.time())
	end

	local function update()
		local restartAt = vp:GetAttribute("RestartAt")

		if type(restartAt) ~= "number" or f.vrOn then
			restartNotice.Enabled = false
			return
		end

		local success, result = pcall(function()
			return workspace:GetServerTimeNow()
		end)

		if not success then
			result = os.time()
		end

		local v3 = restartAt - result

		if v ~= restartAt then
			v = restartAt
			v2 = math.max(30, v3)
			uiScale.Scale = 0.01
		end

		restartNotice.Enabled = true
		local th = lay.TH
		local v4 = v3 <= 60
		local c = if v4 then th.bad.c else th.brass.c
		local v5 = vp:GetAttribute("RestartKind") == "maintenance"
		local restartMsg = vp:GetAttribute("RestartMsg")
		local v6 = (type(restartMsg) ~= "string" or restartMsg == "") and "you'll move to a new server" or restartMsg
		local v7

		if v3 > 0 then
			local v8 = math.max(0, (math.ceil(v3)))
			v7 = (v5 and "Server restart in " or "Update restart in ") .. string.format("%d:%02d", v8 // 60, v8 % 60)
		else
			v7 = "Restarting now…"
		end

		local v8 = if v4 then th.bad.c else th.ink.c
		textLabel.Text = string.format(
			"<font color=\"#%s\">%s</font><font color=\"#%s\">  ·  %s</font>",
			v8:ToHex(),
			esc(v7), -- inferred equivalent call
			th.muted.c:ToHex(),
			esc(v6) -- inferred equivalent call
		)
		notice.BackgroundColor3 = th.panel2.c
		notice.BackgroundTransparency = 0.04
		uiStroke.Color = c
		uiStroke.Transparency = v4 and 0.1 or 0.5
		frame.BackgroundColor3 = c
		frame.Size = UDim2.new(math.clamp(v3 / v2, 0, 1), 0, 0, 2)

		local _, _, v9 = viewport()
		local scale = v9 * (f.touchUI and 1.1 or 1)

		if uiScale.Scale < scale - 0.01 then
			scale = math.min(scale, uiScale.Scale + (scale - uiScale.Scale) * 0.35 + 0.02)
		end

		uiScale.Scale = scale
		local inst = u.topbar and u.topbar.inst
		local v10

		if inst then
			v10 = inst.AbsolutePosition.Y + inst.AbsoluteSize.Y - restartNotice.AbsolutePosition.Y + 6 * v9
		else
			v10 = 52 * v9
		end

		notice.Position = UDim2.new(0.5, 0, 0, (math.floor(v10)))
	end

	task.spawn(function()
		while true do
			local success, result = pcall(update)

			if not success then
				warn("RestartNotice: " .. tostring(result))
			end

			task.wait(restartNotice.Enabled and 0.05 or 0.5)
		end
	end)
end