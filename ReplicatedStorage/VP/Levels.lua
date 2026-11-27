local list = {
	{
		name = "Easy",
		color = "5fd068",
		grad = { "4fc95e", "b6f27a" }
	},
	{
		name = "Easy+",
		color = "3fbf8c",
		grad = { "34b882", "6fe3c2" }
	},
	{
		name = "Simplified",
		color = "4cc4c9",
		grad = { "3ab8c4", "7fe6ff" }
	},
	{
		name = "Normal",
		color = "4aa3f0",
		grad = { "3d8ff0", "86d0ff" }
	},
	{
		name = "Normal+",
		color = "4a7ff2",
		grad = { "4a6cf2", "8fa6ff" }
	},
	{
		name = "Average",
		color = "8f7ff5",
		grad = { "7f6cf5", "c79bff" }
	},
	{
		name = "Challenging",
		color = "c27cf0",
		grad = { "b46cf0", "ff8ad6" }
	},
	{
		name = "Advanced",
		color = "f0823a",
		grad = { "f0762e", "ffc04d" }
	},
	{
		name = "Advanced+",
		color = "f0643a",
		grad = { "f0502e", "ff9f45" }
	},
	{
		name = "Advanced++",
		color = "e8463a",
		grad = { "e0302e", "ff7a45", "ffb04d" }
	},
	{
		name = "Expert",
		color = "d6245f",
		grad = { "c81f5a", "ff4f8b", "ff9ac0" }
	},
	{
		name = "Intermediate",
		color = "0b2219",
		dark = true,
		grad = { "2c6339", "3d7d48", "5f9460" }
	},
	{
		name = "Virtuoso",
		color = "231b04",
		dark = true,
		grad = { "6e4c0e", "94681a", "b08c3c" }
	},
	{
		name = "God",
		color = "240617",
		dark = true,
		grad = { "000000" }
	},
	{
		name = "Impossible",
		color = "120202",
		dark = true,
		grad = { "460505", "5c0808", "6e0a0a", "4f0606" }
	}
}

local Levels = { list = list, byName = {} }

for k, v in list do
	v.order = k
	v.c = Color3.fromHex(v.color)

	v.ink = v.c
	v.stops = {}

	for _, v2 in v.grad do
		table.insert(v.stops, Color3.fromHex(v2))
	end

	Levels.byName[v.name] = v
end

Levels.byName.Medium = Levels.byName.Normal
Levels.byName.Hard = Levels.byName.Advanced
function Levels.valid(value): boolean
	return type(value) == "string" and Levels.byName[value] ~= nil and value ~= "Medium" and value ~= "Hard"
end

function Levels.get(value)
	if type(value) == "string" then
		return Levels.byName[value]
	end

	return nil
end

function Levels.at(p, value: number)
	local stops = p.stops

	if #stops == 1 then
		return stops[1]
	end

	local v = math.clamp(value, 0, 1) * (#stops - 1)
	local v2 = math.min(math.floor(v) + 1, #stops - 1)
	return stops[v2]:Lerp(stops[v2 + 1], v - (v2 - 1))
end

function Levels.runs(p)
	local v = Levels.get(p)

	if not v then
		return {
			{ t = tostring(p) }
		}
	end

	local name = v.name
	local count = #name
	local result = {}

	for i = 1, count do
		local v2 = not (count > 1) and 0 or (i - 1) / (count - 1)
		table.insert(result, {
			t = string.sub(name, i, i),
			c = { c = Levels.at(v, v2), a = 1 }
		})
	end

	return result
end

Levels.RATING_START = 1000
function Levels.perf(value: number, value2: number)
	return math.clamp(value, 0, 1) * 0.5 + math.clamp(value2, 0, 1) * 0.5
end

function Levels.score(p, p2: number, p3: number, p4: number)
	local v = Levels.get(p)

	if not v then
		return nil
	end

	local v2 = math.clamp(p4 / 150, 0.2, 1)
	return math.floor(v.order * (Levels.perf(p2, p3) - 0.6) * 3.2 * v2 * 100 + 0.5) / 100
end

function Levels.verdict(p: number): string
	if p >= 0.95 then
		return "Masterful performance!"
	end

	if p >= 0.85 then
		return "Excellent playing!"
	end

	if p >= 0.72 then
		return "Well played!"
	end

	if p >= 0.6 then
		return "Good, but you can do better"
	end

	if p >= 0.4 then
		return "Keep practising"
	end

	return "That was a rough one"
end

return Levels