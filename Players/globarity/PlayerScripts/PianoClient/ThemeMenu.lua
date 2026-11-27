return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local lay = data.Lay
	local lp = data.LP
	local themes = data.Themes
	local openMenu = data.openMenu
	local toast = data.toast

	local function c(p) -- 6 equivalent calls inferred from this helper
		return { c = p.c, a = 1 }
	end

	local function dress(p, theme, p2: number)
		local tex = theme.tex

		if not tex then
			return
		end

		local panel = tex.roles.panel or tex.roles.bg
		local v = type(panel) == "number" and { a = panel } or panel

		if type(v) ~= "table" then
			return
		end

		local resampleMode

		if tex.pixel then
			resampleMode = Enum.ResamplerMode.Pixelated
		else
			resampleMode = Enum.ResamplerMode.Default
		end

		local img = v.img or tex.image

		if img and img ~= "" then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = img
			imageLabel.ScaleType = Enum.ScaleType.Tile
			local v2 = math.min(v.size or tex.size or 64, 160)
			imageLabel.TileSize = UDim2.fromOffset(v2, v2)
			imageLabel.ResampleMode = resampleMode

			if v.tint == false then
				imageLabel.ImageColor3 = Color3.new(1, 1, 1)
			else
				local lift = v.lift or tex.lift or 1
				local c2 = theme.panel.c
				imageLabel.ImageColor3 = Color3.new(
					math.min(1, c2.R * lift),
					math.min(1, c2.G * lift),
					(math.min(1, c2.B * lift))
				)
			end

			imageLabel.ImageTransparency = 1 - (v.a or 1)

			imageLabel.Position = UDim2.fromOffset(p2, p2)
			imageLabel.Size = UDim2.new(1, p2 * -2, 1, p2 * -2)
			imageLabel.ZIndex = -6
			local uiCorner = Instance.new("UICorner", imageLabel)
			uiCorner.CornerRadius = UDim.new(0, 7)
			imageLabel.Parent = p.inst
		end

		local top = v.top

		if top and top.img and top.img ~= "" then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = top.img
			imageLabel.ResampleMode = resampleMode

			if top.stretch then
				imageLabel.ScaleType = Enum.ScaleType.Stretch
				imageLabel.Size = UDim2.new(1, p2 * -2, 1, p2 * -2)
			else
				imageLabel.ScaleType = Enum.ScaleType.Tile
				imageLabel.TileSize = UDim2.fromOffset(20, 20)
				imageLabel.Size = UDim2.new(1, p2 * -2, 0, 20)
			end

			imageLabel.Position = UDim2.fromOffset(p2, p2)
			imageLabel.ZIndex = -5
			local uiCorner = Instance.new("UICorner", imageLabel)
			uiCorner.CornerRadius = UDim.new(0, 7)
			imageLabel.Parent = p.inst
		end
	end

	function f.themeMenu(anchor, p: string, callback)
		local scale = u.layerScale.Scale
		local absolutePosition = u.layer.inst.AbsolutePosition
		local absolutePosition2 = anchor.inst.AbsolutePosition
		local absoluteSize = anchor.inst.AbsoluteSize
		local v = (absolutePosition2.X - absolutePosition.X) / scale
		local v2 = (absolutePosition2.Y - absolutePosition.Y) / scale
		local v3 = (absolutePosition2.Y + absoluteSize.Y - absolutePosition.Y) / scale
		local parent = openMenu(v, v3 + 4, (math.max(200, absoluteSize.X / scale + 40)))
		parent.anchor = anchor
		parent.z = 70
		parent.inst.ZIndex = 70
		local parent2 = b({
			scroll = true,
			dir = "col",
			gap = 5,
			pad = { 2, 12, 2, 2 },
			maxH = 315,
			parent = parent
		})
		local inst = parent2.inst
		inst.ScrollBarThickness = 5
		inst.ScrollBarImageTransparency = 0.2
		inst.ScrollBarImageColor3 = lay.TH.muted.c
		local vip = lp:GetAttribute("VIP") == true
		local v4 = 1

		for k, v5 in themes.order do
			local theme = themes[v5]

			if v5 == p then
				v4 = k
			end

			local v6 = v5 == p
			local v7 = {
				dir = "row",
				align = "center",
				gap = 8,
				pad = { 0, 12 },
				h = 40,
				r = 8,
				button = true,
				bg = c(theme.panel), -- inferred equivalent call
				bd = v6 and 2 or 1,
				bdc = 0,
				parent = 0
			}
			local bdc

			if v6 then
				bdc = c(theme.brass) -- inferred equivalent call
			else
				bdc = c(theme.line) -- inferred equivalent call
			end

			v7.bdc = bdc
			v7.parent = parent2
			local parent3 = b(v7)

			dress(parent3, theme, v6 and 2 or 1)

			b({
				w = 10,
				h = 10,
				r = "pill",
				bg = c(theme.brass), -- inferred equivalent call
				noShrink = true,
				parent = parent3
			})
			t({
				t = themes.names[v5],
				f = v6 and "s600_14_08" or "s500_14",
				c = c(theme.ink), -- inferred equivalent call
				grow = 1,
				shrink0 = true,
				ell = true,
				parent = parent3
			})
			local v8 = themes.vipOnly and themes.vipOnly[v5] and not vip

			if themes.vipOnly and themes.vipOnly[v5] then
				b({
					pad = { 1, 5 },
					r = 4,
					bg = { c = theme.brass.c, a = 0.22 },
					noShrink = true,
					parent = parent3,
					{ t({
							t = "vip",
							f = "m600_8_96",
							up = true,
							ls = 0.5376,
							c = c(theme.brassInk) -- inferred equivalent call
						}) }
				})
			end

			parent3:onClick(function()
				if f.closePopup then
					f.closePopup()
				end

				if not v8 then
					callback(v5)
					return
				end

				toast("VIP Gold is a VIP theme.")

				if f.openShop then
					f.closeDialog()
					f.openShop()
				end
			end)
		end

		lay.now()
		local v5 = u.layer.inst.AbsoluteSize.Y / scale
		local v6 = parent.inst.AbsoluteSize.Y / scale
		local v7 = v3 + 4
		local v8 = v7 + v6

		if v5 - 8 < v8 then
			v7 = v2 - 4 - v6
		end

		local v9 = math.clamp(v7, 8, (math.max(8, v5 - 8 - v6)))

		if parent.abs then
			parent.abs.t = v9
		end

		lay.dirty()

		task.defer(function()
			local v10 = math.max(0, (v4 - 4) * 45)
			inst.CanvasPosition = Vector2.new(
				0,
				(math.min(v10, (math.max(0, inst.AbsoluteCanvasSize.Y - inst.AbsoluteWindowSize.Y))))
			)
		end)
	end
end