return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local p = data.P
	local a = data.A
	local s = data.S
	local lay = data.Lay
	local lp = data.LP
	local glyph = data.Glyph
	local notes = data.Notes
	local pianoKeys = data.pianoKeys
	local paintKey = data.paintKey
	local press = data.press
	local release = data.release
	local pressRaw = data.pressRaw
	local releaseRaw = data.releaseRaw
	local img = data.img
	local fx = data.FX
	local viewport = data.viewport
	local gui = data.gui
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local GuiService = game:GetService("GuiService")

	if
		(not UserInputService.TouchEnabled or UserInputService.KeyboardEnabled or UserInputService.VREnabled)
		and (not RunService:IsStudio() or workspace:GetAttribute("ForceTouch") ~= true)
	then
		return
	end

	f.touchUI = true

	if RunService:IsStudio() and typeof(workspace:GetAttribute("FakeSize")) == "Vector2" then
		f.fakeSize = workspace:GetAttribute("FakeSize")
	end

	local function isPhone(): boolean
		local fakeSize = f.fakeSize or gui.AbsoluteSize

		if fakeSize.X <= 0 then
			return false
		end

		local v = math.min(fakeSize.X, fakeSize.Y)
		local success, result = pcall(function(): boolean
			return GuiService.ViewportDisplaySize == Enum.DisplaySize.Small
		end)

		if success and result and not f.fakeSize then
			return v < 600
		end

		return v < 500
	end

	local phoneNow = false
	local function applyPhone()
		phoneNow = isPhone()
		f.phoneNow = phoneNow

		if phoneNow then
			f.vpW = 900
			f.vpH = 440
		else
			f.vpW = nil
			f.vpH = nil
		end

		u.logo:show(not phoneNow)
		u.ver:show(not phoneNow)
		u.side.w = phoneNow and 280 or 320

		for _, v in { u.reviewBtn, u.lbBtn, u.setBtn, u.adminBtn } do
			if v.ico and v.label then
				v.label:show(not phoneNow)
			end
		end

		lay.dirty()
	end

	gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets

	local function fixInset()
		local success, result = pcall(function()
			return GuiService.TopbarInset
		end)

		if not (success and result) then
			return
		end

		local _, _, v = viewport()
		local x = gui.AbsolutePosition.X
		local x2 = gui.AbsoluteSize.X
		local v2 = math.max(0, (result.Min.X - x) / v)
		local v3 = not (result.Max.X > 0 and result.Max.X < x + x2) and 0 or (x + x2 - result.Max.X) / v
		u.topbar.m = {
			0,
			math.max(0, v3 - 12),
			0,
			v2
		}
		lay.dirty()
	end
	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
		task.defer(fixInset)
	end)
	gui:GetPropertyChangedSignal("AbsolutePosition"):Connect(fixInset)
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		applyPhone()
		fixInset()
	end)
	applyPhone()
	fixInset()

	if phoneNow then
		f.setCollapsed(true)
	end

	local v = {}
	local v2 = {}

	for i = 21, 108 do
		if not notes.isBlack(i) then
			table.insert(v, i)
		end

		v2[i] = #v
	end

	local count = #v
	local v3 = {
		8,
		10,
		12,
		15,
		19,
		24,
		29,
		36,
		52
	}

	local v4 = { n = 15, a = v2[60], b = v2[36], two = false }
	local function clampStart(p2: number) -- 7 equivalent calls inferred from this helper
		return (math.clamp(math.floor(p2 + 0.5), 1, count - v4.n + 1))
	end

	local function range(a2: number) -- 2 equivalent calls inferred from this helper
		return v[a2], v[a2 + v4.n - 1]
	end

	local function two() -- 9 equivalent calls inferred from this helper
		return v4.two and p.view ~= "qwerty"
	end

	local kbRange = f.kbRange
	function f.kbRange()
		if p.view == "qwerty" then
			return kbRange()
		end

		return range(v4.a)
	end

	local count2 = 0
	local function save() -- 4 equivalent calls inferred from this helper
		count2 += 1
		local v5 = count2
		task.delay(1, function()
			if v5 == count2 then
				f.savePref("mob", { n = v4.n, a = v4.a, b = v4.b, two = v4.two })
			end
		end)
	end

	local function label(textButton, p2: string)
		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromOffset(0, 0)
		frame.ZIndex = 4
		frame.Parent = textButton
		local v5 = { holder = frame, pool = {} }
		function v5.draw(p3: string, p4: number, p5: number, color: Color3)
			local width = glyph.width(p2, p3)

			for i = glyph.draw(frame, v5.pool, 0, p2, p3, 0, p4 - width / 2, p5, color, 0, 4) + 1, #v5.pool do
				v5.pool[i].Visible = false
			end
		end
		return v5
	end

	local function btnPress(input): boolean -- 2 equivalent calls inferred from this helper
		return input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1
	end

	local v5 = b({
		name = "piano2",
		bds = { 3, 0, 0, 0 },
		bdc = "pianoTop",
		bdz = 6,
		hidden = true,
		parent = u.kb
	})
	v5.inst.Visible = false
	local keys = Instance.new("Frame")
	keys.Name = "keys"
	keys.BackgroundTransparency = 1
	keys.ClipsDescendants = true
	keys.Position = UDim2.fromOffset(0, 3)
	keys.Parent = v5.inst
	local v6 = {}

	for i = 21, 108 do
		local black = notes.isBlack(i)
		local textButton = Instance.new("TextButton")
		textButton.Name = tostring(i)
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.BorderSizePixel = 0
		textButton.ZIndex = black and 3 or 1
		textButton.Visible = false
		local uiCorner = Instance.new("UICorner", textButton)
		uiCorner.CornerRadius = UDim.new(0, black and 4 or 5)
		local v7 = { f = textButton, black = black, m = i }

		if black then
			local sh = img("keysh", {
				ZIndex = 2,
				ScaleType = Enum.ScaleType.Slice,
				Visible = false,
				SliceCenter = Rect.new(fx.keysh.slice[1], fx.keysh.slice[2], fx.keysh.slice[3], fx.keysh.slice[4]),
				ImageColor3 = Color3.new(0, 0, 0),
				ImageTransparency = 0.6
			})
			sh.Parent = keys
			v7.sh = sh
		else
			local uiStroke = Instance.new("UIStroke")
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
			uiStroke.Thickness = 1
			uiStroke.Parent = textButton
			v7.edge = uiStroke
			v7.nn = label(textButton, "m500_8_32")
		end

		v7.lb = label(textButton, black and "m600_9_92" or "m600_12_48")

		if i == 60 then
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromOffset(5, 5)
			frame.ZIndex = 2
			local uiCorner_2 = Instance.new("UICorner", frame)
			uiCorner_2.CornerRadius = UDim.new(1, 0)
			frame.Parent = textButton
			v7.dot = frame
		end

		textButton.Parent = keys
		v6[i] = v7

		local v8 = {}
		textButton.InputBegan:Connect(function(input)
			if not btnPress(input) or u.dialog then -- inferred equivalent call
				return
			end

			local v9 = notes.ORDER[i - a.transpose - 35]

			if v9 then
				v8[input] = v9
				press(v9, "user")
			else
				v8[input] = true
				pressRaw(i)
			end
		end)
		local function finish(p2)
			local v9 = v8[p2]

			if v9 then
				v8[p2] = nil

				if v9 == true then
					releaseRaw(i)
				else
					release(v9)
				end
			end
		end
		textButton.InputEnded:Connect(finish)
		UserInputService.InputEnded:Connect(finish)
	end

	local function layout2()
		if not two() then -- inferred equivalent call
			return
		end

		local pw = v5._pw or 0
		local v7 = (v5._ph or 0) - 3

		if pw <= 0 then
			return
		end

		keys.Size = UDim2.fromOffset(pw, v7)
		local v8, v9 = range(v4.b) -- inferred equivalent call
		local n = v4.n
		local v10 = (pw + n - 1) / n
		local v11 = pw / n * 0.62

		local th = lay.TH
		local count3 = 0

		for i = 21, 108 do
			local v12 = v6[i]
			local f2 = v12.f
			local visible

			if v8 <= i then
				visible = i <= v9
			else
				visible = false
			end

			f2.Visible = visible

			if v12.sh then
				v12.sh.Visible = visible
			end

			if not visible then
				continue
			end

			local v13 = notes.ORDER[i - a.transpose - 35] or f.ctrlLabel(i - a.transpose) or ""

			if v12.black then
				local v14 = count3 / n * pw - v11 / 2
				local v15 = math.floor(v14 + 0.5)
				local v16 = math.floor(v14 + v11 + 0.5)
				local v17 = math.floor(v7 * 0.6 + 0.5)
				f2.Size = UDim2.fromOffset(v16 - v15, v17 + 4)
				f2.Position = UDim2.fromOffset(v15, -4)
				v12.lb.draw(
					v13,
					(v16 - v15) / 2,
					v17 + 4 - 5 - glyph.style("m600_9_92").lh + glyph.baseline("m600_9_92"),
					th.bkInk.c
				)
				local margin = fx.keysh.margin
				v12.sh.Position = UDim2.fromOffset(v15 - margin, -4 - margin + 2)
				v12.sh.Size = UDim2.fromOffset(v16 - v15 + 2 * margin, v17 + 4 + 2 * margin)

				local pianoKey = pianoKeys[i]

				if not pianoKey.f.Visible and pianoKey.hh ~= v17 + 4 then
					pianoKey.hh = v17 + 4
					paintKey(pianoKey)
				end
			else
				local v14 = count3 * (v10 - 1)
				local v15 = math.floor(v14 + 0.5)
				local v16 = math.floor(v14 + v10 + 0.5)
				local v17 = v7 + 5
				f2.Size = UDim2.fromOffset(v16 - v15, v17)
				f2.Position = UDim2.fromOffset(v15, pianoKeys[i].f.Position.Y.Offset)
				count3 += 1
				local v18 = v17 - 1 - 6

				if p.names then
					v18 -= glyph.style("m500_8_32").lh + 1
				end

				v12.lb.draw(
					v13,
					(v16 - v15) / 2,
					v18 - glyph.style("m600_12_48").lh + glyph.baseline("m600_12_48"),
					th.wkInk.c
				)
				v12.nn.holder.Visible = p.names

				if p.names then
					v12.nn.draw(
						notes.noteName(i),
						(v16 - v15) / 2,
						v17 - 1 - 6 - glyph.style("m500_8_32").lh + glyph.baseline("m500_8_32"),
						th.wkSub.c
					)
				end

				v12.edge.Color = th.wkEdge.c

				if v12.dot then
					v12.dot.Position = UDim2.fromOffset(math.floor((v16 - v15) / 2 - 2.5 + 0.5), v17 - 1 - 36 - 5)
					v12.dot.BackgroundColor3 = th.midDot.c
				end
			end

			v12.lastBg = nil
			v12.lastY = nil
		end
	end
	function v5.afterApply()
		layout2()
	end

	RunService.RenderStepped:Connect(function()
		if not two() then -- inferred equivalent call
			return
		end

		local b2 = v4.b

		for i = v[b2], v[b2 + v4.n - 1] do
			local pianoKey = pianoKeys[i]
			local v7 = v6[i]
			local f2 = pianoKey.f
			local grad = pianoKey.grad
			local backgroundColor3 = f2.BackgroundColor3

			if v7.lastBg ~= backgroundColor3 then
				v7.lastBg = backgroundColor3
				v7.f.BackgroundColor3 = backgroundColor3
			end

			if grad and grad.Enabled then
				local v8 = v7.g

				if not v8 then
					v8 = Instance.new("UIGradient")
					v8.Rotation = 90
					v8.Parent = v7.f
					v7.g = v8
				end

				local color = grad.Color

				if v7.lastCs ~= color then
					v7.lastCs = color
					v8.Color = color
				end

				v8.Enabled = true
			elseif v7.g and v7.g.Enabled then
				v7.g.Enabled = false
				v7.lastCs = nil
			end

			if v7.black then
				continue
			end

			local offset = f2.Position.Y.Offset

			if v7.lastY == offset then
				continue
			end

			v7.lastY = offset
			v7.f.Position = UDim2.fromOffset(v7.f.Position.X.Offset, offset)
		end
	end)

	local function iconButton(p2: string, rotation: number?, p3: string?)
		local parent = b({
			dir = "row",
			align = "center",
			justify = "center",
			gap = 4,
			h = 32,
			minW = 40,
			pad = { 0, 8 },
			bd = 1,
			bdc = "glassLine",
			bg = "white05",
			r = 7,
			button = true,
			noShrink = true,
			sty = {
				on = { bg = "brassSoft", bdc = "brass55" }
			}
		})

		if f.hasIcons() then
			local ico = f.ico(p2, 15, "ink")

			if rotation then
				ico.im.Rotation = rotation
			end

			parent:add(ico)
		elseif not p3 then
			t({
				t = rotation == -90 and "‹" or rotation == 90 and "›" or p2,
				f = "s600_14_08",
				parent = parent
			})
		end

		if p3 then
			t({ t = p3, f = "m600_13_12", parent = parent })
		end

		return parent
	end

	local v7 = {}
	local fn
	local function shift(p2: string, p3: number) -- 2 equivalent calls inferred from this helper
		v4[p2] = clampStart(v4[p2] + p3) -- inferred equivalent call
		fn()
		save() -- inferred equivalent call
	end
	local function makeBar(p2: string)
		local bar = b({
			name = "nav_" .. p2,
			dir = "row",
			align = "center",
			gap = 6,
			h = 40,
			pad = { 0, 8 },
			bg = "panel",
			parent = u.kb
		})
		local v8 = iconButton("chevron-up", -90)
		bar:add(v8)
		local map = b({
			grow = 1,
			shrink0 = true,
			h = 28,
			r = 5,
			clip = true,
			bg = "bk",
			button = true,
			parent = bar
		})
		local v9 = iconButton("chevron-up", 90)
		bar:add(v9)
		v8:onClick(function()
			shift(p2, -7) -- inferred equivalent call
		end)
		v9:onClick(function()
			shift(p2, 7) -- inferred equivalent call
		end)

		local v10 = {}
		local v11 = {}

		for i = 1, count do
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			frame.ZIndex = 1
			frame.Parent = map.inst
			v10[i] = frame
		end

		for i = 21, 108 do
			if not notes.isBlack(i) then
				continue
			end

			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			frame.ZIndex = 2
			frame.Parent = map.inst
			v11[i] = frame
		end

		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.ZIndex = 3
		frame.BackgroundTransparency = 0.72
		local uiCorner = Instance.new("UICorner", frame)
		uiCorner.CornerRadius = UDim.new(0, 4)
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 2
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = frame
		frame.Parent = map.inst

		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.ZIndex = 4
		frame2.Size = UDim2.fromOffset(3, 3)
		local uiCorner_2 = Instance.new("UICorner", frame2)
		uiCorner_2.CornerRadius = UDim.new(1, 0)
		frame2.Parent = map.inst
		function map:afterApply()
			local pw = self._pw or 0
			local ph = self._ph or 0

			if pw <= 0 then
				return
			end

			local th = lay.TH
			local v12 = pw / count

			for k, v13 in v10 do
				local v14 = math.floor((k - 1) * v12 + 0.5)
				local v15 = math.floor(k * v12 + 0.5)
				v13.Position = UDim2.fromOffset(v14, 0)
				v13.Size = UDim2.fromOffset(math.max(1, v15 - v14 - 1), ph)
				v13.BackgroundColor3 = th.wk.c
			end

			for k, v13 in v11 do
				local v14 = v2[k] * v12 - v12 * 0.3
				v13.Position = UDim2.fromOffset(math.floor(v14 + 0.5), 0)
				v13.Size = UDim2.fromOffset(math.max(1, (math.floor(v12 * 0.6 + 0.5))), (math.floor(ph * 0.6 + 0.5)))
				v13.BackgroundColor3 = th.bk.c
			end

			local v13 = v4[p2]
			frame.Position = UDim2.fromOffset(math.floor((v13 - 1) * v12 + 0.5), 0)
			frame.Size = UDim2.fromOffset(math.floor(v4.n * v12 + 0.5) - 1, ph)

			local c = th.brass.c
			local _, v14, v15 = c:ToHSV()

			if v14 < 0.25 and v15 > 0.7 then
				c = th.hlBk.c
			end

			frame.BackgroundColor3 = c
			uiStroke.Color = c
			frame2.Position = UDim2.fromOffset(math.floor((v2[60] - 0.5) * v12 - 1.5 + 0.5), ph - 6)
			frame2.BackgroundColor3 = th.midDot.c
		end

		local v12 = nil
		local function moveTo(x: number) -- 2 equivalent calls inferred from this helper
			local x2 = map.inst.AbsolutePosition.X
			local v13 = math.max(1, map.inst.AbsoluteSize.X)
			local v14 = clampStart((x - x2) / v13 * count - v4.n / 2 + 1) -- inferred equivalent call

			if v14 ~= v4[p2] then
				v4[p2] = v14
				fn()
			end
		end
		map.inst.InputBegan:Connect(function(input)
			if not btnPress(input) then -- inferred equivalent call
				return
			end

			v12 = input
			moveTo(input.Position.X) -- inferred equivalent call
		end)
		UserInputService.InputChanged:Connect(function(input)
			if
				not v12
				or input ~= v12
				and (v12.UserInputType ~= Enum.UserInputType.MouseButton1 or input.UserInputType ~= Enum.UserInputType.MouseMovement)
			then
				return
			end

			moveTo(input.Position.X) -- inferred equivalent call
		end)
		UserInputService.InputEnded:Connect(function(input)
			if v12 and (input == v12 or input.UserInputType == Enum.UserInputType.MouseButton1) then
				v12 = nil
				save() -- inferred equivalent call
			end
		end)
		v7[p2] = { bar = bar, map = map }
		return bar
	end

	local bar = makeBar("a")
	local bar2 = makeBar("b")
	u.navA = bar

	local v8 = iconButton("minus")
	bar:add(v8)
	local v9 = iconButton("plus")
	bar:add(v9)
	local v10 = iconButton("piano", nil, "2")
	bar:add(v10)
	local function zoom(p2: number)
		local index = table.find(v3, v4.n) or 4
		local v11 = math.clamp(index + p2, 1, #v3)

		if v11 == index then
			return
		end

		local v12 = v4.a + v4.n / 2
		local v13 = v4.b + v4.n / 2
		v4.n = v3[v11]
		v4.a = clampStart(v12 - v4.n / 2) -- inferred equivalent call
		v4.b = clampStart(v13 - v4.n / 2) -- inferred equivalent call
		fn()
		save() -- inferred equivalent call
	end
	v8:onClick(function()
		zoom(1)
	end)
	v9:onClick(function()
		zoom(-1)
	end)
	v10:onClick(function()
		v4.two = not v4.two
		fn()
		save() -- inferred equivalent call
		f.toast(v4.two and "Two pianos: each one moves on its own." or "One piano.")
	end)

	local kids = u.kb.kids

	for _, v11 in { bar, bar2, v5 } do
		local index = table.find(kids, v11)

		if index then
			table.remove(kids, index)
		end
	end

	table.insert(kids, table.find(kids, u.piano) or 2, bar)
	table.insert(kids, bar2)
	table.insert(kids, v5)

	local function pianoH()
		local v11 = select(2, viewport())
		local v12

		if two() then -- inferred equivalent call
			v12 = math.clamp(0.24 * v11, 88, 150)
		else
			v12 = math.clamp(0.33 * v11, 120, 220)
		end

		if not (phoneNow and u.main.lh_) then
			return v12
		end

		local maxValue = 70

		if not u.hud.hidden and u.hud.lh_ then
			maxValue = math.max(maxValue, (u.hud.abs and u.hud.abs.t or 62) + u.hud.lh_ + 6)
		end

		local v13 = two() and 2 or 1 -- inferred equivalent call
		return (math.floor((math.clamp((u.main.lh_ - 2 - v13 * 40 - maxValue) / v13, 80, v12))))
	end

	u.piano.hf = pianoH
	v5.hf = pianoH

	local paintSheet = f.paintSheet
	function f.paintSheet()
		paintSheet()

		if phoneNow then
			u.sheet.h = math.min(u.sheet.h or 0, 64.24000000000001)
		end
	end
	local flag = false
	RunService.Heartbeat:Connect(function()
		if phoneNow then
			flag = true

			if not u.hrow2.hidden then
				u.hrow2:show(false)
			end

			local v11 = two() -- inferred equivalent call
			local v12 = not (v11 or p.hudMin)

			if (u.sheet.hidden == true) == v12 then
				u.sheet:show(v12)
				u.bar:show(v12)
			end

			if (u.minBtn.hidden == true) ~= v11 then
				u.minBtn:show(not v11)
			end
		elseif flag then
			flag = false
			u.hrow2:show(not p.hudMin)
			u.sheet:show(not p.hudMin)
			u.bar:show(not p.hudMin)
			u.minBtn:show(true)
		end

		if phoneNow and u.piano.lh_ and math.abs(u.piano.lh_ - u.piano.hf()) > 1 then
			lay.dirty()
		end
	end)

	fn = function()
		bar:show(p.view ~= "qwerty")
		bar2:show(two()) -- inferred equivalent call
		v5:show(two()) -- inferred equivalent call
		v10:state("on", v4.two)
		local index = table.find(v3, v4.n) or 4
		v8.op = #v3 <= index and 0.4 or 1
		v9.op = index <= 1 and 0.4 or 1
		v8:repaintAll()
		v9:repaintAll()
		f.layoutPiano()
		lay.dirty()
	end
	local layoutPiano = f.layoutPiano
	function f.layoutPiano()
		layoutPiano()
		layout2()

		for _, v11 in v7 do
			if v11.map.afterApply then
				v11.map.afterApply(v11.map)
			end
		end
	end
	local setView = f.setView
	function f.setView(p2: string, flag2: boolean?)
		setView(p2, flag2)
		fn()
	end
	function f.mobPrefs(data2)
		if type(data2) ~= "table" then
			return
		end

		if table.find(v3, data2.n) then
			v4.n = data2.n
		end

		if type(data2.a) == "number" then
			v4.a = clampStart(data2.a) -- inferred equivalent call
		end

		if type(data2.b) == "number" then
			v4.b = clampStart(data2.b) -- inferred equivalent call
		end

		v4.two = data2.two == true
		fn()
	end

	local v11 = ""
	RunService.Heartbeat:Connect(function()
		if s.mode == "free" or p.view == "qwerty" then
			v11 = ""
			return
		end

		local v12 = 1e999
		local v13 = -1e999

		for k, pianoKey in pianoKeys do
			if not pianoKey.target or pianoKey.got then
				continue
			end

			if k < v12 then
				v12 = k
			end

			if v13 < k then
				v13 = k
			end
		end

		if v12 == 1e999 then
			return
		end

		local v14 = v12 .. ":" .. v13 .. ":" .. tostring(s.idx)

		if v14 == v11 then
			return
		end

		v11 = v14
		local function sees(p2: number): boolean -- 2 equivalent calls inferred from this helper
			local v15, v16 = range(p2) -- inferred equivalent call
			return v15 <= v12 and v13 <= v16
		end

		if sees(v4.a) or two() and sees(v4.b) then -- inferred equivalent call
			return
		end

		local v15 = v2[v12]
		local v16 = v2[v13]
		local v17 = "a"

		if two() then -- inferred equivalent call
			local midpoint = (v15 + v16) / 2
			v17 = math.abs(v4.b + v4.n / 2 - midpoint) < math.abs(v4.a + v4.n / 2 - midpoint) and "b" or v17
		end

		if not (v16 - v15 + 1 >= v4.n) then
			v15 = (v15 + v16) / 2 - v4.n / 2 + 1
		end

		v4[v17] = clampStart(v15) -- inferred equivalent call
		fn()
	end)

	local v12 = t({
		t = "",
		f = "m500_10_56",
		c = { c = Color3.new(1, 1, 1), a = 1 },
		align = "c"
	})
	local v13 = b({
		h = 16,
		minW = 16,
		pad = { 0, 4 },
		r = "pill",
		bg = { c = Color3.fromHex("e5484d"), a = 1 },
		dir = "row",
		align = "center",
		justify = "center",
		abs = { t = -6, r = -6 },
		z = 8,
		hidden = true,
		parent = u.sideBtn,
		{ v12 }
	})
	v13.inst.Visible = false
	local v14 = 0
	local function set(p2: number) -- 1 equivalent call inferred from this helper
		if p2 == v14 then
			return
		end

		v14 = p2
		v12:setText(p2 > 99 and "99+" or tostring(p2))
		v13:show(p2 > 0)
		lay.dirty()
	end
	local chatNew = f.chatNew
	function f.chatNew(p2: number)
		chatNew(p2)

		if p2 ~= lp.UserId and p.collapsed then
			set(v14 + 1) -- inferred equivalent call
		end
	end
	task.spawn(function()
		while true do
			task.wait(0.25)

			if not (v14 > 0) or p.collapsed or v14 == 0 then
				continue
			end

			v14 = 0
			v12:setText((tostring(0)))
			v13:show(false)
			lay.dirty()
		end
	end)

	local showTab = f.showTab
	function f.showTab(p2: string)
		showTab(p2)

		if p.collapsed and not p.fullscreen then
			f.setCollapsed(false)
		end
	end

	fn()
end