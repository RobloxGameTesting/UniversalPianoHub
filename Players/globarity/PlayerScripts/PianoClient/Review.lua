return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local lay = data.Lay
	local lp = data.LP
	local api = data.api
	local btn = data.btn
	local smallBtn = data.smallBtn
	local note = data.note
	local tag = data.tag
	local openDialog = data.openDialog
	local input = data.input
	local field = data.field
	local statusLine = data.statusLine
	local toast = data.toast
	local l145 = data.L145
	local levelRun = data.levelRun
	local levelPicker = data.levelPicker
	local viewport = data.viewport
	local loadSheet = data.loadSheet
	local isAdmin = data.isAdmin
	local notes = data.Notes
	local levels = data.Levels
	local comm = data.COMM
	local glyph = data.Glyph
	local p = data.P
	local s = data.S

	local v = {}
	local v2 = {}
	local v3 = {
		items = nil,
		at = 0,
		page = 1,
		sort = "hints",
		sel = {},
		texts = {},
		cur = nil,
		loaded = nil,
		count = 0
	}

	local v4 = {
		{
			"Copied notes",
			"These notes are the same as a song that's already in the library. How did you make this sheet? Write your answer as the first line of the notes, starting with // (for example: // I pressed Edit on Happy Birthday). Then paste your song's own notes below it and submit again."
		},
		{ "Too short", "This is too short to be a song. Paste the notes of the whole song and submit again." },
		{
			"Random keys",
			"These notes look like random keys, not a song. Paste the real notes of your song and submit again."
		},
		{
			"Real name",
			"Give the sheet the song's real name (you can add the artist or the game it's from), then submit again."
		},
		{ "Difficulty", "The difficulty doesn't fit this song. Pick the level that matches it and submit again." },
		{
			"Already in library",
			"This song is already in the library. Play that one, or make your own arrangement and say what's different in the title."
		}
	}
	local v5 = {
		{ "hints", "By problem" },
		{ "old", "Oldest" },
		{ "new", "Newest" },
		{ "short", "Shortest" },
		{ "name", "By name" }
	}

	for k, v6 in {
		{ "lib", "Same notes as a sheet in the library" },
		{ "copy", "Same notes as another sheet in the queue" },
		{ "mash", "Keys pressed in a row along the keyboard" },
		{ "short", "Very few notes" },
		{ "name", "Default name" },
		{ "title", "Name already in the library" },
		{ "none", "No problems found" }
	} do
		v[v6[1]] = k
		v2[v6[1]] = v6[2]
	end

	local function groupOf(p2)
		local v6 = v.none
		local v7 = "none"

		for _, v8 in p2.flags or {} do
			local v9 = v[v8.k]

			if not (v9 and v9 < v6) then
				continue
			end

			v7 = v8.k
			v6 = v9
		end

		return v7
	end

	local function sortItems() -- 2 equivalent calls inferred from this helper
		local items = v3.items

		if not items then
			return
		end

		local sort = v3.sort
		table.sort(items, function(a, b2)
			if sort == "hints" then
				local v6 = v[groupOf(a)]
				local v7 = v[groupOf(b2)]

				if v6 ~= v7 then
					return v6 < v7
				end

				local title = string.lower((tostring(a.title)))
				local title2 = string.lower((tostring(b2.title)))

				if title ~= title2 then
					return title < title2
				end
			else
				if sort == "new" then
					return (tonumber(a.at) or 0) > (tonumber(b2.at) or 0)
				end

				if sort == "short" then
					local steps = tonumber(a.steps) or 0
					local steps2 = tonumber(b2.steps) or 0

					if steps ~= steps2 then
						return steps < steps2
					end
				elseif sort == "name" then
					local title = string.lower((tostring(a.title)))
					local title2 = string.lower((tostring(b2.title)))

					if title ~= title2 then
						return title < title2
					end
				end
			end

			local vip = a.vip == true

			if vip == (b2.vip == true) then
				return (tonumber(a.at) or 0) < (tonumber(b2.at) or 0)
			end

			return vip
		end)
	end
	local function paintCount() -- 3 equivalent calls inferred from this helper
		local count = v3.count
		u.reviewBtn.label:setText(not (count > 0) and "Review sheets" or "Review sheets · " .. count)
		u.reviewBtn.label.c = count > 0 and "brassInk" or "muted"
		u.reviewBtn.label:paint()
		lay.dirty()
	end

	function f.refreshReview()
		if isAdmin() then
			task.spawn(function()
				local count = api("pendingCount")

				if type(count) ~= "number" then
					return
				end

				v3.count = count
				paintCount() -- inferred equivalent call
				u.reviewBtn:show(true)
				lay.dirty()
			end)
			return
		end

		u.reviewBtn:show(false)
		lay.dirty()
	end
	local function loadQueue(): boolean
		local items = api("pending")

		if type(items) ~= "table" then
			return false
		end

		v3.items = items
		v3.at = os.clock()
		v3.count = #items
		local idSet = {}

		for _, v6 in items do
			idSet[v6.id] = true
		end

		for k in v3.sel do
			if not idSet[k] then
				v3.sel[k] = nil
			end
		end

		sortItems() -- inferred equivalent call
		paintCount() -- inferred equivalent call
		return true
	end

	local function drop(p2)
		if v3.items then
			for k, item in v3.items do
				if item.id == p2.id then
					table.remove(v3.items, k)
					break
				end
			end
		end

		v3.sel[p2.id] = nil
		v3.texts[p2.id] = nil
		v3.count = math.max(0, v3.count - 1)
		paintCount() -- inferred equivalent call
	end
	local function fullText(p2)
		local text = v3.texts[p2.id]

		if text then
			return text
		end

		local v6 = api("pendingText", p2.id)

		if type(v6) ~= "string" then
			return nil
		end

		v3.texts[p2.id] = v6
		return v6
	end

	local function answer(p2, approve: boolean, reason: string?)
		local v6, v7 = api("review", { id = p2.id, approve = approve, reason = reason })

		if v6 or v7 == "This sheet was already reviewed." then
			drop(p2)
		end

		if v6 or v7 ~= "This sheet was already reviewed." then
			return v6 == true, v7
		end

		return true, "Another admin already answered this one."
	end

	local function metaRuns(data2)
		local result = {
			{
				t = (tonumber(data2.steps) or 0) .. " steps · " .. (not tonumber(data2.bpm) and "no BPM · " or data2.bpm .. " BPM · ")
			}
		}
		local v6 = levelRun(data2.level)

		if v6 then
			for _, v7 in v6 do
				table.insert(result, v7)
			end

			table.insert(result, { t = " · " })
		end

		table.insert(result, {
			t = "by " .. tostring(data2.authorName) .. " (" .. tostring(data2.author) .. ")"
		})

		if data2.replaceId then
			table.insert(result, { t = " · update of a published sheet", c = "brassInk" })
		end

		return result
	end

	local function cut(head: string, p2: number) -- 1 equivalent call inferred from this helper
		if #head <= p2 then
			return head
		end

		return string.gsub(string.sub(head, 1, p2), "[\192-\255][\128-\191]*$", "") .. " …"
	end

	local function reasonPicker(parent, p2: string)
		local _, v6 = input(field(parent, p2), "e.g. Wrong notes in the second half")
		local v7 = b({
			dir = "row",
			wrap = true,
			gap = 6,
			rowGap = 6,
			parent = parent
		})

		for _, v8 in v4 do
			smallBtn(v7, v8[1]):onClick(function()
				v6.Text = v8[2]
			end)
		end

		return v6
	end

	local function nTicked() -- 3 equivalent calls inferred from this helper
		local count = 0

		for _ in v3.sel do
			count += 1
		end

		return count
	end

	local fn

	local function card(parent, item, fn2)
		local v6 = v3.sel[item.id] == true
		local parent2 = b({
			dir = "col",
			gap = 6,
			pad = { 10, 12 },
			bg = "panel2",
			bd = 1,
			bdc = v6 and "brass50" or "line",
			r = 10,
			parent = parent
		})
		local parent3 = b({ dir = "row", align = "center", gap = 6, parent = parent2 })

		if item.vip == true then
			tag(parent3, "vip", "host")
		end

		if (tonumber(item.dup) or 1) > 1 then
			tag(parent3, "sent " .. item.dup .. " times", "host")
		end

		t({
			t = tostring(item.title),
			f = "s500_14_08",
			lh = l145(14.08),
			ell = true,
			shrink0 = true,
			parent = parent3
		})
		t({
			runs = metaRuns(item),
			f = "m400_10_88",
			c = "muted",
			ell = true,
			parent = parent2
		})

		if item.flags then
			local v7 = b({
				dir = "row",
				wrap = true,
				gap = 5,
				rowGap = 5,
				parent = parent2
			})

			for _, flag in item.flags do
				tag(v7, tostring(flag.t), flag.k ~= "title" and "bad" or nil)
			end
		end

		t({
			t = cut(tostring(item.head or ""), 120), -- inferred equivalent call
			f = "s400_12_8",
			lh = l145(12.8),
			c = "muted",
			wrap = true,
			breakAll = true,
			parent = parent2
		})
		local v7 = statusLine(parent2)
		local parent4 = b({
			dir = "row",
			wrap = true,
			gap = 8,
			align = "center",
			parent = parent2
		})
		local v8 = btn("Play")
		parent4:add(v8)
		local v9 = btn("Edit")
		parent4:add(v9)
		local v10 = btn("Approve", "primary")
		parent4:add(v10)
		local v11 = btn("Reject", "danger")
		parent4:add(v11)
		b({ grow = 1, parent = parent4 })
		local v12 = smallBtn(parent4, v6 and "Ticked" or "Tick", v6 and "brassInk" or "muted")

		if v6 then
			v12.bdc = "brass50"
			v12.bg = "brassSoft"
			v12:paint()
		end

		v12:onClick(function()
			if not v6 and nTicked() >= 50 then -- inferred equivalent call
				toast(50 .. " at a time.")
				return
			end

			v3.sel[item.id] = not v6 or nil
			fn2()
		end)
		v8:onClick(function()
			f.reviewStart(item)
		end)
		v9:onClick(function()
			fn(item, "pending", function()
				f.openReview()
			end)
		end)
		v10:onClick(function()
			v7("Publishing…")
			local v13, v14 = answer(item, true)

			if not v13 then
				v7(v14 or "Couldn't publish.", true)
				return
			end

			toast(v14 or "Published.")
			fn2()
		end)
		local v13 = nil
		v11:onClick(function()
			if v13 then
				return
			end

			v13 = b({ dir = "col", gap = 6, parent = parent2 })
			local v14 = reasonPicker(v13, "Reason (it replaces the notes in the author's sheet)")
			local v15 = btn("Send rejection", "danger")
			v13:add(v15)
			v15.self = "start"
			v15:onClick(function()
				if string.gsub(v14.Text, "%s", "") == "" then
					v7("Write the reason.", true)
					return
				end

				v7("Sending…")
				local v16, v17 = answer(item, false, v14.Text)

				if not v16 then
					v7(v17 or "Couldn't reject.", true)
					return
				end

				toast(v17 or "Rejected.")
				fn2()
			end)
			lay.dirty()
			task.defer(function()
				v14:CaptureFocus()
			end)
		end)
	end

	function f.openReview(flag: boolean?)
		local parent = openDialog("Sheets to review", true, 760)
		local parent2 = b({
			dir = "row",
			wrap = true,
			align = "center",
			gap = 6,
			rowGap = 6,
			parent = parent
		})
		local parent3 = b({
			scroll = true,
			dir = "col",
			gap = 8,
			grow = 1,
			vshrink = true,
			minH = 60,
			parent = parent
		})
		local parent4 = b({ dir = "col", gap = 8, parent = parent })
		local function toTop() -- 4 equivalent calls inferred from this helper
			local inst = parent3.inst

			if inst and inst:IsA("ScrollingFrame") then
				inst.CanvasPosition = Vector2.zero
			end
		end

		local function fn2()
			if u.dialog ~= parent then
				return
			end

			parent2:clear()
			parent3:clear()
			parent4:clear()
			local items = v3.items or {}
			parent2:add(t({
				t = "Sort",
				f = "m500_10_24",
				up = true,
				ls = 1.024,
				c = "muted"
			}))

			for _, v6 in v5 do
				local v7 = v3.sort == v6[1]
				local v8 = smallBtn(parent2, v6[2], v7 and "brassInk" or "muted")

				if v7 then
					v8.bdc = "brass50"
					v8.bg = "brassSoft"
					v8:paint()
				end

				v8:onClick(function()
					v3.sort = v6[1]
					v3.page = 1
					sortItems() -- inferred equivalent call
					fn2()
					toTop() -- inferred equivalent call
				end)
			end

			b({ grow = 1, parent = parent2 })
			smallBtn(parent2, "Refresh"):onClick(function()
				parent3:clear()
				parent3:add(note("Loading…"))
				lay.dirty()
				task.spawn(function()
					loadQueue()
					fn2()
				end)
			end)

			if #items == 0 then
				parent3:add(note("Nothing to review right now."))
			end

			local v6 = math.max(1, (math.ceil(#items / 10)))
			v3.page = math.clamp(v3.page, 1, v6)

			local v7 = {}

			if v3.sort == "hints" then
				for _, item in items do
					local v8 = groupOf(item)
					v7[v8] = (v7[v8] or 0) + 1
				end
			end

			local v8 = nil

			for i = (v3.page - 1) * 10 + 1, math.min(#items, v3.page * 10) do
				local item = items[i]

				if v3.sort == "hints" then
					local v9 = groupOf(item)

					if v9 ~= v8 then
						local v10 = b({
							dir = "row",
							align = "center",
							gap = 8,
							pad = { 6, 2, 0, 2 },
							parent = parent3
						})
						v10:add(t({
							t = string.upper(v2[v9]) .. "  ·  " .. tostring(v7[v9]),
							f = "m500_10_24",
							ls = 1.024,
							c = v9 == "none" and "ok" or "bad",
							ell = true,
							shrink0 = true,
							grow = 1
						}))
						smallBtn(v10, "Tick all " .. math.min(v7[v9], 50)):onClick(function()
							local count = nTicked() -- inferred equivalent call

							for _, item2 in items do
								if count >= 50 then
									break
								end

								if groupOf(item2) ~= v9 or v3.sel[item2.id] then
									continue
								end

								v3.sel[item2.id] = true
								count += 1
							end

							if count >= 50 then
								toast(50 .. " at a time.")
							end

							fn2()
						end)
						v8 = v9
					end
				end

				card(parent3, item, fn2)
			end

			if v6 > 1 then
				local v9 = b({
					dir = "row",
					align = "center",
					justify = "center",
					gap = 10,
					parent = parent4
				})
				local v10 = smallBtn(v9, "<<")
				local v11 = smallBtn(v9, "<")
				v9:add(t({
					t = "PAGE " .. v3.page .. " / " .. v6 .. "  ·  " .. #items .. " SHEETS",
					f = "m500_10_24",
					ls = 1.024,
					c = "muted"
				}))
				local v12 = smallBtn(v9, ">")
				v10:onClick(function()
					if v3.page > 1 then
						v3.page = 1
						fn2()
						toTop() -- inferred equivalent call
					end
				end)
				v11:onClick(function()
					if v3.page > 1 then
						v3.page -= 1
						fn2()
						toTop() -- inferred equivalent call
					end
				end)
				v12:onClick(function()
					if v3.page < v6 then
						v3.page += 1
						fn2()
						toTop() -- inferred equivalent call
					end
				end)
			end

			local count = nTicked() -- inferred equivalent call

			if count > 0 then
				local parent5 = b({
					dir = "col",
					gap = 6,
					pad = { 10, 12 },
					bg = "badSoft",
					bd = 1,
					bdc = "line",
					r = 10,
					parent = parent4
				})
				local parent6 = b({ dir = "row", align = "center", gap = 8, parent = parent5 })
				parent6:add(t({
					t = count .. " ticked",
					f = "s500_14_08",
					lh = l145(14.08)
				}))
				b({ grow = 1, parent = parent6 })
				smallBtn(parent6, "Untick all"):onClick(function()
					table.clear(v3.sel)
					fn2()
				end)

				local v9 = b({
					dir = "row",
					align = "center",
					gap = 10,
					wrap = true,
					parent = parent5
				})
				local v10 = btn("Approve " .. count .. " ticked", "primary")
				v9:add(v10)
				v10.noShrink = true
				local v11 = statusLine(v9)
				local flag2 = false
				local flag3 = false
				v10:onClick(function()
					if flag3 then
						return
					end

					if flag2 then
						flag2 = false
						flag3 = true
						local ids = {}

						for k in v3.sel do
							table.insert(ids, k)
						end

						v11("Publishing " .. #ids .. "…")
						local v12, v13 = api("approveMany", { ids = ids })
						flag3 = false

						if not v12 then
							v11(tostring(v13 or "Couldn't publish."), true)
							return
						end

						local v14

						if type(v13) == "table" then
							v14 = tonumber(v13.done) or 0
						else
							v14 = #ids
						end

						local back = type(v13) == "table" and tonumber(v13.back) or 0

						for _, id in ids do
							drop({ id = id })
						end

						table.clear(v3.sel)
						toast("Published " .. v14 .. (not (back > 0) and "" or " (" .. back .. " couldn't be read and stay in the queue)") .. ".")
						f.refreshReview()

						if back > 0 then
							task.spawn(function()
								loadQueue()
								fn2()
							end)
						else
							fn2()
						end

						task.spawn(function()
							f.loadCommunity(true)
							f.renderLib()
						end)
					else
						flag2 = true
						v10.label:setText("Click again to publish " .. count)
						task.delay(3, function()
							if flag2 then
								flag2 = false
								v10.label:setText("Approve " .. count .. " ticked")
							end
						end)
					end
				end)
				local v12 = reasonPicker(parent5, "One reason for all of them")
				local v13 = statusLine(parent5)
				local v14 = btn("Reject " .. count .. " ticked", "danger")
				parent5:add(v14)
				v14.self = "start"
				v14:onClick(function()
					if string.gsub(v12.Text, "%s", "") == "" then
						v13("Write the reason.", true)
						return
					end

					local ids = {}

					for k in v3.sel do
						table.insert(ids, k)
					end

					v13("Sending " .. #ids .. " rejections…")
					local v15, v16 = api("rejectMany", { ids = ids, reason = v12.Text })

					if not v15 then
						v13(tostring(v16 or "Couldn't reject."), true)
						return
					end

					for _, id in ids do
						drop({ id = id })
					end

					table.clear(v3.sel)
					toast("Rejected " .. tostring(v16) .. ".")
					f.refreshReview()
					fn2()
				end)
			end

			lay.dirty()
		end

		if v3.items and not flag and os.clock() - v3.at < 60 then
			fn2()
		else
			parent3:add(note("Loading…"))
			task.spawn(function()
				if loadQueue() then
					fn2()
				elseif u.dialog == parent then
					parent3:clear()
					parent3:add(note("Couldn't load the queue."))
					lay.dirty()
				end
			end)
		end
	end
	u.reviewBtn:onClick(function()
		f.openReview()
	end)

	fn = function(state, p2: string, callback)
		local v6 = p2 == "pub"
		local parent = openDialog(v6 and "Edit published sheet" or "Edit before review", true)
		parent:add(note(
			"by " .. tostring(state.authorName) .. ". " .. (v6 and "Saving changes it in the library for everyone (favourites and ratings stay) and in the author's own copy." or "Your changes are published when you press Approve, and the author's sheet gets them too."),
			{ lh = l145(12.8) }
		))
		local v7 = b({ dir = "row", gap = 10, parent = parent })
		local _, v8 = input(field(v7, "Title", true), "Title")
		v8.Text = tostring(state.title or "")
		local v9 = field(v7, "BPM")
		v9.w = 92
		local _, v10 = input(v9, "1–500")
		v10.Text = not tonumber(state.bpm) and "" or tostring(state.bpm)
		local level

		if levels.valid(state.level) then
			level = state.level
		else
			level = nil
		end

		levelPicker(field(parent, "Difficulty"), level, function(p3)
			level = p3
		end)
		local _, v11 = input(field(parent, "Notes", true), "", {
			multi = true,
			grow = true,
			h = math.max(120, 0.34 * select(2, viewport()))
		})
		v11.Text = ""
		v11.PlaceholderText = "Loading…"
		local v12 = false
		task.spawn(function()
			local v13

			if v6 then
				v13 = comm.texts[state.id] or api("communitySheet", state.id)
			else
				local v14 = state
				v13 = v3.texts[v14.id]

				if not v13 then
					v13 = api("pendingText", v14.id)

					if type(v13) == "string" then
						v3.texts[v14.id] = v13
					else
						v13 = nil
					end
				end
			end

			if u.dialog ~= parent then
				return
			end

			v11.Text = type(v13) ~= "string" and "" or v13
			v11.PlaceholderText = type(v13) == "string" and "" or "Couldn't load the notes."
			v12 = type(v13) == "string"
		end)
		local v13 = statusLine(parent)
		local v14 = b({ dir = "row", wrap = true, gap = 8, parent = parent })
		local v15 = btn("Save changes", "primary")
		v14:add(v15)
		local v16 = btn(callback and "Back" or "Cancel")
		v14:add(v16)
		v16:onClick(function()
			if callback then
				callback()
			else
				f.closeDialog()
			end
		end)
		local flag = false
		v15:onClick(function()
			if flag then
				return
			end

			if not v12 then
				v13("The notes are still loading.", true)
				return
			end

			local text = tonumber(v10.Text)
			local text2 = v11.Text
			flag = true
			v13("Saving…")
			local v17, v18 = api(v6 and "editPublished" or "editPending", {
				id = state.id,
				title = v8.Text,
				text = text2,
				level = level,
				bpm = text
			})
			flag = false

			if not v17 then
				v13(tostring(v18 or "Couldn't save."), true)
			elseif v6 then
				comm.texts[state.id] = nil
				f.closeDialog()
				toast("Saved. The library has the new version.")
				task.spawn(function()
					f.loadCommunity(true)
					f.renderLib()
				end)
			else
				local text3 = v8.Text
				local level2 = level
				state.title = text3
				state.level = level2
				state.bpm = text
				state.edited = true
				state.steps = #notes.parse(text2)
				state.head = string.sub(text2, 1, 200)
				v3.texts[state.id] = text2
				toast("Saved. Approve it to publish.")

				if callback then
					callback()
				else
					f.closeDialog()
				end
			end
		end)
	end
	function f.editPending(p2)
		fn(p2, "pending", function()
			f.openReview()
		end)
	end

	function f.adminEdit(p2)
		fn(p2, "pub")
	end

	local playerGui = lp:WaitForChild("PlayerGui")
	local reviewBar = Instance.new("ScreenGui")
	reviewBar.Name = "ReviewBar"
	reviewBar.IgnoreGuiInset = true
	reviewBar.ScreenInsets = Enum.ScreenInsets.None
	reviewBar.ResetOnSpawn = false
	reviewBar.DisplayOrder = 19
	reviewBar.Enabled = false
	reviewBar.Parent = playerGui

	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.AnchorPoint = Vector2.new(0.5, 1)
	bar.Size = UDim2.fromOffset(640, 0)
	bar.AutomaticSize = Enum.AutomaticSize.Y
	bar.BorderSizePixel = 0
	bar.Active = true
	bar.Parent = reviewBar
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = bar
	local uiCorner = Instance.new("UICorner", bar)
	uiCorner.CornerRadius = UDim.new(0, 12)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = bar
	local uiPadding = Instance.new("UIPadding")
	local udim = UDim.new(0, 10)
	local udim2 = UDim.new(0, 10)
	uiPadding.PaddingTop = udim
	uiPadding.PaddingBottom = udim2
	local udim3 = UDim.new(0, 12)
	local udim4 = UDim.new(0, 12)
	uiPadding.PaddingLeft = udim3
	uiPadding.PaddingRight = udim4
	uiPadding.Parent = bar
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 5)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = bar

	local v6 = {}
	local function label(parent, p2: string, p3: string, layoutOrder: number, flag: boolean?)
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.FontFace = glyph.nativeFont(p2)
		textLabel.TextSize = glyph.nativeSize(p2)
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextWrapped = flag == true
		local textTruncate

		if flag then
			textTruncate = Enum.TextTruncate.None
		else
			textTruncate = Enum.TextTruncate.AtEnd
		end

		textLabel.TextTruncate = textTruncate
		textLabel.Size = UDim2.new(1, 0, 0, flag and 0 or textLabel.TextSize + 4)
		local automaticSize

		if flag then
			automaticSize = Enum.AutomaticSize.Y
		else
			automaticSize = Enum.AutomaticSize.None
		end

		textLabel.AutomaticSize = automaticSize
		textLabel.LayoutOrder = layoutOrder
		textLabel.Text = ""
		textLabel.Parent = parent
		v6[textLabel] = p3
		return textLabel
	end

	local function row(layoutOrder: number, value: number?)
		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(1, 0, 0, value or 0)
		local automaticSize

		if value then
			automaticSize = Enum.AutomaticSize.None
		else
			automaticSize = Enum.AutomaticSize.Y
		end

		frame.AutomaticSize = automaticSize
		frame.LayoutOrder = layoutOrder
		frame.Parent = bar
		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout2.Wraps = true
		uiListLayout2.Padding = UDim.new(0, 6)
		uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.Parent = frame
		return frame
	end

	local v7 = {}
	local function nbtn(parent, text: string, p2: string, layoutOrder: number, flag: boolean?)
		local textButton = Instance.new("TextButton")
		local v8 = flag and "s400_11_84" or "s500_13_6"
		textButton.FontFace = glyph.nativeFont(v8)
		textButton.TextSize = glyph.nativeSize(v8)
		textButton.Text = text
		textButton.AutoButtonColor = true
		textButton.AutomaticSize = Enum.AutomaticSize.X
		textButton.Size = UDim2.fromOffset(0, flag and 24 or 30)
		textButton.LayoutOrder = layoutOrder
		local uiCorner = Instance.new("UICorner", textButton)
		uiCorner.CornerRadius = UDim.new(0, 7)
		local uiPadding2 = Instance.new("UIPadding")
		local udim5 = UDim.new(0, flag and 8 or 12)
		local udim6 = UDim.new(0, flag and 8 or 12)
		uiPadding2.PaddingLeft = udim5
		uiPadding2.PaddingRight = udim6
		uiPadding2.Parent = textButton
		local uiStroke2 = Instance.new("UIStroke")
		uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke2.Parent = textButton
		textButton.Parent = parent
		v7[textButton] = p2
		return textButton
	end

	local v8 = row(1)
	local v9 = label(v8, "m500_10_24", "brassInk", 1)
	v9.Size = UDim2.fromOffset(0, 16)
	v9.AutomaticSize = Enum.AutomaticSize.X
	local v10 = label(v8, "s600_14_08", "ink", 2)
	v10.Size = UDim2.new(1, -150, 0, 20)
	local v11 = label(bar, "m400_10_88", "muted", 2)
	local v12 = label(bar, "s400_12_8", "bad", 3, true)
	local v13 = label(bar, "s400_12_8", "muted", 4, true)
	local v14 = row(5)
	local v15 = nbtn(v14, "Approve", "primary", 1)
	local v16 = nbtn(v14, "Reject…", "danger", 2)
	local v17 = nbtn(v14, "Edit", "plain", 3)
	local v18 = nbtn(v14, "Skip", "plain", 4)
	local v19 = nbtn(v14, "Queue", "plain", 5)
	local v20 = nbtn(v14, "End review", "plain", 6)

	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.LayoutOrder = 6
	frame.Visible = false
	frame.Parent = bar
	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.Padding = UDim.new(0, 6)
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Parent = frame
	local textBox = Instance.new("TextBox")
	textBox.ClearTextOnFocus = false
	textBox.Text = ""
	textBox.PlaceholderText = "Reason (it replaces the notes in the author's sheet)"
	textBox.FontFace = glyph.nativeFont("s400_13_12")
	textBox.TextSize = glyph.nativeSize("s400_13_12")
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.TextWrapped = true
	textBox.Size = UDim2.new(1, 0, 0, 34)
	textBox.AutomaticSize = Enum.AutomaticSize.Y
	textBox.LayoutOrder = 1
	local uiCorner_2 = Instance.new("UICorner", textBox)
	uiCorner_2.CornerRadius = UDim.new(0, 7)
	local uiPadding2 = Instance.new("UIPadding")
	local udim5 = UDim.new(0, 10)
	local udim6 = UDim.new(0, 10)
	local udim7 = UDim.new(0, 7)
	local udim8 = UDim.new(0, 7)
	uiPadding2.PaddingLeft = udim5
	uiPadding2.PaddingRight = udim6
	uiPadding2.PaddingTop = udim7
	uiPadding2.PaddingBottom = udim8
	uiPadding2.Parent = textBox
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke2.Parent = textBox
	textBox.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.BackgroundTransparency = 1
	frame2.Size = UDim2.new(1, 0, 0, 0)
	frame2.AutomaticSize = Enum.AutomaticSize.Y
	frame2.LayoutOrder = 2
	frame2.Parent = frame
	local uiListLayout3 = Instance.new("UIListLayout")
	uiListLayout3.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout3.Wraps = true
	uiListLayout3.Padding = UDim.new(0, 6)
	uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout3.Parent = frame2

	for k, v21 in v4 do
		nbtn(frame2, v21[1], "plain", k, true).Activated:Connect(function()
			textBox.Text = v21[2]
		end)
	end

	local v21 = nbtn(frame, "Send rejection", "danger", 3)

	local function paint()
		local th = lay.TH
		bar.BackgroundColor3 = th.panel2.c
		bar.BackgroundTransparency = 0
		uiStroke.Color = th.brass.c
		uiStroke.Transparency = 0.45

		for k, v22 in v6 do
			k.TextColor3 = (th[v22] or th.ink).c
		end

		local function col(p2: string, p3: string) -- 7 equivalent calls inferred from this helper
			return (th[p2] or th[p3]).c
		end

		for k, v22 in v7 do
			local uiStroke3 = k:FindFirstChildOfClass("UIStroke")

			if v22 == "primary" then
				k.BackgroundColor3 = col("ink", "ink") -- inferred equivalent call
				k.TextColor3 = col("bg", "panel") -- inferred equivalent call
				uiStroke3.Color = col("ink", "ink") -- inferred equivalent call
			else
				k.BackgroundColor3 = col("panel", "panel2") -- inferred equivalent call
				local textColor

				if v22 == "danger" then
					textColor = col("bad", "ink") -- inferred equivalent call
				else
					textColor = col("ink", "ink") -- inferred equivalent call
				end

				k.TextColor3 = textColor
				uiStroke3.Color = col("line", "panel2") -- inferred equivalent call
			end
		end

		textBox.BackgroundColor3 = (th.field or th.panel2).c
		textBox.TextColor3 = th.ink.c
		textBox.PlaceholderColor3 = th.muted.c
		uiStroke2.Color = th.line.c
	end

	local function setStatus(text: string, flag: boolean?) -- 2 equivalent calls inferred from this helper
		v13.Text = text
		v6[v13] = flag and "bad" or "muted"
		v13.Visible = text ~= ""

		local success, result = pcall(paint)

		if not success then
			warn("ReviewBar: " .. tostring(result))
		end
	end
	local function indexOf(p2) -- 2 equivalent calls inferred from this helper
		for k, v22 in v3.items or {} do
			if v22.id == p2.id then
				return k
			end
		end

		return nil
	end

	local function nextOf(cur)
		local items = v3.items or {}
		local k = indexOf(cur) -- inferred equivalent call
		local v22

		if k then
			v22 = items[k + 1]
		end

		local selected = v22 or items[1]

		if selected and selected.id ~= cur.id then
			return selected
		end

		return nil
	end

	local function showInfo(data2)
		local k = indexOf(data2) -- inferred equivalent call
		v9.Text = (not k and "—" or k .. " / " .. #(v3.items or {})) .. "  "
		v10.Text = tostring(data2.title) .. (not ((tonumber(data2.dup) or 1) > 1) and "" or "   (sent " .. data2.dup .. " times)")
		local v22 = levels.get(data2.level)
		v11.Text = (tonumber(data2.steps) or 0) .. " steps · " .. (not tonumber(data2.bpm) and "no BPM" or data2.bpm .. " BPM") .. " · " .. (not v22 and "no difficulty" or v22.name) .. " · by " .. tostring(data2.authorName) .. (data2.replaceId and " · update of a published sheet" or "")
		local ts = {}

		for _, v23 in data2.flags or {} do
			table.insert(ts, (tostring(v23.t)))
		end

		v12.Text = table.concat(ts, "  ·  ")
		v12.Visible = #ts > 0
		frame.Visible = false
		textBox.Text = ""
	end

	local function openCur()
		local cur = v3.cur
		v3.loaded = nil

		if not cur then
			return
		end

		f.closeDialog()
		local success, result = pcall(showInfo, cur)

		if not success then
			warn("ReviewBar: " .. tostring(result))
		end

		v13.Text = "Loading the notes…"
		v6[v13] = "muted"
		v13.Visible = true

		local success2, result2 = pcall(paint)

		if not success2 then
			warn("ReviewBar: " .. tostring(result2))
		end

		task.spawn(function()
			local v22 = cur
			local v23 = v3.texts[v22.id]

			if not v23 then
				v23 = api("pendingText", v22.id)

				if type(v23) == "string" then
					v3.texts[v22.id] = v23
				else
					v23 = nil
				end
			end

			if v3.cur ~= cur then
				return
			end

			if v23 then
				loadSheet(tostring(cur.title), v23, "tmp", (tonumber(cur.bpm)))

				if p.hudOpen == false and f.setHudOpen then
					f.setHudOpen(true)
				end

				v3.loaded = cur
				v13.Text = ""
				v6[v13] = "muted"
				v13.Visible = false

				local success3, result3 = pcall(paint)

				if not success3 then
					warn("ReviewBar: " .. tostring(result3))
				end

				local v24 = nextOf(cur)

				if v24 and not v3.texts[v24.id] then
					task.spawn(fullText, v24)
				end
			else
				v13.Text = "Couldn't load the notes. Press Skip or try again in a moment."
				v6[v13] = "bad"
				v13.Visible = true

				local success3, result3 = pcall(paint)

				if not success3 then
					warn("ReviewBar: " .. tostring(result3))
				end
			end
		end)
	end
	local function goNext(cur) -- 3 equivalent calls inferred from this helper
		v3.cur = cur

		if cur then
			openCur()
		else
			toast(#(v3.items or {}) == 0 and "The queue is empty. Nice work!" or "Review ended.")
		end
	end

	function f.inReview(): boolean
		return v3.cur ~= nil
	end

	function f.reviewStart(cur)
		v3.cur = cur
		openCur()
	end
	local flag = false
	local function act(fn2) -- 2 equivalent calls inferred from this helper
		if flag then
			return
		end

		flag = true
		local success, result = pcall(fn2)
		flag = false

		if not success then
			warn("ReviewBar: " .. tostring(result))
		end
	end
	v15.Activated:Connect(function()
		act(function() -- inferred equivalent call
			local cur = v3.cur

			if not cur then
				return
			end

			v13.Text = "Publishing…"
			v6[v13] = "muted"
			v13.Visible = true

			local success, result = pcall(paint)

			if not success then
				warn("ReviewBar: " .. tostring(result))
			end

			local cur2 = nextOf(cur)
			local v22, v23 = answer(cur, true)

			if v22 then
				toast(v23 or "\"" .. tostring(cur.title) .. "\" published.")
				goNext(cur2) -- inferred equivalent call
			else
				setStatus(v23 or "Couldn't publish.", true) -- inferred equivalent call
			end
		end)
	end)
	v16.Activated:Connect(function()
		frame.Visible = not frame.Visible

		if frame.Visible then
			task.defer(function()
				textBox:CaptureFocus()
			end)
		end
	end)
	v21.Activated:Connect(function()
		act(function() -- inferred equivalent call
			local cur = v3.cur

			if not cur then
				return
			end

			if string.gsub(textBox.Text, "%s", "") == "" then
				v13.Text = "Write the reason or pick one."
				v6[v13] = "bad"
				v13.Visible = true

				local success, result = pcall(paint)

				if not success then
					warn("ReviewBar: " .. tostring(result))
				end
			else
				v13.Text = "Sending…"
				v6[v13] = "muted"
				v13.Visible = true

				local success, result = pcall(paint)

				if not success then
					warn("ReviewBar: " .. tostring(result))
				end

				local cur2 = nextOf(cur)
				local v22, v23 = answer(cur, false, textBox.Text)

				if v22 then
					toast(v23 or "\"" .. tostring(cur.title) .. "\" rejected.")
					goNext(cur2) -- inferred equivalent call
				else
					setStatus(v23 or "Couldn't reject.", true) -- inferred equivalent call
				end
			end
		end)
	end)
	v17.Activated:Connect(function()
		local cur = v3.cur

		if cur then
			fn(cur, "pending", openCur)
		end
	end)
	v18.Activated:Connect(function()
		local cur = v3.cur

		if cur then
			goNext(nextOf(cur)) -- inferred equivalent call
		end
	end)
	v19.Activated:Connect(function()
		f.openReview()
	end)
	v20.Activated:Connect(function()
		v3.cur = nil
		v3.loaded = nil
	end)

	local function keysTop()
		if not (u.kb and u.kb.inst) then
			return nil
		end

		local minY = 1e999
		local minX = 1e999
		local maxValue = -1e999

		for _, v22 in u.kb.kids or {} do
			local inst = v22.inst

			if not (v22 ~= u.stage and inst and inst.Visible and inst.AbsoluteSize.Y > 1) then
				continue
			end

			minY = math.min(minY, inst.AbsolutePosition.Y)
			minX = math.min(minX, inst.AbsolutePosition.X)
			maxValue = math.max(maxValue, inst.AbsolutePosition.X + inst.AbsoluteSize.X)
		end

		if minY == 1e999 then
			return nil
		end

		return minY, minX, maxValue
	end

	local v22 = false
	local function update()
		if v3.cur and v3.loaded == v3.cur and s.activeId ~= "tmp" then
			v3.cur = nil
			v3.loaded = nil
		end

		local enabled

		if v3.cur == nil or u.dialog ~= nil then
			enabled = false
		else
			enabled = not f.vrOn and isAdmin()
		end

		local v23, v24, v25

		if enabled then
			v23, v24, v25 = keysTop()

			if not v23 then
				enabled = false
			end
		end

		if enabled ~= v22 then
			v22 = enabled
			reviewBar.Enabled = enabled
		end

		if not enabled then
			return
		end

		paint()
		local _, _, scale = viewport()
		uiScale.Scale = scale
		local absolutePosition = reviewBar.AbsolutePosition
		local v26 = math.min(640, (math.max(320, (v25 - v24) / scale - 24)))
		bar.Size = UDim2.fromOffset(v26, 0)
		bar.Position = UDim2.fromOffset(
			math.floor((v24 + v25) / 2 - absolutePosition.X),
			(math.floor(v23 - absolutePosition.Y - 10 * scale))
		)
	end
	task.spawn(function()
		while true do
			local success, result = pcall(update)

			if not success then
				warn("ReviewBar: " .. tostring(result))
			end

			task.wait(0.2)
		end
	end)

	lp:GetAttributeChangedSignal("Admin"):Connect(function()
		f.refreshReview()
		f.renderLib()
	end)
	task.spawn(function()
		while true do
			task.wait(90)

			if isAdmin() then
				f.refreshReview()
			end
		end
	end)
end