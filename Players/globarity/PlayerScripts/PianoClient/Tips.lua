return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local s = data.S
	local p = data.P
	local lay = data.Lay
	local btn = data.btn
	local l145 = data.L145
	local glyph = data.Glyph
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")

	local v = { r = true, s = true }
	local v2 = false
	local v3 = false
	local v4 = nil

	local function save(p2: string) -- 7 equivalent calls inferred from this helper
		if v[p2] then
			return
		end

		v[p2] = true
		f.savePref(p2 == "r" and "tipR" or "tipS", true)
	end

	local function keyName() -- 1 equivalent call inferred from this helper
		local v5

		if f.restartKey then
			v5 = f.restartKey()
		else
			v5 = Enum.KeyCode.Backspace
		end

		if v5 == Enum.KeyCode.Backspace then
			return "backspace"
		end

		return v5.Name
	end

	local function keycap(parent, text: string)
		local v5 = text == "backspace"
		local v6 = b({
			w = v5 and 112 or math.max(60, #text * 9 + 24),
			h = 46,
			noShrink = true,
			parent = parent
		})
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(1, 1)
		frame.ZIndex = 58
		local uiCorner = Instance.new("UICorner", frame)
		uiCorner.CornerRadius = UDim.new(0, 9)
		frame.Parent = v6.inst
		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.Position = UDim2.fromOffset(1, 1)
		frame2.Size = UDim2.new(1, -2, 1, -6)
		frame2.ZIndex = 59
		local uiCorner_2 = Instance.new("UICorner", frame2)
		uiCorner_2.CornerRadius = UDim.new(0, 8)
		frame2.Parent = frame
		local v7 = {}
		local function line(p2: number, p3: number, p4: number, rotation: number)
			local frame3 = Instance.new("Frame")
			frame3.BorderSizePixel = 0
			frame3.AnchorPoint = Vector2.new(0.5, 0.5)
			frame3.Position = UDim2.fromOffset(p2, p3)
			frame3.Size = UDim2.fromOffset(p4, 2)
			frame3.Rotation = rotation
			frame3.ZIndex = 60
			local uiCorner = Instance.new("UICorner", frame3)
			uiCorner.CornerRadius = UDim.new(1, 0)
			frame3.Parent = frame2
			table.insert(v7, frame3)
		end
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.ZIndex = 60
		textLabel.Text = text

		if v5 then
			line(27, 12, 30, 0)
			line(15.4, 9.2, 9, -40)
			line(15.4, 14.8, 9, 40)
			textLabel.FontFace = glyph.nativeFont("s400_11_84")
			textLabel.TextSize = glyph.nativeSize("s400_11_84")
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.Position = UDim2.fromOffset(10, 21)
			textLabel.Size = UDim2.new(1, -16, 0, 16)
		else
			textLabel.FontFace = glyph.nativeFont("s500_13_6")
			textLabel.TextSize = glyph.nativeSize("s500_13_6")
			textLabel.Size = UDim2.fromScale(1, 1)
		end

		textLabel.Parent = frame2
		function v6.onPaint()
			local th = lay.TH
			frame.BackgroundColor3 = th.capEdge.c
			frame2.BackgroundColor3 = th.cap.c

			for _, v8 in v7 do
				v8.BackgroundColor3 = th.ink.c
			end

			textLabel.TextColor3 = th.ink.c
		end
		v6:paint()
		return v6
	end

	local function onScreen(p2): boolean
		if not p2 or not p2.inst or p2.hidden then
			return false
		end

		local guiObject = p2.inst

		while guiObject and guiObject:IsA("GuiObject") do
			if not guiObject.Visible then
				return false
			end

			guiObject = guiObject.Parent
		end

		return p2.inst.AbsoluteSize.X > 0
	end

	local fn

	local function remove(state)
		state.alive = false
		local uiScale = state.node.inst:FindFirstChildOfClass("UIScale")
		local function gone() -- 1 equivalent call inferred from this helper
			state.conn:Disconnect()
			state.ring:Destroy()
			state.node:destroy()
			lay.dirty()
		end

		if uiScale then
			local tween = TweenService:Create(
				uiScale,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ Scale = 0 }
			)
			tween:Play()
			tween.Completed:Connect(gone)
		else
			gone() -- inferred equivalent call
		end
	end
	local function close(p2: string) -- 1 equivalent call inferred from this helper
		local v5 = v4

		if not v5 or v5.k ~= p2 then
			return
		end

		v4 = nil
		save(p2) -- inferred equivalent call
		remove(v5)

		task.delay(1.2, fn)
	end

	local function show(p2: string)
		local v5

		if p2 == "r" then
			v5 = u.restartBtn
		else
			v5 = u.secHud
		end

		local touchUI = f.touchUI == true
		local v6 = b({
			dir = "col",
			gap = 0,
			w = p2 == "r" and 300 or 320,
			z = 57,
			abs = { l = 0, t = 0 },
			button = true,
			parent = u.layer
		})
		local v7 = b({
			dir = "row",
			justify = "center",
			parent = v6,
			{ t({ t = "↑", f = "s600_16", lh = 18, c = "brassInk" }) }
		})
		local parent = b({
			dir = "col",
			gap = 8,
			pad = { 12, 14 },
			r = 12,
			bg = "panel2",
			bd = 1,
			bdc = "brass55",
			shadow = { img = "sh60", blur = 40, y = 12 },
			parent = v6
		})
		local v8 = b({
			dir = "row",
			justify = "center",
			parent = v6,
			{ t({ t = "↓", f = "s600_16", lh = 18, c = "brassInk" }) }
		})
		parent:add(t({
			t = "Good to know",
			f = "m500_10_24",
			up = true,
			ls = 1.024,
			c = "brassInk"
		}))

		if p2 == "r" then
			parent:add(t({
				t = "Start the song over",
				f = "s600_14_08",
				lh = l145(14.08),
				c = "ink"
			}))

			if touchUI then
				parent:add(t({
					t = "Missed a note? Tap this button and the song starts again from its first note.",
					f = "s400_12_8",
					lh = l145(12.8),
					c = "muted",
					wrap = true
				}))
			else
				local parent2 = b({ dir = "row", align = "center", gap = 10, parent = parent })
				keycap(parent2, keyName()) -- inferred equivalent call
				parent2:add(t({
					t = "or this button: the song starts again from its first note.",
					f = "s400_12_8",
					lh = l145(12.8),
					c = "muted",
					wrap = true,
					grow = 1,
					shrink0 = true
				}))

				parent:add(t({
					t = "You can pick another key in Settings.",
					f = "s400_12_8",
					lh = l145(12.8),
					c = "dim",
					wrap = true
				}))
			end
		else
			local v9 = touchUI and "Tap" or "Click"
			parent:add(t({
				t = "Practise just the hard part",
				f = "s600_14_08",
				lh = l145(14.08),
				c = "ink"
			}))

			for k, v10 in {
				"Press Section.",
				v9 .. " the first note of the part in the sheet.",
				v9 .. " its last note: only that part plays, again and again."
			} do
				local v11 = b({ dir = "row", gap = 8, align = "start", parent = parent })
				v11:add(t({
					t = tostring(k),
					f = "m600_12_8",
					lh = l145(12.8),
					c = "brassInk",
					noShrink = true
				}))
				v11:add(t({
					t = v10,
					f = "s400_12_8",
					lh = l145(12.8),
					c = "muted",
					wrap = true,
					grow = 1,
					shrink0 = true
				}))
			end

			parent:add(t({
				t = "Full song brings the whole song back.",
				f = "s400_12_8",
				lh = l145(12.8),
				c = "dim",
				wrap = true
			}))
		end

		local v9 = b({ dir = "row", justify = "end", parent = parent })
		local v10 = btn("Got it", "primary")
		v9:add(v10)
		v10:onClick(function()
			local v11 = p2
			local v12 = v4

			if v12 then
				if v12.k ~= v11 then
					return
				end

				v4 = nil
				save(v11) -- inferred equivalent call
				remove(v12)

				task.delay(1.2, fn)
			end
		end)

		local uiScale = Instance.new("UIScale")
		uiScale.Scale = 0.4
		uiScale.Parent = v6.inst

		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.ZIndex = 56
		local uiCorner = Instance.new("UICorner", frame)
		uiCorner.CornerRadius = UDim.new(0, 10)
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 2
		uiStroke.Parent = frame
		frame.Parent = u.layer.inst
		TweenService:Create(uiStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Transparency = 0.8
		}):Play()

		local v11 = {
			k = p2,
			node = v6,
			ring = frame,
			alive = true,
			conn = nil,
			side = ""
		}
		v4 = v11

		local function place()
			local visible = onScreen(v5)

			if visible then
				if u.dialog == nil then
					visible = not (p.fullscreen or f.vrOn or f.tutBusy and f.tutBusy())

					if visible then
						visible = not (f.inReview and f.inReview())
					end
				else
					visible = false
				end
			end

			v6.inst.Visible = visible
			frame.Visible = visible

			if not visible then
				return
			end

			local v12 = math.max(u.layerScale.Scale, 0.01)
			local absolutePosition = u.layer.inst.AbsolutePosition
			local inst = v5.inst
			local v13 = (inst.AbsolutePosition.X - absolutePosition.X) / v12
			local v14 = (inst.AbsolutePosition.Y - absolutePosition.Y) / v12
			local v15 = inst.AbsoluteSize.X / v12
			local v16 = inst.AbsoluteSize.Y / v12
			local lw = u.layer.lw or 1280
			local lw2 = v6.lw or v6.w or 300
			local lh_ = v6.lh_ or 150
			local side = v14 - lh_ - 4 >= 2 and "above" or "below"

			if side ~= v11.side then
				v11.side = side
				v7:show(side == "below")
				v8:show(side == "above")
				lay.dirty()
			end

			local v17 = math.clamp(v13 + v15 / 2 - lw2 / 2, 4, (math.max(4, lw - lw2 - 4)))
			local v18

			if side == "above" then
				v18 = v14 - lh_ - 4
			else
				v18 = v14 + v16 + 4
			end

			if math.abs((v6.abs.l or 0) - v17) > 0.5 or math.abs((v6.abs.t or 0) - v18) > 0.5 then
				v6.abs = { l = v17, t = v18 }
				lay.dirty()
			end

			frame.Position = UDim2.fromOffset(math.floor(v13 - 4), (math.floor(v14 - 4)))
			frame.Size = UDim2.fromOffset(math.ceil(v15 + 8), (math.ceil(v16 + 8)))
			uiStroke.Color = lay.TH.brass.c
		end
		v7:show(false)
		lay.now()
		place()
		lay.now()
		v11.conn = RunService.RenderStepped:Connect(function()
			local success, result = pcall(place)

			if not success then
				warn("Tips: " .. tostring(result))
			end
		end)
		TweenService:Create(uiScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	end

	fn = function()
		if v4 or not v3 then
			return
		end

		if not v.r then
			show("r")
		elseif not v.s then
			show("s")
		end
	end

	u.restartBtn:onClick(function()
		if v4 and v4.k == "r" then
			local v5 = v4

			if v5 then
				if v5.k ~= "r" then
					return
				end

				v4 = nil
				save("r") -- inferred equivalent call
				remove(v5)

				task.delay(1.2, fn)
			end
		elseif f.touchUI then
			save("r") -- inferred equivalent call
		end
	end)
	local restart = f.restart

	if restart then
		function f.restart(...)
			if v4 and v4.k == "r" then
				close("r") -- inferred equivalent call
			else
				save("r") -- inferred equivalent call
			end

			return restart(...)
		end
	end

	u.secHud:onClick(function()
		if v4 and v4.k == "s" then
			local v5 = v4

			if v5 then
				if v5.k ~= "s" then
					return
				end

				v4 = nil
				save("s") -- inferred equivalent call
				remove(v5)

				task.delay(1.2, fn)
			end
		else
			save("s") -- inferred equivalent call
		end
	end)

	function f.tipPrefs(p2)
		v.r = p2.tipR == true
		v.s = p2.tipS == true
		v3 = false

		if v4 then
			local v5 = v4
			v4 = nil
			remove(v5)
		end

		task.delay(2, function()
			v2 = true
		end)
	end

	function f.onSheet(_: string)
		if not v2 or v3 or f.autoOpening or v.r and v.s then
			return
		end

		if f.tutBusy and f.tutBusy() or f.inReview and f.inReview() or #s.steps == 0 then
			return
		end

		v3 = true
		task.delay(1.5, fn)
	end
end