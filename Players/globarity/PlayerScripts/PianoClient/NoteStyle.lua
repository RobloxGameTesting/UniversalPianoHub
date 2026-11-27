return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local lay = data.Lay
	local lp = data.LP
	local api = data.api
	local btn = data.btn
	local note = data.note
	local img = data.img
	local fx = data.FX
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")

	local v = { ["1"] = "along", ["2"] = "each" }
	local function parse(value: string)
		local result = {}

		for k in string.gmatch(value, "[^;]+") do
			local v2, v3 = string.match(k, "^(%a+)=(.+)$")

			if v2 == "w" or v2 == "b" then
				local v4, v5 = string.match(v3, "^(%x%x%x%x%x%x),?(%x*)$")

				if v4 then
					local color = Color3.fromHex(v4)
					local v6

					if v5 and #v5 == 6 then
						v6 = Color3.fromHex(v5)
					end

					result[v2] = { color, v6 }
				end
			elseif v2 == "f" and v[v3] then
				result.fw = { v[v3], 1 }
				result.fb = { v[v3], 1 }
			elseif v2 == "fw" or v2 == "fb" then
				local v4, v5 = string.match(v3, "^([12]),(%d+)$")

				if v4 then
					result[v2] = { v[v4], math.clamp(tonumber(v5) or 100, 5, 300) / 100 }
				end
			elseif v2 == "gw" or v2 == "gb" then
				local v4 = tonumber(string.match(v3, "^(%d+)$"))

				if v4 then
					result[v2] = math.clamp(v4, 0, 200) / 100
				end
			end
		end

		return if result.w then result else nil
	end

	local v2 = {}

	function f.styleOf(instance)
		local noteStyle = instance:GetAttribute("NoteStyle")

		if type(noteStyle) ~= "string" or noteStyle == "" or instance:GetAttribute("VIP") ~= true then
			return nil
		end

		local v3 = v2[noteStyle]

		if v3 == nil then
			v3 = parse(noteStyle) or false
			v2[noteStyle] = v3
		end

		return v3 or nil
	end

	function f.noteFx(instance)
		return f.styleOf(instance) or instance:GetAttribute("Rainbow") == true
	end

	function f.styleColor(data2, value: number, flag: boolean?, value2: number?)
		local v3 = flag and data2.b ~= nil
		local v4 = if v3 then data2.b else data2.w
		local v5 = v4[1]
		local v6 = v4[2]

		if not v6 then
			return v5
		end

		local v7 = if v3 then data2.fb else data2.fw
		local v8 = math.max(1, u.stage._pw or 1000)
		value = value or 0
		local v9

		if v7 and v7[1] == "each" then
			local v10 = math.sin(math.floor(value) * 12.9898) * 43758.5453
			v9 = 0.5 - math.cos(6.283185307179586 * (os.clock() * 0.45 * v7[2] + v10 % 1 + (value2 or 0))) * 0.5
		else
			local v10 = value / v8 + (not v7 and 0 or os.clock() * 0.25 * v7[2] + (value2 or 0))
			v9 = 0.5 - math.cos(3.141592653589793 * v10) * 0.5
		end

		return v5:Lerp(v6, v9)
	end

	function f.styleFlows(data2, flag: boolean?): boolean
		local v3 = flag and data2.b ~= nil
		local v4 = if v3 then data2.b else data2.w

		if v4[2] == nil then
			return false
		else
			local v5 = if v3 then data2.fb else data2.fw
			return v5 ~= nil
		end
	end

	function f.styleGlow(p, flag: boolean?)
		local v3 = if flag then p.gb else p.gw
		return v3 or 1
	end

	local v3 = {
		on = false,
		w = { Color3.fromHex("ff4fa3"), Color3.fromHex("5ec8f2") },
		wGrad = true,
		bOwn = false,
		b = { Color3.fromHex("b48cff"), Color3.fromHex("f2c14e") },
		bGrad = false,
		wFlow = "along",
		wSpeed = 100,
		bFlow = false,
		bSpeed = 100,
		wGlow = 100,
		bGlow = 100
	}

	local function encode()
		local function one(list, flag: boolean) -- 2 equivalent calls inferred from this helper
			return list[1]:ToHex() .. (not flag and "" or "," .. list[2]:ToHex())
		end

		local function fl(p, p2: number) -- 2 equivalent calls inferred from this helper
			return (p == "each" and "2" or "1") .. "," .. math.floor(p2 + 0.5)
		end

		local v4 = "w=" .. one(v3.w, v3.wGrad) -- inferred equivalent call

		if v3.bOwn then
			v4 ..= ";b=" .. one(v3.b, v3.bGrad) -- inferred equivalent call
		end

		if v3.wGrad and v3.wFlow then
			v4 ..= ";fw=" .. fl(v3.wFlow, v3.wSpeed) -- inferred equivalent call
		end

		if v3.bOwn and v3.bGrad and v3.bFlow then
			v4 ..= ";fb=" .. fl(v3.bFlow, v3.bSpeed) -- inferred equivalent call
		end

		if v3.wGlow ~= 100 then
			v4 ..= ";gw=" .. math.floor(v3.wGlow + 0.5)
		end

		if v3.bGlow ~= 100 then
			return v4 .. ";gb=" .. math.floor(v3.bGlow + 0.5)
		end

		return v4
	end

	local function decode(value)
		if type(value) ~= "string" then
			return
		end

		local v4 = parse(value)

		if not v4 then
			return
		end

		v3.w = { v4.w[1], v4.w[2] or v3.w[2] }
		v3.wGrad = v4.w[2] ~= nil
		v3.bOwn = v4.b ~= nil

		if v4.b then
			v3.b = { v4.b[1], v4.b[2] or v3.b[2] }
			v3.bGrad = v4.b[2] ~= nil
		end

		local wFlow = if v4.fw then v4.fw[1] else false
		v3.wFlow = wFlow
		v3.wSpeed = not v4.fw and 100 or math.floor(v4.fw[2] * 100 + 0.5)
		local bFlow = if v4.fb then v4.fb[1] else false
		v3.bFlow = bFlow
		v3.bSpeed = not v4.fb and 100 or math.floor(v4.fb[2] * 100 + 0.5)
		v3.wGlow = not v4.gw and 100 or math.floor(v4.gw * 100 + 0.5)
		v3.bGlow = not v4.gb and 100 or math.floor(v4.gb * 100 + 0.5)
	end

	local v4 = {}

	function f.nsPrefs(data2)
		if type(data2) ~= "table" then
			return
		end

		decode(data2.nstyle)
		v3.on = data2.nstyleOn == true
		v4 = {}

		if type(data2.nsp) == "table" then
			for _, v5 in data2.nsp do
				if not (type(v5) == "table" and type(v5.n) == "string" and type(v5.s) == "string") then
					continue
				end

				if not (parse(v5.s) and #v4 < 20) then
					continue
				end

				table.insert(v4, { n = v5.n, s = v5.s })
			end
		end
	end

	local count = 0
	local function changed() -- 9 equivalent calls inferred from this helper
		count += 1
		local v5 = count
		task.delay(0.6, function()
			if v5 == count then
				task.spawn(api, "setNoteStyle", { s = encode(), on = v3.on })
			end
		end)
	end

	local function hsl(p: number, p2: number, p3: number) -- 1 equivalent call inferred from this helper
		if p3 <= 0.5 then
			return Color3.fromHSV(p, p2, p3 * 2)
		end

		return Color3.fromHSV(p, p2 * (1 - (p3 - 0.5) * 2), 1)
	end

	local function toHSL(color: Color3)
		local hsv, v5, v6 = color:ToHSV()

		if v6 < 0.999 then
			return hsv, v5, v6 / 2
		end

		return hsv, 1, 0.5 + (1 - v5) / 2
	end

	local function openPicker(anchor, p: string, fn, fn2, callback, callback2)
		local v5, v6 = f.at(anchor)
		local parent = callback(v5, v6 + 30, 292, v6 - 6)
		parent.anchor = anchor
		parent.z = 70
		parent.inst.ZIndex = 70
		local v7, v8, v9 = fn():ToHSV()
		local v10

		if v9 < 0.999 then
			v10 = v9 / 2
		else
			v10 = 0.5 + (1 - v8) / 2
			v8 = 1
		end

		t({
			t = p,
			f = "m500_10_24",
			up = true,
			ls = 1.024,
			c = "muted",
			grow = 1,
			shrink0 = true,
			parent = b({
				dir = "row",
				align = "center",
				pad = { 2, 4 },
				parent = parent
			})
		})

		local v11 = b({
			w = 236,
			h = 236,
			m = { 4, 0 },
			button = true,
			parent = b({ dir = "row", justify = "center", parent = parent })
		})
		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromOffset(236, 236)
		frame.ZIndex = 71
		local uiCorner = Instance.new("UICorner", frame)
		uiCorner.CornerRadius = UDim.new(1, 0)
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 14
		uiStroke.Color = Color3.new(1, 1, 1)
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
		uiStroke.Parent = frame
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Parent = uiStroke
		frame.Parent = v11.inst
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://89205369778328"
		imageLabel.Size = UDim2.fromOffset(196, 196)
		imageLabel.Position = UDim2.fromOffset(20, 20)
		imageLabel.ZIndex = 71
		imageLabel.Parent = v11.inst

		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.BackgroundColor3 = Color3.new(1, 1, 1)
		frame2.Size = UDim2.fromScale(1, 1)
		frame2.ZIndex = 72
		local uiCorner_2 = Instance.new("UICorner", frame2)
		uiCorner_2.CornerRadius = UDim.new(1, 0)
		frame2.Parent = imageLabel
		local function knob(p2: number)
			local frame3 = Instance.new("Frame")
			frame3.Size = UDim2.fromOffset(p2, p2)
			frame3.BackgroundColor3 = Color3.new(1, 1, 1)
			frame3.ZIndex = 74
			local uiCorner = Instance.new("UICorner", frame3)
			uiCorner.CornerRadius = UDim.new(1, 0)
			local uiStroke2 = Instance.new("UIStroke")
			uiStroke2.Thickness = 2
			uiStroke2.Color = Color3.fromHex("222222")
			uiStroke2.Parent = frame3
			frame3.Parent = v11.inst
			return frame3
		end

		local parent2 = knob(14)
		local parent3 = knob(16)

		local parent4 = b({
			dir = "row",
			align = "center",
			gap = 6,
			m = { 6, 0, 2, 0 },
			parent = parent
		})
		local v12 = b({
			w = 30,
			h = 30,
			r = 7,
			bd = 1,
			bdc = "line",
			noShrink = true,
			parent = parent4
		})
		local v13, v14 = callback2(parent4, "#rrggbb", { h = 30 })
		v13.w = 86
		local v15 = {}

		for _, v16 in { "R", "G", "B" } do
			local v17, v18 = callback2(parent4, v16, { h = 30 })
			v17.w = 44
			table.insert(v15, v18)
		end

		local flag = false
		local function render()
			local backgroundColor = hsl(v7, v8, v10) -- inferred equivalent call
			local v16 = v7 * 2 * 3.141592653589793
			parent2.Position = UDim2.fromOffset(118 + math.sin(v16) * v8 * 98 - 7, 118 - math.cos(v16) * v8 * 98 - 7)
			local v17 = v10 * 3.141592653589793

			parent3.Position = UDim2.fromOffset(118 - math.sin(v17) * 111 - 8, 118 - math.cos(v17) * 111 - 8)
			parent3.BackgroundColor3 = backgroundColor
			parent2.BackgroundColor3 = backgroundColor
			uiGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromHSV(v7, v8, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
			})
			imageLabel.ImageColor3 = Color3.fromHSV(0, 0, (math.min(1, v10 * 2)))
			frame2.BackgroundTransparency = 1 - math.max(0, (v10 - 0.5) * 2)
			v12.bg = { c = backgroundColor, a = 1 }
			v12:paint()
			flag = true

			if not v14:IsFocused() then
				v14.Text = "#" .. string.upper(backgroundColor:ToHex())
			end

			local v18 = {
				math.floor(backgroundColor.R * 255 + 0.5),
				math.floor(backgroundColor.G * 255 + 0.5),
				(math.floor(backgroundColor.B * 255 + 0.5))
			}

			for k, v19 in v15 do
				if not v19:IsFocused() then
					v19.Text = tostring(v18[k])
				end
			end

			flag = false
		end
		local function apply() -- 3 equivalent calls inferred from this helper
			fn2(hsl(v7, v8, v10))
			render()
		end

		local v16 = nil
		local function at(p2: number, p3: number, flag2: boolean)
			local v17 = p2 - 118
			local v18 = p3 - 118
			local v19 = math.sqrt(v17 * v17 + v18 * v18)

			if flag2 or not v16 then
				v16 = v19 <= 102 and "wheel" or v19 >= 100 and v19 <= 120 and "ring" or nil
			end

			if v16 == "wheel" then
				v7 = math.atan2(v17, -v18) / 6.283185307179586 % 1
				v8 = math.clamp(v19 / 98, 0, 1)
			elseif v16 == "ring" then
				v10 = math.clamp(math.acos((math.clamp(-v18 / math.max(v19, 1), -1, 1))) / 3.141592653589793, 0, 1)
			else
				return
			end

			apply() -- inferred equivalent call
		end
		local v17 = nil
		v11.inst.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				v17 = input
				local absolutePosition = v11.inst.AbsolutePosition
				local v18 = v11.inst.AbsoluteSize.X / 236
				at((input.Position.X - absolutePosition.X) / v18, (input.Position.Y - absolutePosition.Y) / v18, true)
			end
		end)
		local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			if v17 and (input.UserInputType == Enum.UserInputType.MouseMovement or input == v17) then
				local absolutePosition = v11.inst.AbsolutePosition
				local v18 = v11.inst.AbsoluteSize.X / 236
				at((input.Position.X - absolutePosition.X) / v18, (input.Position.Y - absolutePosition.Y) / v18, false)
			end
		end)
		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input == v17 or input.UserInputType == Enum.UserInputType.MouseButton1 then
				v17 = nil
				v16 = nil
			end
		end)

		if f.drags then
			local v18 = 0
			f.drags[v11.inst] = function(p2: number, value: number?)
				local absolutePosition = v11.inst.AbsolutePosition
				local v19 = v11.inst.AbsoluteSize.X / 236

				local now = os.clock()
				at((p2 - absolutePosition.X) / v19, ((value or 0) - absolutePosition.Y) / v19, now - v18 > 0.2)
				v18 = now
			end
		end

		parent.inst.Destroying:Connect(function()
			inputChangedConnection:Disconnect()
			inputEndedConnection:Disconnect()
		end)

		v14.FocusLost:Connect(function()
			local v18 = string.match(v14.Text, "^%s*#?(%x%x%x%x%x%x)%s*$")

			if not v18 then
				render()
				return
			end

			local hsv, v19, v20 = Color3.fromHex(v18):ToHSV()
			local v21

			if v20 < 0.999 then
				v21 = v20 / 2
			else
				v21 = 0.5 + (1 - v19) / 2
				v19 = 1
			end

			v7 = hsv
			v8 = v19
			v10 = v21
			apply() -- inferred equivalent call
		end)

		for _, v18 in v15 do
			v18.FocusLost:Connect(function()
				if flag then
					return
				end

				local v19 = {}

				for k, v20 in v15 do
					v19[k] = math.clamp(math.floor(tonumber(v20.Text) or 0), 0, 255)
				end

				local hsv, v20, v21 = Color3.fromRGB(v19[1], v19[2], v19[3]):ToHSV()
				local v22

				if v21 < 0.999 then
					v22 = v21 / 2
				else
					v22 = 0.5 + (1 - v20) / 2
					v20 = 1
				end

				v7 = hsv
				v8 = v20
				v10 = v22
				apply() -- inferred equivalent call
			end)
		end

		local v18 = btn("Done", "primary")
		b({ dir = "row", justify = "end", parent = parent }):add(v18)
		v18:onClick(function()
			f.closePopup()
		end)
		render()
		lay.dirty()
	end

	local v5 = {
		{
			name = "Sunset",
			w = { "ff5f6d", "ffc371" },
			wf = "along",
			ws = 100
		},
		{
			name = "Ocean",
			w = { "00c6ff", "0072ff" },
			wf = "along",
			ws = 70,
			b = { "a0f0ff" }
		},
		{
			name = "Neon",
			w = { "f72585", "4cc9f0" },
			wf = "each",
			ws = 140,
			b = { "7209b7", "f72585" },
			bf = "each",
			bs = 160
		},
		{
			name = "Aurora",
			w = { "43e97b", "38f9d7" },
			wf = "along",
			ws = 60,
			b = { "a18cd1", "fbc2eb" },
			bf = "each",
			bs = 100
		},
		{
			name = "Fire",
			w = { "ff512f", "f09819" },
			wf = "each",
			ws = 180,
			b = { "c31432" }
		},
		{
			name = "Galaxy",
			w = { "1f0a4d", "b44cff" },
			wf = "along",
			ws = 45,
			b = { "120638", "f0eaff" },
			bf = "each",
			bs = 170
		},
		{
			name = "Candy",
			w = { "ff9a9e", "fecfef" },
			wf = "each",
			ws = 90,
			b = { "a1c4fd" }
		},
		{
			name = "Gold",
			w = { "f7971e", "ffd200" },
			wf = "along",
			ws = 50,
			b = { "fff1b8" }
		},
		{
			name = "VIP",
			w = { "ffb800", "fff4c2" },
			wf = "along",
			ws = 170,
			b = { "a8740f", "ffd54a" },
			bf = "along",
			bs = 170
		},
		{
			name = "Blood Bath",
			w = { "210000", "e20000" },
			wf = "along",
			ws = 130,
			b = { "000000" }
		}
	}

	local function usePreset(p)
		local v6 = p or {
			w = { "ff4fa3", "5ec8f2" },
			wf = "along",
			ws = 100
		}
		v3.w = { Color3.fromHex(v6.w[1]), Color3.fromHex(v6.w[2] or v6.w[1]) }
		v3.wGrad = v6.w[2] ~= nil
		v3.wFlow = v6.wf or false
		v3.wSpeed = v6.ws or 100
		v3.bOwn = v6.b ~= nil

		if v6.b then
			v3.b = { Color3.fromHex(v6.b[1]), Color3.fromHex(v6.b[2] or v6.b[1]) }
			v3.bGrad = v6.b[2] ~= nil
		end

		v3.bFlow = v6.bf or false
		v3.bSpeed = v6.bs or 100
		v3.wGlow = v6.gw or 100
		v3.bGlow = v6.gb or 100
	end

	function f.noteStyleRow(parent2, callback, callback2, callback3, callback4, callback5, callback6)
		local vip = lp:GetAttribute("VIP") == true
		local v6 = callback(
			parent2,
			"Note colours (VIP)",
			"Pick the colour of your notes: one colour or a gradient, another one for the black keys, and the gradient can flow. Everyone sees them. Turning them on turns Rainbow Notes off."
		)

		if vip then
			local parent3 = b({
				dir = "col",
				gap = 10,
				pad = { 10, 0, 14, 0 },
				bds = { 0, 0, 1, 0 },
				bdc = "line",
				parent = parent2
			})
			local _, v7 = callback2(v6, "On", v3.on, function(on)
				v3.on = on
				parent3:show(on)
				lay.dirty()
				changed() -- inferred equivalent call
			end)
			parent3:show(v3.on)

			local noteStyleChangedConnection = lp:GetAttributeChangedSignal("NoteStyle"):Connect(function()
				if lp:GetAttribute("NoteStyle") == "" and v3.on and lp:GetAttribute("Rainbow") == true then
					v3.on = false
					v7(false)
					parent3:show(false)
					lay.dirty()
				end
			end)
			v6.inst.Destroying:Connect(function()
				noteStyleChangedConnection:Disconnect()
			end)

			local fn

			local function looks(parent, p, p2) -- 1 equivalent call inferred from this helper
				local function bar(p3: number, list)
					local v8 = b({
						w = p3,
						h = 14,
						r = 7,
						bd = 1,
						bdc = "line",
						bg = { c = Color3.new(1, 1, 1), a = 1 },
						noShrink = true,
						parent = parent
					})
					local uiGradient = Instance.new("UIGradient")
					uiGradient.Color = ColorSequence.new(list[1], list[2] or list[1])
					uiGradient.Parent = v8.inst
				end
				bar(30, p)

				if p2 then
					bar(14, p2)
				end
			end
			local function hexes(list)
				local color = Color3.fromHex(list[1])
				local v8

				if list[2] then
					v8 = Color3.fromHex(list[2])
				end

				return { color, v8 }
			end

			local function menuHead(parent, p: string)
				t({
					t = p,
					f = "m500_10_24",
					up = true,
					ls = 1.024,
					c = "muted",
					parent = b({
						pad = { 6, 8, 2, 8 },
						parent = parent
					})
				})
			end
			local function onTop(p) -- 2 equivalent calls inferred from this helper
				p.z = 70
				p.inst.ZIndex = 70
			end

			local function fn2(anchor)
				local v8, v9 = f.at(anchor)
				local parent = callback4(v8, v9 + 34, 300, v9 - 6)
				parent.anchor = anchor
				onTop(parent) -- inferred equivalent call
				local parent4 = b({
					scroll = true,
					dir = "col",
					gap = 2,
					maxH = 330,
					parent = parent
				})
				local function item(p: string, p2, p3, fn3, callback7)
					local parent5 = b({ dir = "row", align = "center", gap = 2, parent = parent4 })
					local parent6 = b({
						dir = "row",
						align = "center",
						gap = 8,
						pad = { 7, 8 },
						r = 8,
						grow = 1,
						button = true,
						hov = { bg = "white05" },
						parent = parent5
					})
					parent6:bindHover()
					looks(parent6, p2, p3) -- inferred equivalent call
					t({
						t = p,
						f = "s500_14",
						lh = 20.3,
						grow = 1,
						shrink0 = true,
						ell = true,
						parent = parent6
					})
					parent6:onClick(function()
						f.closePopup()
						fn3()
						fn()
						changed() -- inferred equivalent call
					end)

					if callback7 then
						local v10 = b({
							pad = { 2, 8 },
							r = 6,
							button = true,
							noShrink = true,
							hov = { bg = "white05" },
							parent = parent5,
							{ t({ t = "×", f = "s400_22_4", lh = 22.4, c = "muted" }) }
						})
						v10:bindHover()
						v10:onClick(callback7)
					end
				end

				if #v4 > 0 then
					menuHead(parent4, "My presets")

					for k, v10 in v4 do
						local v11 = parse(v10.s)

						if v11 then
							item(v10.n, v11.w, v11.b, function()
								decode(v10.s)
							end, function()
								table.remove(v4, k)
								f.savePref("nsp", table.clone(v4))
								fn2(anchor)
							end)
						end
					end
				end

				menuHead(parent4, "Presets")

				for _, v10 in v5 do
					local name = v10.name
					local w = v10.w
					local color = Color3.fromHex(w[1])
					local v11

					if w[2] then
						v11 = Color3.fromHex(w[2])
					end

					local v12

					if v10.b then
						local b2 = v10.b
						v12 = { nil, nil }
						local color2 = Color3.fromHex(b2[1])
						local v13

						if b2[2] then
							v13 = Color3.fromHex(b2[2])
						end

						v12[1], v12[2] = color2, v13
					end

					item(name, { color, v11 }, v12, function()
						usePreset(v10)
					end)
				end

				lay.dirty()
			end

			local function openSave(anchor)
				local v8, v9 = f.at(anchor)
				local parent = callback4(v8, v9 + 34, 280, v9 - 6)
				parent.anchor = anchor
				onTop(parent) -- inferred equivalent call
				menuHead(parent, "Save as preset")
				local v10 = b({ dir = "row", align = "center", gap = 6, parent = parent })
				local _, v11 = callback5(v10, "Name", { h = 32, grow = true })
				local v12 = btn("Save", "primary")
				v10:add(v12)

				if #v4 >= 20 then
					parent:add(note("You have " .. 20 .. " presets: saving one more removes the oldest."))
				end

				local function save()
					local v13 = string.gsub(string.gsub(v11.Text, "^%s+", ""), "%s+$", "")
					local v14 = utf8.offset(v13, 25)

					if v14 then
						v13 = string.sub(v13, 1, v14 - 1)
					end

					if v13 == "" then
						v13 = "My preset " .. #v4 + 1
					end

					for i = #v4, 1, -1 do
						if string.lower(v4[i].n) ~= string.lower(v13) then
							continue
						end

						table.remove(v4, i)
					end

					table.insert(v4, 1, { n = v13, s = encode() })

					while #v4 > 20 do
						table.remove(v4)
					end

					f.savePref("nsp", table.clone(v4))
					f.closePopup()
				end
				v12:onClick(save)
				v11.FocusLost:Connect(function(p)
					if p then
						save()
					end
				end)
				task.defer(function()
					if v11.Parent then
						v11:CaptureFocus()
					end
				end)
				lay.dirty()
			end

			fn = function()
				parent3:clear()

				local parent4 = b({
					dir = "row",
					align = "center",
					wrap = true,
					gap = 8,
					rowGap = 6,
					parent = parent3
				})
				t({
					t = "Presets",
					f = "s500_14",
					lh = 20.3,
					w = 86,
					parent = parent4
				})
				local v8 = btn("Choose preset…")
				parent4:add(v8)
				v8:onClick(function()
					fn2(v8)
				end)
				local anchor = btn("Save as preset")
				parent4:add(anchor)
				anchor:onClick(function()
					openSave(anchor)
				end)
				local v9 = btn("Reset")
				parent4:add(v9)
				v9:onClick(function()
					usePreset(nil)
					fn()
					changed() -- inferred equivalent call
				end)
				local v10 = {}
				local function slot(value: string) -- 3 equivalent calls inferred from this helper
					local v11

					if string.sub(value, 1, 1) == "w" then
						v11 = v3.w
					else
						v11 = v3.b
					end

					return v11[string.sub(value, 2, 2) == "A" and 1 or 2]
				end

				local v11 = {
					wA = "White keys: first colour",
					wB = "White keys: second colour",
					bA = "Black keys: first colour",
					bB = "Black keys: second colour"
				}
				local fn3
				local function swatch(parent, value: string)
					local anchor2 = b({
						w = 40,
						h = 26,
						r = 7,
						bd = 1,
						bdc = "line",
						bg = { c = slot(value), a = 1 }, -- inferred equivalent call
						button = true,
						hov = { bdc = "ink" },
						parent = parent
					})
					anchor2:bindHover()
					v10[value] = anchor2
					anchor2:onClick(function()
						local v12 = value == "wA" and not v3.wGrad

						if not v12 then
							if value == "bA" then
								v12 = not v3.bGrad
							else
								v12 = false
							end
						end

						local v13

						if v12 then
							v13 = value == "wA" and "White keys: colour" or "Black keys: colour"
						else
							v13 = v11[value]
						end

						openPicker(anchor2, v13, function()
							return slot(value) -- inferred equivalent call
						end, function(p)
							local v14

							if string.sub(value, 1, 1) == "w" then
								v14 = v3.w
							else
								v14 = v3.b
							end

							v14[string.sub(value, 2, 2) == "A" and 1 or 2] = p
							fn3()
							changed() -- inferred equivalent call
						end, callback4, callback5)
					end)
					return anchor2
				end

				local function lineFor(p: string)
					local parent = b({
						dir = "row",
						align = "center",
						wrap = true,
						gap = 10,
						rowGap = 8,
						parent = parent3
					})
					t({
						t = p,
						f = "s500_14",
						lh = 20.3,
						w = 86,
						parent = parent
					})
					return parent
				end

				local parent = lineFor("White keys")
				callback3(parent, {
					{ "solid", "One colour" },
					{ "grad", "Gradient" }
				}, v3.wGrad and "grad" or "solid", function(p)
					v3.wGrad = p == "grad"
					fn3()
					changed() -- inferred equivalent call
				end)
				local parent5 = b({ dir = "row", gap = 6, parent = parent })
				swatch(parent5, "wA")
				swatch(parent5, "wB")

				local v12 = {}
				local function flowRow(p: string)
					local v13 = b({
						dir = "row",
						align = "center",
						wrap = true,
						gap = 10,
						rowGap = 8,
						pad = { 0, 0, 0, 96 },
						parent = parent3
					})
					local v14 = p .. "Flow"
					local v15 = p .. "Speed"
					callback3(v13, {
						{ "off", "Still" },
						{ "along", "Flow along the keys" },
						{ "each", "Each key on its own" }
					}, not v3[v14] and "off" or v3[v14], function(p2)
						if p2 == "off" then
							p2 = false
						end

						v3[v14] = p2
						fn3()
						changed() -- inferred equivalent call
					end)
					local v16 = b({ dir = "row", align = "center", gap = 8, parent = v13 })
					t({ t = "Speed", f = "s500_13_44", parent = v16 })
					local v17 = t({
						t = v3[v15] .. "%",
						f = "m500_10_56",
						c = "muted",
						w = 40,
						align = "r"
					})
					v16:add(callback6(10, 300, 10, v3[v15], function(p2)
						v3[v15] = p2
						v17:setText(p2 .. "%")
						changed() -- inferred equivalent call
					end, 120))
					v16:add(v17)
					v12[p] = { row = v13, sp = v16 }
					return v13
				end

				flowRow("w")

				local parent6 = lineFor("Black keys")
				callback3(parent6, {
					{ "same", "Like white" },
					{ "solid", "One colour" },
					{ "grad", "Gradient" }
				}, v3.bOwn and (v3.bGrad and "grad" or "solid") or "same", function(p)
					v3.bOwn = p ~= "same"
					v3.bGrad = p == "grad"
					fn3()
					changed() -- inferred equivalent call
				end)
				local parent7 = b({ dir = "row", gap = 6, parent = parent6 })
				swatch(parent7, "bA")
				swatch(parent7, "bB")
				flowRow("b")

				local parent8 = lineFor("Glow")

				for _, v13 in { "w", "b" } do
					local v14 = v13 .. "Glow"
					local parent9 = b({ dir = "row", align = "center", gap = 8, parent = parent8 })
					t({
						t = v13 == "w" and "White keys" or "Black keys",
						f = "s500_13_44",
						parent = parent9
					})
					local v15 = t({
						t = v3[v14] .. "%",
						f = "m500_10_56",
						c = "muted",
						w = 40,
						align = "r"
					})
					parent9:add(callback6(0, 200, 10, v3[v14], function(p)
						v3[v14] = p
						v15:setText(p .. "%")
						changed() -- inferred equivalent call
					end, 110))
					parent9:add(v15)
				end

				parent3:add(note("A gradient can flow: along the keys it travels from key to key, or each key changes on its own. Black keys \"Like white\" flow with the white ones."))

				local v13 = b({
					h = 56,
					r = 8,
					bg = "stage",
					bd = 1,
					bdc = "line",
					clip = true,
					parent = parent3
				})
				local v14 = {
					false,
					true,
					false,
					true,
					false,
					false,
					true,
					false,
					true,
					false,
					true,
					false
				}
				local v15 = {}

				for i = 1, 24 do
					local v16 = img("glow", {
						ZIndex = 1,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(fx.glow.slice[1], fx.glow.slice[2], fx.glow.slice[3], fx.glow.slice[4])
					})
					v16.Parent = v13.inst
					local frame = Instance.new("Frame")
					frame.BorderSizePixel = 0
					frame.ZIndex = 2
					local uiCorner = Instance.new("UICorner", frame)
					uiCorner.CornerRadius = UDim.new(1, 0)
					frame.Parent = v13.inst
					table.insert(v15, {
						f = frame,
						g = v16,
						black = v14[(i - 1) % 12 + 1]
					})
				end

				fn3 = function()
					for k, v16 in v10 do
						local v17

						if k == "wA" then
							v17 = true
						else
							v17 = k == "wB" and v3.wGrad or k == "bA" and v3.bOwn

							if not v17 then
								if k == "bB" then
									v17 = v3.bOwn and v3.bGrad
								else
									v17 = false
								end
							end
						end

						v16:show(v17)
						v16.bg = { c = slot(k), a = 1 } -- inferred equivalent call
						v16:paint()
					end

					parent7:show(v3.bOwn)

					if v12.w then
						v12.w.row:show(v3.wGrad)
						v12.w.sp:show(v3.wFlow ~= false)
					end

					if v12.b then
						v12.b.row:show(v3.bOwn and v3.bGrad)
						v12.b.sp:show(v3.bFlow ~= false)
					end

					lay.dirty()
				end
				fn3()

				local renderSteppedConnection = RunService.RenderStepped:Connect(function()
					if not v3.on then
						return
					end

					local x = v13.inst.AbsoluteSize.X

					if x <= 0 then
						return
					end

					local v16 = v3.w[1]
					local v17

					if v3.wGrad then
						v17 = v3.w[2]
					end

					local v18 = {
						w = { v16, v17 },
						b = 0,
						fw = 0,
						fb = 0,
						gw = 0,
						gb = 0
					}
					local v19

					if v3.bOwn then
						v19 = { nil, nil }
						local v20 = v3.b[1]
						local v21

						if v3.bGrad then
							v21 = v3.b[2]
						end

						v19[1], v19[2] = v20, v21
					end

					v18.b = v19
					v18.fw = v3.wFlow and { v3.wFlow, v3.wSpeed / 100 } or nil
					v18.fb = v3.bFlow and { v3.bFlow, v3.bSpeed / 100 } or nil
					v18.gw = v3.wGlow / 100
					v18.gb = v3.bGlow / 100
					local v20 = math.max(1, u.stage._pw or 1000)
					local v21 = x / 24

					for k, v22 in v15 do
						local v23 = (k - 0.5) * v21
						local v24 = v22.black and 6 or 9
						local v25 = v22.black and 24 or 34
						local v26 = 44 - v25
						v22.f.Position = UDim2.fromOffset(math.floor(v23 - v24 / 2 + 0.5), v26)
						v22.f.Size = UDim2.fromOffset(v24, v25)
						local styleColor = f.styleColor(v18, v23 / x * v20, v22.black)
						v22.f.BackgroundColor3 = styleColor
						local styleGlow = f.styleGlow(v18, v22.black)
						local v27 = fx.glow.margin * math.max(1, styleGlow)
						local v28 = v24 + 2 * v27
						v22.g.SliceScale = math.min(1, v28 / fx.glow.w)
						v22.g.Position = UDim2.fromOffset(math.floor(v23 - v28 / 2 + 0.5), v26 - v27)
						v22.g.Size = UDim2.fromOffset(v28, v25 + 2 * v27)
						v22.g.ImageColor3 = styleColor
						v22.g.ImageTransparency = 1 - math.min(1, styleGlow)
					end
				end)
				v13.inst.Destroying:Connect(function()
					renderSteppedConnection:Disconnect()
				end)
				lay.dirty()
			end
			fn()
		else
			local v7 = btn("Get VIP")
			v6:add(v7)
			v7:onClick(function()
				f.closeDialog()

				if f.openShop then
					f.openShop()
				end
			end)
		end
	end
end