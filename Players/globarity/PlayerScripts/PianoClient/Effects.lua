return function(data)
	local f = data.F
	local _lay = data.Lay
	local fx = data.FX
	local img = data.img
	local RunService = game:GetService("RunService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Icons = require(ReplicatedStorage:WaitForChild("VP"):WaitForChild("Icons"))

	f.EFFECTS = {
		default = { name = "Pixels", desc = "Little sparks of light" },
		hearts = { name = "Hearts", desc = "Little hearts float up from every note" }
	}

	f.EFFECT_ORDER = { "default", "hearts" }
	function f.effectOf(instance)
		local noteFx = instance and instance:GetAttribute("NoteFx")

		if type(noteFx) == "string" and f.EFFECTS[noteFx] then
			return noteFx
		end

		return "default"
	end

	local heartfill = Icons.cells["heart-fill"]
	local color = Color3.new(1, 1, 1)

	local v = { dot = {}, heart = {}, core = {}, nglow = {} }
	local function make(p: string)
		if p == "nglow" then
			return img("glow", {
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(fx.glow.slice[1], fx.glow.slice[2], fx.glow.slice[3], fx.glow.slice[4])
			})
		end

		if p == "heart" then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.Image = Icons.image
			imageLabel.ImageRectOffset = Vector2.new(heartfill[1], heartfill[2])
			imageLabel.ImageRectSize = Vector2.new(heartfill[3], heartfill[3])
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			return imageLabel
		else
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0

			if p == "dot" then
				frame.Size = UDim2.fromOffset(2, 2)
				return frame
			end

			if p == "core" then
				local uiCorner = Instance.new("UICorner", frame)
				uiCorner.CornerRadius = UDim.new(1, 0)
			end

			return frame
		end
	end

	local function get(p: string, parent, zIndex: number)
		local selected = table.remove(v[p]) or make(p)
		selected.ZIndex = zIndex
		selected.Parent = parent
		return selected
	end

	local v2 = {}

	local function stepDot(data2, p: number, backgroundTransparency: number) -- 1 equivalent call inferred from this helper
		data2.f.Position = UDim2.fromOffset(
			math.floor(data2.x + data2.vx * p + 0.5),
			(math.floor(data2.y + data2.vy * p + p * 60 * p + 0.5))
		)
		data2.f.BackgroundTransparency = backgroundTransparency
	end
	local function pixels(parent, p: number, p2: number, p3: number, color2: Color3, flag: boolean, zIndex: number, now: number, flag2: boolean, p4: number)
		for _ = 1, flag2 and 3 or 9 do
			local v3 = table.remove(v.dot)

			if not v3 then
				v3 = Instance.new("Frame")
				v3.BorderSizePixel = 0

				v3.Size = UDim2.fromOffset(2, 2)
			end

			v3.ZIndex = zIndex
			v3.Parent = parent
			local backgroundColor

			if flag then
				backgroundColor = f.rainbow(p, math.random() * 0.5)
			else
				backgroundColor = color2
			end

			v3.BackgroundColor3 = backgroundColor
			local v4 = {
				host = parent,
				parts = {
					{ "dot", v3 }
				},
				f = v3,
				t0 = now,
				life = 0.35 + math.random() * 0.35,
				x = p + (math.random() - 0.5) * p3 * 0.6,
				y = p2 - 2,
				vx = (math.random() - 0.5) * 70 * p4,
				vy = -(40 + math.random() * 120) * p4,
				step = stepDot
			}
			stepDot(v4, 0, 0) -- inferred equivalent call
			table.insert(v2, v4)
		end
	end

	local function stepHeart(data2, p: number, p2: number)
		local v3

		if p2 < 0.12 then
			v3 = p2 * 1.25 / 0.12
		else
			v3 = (math.max)(0, 1 - (p2 - 0.12) / 0.15) * 0.25 + 1
		end

		local v4 = data2.size * v3
		data2.f.Size = UDim2.fromOffset(v4, v4)
		data2.f.Position = UDim2.fromOffset(
			data2.x + math.sin(p * data2.fr + data2.ph) * data2.sway,
			data2.y + data2.vy * p
		)
		data2.f.Rotation = math.sin(p * data2.fr + data2.ph + 0.8) * 12
		data2.f.ImageTransparency = p2 < 0.55 and 0 or ((p2 - 0.55) / 0.45) ^ 1.5
	end
	local function hearts(parent, p: number, p2: number, p3: number, color2: Color3, flag: boolean, p4: number, now: number, flag2: boolean, p5: number)
		local v3 = math.clamp(p3 * 0.46, 6, 26)

		for i = 1, flag2 and 2 or 4 do
			local zIndex = p4 - 3
			local v4 = table.remove(v.heart)

			if not v4 then
				v4 = Instance.new("ImageLabel")
				v4.BackgroundTransparency = 1
				v4.BorderSizePixel = 0
				v4.Image = Icons.image
				v4.ImageRectOffset = Vector2.new(heartfill[1], heartfill[2])
				v4.ImageRectSize = Vector2.new(heartfill[3], heartfill[3])
				v4.AnchorPoint = Vector2.new(0.5, 0.5)
			end

			v4.ZIndex = zIndex
			v4.Parent = parent
			local v5

			if flag then
				v5 = f.rainbow(p, math.random() * 0.5)
			else
				v5 = color2
			end

			v4.ImageColor3 = v5:Lerp(color, 0.12)
			local v6 = {
				host = parent,
				parts = {
					{ "heart", v4 }
				},
				f = v4,
				t0 = now,
				life = 0.8 + math.random() * 0.35,
				x = p + (i - 2.5) * v3 * 0.5 + (math.random() - 0.5) * v3 * 0.4,
				y = p2 - v3 * (0.4 + math.random() * 0.5),
				vy = -(18 + math.random() * 24) * p5,
				size = 5 + math.random() * 2,
				sway = 2 + math.random() * 3,
				fr = 4 + math.random() * 2,
				ph = math.random() * 6.3,
				step = stepHeart
			}
			stepHeart(v6, 0, 0)
			table.insert(v2, v6)
		end
	end

	function f.burst(p, p2: number, p3: number, p4: number, color2: Color3, p5: string?, flag: boolean?, value: number?, value2: number?)
		local v3 = #v2 > 450
		local v4 = value2 or 1

		if p5 == "hearts" then
			hearts(p, p2, p3, p4, color2, flag == true, value or 4, os.clock(), v3, v4)
		else
			pixels(p, p2, p3, p4, color2, flag == true, value or 4, os.clock(), v3, v4)
		end
	end

	function f:barFx(_: string?)
		self.fxStep = nil
	end

	RunService.RenderStepped:Connect(function()
		if #v2 == 0 then
			return
		end

		local now = os.clock()
		local v3 = 1

		while v3 <= #v2 do
			local v4 = v2[v3]
			local v5 = now - v4.t0
			local v6 = v5 / v4.life

			if v6 >= 1 or v4.host.Parent == nil then
				local v7 = v4.host.Parent ~= nil

				for _, part in v4.parts do
					if not v7 then
						continue
					end

					part[2].Parent = nil
					table.insert(v[part[1]], part[2])
				end

				v2[v3] = v2[#v2]
				v2[#v2] = nil
			else
				v4.step(v4, v5, (math.min(1, v6)))
				v3 += 1
			end
		end
	end)

	local function stepNote(data2, p: number, _: number)
		local bar = data2.bar
		local v3 = data2.y - data2.v * p
		local v4

		if data2.hold < p then
			v4 = data2.y - data2.v * (p - data2.hold)
		else
			v4 = data2.y
		end

		local v5 = v4 - v3

		if v5 < bar.w then
			v3 = v4 - bar.w
			v5 = bar.w
		end

		bar.fill.Position = UDim2.fromOffset(bar.x - bar.w / 2, v3)
		bar.fill.Size = UDim2.fromOffset(bar.w, v5)
		local v6 = bar.w + 2 * bar.gm
		bar.glow.SliceScale = math.min(1, v6 / fx.glow.w)
		bar.glow.Position = UDim2.fromOffset(bar.x - v6 / 2, v3 - bar.gm)
		bar.glow.Size = UDim2.fromOffset(v6, v5 + 2 * bar.gm)
	end
	local function previewNote(frame, p: number, p2: number, p3: number, color2: Color3, zIndex: number, p4: number)
		local zIndex2 = zIndex + 1
		local fill = table.remove(v.core)

		if not fill then
			fill = Instance.new("Frame")
			fill.BorderSizePixel = 0

			local uiCorner = Instance.new("UICorner", fill)
			uiCorner.CornerRadius = UDim.new(1, 0)
		end

		fill.ZIndex = zIndex2
		fill.Parent = frame

		fill.BackgroundColor3 = color2
		fill.BackgroundTransparency = 0
		local glow = table.remove(v.nglow)
			or img("glow", {
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(fx.glow.slice[1], fx.glow.slice[2], fx.glow.slice[3], fx.glow.slice[4])
			})
		glow.ZIndex = zIndex
		glow.Parent = frame

		glow.ImageColor3 = color2
		glow.ImageTransparency = 0.15
		local bar = {
			fill = fill,
			glow = glow,
			w = p3,
			x = p,
			gm = fx.glow.margin * 0.6
		}
		local v3 = math.max(150, p2 * 0.7) * p4
		local v4 = {
			host = frame,
			parts = {
				{ "core", fill },
				{ "nglow", glow }
			},
			bar = bar,
			t0 = os.clock(),
			life = (p2 + p3 * 4) / v3 + 0.3,
			y = p2,
			v = v3,
			hold = 0.08 + math.random() * 0.25,
			step = stepNote
		}
		stepNote(v4, 0, 0)
		table.insert(v2, v4)
	end
	function f.effectPreview(p, p2: string, value: number?)
		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 1)
		frame.ClipsDescendants = true
		frame.ZIndex = 66
		frame.Parent = p.inst

		local v3 = (value or 84) - 26
		local v4 = math.random()
		task.spawn(function()
			while frame.Parent do
				local lw = p.lw or 0

				if lw > 20 then
					v4 = (v4 + 0.17) % 1
					local color2 = Color3.fromHSV(v4, 0.6, 1)
					local v5 = math.floor(lw / 2)
					previewNote(frame, v5, v3, 8, color2, 67, 0.6)
					f.burst(frame, v5, v3, 16, color2, p2, false, 67, 0.85)
				end

				task.wait(1.1)
			end
		end)
		return frame
	end
end