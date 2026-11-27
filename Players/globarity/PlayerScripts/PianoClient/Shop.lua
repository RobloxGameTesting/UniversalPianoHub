return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local p = data.P
	local api = data.api
	local lay = data.Lay
	local lp = data.LP
	local l145 = data.L145
	local _btn = data.btn
	local note = data.note
	local eyebrow = data.eyebrow
	local openDialog = data.openDialog
	local _input = data.input
	local _statusLine = data.statusLine
	local toast = data.toast
	local gui = data.gui
	local glyph = data.Glyph
	local MarketplaceService = game:GetService("MarketplaceService")
	local TweenService = game:GetService("TweenService")

	local text2 = utf8.char(57346)
	local rbxassetfontsfamiliesBuilderSansjson = Font.new(
		"rbxasset://fonts/families/BuilderSans.json",
		Enum.FontWeight.Bold
	)
	local function fmt(p2: number)
		local v = tostring((math.floor(p2)))
		local v2 = string.reverse((string.gsub(string.reverse(v), "(%d%d%d)", "%1,")))
		return (string.gsub(v2, "^,", ""))
	end

	f.fmtRobux = fmt

	local function robux(textSize: number, p2: string)
		local v = b({ w = textSize, h = textSize, noShrink = true })
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Text = text2
		textLabel.FontFace = rbxassetfontsfamiliesBuilderSansjson
		textLabel.TextSize = textSize
		textLabel.ZIndex = 66
		textLabel.Parent = v.inst
		v.c = p2
		function v.onPaint(p3)
			textLabel.TextColor3 = lay.TH[p3.c].c
		end
		v:paint()
		return v
	end

	f.robuxIcon = robux

	local shopBtn = u.shopBtn
	shopBtn:add(robux(17, "brassInk"))

	if shopBtn.label then
		shopBtn.label:show(false)
	end

	shopBtn.pad = lay.pad4({ 0, 6 })
	lay.dirty()

	local function priceBtn(p2: string, p3: number?)
		local parent = b({
			dir = "row",
			align = "center",
			justify = "center",
			gap = 6,
			pad = { 8, 14 },
			bd = 1,
			bdc = "ink",
			bg = "ink",
			r = 8,
			button = true
		})
		t({
			t = p2,
			f = "s500_13_6",
			lh = 19.72,
			c = "bg",
			parent = parent
		})

		if p3 then
			parent:add(robux(14, "bg"))
			t({ t = fmt(p3), f = "s600_14_08", c = "bg", parent = parent })
		end

		return parent
	end

	function f.openShop()
		if f.closePopup then
			f.closePopup()
		end

		local v = openDialog("Support the game", false, f.phoneNow and 2000 or 600)
		f.shopDialog = v
		local parent = b({
			dir = "col",
			gap = 12,
			scroll = true,
			grow = 1,
			vshrink = true,
			minH = 60,
			pad = { 0, 6, 0, 0 },
			parent = v
		})

		local inst = parent.inst
		inst.ScrollBarThickness = 4
		inst.ScrollBarImageTransparency = 0.3
		inst.ScrollBarImageColor3 = lay.TH.muted.c

		parent:add(note("Loading…"))
		task.spawn(function()
			local shopInfo = api("shop")

			if type(shopInfo) == "table" then
				f.shopInfo = shopInfo
			end

			if u.dialog ~= v then
				return
			end

			parent:clear()

			if type(shopInfo) == "table" then
				local parent2 = b({
					dir = "col",
					gap = 8,
					pad = { 14, 16 },
					r = 12,
					bd = 1,
					bdc = "brass55",
					bg = "brassSoft",
					parent = parent
				})
				local parent3 = b({ dir = "row", align = "center", gap = 8, parent = parent2 })
				t({
					t = "VIP",
					f = "d700_20_8",
					lh = 20.8,
					c = "brassInk",
					parent = parent3
				})
				t({
					t = "forever",
					f = "m500_10_56",
					up = true,
					c = "muted",
					parent = parent3
				})

				for _, v2 in {
					"Your own note colours: gradients, flowing, black keys apart",
					"A VIP tag next to your name and the VIP Gold theme",
					"Rooms for up to 24 players",
					"Your sheets go first in the review queue"
				} do
					t({
						runs = {
							{ t = "+  ", c = "brassInk" },
							{ t = v2 }
						},
						f = "s400_14_08",
						lh = l145(14.08),
						wrap = true,
						parent = parent2
					})
				end

				if f.vipDemo then
					f.vipDemo(parent2)
				end

				local vipPass = tonumber(shopInfo.vipPass) or 0

				if shopInfo.vip == true or lp:GetAttribute("VIP") == true then
					t({
						t = "You're VIP. Thank you!",
						f = "s600_14_08",
						c = "brassInk",
						parent = parent2
					})
				elseif vipPass <= 0 then
					parent2:add(note("Coming soon."))
				else
					local v2 = priceBtn("Buy VIP forever", tonumber(shopInfo.vipPrice))
					v2.self = "start"
					parent2:add(v2)
					v2:onClick(function()
						MarketplaceService:PromptGamePassPurchase(lp, vipPass)
					end)
				end

				local rainbowPass = tonumber(shopInfo.rainbowPass) or 0
				f.rainbowPassId = rainbowPass

				if rainbowPass > 0 then
					local parent4 = b({
						dir = "row",
						align = "center",
						gap = 12,
						pad = { 12, 16 },
						r = 12,
						bd = 1,
						bdc = "line",
						bg = "panel2",
						parent = parent
					})
					local v2 = b({
						w = 34,
						h = 34,
						r = 9,
						noShrink = true,
						bg = { c = Color3.new(1, 1, 1), a = 1 },
						parent = parent4
					})
					local uiGradient = Instance.new("UIGradient")
					uiGradient.Rotation = 45
					uiGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ff4d4d")),
						ColorSequenceKeypoint.new(0.33, Color3.fromHex("ffd93d")),
						ColorSequenceKeypoint.new(0.66, Color3.fromHex("4dd8ff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("c56bff"))
					})
					uiGradient.Parent = v2.inst
					local parent5 = b({
						dir = "col",
						gap = 2,
						grow = 1,
						shrink0 = true,
						parent = parent4
					})
					t({ t = "Rainbow Notes", f = "s600_14_08", parent = parent5 })
					t({
						t = "Your notes shine in every colour, for everyone to see.",
						f = "s400_12_8",
						lh = l145(12.8),
						c = "muted",
						wrap = true,
						parent = parent5
					})

					if shopInfo.rainbow == true or lp:GetAttribute("RainbowOwned") == true then
						t({
							t = "Yours!",
							f = "s600_14_08",
							c = "brassInk",
							noShrink = true,
							parent = parent4
						})
					else
						local v3 = priceBtn("Buy", tonumber(shopInfo.rainbowPrice))
						v3.noShrink = true
						parent4:add(v3)
						v3:onClick(function()
							MarketplaceService:PromptGamePassPurchase(lp, rainbowPass)
						end)
					end
				end

				if f.EFFECT_ORDER then
					parent:add(eyebrow("Note effects  ·  tap one to wear it"))
					local parent4 = b({
						dir = "row",
						wrap = true,
						gap = 10,
						rowGap = 10,
						parent = parent
					})
					local v2 = type(shopInfo.effects) ~= "table" and {} or shopInfo.effects
					f.effectPassIds = {}

					for k, v3 in v2 do
						if not (type(v3) == "table" and (tonumber(v3.pass) or 0) > 0) then
							continue
						end

						f.effectPassIds[tonumber(v3.pass)] = k
					end

					local v3 = nil
					local function fn()
						if u.dialog ~= v then
							return
						end

						parent4:clear()
						local v4 = v3 or f.effectOf(lp)

						for _, v5 in f.EFFECT_ORDER do
							local v6 = f.EFFECTS[v5]
							local v7 = v2[v5]
							local v8

							if v5 == "default" then
								v8 = true
							elseif type(v7) == "table" then
								v8 = v7.owned == true
							else
								v8 = false
							end

							local v9

							if type(v7) == "table" then
								v9 = (tonumber(v7.pass) or 0) > 0
							else
								v9 = false
							end

							local v10 = v4 == v5
							local v11 = b({
								w = 104,
								h = 104,
								r = 12,
								bg = "stage",
								bd = v10 and 2 or 1,
								bdc = v10 and "brass" or "line",
								clip = true,
								button = true,
								hov = not v10 and { bdc = "btnHoverLine" } or nil,
								parent = parent4
							})

							if not v10 then
								v11:bindHover()
							end

							f.effectPreview(v11, v5, 104)

							local frame = Instance.new("Frame")
							frame.BorderSizePixel = 0
							frame.BackgroundColor3 = Color3.new(0, 0, 0)
							frame.AnchorPoint = Vector2.new(0, 1)
							frame.Position = UDim2.fromScale(0, 1)
							frame.Size = UDim2.new(1, 0, 0, 30)
							frame.ZIndex = 72
							local uiCorner = Instance.new("UICorner", frame)
							uiCorner.CornerRadius = UDim.new(0, 12)
							local uiGradient = Instance.new("UIGradient")
							uiGradient.Rotation = 90
							uiGradient.Transparency = NumberSequence.new(1, 0.2)
							uiGradient.Parent = frame
							frame.Parent = v11.inst
							local function word(text: string, fontFace, textSize: number, textColor: Color3, textXAlignment)
								local textLabel = Instance.new("TextLabel")
								textLabel.BackgroundTransparency = 1
								textLabel.Text = text
								textLabel.FontFace = fontFace
								textLabel.TextSize = textSize
								textLabel.TextColor3 = textColor
								textLabel.TextXAlignment = textXAlignment
								textLabel.TextTruncate = Enum.TextTruncate.AtEnd
								textLabel.AnchorPoint = Vector2.new(0, 1)
								textLabel.Position = UDim2.new(0, 8, 1, -5)
								textLabel.Size = UDim2.new(1, -16, 0, 16)
								textLabel.ZIndex = 73
								textLabel.Parent = v11.inst
								return textLabel
							end

							local color = Color3.new(1, 1, 1)
							local v12 = lay.TH.brassInk.c
							local v13, v14

							if v10 then
								v13 = glyph.nativeFont("s600_14_08")
								v14 = "On"
							elseif v8 then
								v13 = glyph.nativeFont("s500_12_8")
								v12 = Color3.fromRGB(200, 200, 200)
								v14 = "Wear"
							elseif v9 and tonumber(v7.price) then
								v14 = text2 .. " " .. fmt(tonumber(v7.price))
								v13 = rbxassetfontsfamiliesBuilderSansjson
							else
								v13 = glyph.nativeFont("s500_12_8")
								v12 = Color3.fromRGB(150, 150, 150)
								v14 = "Soon"
							end

							local v15 = word(
								v6.name,
								glyph.nativeFont("s600_14_08"),
								13,
								color,
								Enum.TextXAlignment.Left
							)
							word(v14, v13, 13, v12, Enum.TextXAlignment.Right)

							v15.Size = UDim2.new(1, -52, 0, 16)

							if v10 then
								v11.bdc = "brass"
							end

							v11:onClick(function()
								if v10 then
									return
								end

								if v8 then
									task.spawn(function()
										local v16, v17 = api("setEffect", v5)

										if not v16 then
											toast((tostring(v17 or "Couldn't change it.")))
											return
										end

										v3 = v5
										toast(v6.name .. " is on: play a few notes.")
										fn()
									end)
								elseif v9 then
									MarketplaceService:PromptGamePassPurchase(lp, (tonumber(v7.pass)))
								else
									toast(v6.name .. " is coming soon.")
								end
							end)
						end

						lay.dirty()
					end
					fn()
				end

				parent:add(eyebrow("Donate to the developer"))
				local v2 = type(shopInfo.products) ~= "table" and {} or shopInfo.products

				if #v2 > 0 then
					local parent4 = b({
						dir = "row",
						wrap = true,
						gap = 8,
						rowGap = 8,
						parent = parent
					})

					for _, v3 in v2 do
						local parent5 = b({
							dir = "row",
							align = "center",
							gap = 5,
							pad = { 7, 12 },
							bd = 1,
							bdc = "line",
							bg = "panel2",
							r = 8,
							button = true,
							hov = { bdc = "btnHoverLine" },
							parent = parent4
						})
						parent5:bindHover()
						parent5:add(robux(14, "brassInk"))
						t({
							t = fmt(tonumber(v3.price) or 0),
							f = "s600_14_08",
							parent = parent5
						})
						parent5:onClick(function()
							MarketplaceService:PromptProductPurchase(lp, (tonumber(v3.id)))
						end)
					end
				end

				if #v2 == 0 then
					parent:add(note("Coming soon."))
				end

				lay.dirty()
			else
				parent:add(note("Couldn't load. Try again in a minute."))
				lay.dirty()
			end
		end)
	end
	u.shopBtn:onClick(f.openShop)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p2, p3, p4)
		if p2 ~= lp or not p4 then
			return
		end

		local v = f.effectPassIds and f.effectPassIds[p3]
		toast(p3 == f.rainbowPassId and "Rainbow Notes are yours! Play a few notes." or not (v and f.EFFECTS and f.EFFECTS[v]) and "Welcome to VIP! Thank you for supporting the game." or f.EFFECTS[v].name .. " is yours and on! Play a few notes.")

		task.delay(1, function()
			if u.dialog ~= nil and u.dialog == f.shopDialog then
				f.openShop()
			end
		end)
	end)
	MarketplaceService.PromptProductPurchaseFinished:Connect(function(p2, _, p3)
		if p2 == lp.UserId and p3 then
			toast("Thank you for the donation!")
		end
	end)

	local v = {}
	local v2 = false
	local function showNext()
		local v3 = table.remove(v, 1)

		if not v3 then
			v2 = false
			return
		end

		v2 = true
		local th = lay.TH
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.45)
		frame.Size = UDim2.fromOffset(440, 170)
		frame.BackgroundColor3 = th.panel.c
		frame.BorderSizePixel = 0
		frame.ZIndex = 50
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 18)
		uiCorner.Parent = frame
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = th.brass.c
		uiStroke.Thickness = 2
		uiStroke.Parent = frame
		local uiScale = Instance.new("UIScale")
		uiScale.Scale = 0.85
		uiScale.Parent = frame
		local function label(text: string, p2: number, p3: number, textSize: number, c: Color3, fontFace)
			local textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.Position = UDim2.new(0, 16, 0, p2)
			textLabel.Size = UDim2.new(1, -32, 0, p3)
			textLabel.Text = text
			textLabel.TextSize = textSize
			textLabel.TextColor3 = c
			textLabel.FontFace = fontFace
			textLabel.TextTruncate = Enum.TextTruncate.AtEnd
			textLabel.ZIndex = 51
			textLabel.Parent = frame
			return textLabel
		end

		local nativeFont = glyph.nativeFont("s600_16")
		local v4 = label(
			"♥  " .. tostring(v3.from) .. (v3.gift and " gifted you" or " donated"),
			18,
			26,
			20,
			th.ink.c,
			nativeFont
		)
		local v5

		if v3.gift then
			v5 = label(tostring(v3.gift), 56, 56, 44, th.brassInk.c, rbxassetfontsfamiliesBuilderSansjson)
		else
			v5 = label(
				text2 .. " " .. fmt(tonumber(v3.amount) or 0),
				52,
				64,
				56,
				th.brassInk.c,
				rbxassetfontsfamiliesBuilderSansjson
			)
		end

		local v6 = {
			v4,
			v5,
			label(
				v3.gift and "Enjoy!" or v3.dev and "to the game. Thank you!" or "to you!",
				122,
				26,
				18,
				th.muted.c,
				nativeFont
			)
		}
		frame.BackgroundTransparency = 1
		uiStroke.Transparency = 1

		for _, v7 in v6 do
			v7.TextTransparency = 1
		end

		frame.Parent = gui
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(uiScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
		TweenService:Create(frame, tweenInfo, { BackgroundTransparency = 0.04 }):Play()
		TweenService:Create(uiStroke, tweenInfo, { Transparency = 0 }):Play()

		for _, instance in v6 do
			TweenService:Create(instance, tweenInfo, { TextTransparency = 0 }):Play()
		end

		task.delay(5, function()
			local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(frame, tweenInfo2, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(uiStroke, tweenInfo2, { Transparency = 1 }):Play()

			for _, instance in v6 do
				TweenService:Create(instance, tweenInfo2, { TextTransparency = 1 }):Play()
			end

			TweenService:Create(uiScale, tweenInfo2, { Scale = 0.9 }):Play()
			task.delay(0.35, function()
				frame:Destroy()
				showNext()
			end)
		end)
	end
	function f.donationAlert(p2)
		if p.donAlert == false then
			return
		end

		table.insert(v, p2)

		if not v2 then
			showNext()
		end
	end
end