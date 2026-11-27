return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local p = data.P
	local lay = data.Lay
	local glyph = data.Glyph
	local notes = data.Notes
	local note = data.NOTE
	local glyphLabel = data.glyphLabel
	local _paintKey = data.paintKey
	local keys = data.keys
	local press = data.press
	local release = data.release
	local UserInputService = game:GetService("UserInputService")
	local color = Color3.fromHex("111111")

	local v = 0
	local v2 = false
	local v3 = false
	local v4 = false

	local function shiftOn() -- 2 equivalent calls inferred from this helper
		return v > 0 or (v2 or v3 or v4)
	end

	local function isPress(input): boolean -- 3 equivalent calls inferred from this helper
		return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
	end

	local function keyFrame(name: string, flag: boolean)
		local instance = Instance.new(flag and "TextButton" or "Frame")
		instance.Name = name
		instance.BorderSizePixel = 0

		if flag then
			instance.Text = ""
			instance.AutoButtonColor = false
		end

		local uiCorner = Instance.new("UICorner", instance)
		uiCorner.CornerRadius = UDim.new(0, 9)
		instance.Parent = u.qwerty.inst
		local face = Instance.new("Frame")
		face.Name = "face"
		face.BorderSizePixel = 0
		face.ZIndex = 2
		face.Active = false
		local uiCorner_2 = Instance.new("UICorner", face)
		uiCorner_2.CornerRadius = UDim.new(0, 8)
		face.Parent = instance
		return instance, face
	end

	local v5 = false
	local v6 = {}
	local v7 = false
	local fn
	local v8 = {}

	for k, v9 in {
		{
			{ "~`" },
			"1234567890",
			{ "_-" },
			{ "+=" },
			{ "delete", 2 }
		},
		{
			{ "tab", 1.5 },
			"qwertyuiop",
			{ "{[" },
			{ "}]" },
			{ "|\\", 1.5 }
		},
		{
			{ "caps lock", 1.75 },
			"asdfghjkl",
			{ ":;" },
			{ "\"'" },
			{ "enter", 2.25 }
		},
		{
			{ "shift", 2.25 },
			"zxcvbnm",
			{ "<," },
			{ ">." },
			{ "?/" },
			{ "shift", 2.75 }
		}
	} do
		local total = 0

		for _, v10 in v9 do
			if type(v10) == "string" then
				for i = 1, #v10 do
					local name = string.sub(v10, i, i)
					local v11 = notes.DIGSHIFT[name] or string.upper(name)
					local v12, v13 = keyFrame(name, true)

					local frame = Instance.new("Frame")
					frame.BorderSizePixel = 0
					frame.ZIndex = 3
					frame.Visible = false
					local uiCorner = Instance.new("UICorner", frame)
					uiCorner.CornerRadius = UDim.new(0, 8)
					frame.Parent = v13
					local cell = {
						f = v12,
						face = v13,
						band = frame,
						r = k,
						u = total,
						n = 1
					}

					for k2, ch in { v11, name } do
						local v14 = k2 == 1
						local v15 = {
							f = v12,
							kind = v14 and "qup" or "qlo",
							cell = cell,
							down = false,
							rdown = 0,
							target = false,
							got = false
						}
						v15.lb = glyphLabel(v13, v14 and "m600_13_12" or "m600_21_6")

						if not v14 then
							v15.nn = glyphLabel(v13, "m500_9_92")
						end

						v15.ch = ch
						v15.has = note[ch] ~= nil

						if v15.has then
							keys[ch] = v15
						end

						if v14 then
							cell.up = v15
						else
							cell.lo = v15
						end
					end

					local v14 = {}
					v12.InputBegan:Connect(function(input)
						if not isPress(input) or u.dialog then -- inferred equivalent call
							return
						end

						local v15

						if shiftOn() and cell.up.has then -- inferred equivalent call
							v15 = cell.up.ch
						else
							v15 = name
						end

						v14[input] = v15
						press(v15, "user")

						if v > 0 then
							v7 = true
						end

						if v2 then
							v2 = false
							fn()
						end
					end)
					local function finish(p2)
						local v15 = v14[p2]

						if v15 then
							v14[p2] = nil
							release(v15)
						end
					end
					v12.InputEnded:Connect(finish)
					UserInputService.InputEnded:Connect(finish)
					table.insert(v8, cell)
					total += 1
				end
			else
				local v11 = v10[2] or 1
				local text = v10[1]
				local mod = text == "shift" or text == "caps lock"
				local toggle = text == "enter"
				local v12, face = keyFrame(text, mod or toggle)
				local word = #text > 2
				local v13 = {
					f = v12,
					face = face,
					r = k,
					u = total,
					n = v11,
					text = text,
					word = word,
					mod = mod,
					toggle = toggle
				}

				if toggle then
					v12.InputBegan:Connect(function(input)
						if not isPress(input) or not f.touchUI or u.dialog then -- inferred equivalent call
							return
						end

						f.setStickyShift(not v5)
						f.toast(v5 and "Shift: tap it once, and the next note plays its Shift symbol" or "Shift: hold it while you tap a key, like a real keyboard")
					end)
				end

				if word then
					v13.lb = glyphLabel(face, "s400_13_44")
				else
					v13.top = glyphLabel(face, "m600_13_12")
					v13.bot = glyphLabel(face, "m600_13_12")
				end

				if mod then
					table.insert(v6, v13)
					local v14 = {}
					v12.InputBegan:Connect(function(input)
						if not isPress(input) then -- inferred equivalent call
							return
						end

						if text == "caps lock" then
							v3 = not v3
							v2 = false
						else
							v14[input] = true
							v += 1
							v7 = false
						end

						fn()
					end)
					local function finish(p2)
						if not v14[p2] then
							return
						end

						v14[p2] = nil
						v = math.max(0, v - 1)

						if v5 and not v7 then
							v2 = not v2
						end

						fn()
					end
					v12.InputEnded:Connect(finish)
					UserInputService.InputEnded:Connect(finish)
				end

				table.insert(v8, v13)
				total += v11
			end
		end
	end

	function f.setStickyShift(flag: boolean, flag2: boolean?)
		v5 = flag
		v2 = false

		if not flag2 then
			f.savePref("sshift", flag)
		end

		if f.layoutQwerty then
			f.layoutQwerty()
		end

		fn()
	end

	local function realShiftChanged() -- 2 equivalent calls inferred from this helper
		local v9 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

		if v9 ~= v4 then
			v4 = v9
			fn()
		end
	end
	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			realShiftChanged() -- inferred equivalent call
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			realShiftChanged() -- inferred equivalent call
		end
	end)

	local function lit(data2, th)
		if not data2.has then
			return nil
		end

		if data2.down then
			return th.brass.c
		end

		if data2.rdown > 0 and data2.rcol then
			return data2.rcol
		end

		if data2.flash == "bad" then
			return th.badk.c
		end

		if data2.flash == "ok" or data2.got then
			return th.okk.c
		end

		return if data2.target then th.hl.c else nil
	end

	function f.paintQKey(p2)
		local cell = p2.cell

		if not cell then
			return
		end

		local th = lay.TH
		local v9 = lit(cell.lo, th)
		local backgroundColor = lit(cell.up, th)
		local v10 = v9 or backgroundColor
		cell.face.BackgroundColor3 = v10 or th.cap.c
		local band = cell.band
		band.Visible = v9 ~= nil and backgroundColor ~= nil

		if backgroundColor then
			cell.band.BackgroundColor3 = backgroundColor
		end

		local v11, v12, v13, v14

		if v10 then
			v11 = color
			v12 = color
			v13 = backgroundColor and 0 or 0.55
			v14 = if v9 then 0 else 0.55
		else
			local v15 = shiftOn() -- inferred equivalent call
			v11 = if v15 then th.ink.c else th.muted.c
			v12 = if v15 then th.muted.c else th.ink.c
			v13 = 0
			v14 = 0
		end

		cell.up.lb.recolor(v11, v13)
		cell.lo.lb.recolor(v12, v14)

		if cell.lo.nn then
			local recolor = cell.lo.nn.recolor
			local v15 = if v10 then color else th.muted.c
			recolor(v15, v14)
		end
	end
	local function paintMod(data2)
		local th = lay.TH
		local v9

		if data2.text == "caps lock" then
			v9 = v3
		else
			v9 = v > 0 or (v2 or v4)
		end

		local face = data2.face
		local c

		if v9 then
			c = th.brass.c
		else
			c = if th.light then th.line.c else th.panel.c
		end

		face.BackgroundColor3 = c
		local recolor = data2.lb.recolor
		local v10 = if v9 then color else th.muted.c
		recolor(v10, 0)
	end
	fn = function()
		for _, v9 in v8 do
			if v9.lo then
				f.paintQKey(v9.lo)
			elseif v9.mod then
				paintMod(v9)
			end
		end
	end

	local hf = u.qwerty.hf
	function u.qwerty.hf()
		if p.kbFull and u.main.lh_ then
			return (math.floor(u.main.lh_ * 0.7))
		end

		return hf()
	end

	local v9 = nil
	local v10 = nil
	local function makeButtons()
		if v9 then
			return
		end

		v9 = b({
			dir = "row",
			align = "center",
			justify = "center",
			w = 28,
			h = 28,
			bd = 1,
			bdc = "glassLine",
			bg = "white05",
			r = 6,
			button = true
		})

		if f.hasIcons and f.hasIcons() then
			v9:add(f.ico("keyboard", 15, "ink"))
		else
			v9:add(t({ t = "KB", f = "m600_13_6" }))
		end

		u.pillR:add(v9)
		local kids = u.pillR.kids
		table.remove(kids, (table.find(kids, v9)))
		table.insert(kids, table.find(kids, u.fsBtn) or #kids + 1, v9)
		v9:onClick(function()
			f.setKbFull(true)
		end)
		v10 = b({
			dir = "row",
			align = "center",
			gap = 6,
			h = 30,
			pad = { 0, 12 },
			bd = 1,
			bdc = "glassLine",
			bg = "glass",
			r = 8,
			button = true,
			z = 7,
			abs = { t = 8, l = 8 },
			hidden = true,
			parent = u.main
		})
		v10.inst.Visible = false

		if f.hasIcons and f.hasIcons() then
			v10:add(f.ico("minimize", 14, "ink"))
		end

		v10:add(t({ t = "Exit", f = "s500_12_48", lh = 18 }))
		v10:onClick(function()
			f.setKbFull(false)
		end)

		local RunService = game:GetService("RunService")
		RunService.RenderStepped:Connect(function()
			if not p.kbFull then
				return
			end

			local GuiService = game:GetService("GuiService")
			local success, result = pcall(function()
				return GuiService.TopbarInset
			end)
			local inst = u.main.inst
			local v11 = math.max(u.layerScale.Scale, 0.01)
			local v12, v13

			if success and result and result.Height > 0 then
				local guiInset = GuiService:GetGuiInset()
				v12 = math.max(8, (result.Min.X - guiInset.X - inst.AbsolutePosition.X) / v11 + 8)
				v13 = math.max(4, (result.Min.Y - guiInset.Y + result.Height / 2 - inst.AbsolutePosition.Y) / v11 - 15)
			else
				v12 = 8
				v13 = 8
			end

			local abs = v10.abs

			if math.abs((abs.l or 0) - v12) > 0.5 or math.abs((abs.t or 0) - v13) > 0.5 then
				v10.abs = { l = v12, t = v13 }
				lay.dirty()
			end
		end)
	end
	function f.setKbFull(flag: boolean)
		local kbFull = flag and p.view == "qwerty"

		if (p.kbFull == true) == kbFull then
			return
		end

		p.kbFull = kbFull

		if kbFull then
			p.kbWasFs = p.fullscreen == true

			if not p.fullscreen and f.toggleFullscreen then
				f.toggleFullscreen()
			end
		elseif p.fullscreen and not p.kbWasFs and f.toggleFullscreen then
			f.toggleFullscreen()
		end

		u.pillL:show(not kbFull)
		u.pillR:show(not kbFull)

		if v10 then
			v10:show(kbFull)
		end

		lay.dirty()
	end

	local function baseFor(p2: string, p3: number, p4: number) -- 7 equivalent calls inferred from this helper
		return p3 + p4 / 2 - glyph.style(p2).lh / 2 + glyph.baseline(p2)
	end

	function f.layoutQwerty()
		local qwerty = u.qwerty
		makeButtons()

		if (v9.hidden == true) == (p.view == "qwerty") then
			v9:show(p.view == "qwerty")
			lay.dirty()
		end

		if p.kbFull and p.view ~= "qwerty" then
			f.setKbFull(false)
		end

		local pw = qwerty._pw or 0
		local ph = qwerty._ph or 0

		if pw <= 0 or not qwerty.inst.Visible then
			return
		end

		f.layoutPiano()
		local th = lay.TH
		local v11 = ph > 260 and 8 or 6
		local v12 = (pw - 24 - v11 * 14) / 15
		local v13 = (ph - 3 - 10 - 12 - v11 * 3) / 4

		local c = if th.light then th.line.c else th.panel.c
		local backgroundColor

		if th.light then
			backgroundColor = c:Lerp(Color3.new(0, 0, 0), 0.18)
		else
			backgroundColor = th.bg.c
		end

		for _, v14 in v8 do
			local v15 = 12 + v14.u * (v12 + v11)
			local v16 = 13 + (v14.r - 1) * (v13 + v11)
			local v17 = math.floor(v15 + 0.5)
			local v18 = math.floor(v15 + v14.n * v12 + (v14.n - 1) * v11 + 0.5)
			local v19 = math.floor(v16 + 0.5)
			local v20 = math.floor(v16 + v13 + 0.5)
			local f2 = v14.f
			f2.Position = UDim2.fromOffset(v17, v19)
			f2.Size = UDim2.fromOffset(v18 - v17, v20 - v19)

			local v21 = v18 - v17 - 2
			local v22 = v20 - v19 - 5
			local face = v14.face
			face.Position = UDim2.fromOffset(1, 1)
			face.Size = UDim2.fromOffset(v21, v22)
			local v23 = math.floor(v22 * 0.42 + 0.5)

			if v14.lo then
				f2.BackgroundColor3 = th.capEdge.c
				v14.band.Position = UDim2.fromOffset(0, 0)
				v14.band.Size = UDim2.fromOffset(v21, (math.max(4, (math.floor(v22 * 0.12)))))
				v14.up.lb.draw(
					not v14.up.has and "" or v14.up.ch,
					v21 / 2,
					baseFor("m600_13_12", v23 / 2, 6), -- inferred equivalent call
					th.muted.c
				)
				v14.lo.lb.draw(v14.lo.ch, v21 / 2, baseFor("m600_21_6", v23 - 3, v22 - v23), th.ink.c) -- inferred equivalent call
				v14.lo.nn.holder.Visible = p.names

				if p.names then
					local noteName = notes.noteName(note[v14.lo.ch])
					v14.lo.nn.draw(
						noteName,
						v21 - 7 - glyph.width("m500_9_92", noteName) / 2,
						baseFor("m500_9_92", v23, v22 - v23), -- inferred equivalent call
						th.muted.c
					)
				end

				f.paintQKey(v14.lo)
			else
				f2.BackgroundColor3 = backgroundColor
				face.BackgroundColor3 = c
				local c2 = th.dim.c

				if v14.toggle and f.touchUI then
					local draw = v14.lb.draw
					local v24 = v5 and "shift: tap" or "shift: hold"
					local v25 = v21 / 2
					local v26 = baseFor("s400_13_44", v22 / 2, 0) -- inferred equivalent call

					local v27 = if v5 then th.brassInk.c else th.ink.c
					draw(v24, v25, v26, v27)
				elseif v14.word then
					local width = glyph.width("s400_13_44", v14.text)
					local v24

					if v14.text == "enter" or v14.text == "delete" then
						v24 = true
					elseif v14.text == "shift" then
						v24 = v14.u > 7
					else
						v24 = false
					end

					local v25

					if v24 then
						v25 = v21 - 12 - width / 2
					else
						v25 = 12 + width / 2
					end

					v14.lb.draw(v14.text, v25, baseFor("s400_13_44", v22 / 2, 0), c2) -- inferred equivalent call

					if v14.mod then
						paintMod(v14)
					end
				else
					v14.top.draw(string.sub(v14.text, 1, 1), v21 / 2, baseFor("m600_13_12", v23 / 2, 6), c2) -- inferred equivalent call
					v14.bot.draw(string.sub(v14.text, 2, 2), v21 / 2, baseFor("m600_13_12", v23 - 3, v22 - v23), c2) -- inferred equivalent call
				end
			end
		end

		f.layoutStage()
	end
end