local Notes = {}
Notes.VP = "1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"
Notes.LOW = 36
Notes.NOTE = {}
Notes.ORDER = {}

for i = 1, #Notes.VP do
	local v = string.sub(Notes.VP, i, i)
	Notes.NOTE[v] = Notes.LOW + i - 1
	Notes.ORDER[i] = v
end

local v = {
	"C",
	"C#",
	"D",
	"D#",
	"E",
	"F",
	"F#",
	"G",
	"G#",
	"A",
	"A#",
	"B"
}
function Notes.isBlack(p: number): boolean
	local v2 = p % 12
	return v2 == 1 or v2 == 3 or v2 == 6 or v2 == 8 or v2 == 10
end

function Notes.noteName(p: number)
	return v[p % 12 + 1] .. tostring(math.floor(p / 12) - 1)
end

Notes.SHIFTSYM = {
	["!"] = "1",
	["@"] = "2",
	["#"] = "3",
	["$"] = "4",
	["%"] = "5",
	["^"] = "6",
	["&"] = "7",
	["*"] = "8",
	["("] = "9",
	[")"] = "0"
}
Notes.DIGSHIFT = {
	["1"] = "!",
	["2"] = "@",
	["3"] = "#",
	["4"] = "$",
	["5"] = "%",
	["6"] = "^",
	["7"] = "&",
	["8"] = "*",
	["9"] = "(",
	["0"] = ")"
}

function Notes.physical(p: string)
	if Notes.SHIFTSYM[p] then
		return true, Notes.SHIFTSYM[p]
	end

	if p >= "A" and p <= "Z" then
		return true, p
	end

	return false, p
end

function Notes.parse(value: string)
	local v2 = {}
	local result = {}

	local v3 = 0
	local count = 0
	local count2 = 0
	local count3 = 0

	local count4 = #value
	local function gap()
		local v4

		if v3 == 0 and count == 0 and count2 == 0 and count3 == 0 then
			v4 = 0.5
		elseif count3 > 0 and count == 0 and count2 == 0 then
			v4 = 0.75
		else
			local v5 = math.max(0, v3 - (count > 0 and 0 or 1))
			v4 = count + 1 + v5 * 0.5 + (count2 >= 2 and 2 or 0)
		end

		v3 = 0
		count = 0
		count2 = 0
		count3 = 0
		return (math.min(v4, 8))
	end

	local function push(keys, p: number, p2: number, p3: number) -- 3 equivalent calls inferred from this helper
		table.insert(v2, {
			keys = keys,
			s = p,
			e = p2,
			wait = #v2 == 0 and 0 or p3
		})
	end

	local v4 = 1

	while v4 <= count4 do
		local v5 = string.sub(value, v4, v4)

		if v5 == "/" and string.sub(value, v4 + 1, v4 + 1) == "/" then
			local v6 = string.find(value, "\n", v4 + 1, true)
			local v7

			if v6 then
				v7 = v6 - 1
			else
				v7 = count4
			end

			table.insert(result, { v4, v7 })
			v4 = v7 + 1
		elseif v5 == "[" then
			local v6 = string.find(value, "]", v4 + 1, true)
			local v7 = string.find(value, "\n", v4 + 1, true)

			if v6 and not (v7 and v7 < v6) then
				local v8 = string.sub(value, v4 + 1, v6 - 1)

				if string.find(v8, "%S%s+%S") then
					local v9 = true

					for i = v4 + 1, v6 - 1 do
						local v10 = string.sub(value, i, i)

						if not Notes.NOTE[v10] then
							continue
						end

						push({ v10 }, i, i, not v9 and 0.25 or gap()) -- inferred equivalent call
						v9 = false
					end
				else
					local set = {}
					local keys = {}

					for i = 1, #v8 do
						local v9 = string.sub(v8, i, i)

						if not Notes.NOTE[v9] or set[v9] then
							continue
						end

						set[v9] = true
						table.insert(keys, v9)
					end

					if #keys > 0 then
						push(keys, v4, v6, gap()) -- inferred equivalent call
					end
				end

				v4 = v6 + 1
			else
				v4 += 1
			end
		else
			if Notes.NOTE[v5] then
				push({ v5 }, v4, v4, gap()) -- inferred equivalent call
			elseif v5 == " " or v5 == "\t" then
				if count2 == 0 then
					v3 += 1
				end
			elseif v5 == "-" then
				count3 += 1
			elseif v5 == "|" then
				count += 1
			elseif v5 == "\n" then
				count2 += 1
				v3 = 1
			end

			v4 += 1
		end
	end

	return v2, result
end

function Notes.fmtK(value: number)
	local v2 = math.max(0, (math.floor(value or 0)))

	if v2 < 1000 then
		return (tostring(v2))
	end

	local function f(p: number) -- 2 equivalent calls inferred from this helper
		if p < 10 then
			local v3 = string.format("%.1f", p)
			return (string.gsub(v3, "%.0$", ""))
		end

		return (tostring((math.floor(p))))
	end

	if v2 < 1000000 then
		return f(v2 / 1000) .. "k" -- inferred equivalent call
	end

	return f(v2 / 1000000) .. "M" -- inferred equivalent call
end

function Notes.fmtTime(p: number)
	local v2 = math.floor(p / 1000)
	return string.format("%d:%02d", v2 // 60, v2 % 60)
end

function Notes.plural(p: number, p2: string, p3: string, p4: string)
	local v2 = p % 10
	local v3 = p % 100

	if v2 == 1 and v3 ~= 11 then
		return p2
	end

	if v2 >= 2 and v2 <= 4 and (v3 < 10 or v3 >= 20) then
		return p3
	end

	return p4
end

return Notes