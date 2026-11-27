return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local _s = data.S
	local p = data.P
	local lay = data.Lay
	local btn = data.btn
	local _note = data.note
	local eyebrow = data.eyebrow
	local l145 = data.L145
	local toast = data.toast
	local comm = data.COMM
	local press = data.press
	local release = data.release
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")

	local v = nil

	function f.tutBusy(): boolean
		return v ~= nil
	end

	local function jingle(items, duration: number) -- 1 equivalent call inferred from this helper
		task.spawn(function()
			for _, item in items do
				if not v then
					break
				end

				press(item, "auto")
				task.delay(0.5, function()
					release(item)
				end)
				task.wait(duration)
			end
		end)
	end

	local function findHB()
		local v2 = nil
		local v3 = nil

		for _, v4 in comm.index do
			if v4.id == "c441aad24-6" then
				return v4
			end

			if not v2 and string.find(string.lower((tostring(v4.title))), "happy birthday", 1, true) then
				v2 = v4
			end

			if v3 or v4.level ~= "Easy" then
				continue
			end

			v3 = v4
		end

		return v2 or v3
	end

	local function frame(zIndex: number, flag: boolean) -- 5 equivalent calls inferred from this helper
		local instance = Instance.new(flag and "TextButton" or "Frame")
		instance.BorderSizePixel = 0
		instance.ZIndex = zIndex

		if flag then
			instance.Text = ""
			instance.AutoButtonColor = false
			instance.Selectable = false
		end

		instance.Parent = u.layer.inst
		return instance
	end

	local function spotlight(list)
		local th = lay.TH
		local c = th.overlay.c
		local a = th.overlay.a

		if not v.dims then
			v.dims = {}
			local dims = v.dims
			dims[1] = frame(90, true) -- inferred equivalent call
			local dims2 = v.dims
			dims2[2] = frame(90, true) -- inferred equivalent call
			local dims3 = v.dims
			dims3[3] = frame(90, true) -- inferred equivalent call
			local dims4 = v.dims
			dims4[4] = frame(90, true) -- inferred equivalent call
			v.ring = frame(91, false) -- inferred equivalent call
			v.ring.BackgroundTransparency = 1
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, 12)
			uiCorner.Parent = v.ring
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = 2
			uiStroke.Parent = v.ring
			v.ringTw = TweenService:Create(
				uiStroke,
				TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Transparency = 0.75 }
			)
			v.ringTw:Play()
		end

		local lw = u.layer.lw or 1280
		local lh_ = u.layer.lh_ or 720
		local uiStroke = v.ring:FindFirstChildOfClass("UIStroke")
		uiStroke.Color = th.brass.c

		if list then
			local item = list[1]
			local item2 = list[2]
			local item3 = list[3]
			local item4 = list[4]
			local v2 = {
				{ 0, 0, lw, item2 },
				{
					0,
					item2 + item4,
					lw,
					lh_ - item2 - item4
				},
				{ 0, item2, item, item4 },
				{
					item + item3,
					item2,
					lw - item - item3,
					item4
				}
			}

			for k, dim in v.dims do
				local v3 = v2[k]
				dim.Visible = v3[3] > 0 and v3[4] > 0
				dim.BackgroundColor3 = c
				dim.BackgroundTransparency = 1 - a
				dim.Position = UDim2.fromOffset(math.floor(v3[1]), (math.floor(v3[2])))
				dim.Size = UDim2.fromOffset(math.ceil(v3[3]), (math.ceil(v3[4])))
			end

			v.ring.Visible = item3 > 0
			v.ring.Position = UDim2.fromOffset(math.floor(item - 3), (math.floor(item2 - 3)))
			v.ring.Size = UDim2.fromOffset(math.ceil(item3 + 6), (math.ceil(item4 + 6)))
		else
			for _, dim in v.dims do
				dim.Visible = false
			end

			v.ring.Visible = false
		end
	end

	local function rectOf(data2, value: number?)
		if data2 and data2.ax and not data2.hidden and data2.inst.Visible then
			local v2 = value or 6
			return {
				data2.ax - v2,
				data2.ay - v2,
				(data2.lw or 0) + 2 * v2,
				(data2.lh_ or 0) + 2 * v2
			}
		end

		return nil
	end

	local function rectOfAll(items, p2: number?)
		local minValue = 1e999
		local minValue2 = 1e999
		local maxValue = -1e999
		local maxValue2 = -1e999

		for _, item in items do
			local v2 = rectOf(item, p2)

			if not v2 then
				continue
			end

			minValue = math.min(minValue, v2[1])
			minValue2 = math.min(minValue2, v2[2])
			maxValue = math.max(maxValue, v2[1] + v2[3])
			maxValue2 = math.max(maxValue2, v2[2] + v2[4])
		end

		if minValue == 1e999 then
			return nil
		end

		return {
			minValue,
			minValue2,
			maxValue - minValue,
			maxValue2 - minValue2
		}
	end

	local v2 = nil
	local v3 = {}
	local v4 = {}
	local fn

	local function finish(flag: boolean)
		if not v then
			return
		end

		local v5 = v
		v = nil

		if v5.conn then
			v5.conn:Disconnect()
		end

		if v5.ringTw then
			v5.ringTw:Cancel()
		end

		for _, v6 in v5.dims or {} do
			v6:Destroy()
		end

		if v5.ring then
			v5.ring:Destroy()
		end

		if v5.card then
			v5.card:destroy()
		end

		f.tutKey = nil
		f.tutFinish = nil
		lay.dirty()

		if v5.tips then
			task.delay(1.5, f.roomHint)
			return
		end

		f.savePref("tut", true)

		if f.phoneNow and not p.collapsed then
			f.setCollapsed(true)
		end

		if flag then
			toast("That's the tour. Welcome to Universal Piano Hub!")
		end

		if not p.firstTour then
			f.setMuteAll(v5.wasMuted == true)

			return
		end

		p.firstTour = nil
		task.delay(1.2, f.startTips)
	end

	local function hintAt(name: string, roomBtn, p2: string, p3: string, openRoomDialog, p4: string)
		if u[name] then
			return
		end

		local parent = b({
			name = name,
			dir = "row",
			align = "center",
			gap = 9,
			pad = { 5, 14, 5, 11 },
			r = 10,
			bg = "panel2",
			bd = 1,
			bdc = "brass55",
			z = 55,
			abs = { l = 0, t = 0 },
			button = true,
			hov = { bdc = "brass" },
			parent = u.layer
		})
		parent:bindHover()

		if p4 == "right" then
			t({
				t = "←",
				f = "s600_16",
				lh = 23.2,
				c = "brassInk",
				noShrink = true,
				parent = parent
			})
		end

		local parent2 = b({ dir = "col", parent = parent })
		t({
			t = p2,
			f = "s600_14_08",
			lh = l145(14.08),
			c = "brassInk",
			parent = parent2
		})
		t({
			t = p3,
			f = "s400_12_8",
			lh = l145(12.8),
			c = "ink",
			parent = parent2
		})

		if p4 == "below" then
			t({
				t = "↑",
				f = "s600_16",
				lh = 23.2,
				c = "brassInk",
				noShrink = true,
				parent = parent
			})
		end

		u[name] = parent
		local uiScale = Instance.new("UIScale")
		uiScale.Scale = 0.4
		uiScale.Parent = parent.inst

		local function place()
			local v5 = math.max(u.layerScale.Scale, 0.01)
			local absolutePosition = u.layer.inst.AbsolutePosition
			local inst = roomBtn.inst
			local v6, v7

			if p4 == "below" then
				local lw = u.layer.lw or 1280
				v6 = math.clamp(
					(inst.AbsolutePosition.X + inst.AbsoluteSize.X - absolutePosition.X) / v5 - (parent.lw or 200),
					4,
					(math.max(4, lw - (parent.lw or 200) - 4))
				)
				v7 = (inst.AbsolutePosition.Y + inst.AbsoluteSize.Y - absolutePosition.Y) / v5 + 10
			else
				v6 = (inst.AbsolutePosition.X + inst.AbsoluteSize.X - absolutePosition.X) / v5 + 12
				v7 = (inst.AbsolutePosition.Y + inst.AbsoluteSize.Y / 2 - absolutePosition.Y) / v5 - (parent.lh_ or 40) / 2
			end

			if math.abs((parent.abs.l or 0) - v6) > 0.5 or math.abs((parent.abs.t or 0) - v7) > 0.5 then
				parent.abs = { l = v6, t = math.max(2, v7) }
				lay.dirty()
			end

			local inst2 = parent.inst
			local visible = inst.Visible

			if visible then
				if inst.AbsoluteSize.X > 0 then
					visible = not p.fullscreen
				else
					visible = false
				end
			end

			inst2.Visible = visible
		end
		lay.now()
		place()
		lay.now()
		local renderSteppedConnection = RunService.RenderStepped:Connect(place)
		TweenService:Create(uiScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()

		local flag = true
		task.spawn(function()
			while flag do
				local frame2 = Instance.new("Frame")
				frame2.BackgroundTransparency = 1
				frame2.AnchorPoint = Vector2.new(0.5, 0.5)
				frame2.Position = UDim2.fromScale(0.5, 0.5)
				frame2.Size = UDim2.fromScale(1, 1)
				local uiCorner = Instance.new("UICorner", frame2)
				uiCorner.CornerRadius = UDim.new(0, 12)
				local uiStroke = Instance.new("UIStroke")
				uiStroke.Thickness = 2
				uiStroke.Color = lay.TH.brass.c
				uiStroke.Parent = frame2
				frame2.Parent = parent.inst
				local tweenInfo = TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(frame2, tweenInfo, { Size = UDim2.new(1, 18, 1, 14) }):Play()
				TweenService:Create(uiStroke, tweenInfo, { Transparency = 1 }):Play()
				task.delay(1.2, function()
					frame2:Destroy()
				end)
				task.wait(1.4)
			end
		end)
		local function remove()
			if not flag then
				return
			end

			flag = false
			local tween = TweenService:Create(
				uiScale,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ Scale = 0 }
			)
			tween:Play()
			tween.Completed:Connect(function()
				renderSteppedConnection:Disconnect()
				parent:destroy()
				u[name] = nil
				lay.dirty()
			end)
		end
		parent:onClick(function()
			remove()
			task.spawn(openRoomDialog)
		end)
		task.delay(20, remove)
	end

	function f.roomHint()
		hintAt(
			"roomHint",
			u.roomBtn,
			"Play with friends",
			"Make a private room with a password",
			f.openRoomDialog,
			"right"
		)
	end

	local function card(data2, p2: number)
		if v.card then
			v.card:destroy()
		end

		local v5 = b({
			dir = "col",
			gap = 10,
			pad = { 16, 18 },
			w = 360,
			bg = "panel",
			bd = 1,
			bdc = "brass55",
			r = 14,
			z = 92,
			button = true,
			shadow = { img = "sh60", blur = 50, y = 18 },
			abs = { l = 0, t = 0 },
			parent = u.layer
		})
		v.card = v5

		local parent = b({ dir = "row", align = "center", gap = 8, parent = v5 })
		parent:add(eyebrow(
			data2.tip and "Good to know" or data2.final and "Your turn" or string.format("Tour · %d of %d", p2, #v2 - 1),
			{ c = "brassInk" }
		))
		local parent2 = b({
			dir = "row",
			gap = 4,
			grow = 1,
			justify = "end",
			parent = parent
		})

		for i = 1, #v2 > 1 and #v2 or 0 do
			b({
				w = i == p2 and 14 or 6,
				h = 6,
				r = "pill",
				bg = i <= p2 and "brass" or "line",
				parent = parent2
			})
		end

		t({
			t = data2.title,
			f = "d600_20",
			lh = 24,
			wrap = true,
			parent = v5
		})

		for _, runs in data2.text do
			if type(runs) == "table" then
				local parent3 = b({ dir = "row", gap = 8, align = "start", parent = v5 })
				b({
					w = 6,
					h = 6,
					r = "pill",
					bg = "brass",
					m = { 7, 0, 0, 0 },
					noShrink = true,
					parent = parent3
				})
				parent3:add(t({
					runs = runs,
					f = "s400_14",
					lh = l145(14),
					c = "muted",
					wrap = true,
					grow = 1,
					shrink0 = true
				}))
			else
				v5:add(t({
					t = runs,
					f = "s400_14",
					lh = l145(14),
					c = "muted",
					wrap = true
				}))
			end
		end

		local v6

		if data2.task then
			v6 = t({
				t = data2.task(),
				f = "m600_12_8",
				lh = 18,
				c = "brassInk",
				parent = v5
			})
		end

		local parent3 = b({ dir = "row", align = "center", gap = 8, parent = v5 })

		if not (data2.final or data2.tip) then
			b({
				dir = "row",
				button = true,
				parent = parent3,
				{ t({ t = "Skip tour", f = "s500_13_6", lh = 19.72, c = "dim" }) }
			}):onClick(function()
				finish(false)
			end)
		end

		b({ grow = 1, parent = parent3 })

		if p2 > 1 and not (data2.final or data2.tip) then
			local v7 = btn("Back")
			parent3:add(v7)
			v7:onClick(function()
				fn(p2 - 1)
			end)
		end

		local v7 = btn(data2.next or "Next", "primary")
		parent3:add(v7)
		v7:onClick(function()
			if data2.final or p2 == #v2 then
				finish(true)
			else
				fn(p2 + 1)
			end
		end)
		return v5, v6
	end

	local function place(state, list, p2: string?)
		local lw = u.layer.lw or 1280
		local lh_ = u.layer.lh_ or 720
		local w = state.w or 360
		state.abs = { l = 0, t = 0 }
		lay.now()
		local lh_2 = state.lh_ or 260
		local v5 = math.max(8, lh_ - lh_2 - 8)

		if p2 == "corner" then
			if f.phoneNow then
				state.abs = { r = 8, t = 4 }
			else
				local v6

				if p.view == "qwerty" then
					v6 = u.qwerty
				else
					v6 = u.piano
				end

				local v7

				if v6.ay then
					v7 = v6.ay - 14
				else
					v7 = lh_ - 18
				end

				local v8 = v7 - lh_2
				state.abs = {
					l = lw - w - 24,
					t = math.clamp(v8, 8, v5)
				}
			end
		elseif list then
			local function fits(p3: number, p4: number): boolean -- 1 equivalent call inferred from this helper
				return p3 >= 8 and p4 >= 8 and p3 + w <= lw - 8 and p4 + lh_2 <= lh_ - 8
			end

			local v6 = math.clamp(list[1] + list[3] / 2 - w / 2, 8, (math.max(8, lw - w - 8)))
			local v7 = math.clamp(list[2] + list[4] / 2 - lh_2 / 2, 8, v5)
			local v8 = {
				{ v6, list[2] + list[4] + 14 },
				{ v6, list[2] - 14 - lh_2 },
				{ list[1] + list[3] + 16, v7 },
				{ list[1] - 16 - w, v7 }
			}

			local item = list[4]
			local v9 = nil

			for _, v10 in lh_ * 0.45 < item and { v8[3], v8[4], v8[1], v8[2] } or v8 do
				if fits(v10[1], v10[2]) then -- inferred equivalent call
					v9 = v10
					break
				end
			end

			local v10 = v9 or { v6, not (list[2] + list[4] / 2 < lh_ / 2) and 8 or v5 }

			state.abs = { l = v10[1], t = v10[2] }
		else
			state.abs = { cx = true, cy = true }
		end

		lay.dirty()
	end

	local function practiceOn() -- 1 equivalent call inferred from this helper
		if f.phoneNow and not p.collapsed then
			f.setCollapsed(true)
		end

		if p.hudOpen == false then
			f.setHudOpen(true)
		end

		f.setMode("practice")
	end
	local touchUI = f.touchUI == true

	local function fiveNotes()
		v.notes = 0
		local i = v.i
		function f.tutKey()
			if not v or v.i ~= i then
				return
			end

			v.notes += 1

			if v.task then
				v.task:setText(string.format("Notes played: %d / 5", (math.min(v.notes, 5))))
			end

			if v.notes == 5 then
				if v.task then
					v.task:setText("Nice! That's a piano.")
				end

				task.delay(0.9, function()
					if v and v.i == i then
						fn(i + 1)
					end
				end)
			end
		end
	end

	for _, v5 in {
		{
			title = "Welcome to Universal Piano Hub",
			text = {
				touchUI and "A real piano under your fingers, and a place to get good at it. Here is what you get:" or "A real piano on your keyboard, and a place to get good at it. Here is what you get:",
				{
					{ t = "Recorded concert grands", c = "ink" },
					{ t = " and 60+ sound fonts, with studio effects" }
				},
				{
					{ t = "Practice mode", c = "ink" },
					{ t = " that scores your accuracy and rhythm" }
				},
				{
					{ t = "A pianist rating", c = "ink" },
					{ t = " and leaderboards to climb" }
				},
				{
					{ t = "Private rooms", c = "ink" },
					{ t = " with friends and voice chat" }
				}
			},
			next = "Show me",
			enter = function()
				jingle({ "t", "u", "o", "s" }, 0.12) -- inferred equivalent call
			end
		},
		{
			title = "Peace and quiet",
			text = {
				"Mute all is on while the tour runs: you don't hear other players' pianos or see their notes, and they don't hear yours.",
				"Use it any time you want to practise alone, or to play as loud and fast as you like without bothering anyone."
			},
			target = function()
				return u.muteBtn
			end
		},
		{
			title = touchUI and "Tap to play" or "Your keyboard is the piano",
			text = { touchUI and "Tap the keys, low notes on the left. Several fingers at once make a chord. Try it: play any five notes." or "Every letter, number and Shift symbol is a key, low notes on the left. Try it: play any five notes." },
			target = function()
				return if p.view == "qwerty" then u.qwerty else u.piano
			end,
			task = function()
				return string.format("Notes played: %d / 5", (math.min(v.notes, 5)))
			end,
			enter = fiveNotes
		},
		{
			touch = true,
			title = "Move along the piano",
			text = {
				{
					{ t = "The strip", c = "ink" },
					{
						t = " is the whole piano: drag it, or tap the arrows, to move to other keys."
					}
				},
				{
					{ t = "− and +", c = "ink" },
					{ t = " show more keys or bigger ones." }
				},
				{
					{ t = "2", c = "ink" },
					{ t = " opens a second piano under the first, each with its own strip." }
				}
			},
			target = function()
				return u.navA
			end,
			enter = function()
				if p.view == "qwerty" then
					f.setView("piano", true)
				end
			end
		},
		{
			title = "Real pianos, not one beep",
			text = { "Pick the sound here: recorded Steinway and Yamaha grands, soft felt and cinematic pianos, e-pianos, strings, synths and more. Star the ones you like." },
			target = function()
				return u.instrSel.parent
			end
		},
		{
			title = "Studio effects",
			text = { "SFX adds reverb, echo, chorus, EQ and pitch shift. Mix them, save your setups and share them as a code. It glows green while an effect is on." },
			target = function()
				return u.revBtn
			end
		},
		{
			touch = true,
			title = "Players, chat and notes",
			text = { "This button opens the side panel: who's here, the chat and the sheet music. On a phone it starts folded, so the piano gets the whole screen. Tap it again to fold it." },
			target = function()
				return u.sideBtn
			end
		},
		{
			title = "Sheet music from players",
			text = {
				"Notes holds songs other players wrote, each one checked by an admin. Search them, rate them, keep favourites, or paste your own and submit it.",
				touchUI and "Swipe the list up and down: there are a lot of songs." or "Scroll the list: there are a lot of songs."
			},
			target = function()
				return u.tabsCard
			end,
			enter = function()
				f.showTab("lib")

				local i = v.i
				local inst = u.libPane.inst
				inst.CanvasPosition = Vector2.new(0, 0)
				task.delay(0.8, function()
					if not v or v.i ~= i then
						return
					end

					local v5 = inst.AbsoluteCanvasSize.Y - inst.AbsoluteSize.Y

					if v5 <= 4 then
						return
					end

					local tweenInfo = TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
					TweenService:Create(inst, tweenInfo, {
						CanvasPosition = Vector2.new(0, (math.min(v5, 320)))
					}):Play()
					task.delay(2.1, function()
						if v and v.i == i then
							TweenService:Create(inst, tweenInfo, {
								CanvasPosition = Vector2.new(0, 0)
							}):Play()
						end
					end)
				end)
			end
		},
		{
			title = "Practice that keeps score",
			text = {
				touchUI and "Open a sheet and play it here: the next notes glow on the piano, wrong notes shake." or "Open a sheet and play it here: the big keycap is what to press now, the keys glow on the piano, wrong notes shake.",
				"Finish a song and you get accuracy, rhythm and a score for your pianist rating."
			},
			target = function()
				return u.hud
			end,
			enter = practiceOn
		},
		{
			title = "Fix it, or keep going",
			text = {
				{
					{ t = "Edit", c = "ink" },
					{
						t = " opens the notes. Your own sheet you can change; anyone else's you get as a copy to save."
					}
				},
				{
					{ t = "Non-stop", c = "ink" },
					{
						t = ": a wrong note doesn't hold you up, the sheet moves on. Good for playing through a whole song."
					}
				}
			},
			target = function()
				return { u.editHud, u.flowBtn }
			end,
			enter = practiceOn
		},
		{
			title = "Practise just one part",
			text = {
				{
					{ t = "Section", c = "ink" },
					{
						t = touchUI and ": tap it, then tap the first note of a hard part in the sheet and its last note. Only that part plays, again and again." or ": click it, then click the first note of a hard part in the sheet and its last note. Only that part plays, again and again."
					}
				},
				{
					{ t = "Full song", c = "ink" },
					{
						t = " (the same button) plays the whole sheet again; press it once more to pick another part."
					}
				}
			},
			target = function()
				return u.secHud
			end,
			enter = practiceOn
		},
		{
			title = "Again, and again",
			text = {
				{
					{ t = "Loop", c = "ink" },
					{ t = " (the two arrows) starts the sheet over when you finish it." }
				},
				{
					{ t = "Restart", c = "ink" },
					{
						t = touchUI and " (the round arrow) goes back to the first note." or " (the round arrow, or Backspace) goes back to the first note. The key can be changed in Settings."
					}
				},
				{
					{ t = "Fold", c = "ink" },
					{ t = " (the little arrow up) hides the notes, so only the controls stay." }
				},
				{
					{ t = "Close", c = "ink" },
					{
						t = " (the cross) puts the panel away for free play. Drag the panel to move it."
					}
				}
			},
			target = function()
				return { u.loopBtn, u.restartBtn, u.minBtn, u.closeBtn }
			end,
			enter = practiceOn
		},
		{
			title = "Don't know how it goes?",
			text = {
				"Autoplay plays the sheet for you. Play and Pause are right here, and BPM sets the speed (each sheet comes with its own).",
				touchUI and "Then switch back to Practice and play it yourself." or "Or tap [ and ] to play it note by note at your own pace."
			},
			target = function()
				return { u.seg, u.playBtn, u.tempoBox }
			end,
			enter = function()
				if p.hudOpen == false then
					f.setHudOpen(true)
				end

				f.setMode("auto")
			end
		},
		{
			title = "Climb the leaderboard",
			text = { "Harder songs played cleanly and in time raise your pianist rating the most. See who's on top here." },
			target = function()
				return u.lbBtn
			end
		},
		{
			title = "Play together",
			text = { "Make your own room, invite friends, lock it with a password and talk with voice chat while you play." },
			target = function()
				return u.roomBtn
			end
		},
		{
			title = "Make it yours",
			text = {
				"Settings: a piano or a computer-keyboard view, 88 or 61 keys, pedal, note names on the keys and colour themes.",
				"Statistics shows how much you've played, and you can take this tour again from here."
			},
			target = function()
				return u.dialog
			end,
			enter = function()
				f.openSettings()
			end
		},
		{
			title = "Computer keyboard",
			text = {
				"Like letters better than piano keys? Pick Computer keyboard here: a real keyboard, every note on its letter.",
				touchUI and "Hold Shift while you tap a key for its Shift note (the \"shift: hold\" key switches it to one tap; Caps Lock keeps it on). The keyboard button next to the volume opens it on the whole screen." or "Shift works as usual, and the keyboard button next to the volume opens it on the whole screen."
			},
			target = function()
				if u.viewRow then
					return u.viewRow.kids[#u.viewRow.kids]
				end

				return nil
			end,
			enter = function()
				f.openSettings()
			end
		},
		{
			title = "Pick a look",
			text = {
				"Themes change the colours of everything: dark or light, Ocean, Sakura, Wood, Minecraft, Roblox Classic and more.",
				"Pick one here whenever you like."
			},
			target = function()
				local themeRow = u.themeRow

				if not (themeRow and themeRow.inst.Parent) then
					return nil
				end

				local v5 = math.max(u.layerScale.Scale, 0.01)
				local absolutePosition = u.layer.inst.AbsolutePosition
				local absolutePosition2 = themeRow.inst.AbsolutePosition
				return {
					ax = (absolutePosition2.X - absolutePosition.X) / v5,
					ay = (absolutePosition2.Y - absolutePosition.Y) / v5,
					lw = themeRow.lw,
					lh_ = themeRow.lh_,
					inst = themeRow.inst
				}
			end,
			enter = function()
				f.openSettings()

				lay.now()

				if not u.themeRow then
					return
				end

				local inst = u.themeRow.inst
				local scrollingFrame = inst:FindFirstAncestorWhichIsA("ScrollingFrame")

				if not scrollingFrame then
					return
				end

				local v5 = inst.AbsolutePosition.Y - scrollingFrame.AbsolutePosition.Y + scrollingFrame.CanvasPosition.Y - scrollingFrame.AbsoluteSize.Y / 3
				scrollingFrame.CanvasPosition = Vector2.new(
					0,
					(math.clamp(
						v5,
						0,
						(math.max(0, scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteSize.Y))
					))
				)

				task.wait()
			end
		},
		{
			final = true,
			title = "Now you: Happy Birthday",
			text = {
				touchUI and "Tap the glowing keys, one after the other. Chords in [ ] go together." or "Press the key on the big keycap, then the next one. Chords in [ ] are pressed together.",
				"Play it to the end to see your first score, or finish the tour whenever you like."
			},
			next = "Finish tour",
			enter = function()
				local hb = findHB()

				if hb then
					practiceOn() -- inferred equivalent call
					f.openCommunity(hb)
				end

				function f.tutFinish()
					finish(true)
				end
			end
		}
	} do
		if not v5.touch or touchUI then
			table.insert(v3, v5)
		end
	end

	v2 = v3

	for _, v5 in {
		{
			tip = true,
			title = "Nobody hears you yet",
			text = {
				"Mute all stays on for now: your playing bothers nobody, so play as much and as fast as you like.",
				(touchUI and "Tap" or "Click") .. " this button when you want to play for everyone: then the whole server hears you, and you hear them."
			},
			target = function()
				return u.muteBtn
			end,
			doneWhen = function(): boolean
				return not p.muteAll
			end,
			next = "Got it"
		},
		{
			tip = true,
			touch = true,
			title = "Players, chat and notes",
			text = { "Tap this button to open them: who's here, the chat and the sheet music. Tap it again to fold them away." },
			target = function()
				return u.sideBtn
			end,
			doneWhen = function(): boolean
				return not p.collapsed
			end,
			next = "Got it"
		}
	} do
		if not v5.touch or touchUI then
			table.insert(v4, v5)
		end
	end

	fn = function(p2: number)
		if not v then
			return
		end

		f.closeDialog()
		f.closePopup()
		f.tutKey = nil
		v.i = p2
		local v5 = v2[p2]

		if v5.enter then
			v5.enter()
		end

		lay.now()
		local v6, task2 = card(v5, p2)
		v.task = task2

		if v5.final then
			spotlight(nil)
			place(v6, nil, "corner")

			local v7 = rectOf(u.hud, 4)

			if v7 then
				v.ring.Visible = true
				v.ring.Position = UDim2.fromOffset(math.floor(v7[1] - 3), (math.floor(v7[2] - 3)))
				v.ring.Size = UDim2.fromOffset(math.ceil(v7[3] + 6), (math.ceil(v7[4] + 6)))
			end
		else
			local v7 = v5.target and v5.target()
			local v8

			if type(v7) == "table" and not v7.inst then
				v8 = rectOfAll(v7)
			else
				v8 = rectOf(v7)
			end

			spotlight(v8 or { 0, 0, 0, 0 })
			place(v6, v8)

			if v5.doneWhen then
				local v9 = v
				task.spawn(function()
					while v == v9 and v.i == p2 do
						if v5.doneWhen() then
							task.wait(0.4)

							if v ~= v9 or v.i ~= p2 then
								break
							end

							if p2 == #v2 then
								finish(true)
								break
							end

							fn(p2 + 1)
							break
						end

						task.wait(0.15)
					end
				end)
			end
		end
	end

	local function watchSize() -- 2 equivalent calls inferred from this helper
		v.conn = u.layer.inst:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if v then
				task.defer(function()
					if v then
						fn(v.i)
					end
				end)
			end
		end)
	end
	function f.startTips()
		if v or #v4 == 0 then
			return
		end

		v2 = v4
		v = { i = 1, tips = true }
		watchSize() -- inferred equivalent call
		fn(1)
	end
	function f.startTutorial()
		if v then
			return
		end

		v2 = v3
		v = {
			i = 1,
			notes = 0,
			wasMuted = p.muteAll == true
		}

		f.setMuteAll(true)
		watchSize() -- inferred equivalent call
		fn(1)
	end
end