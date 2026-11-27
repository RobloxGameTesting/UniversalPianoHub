local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vp = ReplicatedStorage:WaitForChild("VP")
local GlyphData = require(vp:WaitForChild("GlyphData"))
local KernData = require(vp:WaitForChild("KernData"))

local Glyph = {}
Glyph.image = GlyphData.image
Glyph.fx = GlyphData.fx

local v = {}
local v2 = {}
local v3 = {}

for i = 1, 64 do
	v[string.byte("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_", i)] = i - 1
end

local function dec(value: string, p: number, p2: number) -- 15 equivalent calls inferred from this helper
	local v4 = 0

	for i = p, p + p2 - 1 do
		v4 = v4 * 64 + v[string.byte(value, i)]
	end

	return v4
end

local function kernTable(kf: string)
	if kf == "" then
		return nil
	end

	local v4 = v2[kf]

	if v4 then
		return v4
	end

	local result = {}
	local v5 = KernData[kf]

	if v5 then
		for i = 1, #v5, 5 do
			local v6 = dec(v5, i, 3) -- inferred equivalent call
			local v7 = v6 // 95 + 32
			local v8 = v6 % 95 + 32
			local v9 = result[v7]

			if not v9 then
				v9 = {}
				result[v7] = v9
			end

			v9[v8] = (dec(v5, i + 3, 2) - 2048) / 1000 -- inferred equivalent call
		end
	end

	v2[kf] = result
	return result
end

function Glyph.style(name: string)
	local v4 = v3[name]

	if v4 then
		return v4
	end

	local style = GlyphData.styles[name]
	assert(style, "unknown text style " .. tostring(name))
	local v5 = {
		name = name,
		sz = style.sz,
		asc = style.asc,
		desc = style.desc,
		lh = style.lh,
		g = {},
		kern = kernTable(style.kf),
		weight = tonumber(string.match(name, "^%a+(%d+)")) or 400,
		mono = string.sub(name, 1, 1) == "m"
	}

	local function full(value: string)
		for i = 1, #value, 13 do
			local v6 = dec(value, i, 3) -- inferred equivalent call
			local adv = dec(value, i + 3, 2) / 100 -- inferred equivalent call
			local v7 = dec(value, i + 5, 2) -- inferred equivalent call

			if v7 == 4095 then
				v5.g[v6] = { adv = adv }
			else
				local g = v5.g
				local v8 = i + 7
				local v9 = 0
				local v10 = {
					adv = adv,
					x = v7,
					y = 0,
					w = 0,
					h = 0,
					ox = 0,
					oy = 0
				}

				for j = v8, v8 + 2 - 1 do
					v9 = v9 * 64 + v[string.byte(value, j)]
				end

				v10.y = v9
				v10.w = dec(value, i + 9, 1) -- inferred equivalent call
				v10.h = dec(value, i + 10, 1) -- inferred equivalent call
				v10.ox = dec(value, i + 11, 1) - 32 -- inferred equivalent call
				v10.oy = dec(value, i + 12, 1) - 40 -- inferred equivalent call
				g[v6] = v10
			end
		end
	end

	if style.madv then
		local g = style.g
		local madv = style.madv

		for i = 1, #g, 11 do
			local v6 = dec(g, i, 3) -- inferred equivalent call
			local v7 = dec(g, i + 3, 2) -- inferred equivalent call

			if v7 == 4095 then
				v5.g[v6] = { adv = madv }
			else
				local g2 = v5.g
				local v8 = i + 5
				local v9 = 0
				local v10 = {
					adv = madv,
					x = v7,
					y = 0,
					w = 0,
					h = 0,
					ox = 0,
					oy = 0
				}

				for j = v8, v8 + 2 - 1 do
					v9 = v9 * 64 + v[string.byte(g, j)]
				end

				v10.y = v9
				v10.w = dec(g, i + 7, 1) -- inferred equivalent call
				v10.h = dec(g, i + 8, 1) -- inferred equivalent call
				v10.ox = dec(g, i + 9, 1) - 32 -- inferred equivalent call
				v10.oy = dec(g, i + 10, 1) - 40 -- inferred equivalent call
				g2[v6] = v10
			end
		end

		if style.ex then
			full(style.ex)
		end
	else
		full(style.g)
	end

	v3[name] = v5
	return v5
end

local function codes(value: string)
	local result = {}

	if not pcall(function()
		for _, v4 in utf8.codes(value) do
			table.insert(result, v4)
		end
	end) then
		table.clear(result)

		for i = 1, #value do
			table.insert(result, string.byte(value, i))
		end
	end

	return result
end

Glyph.codes = codes

local function fallbackAdv(style, p: number) -- 2 equivalent calls inferred from this helper
	if p >= 126976 then
		return style.sz * 1.2
	end

	if p >= 8192 then
		return style.sz * 0.95
	end

	return style.sz * 0.6
end

function Glyph.run(p: string, p2: string, value: number?)
	local style = Glyph.style(p)

	local kern = style.kern
	local v4 = nil
	local total = 0
	local result = {}
	local v5 = value or 0

	for _, v6 in codes(p2) do
		local v7 = style.g[v6]

		if v4 and kern then
			local v8 = kern[v4]

			if v8 then
				local v9 = v8[v6]

				if v9 then
					total += v9 * style.sz
				end
			end
		end

		table.insert(result, v6)
		table.insert(result, total)
		local v8

		if v7 then
			v8 = v7.adv
		else
			v8 = fallbackAdv(style, v6) -- inferred equivalent call
		end

		total += v8 + v5
		v4 = v6
	end

	return result, total
end

function Glyph.width(p: string, p2: string, p3: number?)
	local _, v4 = Glyph.run(p, p2, p3)
	return v4
end

function Glyph.supports(p: string, p2: string): boolean
	local style = Glyph.style(p)

	for _, v4 in codes(p2) do
		if not style.g[v4] then
			return false
		end
	end

	return true
end

function Glyph.baseline(p: string, p2: number?)
	local style = Glyph.style(p)
	return ((p2 or style.lh) - (style.asc + style.desc)) / 2 + style.asc
end

local v4 = {
	[400] = Enum.FontWeight.Regular,
	[500] = Enum.FontWeight.Medium,
	[600] = Enum.FontWeight.SemiBold,
	[700] = Enum.FontWeight.Bold
}
function Glyph.nativeFont(value: string)
	local style = Glyph.style(value)
	local v5 = string.sub(value, 1, 2) == "si"
	local v6 = v4[style.weight] or Enum.FontWeight.Regular
	local v7

	if v5 then
		v7 = Enum.FontStyle.Italic
	else
		v7 = Enum.FontStyle.Normal
	end

	return Font.fromId(12187364147, v6, v7)
end

function Glyph:fitInput(p: string)
	local nativeFont = Glyph.nativeFont(p)
	local rbxassetfontsfamiliesBuilderSansjson = Font.new(
		"rbxasset://fonts/families/BuilderSans.json",
		nativeFont.Weight,
		nativeFont.Style
	)
	local v5 = nil
	local function upd() -- 1 equivalent call inferred from this helper
		local v6 = string.find(self.Text, "[\205-\212]") ~= nil

		if v6 ~= v5 then
			v5 = v6
			local fontFace

			if v6 then
				fontFace = rbxassetfontsfamiliesBuilderSansjson
			else
				fontFace = nativeFont
			end

			self.FontFace = fontFace
		end
	end
	self:GetPropertyChangedSignal("Text"):Connect(upd)
	upd() -- inferred equivalent call
end
function Glyph.nativeSize(p: string)
	return (math.floor(Glyph.style(p).sz * 1.305 + 0.5))
end

function Glyph.draw(parent, p, count: number, p2: string, p3: string, p4: number?, p5: number, p6: number, color: Color3, p7: number, zIndex: number)
	local style = Glyph.style(p2)
	local v5 = Glyph.run(p2, p3, p4)
	local v6 = math.floor(p6 + 0.5)

	for i = 1, #v5, 2 do
		local v7 = v5[i]
		local v8 = style.g[v7]
		local v9 = math.floor(p5 + v5[i + 1] + 0.5)

		if v8 and v8.x then
			count += 1
			local v10 = p[count]

			if not (v10 and v10:IsA("ImageLabel")) then
				if v10 then
					v10:Destroy()
				end

				v10 = Instance.new("ImageLabel")
				v10.BackgroundTransparency = 1
				v10.BorderSizePixel = 0
				v10.Image = GlyphData.image
				v10.ResampleMode = Enum.ResamplerMode.Default
				p[count] = v10
			end

			v10.ImageRectOffset = Vector2.new(v8.x, v8.y)
			v10.ImageRectSize = Vector2.new(v8.w, v8.h)
			v10.Size = UDim2.fromOffset(v8.w, v8.h)
			v10.Position = UDim2.fromOffset(v9 + v8.ox, v6 + v8.oy)
			v10.ImageColor3 = color
			v10.ImageTransparency = p7
			v10.ZIndex = zIndex
			v10.Visible = true
			v10.Parent = parent
		elseif not v8 and v7 ~= 32 then
			count += 1
			local v10 = p[count]

			if not (v10 and v10:IsA("TextLabel")) then
				if v10 then
					v10:Destroy()
				end

				v10 = Instance.new("TextLabel")
				v10.BackgroundTransparency = 1
				v10.BorderSizePixel = 0
				v10.TextXAlignment = Enum.TextXAlignment.Left
				v10.TextYAlignment = Enum.TextYAlignment.Bottom
				p[count] = v10
			end

			v10.FontFace = Glyph.nativeFont(p2)
			v10.TextSize = Glyph.nativeSize(p2)
			v10.Text = utf8.char(v7)
			v10.Size = UDim2.fromOffset(math.ceil(fallbackAdv(style, v7)) + 2, (math.ceil(style.asc + style.desc))) -- inferred equivalent call
			v10.Position = UDim2.fromOffset(v9, v6 - math.ceil(style.asc) + math.floor(style.desc * 0.35))
			v10.TextColor3 = color
			v10.TextTransparency = p7
			v10.ZIndex = zIndex
			v10.Visible = true
			v10.Parent = parent
		end
	end

	return count
end

return Glyph