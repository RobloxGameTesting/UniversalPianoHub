return function(data)
	local runService = data.RunService
	local lp = data.LP
	local levels = data.Levels
	local lay = data.Lay
	local audio = data.Audio
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local api = data.api
	local s = data.S
	local a = data.A
	local p = data.P
	local l145 = data.L145
	local btn = data.btn
	local eyebrow = data.eyebrow
	local note = data.note
	local radio = data.radio
	local range = data.range
	local restart = data.restart
	local openDialog = data.openDialog
	local input = data.input
	local statusLine = data.statusLine
	local findSheet = data.findSheet
	local findCommunity = data.findCommunity
	local smallBtn = data.smallBtn

	function f.sfxNum(p2: number, p3: string)
		local v

		if math.abs(p2 - math.floor(p2)) < 1e-6 then
			v = tostring((math.floor(p2)))
		else
			v = string.format("%.2f", p2)
		end

		local v2 = string.gsub(v, "(%.%d-)0+$", "%1")
		local v3 = string.gsub(v2, "%.$", "")

		if p3 == "" then
			return v3
		end

		return v3 .. " " .. p3
	end

	function f.openSfx()
		local sfx = f.Sfx
		local parent = openDialog("SFX", true, 760)
		function parent.wf(p2: number)
			return (math.min(960, p2))
		end
		parent.playable = true
		local HttpService = game:GetService("HttpService")

		local v = b({
			dir = "row",
			wrap = true,
			gap = 6,
			rowGap = 6,
			align = "center",
			parent = parent
		})
		local v2 = btn("Import")
		v:add(v2)
		local v3 = btn("Export")
		v:add(v3)
		local v4 = btn("Save / Load")
		v:add(v4)
		local v5 = btn("Custom")
		v:add(v5)
		local v6 = btn("All off", "danger")
		v:add(v6)
		f.iconify(v2, "download", 14)
		f.iconify(v3, "upload", 14)
		f.iconify(v4, "save", 14)
		f.iconify(v5, "sliders-horizontal", 14)
		f.iconify(v6, "power", 14)

		local v7 = b({
			dir = "row",
			gap = 6,
			align = "center",
			hidden = true,
			parent = parent
		})
		local _, v8 = input(v7, "", { grow = true })
		local v9 = btn("Apply", "primary")
		v7:add(v9)
		local parent2 = b({
			dir = "col",
			gap = 4,
			hidden = true,
			pad = 8,
			bg = "panel2",
			bd = 1,
			bdc = "line",
			r = 10,
			parent = parent
		})
		local v10 = statusLine(parent)

		local v11 = b({
			h = 52,
			noShrink = true,
			bg = "panel2",
			bd = 1,
			bdc = "line",
			r = 10,
			clip = true,
			parent = parent
		})

		local v12 = {}
		local v13 = ""

		for i = 1, 72 do
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			frame.ZIndex = 66
			frame.Parent = v11.inst
			v12[i] = frame
		end

		local v14 = table.create(72, 0)

		local parent3 = b({
			scroll = true,
			dir = "col",
			gap = 10,
			grow = 1,
			vshrink = true,
			minH = 140,
			parent = parent
		})
		local parent4 = b({
			dir = "row",
			wrap = true,
			gap = 8,
			rowGap = 8,
			parent = parent3
		})

		local v15 = {}
		local v16 = false

		for _, v17 in sfx.KINDS do
			local parent5 = b({
				dir = "col",
				gap = 2,
				w = 146,
				pad = { 8, 6 },
				bg = "panel2",
				bd = 1,
				bdc = "line",
				r = 10,
				parent = parent4
			})
			parent5:add(eyebrow(v17.name, {
				m = { 0, 4, 4, 4 }
			}))

			local v18 = {
				{ "off", "Off" }
			}
			local v19 = {}

			for _, preset in v17.presets do
				table.insert(v18, { preset[1], preset[2] })
			end

			table.insert(v18, { "custom", "Custom" })
			local v20 = {}
			local function paint()
				local v21 = p.sfx[v17.key] or "off"

				for k, v22 in v19 do
					local on = k == v21
					v22.r.on = on
					v22.r:paint()
					v22.b.bg = on and "brassSoft" or nil
					v22.b:paint()
				end

				local v22 = sfx.props(p.sfx, v17.key) or v17.presets[1][3]

				for _, v23 in v20 do
					local v24 = v22[v23.p[1]] or v23.p[3]
					v23.rg.set(v24)
					v23.cap:setRuns({
						{
							t = v23.p[2] .. " ",
							c = "muted"
						},
						{ t = f.sfxNum(v24, v23.p[6]), c = "ink" }
					})
				end
			end

			for _, v21 in v18 do
				local v22 = b({
					dir = "row",
					align = "center",
					gap = 4,
					pad = { 3, 4 },
					r = 7,
					button = true,
					parent = parent5
				})
				local v23 = radio(false)
				v22:add(v23)
				v22:add(t({
					t = v21[2],
					f = "s500_13_44",
					lh = l145(13.44),
					ell = true,
					grow = 1,
					shrink0 = true
				}))
				v19[v21[1]] = { b = v22, r = v23 }
				local v24 = v21
				v22:onClick(function()
					if v24[1] == "off" then
						p.sfx[v17.key] = nil
					else
						if v24[1] == "custom" and not p.sfx.custom[v17.key] then
							p.sfx.custom[v17.key] = table.clone(sfx.props(p.sfx, v17.key) or v17.presets[1][3])
						end

						p.sfx[v17.key] = v24[1]
					end

					paint()
					f.applySfx()
				end)
			end

			local v21 = b({
				dir = "col",
				gap = 2,
				hidden = true,
				m = { 6, 0, 0, 0 },
				pad = { 6, 2, 0, 2 },
				bds = { 1, 0, 0, 0 },
				bdc = "line",
				parent = parent5
			})

			for _, param in v17.params do
				local cap = t({
					f = "m600_8_96",
					up = true,
					ls = 0.896,
					runs = {
						{ t = param[2], c = "muted" }
					},
					parent = v21
				})
				local v22 = param
				local rg = range(param[3], param[4], param[5], param[3], function(p2)
					local v23 = p.sfx.custom[v17.key] or table.clone(sfx.props(p.sfx, v17.key) or v17.presets[1][3])
					v23[v22[1]] = p2
					p.sfx.custom[v17.key] = v23
					p.sfx[v17.key] = "custom"
					paint()
					f.applySfx()
				end, 126)
				v21:add(rg)
				table.insert(v20, { p = param, rg = rg, cap = cap })
			end

			paint()
			table.insert(v15, { paint = paint, cb = v21 })
		end

		local v17 = b({
			dir = "row",
			wrap = true,
			align = "center",
			gap = 10,
			rowGap = 6,
			pad = { 8, 10 },
			bg = "panel2",
			bd = 1,
			bdc = "line",
			r = 10,
			parent = parent3
		})
		v17:add(eyebrow("Pitch shift"))
		local function stText(p2: number) -- 3 equivalent calls inferred from this helper
			return (p2 > 0 and "+" or "") .. f.sfxNum(p2, "st")
		end

		local v18 = t({
			t = stText(p.sfx.pitch or 0), -- inferred equivalent call
			f = "m600_13_6",
			lh = 19.72,
			c = "ink",
			noShrink = true
		})
		local v19 = range(sfx.PITCH.min, sfx.PITCH.max, sfx.PITCH.step, p.sfx.pitch or 0, function(p2)
			local sfx2 = p.sfx
			local pitch

			if p2 ~= 0 then
				pitch = p2
			end

			sfx2.pitch = pitch
			v18:setText(stText(p2)) -- inferred equivalent call
			f.applySfx()
		end, 260)
		v17:add(v19)
		v17:add(v18)
		smallBtn(v17, "Reset"):onClick(function()
			p.sfx.pitch = nil
			v19.set(0)
			v18:setText("" .. f.sfxNum(0, "st"))
			f.applySfx()
		end)
		v17:add(note("Semitones; it changes the sound, not the keys.", { lh = l145(12.8) }))

		local function repaintAll()
			for _, v20 in v15 do
				v20.paint()
			end

			v19.set(p.sfx.pitch or 0)
			v18:setText(stText(p.sfx.pitch or 0)) -- inferred equivalent call
			lay.dirty()
		end

		local function showCode(p2: string, text: string, placeholderText: string, p3: string)
			v13 = p2
			parent2:show(false)
			v7:show(true)
			v8.Text = text
			v8.PlaceholderText = placeholderText
			v9.label:setText(p3)
			lay.dirty()
			task.defer(function()
				v8:CaptureFocus()

				if text ~= "" then
					v8.SelectionStart = 1
					v8.CursorPosition = #text + 1
				end
			end)
		end
		v3:onClick(function()
			showCode("export", "UPH-SFX:" .. HttpService:JSONEncode(p.sfx), "", "Done")
			v10("Select the code and press Ctrl+C to copy it. Others can paste it with Import.")
		end)
		v2:onClick(function()
			showCode("import", "", "Paste an SFX code here", "Apply")
			v10("")
		end)
		local function renderSlots()
			parent2:clear()
			parent2:add(eyebrow("Saved setups", {
				m = { 0, 2, 2, 2 }
			}))

			if #p.sfxSlots == 0 then
				parent2:add(note("Nothing saved yet."))
			end

			for k, sfxSlot in p.sfxSlots do
				local v20 = b({ dir = "row", align = "center", gap = 6, parent = parent2 })
				v20:add(t({
					t = tostring(sfxSlot.name),
					f = "s500_14",
					lh = 20.3,
					ell = true,
					grow = 1,
					shrink0 = true
				}))
				smallBtn(v20, "Load"):onClick(function()
					p.sfx = sfx.clean(sfxSlot.cfg)
					f.applySfx()
					repaintAll()
					v10("Loaded \"" .. tostring(sfxSlot.name) .. "\".")
				end)
				smallBtn(v20, "×", "bad"):onClick(function()
					table.remove(p.sfxSlots, k)
					f.savePref("sfxSlots", p.sfxSlots)
					renderSlots()
				end)
			end

			local v20 = btn("Save current…")
			parent2:add(v20)
			v20:onClick(function()
				showCode("save", "", "Name for this setup", "Save")
			end)
			lay.dirty()
		end
		v4:onClick(function()
			v7:show(false)
			parent2:show(parent2.hidden == true)

			if not parent2.hidden then
				renderSlots()
			end

			lay.dirty()
		end)
		local function codeApply()
			if v13 == "export" then
				v7:show(false)
				v10("")
				lay.dirty()
			elseif v13 == "import" then
				local v20 = string.gsub(v8.Text, "^%s*UPH%-SFX:", "")
				local success, result = pcall(function()
					return HttpService:JSONDecode(v20)
				end)

				if not success or type(result) ~= "table" then
					v10("This isn't an SFX code.", true)
					return
				end

				p.sfx = sfx.clean(result)
				f.applySfx()
				repaintAll()
				v7:show(false)
				v10("Imported.")
			elseif v13 == "save" then
				local name = string.sub(string.gsub(v8.Text, "^%s+", ""), 1, 30)

				if name == "" then
					v10("Write a name.", true)
					return
				end

				for i = #p.sfxSlots, 1, -1 do
					if p.sfxSlots[i].name == name then
						table.remove(p.sfxSlots, i)
					end
				end

				if #p.sfxSlots >= 10 then
					v10("You can keep 10 setups. Remove one first.", true)
					return
				end

				table.insert(p.sfxSlots, { name = name, cfg = sfx.clean(p.sfx) })
				f.savePref("sfxSlots", p.sfxSlots)
				v7:show(false)
				parent2:show(true)
				renderSlots()
				v10("Saved \"" .. name .. "\".")
			end
		end
		v9:onClick(codeApply)
		v8.FocusLost:Connect(function(p2)
			if p2 then
				codeApply()
			end
		end)
		v5:onClick(function()
			v16 = not v16

			for _, v20 in v15 do
				v20.cb:show(v16)
			end

			v5.label:setText(v16 and "Hide custom" or "Custom")
			lay.dirty()
		end)
		v6:onClick(function()
			p.sfx = sfx.clean({})
			f.applySfx()
			repaintAll()
		end)

		local total = 0
		local renderSteppedConnection = nil
		renderSteppedConnection = runService.RenderStepped:Connect(function(dt)
			if u.dialog ~= parent then
				renderSteppedConnection:Disconnect()
				return
			end

			total += dt

			if total < 1 / 30 then
				return
			end

			total = 0
			table.remove(v14, 1)
			table.insert(v14, math.clamp(audio.loudness() / 250, 0, 1) ^ 0.6)
			local pw = v11._pw or 0
			local ph = v11._ph or 0

			if pw <= 0 then
				return
			end

			local v20 = pw / 72
			local c = lay.TH.brass.c

			for k, v21 in v12 do
				local v22 = math.max(2, (math.floor(v14[k] * (ph - 12) + 0.5)))
				v21.BackgroundColor3 = c
				v21.BackgroundTransparency = v14[k] > 0.01 and 0.1 or 0.55
				v21.Size = UDim2.fromOffset(math.max(1, (math.floor(v20 - 2))), v22)
				v21.Position = UDim2.fromOffset(math.floor((k - 1) * v20 + 1), (math.floor((ph - v22) / 2)))
			end
		end)
	end

	f.SF_CATS = {
		{ "fav", "Favorites" },
		{ "grand", "Grand Pianos" },
		{ "keys", "Keys & Organs" },
		{ "perc", "Percussion" },
		{ "strings", "Strings" },
		{ "synth", "Synth" },
		{ "wind", "Wind" }
	}
	function f.openSoundFonts()
		local parent = openDialog("Sound fonts", true, 512)
		parent.playable = true
		local v = (audio.byKey[a.instr] or audio.list[1]).cat or "grand"

		local parent2 = b({
			dir = "row",
			gap = 12,
			grow = 1,
			vshrink = true,
			minH = 200,
			parent = parent
		})
		local parent3 = b({ dir = "col", gap = 3, w = 178, parent = parent2 })
		local parent4 = b({
			scroll = true,
			dir = "col",
			gap = 2,
			grow = 1,
			basis = 0,
			shrink0 = true,
			parent = parent2
		})
		local _, v2 = input(parent3, "Search…")
		b({ h = 5, parent = parent3 })
		local v3 = {}

		local function counts()
			local result = { fav = 0 }

			for _, item in audio.list do
				if item.id == "" then
					continue
				end

				result[item.cat] = (result[item.cat] or 0) + 1

				if p.ifav[item.key] then
					result.fav += 1
				end
			end

			return result
		end

		local function paintCats()
			local v4 = counts()

			for k, v5 in v3 do
				local v6

				if k == v then
					v6 = v2.Text == ""
				else
					v6 = false
				end

				v5:state("on", v6)
				v5.label.c = v6 and "brassInk" or "ink"
				v5.label:paint()
				v5.count.c = v6 and "brassInk" or "dim"
				v5.count:setText((tostring(v4[k] or 0)))
				v5.count:paint()
			end
		end

		local fn

		for _, v4 in f.SF_CATS do
			local label = t({
				t = v4[2],
				f = "s500_13_6",
				lh = 19.72,
				c = "ink",
				ell = true,
				grow = 1,
				shrink0 = true
			})
			local count = t({ t = "0", f = "s500_12_48", lh = 18.096, c = "dim" })
			local v5 = b({
				dir = "row",
				align = "center",
				gap = 8,
				pad = { 7, 10 },
				r = 8,
				button = true,
				hov = { bg = "white05" },
				sty = {
					on = { bg = "brassSoft" }
				},
				parent = parent3,
				{ label, count }
			})
			v5:bindHover()
			v5.label = label
			v5.count = count
			v3[v4[1]] = v5
			v5:onClick(function()
				v = v4[1]
				v2.Text = ""
				paintCats()
				fn()
			end)
		end

		b({ grow = 1, minH = 8, parent = parent3 })
		parent3:add(note(
			"Salamander Grand by A. Holm (CC BY 3.0), Headroom Piano by B. Nilsson (CC BY 4.0), E-Pianos by G. Sullivan (CC BY 3.0), Splendid Grand (PD), VCSL, Upright KW and the FreePats honky-tonk piano (CC0), GeneralUser GS, MuseScore General, FluidR3.",
			{ f = "s400_11_84", lh = l145(11.84), c = "dim" }
		))
		fn = function()
			parent4:clear()
			local text = string.lower(v2.Text)

			local v4 = {}
			local count = 0
			local count2 = 0

			for _, item in audio.list do
				if item.id == "" then
					continue
				end

				local v5

				if text == "" then
					if v == "fav" then
						v5 = p.ifav[item.key] == true
					else
						v5 = item.cat == v
					end
				else
					v5 = string.find(string.lower(item.name), text, 1, true) ~= nil
				end

				if not v5 then
					continue
				end

				table.insert(v4, item)

				if item.hq then
					count += 1
				end
			end

			local v5 = {}

			for _, v6 in v4 do
				if v6.hq then
					table.insert(v5, v6)
				end
			end

			for _, v6 in v4 do
				if not v6.hq then
					table.insert(v5, v6)
				end
			end

			local v6

			if count > 0 then
				v6 = count < #v5
			else
				v6 = false
			end

			for k, v7 in v5 do
				if v6 and (k == 1 or k == count + 1) then
					parent4:add(eyebrow(k == 1 and "High quality" or "Classic", {
						m = {
							k == 1 and 2 or 10,
							10,
							2,
							10
						}
					}))
				end

				count2 += 1
				local v8 = v7.key == a.instr
				local v9 = b({
					dir = "row",
					align = "center",
					gap = 8,
					pad = { 6, 10 },
					r = 8,
					button = true,
					bg = v8 and "brassSoft" or nil,
					hov = not v8 and { bg = "white05" } or nil,
					parent = parent4
				})

				if not v8 then
					v9:bindHover()
				end

				v9:add(t({
					t = v7.name,
					f = "s500_14",
					lh = 20.3,
					c = v8 and "brassInk" or "ink",
					ell = true,
					grow = 1,
					shrink0 = true
				}))
				local v10 = p.ifav[v7.key] == true
				local v11 = smallBtn(v9, "★", v10 and "brassInk" or "dim", true)
				f.iconify(v11, v10 and "star-fill" or "star", 13, true)
				v11:onClick(function()
					p.ifav[v7.key] = not v10 or nil
					f.savePref("ifav", p.ifav)
					paintCats()
					fn()
				end)
				v9:onClick(function()
					f.setInstrument(v7.key)
					fn()
				end)
			end

			if count2 == 0 then
				parent4:add(note(
					v == "fav" and text == "" and "No favourites yet. Press ★ next to a sound to keep it here." or text == "" and "No sounds here yet." or "Nothing found.",
					{
						pad = { 4, 8 }
					}
				))
			end

			lay.dirty()
		end
		v2:GetPropertyChangedSignal("Text"):Connect(function()
			paintCats()
			fn()
		end)
		paintCats()
		fn()
	end

	local TweenService = game:GetService("TweenService")
	local soundLoading = Instance.new("Frame")
	soundLoading.Name = "SoundLoading"
	soundLoading.AnchorPoint = Vector2.new(1, 1)
	soundLoading.Size = UDim2.fromOffset(300, 52)
	soundLoading.Visible = false
	soundLoading.ZIndex = 60
	local uiCorner = Instance.new("UICorner", soundLoading)
	uiCorner.CornerRadius = UDim.new(0, 12)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Parent = soundLoading
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(18, 18)
	frame.Position = UDim2.fromOffset(17, 17)
	frame.BackgroundTransparency = 1
	frame.ZIndex = 61
	local uiCorner_2 = Instance.new("UICorner", frame)
	uiCorner_2.CornerRadius = UDim.new(1, 0)
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 2.5
	uiStroke2.Parent = frame
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6, 0.15),
		NumberSequenceKeypoint.new(0.62, 1),
		NumberSequenceKeypoint.new(1, 1)
	})
	uiGradient.Parent = uiStroke2
	frame.Parent = soundLoading
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromOffset(18, 18)
	textLabel.Position = UDim2.fromOffset(17, 17)
	textLabel.Text = "✓"
	textLabel.TextSize = 16
	textLabel.Font = Enum.Font.BuilderSansBold
	textLabel.ZIndex = 61
	textLabel.Parent = soundLoading
	local function label(p2: number, textSize: number, p3)
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.BackgroundTransparency = 1
		textLabel2.Position = UDim2.fromOffset(48, p2)
		textLabel2.Size = UDim2.new(1, -60, 0, textSize + 4)
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.TextTruncate = Enum.TextTruncate.AtEnd
		textLabel2.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", p3)
		textLabel2.TextSize = textSize
		textLabel2.ZIndex = 61
		textLabel2.Parent = soundLoading
		return textLabel2
	end

	local v = label(8, 15, Enum.FontWeight.SemiBold)
	local v2 = label(28, 12, Enum.FontWeight.Regular)
	local v3 = false
	local v4 = 0
	local v5 = 0
	local udim = UDim2.new(1, -16, 1, -16)
	local udim2 = UDim2.new(1, 340, 1, -16)
	local function paint(visible: boolean) -- 2 equivalent calls inferred from this helper
		local th = lay.TH
		soundLoading.BackgroundColor3 = th.panel2.c
		uiStroke.Color = th.line.c
		uiStroke2.Color = th.brass.c
		textLabel.TextColor3 = th.ok.c
		v.TextColor3 = th.ink.c
		v2.TextColor3 = th.muted.c
		frame.Visible = not visible
		textLabel.Visible = visible
	end
	local function slide(flag: boolean)
		v3 = flag

		if flag then
			soundLoading.Parent = u.layer.inst
			soundLoading.Position = udim2
			soundLoading.Visible = true
		end

		local quint = Enum.EasingStyle.Quint
		local v6

		if flag then
			v6 = Enum.EasingDirection.Out
		else
			v6 = Enum.EasingDirection.In
		end

		local tweenInfo = TweenInfo.new(flag and 0.45 or 0.35, quint, v6)
		local position = if flag then udim else udim2
		local tween = TweenService:Create(soundLoading, tweenInfo, { Position = position })
		tween:Play()

		if not flag then
			tween.Completed:Once(function()
				if not v3 then
					soundLoading.Visible = false
				end
			end)
		end
	end
	runService.RenderStepped:Connect(function(dt)
		if soundLoading.Visible then
			uiGradient.Rotation = (uiGradient.Rotation + dt * 360) % 360
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.15)
			local loading = audio.loading(a.instr)
			local v6 = audio.byKey[a.instr]
			local now = os.clock()

			if loading then
				if v5 == 0 then
					v5 = now
				end

				if v3 and v4 > 0 or not v3 and now - v5 > 0.3 then
					v.Text = "Loading " .. (not v6 and "the sound" or v6.name) .. "…"
					v2.Text = "Notes will sound as soon as it's here"
					paint(false) -- inferred equivalent call
					v4 = 0

					if not v3 then
						slide(true)
					end
				end
			else
				v5 = 0

				if v3 then
					if v4 == 0 then
						v4 = now
						v.Text = (not v6 and "The sound" or v6.name) .. " is ready"
						v2.Text = "Have fun playing!"
						paint(true) -- inferred equivalent call
					elseif now - v4 > 1.4 then
						slide(false)
					end
				end
			end
		end
	end)

	local function fmtNum(p2: number)
		local v6 = tostring((math.floor(p2 + 0.5)))
		local v7 = string.reverse(string.gsub(string.reverse(v6), "(%d%d%d)", "%1,"))
		local v8 = string.gsub(v7, "^,", "")
		return (string.gsub(v8, "^%-,", "-"))
	end

	f.fmtNum = fmtNum
	local v6 = {
		{ "rating", "Pianist rating" },
		{ "presses", "Notes played" },
		{ "time", "Time in game" },
		{ "donated", "Donated" },
		{ "raised", "Raised" }
	}
	local v7 = {
		{ "all", "All time" },
		{ "month", "This month" },
		{ "week", "This week" },
		{ "day", "Today" }
	}
	local function lbValue(p2: string, p3: number)
		if p2 == "time" then
			local v8 = p3 / 3600

			if v8 < 1 then
				return math.floor(p3 / 60) .. " min"
			end

			return string.format("%.1f h", v8)
		elseif p2 == "donated" or p2 == "raised" then
			return fmtNum(p3) .. " R$"
		else
			return fmtNum(p3)
		end
	end

	function f.openLeaderboard()
		local parent = openDialog("Leaderboard", true, 680)
		local metric = "rating"
		local v8 = "all"
		local function pills(items, p2: string, fn)
			local parent2 = b({
				dir = "row",
				wrap = true,
				gap = 6,
				rowGap = 6,
				parent = parent
			})
			local v9 = {}
			local function set(p3: string)
				for k, v10 in v9 do
					v10:state("on", k == p3)
					v10.label.c = k == p3 and "bg" or "muted"
					v10.label:paint()
				end
			end

			for _, item in items do
				local label2 = t({ t = item[2], f = "s500_13_6", lh = 19.72, c = "muted" })
				local v10 = b({
					dir = "row",
					pad = { 4, 12 },
					r = "pill",
					bd = 1,
					bdc = "line",
					button = true,
					sty = {
						on = { bg = "ink", bdc = "ink" }
					},
					parent = parent2,
					{ label2 }
				})
				v10.label = label2
				v9[item[1]] = v10
				v10:onClick(function()
					set(item[1])
					fn(item[1])
				end)
			end

			set(p2)
			return parent2
		end

		local parent2 = nil
		local v9 = nil
		local count = 0
		local function load()
			count += 1
			local v10 = count
			parent2:clear()
			parent2:add(note("Loading…"))
			v9:setText("")
			lay.dirty()
			task.spawn(function()
				local v11 = api("leaderboard", {
					metric = metric,
					period = metric == "rating" and "all" or v8
				})

				if v10 ~= count or u.dialog ~= parent then
					return
				end

				parent2:clear()

				if type(v11) == "table" and type(v11.rows) == "table" then
					if #v11.rows == 0 then
						parent2:add(note("Nobody here yet."))
					end

					for k, row in v11.rows do
						local parent3 = b({
							dir = "row",
							align = "center",
							gap = 10,
							pad = { 5, 8 },
							r = 8,
							bg = row.id == lp.UserId and "brassSoft" or k % 2 == 0 and "white05" or nil,
							parent = parent2
						})
						b({
							w = 28,
							noShrink = true,
							parent = parent3,
							{ t({
									t = tostring(k),
									f = "m600_14_72",
									c = k <= 3 and "brassInk" or "muted"
								}) }
						})
						local v12 = b({
							w = 28,
							h = 28,
							r = "pill",
							clip = true,
							bg = "panel2",
							noShrink = true,
							parent = parent3
						})

						if tonumber(row.id) and row.id > 0 then
							local imageLabel = Instance.new("ImageLabel")
							imageLabel.BackgroundTransparency = 1
							imageLabel.Size = UDim2.fromScale(1, 1)
							imageLabel.ZIndex = 66
							imageLabel.Image = "rbxthumb://type=AvatarHeadShot&id=" .. row.id .. "&w=48&h=48"
							imageLabel.Parent = v12.inst
						end

						local parent4 = b({
							dir = "col",
							grow = 1,
							shrink0 = true,
							parent = parent3
						})
						t({
							t = tostring(row.display or row.name or "?"),
							f = "s500_14_08",
							lh = l145(14.08),
							ell = true,
							parent = parent4
						})
						t({
							t = "@" .. tostring(row.name or "?"),
							f = "s400_12_8",
							lh = 16,
							c = "muted",
							ell = true,
							parent = parent4
						})
						t({
							t = lbValue(metric, tonumber(row.v) or 0),
							f = "m600_14_72",
							c = "ink",
							noShrink = true,
							parent = parent3
						})
					end

					v9:setText("You: " .. lbValue(metric, tonumber(v11.mine) or 0))
				else
					parent2:add(note("Couldn't load the leaderboard. Try again in a minute."))
				end

				lay.dirty()
			end)
		end
		local v10 = nil
		pills(v6, metric, function(p2)
			metric = p2

			v10:show(p2 ~= "rating")
			load()
		end)
		v10 = pills(v7, v8, function(p2)
			v8 = p2
			load()
		end)
		v10:show(metric ~= "rating")
		parent2 = b({
			scroll = true,
			dir = "col",
			gap = 2,
			grow = 1,
			vshrink = true,
			minH = 80,
			parent = parent
		})
		v9 = t({
			t = "",
			f = "s500_13_44",
			lh = l145(13.44),
			c = "muted",
			parent = parent
		})
		parent:add(note("Updates every few minutes. Days and weeks follow UTC time.", {
			lh = l145(12.8)
		}))
		load()
	end
	u.lbBtn:onClick(f.openLeaderboard)

	function f.runStats()
		local goodKeys = s.goodKeys
		local mistakes = s.mistakes
		local v8 = not (goodKeys + mistakes > 0) and 0 or goodKeys / (goodKeys + mistakes)
		local v9 = 60 / (s.sheetBpm or s.bpm or 120) / 2
		local total = 0

		for i = 2, #s.steps do
			total += s.steps[i].wait * v9
		end

		local time = s.times[1]
		local time2 = s.times[#s.steps]

		if not time or not time2 or total <= 0 then
			return v8, 0, 1
		end

		local v10 = math.max(time2 - time, 0.001)
		return v8, math.clamp(1 - (math.max(v10, total) / math.min(v10, total) - 1.1) / 0.9, 0, 1), v10 / total
	end

	function f.showResult()
		if f.tutFinish then
			f.tutFinish()
		end

		if #s.steps < 2 then
			return
		end

		local acc, rhy, v8 = f.runStats()
		local perf = levels.perf(acc, rhy)
		local activeId = s.activeId
		local sheet = findSheet(activeId)

		local v9 = findCommunity(activeId)

		if not v9 then
			if sheet and type(sheet.pubId) == "string" and sheet.status == "published" and not sheet.edited then
				v9 = findCommunity(sheet.pubId) or nil
			else
				v9 = nil
			end
		end

		local level = v9 and v9.level or sheet and sheet.level
		local parent = openDialog(levels.verdict(perf), false)
		parent.playable = true
		local parent2 = b({ dir = "row", align = "center", gap = 12, parent = parent })
		parent2:add(eyebrow("Your score"))
		local v10 = t({
			t = v9 and "…" or "—",
			f = "m600_24",
			lh = 28,
			c = v9 and "muted" or "dim",
			parent = parent2
		})
		local parent3 = b({ dir = "row", gap = 8, parent = parent })
		local function tile(p2: string)
			local v11 = b({
				dir = "col",
				gap = 5,
				pad = { 9, 12 },
				bg = "panel2",
				bd = 1,
				bdc = "line",
				r = 10,
				grow = 1,
				basis = 0,
				shrink0 = true,
				parent = parent3
			})
			v11:add(eyebrow(p2))
			return v11
		end

		t({
			t = math.floor(acc * 100 + 0.5) .. "%",
			f = "m600_21_6",
			lh = 24,
			parent = tile("Accuracy")
		})
		t({
			t = math.floor(rhy * 100 + 0.5) .. "%",
			f = "m600_21_6",
			lh = 24,
			parent = tile("Rhythm")
		})
		local parent4 = tile("Difficulty")
		local v11 = levels.get(level)

		if v11 then
			parent4:add(f.levelText(v11, "s600_16", 24))
		else
			t({
				t = "—",
				f = "m600_21_6",
				lh = 24,
				c = "dim",
				parent = parent4
			})
		end

		local v12 = t({
			t = not p.rating and "—" or tostring((math.floor(p.rating))),
			f = "m600_21_6",
			lh = 24,
			parent = tile("Pianist rating")
		})
		local v13

		if s.sheetBpm and v8 < 0.8 then
			v13 = "Try slowing down."
		elseif s.sheetBpm and v8 > 1.3 then
			v13 = "Try speeding up."
		elseif acc < 0.8 then
			v13 = "Watch out for wrong notes."
		else
			v13 = nil
		end

		if v9 then
			if not s.sheetBpm then
				v13 = (not v13 and "" or v13 .. " ") .. "This sheet has no BPM yet, so the rhythm is checked against Autoplay's tempo."
			end
		else
			v13 = (not v13 and "" or v13 .. " ") .. "Only published sheets count toward your pianist rating."
		end

		if v13 then
			parent:add(note(v13))
		end

		local v14 = b({ dir = "row", gap = 8, parent = parent })
		local v15 = btn("Play again", "primary")
		v14:add(v15)
		local v16 = btn("Close")
		v14:add(v16)
		v15:onClick(function()
			f.closeDialog()
			restart()
		end)
		v16:onClick(f.closeDialog)

		if v9 then
			local elapsed = s.elapsed
			local count = #s.steps
			task.spawn(function()
				local v17 = api("rateRun", {
					id = v9.id,
					acc = acc,
					rhy = rhy,
					ms = elapsed,
					steps = count
				})

				if type(v17) == "table" and type(v17.score) == "number" then
					local rating = p.rating
					p.rating = tonumber(v17.rating) or p.rating
					v10.c = v17.score >= 0 and "ok" or "bad"
					v10:setText(string.format("%+.2f", v17.score))
					v10:paint()
					local v18 = {
						{
							t = tostring((math.floor(p.rating or 0)))
						}
					}
					local v19 = not (rating and p.rating) and 0 or math.floor(p.rating) - math.floor(rating)

					if v19 ~= 0 then
						table.insert(v18, {
							t = string.format(" %+d", v19),
							c = v19 > 0 and "ok" or "bad",
							f = "m600_14_72"
						})
					end

					v12:setRuns(v18)
					lay.dirty()
				else
					v10.c = "dim"
					v10:setText("—")
					v10:paint()

					if u.dialog == parent then
						parent:add(note("This run didn't count toward your rating."))
					end
				end
			end)
		end
	end

	function f.openStartOver()
		local UserInputService = game:GetService("UserInputService")
		local parent = openDialog("Start over?")
		local parent2 = b({ dir = "col", gap = 10, parent = parent })
		t({
			t = "The game starts again as on your first visit: you rejoin this server, with the tour and the default settings.",
			f = "s400_14",
			lh = l145(14),
			wrap = true,
			parent = parent2
		})
		local function line(p2: string, p3: string, p4: string)
			t({
				runs = {
					{ t = p2, c = p4 },
					{ t = p3 }
				},
				f = "s400_13_44",
				lh = l145(13.44),
				c = "muted",
				wrap = true,
				parent = parent2
			})
		end
		line(
			"Erased: ",
			"your statistics (time played, keys, runs) and settings (theme, sound, keyboard view, volume, pedal and the rest).",
			"bad"
		)
		line(
			"Kept: ",
			"your pianist rating, your own sheets, favourites and ratings, purchases, starred sounds and saved SFX setups.",
			"ok"
		)
		local v8 = btn("Hold for 2 seconds to start over", "danger")
		v8.self = "stretch"
		parent2:add(v8)
		local inst = v8.inst
		inst.ClipsDescendants = true
		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.BackgroundColor3 = lay.TH.bad.c
		frame2.BackgroundTransparency = 0.6
		frame2.Size = UDim2.fromScale(0, 1)
		frame2.ZIndex = inst.ZIndex
		frame2.Parent = inst
		local v9 = nil
		local lastTime = 0
		local v10 = false
		local renderSteppedConnection = nil
		local function stop() -- 2 equivalent calls inferred from this helper
			v9 = nil

			if not v10 then
				frame2.Size = UDim2.fromScale(0, 1)
			end
		end
		inst.InputBegan:Connect(function(input2)
			if
				v10
				or input2.UserInputType ~= Enum.UserInputType.MouseButton1
				and input2.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end

			v9 = input2
			lastTime = os.clock()
		end)
		inst.InputEnded:Connect(function(input2)
			if input2 == v9 then
				stop() -- inferred equivalent call
			end
		end)
		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input2)
			if input2 == v9 then
				stop() -- inferred equivalent call
			end
		end)
		renderSteppedConnection = runService.RenderStepped:Connect(function()
			if u.dialog == parent then
				if not v9 or v10 then
					return
				end

				local v11 = math.clamp((os.clock() - lastTime) / 2, 0, 1)
				frame2.Size = UDim2.fromScale(v11, 1)

				if v11 < 1 then
					return
				end

				v10 = true
				v9 = nil
				v8.label:setText("Starting over…")

				f.prefsHold(true)
				task.spawn(function()
					local v12 = api("startOver")

					if v12 == "studio" then
						f.prefsHold(false)
						f.closeDialog()
						f.toast("Reset. Studio can't rejoin: stop and press Play to start over.")
					elseif not v12 then
						f.prefsHold(false)
						f.closeDialog()
						f.toast("That didn't work. Try again in a moment.")
					end
				end)
			else
				renderSteppedConnection:Disconnect()
				inputEndedConnection:Disconnect()
			end
		end)
		t({
			t = "Let go before it fills up and nothing changes.",
			f = "s400_12_8",
			lh = 18.56,
			c = "dim",
			wrap = true,
			parent = parent2
		})
		lay.dirty()
	end
end