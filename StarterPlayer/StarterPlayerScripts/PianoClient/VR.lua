return function(data)
	local b = data.B
	local t = data.T
	local u = data.U
	local f = data.F
	local p = data.P
	local a = data.A
	local lay = data.Lay
	local notes = data.Notes
	local glyph = data.Glyph
	local pianoKeys = data.pianoKeys
	local press = data.press
	local release = data.release
	local pressRaw = data.pressRaw
	local releaseRaw = data.releaseRaw
	local btn = data.btn
	local glyphLabel = data.glyphLabel
	local img = data.img
	local fx = data.FX
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local VRService = game:GetService("VRService")
	local HapticService = game:GetService("HapticService")
	local v = RunService:IsStudio() and workspace:GetAttribute("FakeVR") == true

	if not (UserInputService.VREnabled or v) then
		return
	end

	f.vrOn = true

	f.fakeSize = Vector2.new(1300, 760)

	local currentCamera = workspace.CurrentCamera

	local v2 = CFrame.new(0, 0, 30) * CFrame.Angles(0, 3.141592653589793, 0)

	local v3 = {
		d = 0.42,
		h = 0.72,
		s = 1,
		l = 0.16,
		a = 5,
		gl = 2,
		gr = 2
	}
	local clone = table.clone(v3)

	local function userCF(p2)
		if v then
			local v4 = p2 == Enum.UserCFrame.Head and "FakeHead"
				or p2 == Enum.UserCFrame.LeftHand and "FakeL"
				or "FakeR"
			local attribute = workspace:GetAttribute(v4)

			if typeof(attribute) == "CFrame" then
				return attribute
			end

			if p2 == Enum.UserCFrame.Head then
				return (CFrame.new(0, 5.5, 0))
			end

			return nil
		else
			if p2 ~= Enum.UserCFrame.Head then
				local success, result = pcall(function()
					return VRService:GetUserCFrameEnabled(p2)
				end)

				if success and not result then
					return nil
				end
			end

			local success, result = pcall(function()
				return VRService:GetUserCFrame(p2)
			end)
			return if success then result else nil
		end
	end

	local v4 = nil
	local function toWorld(cframe: CFrame) -- 4 equivalent calls inferred from this helper
		return v4 * CFrame.new(cframe.Position * currentCamera.HeadScale) * cframe.Rotation
	end

	local function computeBase(cframe: CFrame)
		local v5 = 0

		if not v then
			local success, result = pcall(function()
				return VRService:GetUserCFrame(Enum.UserCFrame.Floor)
			end)

			if success and result then
				v5 = result.Position.Y
			end
		end

		local v6

		if cframe.Position.Y - v5 < 3 then
			v6 = 5.333333333333334 - cframe.Position.Y * currentCamera.HeadScale
		else
			v6 = -v5 * currentCamera.HeadScale
		end

		v4 = v2 * CFrame.new(0, v6, 0)
	end

	local vrPiano = Instance.new("Folder")
	vrPiano.Name = "VRPiano"
	vrPiano.Parent = workspace
	local function part(shape) -- 7 equivalent calls inferred from this helper
		local part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.CastShadow = false
		part2.Material = Enum.Material.SmoothPlastic
		part2.TopSurface = Enum.SurfaceType.Smooth
		part2.BottomSurface = Enum.SurfaceType.Smooth

		if shape then
			part2.Shape = shape
		end

		part2.Parent = vrPiano
		return part2
	end

	local function surface(playerGui, front, p2: number, p3: number, adornee) -- 2 equivalent calls inferred from this helper
		local surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Face = front
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
		surfaceGui.CanvasSize = Vector2.new(p2, p3)
		surfaceGui.LightInfluence = 0
		surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		surfaceGui.ResetOnSpawn = false
		surfaceGui.ClipsDescendants = true
		surfaceGui.MaxDistance = 0

		if adornee then
			surfaceGui.Adornee = adornee
			surfaceGui.Active = true
		end

		surfaceGui.Parent = playerGui
		return surfaceGui
	end

	local part2 = part() -- inferred equivalent call
	local part3 = part() -- inferred equivalent call
	local part4 = part() -- inferred equivalent call
	part3.Transparency = 1
	part4.Transparency = 1
	local parent = surface(part3, Enum.NormalId.Top, 1040, 130) -- inferred equivalent call
	local parent2 = surface(part4, Enum.NormalId.Top, 1040, 130) -- inferred equivalent call
	local count = 0
	local v5 = {}
	local v6 = {}
	local v7 = {}

	for i = 21, 108 do
		local black = notes.isBlack(i)
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.ZIndex = black and 3 or 1
		local uiCorner = Instance.new("UICorner", frame)
		uiCorner.CornerRadius = UDim.new(0, black and 4 or 5)
		local v8 = { f = frame, black = black, m = i }

		if black then
			v8.x = count * 0.0235 - 0.611
			v5[count] = v8
			v8.sh = img("keysh", {
				ZIndex = 2,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(fx.keysh.slice[1], fx.keysh.slice[2], fx.keysh.slice[3], fx.keysh.slice[4]),
				ImageColor3 = Color3.new(0, 0, 0),
				ImageTransparency = 0.6
			})
			v8.sh.Parent = parent
			v8.lb = glyphLabel(frame, "m600_9_92")
			frame.Parent = parent2
		else
			v8.x = (count + 0.5) * 0.0235 - 0.611
			count += 1
			v6[count] = v8
			local uiStroke = Instance.new("UIStroke")
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
			uiStroke.Thickness = 1
			uiStroke.Parent = frame
			v8.edge = uiStroke
			v8.lb = glyphLabel(frame, "m600_12_48")
			v8.nn = glyphLabel(frame, "m500_8_32")

			if i == 60 then
				local frame2 = Instance.new("Frame")
				frame2.BorderSizePixel = 0
				frame2.Size = UDim2.fromOffset(5, 5)
				frame2.ZIndex = 2
				local uiCorner_2 = Instance.new("UICorner", frame2)
				uiCorner_2.CornerRadius = UDim.new(1, 0)
				frame2.Parent = frame
				v8.dot = frame2
			end

			frame.Parent = parent
		end

		v7[i] = v8
	end

	local v8 = ""
	local function drawKeys()
		local th = lay.TH
		local count2 = 0

		for i = 21, 108 do
			local v9 = v7[i]
			local f2 = v9.f
			local v10 = notes.ORDER[i - a.transpose - 35] or f.ctrlLabel(i - a.transpose) or ""

			if v9.black then
				local v11 = count2 / 52 * 1040 - 6.2
				local v12 = math.floor(v11 + 0.5)
				local v13 = math.floor(v11 + 12.4 + 0.5)

				f2.Size = UDim2.fromOffset(v13 - v12, 82)
				f2.Position = UDim2.fromOffset(v12, -4)
				v9.lb.draw(
					v10,
					(v13 - v12) / 2,
					77 - glyph.style("m600_9_92").lh + glyph.baseline("m600_9_92"),
					th.bkInk.c
				)
				local margin = fx.keysh.margin
				v9.sh.Position = UDim2.fromOffset(v12 - margin, -4 - margin + 2)
				v9.sh.Size = UDim2.fromOffset(v13 - v12 + 2 * margin, 82 + 2 * margin)
			else
				local v11 = count2 * (1039 / 52)
				local x0 = math.floor(v11 + 0.5)
				local v12 = math.floor(v11 + 1091 / 52 + 0.5)
				count2 += 1

				v9.x0 = x0
				f2.Size = UDim2.fromOffset(v12 - x0, 135)
				f2.Position = UDim2.fromOffset(x0, -5)
				local v13 = 128

				if p.names then
					v13 -= glyph.style("m500_8_32").lh + 1
				end

				v9.lb.draw(
					v10,
					(v12 - x0) / 2,
					v13 - glyph.style("m600_12_48").lh + glyph.baseline("m600_12_48"),
					th.wkInk.c
				)
				v9.nn.holder.Visible = p.names

				if p.names then
					v9.nn.draw(
						notes.noteName(i),
						(v12 - x0) / 2,
						128 - glyph.style("m500_8_32").lh + glyph.baseline("m500_8_32"),
						th.wkSub.c
					)
				end

				v9.edge.Color = th.wkEdge.c

				if v9.dot then
					v9.dot.Position = UDim2.fromOffset(math.floor((v12 - x0) / 2 - 2.5 + 0.5), 93)
					v9.dot.BackgroundColor3 = th.midDot.c
				end
			end

			v9.bg = nil
			v9.cs = nil
			v9.y = nil
		end
	end

	local function mirrorKeys()
		for k, v9 in v7 do
			local pianoKey = pianoKeys[k]
			local f2 = pianoKey.f
			local grad = pianoKey.grad
			local backgroundColor3 = f2.BackgroundColor3

			if v9.bg ~= backgroundColor3 then
				v9.bg = backgroundColor3
				v9.f.BackgroundColor3 = backgroundColor3
			end

			if grad and grad.Enabled then
				local v10 = v9.g

				if not v10 then
					v10 = Instance.new("UIGradient")
					v10.Rotation = 90
					v10.Parent = v9.f
					v9.g = v10
				end

				if v9.cs ~= grad.Color then
					v9.cs = grad.Color
					v10.Color = grad.Color
				end

				v10.Enabled = true
			elseif v9.g and v9.g.Enabled then
				v9.g.Enabled = false
				v9.cs = nil
			end

			if v9.black then
				continue
			end

			local offset = f2.Position.Y.Offset

			if v9.y == offset then
				continue
			end

			v9.y = offset
			v9.f.Position = UDim2.fromOffset(v9.x0 or 0, offset)
		end
	end

	local function keyAt(x: number, z: number)
		if z > 0 or z < -0.15 or math.abs(x) > 0.611 then
			return nil, 0
		end

		local v9 = (x + 0.611) / 0.0235

		if not (z < -0.06) then
			return v6[math.clamp(math.floor(v9) + 1, 1, 52)], 0
		end

		local v10 = v5[math.floor(v9 + 0.5)]

		if v10 and math.abs(x - v10.x) <= 0.007285 then
			return v10, 0.012
		end

		return v6[math.clamp(math.floor(v9) + 1, 1, 52)], 0
	end

	local cframe = CFrame.new()
	local flag = false
	local v9 = nil
	local v10 = 0
	local fn
	local function layoutPiano()
		local v11 = clone.s * (10 / 3)

		local cframe2 = CFrame.Angles(0, -1.5707963267948966, 0)
		part3.Size = Vector3.new(0.15 * v11, 0.001 * v11, 1.222 * v11)
		part3.CFrame = cframe * CFrame.new(0, -0.0005 * v11, -0.075 * v11) * cframe2
		part4.Size = part3.Size
		part4.CFrame = cframe * CFrame.new(0, 0.0115 * v11, -0.075 * v11) * cframe2
		part2.Size = Vector3.new(1.234, 0.02, 0.158) * v11
		part2.CFrame = cframe * CFrame.new(Vector3.new(0, -0.011, -0.077) * v11)

		if fn then
			fn()
		end
	end
	local function flat(lookVector: Vector3) -- 2 equivalent calls inferred from this helper
		local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)

		if vector3.Magnitude > 0.01 then
			return vector3.Unit
		end

		return Vector3.new(0, 0, -1)
	end

	local function computePiano()
		if not v9 then
			return
		end

		local fwd = v9.fwd
		local cross = fwd:Cross(Vector3.new(0, 1, 0))
		local v11 = v9.pos + fwd * (clone.d * (10 / 3)) + cross * (v10 * (10 / 3)) - Vector3.new(0, 1, 0) * (clone.h * (10 / 3))

		cframe = CFrame.fromMatrix(v11, cross, Vector3.new(0, 1, 0), -fwd)
		flag = true
		layoutPiano()
	end
	local function headWorld() -- 2 equivalent calls inferred from this helper
		local v11 = userCF(Enum.UserCFrame.Head)

		if v11 and v4 then
			return toWorld(v11) -- inferred equivalent call
		end

		return nil
	end

	function f.vrPlaceInFront()
		local v11 = headWorld() -- inferred equivalent call

		if not v11 then
			return
		end

		v9 = { pos = v11.Position, fwd = flat(v11.LookVector) } -- inferred equivalent call
		v10 = 0
		computePiano()
	end

	local Players = game:GetService("Players")
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local function panel(name: string, cw: number, ch: number)
		local adornee = part() -- inferred equivalent call
		adornee.Name = name
		adornee.Transparency = 1
		local sg = surface(playerGui, Enum.NormalId.Front, cw, ch, adornee)
		sg.Name = "VR" .. name
		return {
			p = adornee,
			sg = sg,
			cw = cw,
			ch = ch,
			name = name
		}
	end

	local v11 = panel("Stage", 1300, 760)
	local v12 = panel("Side", 336, 760)
	local v13 = panel("Windows", 720, 760)
	u.app.inst.Parent = v11.sg
	local uiScale = u.app.inst:FindFirstChildOfClass("UIScale")

	if uiScale then
		uiScale.Scale = 1
	end

	u.layer.inst.Parent = v13.sg
	u.layerScale.Scale = 1

	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	local uiCorner = Instance.new("UICorner", frame)
	uiCorner.CornerRadius = UDim.new(0, 14)
	frame.Parent = v12.sg
	u.side:detach()
	u.side.inst.Parent = v12.sg
	u.side.inst.ZIndex = 2
	lay.root(u.app, function()
		return v11.cw, v11.ch
	end)
	lay.root(u.side, function(): (number, number, number, number)
		return 320, 740, 8, 10
	end)
	lay.root(u.layer, function()
		return v13.cw, v13.ch
	end)

	function u.piano.hf(): number
		return 4
	end
	u.sideBtn:show(false)
	u.topbar.m = { 0, 0, 0, 0 }
	lay.dirty()

	local function setPanel(data2, vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3, vector3_4: Vector3, p2: number) -- 2 equivalent calls inferred from this helper
		data2.p.Size = Vector3.new(data2.cw * p2, data2.ch * p2, 0.01)

		data2.p.CFrame = CFrame.fromMatrix(vector3, -vector3_2, vector3_3, -vector3_4)
	end

	local function facing(vector: Vector3) -- 2 equivalent calls inferred from this helper
		local unit = (vector:Cross(Vector3.new(0, 1, 0)) * 0.9781476007338057 + Vector3.new(0, 0.20791169, 0)).Unit
		return unit:Cross(vector), unit
	end

	local v14 = ""

	local v15 = v11
	local v16 = ""
	function f.vrPlaceWindows(flag2: boolean?)
		local v17

		if not u.dialog then
			v17 = v15
		end

		local v18 = not v17 and "dialog" or v17.name

		if v18 == v16 and not flag2 then
			return
		end

		v16 = v18
		local p2 = (v17 or v11).p
		local v19 = p2.Size.X / (v17 or v11).cw
		local cw = not v17 and 720 or v17.cw
		local ch = not v17 and 760 or v17.ch
		v13.cw = cw
		v13.ch = ch
		v13.sg.CanvasSize = Vector2.new(cw, ch)
		v13.p.Size = Vector3.new(cw * v19, ch * v19, 0.01)
		v13.p.CFrame = p2.CFrame + p2.CFrame.LookVector * ((v17 and 0.015 or 0.06) * (10 / 3))
		lay.dirty()
	end

	local flag2 = false
	fn = function()
		if flag2 then
			return
		end

		local inst = u.stage.inst
		local absolutePosition = inst.AbsolutePosition
		local absoluteSize = inst.AbsoluteSize

		if absoluteSize.X < 10 then
			return
		end

		v14 = tostring(absolutePosition) .. tostring(absoluteSize)
		local v17 = clone.s * (10 / 3)

		local v18 = 1.222 * v17 / absoluteSize.X
		local rightVector = cframe.RightVector
		local zVector = cframe.ZVector
		local v19, unit2 = facing(rightVector) -- inferred equivalent call
		local pointToWorldSpace = cframe:PointToWorldSpace((Vector3.new(0, 0.016 * v17, -0.154 * v17)))
		local v20 = absolutePosition.X + absoluteSize.X / 2
		local v21 = absolutePosition.Y + absoluteSize.Y
		local function at(p2: number, p3: number) -- 2 equivalent calls inferred from this helper
			return pointToWorldSpace + rightVector * ((p2 - v20) * v18) + v19 * ((v21 - p3) * v18)
		end

		setPanel(v11, at(v11.cw / 2, v11.ch / 2), rightVector, v19, unit2, v18) -- inferred equivalent call

		local v22 = at(-6, v11.ch) -- inferred equivalent call
		local unit = (rightVector * 0.766044443118978 - zVector * 0.6427876096865393).Unit
		local v23, unit3 = facing(unit) -- inferred equivalent call
		setPanel(v12, v22 - unit * (v12.cw * v18 / 2) + v23 * (v12.ch * v18 / 2), unit, v23, unit3, v18) -- inferred equivalent call

		f.vrPlaceWindows(true)
	end

	local function save()
		local v17 = { v = 3 }

		for k, v18 in clone do
			v17[k] = math.floor(v18 * 1000 + 0.5) / 1000
		end

		f.savePref("vr", v17)
	end
	function f.vrPrefs(p2)
		if type(p2) ~= "table" then
			return
		end

		local v17 = tonumber(p2.v) or 1

		for k, v18 in {
			d = { 0.1, 1 },
			h = { 0.1, 1.4 },
			s = { 0.5, 1.5 },
			l = { 0.05, 0.6 },
			a = { -90, 90 },
			gl = { 0.6, 8 },
			gr = { 0.6, 8 }
		} do
			local v19 = tonumber(p2[k])

			if k == "a" and v19 and v17 == 2 then
				v19 += 15
			end

			if v19 and (v17 >= 2 or k ~= "l" and k ~= "a") then
				clone[k] = math.clamp(v19, v18[1], v18[2])
			end
		end

		computePiano()
	end

	local v17 = {
		{
			uc = Enum.UserCFrame.LeftHand,
			motor = Enum.VibrationMotor.LeftHand,
			grip = Enum.KeyCode.ButtonL1,
			trig = Enum.KeyCode.ButtonL2,
			more = Enum.KeyCode.ButtonX,
			less = Enum.KeyCode.ButtonY,
			gap = "gl",
			side = 1,
			fakeGrip = "FakeGripL"
		},
		{
			uc = Enum.UserCFrame.RightHand,
			motor = Enum.VibrationMotor.RightHand,
			grip = Enum.KeyCode.ButtonR1,
			trig = Enum.KeyCode.ButtonR2,
			more = Enum.KeyCode.ButtonA,
			less = Enum.KeyCode.ButtonB,
			gap = "gr",
			side = -1,
			fakeGrip = "FakeGripR"
		}
	}

	local color = Color3.fromRGB(150, 153, 158)

	for _, v18 in v17 do
		v18.sticks = {}

		for i = 1, 3 do
			local shaft = part(Enum.PartType.Cylinder) -- inferred equivalent call
			shaft.Color = color
			table.insert(v18.sticks, {
				shaft = shaft,
				extra = i > 1,
				shown = true
			})
		end
	end

	local v18 = {}

	local function buzz(state, p2: number)
		state.buzzG = (state.buzzG or 0) + 1
		local buzzG = state.buzzG
		pcall(function()
			HapticService:SetMotor(Enum.UserInputType.Gamepad1, state.motor, p2)
		end)
		task.delay(0.045, function()
			if state.buzzG == buzzG then
				pcall(function()
					HapticService:SetMotor(Enum.UserInputType.Gamepad1, state.motor, 0)
				end)
			end
		end)
	end

	local function hit(state, p2, speed: number, p3)
		local v19 = math.clamp(speed * 0.55 + 0.25, 0.2, 1.27)
		local velocity2 = math.clamp(math.floor(a.velocity * v19 + 0.5), 1, 127)
		state.key = p2
		state.speed = speed
		v18[p2.m] = (v18[p2.m] or 0) + 1
		local ch = notes.ORDER[p2.m - a.transpose - 35]
		local velocity = a.velocity
		a.velocity = velocity2

		if ch then
			state.ch = ch
			press(ch, "user")
		else
			state.ch = nil
			pressRaw(p2.m)
		end

		a.velocity = velocity
		buzz(p3, velocity2 * 0.6 / 127 + 0.2)
	end
	local function letGo(state)
		local key = state.key

		if not key then
			return
		end

		state.key = nil
		local v19 = math.max(0, (v18[key.m] or 1) - 1)
		local m = key.m
		local v20

		if v19 > 0 then
			v20 = v19
		end

		v18[m] = v20

		if v19 == 0 then
			if state.ch then
				release(state.ch)
			else
				releaseRaw(key.m)
			end
		end

		state.ch = nil
	end

	local function stepTip(stick, prev: Vector3, p2: number, p3)
		local prev2 = stick.prev
		stick.prev = prev

		if stick.key then
			local v19, v20 = keyAt(prev.X, prev.Z)

			if v19 then
				local y = prev.Y

				if not (v20 + 0.004 < y or prev.Y < v20 - 0.3) then
					if v19 ~= stick.key then
						letGo(stick)
						hit(stick, v19, stick.speed or 1, p3)
					end

					return
				end
			end

			letGo(stick)
		else
			if not prev2 then
				return
			end

			for _, v19 in { 0.012, 0 } do
				if not (v19 <= prev2.Y and prev.Y < v19) then
					continue
				end

				local lerped = prev2:Lerp(prev, (prev2.Y - v19) / (prev2.Y - prev.Y))
				local v20, v21 = keyAt(lerped.X, lerped.Z)

				if v20 and v21 == v19 then
					hit(stick, v20, (prev2.Y - prev.Y) * clone.s / math.max(p2, 1 / 240), p3)
					return
				end
			end
		end
	end
	local function hideStick(stick) -- 2 equivalent calls inferred from this helper
		letGo(stick)
		stick.prev = nil

		if stick.shown then
			stick.shown = false
			stick.shaft.Transparency = 1
		end
	end
	local function drawStick(stick, vector3: Vector3, vector3_2: Vector3)
		if not stick.shown then
			stick.shown = true
			stick.shaft.Transparency = 0
		end

		local magnitude = (vector3_2 - vector3).Magnitude

		if stick.key then
			local v19 = clone.s * (10 / 3)
			local pointToObjectSpace = cframe:PointToObjectSpace(vector3_2)
			local v20 = (stick.key.black and 0.012 or 0) * v19
			vector3_2 = cframe:PointToWorldSpace((Vector3.new(pointToObjectSpace.X, v20 + 0.02, pointToObjectSpace.Z)))
			local v21 = vector3 - vector3_2

			if v21.Magnitude > 0.001 then
				vector3 = vector3_2 + v21.Unit * magnitude
			end
		end

		stick.shaft.Size = Vector3.new(magnitude, 0.04, 0.04)
		stick.shaft.CFrame = CFrame.lookAt((vector3 + vector3_2) / 2, vector3_2) * CFrame.Angles(0, 1.5707963267948966, 0)
	end

	local function gripHeld(p2): boolean -- 1 equivalent call inferred from this helper
		if v then
			return workspace:GetAttribute(p2.fakeGrip) == true
		end

		return p2.gripDown == true
	end

	UserInputService.InputBegan:Connect(function(input)
		for _, v19 in v17 do
			if input.KeyCode == v19.grip then
				v19.gripDown = true
			end

			if input.KeyCode == v19.more then
				v19.moreDown = true
			end

			if input.KeyCode == v19.less then
				v19.lessDown = true
			end
		end

		if input.KeyCode == Enum.KeyCode.ButtonL3 or input.KeyCode == Enum.KeyCode.ButtonR3 then
			f.vrPlaceAtSticks()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		for _, v19 in v17 do
			if input.KeyCode == v19.grip then
				v19.gripDown = false
			end

			if not (input.KeyCode == v19.more or input.KeyCode == v19.less) then
				continue
			end

			if input.KeyCode == v19.more then
				v19.moreDown = false
			else
				v19.lessDown = false
			end

			save()
		end
	end)

	local v19 = { v11, v12, v13 }

	local function rayPanel(vector3: Vector3, vector: Vector3, p2)
		local v20 = 1e999
		local v21 = nil
		local v22 = 0
		local v23 = 0

		for _, v24 in p2 and { p2 } or v19 do
			local p3 = v24.p
			local lookVector = p3.CFrame.LookVector
			local dot = vector:Dot(lookVector)

			if not (dot < -0.0001) then
				continue
			end

			local v25 = (p3.Position + lookVector * (p3.Size.Z / 2) - vector3):Dot(lookVector) / dot

			if not (v25 > 0 and v25 < v20) then
				continue
			end

			local pointToObjectSpace = p3.CFrame:PointToObjectSpace(vector3 + vector * v25)

			if not (p2 or math.abs(pointToObjectSpace.X) <= p3.Size.X / 2 and math.abs(pointToObjectSpace.Y) <= p3.Size.Y / 2) then
				continue
			end

			v22 = (0.5 - pointToObjectSpace.X / p3.Size.X) * v24.cw
			v23 = (0.5 - pointToObjectSpace.Y / p3.Size.Y) * v24.ch
			v21 = v24
			v20 = v25
		end

		return v21, v22, v23, v20
	end

	local function fn2(vector3: Vector3, vector3_2: Vector3)
		local result = {}

		for _, pn in v19 do
			local v20, v21, v22, v23 = rayPanel(vector3, vector3_2, pn)
			local p2 = pn.p

			if not v20 then
				continue
			end

			local pointToObjectSpace = p2.CFrame:PointToObjectSpace(vector3 + vector3_2 * v23)

			if not (math.abs(pointToObjectSpace.X) <= p2.Size.X / 2 and math.abs(pointToObjectSpace.Y) <= p2.Size.Y / 2) then
				continue
			end

			table.insert(result, { pn = pn, u = v21, v = v22, t = v23 })
		end

		table.sort(result, function(a2, b2): boolean
			return a2.t < b2.t
		end)
		return result
	end

	local function topAt(sg, u2: number, p2: number, callback)
		local v20 = nil
		local v21 = nil
		local function newer(clone2, list): boolean
			if not list then
				return true
			end

			for i = 1, math.max(#clone2, #list) do
				local item = clone2[i]
				local item2 = list[i]

				if item == nil then
					return false
				end

				if item2 == nil then
					return true
				end

				if item ~= item2 then
					return item2 < item
				end
			end

			return false
		end

		local function walk(instance, p3)
			for i, guiObject in instance:GetChildren() do
				if not (guiObject:IsA("GuiObject") and guiObject.Visible) then
					continue
				end

				local absolutePosition = guiObject.AbsolutePosition
				local absoluteSize = guiObject.AbsoluteSize
				local v22

				if
					u2 >= absolutePosition.X
					and p2 >= absolutePosition.Y
					and u2 <= absolutePosition.X + absoluteSize.X
				then
					v22 = p2 <= absolutePosition.Y + absoluteSize.Y
				else
					v22 = false
				end

				if not (v22 or not guiObject.ClipsDescendants) then
					continue
				end

				local clone2 = table.clone(p3)
				table.insert(clone2, guiObject.ZIndex * 100000 + i)

				if v22 and callback(guiObject) and newer(clone2, v21) then
					v20 = guiObject
					v21 = clone2
				end

				walk(guiObject, clone2)
			end
		end
		walk(sg, {})
		return v20
	end

	local function firstAlong(vector3: Vector3, vector3_2: Vector3, callback)
		for _, v20 in fn2(vector3, vector3_2) do
			local v21 = topAt(v20.pn.sg, v20.u, v20.v, callback)

			if v21 then
				return v21, v20
			end
		end

		return nil, nil
	end

	local function clickable(instance)
		return instance:IsA("GuiButton") or instance:IsA("TextBox")
	end
	local function scroller(scrollingFrame)
		return scrollingFrame:IsA("ScrollingFrame")
	end
	local color2 = Color3.fromRGB(255, 255, 255)

	for _, v20 in v17 do
		v20.beam = part(Enum.PartType.Cylinder) -- inferred equivalent call
		v20.beam.Material = Enum.Material.Neon
		v20.beam.Color = color2
		v20.beam.Transparency = 1
		v20.dot = part(Enum.PartType.Ball) -- inferred equivalent call
		v20.dot.Material = Enum.Material.Neon
		v20.dot.Transparency = 1
		v20.dot.Size = Vector3.new(0.04, 0.04, 0.04)
		v20.stick = 0
	end

	local laserPointer = nil
	local v20 = false
	local function robloxPointer(flag3: boolean)
		local success, result = pcall(function()
			return VRService.LaserPointer
		end)

		if not success then
			return
		end

		if flag3 then
			if laserPointer and result == Enum.VRLaserPointerMode.Disabled then
				pcall(function()
					VRService.LaserPointer = laserPointer
				end)
			end
		else
			if result ~= Enum.VRLaserPointerMode.Disabled then
				laserPointer = result
			end

			pcall(function()
				VRService.LaserPointer = Enum.VRLaserPointerMode.Disabled
			end)
		end
	end
	local function handRay(p2) -- 2 equivalent calls inferred from this helper
		local v21 = userCF(p2.uc)

		if v21 and v4 then
			local world = toWorld(v21) -- inferred equivalent call
			return world.Position, world.LookVector
		end

		return nil, nil
	end

	local function pull(p2): boolean
		local v21, v22 = handRay(p2) -- inferred equivalent call

		if not v21 then
			return false
		end

		local textBox, v23 = firstAlong(v21, v22, clickable)
		local pn

		if v23 then
			pn = v23.pn
		end

		local v24 = not v23 and 0 or v23.u

		if textBox and textBox:IsA("TextBox") then
			textBox:CaptureFocus()
			return true
		end

		local fn3 = textBox and f.drags and f.drags[textBox]

		if fn3 then
			flag2 = true
			fn3(v24, not v23 and 0 or v23.v)
			p2.drag = { fn = fn3, pn = pn }
			return true
		else
			local v25 = textBox and lay.clicks[textBox]

			if v25 then
				if pn ~= v13 then
					if f.closePopup then
						f.closePopup()
					end

					v15 = pn
					f.vrPlaceWindows()
					lay.now()
				end

				for _, callback in v25 do
					task.spawn(callback)
				end

				return true
			end

			if f.closePopup then
				f.closePopup()
			end

			return false
		end
	end

	local function trigOn(p2) -- 2 equivalent calls inferred from this helper
		p2.trigDown = true
		p2.trigClick = pull(p2)
	end
	UserInputService.InputBegan:Connect(function(input)
		for _, v21 in v17 do
			if input.KeyCode == v21.trig then
				trigOn(v21) -- inferred equivalent call
			end
		end
	end)
	local function letSlider(p2) -- 2 equivalent calls inferred from this helper
		if not p2.drag then
			return
		end

		p2.drag = nil

		if not (v17[1].drag or v17[2].drag) then
			flag2 = false
			fn()
		end
	end
	UserInputService.InputEnded:Connect(function(input)
		for _, v21 in v17 do
			if input.KeyCode ~= v21.trig then
				continue
			end

			v21.trigDown = false
			v21.trigClick = false
			letSlider(v21) -- inferred equivalent call
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			v17[1].stick = input.Position.Y
		end

		if input.KeyCode == Enum.KeyCode.Thumbstick2 then
			v17[2].stick = input.Position.Y
		end
	end)

	local function pointers(p2: number)
		local v21 = false

		for _, v22 in v17 do
			if v then
				local ftrig = workspace:GetAttribute(v22.side == 1 and "FakeTrigL" or "FakeTrigR") == true

				if ftrig and not v22.ftrig then
					trigOn(v22) -- inferred equivalent call
				end

				if not ftrig and v22.ftrig then
					v22.trigDown = false
					v22.trigClick = false
					letSlider(v22) -- inferred equivalent call
				end

				v22.ftrig = ftrig
			end

			local v23, v24 = handRay(v22) -- inferred equivalent call
			local pn, v25

			if v23 then
				local v26, v27
				pn, v26, v27, v25 = rayPanel(v23, v24)
			end

			if v22.drag and v23 then
				local _, v26, v27 = rayPanel(v23, v24, v22.drag.pn)
				v22.drag.fn(v26, v27)
			end

			local now = os.clock()

			if pn and now - (v22.hovAt or 0) > 0.1 then
				v22.hovAt = now
				local v26, v27 = firstAlong(v23, v24, clickable)
				v22.hov = v26 ~= nil
				local hovT

				if v27 then
					hovT = v27.t
				end

				v22.hovT = hovT
			end

			if v22.hov and v22.hovT then
				v25 = v22.hovT
			end

			if pn and v23 and (v22.hov or v22.drag) then
				local v26 = v23 + v24 * v25
				local beam = v22.beam
				local dot = v22.dot
				beam.Transparency = 0.55
				dot.Transparency = 0
				v22.beam.Size = Vector3.new(v25, 0.01, 0.01)
				v22.beam.CFrame = CFrame.lookAt((v23 + v26) / 2, v26) * CFrame.Angles(0, 1.5707963267948966, 0)
				v22.dot.CFrame = CFrame.new(v26)
				v22.dot.Color = lay.TH.brass.c
			else
				local beam = v22.beam
				local dot = v22.dot
				beam.Transparency = 1
				dot.Transparency = 1
			end

			if not pn then
				continue
			end

			v21 = true

			if not (math.abs(v22.stick) > 0.25) then
				continue
			end

			if not v22.scroll or v22.scroll.pn ~= pn or now - v22.scroll.at > 0.3 then
				v22.scroll = { pn = pn, at = now, sf = firstAlong(v23, v24, scroller) }
			end

			local sf = v22.scroll.sf

			if not (sf and sf.Parent) then
				continue
			end

			local v26 = math.max(0, sf.AbsoluteCanvasSize.Y - sf.AbsoluteWindowSize.Y)
			sf.CanvasPosition = Vector2.new(
				sf.CanvasPosition.X,
				(math.clamp(sf.CanvasPosition.Y - v22.stick * 900 * p2, 0, v26))
			)
		end

		if v21 ~= v20 then
			v20 = v21
			robloxPointer(not v21)
		end
	end

	function f.vrPlaceAtSticks()
		local v21 = headWorld() -- inferred equivalent call

		if not v21 then
			return
		end

		local count2 = 0
		local total = Vector3.new(0, 0, 0)

		for _, v22 in v17 do
			if not v22.tipW then
				continue
			end

			count2 += 1
			total += v22.tipW
		end

		if count2 == 0 then
			return
		end

		local v22 = total / count2
		local vector = flat(v21.LookVector) -- inferred equivalent call
		local cross = vector:Cross(Vector3.new(0, 1, 0))
		local vector2 = v22 - v21.Position
		v9 = { pos = v21.Position, fwd = vector }

		clone.d = math.clamp(vector2:Dot(vector) / (10 / 3) - 0.05 * clone.s, 0.1, 1)
		clone.h = math.clamp(-vector2.Y / (10 / 3) + 0.005, 0.1, 1.4)
		v10 = vector2:Dot(cross) / (10 / 3)
		computePiano()
		save()
		f.toast("The piano is under your sticks now.")

		if f.vrRowsRefresh then
			f.vrRowsRefresh()
		end
	end

	RunService:BindToRenderStep("VRPiano", Enum.RenderPriority.Camera.Value + 2, function(p2)
		local v21 = userCF(Enum.UserCFrame.Head)

		if not v21 then
			return
		end

		if not v4 then
			computeBase(v21)
		end

		currentCamera.CameraType = Enum.CameraType.Scriptable
		local cframe2

		if v then
			cframe2 = toWorld(v21) -- inferred equivalent call
		else
			cframe2 = v4
		end

		currentCamera.CFrame = cframe2

		if not v9 then
			f.vrPlaceInFront()

			if not v9 then
				return
			end
		end

		if p.kb ~= 88 then
			p.kb = 88
			f.layoutPiano()
		end

		if p.view ~= "piano" then
			f.setView("piano", true)
		end

		local th = lay.TH
		local v22 = a.transpose .. tostring(p.names) .. tostring(th)

		if v22 ~= v8 then
			v8 = v22
			drawKeys()
		end

		mirrorKeys()
		pointers(p2)
		local inst = u.stage.inst

		if tostring(inst.AbsolutePosition) .. tostring(inst.AbsoluteSize) ~= v14 then
			fn()
		end

		f.vrPlaceWindows()

		if part2.Color ~= th.pianoTop.c then
			part2.Color = th.pianoTop.c
		end

		if frame.BackgroundColor3 ~= th.bg.c then
			frame.BackgroundColor3 = th.bg.c
		end

		local v23 = clone.s * (10 / 3)

		for _, v24 in v17 do
			if v24.moreDown or v24.lessDown then
				clone[v24.gap] = math.clamp(clone[v24.gap] + (v24.moreDown and 3 or -3) * p2, 0.6, 8)
			end

			local v25 = cframe.RightVector * (clone[v24.gap] * 0.0235 * v23)
			local v26 = userCF(v24.uc)

			if v26 then
				local world = toWorld(v26) -- inferred equivalent call
				local lookVector = (world * CFrame.Angles(-math.rad(clone.a), 0, 0)).LookVector
				local position = (world * CFrame.new(v24.side * 0.015 * (10 / 3), -0.05, -0.1)).Position
				local v27 = clone.l * (10 / 3)
				v24.tipW = position + lookVector * v27
				local v28

				if v24.trigDown == true then
					v28 = not v24.trigClick
				else
					v28 = false
				end

				local v29 = gripHeld(v24) -- inferred equivalent call
				local v30 = if v24.side == -1 then v28 else v29

				if v24.side == -1 then
					v28 = v29
				end

				for k, stick in v24.sticks do
					if flag then
						letGo(stick)
						stick.prev = nil
					end

					if k == 2 and not v30 or k == 3 and not v28 then
						hideStick(stick) -- inferred equivalent call
					else
						local v31

						if k == 2 then
							v31 = -v25
						else
							v31 = k ~= 3 and Vector3.new(0, 0, 0) or v25
						end

						local v32 = position + v31
						local v41 = v32 + lookVector * v27
						stepTip(stick, cframe:PointToObjectSpace(v41) / v23, p2, v24)
						drawStick(stick, v32, v41)
					end
				end
			else
				v24.tipW = nil

				for _, stick in v24.sticks do
					hideStick(stick) -- inferred equivalent call
				end
			end
		end

		flag = false
	end)

	task.spawn(function()
		local StarterGui = game:GetService("StarterGui")

		for _ = 1, 20 do
			if pcall(function()
				StarterGui:SetCore("VREnableControllerModels", false)
			end) then
				break
			end

			task.wait(0.5)
		end
	end)
	local Lighting = game:GetService("Lighting")
	local depthOfFieldEffect = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")

	if depthOfFieldEffect then
		depthOfFieldEffect.Enabled = false
	end

	function f.vrRows(p2, callback, callback2)
		local v21 = {}
		local function slider(p3: string, p4: string?, min: number, max: number, fn3, fn4, p5: string)
			local v22 = b({ dir = "row", align = "center", gap = 10, parent = callback(p2, p3, p4) })
			local v23 = t({
				t = fn3() .. p5,
				f = "m500_10_56",
				c = "muted",
				w = 56,
				align = "r"
			})
			local v24 = callback2(min, max, 1, math.clamp(fn3(), min, max), function(p6)
				fn4(p6)
				v23:setText(p6 .. p5)
				computePiano()
				save()
			end, 150)
			v22:add(v24)
			v22:add(v23)
			table.insert(v21, function()
				v23:setText(fn3() .. p5)

				if v24.set then
					v24.set((math.clamp(fn3(), min, max)))
				end
			end)
		end
		local function r100(p3: number) -- 4 equivalent calls inferred from this helper
			return (math.floor(p3 * 100 + 0.5))
		end
		slider(
			"VR piano height",
			"Or hold your sticks where the keys should be and click a thumbstick: the piano moves there.",
			-60,
			50,
			function()
				return r100(v3.h - clone.h) -- inferred equivalent call
			end,
			function(p3)
				clone.h = v3.h - p3 / 100
			end,
			" cm"
		)
		slider("VR piano distance", "How far in front of your eyes the keys start.", 10, 100, function()
			return r100(clone.d) -- inferred equivalent call
		end, function(p3)
			clone.d = p3 / 100
		end, " cm")
		slider("VR piano size", "100% is a real piano.", 50, 150, function()
			return r100(clone.s) -- inferred equivalent call
		end, function(p3)
			clone.s = p3 / 100
		end, "%")
		slider("Stick length", nil, 5, 60, function()
			return r100(clone.l) -- inferred equivalent call
		end, function(p3)
			clone.l = p3 / 100
		end, " cm")
		slider(
			"Stick angle",
			"Above 0 the sticks point down from where the controllers point, below 0 up (degrees).",
			-90,
			90,
			function()
				return (math.floor(clone.a + 0.5))
			end,
			function(p3)
				clone.a = p3
			end,
			""
		)
		local v22 = callback(p2, "VR piano", "Put it back in front of you, where you look now.")
		local v23 = btn("Put it in front of me")
		v22:add(v23)
		v23:onClick(function()
			f.vrPlaceInFront()
		end)
		function f.vrRowsRefresh()
			for _, v24 in v21 do
				v24()
			end
		end
		v22.inst.Destroying:Connect(function()
			f.vrRowsRefresh = nil
		end)
	end
end