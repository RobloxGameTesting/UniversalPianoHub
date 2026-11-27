return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local p = data.P
	local lay = data.Lay
	local lp = data.LP
	local api = data.api
	local btn = data.btn
	local note = data.note
	local eyebrow = data.eyebrow
	local openDialog = data.openDialog
	local input = data.input
	local statusLine = data.statusLine
	local toast = data.toast
	local l145 = data.L145
	local vp = data.VP
	local RunService = game:GetService("RunService")
	local remotes = vp:WaitForChild("Remotes")
	local vote = remotes:WaitForChild("Vote")
	local overplay = remotes:WaitForChild("Overplay")

	local function fmtTime(p2: number)
		local v = math.max(0, (math.ceil(p2)))
		return string.format("%d:%02d", v // 60, v % 60)
	end

	local parent = b({
		name = "voteBanner",
		dir = "col",
		gap = 6,
		pad = { 12, 16, 10, 16 },
		bg = "panel",
		bd = 1,
		bdc = "line",
		r = 12,
		z = 58,
		abs = { t = 8, cx = true },
		wf = function(p2: number)
			return (math.min(460, p2 - 16))
		end,
		button = true,
		hidden = true,
		parent = u.layer
	})
	parent.inst.Visible = false
	local parent2 = b({ dir = "row", align = "center", gap = 8, parent = parent })
	parent2:add(eyebrow("Vote kick", { c = "bad" }))
	local v = t({
		t = "",
		f = "s500_13_44",
		lh = l145(13.44),
		ell = true,
		grow = 1,
		shrink0 = true,
		parent = parent2
	})
	local v2 = b({ grow = 1, h = 1, parent = parent2 })
	local v3 = t({
		t = "0:40",
		f = "m600_12_48",
		c = "muted",
		noShrink = true,
		parent = parent2
	})
	local v4 = b({
		pad = { 0, 4 },
		r = 6,
		button = true,
		noShrink = true,
		hov = { bg = "white07" },
		parent = parent2,
		{ t({ t = "×", f = "s400_22_4", lh = 18, c = "muted" }) }
	})
	v4:bindHover()
	local parent3 = b({ dir = "row", align = "center", gap = 8, parent = parent })
	local v5 = t({
		t = "",
		f = "s600_16",
		lh = 23.2,
		ell = true,
		shrink0 = true,
		parent = parent3
	})
	local v6 = t({
		t = "",
		f = "s400_12_8",
		c = "muted",
		ell = true,
		shrink0 = true,
		parent = parent3
	})
	local v7 = t({
		t = "",
		f = "s400_14_08",
		lh = l145(14.08),
		wrap = true,
		parent = parent
	})
	local v8 = t({ t = "", f = "s400_12_8", c = "muted", parent = parent })
	local parent4 = b({
		dir = "row",
		align = "center",
		gap = 8,
		m = { 2, 0, 0, 0 },
		parent = parent
	})
	local v9 = t({
		t = "",
		f = "s500_13_44",
		lh = l145(13.44),
		grow = 1,
		shrink0 = true,
		wrap = true,
		parent = parent4
	})
	local v10 = btn("Kick", "danger")
	parent4:add(v10)
	local v11 = btn("Don't kick")
	parent4:add(v11)
	v10.noShrink = true
	v11.noShrink = true

	v10.sty.on = { bg = "badSoft", bdc = "bad" }
	v11.sty.on = { bg = "white08", bdc = "muted" }
	local v12 = b({
		h = 3,
		r = 2,
		bg = "white08",
		clip = true,
		parent = parent
	})
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.ZIndex = 60
	frame.Parent = v12.inst

	local v13 = nil
	local v14 = 0
	local v15 = nil
	local count = 0
	local v16 = false
	local flag = false
	local function setCompact(flag2: boolean)
		v16 = flag2
		parent3:show(not flag2)
		v7:show(not flag2)
		v8:show(not flag2)
		parent4:show(not flag2)
		v:show(flag2)
		v2:show(not flag2)
		parent.pad = lay.pad4(flag2 and { 8, 12, 8, 14 } or { 12, 16, 10, 16 })
		function parent.wf(p2: number)
			return (math.min(flag2 and 400 or 460, p2 - 16))
		end
		lay.dirty()
	end
	setCompact(false)
	local function setBtns(flag2: boolean) -- 3 equivalent calls inferred from this helper
		v10:show(flag2)
		v11:show(flag2)
	end
	local function render(data2)
		local v17 = data2.target == lp.UserId
		v5:setText((tostring(data2.display)))
		v6:setText("@" .. tostring(data2.name))
		v7:setRuns({
			{ t = "Reason: ", c = "muted" },
			{ t = tostring(data2.reason) }
		})
		v8:setText("Started by " .. tostring(data2.by))
		local yes = tonumber(data2.yes) or 0
		local need = tonumber(data2.need) or 1

		if v17 then
			v9:setText("Players are voting to kick you. " .. yes .. " of " .. need .. " votes so far.")
			setBtns(false) -- inferred equivalent call
		else
			local v18 = v15
			v9:setText(yes .. " of " .. need .. " votes to kick" .. (v18 == true and " · You voted to kick" or v18 == false and " · You voted to keep" or ""))
			setBtns(true) -- inferred equivalent call
			v10:state("on", v18 == true)
			v11:state("on", v18 == false)
		end

		v9.c = v17 and "bad" or "ink"
		v9:paint()

		local v18 = v15

		if v17 then
			v:setRuns({
				{ t = "Vote to kick you: ", c = "bad" },
				{
					t = yes .. " of " .. need,
					c = "ink"
				}
			})
		else
			v:setRuns({
				{ t = "Kick ", c = "muted" },
				{ t = tostring(data2.display), c = "ink" },
				{ t = "?  ", c = "muted" },
				{
					t = yes .. " of " .. need,
					c = "ink"
				},
				{
					t = v18 == true and " · you: kick" or v18 == false and " · you: keep" or "",
					c = "muted"
				}
			})
		end

		lay.dirty()
	end
	local function show(data2)
		count += 1
		local v17 = not v13 or v13.id ~= data2.id

		if v17 then
			v15 = nil
		end

		local v18

		if type(data2.voters) == "table" then
			v18 = data2.voters[tostring(lp.UserId)]
		else
			v18 = false
		end

		if v18 ~= nil then
			v15 = v18
		end

		if v17 then
			flag = false

			setCompact(v15 ~= nil)
		end

		v13 = data2
		v14 = os.clock() + (tonumber(data2.left) or 40)
		parent.bdc = "bad"
		parent:paint()
		render(data2)
		parent:show(not flag)
	end
	local function finished(data2)
		if not v13 or v13.id ~= data2.id then
			return
		end

		v13 = nil
		setBtns(false) -- inferred equivalent call
		local v17 = data2.result == "kicked"
		local v18

		if v17 then
			v18 = tostring(data2.display) .. " was kicked from this server."
		else
			v18 = "Not enough votes. " .. tostring(data2.display) .. " stays."
		end

		v9:setText(v18)

		v9.c = v17 and "bad" or "muted"
		v9:paint()
		local v19

		if v17 then
			v19 = tostring(data2.display) .. " was kicked."
		else
			v19 = tostring(data2.display) .. " stays: not enough votes."
		end

		v:setRuns({
			{
				t = v19,
				c = v17 and "bad" or "muted"
			}
		})

		if flag then
			flag = false
			setCompact(true)
			parent:show(true)
		end

		v3:setText("")
		frame.Size = UDim2.fromScale(0, 1)
		parent.bdc = "line"
		parent:paint()
		lay.dirty()
		count += 1
		local v20 = count
		task.delay(4, function()
			if v20 == count then
				parent:show(false)
			end
		end)
	end
	vote.OnClientEvent:Connect(function(p2)
		if type(p2) ~= "table" then
			return
		end

		if p2.active then
			show(p2)
		else
			finished(p2)
		end
	end)
	task.spawn(function()
		local v17 = api("voteState")

		if type(v17) == "table" and v17.active and not v13 then
			show(v17)
		end
	end)
	local function cast(yes: boolean)
		if not v13 then
			return
		end

		v15 = yes
		render(v13)
		local id = v13.id
		task.spawn(function()
			local v17, v18 = api("vote", { id = id, yes = yes })

			if not v17 and v18 then
				toast((tostring(v18)))
			end
		end)

		task.delay(0.8, function()
			if v13 and v13.id == id and not v16 then
				setCompact(true)
			end
		end)
	end
	v10:onClick(function()
		cast(true)
	end)
	v11:onClick(function()
		cast(false)
	end)
	v4:onClick(function()
		if not v16 then
			setCompact(true)
			return
		end

		if not v13 then
			parent:show(false)

			return
		end

		flag = true
		parent:show(false)
	end)

	parent:onClick(function()
		if v16 and v13 then
			setCompact(false)
		end
	end)
	RunService.RenderStepped:Connect(function()
		if not v13 then
			return
		end

		local v17 = v14 - os.clock()
		v3:setText(fmtTime(v17))
		frame.BackgroundColor3 = lay.TH.bad.c
		frame.Size = UDim2.fromScale(math.clamp(v17 / 40, 0, 1), 1)
	end)

	function f.openVoteKick(player)
		local parent5 = b({ dir = "col", gap = 10, parent = openDialog("Vote kick") })
		t({
			runs = {
				{ t = "Kick " },
				{ t = player.DisplayName, c = "ink" },
				{
					t = " (@" .. player.Name .. ") from this server?",
					c = "muted"
				}
			},
			f = "s400_14_08",
			lh = l145(14.08),
			wrap = true,
			parent = parent5
		})
		parent5:add(note(
			"Everyone on this server votes. If more than half of the players vote yes, " .. player.DisplayName .. " is banned from this server.",
			{ lh = l145(12.8) }
		))
		local _, v17 = input(parent5, "Why? For example: spamming keys", {})
		local v18 = statusLine(parent5)
		local v19 = b({ dir = "row", gap = 8, parent = parent5 })
		local v20 = btn("Start the vote", "danger")
		v19:add(v20)
		local v21 = btn("Cancel")
		v19:add(v21)
		v21:onClick(f.closeDialog)
		local flag2 = false
		local function start()
			if flag2 then
				return
			end

			local v22 = string.gsub(v17.Text, "^%s+", "")

			if #v22 < 3 then
				v18("Write why this player should be kicked.", true)
				return
			end

			flag2 = true
			v18("Starting…")
			task.spawn(function()
				local v23, v24 = api("voteKick", {
					target = player.UserId,
					reason = string.sub(v22, 1, 80)
				})
				flag2 = false

				if v23 then
					f.closeDialog()
				else
					v18(tostring(v24 or "Couldn't start the vote."), true)
				end
			end)
		end
		v20:onClick(start)
		v17.FocusLost:Connect(function(p2)
			if p2 then
				start()
			end
		end)
		task.defer(function()
			v17:CaptureFocus()
		end)
	end

	function f.voteKickBtn(parent5, instance)
		if
			instance == lp
			or instance:GetAttribute("Admin") == true
			or vp:GetAttribute("IsRoom") == true and vp:GetAttribute("RoomHost") == instance.UserId
		then
			return
		end

		local v17 = b({
			dir = "row",
			m = { 4, 0, 0, 0 },
			pad = { 8, 6, 2, 6 },
			bds = { 1, 0, 0, 0 },
			bdc = "line",
			parent = parent5
		})
		local v18 = btn("Vote kick", "danger")
		v18.grow = 1
		v17:add(v18)
		v18:onClick(function()
			if f.closePopup then
				f.closePopup()
			end

			f.openVoteKick(instance)
		end)
	end

	function f.openAdmin(player)
		local parent5 = openDialog("Admin · " .. player.DisplayName)
		local parent6 = b({ dir = "col", parent = parent5 })
		local v17 = statusLine(parent5)
		local function row(p2: string, p3: string, p4: string, p5: string?, action, flag2: boolean?)
			local parent7 = b({
				dir = "row",
				align = "center",
				gap = 14,
				pad = { 10, 0 },
				bds = { 0, 0, 1, 0 },
				bdc = "line",
				parent = parent6
			})
			local parent8 = b({
				dir = "col",
				gap = 2,
				grow = 1,
				shrink0 = true,
				parent = parent7
			})
			t({ t = p2, f = "s600_14_08", lh = l145(14.08), parent = parent8 })
			parent8:add(note(p3, { lh = l145(12.8) }))
			local v18 = btn(flag2 and "Has it" or p4, p5)
			v18.noShrink = true
			parent7:add(v18)

			if flag2 then
				v18.op = 0.45
				v18:repaintAll()
			else
				if (type)(action) == "function" then
					v18:onClick(action)
					return
				end

				local flag3 = false
				v18:onClick(function()
					if flag3 then
						return
					end

					flag3 = true
					v17("Working…")
					task.spawn(function()
						local v19, v20 = api("admin", { target = player.UserId, action = action })
						flag3 = false

						if not player.Parent then
							v17("This player has left.", true)
							return
						end

						v17(tostring(v20 or v19 and "Done." or "Couldn't do that."), not v19)

						if v19 and (action == "vip" or action == "rainbow") then
							v18.label:setText("Has it")
							v18.op = 0.45
							v18:repaintAll()
							flag3 = true
						end

						if v19 and action == "silence" then
							v18.label:setText(player:GetAttribute("Silenced") == true and "Turn on" or "Silence")
						end

						lay.dirty()
					end)
				end)
			end
		end
		row(
			"Give VIP",
			"Free and forever. It arrives as a gift from you, for everyone to see.",
			"Give",
			"primary",
			"vip",
			player:GetAttribute("VIP") == true
		)
		row(
			"Give Rainbow Notes",
			"Free and forever, also as a gift from you.",
			"Give",
			"primary",
			"rainbow",
			player:GetAttribute("RainbowOwned") == true
		)
		row(
			"Overplay warning",
			"Tells them they're overplaying and turns on Mute all for them, so nobody hears them. They can turn it off themselves.",
			"Warn",
			"danger",
			"warn"
		)
		row("Private message", "Only they see it, above their keyboard.", "Write", nil, function()
			f.openAdminPanel(player)
		end)
		local silenced = player:GetAttribute("Silenced") == true
		row(
			silenced and "Their piano is silenced" or "Silence their piano",
			"Nobody on this server hears their piano until you turn it back on or they leave.",
			silenced and "Turn on" or "Silence",
			nil,
			"silence"
		)
	end

	local Players = game:GetService("Players")
	local adminMsg = remotes:WaitForChild("AdminMsg")

	local parent5 = b({
		name = "adminMsg",
		dir = "row",
		align = "center",
		gap = 10,
		pad = { 8, 8, 10, 14 },
		bg = "panel",
		bd = 1,
		bdc = "brass55",
		r = 10,
		z = 54,
		abs = { l = 0, t = 0 },
		w = 520,
		button = true,
		hidden = true,
		parent = u.layer
	})
	parent5.inst.Visible = false
	local parent6 = b({
		dir = "col",
		gap = 1,
		grow = 1,
		shrink0 = true,
		parent = parent5
	})
	local v17 = eyebrow("", { c = "brassInk", ell = true })
	parent6:add(v17)
	local v18 = t({
		t = "",
		f = "s600_14_08",
		lh = l145(14.08),
		wrap = true,
		parent = parent6
	})
	local v19 = b({
		w = 26,
		h = 26,
		dir = "row",
		align = "center",
		justify = "center",
		r = 6,
		button = true,
		noShrink = true,
		hov = { bg = "white05" },
		parent = parent5,
		{ t({ t = "×", f = "s600_16", lh = 23.2, c = "muted" }) }
	})
	v19:bindHover()
	local frame2 = Instance.new("Frame")
	frame2.BorderSizePixel = 0
	frame2.AnchorPoint = Vector2.new(0, 1)
	frame2.ZIndex = 56
	frame2.Parent = parent5.inst
	local v20 = 0
	local v21 = 1
	local function hideMsg() -- 1 equivalent call inferred from this helper
		v20 = 0
		parent5:show(false)
	end
	v19:onClick(hideMsg)
	adminMsg.OnClientEvent:Connect(function(data2)
		if type(data2) ~= "table" then
			return
		end

		local v22

		if data2.private then
			v22 = "Private message from " .. tostring(data2.from)
		else
			v22 = "Message from " .. tostring(data2.from) .. " · admin"
		end

		v17:setText(v22)
		v18:setText((tostring(data2.text)))
		v21 = math.max(1, tonumber(data2.secs) or 10)
		v20 = os.clock() + v21
		parent5:show(true)
		lay.dirty()

		if not data2.private and f.sysMsg then
			f.sysMsg("Admin " .. tostring(data2.from) .. ": " .. tostring(data2.text))
		end
	end)
	RunService.RenderStepped:Connect(function()
		if v20 == 0 then
			return
		end

		local v22 = v20 - os.clock()

		if v22 <= 0 then
			hideMsg() -- inferred equivalent call
		else
			frame2.BackgroundColor3 = lay.TH.brass.c
			local v23 = math.max(0, (parent5.lw or 520) - 24)
			frame2.Position = UDim2.new(0, 12, 1, -3)
			frame2.Size = UDim2.fromOffset(math.floor(v23 * v22 / v21 + 0.5), 2)

			local v24 = math.max(u.layerScale.Scale, 0.01)
			local absolutePosition = u.layer.inst.AbsolutePosition
			local inst = u.main.inst
			local inst2 = u.stage.inst
			local v25 = inst.AbsoluteSize.X / v24
			local v26 = math.max(200, (math.min(520, v25 - 32)))
			local v27 = (inst.AbsolutePosition.X - absolutePosition.X) / v24 + v25 / 2 - v26 / 2
			local v28 = (inst2.AbsolutePosition.Y + inst2.AbsoluteSize.Y - absolutePosition.Y) / v24 - 14 - (parent5.lh_ or 80)
			local abs = parent5.abs

			if parent5.w ~= v26 or math.abs((abs.l or 0) - v27) > 0.5 or math.abs((abs.t or 0) - v28) > 0.5 then
				parent5.w = v26
				parent5.abs = { l = v27, t = v28 }
				lay.dirty()
			end
		end
	end)

	function f.openAdminPanel(p2)
		if f.closePopup then
			f.closePopup()
		end

		local parent7 = b({ dir = "col", gap = 10, parent = openDialog("Admin", true) })
		local function secsRow(p3: string)
			local parent8 = b({ dir = "row", align = "center", gap = 8, parent = parent7 })
			t({ t = "Show for", f = "s400_13_12", c = "muted", parent = parent8 })
			local v22, v23 = input(parent8, "10", {})
			v22.w = 64
			v23.Text = "10"
			t({ t = "seconds", f = "s400_13_12", c = "muted", parent = parent8 })
			b({ grow = 1, h = 1, parent = parent8 })
			local v24 = btn(p3, "primary")
			parent8:add(v24)
			return v23, v24
		end

		parent7:add(eyebrow("Message to everyone on this server"))
		local _, v22 = input(parent7, "Write a message…", {})
		local v23, v24 = secsRow("Send to everyone")
		b({
			h = 1,
			bg = "line",
			m = { 6, 0, 6, 0 },
			parent = parent7
		})
		parent7:add(eyebrow("Private message"))
		local parent8 = b({
			dir = "row",
			wrap = true,
			gap = 6,
			rowGap = 6,
			parent = parent7
		})
		local v25 = p2
		local v26 = {}
		local function paintChips() -- 2 equivalent calls inferred from this helper
			for k, v27 in v26 do
				v27:state("on", k == v25)
			end
		end

		for _, v27 in Players:GetPlayers() do
			if v27 == lp then
				continue
			end

			local v28 = b({
				dir = "row",
				align = "center",
				pad = { 4, 10 },
				r = "pill",
				bd = 1,
				bdc = "line",
				bg = "panel2",
				button = true,
				sty = {
					on = { bg = "brassSoft", bdc = "brass" }
				},
				parent = parent8,
				{ t({ t = v27.DisplayName, f = "s500_13_6", lh = 19.72 }) }
			})
			v26[v27] = v28
			v28:onClick(function()
				v25 = v27
				paintChips() -- inferred equivalent call
			end)
		end

		if next(v26) == nil then
			parent8:add(note("Nobody else is on this server."))
		end

		paintChips() -- inferred equivalent call
		local _, v27 = input(parent7, "Write a private message…", {})
		local v28, v29 = secsRow("Send")
		local v30 = statusLine(parent7)
		local function send(p3, p4, p5)
			if string.gsub(p3.Text, "%s", "") == "" then
				v30("Write the message first.", true)
				return
			end

			if p5 == false then
				v30("Pick who gets it.", true)
				return
			end

			v30("Sending…")
			task.spawn(function()
				local v31 = {
					text = p3.Text,
					secs = tonumber(p4.Text) or 10,
					target = 0
				}
				local target

				if p5 then
					target = p5.UserId
				end

				v31.target = target
				local v32, v44 = api("adminSay", v31)
				v30(tostring(v44 or v32 and "Sent." or "Couldn't send."), not v32)

				if v32 then
					p3.Text = ""
				end
			end)
		end
		v24:onClick(function()
			send(v22, v23, nil)
		end)
		v29:onClick(function()
			send(v27, v28, v25 or false)
		end)

		if p2 then
			task.defer(function()
				v27:CaptureFocus()
			end)
		end
	end

	local function topButton()
		if u.adminBtn then
			return
		end

		local label = t({ t = "Admin", f = "s400_13_6", lh = 19.72, c = "muted" })
		local adminBtn = b({
			dir = "row",
			align = "center",
			justify = "center",
			h = 30,
			minW = 30,
			pad = { 0, 9 },
			bd = 1,
			bdc = "line",
			bg = "panel",
			r = 8,
			button = true,
			noShrink = true,
			hov = { bdc = "hoverLine" },
			{ label }
		})
		adminBtn:bindHover()
		adminBtn.label = label
		u.topbar:add(adminBtn)
		local kids = u.topbar.kids
		table.remove(kids)
		table.insert(kids, table.find(kids, u.reviewBtn) or #kids + 1, adminBtn)

		if f.iconify then
			f.iconify(adminBtn, "shield", 15)
		end

		if u.logo.hidden and adminBtn.ico then
			label:show(false)
		end

		u.adminBtn = adminBtn
		adminBtn:onClick(function()
			f.openAdminPanel()
		end)
		lay.dirty()
	end
	local function checkAdmin() -- 1 equivalent call inferred from this helper
		if lp:GetAttribute("Admin") == true then
			task.spawn(function()
				task.wait()
				topButton()
			end)
		end
	end
	lp:GetAttributeChangedSignal("Admin"):Connect(checkAdmin)
	checkAdmin() -- inferred equivalent call

	function f.adminBtn(object, p2)
		local v22 = btn("Admin")
		object:add(v22)
		v22:onClick(function()
			if f.closePopup then
				f.closePopup()
			end

			f.openAdmin(p2)
		end)
	end

	local muteRing = Instance.new("Frame")
	muteRing.Name = "muteRing"
	muteRing.BackgroundTransparency = 1
	muteRing.Visible = false
	muteRing.ZIndex = 56
	local uiCorner = Instance.new("UICorner", muteRing)
	uiCorner.CornerRadius = UDim.new(0, 10)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Parent = muteRing
	muteRing.Parent = u.layer.inst
	local parent7 = b({
		name = "overplay",
		dir = "col",
		gap = 8,
		pad = { 14, 16 },
		bg = "panel",
		bd = 1,
		bdc = "brass55",
		r = 12,
		z = 57,
		w = 330,
		abs = { t = 60, l = 8 },
		button = true,
		hidden = true,
		parent = u.layer
	})
	parent7.inst.Visible = false

	local frame3 = Instance.new("Frame")
	frame3.BorderSizePixel = 0
	frame3.Size = UDim2.fromOffset(12, 12)
	frame3.Rotation = 45
	frame3.ZIndex = 56
	frame3.Visible = false
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Parent = frame3
	frame3.Parent = u.layer.inst

	local v22 = t({ t = "Whoa, that's fast!", f = "s600_16", lh = 23.2, parent = parent7 })
	local v23 = t({
		t = "Playing this fast can drown out everyone else, so we turned on Mute all for you. Now you can play as fast as you like without bothering anyone: other players don't hear you, and you don't hear them.",
		f = "s400_14_08",
		lh = l145(14.08),
		wrap = true,
		parent = parent7
	})
	t({
		runs = {
			{ t = "To play with everyone again, press " },
			{ t = "the glowing button", c = "brassInk" },
			{ t = " above." }
		},
		f = "s400_14_08",
		lh = l145(14.08),
		wrap = true,
		parent = parent7
	})
	local v24 = note("You'll only see this message once.")
	parent7:add(v24)
	local v25 = btn("Got it", "primary")
	parent7:add(v25)
	v25.self = "end"
	local v26 = false
	local function hideNote() -- 1 equivalent call inferred from this helper
		v26 = false
		parent7:show(false)
		muteRing.Visible = false
		frame3.Visible = false
	end
	v25:onClick(hideNote)
	overplay.OnClientEvent:Connect(function(p2)
		local v27

		if type(p2) == "table" then
			v27 = p2.warn == true
		else
			v27 = false
		end

		if v27 then
			if f.closePopup then
				f.closePopup()
			end

			local parent8 = openDialog("Warning from an admin")
			parent8.title.c = "bad"
			parent8.title:paint()
			local parent9 = b({ dir = "col", gap = 12, parent = parent8 })
			t({
				runs = {
					{ t = tostring(p2.by), c = "ink" },
					{
						t = " says you're overplaying: smashing the keys as fast as you can over everyone else's music. That isn't playing the piano, and nobody here enjoys listening to it. So Mute all is on now: other players don't hear you, and you don't hear them."
					}
				},
				f = "s400_14_08",
				lh = l145(14.08),
				wrap = true,
				parent = parent9
			})
			t({
				t = "Do it again and " .. tostring(p2.by) .. " may ban you from this server.",
				f = "s600_14_08",
				lh = l145(14.08),
				c = "bad",
				wrap = true,
				parent = parent9
			})

			local v28 = btn("OK", "primary")
			parent9:add(v28)
			v28.self = "end"
			v28:onClick(f.closeDialog)
		end

		v22:show(not v27)
		v23:show(not v27)
		v24:show(not v27)

		if f.setMuteAll then
			f.setMuteAll(true)
		end

		v26 = true
		parent7:show(true)
		lay.dirty()
	end)
	RunService.RenderStepped:Connect(function()
		if not v26 then
			return
		end

		if p.muteAll then
			local th = lay.TH
			local v27 = math.max(u.layerScale.Scale, 0.01)
			local absolutePosition = u.layer.inst.AbsolutePosition
			local inst = u.muteBtn.inst
			local lw = u.layer.lw or 1280
			local lw2 = parent7.lw or 330
			local visible = inst.Visible

			if visible then
				if inst.AbsoluteSize.X > 0 then
					visible = not p.fullscreen
				else
					visible = false
				end
			end

			local v28 = (inst.AbsolutePosition.X - absolutePosition.X) / v27
			local v29 = (inst.AbsolutePosition.Y - absolutePosition.Y) / v27
			local v30 = inst.AbsoluteSize.X / v27
			local v31 = inst.AbsoluteSize.Y / v27
			muteRing.Visible = visible
			frame3.Visible = visible
			local v32 = (lw - lw2) / 2
			local v41

			if visible then
				muteRing.Position = UDim2.fromOffset(v28 - 4, v29 - 4)
				muteRing.Size = UDim2.fromOffset(v30 + 8, v31 + 8)
				uiStroke.Color = th.brass.c
				uiStroke.Transparency = (math.sin(os.clock() * 5) * 0.5 + 0.5) * 0.45 + 0.15
				v32 = math.clamp(v28 + v30 / 2 - lw2 / 2, 8, (math.max(8, lw - lw2 - 8)))
				v41 = v29 + v31 + 14
				frame3.Position = UDim2.fromOffset(math.floor(v28 + v30 / 2 - 6 + 0.5), (math.floor(v41 - 6 + 0.5)))
				frame3.BackgroundColor3 = th.panel.c
				uiStroke2.Color = th.brass55.c
			else
				v41 = 60
			end

			local abs = parent7.abs

			if math.abs((abs.l or 0) - v32) > 0.5 or math.abs((abs.t or 0) - v41) > 0.5 then
				parent7.abs = { l = v32, t = v41 }
				lay.dirty()
			end
		else
			hideNote() -- inferred equivalent call
		end
	end)
end