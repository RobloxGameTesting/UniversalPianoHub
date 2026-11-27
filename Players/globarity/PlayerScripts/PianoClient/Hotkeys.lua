return function(data)
	local b = data.B
	local u = data.U
	local f = data.F
	local s = data.S
	local btn = data.btn
	local toast = data.toast
	local UserInputService = game:GetService("UserInputService")
	local GuiService = game:GetService("GuiService")
	local backspace = Enum.KeyCode.Backspace
	local v = backspace
	local v2 = nil

	local v3 = {
		Space = true,
		Tab = true,
		Up = true,
		Down = true,
		Left = true,
		Right = true,
		Return = true,
		KeypadEnter = true,
		LeftBracket = true,
		RightBracket = true,
		LeftShift = true,
		RightShift = true,
		LeftControl = true,
		RightControl = true,
		LeftAlt = true,
		RightAlt = true,
		LeftSuper = true,
		RightSuper = true,
		LeftMeta = true,
		RightMeta = true,
		Escape = true,
		CapsLock = true,
		Unknown = true,
		Zero = true,
		One = true,
		Two = true,
		Three = true,
		Four = true,
		Five = true,
		Six = true,
		Seven = true,
		Eight = true,
		Nine = true
	}

	local function free(p): boolean -- 2 equivalent calls inferred from this helper
		local name = p.Name

		return not v3[name] and #name > 1
	end

	function f.restartKey()
		return v
	end

	function f.keyPrefs(p)
		if type(p) ~= "table" or type(p.rkey) ~= "string" then
			return
		end

		local success, result = pcall(function()
			return Enum.KeyCode[p.rkey]
		end)

		if success and result and free(result) then -- inferred equivalent call
			v = result
		end
	end

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if v2 then
			local v4 = v2
			v2 = nil

			if v4.inst.Parent then
				if input.KeyCode ~= Enum.KeyCode.Escape then
					if free(input.KeyCode) then -- inferred equivalent call
						v = input.KeyCode
						f.savePref("rkey", v.Name)
					else
						toast(input.KeyCode.Name .. " is already used by the game. Pick another key.")
					end
				end

				v4.label:setText(v.Name)
				return
			end
		end

		if
			input.KeyCode ~= v
			or (u.dialog and not u.dialog.playable or UserInputService:GetFocusedTextBox() or GuiService.MenuIsOpen)
		then
			return
		end

		if s.mode == "free" or #s.steps == 0 then
			return
		end

		f.restart()
	end)

	function f.keyRow(p, callback)
		if f.touchUI or f.vrOn then
			return
		end

		local v4 = b({
			dir = "row",
			align = "center",
			gap = 8,
			parent = callback(
				p,
				"Restart key",
				"Starts the sheet over in Practice and Autoplay, like the round-arrow button."
			)
		})
		local v5 = btn(v.Name)
		v4:add(v5)
		v5:onClick(function()
			v2 = v5
			v5.label:setText("Press a key…")
		end)
		local v6 = btn("Default")
		v4:add(v6)
		v6:onClick(function()
			v2 = nil
			v = backspace
			v5.label:setText(v.Name)
			f.savePref("rkey", v.Name)
		end)
	end
end