return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local p = data.P
	local a = data.A
	local lay = data.Lay
	local lp = data.LP
	local api = data.api
	local btn = data.btn
	local note = data.note
	local toast = data.toast
	local _l145 = data.L145
	local vp = data.VP
	local notes = data.Notes
	local pianoKeys = data.pianoKeys
	local gui = data.gui
	local talking = data.talking
	local lastPlay = data.lastPlay
	local colorOf = data.colorOf
	local audio = data.Audio
	local openDialog = data.openDialog
	local input = data.input
	local eyebrow = data.eyebrow
	local note2 = notes.NOTE
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local GuiService = game:GetService("GuiService")
	local TweenService = game:GetService("TweenService")
	local remotes = vp:WaitForChild("Remotes")
	local podium = remotes:WaitForChild("Podium")
	local note3 = remotes:WaitForChild("Note")
	local currentCamera = workspace.CurrentCamera
	local v = { "👏", "❤️", "🔥", "😂", "😮", "🎹" }
	local color = Color3.fromRGB(255, 226, 184)

	local v2 = {
		active = false,
		seats = {},
		seatOf = {},
		mods = {},
		hands = {},
		handAt = {},
		host = 0
	}
	local function amSpeaker(): boolean -- 6 equivalent calls inferred from this helper
		return v2.seatOf[lp.UserId] ~= nil
	end

	local function handFor(p2: number) -- 4 equivalent calls inferred from this helper
		local v3 = v2.handAt[p2]

		if not v3 then
			return ""
		end

		local v4 = math.max(0, (math.floor(workspace:GetServerTimeNow() - v3)))
		return string.format("%d:%02d", v4 // 60, v4 % 60)
	end

	local function canManage(): boolean -- 3 equivalent calls inferred from this helper
		return lp:GetAttribute("Admin") == true or v2.host == lp.UserId or v2.mods[lp.UserId] == true
	end

	local function hasIco(p2: string) -- 12 equivalent calls inferred from this helper
		return f.hasIcons() and f.Icons.cells[p2] ~= nil
	end

	local v3 = {}
	local folder = nil
	local podiumNotes = Instance.new("Folder")
	podiumNotes.Name = "PodiumNotes"
	local v4 = {}
	local v5 = {}
	local v6 = {}

	local function part(name: string, size: Vector3, cframe: CFrame, parent) -- 3 equivalent calls inferred from this helper
		local part2 = Instance.new("Part")
		part2.Name = name
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.CastShadow = false
		part2.Transparency = 1
		part2.Size = size
		part2.CFrame = cframe
		part2.Parent = parent
		return part2
	end

	local function addLight(model, pivot: CFrame)
		local v7 = { rings = {} }
		local lamp = model:FindFirstChild("Lamp")
		local spotLight = lamp and lamp:FindFirstChildOfClass("SpotLight")

		if not (lamp and spotLight) then
			return v7
		end

		local pointToWorldSpace = pivot:PointToWorldSpace(Vector3.new(0, 17, 2.4))
		local pointToWorldSpace2 = pivot:PointToWorldSpace(Vector3.new(0, 0, 1.2))
		lamp.CFrame = CFrame.lookAt(pointToWorldSpace, pointToWorldSpace2)
		spotLight.Angle = 30
		spotLight.Range = 30
		spotLight.Brightness = 0
		spotLight.Color = color
		v7.spot = spotLight

		local cframe = pivot * CFrame.new(0, 0.06, 1.2)
		local pool = f.Icons.pool or ""
		local parent = part("LightPool", Vector3.new(10, 0.05, 10), cframe, model) -- inferred equivalent call

		if pool == "" then
			local surfaceGui = Instance.new("SurfaceGui")
			surfaceGui.Face = Enum.NormalId.Top
			surfaceGui.LightInfluence = 0
			surfaceGui.CanvasSize = Vector2.new(200, 200)
			surfaceGui.Parent = parent

			for _, v8 in { 1, 0.8, 0.62, 0.46, 0.3 } do
				local frame = Instance.new("Frame")
				frame.AnchorPoint = Vector2.new(0.5, 0.5)
				frame.Position = UDim2.fromScale(0.5, 0.5)
				frame.Size = UDim2.fromScale(v8, v8)
				frame.BackgroundColor3 = color
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				local uiCorner = Instance.new("UICorner", frame)
				uiCorner.CornerRadius = UDim.new(0.5, 0)
				frame.Parent = surfaceGui
				table.insert(v7.rings, frame)
			end
		else
			local decal = Instance.new("Decal")
			decal.Face = Enum.NormalId.Top
			decal.Texture = pool
			decal.Color3 = color
			decal.Transparency = 1
			decal.Parent = parent
			v7.decal = decal
		end

		local parent2 = part("Dust", Vector3.new(3.5, 12, 3.5), pivot * CFrame.new(0, 7.5, 1.6), model) -- inferred equivalent call
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particleEmitter.Shape = Enum.ParticleEmitterShape.Box
		particleEmitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		particleEmitter.Rate = 0
		particleEmitter.Lifetime = NumberRange.new(4, 7)
		particleEmitter.Speed = NumberRange.new(0.1, 0.35)
		particleEmitter.SpreadAngle = Vector2.new(180, 180)
		particleEmitter.Size = NumberSequence.new(0.07, 0.12)
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.25, 0.35),
			NumberSequenceKeypoint.new(0.75, 0.35),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.LightEmission = 1
		particleEmitter.LightInfluence = 0
		particleEmitter.Color = ColorSequence.new(color)
		particleEmitter.Drag = 1
		particleEmitter.Parent = parent2
		v7.dust = particleEmitter
		return v7
	end

	local function setLight(light, p2: number)
		if light.spot then
			light.spot.Brightness = p2 * 7.5 + 0.5
		end

		if light.decal then
			light.decal.Transparency = 1 - p2 * 0.7
		end

		for _, ring in light.rings do
			ring.BackgroundTransparency = 1 - p2 * 0.07
		end

		if light.dust then
			light.dust.Rate = not (p2 > 0.15) and 0 or p2 * 7
		end
	end

	local function addTag(model, pivot: CFrame)
		local parent = part("NameTag", Vector3.new(0.2, 0.2, 0.2), pivot * CFrame.new(0, 7.6, 2.6), model) -- inferred equivalent call
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.fromOffset(200, 26)
		billboardGui.LightInfluence = 0
		billboardGui.MaxDistance = 140
		billboardGui.Parent = parent
		local textLabel = Instance.new("TextLabel")
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.Position = UDim2.fromScale(0.5, 0.5)
		textLabel.AutomaticSize = Enum.AutomaticSize.X
		textLabel.Size = UDim2.fromOffset(0, 24)
		textLabel.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
		textLabel.BackgroundTransparency = 0.35
		textLabel.TextColor3 = Color3.fromRGB(240, 236, 228)
		textLabel.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold)
		textLabel.TextSize = 15
		textLabel.Text = ""
		local uiCorner = Instance.new("UICorner", textLabel)
		uiCorner.CornerRadius = UDim.new(1, 0)
		local uiPadding = Instance.new("UIPadding")
		local udim = UDim.new(0, 10)
		local udim2 = UDim.new(0, 10)
		uiPadding.PaddingLeft = udim
		uiPadding.PaddingRight = udim2
		uiPadding.Parent = textLabel
		local uiStroke = Instance.new("UIStroke")
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Thickness = 1.5
		uiStroke.Color = Color3.fromRGB(60, 58, 54)
		uiStroke.Parent = textLabel
		textLabel.Parent = billboardGui
		return { label = textLabel, stroke = uiStroke, uid = 0, look = "" }
	end

	local function scan(model)
		if not model:IsA("Model") then
			return
		end

		local seat = tonumber(model:GetAttribute("Seat"))

		if not seat then
			return
		end

		local keys = nil

		for _ = 1, 300 do
			local keys2 = model:FindFirstChild("Keys")
			keys = keys2 and keys2:FindFirstChild("Keys")

			if keys and #keys:GetChildren() >= 88 then
				break
			end

			task.wait(0.1)
		end

		if not (keys and model.Parent) then
			return
		end

		local pivot = model:GetPivot()
		local rot = pivot - pivot.Position
		local parts = {}

		for _, part2 in keys:GetChildren() do
			if part2:IsA("BasePart") then
				table.insert(parts, part2)
			end
		end

		if #parts ~= 88 then
			return
		end

		local v7 = {}

		for _, v8 in parts do
			v7[v8] = pivot:PointToObjectSpace(v8.Position).X
		end

		table.sort(parts, function(a2, b2): boolean
			return v7[a2] < v7[b2]
		end)
		local keys2 = {}

		for k, part2 in parts do
			local v8 = 20 + k
			local pointToObjectSpace = pivot:PointToObjectSpace(part2.Position)

			local pointToWorldSpace = pivot:PointToWorldSpace((Vector3.new(
				pointToObjectSpace.X,
				pointToObjectSpace.Y + part2.Size.Y / 2,
				pointToObjectSpace.Z - part2.Size.Z / 2 + 0.22
			)))
			keys2[v8] = {
				part = part2,
				cf = part2.CFrame,
				col = part2.Color,
				black = notes.isBlack(v8),
				base = pointToWorldSpace,
				w = part2.Size.X
			}
		end

		v3[seat] = {
			model = model,
			keys = keys2,
			cf = pivot,
			rot = rot,
			pos = pivot.Position,
			light = addLight(model, pivot),
			tag = addTag(model, pivot),
			glow = 0,
			shown = -1
		}
	end

	local function updateLights(p2: number)
		local now = os.clock()

		for k, v7 in v3 do
			local seat = v2.seats[k]
			local v8 = seat and lastPlay[seat]
			local v9

			if v8 == nil then
				v9 = false
			else
				v9 = now - v8 < 0.5
			end

			v7.glow += ((v9 and 1 or 0) - v7.glow) * (1 - math.exp(-p2 * (v9 and 4 or 0.35)))
			local shown = math.floor(v7.glow * 100 + 0.5) / 100

			if shown ~= v7.shown then
				v7.shown = shown
				setLight(v7.light, shown)
			end

			local tag = v7.tag

			if not tag then
				continue
			end

			if tag.uid ~= seat then
				tag.uid = seat
				local playerByUserId = seat and Players:GetPlayerByUserId(seat)
				tag.label.Text = not playerByUserId and "" or playerByUserId.DisplayName
				tag.label.Visible = playerByUserId ~= nil
			end

			local look = seat and talking[seat] and "talk" or v9 and "play" or ""

			if look == tag.look then
				continue
			end

			tag.look = look
			local stroke = tag.stroke
			local color2

			if look == "talk" then
				color2 = Color3.fromRGB(74, 222, 128)
			elseif look == "play" then
				color2 = Color3.fromRGB(214, 170, 92)
			else
				color2 = Color3.fromRGB(60, 58, 54)
			end

			stroke.Color = color2
		end
	end

	local function newBar()
		local v7 = table.remove(v6)

		if v7 then
			return v7
		end

		local part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.CastShadow = false
		part2.Material = Enum.Material.Neon
		return part2
	end

	local function barColor(p2: number, p3: number)
		local playerByUserId = Players:GetPlayerByUserId(p2)

		if playerByUserId and playerByUserId:GetAttribute("Rainbow") == true then
			return Color3.fromHSV((p3 / 40 + os.clock() * 0.18) % 1, 0.6, 1)
		end

		if p2 == lp.UserId then
			return Color3.fromHex("7aa7ff")
		end

		return colorOf(p2)
	end

	local v7 = {}
	local v8 = {}
	local function placeBar(state, p2: number): boolean
		local v9 = not state.t1 and 0 or (p2 - state.t1) * 5

		if v9 > 13 then
			return false
		end

		local v10 = math.max(((state.t1 or p2) - state.t0) * 5, state.w)
		local cframe = CFrame.new(state.base + Vector3.new(0, v9 + v10 / 2, 0)) * state.rot

		if state.h == v10 then
			table.insert(v7, state.p)
			table.insert(v8, cframe)
		else
			state.h = v10
			state.p.Size = Vector3.new(state.w, v10, 0.1)
			state.p.CFrame = cframe
		end

		if v9 > 7 then
			state.p.Transparency = math.clamp((v9 - 7) / 6, 0, 1) * 0.9 + 0.08
		end

		return true
	end

	local function keyUp(p2: number, p3: number)
		local v9 = p2 .. ":" .. p3
		local v10 = v4[v9]

		if not v10 then
			return
		end

		v4[v9] = nil

		if v10.kd.part.Parent then
			v10.kd.part.CFrame = v10.kd.cf
			v10.kd.part.Color = v10.kd.col
		end

		if not v10.bar.t1 then
			v10.bar.t1 = os.clock()
		end
	end
	local function keyDown(p2: number, p3: number, p4: number)
		local v9 = v3[p2]
		local kd = v9 and v9.keys[p3]

		if not kd then
			return
		end

		keyUp(p2, p3)
		local color2 = barColor(p4, p3)

		kd.part.CFrame = kd.cf * CFrame.new(0, -0.04, 0) * CFrame.Angles(0.05235987755982989, 0, 0)
		kd.part.Color = kd.col:Lerp(color2, 0.55)
		local v10 = table.remove(v6)

		if not v10 then
			v10 = Instance.new("Part")
			v10.Anchored = true
			v10.CanCollide = false
			v10.CanQuery = false
			v10.CanTouch = false
			v10.CastShadow = false
			v10.Material = Enum.Material.Neon
		end

		v10.Color = color2
		v10.Transparency = 0.08
		local bar = {
			p = v10,
			base = kd.base,
			rot = v9.rot,
			w = kd.w * (kd.black and 0.9 or 0.8),
			t0 = os.clock(),
			t1 = nil,
			h = 0
		}
		placeBar(bar, bar.t0)

		if v10.Parent ~= podiumNotes then
			v10.Parent = podiumNotes
		end

		table.insert(v5, bar)
		v4[p2 .. ":" .. p3] = { kd = kd, bar = bar }
	end
	local function releaseSeat(k: number)
		local v9 = k .. ":"

		for k2 in table.clone(v4) do
			if string.sub(k2, 1, #v9) == v9 then
				keyUp(k, tonumber((string.sub(k2, #v9 + 1))))
			end
		end
	end
	RunService.RenderStepped:Connect(function()
		if #v5 == 0 then
			return
		end

		local now = os.clock()
		local count = 0

		for i = 1, #v5 do
			local v9 = v5[i]

			if placeBar(v9, now) then
				count += 1
				v5[count] = v9
			else
				v9.p.Transparency = 1
				table.insert(v6, v9.p)
			end
		end

		for i = #v5, count + 1, -1 do
			v5[i] = nil
		end

		if #v7 > 0 then
			workspace:BulkMoveTo(v7, v8, Enum.BulkMoveMode.FireCFrameChanged)
			table.clear(v7)
			table.clear(v8)
		end
	end)

	note3.OnClientEvent:Connect(function(value, p2, p3, _, _, value2)
		if not v2.active or p.muteAll or type(value) ~= "number" then
			return
		end

		local v9 = v2.seatOf[value]

		if not v9 then
			return
		end

		if type(value2) ~= "number" then
			value2 = note2[p2]
		end

		if type(value2) ~= "number" then
			return
		end

		if p3 then
			keyDown(v9, value2, value)
		else
			keyUp(v9, value2)
		end
	end)

	local v9 = {}
	local v10 = nil
	RunService.Heartbeat:Connect(function()
		local v11

		if v2.active then
			v11 = v2.seatOf[lp.UserId]
		end

		if v11 ~= v10 then
			if v10 then
				for k in v9 do
					keyUp(v10, k)
				end
			end

			table.clear(v9)
			v10 = v11
		end

		if not v11 then
			return
		end

		local set = {}

		for k in a.held do
			local v12 = note2[k]

			if v12 then
				set[v12 + a.transpose] = true
			end
		end

		for k, pianoKey in pianoKeys do
			if pianoKey.down then
				set[k] = true
			end
		end

		for k in set do
			if not v9[k] then
				keyDown(v11, k, lp.UserId)
			end
		end

		for k in v9 do
			if not set[k] then
				keyUp(v11, k)
			end
		end

		v9 = set
	end)

	local podiumMask = Instance.new("ScreenGui")
	podiumMask.Name = "PodiumMask"
	podiumMask.IgnoreGuiInset = true
	podiumMask.ScreenInsets = Enum.ScreenInsets.None
	podiumMask.ResetOnSpawn = false
	podiumMask.DisplayOrder = 0
	podiumMask.Enabled = false
	podiumMask.Parent = gui.Parent
	local v11 = {}

	for i = 1, 4 do
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.Parent = podiumMask
		v11[i] = frame
	end

	local function stageRect() -- 1 equivalent call inferred from this helper
		local inst = u.stage.inst
		local guiInset = GuiService:GetGuiInset()
		return
			inst.AbsolutePosition.X + guiInset.X,
			inst.AbsolutePosition.Y + guiInset.Y,
			inst.AbsoluteSize.X,
			inst.AbsoluteSize.Y
	end

	local v12 = {
		pos = nil,
		look = nil,
		shot = nil,
		prevKind = "",
		focusKey = ""
	}
	local v13 = { "behind", "orbit", "hands", "lid", "crane", "behind", "orbit" }
	local v14 = { "behind", "orbit", "crane", "orbit" }
	local function pick(list)
		local prevKind = nil

		for _ = 1, 6 do
			prevKind = list[math.random(1, #list)]

			if prevKind ~= v12.prevKind then
				break
			end
		end

		v12.prevKind = prevKind
		return prevKind
	end

	local function newShot(flag: boolean)
		local v15 = if flag then v14 else v13
		v12.shot = {
			kind = pick(v15),
			t0 = os.clock(),
			dur = 7 + math.random() * 4,
			side = math.random() < 0.5 and -1 or 1,
			a0 = (math.random() * 2 - 1) * 1.1
		}
	end
	local function smooth(p2: number) -- 1 equivalent call inferred from this helper
		return p2 * p2 * (3 - p2 * 2)
	end

	local function around(cf: CFrame, vector3: Vector3, p2: number, p3: number, p4: number) -- 1 equivalent call inferred from this helper
		return vector3 + cf:VectorToWorldSpace((Vector3.new(
			math.sin(p2) * math.cos(p3),
			math.sin(p3),
			math.cos(p2) * math.cos(p3)
		))) * p4
	end

	local function updateView(p2: number)
		local viewportSize = currentCamera.ViewportSize

		if viewportSize.X < 2 or viewportSize.Y < 2 then
			return
		end

		local v15, v16, v17, v18 = stageRect() -- inferred equivalent call
		local absolutePosition = podiumMask.AbsolutePosition
		local guiInset = GuiService:GetGuiInset()
		local v19 = absolutePosition.X + guiInset.X
		local v20 = absolutePosition.Y + guiInset.Y
		local x = podiumMask.AbsoluteSize.X
		local y = podiumMask.AbsoluteSize.Y
		local c = lay.TH.bg.c
		local v21 = v15 - v19
		local v22 = v16 - v20

		for k, v23 in {
			{ 0, 0, x, v22 },
			{
				0,
				v22 + v18,
				x,
				y - v22 - v18
			},
			{ 0, v22, v21, v18 },
			{
				v21 + v17,
				v22,
				x - v21 - v17,
				v18
			}
		} do
			local v24 = v11[k]
			v24.BackgroundColor3 = c
			v24.Position = UDim2.fromOffset(math.floor(v23[1]), (math.floor(v23[2])))
			v24.Size = UDim2.fromOffset(math.ceil((math.max(0, v23[3]))), (math.ceil((math.max(0, v23[4])))))
		end

		local now = os.clock()
		local v23 = {}

		for k, seat in v2.seats do
			local v24 = lastPlay[seat]

			if v3[k] and v24 and now - v24 < 2.5 then
				table.insert(v23, k)
			end
		end

		if #v23 == 0 then
			for k in v2.seats do
				if v3[k] then
					table.insert(v23, k)
				end
			end
		end

		table.sort(v23)
		local joined = table.concat(v23, ",")

		if joined ~= v12.focusKey or not v12.shot then
			v12.focusKey = joined
			newShot(#v23 > 1)
		end

		local shot = v12.shot
		local v24 = math.clamp((now - shot.t0) / shot.dur, 0, 1)

		if v24 >= 1 then
			newShot(#v23 > 1)
			shot = v12.shot
			v24 = 0
		end

		local v25 = smooth(v24) -- inferred equivalent call
		local v26 = math.tan(math.rad(currentCamera.FieldOfView) / 2)
		local v27 = math.max(0.02, math.min(v17, v18) / viewportSize.Y * v26)
		local function fit(p3: number) -- 1 equivalent call inferred from this helper
			return p3 / math.sin((math.atan(v27)))
		end

		local look, pos

		if #v23 == 1 then
			local cf = v3[v23[1]].cf
			look = cf:PointToWorldSpace(Vector3.new(0, 4.2, 0.4))
			local v28 = math.max(fit(6.5), 10) -- inferred equivalent call
			local kind = shot.kind

			if kind == "behind" then
				pos = around( -- inferred equivalent call
					cf,
					look,
					shot.side * (0.32 - v25 * 0.18),
					math.rad(36 - v25 * 5),
					v28 * (1.12 - v25 * 0.16)
				)
			elseif kind == "orbit" then
				local v29 = shot.a0 + shot.side * v25 * 0.7853981633974483
				local v30 = v28 * 1.05
				pos = look + cf:VectorToWorldSpace((Vector3.new(
					math.sin(v29) * 0.898794046299167,
					0.4383711467890774,
					math.cos(v29) * 0.898794046299167
				))) * v30
			elseif kind == "hands" then
				local side = shot.side
				pos = cf:PointToWorldSpace((Vector3.new(side * (8.2 - v25 * 2.2), 5.2, 3.2 - v25 * 0.6)))
				look = cf:PointToWorldSpace((Vector3.new(side * 0.8, 4.2, -0.4)))
			elseif kind == "lid" then
				pos = cf:PointToWorldSpace((Vector3.new(9.5 - v25 * 1.5, 6.4 - v25 * 0.8, v25 * 2.5 + -3.5)))
				look = cf:PointToWorldSpace(Vector3.new(0, 4.8, 1.6))
			else
				local v29 = shot.a0 * 0.35 + shot.side * v25 * 0.5235987755982988
				local v30 = v28 * 1.15
				pos = look + cf:VectorToWorldSpace((Vector3.new(
					math.sin(v29) * 0.43837114678907746,
					0.898794046299167,
					math.cos(v29) * 0.43837114678907746
				))) * v30

				look = cf:PointToWorldSpace(Vector3.new(0, 3.8, -0.6))
			end
		elseif #v23 > 1 then
			local total = Vector3.new(0, 0, 0)
			local total2 = 0
			local total3 = 0

			for _, v28 in v23 do
				local v29 = v3[v28]
				total += v29.pos
				local lookVector = v29.cf.LookVector
				total2 += lookVector.X
				total3 += lookVector.Z
			end

			local average = total / #v23
			local maxMagnitude = 0

			for _, v28 in v23 do
				maxMagnitude = math.max(maxMagnitude, (v3[v28].pos - average).Magnitude)
			end

			local v28 = maxMagnitude + 7
			local cframe = CFrame.new(average) * CFrame.Angles(0, math.atan2(-total2, -total3), 0)
			look = average + Vector3.new(0, 4.2, 0)

			local v29 = math.max(0.02, v17 / viewportSize.Y * v26)
			local v30 = math.max(0.02, v18 / viewportSize.Y * v26)
			local v31 = math.max(v28 / v29, v28 * 0.55 / v30)
			local kind = shot.kind

			if kind == "behind" then
				local v32 = shot.side * (0.25 - v25 * 0.12)
				local v35 = v31 * (1.08 - v25 * 0.08)
				pos = look + cframe:VectorToWorldSpace((Vector3.new(
					math.sin(v32) * 0.8290375725550416,
					0.5591929034707469,
					math.cos(v32) * 0.8290375725550416
				))) * v35
			elseif kind == "orbit" then
				local v32 = shot.a0 * 0.6 + shot.side * v25 * 0.5585053606381855
				pos = look + cframe:VectorToWorldSpace((Vector3.new(
					math.sin(v32) * 0.8660254037844387,
					0.49999999999999994,
					math.cos(v32) * 0.8660254037844387
				))) * v31
			else
				local v32 = shot.a0 * 0.3 + shot.side * v25 * 0.4188790204786391
				local v35 = v31 * 1.05
				pos = look + cframe:VectorToWorldSpace((Vector3.new(
					math.sin(v32) * 0.5299192642332049,
					0.848048096156426,
					math.cos(v32) * 0.5299192642332049
				))) * v35
			end
		else
			local floor = folder and folder:FindFirstChild("Floor")
			look = not floor and Vector3.new(0, 303, 0) or floor.Position + Vector3.new(0, 3, 0)
			local cframe = CFrame.new(look)
			local v28 = now * 0.05
			pos = look + cframe:VectorToWorldSpace((Vector3.new(
				math.sin(v28) * 0.9135454576426009,
				0.4067366430758002,
				math.cos(v28) * 0.9135454576426009
			))) * 30
		end

		local v28 = 1 - math.exp(-p2 * 1.3)

		if v12.pos then
			pos = v12.pos:Lerp(pos, v28)
		end

		v12.pos = pos

		if v12.look then
			look = v12.look:Lerp(look, v28)
		end

		v12.look = look
		local cframe = CFrame.lookAt(v12.pos, v12.look)

		local v29 = v15 + v17 / 2
		local v30 = v16 + v18 / 2
		local unit = Vector3.new(
			(v29 - viewportSize.X / 2) / (viewportSize.Y / 2) * v26,
			-(v30 - viewportSize.Y / 2) / (viewportSize.Y / 2) * v26,
			-1
		).Unit
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = cframe * CFrame.fromRotationBetweenVectors(unit, Vector3.new(0, 0, -1))
	end

	local v15 = {}
	local v16 = 0
	local v17 = {}
	local function fadeNear()
		local now = os.clock()

		if now - v16 > 1 then
			v16 = now
			table.clear(v15)

			for _, v18 in Players:GetPlayers() do
				if v18.Character then
					table.insert(v15, v18.Character)
				end
			end

			if folder then
				for _, humanoid in folder:GetDescendants() do
					if
						not humanoid:IsA("Humanoid")
						or not humanoid.Parent
						or not humanoid.Parent:IsA("Model")
						or Players:GetPlayerFromCharacter(humanoid.Parent)
					then
						continue
					end

					table.insert(v15, humanoid.Parent)
				end
			end
		end

		local position = currentCamera.CFrame.Position

		for _, folder2 in v15 do
			local head = folder2:FindFirstChild("Head")

			if not head then
				continue
			end

			local localTransparencyModifier = math.clamp((7 - (head.Position - position).Magnitude) / 3, 0, 1)

			if not (localTransparencyModifier > 0 or v17[head]) then
				continue
			end

			for _, part2 in folder2:GetDescendants() do
				if part2:IsA("BasePart") then
					part2.LocalTransparencyModifier = localTransparencyModifier
				end
			end

			v17[head] = localTransparencyModifier > 0 or nil
		end
	end

	local v18 = {}
	local function thumb(userId: number, imageLabel) -- 1 equivalent call inferred from this helper
		if v18[userId] then
			imageLabel.Image = v18[userId]
		else
			task.spawn(function()
				local success, result = pcall(function()
					return Players:GetUserThumbnailAsync(
						userId,
						Enum.ThumbnailType.HeadShot,
						Enum.ThumbnailSize.Size150x150
					)
				end)

				if success and type(result) == "string" then
					v18[userId] = result

					if imageLabel.Parent then
						imageLabel.Image = result
					end
				end
			end)
		end
	end
	local v19 = {}
	local function circle(p2, p3: number, parent)
		local v20 = b({
			w = p3,
			h = p3,
			r = "pill",
			bg = "panel2",
			bd = 2,
			bdc = "line",
			noShrink = true,
			button = true,
			parent = parent
		})
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.BackgroundTransparency = 1
		imageLabel.Size = UDim2.new(1, -6, 1, -6)
		imageLabel.Position = UDim2.fromOffset(3, 3)
		local uiCorner = Instance.new("UICorner", imageLabel)
		uiCorner.CornerRadius = UDim.new(1, 0)
		imageLabel.Parent = v20.inst
		thumb(p2.UserId, imageLabel) -- inferred equivalent call
		v20:onClick(function()
			if f.openPlayerMenu then
				f.openPlayerMenu(p2, v20)
			end
		end)
		v19[p2.UserId] = v20
		return v20
	end

	local function badge(parent, p2: string, bg: string)
		local v20 = b({
			w = 20,
			h = 20,
			r = "pill",
			bg = bg,
			dir = "row",
			align = "center",
			justify = "center",
			abs = { t = -3, l = -3 },
			parent = parent
		})

		if f.hasIcons() then
			v20:add(f.ico(p2, 12, "bg"))
		end

		return v20
	end

	local function tbtn(p2: string, p3: string, p4: string, p5: string?, flag: boolean?) -- 1 equivalent call inferred from this helper
		if not f.hasIcons() or f.Icons.cells[p3] == nil then
			p2 = p4
		end

		local v20 = btn(p2, p5)

		if hasIco(p3) then -- inferred equivalent call
			f.iconify(v20, p3, 15, flag)
		end

		return v20
	end

	local v20 = nil
	local parent = nil
	local v21 = ""
	local function closePicker() -- 2 equivalent calls inferred from this helper
		if parent then
			parent:destroy()
			parent = nil
			lay.dirty()
		end
	end
	local function rebuild()
		if not v20 then
			return
		end

		v20.handBtn = nil
		v20.speakers:clear()
		v20.grid:clear()
		v20.tools:clear()
		table.clear(v19)

		local v22 = {}

		for k, seat in v2.seats do
			table.insert(v22, { k, seat })
		end

		table.sort(v22, function(a2, b2): boolean
			return a2[1] < b2[1]
		end)
		v20.podTitle:setText("On the podium · " .. #v22 .. "/6")
		local v23 = math.clamp(math.floor(v20.h * 0.36), 40, 64)

		for _, v24 in v22 do
			local playerByUserId = Players:GetPlayerByUserId(v24[2])

			if not playerByUserId then
				continue
			end

			local parent2 = b({
				dir = "col",
				align = "center",
				gap = 2,
				w = v23 + 22,
				parent = v20.speakers
			})
			local parent3 = circle(playerByUserId, v23, parent2)

			if v24[2] == v2.host then
				badge(parent3, "crown", "brass")
			elseif v2.mods[v24[2]] then
				badge(parent3, "shield", "ink")
			end

			t({
				t = playerByUserId.DisplayName,
				f = "s600_13_6",
				lh = 19.7,
				ell = true,
				maxW = v23 + 22,
				align = "c",
				parent = parent2
			})
			parent3.status = t({
				t = " ",
				f = "s400_11_84",
				lh = 15,
				c = "muted",
				align = "c",
				parent = parent2
			})
		end

		if #v22 == 0 then
			b({
				dir = "col",
				gap = 3,
				pad = { 4, 0 },
				w = 210,
				parent = v20.speakers,
				{
					t({ t = "Nobody is on the podium", f = "s600_14_08", lh = 20.4 }),
					t({
						t = canManage() and "Press someone in the audience to bring them up." or "Raise your hand to ask to go up.", -- inferred equivalent call
						f = "s400_12_8",
						lh = 18.6,
						c = "muted",
						wrap = true
					})
				}
			})
		end

		local v24 = {}

		for _, v25 in Players:GetPlayers() do
			if not v2.seatOf[v25.UserId] then
				table.insert(v24, v25)
			end
		end

		v20.audTitle:setText("Audience · " .. #v24)
		v20.hint:show(not amSpeaker()) -- inferred equivalent call
		local v25 = string.lower(v21)
		table.sort(v24, function(a2, b2): boolean
			local index = table.find(v2.hands, a2.UserId) or 999
			local index2 = table.find(v2.hands, b2.UserId) or 999

			if index == index2 then
				return a2.DisplayName < b2.DisplayName
			end

			return index < index2
		end)

		local v26 = math.clamp(math.floor(v20.h * 0.26), 34, 48)
		local count = 0

		for _, v27 in v24 do
			if not (v25 == "" or string.find(string.lower(v27.DisplayName), v25, 1, true) or string.find(string.lower(v27.Name), v25, 1, true)) then
				continue
			end

			count += 1
			local parent2 = b({
				dir = "col",
				align = "center",
				gap = 2,
				w = v26 + 18,
				parent = v20.grid
			})
			local parent3 = circle(v27, v26, parent2)
			local index = table.find(v2.hands, v27.UserId)

			if index then
				local v28 = b({
					h = 18,
					minW = 18,
					pad = { 0, 5 },
					gap = 2,
					r = "pill",
					bg = "brass",
					dir = "row",
					align = "center",
					justify = "center",
					abs = { t = -5, r = -9 },
					parent = parent3
				})

				if hasIco("hand") then -- inferred equivalent call
					v28:add(f.ico("hand", 11, "bg"))
				end

				v28:add(t({
					t = (hasIco("hand") and "" or "✋") .. index, -- inferred equivalent call
					f = "m600_9_92",
					c = "bg"
				}))
			end

			t({
				t = v27.DisplayName,
				f = "s400_11_84",
				lh = 15,
				c = "muted",
				ell = true,
				maxW = v26 + 18,
				align = "c",
				parent = parent2
			})

			if index then
				parent3.timer = t({
					t = handFor(v27.UserId), -- inferred equivalent call
					f = "m500_11_52",
					c = "brassInk",
					align = "c",
					parent = parent2
				})
			end
		end

		if count == 0 then
			v20.grid:add(t({
				t = v25 == "" and "Everyone here is on the podium." or "Nobody by that name.",
				f = "s400_12_8",
				lh = 18.6,
				c = "muted"
			}))
		end

		if amSpeaker() then -- inferred equivalent call
			local _ico = hasIco("log-out") -- inferred equivalent call
			local v27 = btn("Leave the podium", nil)

			if hasIco("log-out") then -- inferred equivalent call
				f.iconify(v27, "log-out", 15, nil)
			end

			v20.tools:add(v27)
			v27:onClick(function()
				task.spawn(api, "podiumDown", lp.UserId)
			end)
		else
			local v27 = table.find(v2.hands, lp.UserId) ~= nil
			local handBtn = btn(
				hasIco("hand") and (v27 and "Lower hand" or "Raise hand") or v27 and "✋ Lower hand" or "✋ Raise hand", -- inferred equivalent call
				not v27 and "primary" or nil
			)

			if hasIco("hand") then -- inferred equivalent call
				f.iconify(handBtn, "hand", 15, nil)
			end

			v20.tools:add(handBtn)

			if v27 then
				local v28 = v20
				local v29 = v20
				local t2 = handBtn.label.t
				v28.handBtn = handBtn
				v29.handBase = t2
			end

			handBtn:onClick(function()
				task.spawn(function()
					local v28, v29 = api("podiumHand", not v27)

					if not v28 and v29 then
						toast((tostring(v29)))
					end
				end)
			end)
		end

		local v27 = btn(hasIco("smile-plus") and "" or "🙂", nil) -- inferred equivalent call

		if hasIco("smile-plus") then -- inferred equivalent call
			f.iconify(v27, "smile-plus", 15, true)
		end

		v20.tools:add(v27)
		v27:onClick(function()
			if parent then
				closePicker() -- inferred equivalent call
			else
				parent = b({
					dir = "row",
					gap = 4,
					pad = 6,
					r = 10,
					bg = "panel",
					bd = 1,
					bdc = "line",
					abs = {
						r = 12,
						b = v20.h - 4
					},
					z = 9,
					parent = u.main
				})

				for _, v28 in v do
					local v29 = b({
						w = 38,
						h = 38,
						r = 8,
						dir = "row",
						align = "center",
						justify = "center",
						button = true,
						hov = { bg = "white05" },
						parent = parent,
						{ t({ t = v28, f = "s600_16", lh = 23.2 }) }
					})
					v29:bindHover()
					v29:onClick(function()
						task.spawn(api, "podiumEmoji", v28)
					end)
				end

				lay.dirty()
			end
		end)

		if canManage() and #v2.hands > 0 then -- inferred equivalent call
			local v28 = tbtn("Hands · " .. #v2.hands, "hand", "✋ " .. #v2.hands, "primary") -- inferred equivalent call
			v20.tools:add(v28)
			v28:onClick(function()
				f.openHands()
			end)
		end

		lay.dirty()
	end
	local function buildPanel()
		local hf0 = u.piano.hf0 or u.piano.hf
		local v22 = b({
			name = "podPanel",
			dir = "row",
			bg = "panel",
			bds = { 1, 0, 0, 0 },
			bdc = "line",
			parent = u.kb
		})
		function v22.hf(...)
			return (math.floor((not hf0 and 176 or hf0(...)) * 1.35))
		end
		local v23 = v22.hf()

		local parent2 = b({
			dir = "col",
			gap = 6,
			pad = { 10, 16 },
			noShrink = true,
			parent = v22
		})
		local podTitle = eyebrow("On the podium")
		parent2:add(podTitle)
		local speakers = b({ dir = "row", gap = 6, align = "start", parent = parent2 })
		b({
			w = 1,
			bg = "line",
			m = { 12, 0, 12, 0 },
			noShrink = true,
			parent = v22
		})

		local parent3 = b({ dir = "col", grow = 1, shrink0 = true, parent = v22 })
		local parent4 = b({
			dir = "row",
			align = "center",
			gap = 8,
			pad = { 8, 12, 4, 16 },
			parent = parent3
		})
		local audTitle = eyebrow("Audience")
		parent4:add(audTitle)
		b({ grow = 1, parent = parent4 })
		local v24, v25 = input(parent4, "Search", { h = 30 })
		v24.w = 150
		v24.noShrink = true
		v25:GetPropertyChangedSignal("Text"):Connect(function()
			v21 = v25.Text
			rebuild()
		end)
		local tools = b({ dir = "row", gap = 6, noShrink = true, parent = parent4 })

		local hint = t({
			t = "Only you hear your piano: everyone hears just the people on the podium. Raise your hand to ask to go up.",
			f = "s400_12_8",
			lh = 18.6,
			c = "muted",
			wrap = true,
			pad = { 0, 16, 4, 16 },
			parent = parent3
		})
		v20 = {
			node = v22,
			h = v23,
			speakers = speakers,
			grid = b({
				dir = "row",
				wrap = true,
				gap = 8,
				rowGap = 6,
				pad = { 4, 16, 8, 16 },
				parent = b({
					scroll = true,
					grow = 1,
					vshrink = true,
					dir = "col",
					parent = parent3
				})
			}),
			tools = tools,
			podTitle = podTitle,
			audTitle = audTitle,
			hint = hint
		}
	end

	function f.openHands()
		local parent2 = b({ dir = "col", parent = openDialog("Raised hands") })

		if #v2.hands == 0 then
			parent2:add(note("Nobody has a hand up right now."))
		end

		for k, hand in v2.hands do
			local playerByUserId = Players:GetPlayerByUserId(hand)

			if not playerByUserId then
				continue
			end

			local parent3 = b({
				dir = "row",
				align = "center",
				gap = 10,
				pad = { 8, 0 },
				bds = { 0, 0, 1, 0 },
				bdc = "line",
				parent = parent2
			})
			t({
				t = k .. ".",
				f = "m600_12_48",
				c = "muted",
				noShrink = true,
				parent = parent3
			})
			t({
				t = playerByUserId.DisplayName,
				f = "s600_14_08",
				grow = 1,
				shrink0 = true,
				ell = true,
				parent = parent3
			})
			t({
				t = "✋ " .. handFor(hand), -- inferred equivalent call
				f = "m500_11_52",
				c = "muted",
				noShrink = true,
				parent = parent3
			})
			local _ico = hasIco("user-plus") -- inferred equivalent call
			local v22 = btn("Invite to the podium", "primary")

			if hasIco("user-plus") then -- inferred equivalent call
				f.iconify(v22, "user-plus", 15, nil)
			end

			parent3:add(v22)
			v22.noShrink = true
			v22:onClick(function()
				task.spawn(function()
					local v23, v24 = api("podiumUp", hand)

					if v23 then
						f.closeDialog()
					else
						toast((tostring(v24 or "Couldn't bring them up.")))
					end
				end)
			end)
		end
	end

	local function menuItem(parent2, p2: string, p3: string, callback)
		local v22 = b({
			dir = "row",
			align = "center",
			gap = 8,
			pad = { 7, 8 },
			r = 8,
			button = true,
			hov = { bg = "white05" },
			parent = parent2
		})

		if hasIco(p3) then -- inferred equivalent call
			v22:add(f.ico(p3, 15, "brassInk"))
		end

		v22:add(t({ t = p2, f = "s500_14", lh = 20.3, c = "brassInk" }))
		v22:bindHover()
		v22:onClick(function()
			if f.closePopup then
				f.closePopup()
			end

			task.spawn(function()
				local v23, v24 = callback()

				if v23 == false and v24 then
					toast((tostring(v24)))
				end
			end)
		end)
	end
	function f.podiumMenu(parent2, p2)
		if not v2.active then
			return
		end

		local userId = p2.UserId
		local v22 = v2.seatOf[userId] ~= nil
		local count = 0
		local function add(p3: string, p4: string, fn) -- 3 equivalent calls inferred from this helper
			count += 1
			menuItem(parent2, p3, p4, fn)
		end

		if p2 == lp then
			if v22 then
				local function fn()
					return api("podiumDown", userId)
				end

				add("Leave the podium", "log-out", fn) -- inferred equivalent call
			else
				local v23 = table.find(v2.hands, userId) ~= nil
				local function fn()
					return api("podiumHand", not v23)
				end

				count += 1
				menuItem(parent2, v23 and "Lower your hand" or "Raise your hand", "hand", fn)
			end
		elseif canManage() then -- inferred equivalent call
			if v22 then
				local function fn()
					return api("podiumDown", userId)
				end

				add("Move to the audience", "user-minus", fn) -- inferred equivalent call
			else
				local function fn()
					return api("podiumUp", userId)
				end

				add("Invite to the podium", "user-plus", fn) -- inferred equivalent call
			end

			if (lp.UserId == v2.host or lp:GetAttribute("Admin") == true) and userId ~= v2.host then
				local v23 = v2.mods[userId] == true
				local function fn()
					return api("podiumMod", {
						uid = userId,
						on = not v23
					})
				end

				count += 1
				menuItem(parent2, v23 and "Remove moderator" or "Make moderator", "shield", fn)
			end
		end

		if count > 0 then
			b({
				h = 1,
				bg = "line",
				m = { 2, 4, 2, 4 },
				parent = parent2
			})
		end
	end

	local function floatEmoji(uid: number, e: string)
		if not v20 then
			return
		end

		local v22 = v19[uid]
		local inst = u.main.inst
		local v23 = math.max(u.layerScale.Scale, 0.01)
		local v24, v25

		if v22 and v22.inst.Parent and v22.inst.AbsoluteSize.X > 0 then
			v24 = (v22.inst.AbsolutePosition.X - inst.AbsolutePosition.X + v22.inst.AbsoluteSize.X / 2) / v23
			v25 = (v22.inst.AbsolutePosition.Y - inst.AbsolutePosition.Y) / v23
		else
			v24 = inst.AbsoluteSize.X / 2 / v23
			v25 = inst.AbsoluteSize.Y * 0.6 / v23
		end

		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Text = e
		textLabel.TextSize = 30
		textLabel.Size = UDim2.fromOffset(40, 40)
		textLabel.AnchorPoint = Vector2.new(0.5, 1)
		textLabel.Position = UDim2.fromOffset(v24, v25)
		textLabel.ZIndex = 20
		textLabel.Parent = inst
		TweenService:Create(textLabel, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(v24 + math.random(-24, 24), v25 - 110),
			TextTransparency = 1,
			Rotation = math.random(-15, 15)
		}):Play()
		task.delay(1.9, function()
			textLabel:Destroy()
		end)
	end

	local v22 = nil
	local controls = nil
	task.spawn(function()
		local playerScripts = lp:WaitForChild("PlayerScripts", 10)
		local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 10)

		if playerModule then
			pcall(function()
				local module = require(playerModule)
				controls = module:GetControls()
			end)
		end
	end)
	local on = audio.on
	function audio.on(value, p2, p3, value2, ...)
		if v2.active and not amSpeaker() and type(value) == "string" and type(value2) == "number" then -- inferred equivalent call
			local v23 = string.sub(value, 1, 1)

			if v23 == "L" or v23 == "M" then
				value2 *= 0.5
			end
		end

		return on(value, p2, p3, value2, ...)
	end

	for _, v23 in { u.piano, u.qwerty } do
		local hf = v23.hf

		if not hf then
			continue
		end

		v23.hf0 = hf
		function v23.hf(...)
			local v24 = hf(...)

			if v2.active then
				return (math.max(26, (math.floor(v24 * 0.25))))
			end

			return v24
		end
	end

	local function setActive(flag: boolean)
		if flag == v2.active then
			return
		end

		v2.active = flag
		u.podiumOn = flag

		if flag then
			v22 = { app = u.app.bg, main = u.main.bg }
			u.app.bg = { c = Color3.new(), a = 0 }
			u.main.bg = { c = Color3.new(), a = 0 }
			u.app:paint()
			u.main:paint()
			u.stage.inst.Visible = false
			podiumMask.Enabled = true
			podiumNotes.Parent = workspace

			if controls then
				pcall(function()
					controls:Disable()
				end)
			end

			buildPanel()
		else
			if v22 then
				u.app.bg = v22.app
				u.main.bg = v22.main
			end

			u.app:paint()
			u.main:paint()
			u.stage.inst.Visible = true
			podiumMask.Enabled = false

			for k in v3 do
				releaseSeat(k)
			end

			podiumNotes.Parent = nil

			if controls then
				pcall(function()
					controls:Enable()
				end)
			end

			if v20 then
				v20.node:destroy()
				v20 = nil
			end

			closePicker() -- inferred equivalent call
			currentCamera.CameraType = Enum.CameraType.Custom
			v12.pos = nil
			v12.look = nil
			v12.shot = nil
			v12.focusKey = ""
		end

		f.layoutPiano()
		lay.dirty()
	end

	local function applyState(data2)
		local v23 = amSpeaker() -- inferred equivalent call
		table.clear(v2.seats)
		table.clear(v2.seatOf)

		for _, v24 in type(data2.speakers) ~= "table" and {} or data2.speakers do
			local seat = tonumber(v24.seat)
			local uid = tonumber(v24.uid)

			if not (seat and uid) then
				continue
			end

			v2.seats[seat] = uid
			v2.seatOf[uid] = seat
		end

		table.clear(v2.mods)

		for _, v24 in type(data2.mods) ~= "table" and {} or data2.mods do
			v2.mods[v24] = true
		end

		v2.hands = type(data2.hands) ~= "table" and {} or data2.hands
		table.clear(v2.handAt)
		local v24 = type(data2.handsAt) ~= "table" and {} or data2.handsAt

		for k, hand in v2.hands do
			v2.handAt[hand] = tonumber(v24[k])
		end

		v2.host = tonumber(data2.host) or 0

		for k in v3 do
			if not v2.seats[k] then
				releaseSeat(k)
			end
		end

		if v2.active then
			if amSpeaker() and not v23 then -- inferred equivalent call
				toast("You're on the podium: everyone hears your piano and your voice.")
			end

			if v23 and not amSpeaker() then -- inferred equivalent call
				toast("You're in the audience now: only you hear your piano until you're back on the podium.")
			end
		end

		rebuild()
	end
	podium.OnClientEvent:Connect(function(data2)
		if type(data2) ~= "table" then
			return
		end

		if data2.kind == "emoji" then
			if v2.active and tonumber(data2.uid) and type(data2.e) == "string" then
				floatEmoji(tonumber(data2.uid), data2.e)
			end
		else
			if data2.kind ~= "state" then
				return
			end

			if data2.active ~= nil then
				setActive(data2.active == true)
			end

			applyState(data2)

			if type(data2.msg) == "string" and f.sysMsg then
				f.sysMsg(data2.msg)
			end
		end
	end)
	local podiumStageSet = {}
	local function watchStage()
		local podiumStage = workspace:FindFirstChild("PodiumStage")

		if not podiumStage or podiumStageSet[podiumStage] then
			return
		end

		podiumStageSet[podiumStage] = true
		folder = podiumStage

		for _, child in podiumStage:GetChildren() do
			task.spawn(scan, child)
		end

		podiumStage.ChildAdded:Connect(function(child)
			task.spawn(scan, child)
		end)
		podiumStage.ChildRemoved:Connect(function(child)
			for k, v23 in v3 do
				if v23.model ~= child then
					continue
				end

				releaseSeat(k)
				v3[k] = nil
			end
		end)
	end
	workspace.ChildAdded:Connect(function(child)
		if child.Name == "PodiumStage" then
			task.wait(0.2)
			watchStage()
		end
	end)
	watchStage()

	RunService:BindToRenderStep("PodiumView", Enum.RenderPriority.Camera.Value + 1, function(p2)
		if not v2.active then
			return
		end

		updateView(p2)
		updateLights(p2)
		fadeNear()

		if not v20 then
			return
		end

		local now = os.clock()
		local handBtn = v20.handBtn

		if handBtn and handBtn.label then
			local v23 = v20.handBase .. " · " .. handFor(lp.UserId) -- inferred equivalent call

			if handBtn.label.t ~= v23 then
				handBtn.label:setText(v23)
			end
		end

		for k, v23 in v19 do
			if v23.timer then
				local v24 = handFor(k) -- inferred equivalent call

				if v23.timer.t ~= v24 then
					v23.timer:setText(v24)
				end
			end

			local v24

			if lastPlay[k] == nil then
				v24 = false
			else
				v24 = now - lastPlay[k] < 0.6
			end

			local bdc = talking[k] and "ok" or v24 and "brass" or "line"

			if v23.bdc ~= bdc then
				v23.bdc = bdc
				v23:paint()
			end

			if not v23.status then
				continue
			end

			local v25 = talking[k] and "talking" or v24 and "playing" or " "

			if v23.status.t == v25 then
				continue
			end

			v23.status.c = v25 == "talking" and "ok" or "brassInk"
			v23.status:setText(v25)
		end
	end)
	vp:GetAttributeChangedSignal("Podium"):Connect(function()
		if vp:GetAttribute("Podium") == true then
			task.spawn(function()
				local v23 = api("podiumState")

				if type(v23) == "table" then
					setActive(v23.active == true)
					applyState(v23)
				end
			end)
		else
			setActive(false)
		end
	end)

	if vp:GetAttribute("Podium") == true then
		task.spawn(function()
			local v23 = api("podiumState")

			if type(v23) == "table" then
				setActive(v23.active == true)
				applyState(v23)
			end
		end)
	end

	Players.PlayerAdded:Connect(function()
		task.wait(0.5)
		rebuild()
	end)
	Players.PlayerRemoving:Connect(function()
		task.defer(rebuild)
	end)
end