return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local api = data.api
	local lay = data.Lay
	local lp = data.LP
	local l145 = data.L145
	local btn = data.btn
	local note = data.note
	local openDialog = data.openDialog
	local input = data.input
	local _statusLine = data.statusLine
	local tag = data.tag
	local isAdmin = data.isAdmin
	local enterRoom = data.enterRoom

	local function pills(parent, items, p: string, fn)
		local parent2 = b({
			dir = "row",
			wrap = true,
			gap = 6,
			rowGap = 6,
			parent = parent
		})
		local v = {}
		local function set(p2: string)
			for k, v2 in v do
				v2:state("on", k == p2)
				v2.label.c = k == p2 and "bg" or "muted"
				v2.label:paint()
			end
		end

		for _, item in items do
			local label = t({ t = item[2], f = "s500_13_6", lh = 19.72, c = "muted" })
			local v2 = b({
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
				{ label }
			})
			v2.label = label
			v[item[1]] = v2
			v2:onClick(function()
				set(item[1])
				fn(item[1])
			end)
		end

		set(p)
		return parent2
	end

	local function toggle(parent, p: string, fn)
		local v = false
		local v2 = t({ t = p, f = "s500_13_6", lh = 19.72, c = "muted" })
		local v3 = b({
			dir = "row",
			pad = { 4, 12 },
			r = "pill",
			bd = 1,
			bdc = "line",
			button = true,
			sty = {
				on = { bg = "brassSoft", bdc = "brass55" }
			},
			parent = parent,
			{ v2 }
		})
		v3:onClick(function()
			v = not v
			v3:state("on", v)
			v2.c = v and "brassInk" or "muted"
			v2:paint()
			fn(v)
		end)
		return v3
	end

	function f.openRoomBrowser()
		f.closePopup()
		local parent = openDialog("Rooms", true, 640)
		local v = {
			q = "",
			access = "any",
			voice = false,
			auto = false,
			space = false,
			sort = "players"
		}

		local v2 = b({ dir = "row", gap = 8, align = "center", parent = parent })
		local _, v3 = input(v2, "Search rooms by name…", { grow = true })
		local v4 = btn("＋ Create room", "primary")
		v2:add(v4)
		v4:onClick(function()
			f.closeDialog()
			f.openRoomDialog()
		end)

		local parent2 = nil
		local v5 = nil
		local v6 = nil
		local count = 0
		local total = 0
		local v7 = 0

		local function row(room, here: string)
			local v8 = room.host == lp.UserId
			local v9 = here == "room_" .. room.host
			local v10 = room.players >= (room.max or 12)
			local parent3 = b({
				dir = "row",
				align = "center",
				gap = 8,
				pad = { 6, 10 },
				r = 8,
				bg = v9 and "brassSoft" or "white05",
				parent = parent2
			})
			local parent4 = b({
				dir = "row",
				align = "center",
				gap = 6,
				grow = 1,
				shrink0 = true,
				parent = parent3
			})
			t({
				t = (room.access == "password" and "🔒 " or "") .. tostring(room.name),
				f = "s500_14_08",
				lh = l145(14.08),
				ell = true,
				parent = parent4
			})

			if room.kind == "podium" then
				tag(parent4, "podium", "host")
			end

			if room.voiceOnly then
				tag(parent4, "voice", "ok")
			end

			if room.allowAuto == false then
				tag(parent4, "no autoplay")
			end

			if v8 then
				tag(parent4, "yours", "host")
			end

			t({
				t = room.players .. " / " .. (room.max or 12),
				f = "m500_11_52",
				c = v10 and "bad" or "muted",
				noShrink = true,
				parent = parent3
			})

			if v9 then
				t({
					t = "You're here",
					f = "s500_13_6",
					lh = 19.72,
					c = "brassInk",
					noShrink = true,
					parent = parent3
				})
				return
			end

			local v11 = btn(
				v10 and not (v8 or isAdmin()) and "Full" or "Join",
				(not v10 or v8 or isAdmin()) and "primary" or nil
			)
			v11.noShrink = true
			parent3:add(v11)
			v11:onClick(function()
				if v10 and not (v8 or isAdmin()) then
					return
				end

				if room.access == "password" and not (v8 or isAdmin()) then
					f.openPassword(room.host, (tostring(room.name)))
				else
					enterRoom(room.host)
				end
			end)
		end

		local function load(flag: boolean?)
			count += 1
			local v8 = count

			if not flag then
				total = 0
				parent2:clear()
				parent2:add(note("Loading…"))
			end

			v6:show(false)
			lay.dirty()
			task.spawn(function()
				local v9 = api("browseRooms", {
					q = v.q,
					access = v.access,
					voice = v.voice,
					auto = v.auto,
					space = v.space,
					sort = v.sort,
					offset = total
				})

				if v8 ~= count or u.dialog ~= parent then
					return
				end

				if not flag then
					parent2:clear()
				end

				if type(v9) == "table" and type(v9.rooms) == "table" then
					v7 = tonumber(v9.total) or 0

					for _, room in v9.rooms do
						row(room, tostring(v9.here))
					end

					total += #v9.rooms

					if total == 0 then
						parent2:add(note((tonumber(v9.all) or 0) == 0 and "No rooms with players right now. Make the first one!" or "No rooms match. Try other filters."))
					end

					v5:setText(not (v7 > 0) and "" or string.format("%d of %d room%s", total, v7, v7 == 1 and "" or "s"))
					v6:show(total < v7)
				else
					parent2:add(note("Couldn't load the rooms. Try again in a minute."))
				end

				lay.dirty()
			end)
		end

		pills(parent, {
			{ "any", "Any access" },
			{ "public", "Open" },
			{ "password", "🔒 Password" }
		}, v.access, function(access)
			v.access = access
			load()
		end)
		local parent3 = b({
			dir = "row",
			wrap = true,
			gap = 6,
			rowGap = 6,
			parent = parent
		})
		toggle(parent3, "Has space", function(space)
			v.space = space
			load()
		end)
		toggle(parent3, "Voice chat", function(voice)
			v.voice = voice
			load()
		end)
		toggle(parent3, "Autoplay allowed", function(auto)
			v.auto = auto
			load()
		end)
		pills(parent, {
			{ "players", "Most players" },
			{ "fewest", "Fewest players" },
			{ "new", "Newest" },
			{ "name", "A–Z" }
		}, v.sort, function(sort)
			v.sort = sort
			load()
		end)

		parent2 = b({
			scroll = true,
			dir = "col",
			gap = 4,
			grow = 1,
			vshrink = true,
			minH = 120,
			parent = parent
		})
		local parent4 = b({
			dir = "row",
			align = "center",
			gap = 8,
			justify = "between",
			parent = parent
		})
		v5 = t({
			t = "",
			f = "s500_13_44",
			lh = l145(13.44),
			c = "muted",
			parent = parent4
		})
		v6 = btn("Show more")
		parent4:add(v6)
		v6:onClick(function()
			count += 1
			local v8 = count

			v6:show(false)
			lay.dirty()
			local v9 = true
			task.spawn(function()
				local v10 = api("browseRooms", {
					q = v.q,
					access = v.access,
					voice = v.voice,
					auto = v.auto,
					space = v.space,
					sort = v.sort,
					offset = total
				})

				if v8 ~= count or u.dialog ~= parent then
					return
				end

				if not v9 then
					parent2:clear()
				end

				if type(v10) == "table" and type(v10.rooms) == "table" then
					v7 = tonumber(v10.total) or 0

					for _, room in v10.rooms do
						row(room, tostring(v10.here))
					end

					total += #v10.rooms

					if total == 0 then
						parent2:add(note((tonumber(v10.all) or 0) == 0 and "No rooms with players right now. Make the first one!" or "No rooms match. Try other filters."))
					end

					v5:setText(not (v7 > 0) and "" or string.format("%d of %d room%s", total, v7, v7 == 1 and "" or "s"))
					v6:show(total < v7)
				else
					parent2:add(note("Couldn't load the rooms. Try again in a minute."))
				end

				lay.dirty()
			end)
		end)

		local count2 = 0
		v3:GetPropertyChangedSignal("Text"):Connect(function()
			count2 += 1
			local v8 = count2
			task.delay(0.4, function()
				if v8 ~= count2 or u.dialog ~= parent then
					return
				end

				v.q = v3.Text
				load()
			end)
		end)
		load()
	end
end