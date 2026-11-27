return function(data)
	local u = data.U
	local f = data.F
	local s = data.S
	local toast = data.toast
	local setPressed = data.setPressed
	local v = nil
	local v2 = 0

	local function click(): string -- 1 equivalent call inferred from this helper
		return if f.touchUI then "Tap" else "Click"
	end

	local function paint() -- 4 equivalent calls inferred from this helper
		local secHud = u.secHud
		secHud.label:setText(v and "Pick notes…" or s.secA and "Full song" or "Section")
		setPressed(secHud, v ~= nil or s.secA ~= nil)
	end

	function f.secLoop()
		if not s.secA then
			return
		end

		for i = s.secA, s.secB do
			s.res[i] = nil
			s.times[i] = nil
		end

		s.idx = s.secA
		table.clear(s.got)
		s.mistakes = 0
		s.goodKeys = 0
		s.start = nil
		s.finished = false
		f.render()
	end

	function f.secPick(secMark: number): boolean
		if not v then
			return false
		end

		if v == "first" then
			v2 = secMark
			s.secMark = secMark
			v = "last"
			f.render()
			toast("Now the last note of the part.")
		else
			s.secMark = nil
			local secA = math.min(v2, secMark)
			local secB = math.max(v2, secMark)
			s.secA = secA
			s.secB = secB
			v = nil
			f.secLoop()
			toast("Only this part plays now, again and again. Full song plays it all.")
		end

		paint() -- inferred equivalent call
		return true
	end

	function f.secClear()
		v = nil
		s.secMark = nil
		s.secA = nil
		s.secB = nil
		paint() -- inferred equivalent call
	end

	u.secHud:onClick(function()
		if #s.steps == 0 then
			toast("Open a sheet first.")
		elseif v then
			f.secClear()
			f.render()
		elseif s.secA then
			f.secClear()
			s.idx = 1
			f.secLoopAll()
			toast("The whole song again.")
		else
			v = "first"
			toast(click() .. " the first note of the part in the sheet, then the last one.") -- inferred equivalent call
			paint() -- inferred equivalent call
		end
	end)

	function f.secLoopAll()
		table.clear(s.res)
		table.clear(s.times)
		table.clear(s.got)
		s.idx = 1
		s.mistakes = 0
		s.goodKeys = 0
		s.start = nil
		s.finished = false
		f.render()
	end

	paint() -- inferred equivalent call
end