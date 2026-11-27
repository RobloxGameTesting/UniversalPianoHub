local TweenService = game:GetService("TweenService")
local Glyph = require(script.Parent:WaitForChild("Glyph"))
local fx = Glyph.fx

local Lay = {}
local class = {}
class.__index = class
Lay.Node = class

Lay.TH = {}
local object = setmetatable({}, { __mode = "k" })
local count = 0
local v = { 0, 0, 0, 0 }

Lay.FALLBACK = { field = "panel2" }
local function col(value)
	if value == nil then
		return nil, 1
	end

	if typeof(value) == "Color3" then
		return value, 1
	end

	if type(value) == "string" then
		local v2 = Lay.TH[value] or Lay.FALLBACK[value] and Lay.TH[Lay.FALLBACK[value]]

		if v2 then
			return v2.c, v2.a
		end

		return nil, 1
	elseif type(value) == "table" and value.c then
		return value.c, value.a or 1
	else
		return nil, 1
	end
end

Lay.col = col

local function pad4(value)
	if value == nil then
		return v
	end

	if type(value) == "number" then
		return { value, value, value, value }
	end

	if #value == 2 then
		return { value[1], value[2], value[1], value[2] }
	end

	if #value == 3 then
		return { value[1], value[2], value[3], value[2] }
	end

	return value
end

Lay.pad4 = pad4

local function makeInst(self)
	local v2 = self.scroll and "ScrollingFrame"
		or (self.click or self.down or self.hov or self.button) and "TextButton"
		or "Frame"
	local instance = Instance.new(v2)
	instance.Name = self.name or self.kind
	instance.BorderSizePixel = 0
	instance.BackgroundTransparency = 1
	instance.ZIndex = self.z or 1

	if v2 == "TextButton" then
		instance.Text = ""
		instance.AutoButtonColor = false
		instance.Selectable = false
	elseif v2 == "ScrollingFrame" then
		instance.ScrollBarThickness = 0
		instance.ScrollingDirection = Enum.ScrollingDirection.Y
		instance.CanvasSize = UDim2.new()
		instance.ElasticBehavior = Enum.ElasticBehavior.Never
		instance.ScrollBarImageTransparency = 1
	end

	if self.clip or self.scroll then
		instance.ClipsDescendants = true
	end

	if self.hidden then
		instance.Visible = false
	end

	self.inst = instance
	return instance
end

function Lay.box(list)
	local self = setmetatable(list, class)
	self.kind = self.kind or "box"
	self.kids = {}
	self.pad = pad4(self.pad)
	self.m = pad4(self.m)
	self.dir = self.dir or "col"
	self.gap = self.gap or 0
	self.grow = self.grow or 0
	makeInst(self)
	object[self] = true
	local item = list[1]

	if type(item) == "table" then
		self[1] = nil

		for _, v2 in item do
			self:add(v2)
		end
	end

	if self.parent then
		local parent = self.parent
		self.parent = nil
		parent:add(self)
	end

	self:paint()
	return self
end

function Lay:text()
	self.kind = "text"

	if self.t == nil and self.runs == nil then
		self.t = ""
	end

	local box = Lay.box(self)
	box.pool = {}
	box.drawn = nil
	return box
end

function class:add(object2)
	if object2.parent then
		object2:detach()
	end

	object2.parent = self
	table.insert(self.kids, object2)
	object2.inst.Parent = self.inst
	return object2
end

function class:detach()
	local parent = self.parent

	if not parent then
		return
	end

	local index = table.find(parent.kids, self)

	if index then
		table.remove(parent.kids, index)
	end

	self.parent = nil
	self.inst.Parent = nil
end

function class:destroy()
	for _, v2 in table.clone(self.kids) do
		v2:destroy()
	end

	self:detach()
	object[self] = nil

	if self.extras then
		for _, extra in self.extras do
			extra:Destroy()
		end
	end

	if self.shadowInst then
		self.shadowInst:Destroy()
	end

	self.inst:Destroy()
end

function class.clear(p)
	for _, v2 in table.clone(p.kids) do
		v2:destroy()
	end
end

function class:show(visible: boolean)
	if self.hidden == not visible then
		return
	end

	self.hidden = not visible
	self.inst.Visible = visible

	if self.parent then
		Lay.dirtyFrom(self.parent)
	else
		Lay.dirty()
	end
end

local function opacity(object2) -- 2 equivalent calls inferred from this helper
	local v2 = 1

	while object2 do
		if object2.op then
			v2 *= object2.op
		end

		object2 = object2.parent
	end

	return v2
end

local function extra(object2, p: string, className: string) -- 10 equivalent calls inferred from this helper
	object2.extras = object2.extras or {}
	local v2 = object2.extras[p]

	if not v2 then
		v2 = Instance.new(className)
		object2.extras[p] = v2
	end

	return v2
end

local function dropExtra(object2, p: string) -- 7 equivalent calls inferred from this helper
	if object2.extras and object2.extras[p] then
		object2.extras[p]:Destroy()
		object2.extras[p] = nil
	end
end

local function cornerRadius(object2)
	local r = object2.r

	if r == nil or Lay.TH.square and r ~= "pill" then
		return nil
	end

	if r == "pill" then
		return UDim.new(1, 0)
	end

	if type(r) == "number" and r > 0 then
		return UDim.new(0, r)
	end

	return nil
end

function class:state(p: string, flag: boolean)
	self.st = self.st or {}

	if (self.st[p] == true) == flag then
		return
	end

	self.st[p] = flag or nil
	self:paint()
end

local function prop(object2, p: string)
	if object2.sty and object2.st then
		for k, v2 in object2.st do
			if not v2 then
				continue
			end

			local v3 = object2.sty[k]

			if v3 and v3[p] ~= nil then
				return v3[p]
			end
		end
	end

	if object2.hovering and object2.hov and object2.hov[p] ~= nil then
		return object2.hov[p]
	end

	return object2[p]
end

Lay.prop = prop

function class:paint()
	local inst = self.inst
	local v2 = opacity(self) -- inferred equivalent call
	local backgroundColor, v3 = col(prop(self, "bg"))

	if backgroundColor then
		inst.BackgroundColor3 = backgroundColor
		inst.BackgroundTransparency = 1 - v3 * v2
	else
		inst.BackgroundTransparency = 1
	end

	local v4 = prop(self, "grad")

	if v4 then
		local grad = extra(self, "grad", "UIGradient") -- inferred equivalent call
		local colorSequenceKeypoints = {}
		local numberSequenceKeypoints = {}

		for _, stop in v4.stops do
			local v5, v6 = col(stop[2])
			table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(stop[1], v5 or Color3.new()))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(stop[1], 1 - v6))
		end

		grad.Color = ColorSequence.new(colorSequenceKeypoints)
		grad.Transparency = NumberSequence.new(numberSequenceKeypoints)
		grad.Rotation = v4.rot or 90
		grad.Parent = inst

		if not backgroundColor then
			inst.BackgroundColor3 = Color3.new(1, 1, 1)
			inst.BackgroundTransparency = 1 - v2
		end
	else
		dropExtra(self, "grad") -- inferred equivalent call
	end

	local cornerRadius2 = cornerRadius(self)

	if cornerRadius2 then
		local corner = extra(self, "corner", "UICorner") -- inferred equivalent call
		corner.CornerRadius = cornerRadius2
		corner.Parent = inst
	else
		dropExtra(self, "corner") -- inferred equivalent call
	end

	local thickness = prop(self, "bd")

	if thickness and thickness > 0 and not self.bds then
		local v5, v6 = col(prop(self, "bdc"))
		local stroke = extra(self, "stroke", "UIStroke") -- inferred equivalent call
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
		stroke.Thickness = thickness
		stroke.Color = v5 or Color3.new()
		stroke.Transparency = not v5 and 1 or 1 - v6 * v2
		stroke.Parent = inst
	else
		dropExtra(self, "stroke") -- inferred equivalent call
	end

	if self.bds then
		local v5, v6 = col(prop(self, "bdc"))
		local bds = self.bds

		if cornerRadius2 then
			inst.BackgroundColor3 = v5 or inst.BackgroundColor3
			inst.BackgroundTransparency = not v5 and 1 or 1 - v6 * v2
			local parent = extra(self, "inner", "Frame") -- inferred equivalent call
			parent.BorderSizePixel = 0
			parent.BackgroundColor3 = backgroundColor or Color3.new()
			parent.BackgroundTransparency = not backgroundColor and 1 or 1 - v3 * v2
			parent.Position = UDim2.fromOffset(bds[4], bds[1])
			parent.Size = UDim2.new(1, -(bds[2] + bds[4]), 1, -(bds[1] + bds[3]))
			parent.ZIndex = -5
			local uiCorner = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
			local v7 = cornerRadius2.Scale > 0 and 999 or cornerRadius2.Offset
			uiCorner.CornerRadius = UDim.new(0, (math.max(0, v7 - math.min(bds[1], bds[2], bds[3], bds[4]))))
			uiCorner.Parent = parent
			parent.Parent = inst

			if self.grad then
				local grad = self.extras and self.extras.grad

				if grad then
					grad.Parent = parent
				end
			end
		else
			for k, v7 in { "bt", "br", "bb", "bl" } do
				local bd = bds[k]

				if bd > 0 then
					local v8 = extra(self, v7, "Frame") -- inferred equivalent call
					v8.BorderSizePixel = 0
					v8.BackgroundColor3 = v5 or Color3.new()
					v8.BackgroundTransparency = not v5 and 1 or 1 - v6 * v2
					v8.ZIndex = self.bdz or -4

					if k == 1 then
						v8.Position = UDim2.new()
						v8.Size = UDim2.new(1, 0, 0, bd)
					elseif k == 2 then
						v8.Position = UDim2.new(1, -bd, 0, 0)
						v8.Size = UDim2.new(0, bd, 1, 0)
					elseif k == 3 then
						v8.Position = UDim2.new(0, 0, 1, -bd)
						v8.Size = UDim2.new(1, 0, 0, bd)
					else
						v8.Position = UDim2.new()
						v8.Size = UDim2.new(0, bd, 1, 0)
					end

					v8.Parent = inst
				else
					dropExtra(self, v7) -- inferred equivalent call
				end
			end
		end
	end

	local tex = Lay.TH.tex
	local v5 = prop(self, "bg")

	if v5 == nil and v4 then
		v5 = v4.stops[1][2]
	end

	local v6

	if tex and type(v5) == "string" then
		v6 = tex.roles[v5]
	end

	local v7 = type(v6) == "number" and { a = v6 } or v6

	if type(v7) ~= "table" then
		v7 = nil
	end

	local img

	if v7 then
		img = v7.img or tex.image
	end

	local v8

	if type(img) == "string" then
		v8 = img ~= ""
	else
		v8 = false
	end

	local top

	if v7 then
		top = v7.top
	end

	local v9

	if type(top) == "table" and type(top.img) == "string" then
		v9 = top.img ~= ""
	else
		v9 = false
	end

	local edge

	if v7 then
		edge = v7.edge
	end

	local v10

	if type(edge) == "table" and type(edge.img) == "string" then
		v10 = edge.img ~= ""
	else
		v10 = false
	end

	local v11 = (not thickness or not (thickness > 0) or self.bds) and 0 or thickness
	local inner = self.bds and cornerRadius2 and self.extras and self.extras.inner
	local resampleMode

	if tex and tex.pixel then
		resampleMode = Enum.ResamplerMode.Pixelated
	else
		resampleMode = Enum.ResamplerMode.Default
	end

	if v8 then
		local parent = extra(self, "tex", "ImageLabel") -- inferred equivalent call
		parent.BackgroundTransparency = 1
		parent.Image = img

		if v7.stretch then
			parent.ScaleType = Enum.ScaleType.Stretch
		elseif v7.slice then
			local slice = v7.slice
			parent.ScaleType = Enum.ScaleType.Slice
			parent.SliceCenter = Rect.new(slice.c, slice.c, slice.w - slice.c, slice.w - slice.c)
			parent.SliceScale = slice.scale or 1
		else
			local size = v7.size or tex.size
			parent.ScaleType = Enum.ScaleType.Tile
			parent.TileSize = UDim2.fromOffset(size, size)
		end

		parent.ResampleMode = resampleMode
		local v12, v13 = col(v5)
		local v14 = v12 or Color3.new()

		if v7.tint == false then
			parent.ImageColor3 = Color3.new(1, 1, 1)
		else
			local lift = v7.lift or tex.lift or 1
			parent.ImageColor3 = Color3.new(
				math.min(1, v14.R * lift),
				math.min(1, v14.G * lift),
				(math.min(1, v14.B * lift))
			)
		end

		parent.ImageTransparency = 1 - v13 * v2 * (v7.a or 1)
		parent.Position = UDim2.fromOffset(v11, v11)
		parent.Size = UDim2.new(1, -2 * v11, 1, -2 * v11)
		parent.ZIndex = -6
		local uiCorner = parent:FindFirstChildOfClass("UICorner")

		if cornerRadius2 then
			local v15 = uiCorner or Instance.new("UICorner")

			if not (cornerRadius2.Scale > 0) then
				cornerRadius2 = UDim.new(0, (math.max(0, cornerRadius2.Offset - v11)))
			end

			v15.CornerRadius = cornerRadius2
			v15.Parent = parent
		elseif uiCorner then
			uiCorner:Destroy()
		end

		parent.Parent = inner or inst
	else
		dropExtra(self, "tex") -- inferred equivalent call
	end

	if v9 then
		local texTop = extra(self, "texTop", "ImageLabel") -- inferred equivalent call
		texTop.BackgroundTransparency = 1
		texTop.Image = top.img

		if top.stretch then
			texTop.ScaleType = Enum.ScaleType.Stretch
		else
			texTop.ScaleType = Enum.ScaleType.Tile
			texTop.TileSize = UDim2.fromOffset(top.size, top.size)
		end

		texTop.ResampleMode = resampleMode
		texTop.ImageTransparency = 1 - v2
		texTop.Position = UDim2.fromOffset(v11, v11)
		texTop.Size = UDim2.new(1, -2 * v11, 0, top.h or top.size)
		texTop.ZIndex = -5
		texTop.Parent = inner or inst
	else
		dropExtra(self, "texTop") -- inferred equivalent call
	end

	if v10 then
		local texEdge = extra(self, "texEdge", "ImageLabel") -- inferred equivalent call
		texEdge.BackgroundTransparency = 1
		texEdge.Image = edge.img
		texEdge.ScaleType = Enum.ScaleType.Slice
		texEdge.SliceCenter = Rect.new(edge.c, edge.c, edge.w - edge.c, edge.w - edge.c)
		texEdge.SliceScale = edge.scale or 1
		texEdge.ResampleMode = resampleMode
		texEdge.ImageTransparency = 1 - v2
		texEdge.Position = UDim2.fromOffset(v11, v11)
		texEdge.Size = UDim2.new(1, -2 * v11, 1, -2 * v11)
		texEdge.ZIndex = -4
		texEdge.Parent = inner or inst
	else
		dropExtra(self, "texEdge") -- inferred equivalent call
	end

	local shadow = self.shadow

	if shadow then
		local v12 = fx[shadow.img]
		local shadow2 = self.shadowInst

		if not shadow2 then
			shadow2 = Instance.new("ImageLabel")
			shadow2.Name = "shadow"
			self.shadowInst = shadow2
		end

		shadow2.BackgroundTransparency = 1
		shadow2.Image = Glyph.image
		shadow2.ImageRectOffset = Vector2.new(v12.x, v12.y)
		shadow2.ImageRectSize = Vector2.new(v12.w, v12.h)
		shadow2.ScaleType = Enum.ScaleType.Slice
		shadow2.SliceCenter = Rect.new(v12.slice[1], v12.slice[2], v12.slice[3], v12.slice[4])
		local v13 = (shadow.blur or 60) / (shadow.img == "sh60" and 60 or 30)
		shadow2.SliceScale = v12.scale * v13
		self.shadowM = v12.margin * v13 - (shadow.spread or 0)
		local v14, v15 = col(shadow.c or { c = Color3.new(0, 0, 0), a = 0.5 })
		shadow2.ImageColor3 = v14 or Color3.new()
		shadow2.ImageTransparency = 1 - v15 * v2
		shadow2.ZIndex = inst.ZIndex - 1
		shadow2.Parent = inst.Parent
	end

	if self.cover then
		local parent = extra(self, "cover", "Frame") -- inferred equivalent call
		parent.BackgroundTransparency = 1
		parent.Size = UDim2.fromScale(1, 1)
		parent.ZIndex = self.cover.z or 50
		local uiCorner = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, self.cover.r)
		uiCorner.Parent = parent
		local uiStroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.BorderStrokePosition = Enum.BorderStrokePosition.Outer
		uiStroke.Thickness = self.cover.w or 4
		uiStroke.Color = col(self.cover.c) or Color3.new()
		uiStroke.Parent = parent
		parent.Parent = inst

		if self.cover.line then
			local parent2 = extra(self, "coverLine", "Frame") -- inferred equivalent call
			parent2.BackgroundTransparency = 1
			parent2.Size = UDim2.fromScale(1, 1)
			parent2.ZIndex = (self.cover.z or 50) + 1
			local uiCorner2 = parent2:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
			uiCorner2.CornerRadius = UDim.new(0, self.cover.r)
			uiCorner2.Parent = parent2
			local uiStroke2 = parent2:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
			uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke2.BorderStrokePosition = Enum.BorderStrokePosition.Inner
			uiStroke2.Thickness = 1
			local v12, v13 = col(self.cover.line)
			uiStroke2.Color = v12 or Color3.new()
			uiStroke2.Transparency = 1 - v13
			uiStroke2.Parent = parent2
			parent2.Parent = inst
		end
	end

	if self.kind == "text" then
		self.drawn = nil

		if self.laid then
			self:drawText()
		end
	end

	if self.onPaint then
		self.onPaint(self)
	end

	for _, kid in self.kids do
		if kid.op ~= nil or self.op ~= nil or kid.inheritPaint then
			kid:paint()
		end
	end
end

function class:repaintAll()
	self:paint()

	for _, kid in self.kids do
		kid:repaintAll()
	end
end

function Lay.setTheme(th)
	Lay.TH = th

	for k in object do
		if k.inst.Parent ~= nil or k.isRoot then
			k:paint()
		end
	end
end

local function runsOf(data)
	if data.runs then
		return data.runs
	end

	return {
		{ t = data.t, f = data.f, c = nil, ls = data.ls }
	}
end

local function upper(data, t: string) -- 1 equivalent call inferred from this helper
	if data.up then
		return string.upper(t)
	end

	return t
end

local function tokens(data)
	local result = {}

	for k, v2 in runsOf(data) do
		local v3 = upper(data, v2.t or "") -- inferred equivalent call
		local f = v2.f or data.f
		local ls = v2.ls or data.ls or 0

		if data.pre then
			table.insert(result, {
				ri = k,
				t = v3,
				w = Glyph.width(f, v3, ls),
				f = f,
				ls = ls
			})
		else
			local v4 = 1

			while v4 <= #v3 do
				local v5, v6 = string.find(v3, " +", v4)

				if v5 then
					if v4 < v5 then
						local v7 = string.sub(v3, v4, v5 - 1)
						table.insert(result, {
							ri = k,
							t = v7,
							w = Glyph.width(f, v7, ls),
							f = f,
							ls = ls
						})
					end

					table.insert(result, {
						ri = k,
						t = " ",
						w = Glyph.width(f, " ", ls),
						f = f,
						ls = ls,
						space = true
					})
					v4 = v6 + 1
				else
					local v7 = string.sub(v3, v4)
					table.insert(result, {
						ri = k,
						t = v7,
						w = Glyph.width(f, v7, ls),
						f = f,
						ls = ls
					})
					break
				end
			end
		end
	end

	return result
end

local function textIntrinsic(data)
	local v2 = tokens(data)
	local v3 = 0
	local maxValue = 0
	local total = 0

	for _, v4 in v2 do
		v3 += v4.w

		if v4.space then
			maxValue = math.max(maxValue, total)
			total = 0
		else
			total += v4.w
		end
	end

	local v4 = math.max(maxValue, total)
	local pad = data.pad
	local v5 = pad[2] + pad[4]

	if data.wrap then
		if data.maxTW then
			v3 = math.min(v3, data.maxTW)
		end

		return v4 + v5, v3 + v5
	elseif data.ell then
		return v5, v3 + v5
	else
		return v3 + v5, v3 + v5
	end
end

local function wrapLines(object2, p: number)
	local v2 = tokens(object2)
	local lines = {}
	local v3 = { items = 0, w = 0 }
	v3.items = {}
	local function push()
		while #v3.items > 0 and v3.items[#v3.items].space do
			v3.w -= v3.items[#v3.items].w
			table.remove(v3.items)
		end

		table.insert(lines, v3)
		v3 = { items = {}, w = 0 }
	end

	for _, v4 in v2 do
		if object2.wrap and not v4.space then
			local v5 = v3.w + v4.w

			if p + 0.01 < v5 and #v3.items > 0 then
				push()
			end
		end

		if not (not v4.space or #v3.items ~= 0 or not object2.wrap) then
			continue
		end

		if object2.wrap and not v4.space then
			local w = v4.w

			if p + 0.01 < w and object2.breakAll then
				local v5 = ""

				for _, v6 in Glyph.codes(v4.t) do
					local v7 = utf8.char(v6)
					local width = Glyph.width(v4.f, v5 .. v7, v4.ls)

					if p < v3.w + width and v5 ~= "" then
						table.insert(v3.items, {
							ri = v4.ri,
							t = v5,
							w = Glyph.width(v4.f, v5, v4.ls),
							f = v4.f,
							ls = v4.ls
						})
						v3.w += Glyph.width(v4.f, v5, v4.ls)
						push()
						v5 = v7
					else
						v5 ..= v7
					end
				end

				if v5 ~= "" then
					local width = Glyph.width(v4.f, v5, v4.ls)
					table.insert(v3.items, {
						ri = v4.ri,
						t = v5,
						w = width,
						f = v4.f,
						ls = v4.ls
					})
					v3.w += width
				end

				continue
			end
		end

		table.insert(v3.items, v4)
		v3.w += v4.w
	end

	push()

	if not object2.ell or object2.wrap or not lines[1] then
		return lines
	end

	local w = lines[1].w

	if not (p + 0.01 < w) then
		return lines
	end

	local items = lines[1].items
	local f = items[1] and items[1].f or object2.f
	local ls = object2.ls or 0
	local width = Glyph.width(f, "…", ls)
	local total = 0
	local items2 = {}

	for _, item in items do
		if total + item.w + width <= p then
			table.insert(items2, item)
			total += item.w
		else
			local ls2 = item.ls or ls
			local codes = Glyph.codes(item.t)
			local v4 = ""

			for i = #codes, 0, -1 do
				local v5 = ""

				for j = 1, i do
					v5 ..= utf8.char(codes[j])
				end

				local v6 = string.gsub(v5, " +$", "")

				if total + Glyph.width(item.f or f, v6, ls2) + width <= p then
					v4 = v6
					break
				end
			end

			local v5 = v4 .. "…"
			local width2 = Glyph.width(item.f or f, v5, ls2)
			table.insert(items2, {
				ri = item.ri or 1,
				t = v5,
				w = width2,
				f = item.f or f,
				ls = ls2
			})
			total += width2
			break
		end
	end

	lines[1] = { items = items2, w = total }

	return lines
end

function class:lineHeight()
	if self.lh then
		return self.lh
	end

	local f = self.runs and self.runs[1] and self.runs[1].f or self.f
	return Glyph.style(f).lh
end

function class:drawText()
	local inst = self.inst
	local lines = self.lines
	local v2 = opacity(self) -- inferred equivalent call
	local v3, v4 = col(prop(self, "c") or "ink")
	local pad = self.pad
	local lineHeight = self:lineHeight()

	local v5 = runsOf(self)
	local v6 = (self.lw or 0) - pad[2] - pad[4]
	local v7 = 0

	for k, v8 in self.lines or {} do
		local v9 = pad[4]
		local align = self.align or "l"

		if align == "c" then
			v9 += (v6 - v8.w) / 2
		elseif align == "r" then
			v9 += v6 - v8.w
		end

		local v10 = pad[1] + (k - 1) * lineHeight

		for _, item in v8.items do
			if not item.space then
				local v11 = v5[item.ri]
				local v12, v13

				if v11 and v11.c then
					v12, v13 = col(v11.c)
				else
					v13 = v4
					v12 = v3
				end

				local v14 = v10 + Glyph.baseline(item.f, lineHeight)
				v7 = Glyph.draw(
					inst,
					self.pool,
					v7,
					item.f,
					item.t,
					item.ls,
					v9,
					v14,
					v12 or Color3.new(1, 1, 1),
					1 - v13 * v2,
					(self.z or 1) + (self.tz or 0)
				)
			end

			v9 += item.w
		end
	end

	for i = v7 + 1, #self.pool do
		self.pool[i].Visible = false
	end

	self.drawn = lines
end

function class:setText(p: string)
	if self.t == p and not self.runs then
		return
	end

	self.t = p
	self.runs = nil
	self.drawn = nil
	Lay.dirtyFrom(self)
end
function class:setRuns(runs)
	self.runs = runs
	self.t = nil
	self.drawn = nil
	Lay.dirtyFrom(self)
end
function class:set(p: string, p2)
	if self[p] == p2 then
		return
	end

	self[p] = p2
	self:paint()
end

local function inFlow(kid): boolean -- 2 equivalent calls inferred from this helper
	return not (kid.hidden or kid.abs)
end

local function bords(p)
	if p.bds then
		return p.bds[1], p.bds[2], p.bds[3], p.bds[4]
	end

	local bd = p.bd or 0
	return bd, bd, bd, bd
end

function class:intrinsic()
	if self._ip == count then
		return self._imin, self._imax
	end

	local v2, imax

	if self.w then
		v2 = self.w
		imax = self.w
	elseif self.kind == "text" then
		v2, imax = textIntrinsic(self)
	else
		local pad = self.pad
		local v3, v4

		if self.bds then
			local _ = self.bds[1]
			v3 = self.bds[2]
			local _ = self.bds[3]
			v4 = self.bds[4]
		else
			v3 = self.bd or 0
			v4 = v3
		end

		local v5 = pad[2] + pad[4] + v3 + v4
		local count2 = 0
		local total = 0
		local total2 = 0
		local v6 = 0
		local v7 = 0

		for _, kid in self.kids do
			if not inFlow(kid) then -- inferred equivalent call
				continue
			end

			local intrinsic, v8 = kid:intrinsic()
			local v9 = kid.m[2] + kid.m[4]
			local v10 = intrinsic + v9
			local v11 = v8 + v9
			count2 += 1
			total += v10
			total2 += v11
			v6 = math.max(v6, v10)
			v7 = math.max(v7, v11)
		end

		local v8 = math.max(0, count2 - 1) * self.gap

		if self.dir == "row" then
			v7 = total2 + v8

			if not self.wrap then
				v6 = total + v8
			end
		end

		v2 = v6 + v5
		imax = v7 + v5

		if self.textW then
			imax = math.min(imax, self.textW + v5)
		end
	end

	if self.minW then
		v2 = math.max(v2, self.minW)
		imax = math.max(imax, self.minW)
	end

	if self.maxW then
		imax = math.min(imax, self.maxW)
		v2 = math.min(v2, self.maxW)
	end

	local minW = self.shrink0 and (self.minW or 0) or v2
	self._ip = count
	self._imin = minW
	self._imax = imax
	return minW, imax
end

local function clampW(item, p: number) -- 1 equivalent call inferred from this helper
	if item.minW then
		p = math.max(p, item.minW)
	end

	if item.maxW then
		p = math.min(p, item.maxW)
	end

	return p
end

local fn

local function crossPos(p: string, p2: number, p3) -- 2 equivalent calls inferred from this helper
	local v2 = p3.lh_ + p3.m[1] + p3.m[3]

	if p == "center" then
		return (p2 - v2) / 2 + p3.m[1]
	elseif p == "end" then
		return p2 - v2 + p3.m[1]
	end

	return p3.m[1]
end

local function layoutRow(object2, kids, p: number, p2: number?, p3: number, p4: number)
	local gap = object2.gap

	if object2.wrap then
		local v2 = { items = {}, w = 0 }
		local v3 = {}

		for _, item in kids do
			local v4 = item.w or item.basis

			if not v4 then
				local v5
				v5, v4 = item:intrinsic()
			end

			if item.minW then
				v4 = math.max(v4, item.minW)
			end

			if item.maxW then
				v4 = math.min(v4, item.maxW)
			end

			local v5 = math.min(v4, p)
			local v6 = v5 + item.m[2] + item.m[4]

			if #v2.items > 0 then
				local v7 = v2.w + gap + v6

				if p + 0.01 < v7 then
					table.insert(v3, v2)
					v2 = { items = {}, w = 0 }
				end
			end

			v2.w += (not (#v2.items > 0) and 0 or gap) + v6
			table.insert(v2.items, { c = item, w = v5 })
		end

		if #v2.items > 0 then
			table.insert(v3, v2)
		end

		local rowGap = object2.rowGap or gap
		local total = 0

		for k, v4 in v3 do
			local maxValue = 0

			for _, item in v4.items do
				fn(item.c, item.w, item.c.h)
				maxValue = math.max(maxValue, item.c.lh_ + item.c.m[1] + item.c.m[3])
			end

			local v5 = p - v4.w
			local v6 = 0
			local v7 = 0
			local justify = object2.justify

			if justify == "center" then
				v6 = v5 / 2
			elseif justify == "end" then
				v6 = v5
			elseif justify == "between" and #v4.items > 1 then
				v7 = v5 / (#v4.items - 1)
			end

			for _, item in v4.items do
				local c = item.c
				local v8 = c.self or object2.align or "stretch"

				if v8 == "stretch" and not c.h then
					fn(c, item.w, maxValue - c.m[1] - c.m[3])
				end

				c.lx = p3 + v6 + c.m[4]
				c.ly = p4 + total + crossPos(v8, maxValue, c) -- inferred equivalent call
				v6 += c.m[4] + item.w + c.m[2] + gap + v7
			end

			total += maxValue + (not (k < #v3) and 0 or rowGap)
		end

		return total
	else
		local count2 = #kids
		local v2 = table.create(count2)
		local v3 = table.create(count2)
		local v4 = table.create(count2)
		local total = 0

		for k, item in kids do
			local v5

			if item.w then
				v5 = item.w
			elseif item.wf then
				v5 = item.wf(p)
			elseif item.basis then
				v5 = item.basis
			else
				local _
				_, v5 = item:intrinsic()
			end

			if item.minW then
				v5 = math.max(v5, item.minW)
			end

			if item.maxW then
				v5 = math.min(v5, item.maxW)
			end

			local v6

			if item.w then
				v6 = item.w
			elseif item.noShrink then
				v6 = v5
			elseif item.shrink0 then
				v6 = item.minW or 0
			else
				v6 = item:intrinsic()
			end

			v2[k] = v5
			v3[k] = math.min(v6, v5)
			v4[k] = v5
			total += v5 + item.m[2] + item.m[4]
		end

		local v5 = p - (total + math.max(0, count2 - 1) * gap)

		if v5 > 0.001 then
			local total2 = 0

			for _, item in kids do
				total2 += item.grow
			end

			if total2 > 0 then
				for k, item in kids do
					if item.grow > 0 then
						v4[k] = clampW(item, v2[k] + v5 * item.grow / total2) -- inferred equivalent call
					end
				end
			end
		elseif v5 < -0.001 then
			local v6 = -v5
			local set = {}

			for _ = 1, count2 do
				local total2 = 0

				for k, item in kids do
					if not (set[k] or item.noShrink) then
						total2 += v2[k]
					end
				end

				if total2 <= 0 or v6 <= 0.001 then
					break
				end

				local total3 = 0
				local flag = false

				for k, item in kids do
					if set[k] or item.noShrink then
						continue
					end

					local v7 = v6 * v2[k] / total2

					if not (v4[k] - v7 < v3[k]) then
						continue
					end

					total3 += v4[k] - v3[k]
					v4[k] = v3[k]
					set[k] = true
					flag = true
				end

				if flag then
					v6 -= total3
				else
					for k, item in kids do
						if not (set[k] or item.noShrink) then
							v4[k] -= v6 * v2[k] / total2
						end
					end

					break
				end
			end
		end

		local maxValue = 0

		for k, item in kids do
			fn(item, v4[k], item.h)
			maxValue = math.max(maxValue, item.lh_ + item.m[1] + item.m[3])
		end

		local total2 = 0
		local v6 = p2 or maxValue

		for k, item in kids do
			if (item.self or object2.align or "stretch") == "stretch" and not item.h then
				fn(item, v4[k], v6 - item.m[1] - item.m[3])
			end

			total2 += v4[k] + item.m[2] + item.m[4]
		end

		local v7 = p - (total2 + math.max(0, count2 - 1) * gap)
		local v8 = 0
		local v9 = 0
		local justify = object2.justify

		if justify == "center" then
			v8 = v7 / 2
		elseif justify == "end" then
			v8 = v7
		elseif justify == "between" and count2 > 1 then
			v9 = v7 / (count2 - 1)
		end

		for k, item in kids do
			local v10 = item.self or object2.align or "stretch"
			item.lx = p3 + v8 + item.m[4]
			item.ly = p4 + crossPos(v10, v6, item) -- inferred equivalent call
			v8 += item.m[4] + v4[k] + item.m[2] + gap + v9
		end

		return v6
	end
end

local function layoutCol(object2, kids, p: number, p2: number?, p3: number, p4: number)
	local gap = object2.gap
	local count2 = #kids
	local v2 = table.create(count2)
	local total = 0

	for k, item in kids do
		local v3 = item.self or object2.align or "stretch"
		local v4

		if item.w then
			v4 = item.w
		elseif item.wf then
			v4 = item.wf(p)
		elseif v3 == "stretch" then
			v4 = p - item.m[2] - item.m[4]

			if item.minW then
				v4 = math.max(v4, item.minW)
			end

			if item.maxW then
				v4 = math.min(v4, item.maxW)
			end
		else
			local _, v5 = item:intrinsic()

			if item.minW then
				v5 = math.max(v5, item.minW)
			end

			if item.maxW then
				v5 = math.min(v5, item.maxW)
			end

			v4 = math.min(v5, p - item.m[2] - item.m[4])
		end

		v2[k] = v4
		fn(item, v4, item.h or item.hf and item.hf(p2))
		total += item.lh_ + item.m[1] + item.m[3]
	end

	local v3 = total + math.max(0, count2 - 1) * gap

	if p2 then
		local v4 = p2 - v3

		if v4 > 0.001 then
			local total2 = 0

			for _, item in kids do
				total2 += item.grow
			end

			if total2 > 0 then
				for k, item in kids do
					if not (item.grow > 0) then
						continue
					end

					local v5 = item.lh_ + v4 * item.grow / total2

					if item.maxH then
						v5 = math.min(v5, item.maxH)
					end

					fn(item, v2[k], v5)
				end

				v3 = p2
			end
		elseif v4 < -0.001 then
			local total2 = 0

			for _, item in kids do
				if item.vshrink then
					total2 += item.lh_
				end
			end

			if total2 > 0 then
				local v5 = -v4

				for k, item in kids do
					if not item.vshrink then
						continue
					end

					local v6 = math.max(item.minH or 0, item.lh_ - v5 * item.lh_ / total2)
					fn(item, v2[k], v6)
				end

				local total3 = 0

				for _, item in kids do
					total3 += item.lh_ + item.m[1] + item.m[3]
				end

				v3 = total3 + math.max(0, count2 - 1) * gap
			end
		end
	end

	local v4 = (p2 or v3) - v3
	local v5 = 0
	local v6 = 0
	local justify = object2.justify

	if justify == "center" then
		v5 = v4 / 2
	elseif justify == "end" then
		v5 = v4
	elseif justify == "between" and count2 > 1 then
		v6 = v4 / (count2 - 1)
	end

	for k, item in kids do
		local v7 = item.self or object2.align or "stretch"
		local v8 = item.m[4]

		if v7 == "center" then
			v8 = (p - v2[k]) / 2
		elseif v7 == "end" then
			v8 = p - v2[k] - item.m[2]
		end

		item.lx = p3 + v8
		item.ly = p4 + v5 + item.m[1]
		v5 += item.m[1] + item.lh_ + item.m[3] + gap + v6
	end

	return v3
end

local function layoutAbs(object2, kid, lw: number, lh_: number)
	local v2, v3, v4, v5

	if object2.bds then
		v2 = object2.bds[1]
		v3 = object2.bds[2]
		v4 = object2.bds[3]
		v5 = object2.bds[4]
	else
		v5 = object2.bd or 0
		v4 = v5
		v2 = v4
		v3 = v2
		v4 = v3
		v2 = v4
	end

	local v6 = lw - v5 - v3
	local v7 = lh_ - v2 - v4
	local abs = kid.abs
	local v8 = kid.w or kid.wf and kid.wf(v6)

	if not v8 then
		if abs.l and abs.r then
			v8 = v6 - abs.l - abs.r
		else
			local _, v9 = kid:intrinsic()
			v8 = math.min(v9, v6)
		end
	end

	if kid.minW then
		v8 = math.max(v8, kid.minW)
	end

	if kid.maxW then
		v8 = math.min(v8, kid.maxW)
	end

	local v9 = kid.h or kid.hf and kid.hf(v7)

	if not v9 and abs.t and abs.b then
		v9 = v7 - abs.t - abs.b
	end

	fn(kid, v8, v9)
	local lx

	if abs.l then
		lx = v5 + abs.l
	elseif abs.r then
		lx = lw - v3 - abs.r - kid.lw
	elseif abs.cx then
		lx = v5 + (v6 - kid.lw) / 2 + (abs.dx or 0)
	else
		lx = v5
	end

	local ly

	if abs.t then
		ly = v2 + abs.t
	elseif abs.b then
		ly = lh_ - v4 - abs.b - kid.lh_
	elseif abs.cy then
		ly = v2 + (v7 - kid.lh_) / 2 + (abs.dy or 0)
	else
		ly = v2
	end

	if abs.flip then
		local v10 = ly + kid.lh_

		if lh_ - v4 < v10 then
			ly = abs.flip - kid.lh_
		end
	end

	if abs.clamp then
		lx = math.clamp(lx, v5, (math.max(v5, lw - v3 - kid.lw)))
		local v10 = lh_ - v4 - kid.lh_

		if kid.limitY then
			v10 = math.min(v10, v2 + kid.limitY() - kid.lh_)
		end

		ly = math.clamp(ly, v2, (math.max(v2, v10)))
	end

	kid.lx = lx
	kid.ly = ly
end

fn = function(object2, lw: number, hin: number?)
	object2.lw = lw
	object2.laid = true
	object2._Hin = hin

	if object2.kind == "text" then
		local pad = object2.pad
		local lines = wrapLines(object2, lw - pad[2] - pad[4])
		local values = { tostring((math.floor(lw * 100))), object2.align or "l" }

		for _, v2 in lines do
			local v3 = {}

			for _, item in v2.items do
				table.insert(v3, item.t .. "\1" .. item.ri)
			end

			table.insert(values, table.concat(v3, "\2"))
		end

		local joined = table.concat(values, "\3")

		if joined ~= object2.linesSig or not object2.lines then
			object2.lines = lines
			object2.linesSig = joined
		end

		local lineHeight = object2:lineHeight()
		local lh_ = hin or #object2.lines * lineHeight + pad[1] + pad[3]

		if object2.minH then
			lh_ = math.max(lh_, object2.minH)
		end

		object2.lh_ = lh_
	else
		local pad = object2.pad
		local v2, v3, v4, v5

		if object2.bds then
			v2 = object2.bds[1]
			v3 = object2.bds[2]
			v4 = object2.bds[3]
			v5 = object2.bds[4]
		else
			v5 = object2.bd or 0
			v4 = v5
			v2 = v4
			v3 = v2
			v4 = v3
			v2 = v4
		end

		local v6 = lw - pad[2] - pad[4] - v5 - v3
		local v7

		if hin then
			v7 = hin - pad[1] - pad[3] - v2 - v4
		end

		local kids = {}

		for _, kid in object2.kids do
			if inFlow(kid) then -- inferred equivalent call
				table.insert(kids, kid)
			end
		end

		local v8 = v5 + pad[4]
		local v9 = v2 + pad[1]
		local v10

		if object2.scroll then
			if object2.dir == "row" then
				v10 = layoutRow(object2, kids, v6, nil, v8, v9)
			else
				v10 = layoutCol(object2, kids, v6, nil, v8, v9)
			end

			object2.canvasH = v10 + pad[1] + pad[3] + v2 + v4
		elseif object2.dir == "row" then
			v10 = layoutRow(object2, kids, v6, v7, v8, v9)
		else
			v10 = layoutCol(object2, kids, v6, v7, v8, v9)
		end

		local lh_ = hin or v10 + pad[1] + pad[3] + v2 + v4

		if object2.minH then
			lh_ = math.max(lh_, object2.minH)
		end

		if object2.maxH and not hin then
			lh_ = math.min(lh_, object2.maxH)
		end

		object2.lh_ = lh_

		if object2.scroll and object2.maxH and not hin then
			object2.lh_ = math.min(lh_, object2.maxH)
		end

		for _, kid in object2.kids do
			if not kid.abs or kid.hidden then
				continue
			end

			layoutAbs(object2, kid, lw, object2.lh_)
		end

		if object2.afterLayout then
			object2.afterLayout(object2)
		end
	end
end
Lay.layoutNode = fn
local function apply(object2, pax: number, pay: number, prx: number, pry: number)
	local ax = pax + (object2.lx or 0)
	local ay = pay + (object2.ly or 0) + (object2.ty or 0)
	local v2 = math.floor(ax + 0.5)
	local v3 = math.floor(ay + 0.5)
	local pw = math.floor(ax + object2.lw + 0.5) - v2
	local ph = math.floor(ay + object2.lh_ + 0.5) - v3
	local px = v2 - prx
	local py = v3 - pry

	if object2._px ~= px or object2._py ~= py then
		object2._px = px
		object2._py = py
		object2.inst.Position = UDim2.fromOffset(px, py)
	end

	if object2._pw ~= pw or object2._ph ~= ph then
		object2._pw = pw
		object2._ph = ph
		object2.inst.Size = UDim2.fromOffset(pw, ph)
	end

	object2.ax = ax
	object2.ay = ay

	object2._pax = pax
	object2._pay = pay
	object2._prx = prx
	object2._pry = pry

	if object2.shadowInst and object2.shadow then
		local shadowM = object2.shadowM or 0
		local shadowInst = object2.shadowInst
		shadowInst.Parent = object2.inst.Parent
		shadowInst.Position = UDim2.fromOffset(
			px - shadowM + (object2.shadow.x or 0),
			py - shadowM + (object2.shadow.y or 0)
		)
		shadowInst.Size = UDim2.fromOffset(pw + 2 * shadowM, ph + 2 * shadowM)
		shadowInst.Visible = object2.inst.Visible
	end

	if object2.kind == "text" then
		if object2.drawn ~= object2.lines then
			object2:drawText()
		end
	elseif object2.scroll then
		local inst = object2.inst
		local ch = math.floor((object2.canvasH or 0) + 0.5)

		if object2._ch ~= ch then
			object2._ch = ch
			inst.CanvasSize = UDim2.fromOffset(0, ch)
		end

		for _, kid in object2.kids do
			if kid.hidden or not kid.laid then
				continue
			end

			apply(kid, ax, ay, v2, v3)
		end

		if object2.onScrollLayout then
			object2.onScrollLayout(object2)
		end
	else
		for _, kid in object2.kids do
			if kid.hidden or not kid.laid then
				continue
			end

			apply(kid, ax, ay, v2, v3)
		end

		if object2.afterApply then
			object2.afterApply(object2)
		end
	end
end

local v2 = {}
local flag = false

local v3 = {}
function Lay:root(size)
	self.isRoot = true

	for _, v4 in v2 do
		if v4.n == self then
			v4.size = size
			Lay.dirty()
			return
		end
	end

	table.insert(v2, { n = self, size = size })
	Lay.dirty()
end
function Lay.dirty()
	flag = true
end
function Lay.dirtyFrom(data)
	if flag then
		return
	end

	while data and not data.boundary do
		data = data.parent
	end

	if data and data.laid and data._pax and data.parent then
		v3[data] = true
	else
		flag = true
	end
end
function Lay.flush()
	if not flag then
		if next(v3) == nil then
			return
		end

		count += 1

		for k in v3 do
			v3[k] = nil

			if not k.parent or k.hidden then
				continue
			end

			local lh_ = k.lh_
			fn(k, k.lw, k._Hin)

			if math.abs(k.lh_ - lh_) > 0.001 then
				flag = true
			else
				apply(k, k._pax, k._pay, k._prx, k._pry)
			end
		end

		if not flag then
			return
		end
	end

	table.clear(v3)
	flag = false
	count += 1

	for _, v4 in v2 do
		local size, v5, v6, v7 = v4.size()
		local n = v4.n

		if n.hidden then
			continue
		end

		fn(n, size, v5)
		n.lx = v6 or 0
		n.ly = v7 or 0
		apply(n, 0, 0, 0, 0)
	end
end

function Lay.now()
	flag = true
	Lay.flush()
end

function class:bindHover()
	local inst = self.inst
	inst.MouseEnter:Connect(function()
		self.hovering = true
		self:paint()
	end)
	inst.MouseLeave:Connect(function()
		self.hovering = false
		self:paint()
	end)
end

Lay.clicks = setmetatable({}, { __mode = "k" })
function class.onClick(p, callback)
	local inst = p.inst
	local function go()
		if p.disabled then
			return
		end

		callback()
	end
	inst.Activated:Connect(go)
	local gos = Lay.clicks[inst]

	if not gos then
		gos = {}
		Lay.clicks[inst] = gos
	end

	table.insert(gos, go)
end

function Lay.tween(instance, duration: number, goal)
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		goal
	)
	tween:Play()
	return tween
end

return Lay