local Sfx = {}

Sfx.KINDS = {
	{
		key = "reverb",
		name = "Reverb",
		class = "ReverbSoundEffect",
		prio = 4,
		params = {
			{ "DecayTime", "Decay", 0.1, 20, 0.1, "s" },
			{ "WetLevel", "Wet", -60, 0, 1, "dB" },
			{ "DryLevel", "Dry", -60, 0, 1, "dB" },
			{ "Density", "Density", 0, 1, 0.05, "" },
			{ "Diffusion", "Diffusion", 0, 1, 0.05, "" }
		},
		presets = {
			{
				"basic",
				"Basic",
				{
					DecayTime = 1.8,
					Density = 1,
					Diffusion = 1,
					WetLevel = -16,
					DryLevel = 0
				}
			},
			{
				"room",
				"Room",
				{
					DecayTime = 0.7,
					Density = 1,
					Diffusion = 0.8,
					WetLevel = -12,
					DryLevel = 0
				}
			},
			{
				"stone",
				"Stone Room",
				{
					DecayTime = 1.4,
					Density = 0.6,
					Diffusion = 0.6,
					WetLevel = -8,
					DryLevel = 0
				}
			},
			{
				"hall",
				"Concert Hall",
				{
					DecayTime = 3.2,
					Density = 1,
					Diffusion = 1,
					WetLevel = -10,
					DryLevel = -1
				}
			},
			{
				"plate",
				"Plate",
				{
					DecayTime = 2.2,
					Density = 0.4,
					Diffusion = 1,
					WetLevel = -9,
					DryLevel = 0
				}
			},
			{
				"cathedral",
				"Cathedral",
				{
					DecayTime = 7,
					Density = 1,
					Diffusion = 1,
					WetLevel = -7,
					DryLevel = -3
				}
			},
			{
				"hangar",
				"Hangar",
				{
					DecayTime = 11,
					Density = 1,
					Diffusion = 1,
					WetLevel = -8,
					DryLevel = -2
				}
			},
			{
				"space",
				"Space",
				{
					DecayTime = 18,
					Density = 0.3,
					Diffusion = 1,
					WetLevel = -6,
					DryLevel = -4
				}
			}
		}
	},
	{
		key = "eq",
		name = "Equalizer",
		class = "EqualizerSoundEffect",
		prio = 10,
		params = {
			{ "LowGain", "Low", -40, 10, 1, "dB" },
			{ "MidGain", "Mid", -40, 10, 1, "dB" },
			{ "HighGain", "High", -40, 10, 1, "dB" }
		},
		presets = {
			{
				"bright",
				"Bright",
				{ LowGain = -2, MidGain = 0, HighGain = 6 }
			},
			{
				"warm",
				"Warm",
				{ LowGain = 4, MidGain = 1, HighGain = -5 }
			},
			{
				"vocals",
				"Vocals",
				{ LowGain = -6, MidGain = 4, HighGain = 1 }
			},
			{
				"midbass",
				"Mid Bass",
				{ LowGain = 6, MidGain = 2, HighGain = -2 }
			},
			{
				"deepbass",
				"Deep Bass",
				{ LowGain = 9, MidGain = -3, HighGain = -4 }
			},
			{
				"vintage",
				"Vintage",
				{ LowGain = -8, MidGain = 3, HighGain = -12 }
			},
			{
				"oldradio",
				"Old Radio",
				{ LowGain = -30, MidGain = 5, HighGain = -25 }
			},
			{
				"muted",
				"Muted",
				{ LowGain = 0, MidGain = -8, HighGain = -30 }
			}
		}
	},
	{
		key = "echo",
		name = "Echo / Delay",
		class = "EchoSoundEffect",
		prio = 5,
		params = {
			{ "Delay", "Delay", 0.01, 1, 0.01, "s" },
			{ "Feedback", "Feedback", 0, 0.9, 0.05, "" },
			{ "WetLevel", "Wet", -60, 0, 1, "dB" }
		},
		presets = {
			{
				"replies",
				"Replies",
				{ Delay = 0.12, Feedback = 0.2, WetLevel = -10, DryLevel = 0 }
			},
			{
				"fast",
				"Fast",
				{ Delay = 0.08, Feedback = 0.15, WetLevel = -12, DryLevel = 0 }
			},
			{
				"moderate",
				"Moderate",
				{ Delay = 0.35, Feedback = 0.25, WetLevel = -10, DryLevel = 0 }
			},
			{
				"delayed",
				"Delayed",
				{ Delay = 0.3, Feedback = 0.35, WetLevel = -8, DryLevel = 0 }
			},
			{
				"slow",
				"Slow",
				{ Delay = 0.6, Feedback = 0.35, WetLevel = -8, DryLevel = 0 }
			},
			{
				"accel",
				"Accelerated",
				{ Delay = 0.05, Feedback = 0.55, WetLevel = -12, DryLevel = 0 }
			},
			{
				"canyon",
				"Canyon",
				{ Delay = 0.9, Feedback = 0.45, WetLevel = -6, DryLevel = 0 }
			}
		}
	},
	{
		key = "tremolo",
		name = "Tremolo",
		class = "TremoloSoundEffect",
		prio = 6,
		params = {
			{ "Frequency", "Speed", 0.1, 20, 0.1, "Hz" },
			{ "Depth", "Depth", 0, 1, 0.05, "" },
			{ "Duty", "Duty", 0, 1, 0.05, "" }
		},
		presets = {
			{
				"pulse",
				"Pulse",
				{ Frequency = 6, Depth = 1, Duty = 0.5 }
			},
			{
				"ballad",
				"Ballad",
				{ Frequency = 3, Depth = 0.4, Duty = 0.5 }
			},
			{
				"rotslow",
				"Rotary Slow",
				{ Frequency = 1.2, Depth = 0.35, Duty = 0.6 }
			},
			{
				"rotfast",
				"Rotary Fast",
				{ Frequency = 7, Depth = 0.5, Duty = 0.6 }
			},
			{
				"shiver",
				"Shiver",
				{ Frequency = 14, Depth = 0.8, Duty = 0.3 }
			}
		}
	},
	{
		key = "chorus",
		name = "Chorus",
		class = "ChorusSoundEffect",
		prio = 8,
		params = {
			{ "Rate", "Rate", 0, 20, 0.1, "Hz" },
			{ "Depth", "Depth", 0, 1, 0.05, "" },
			{ "Mix", "Mix", 0, 1, 0.05, "" }
		},
		presets = {
			{
				"chorus1",
				"Chorus I",
				{ Rate = 0.5, Depth = 0.15, Mix = 0.5 }
			},
			{
				"chorus2",
				"Chorus II",
				{ Rate = 1.2, Depth = 0.3, Mix = 0.5 }
			},
			{
				"wide",
				"Wide",
				{ Rate = 0.8, Depth = 0.5, Mix = 0.6 }
			},
			{
				"slow",
				"Slow",
				{ Rate = 0.2, Depth = 0.2, Mix = 0.5 }
			},
			{
				"vibro",
				"Vibro",
				{ Rate = 5, Depth = 0.45, Mix = 0.8 }
			}
		}
	},
	{
		key = "flange",
		name = "Flange",
		class = "FlangeSoundEffect",
		prio = 7,
		params = {
			{ "Rate", "Rate", 0, 20, 0.05, "Hz" },
			{ "Depth", "Depth", 0, 1, 0.05, "" },
			{ "Mix", "Mix", 0, 1, 0.05, "" }
		},
		presets = {
			{
				"light",
				"Light",
				{ Rate = 0.3, Depth = 0.3, Mix = 0.35 }
			},
			{
				"heavy",
				"Heavy",
				{ Rate = 0.5, Depth = 0.7, Mix = 0.6 }
			},
			{
				"oldrecord",
				"Old Record",
				{ Rate = 0.1, Depth = 0.45, Mix = 0.5 }
			},
			{
				"tape",
				"Vintage Tape",
				{ Rate = 1.5, Depth = 0.2, Mix = 0.4 }
			},
			{
				"jet",
				"Jet",
				{ Rate = 0.15, Depth = 0.9, Mix = 0.7 }
			}
		}
	}
}

Sfx.byKey = {}

for _, v in Sfx.KINDS do
	v.byPreset = {}

	for _, preset in v.presets do
		v.byPreset[preset[1]] = preset
	end

	Sfx.byKey[v.key] = v
end

Sfx.PITCH = { min = -12, max = 12, step = 0.25 }
Sfx.DEFAULT = {}

function Sfx.props(p, p2: string)
	local v = Sfx.byKey[p2]
	local v2 = p and p[p2]

	if not v or type(v2) ~= "string" then
		return nil
	end

	if v2 == "custom" then
		local clone = table.clone(v.presets[1][3])
		local v3 = p.custom and p.custom[p2]

		if type(v3) ~= "table" then
			return clone
		end

		for _, param in v.params do
			local v4 = tonumber(v3[param[1]])

			if v4 then
				clone[param[1]] = math.clamp(v4, param[3], param[4])
			end
		end

		return clone
	else
		local v3 = v.byPreset[v2]
		return if v3 then v3[3] else nil
	end
end

function Sfx.anyOn(p): boolean
	if type(p) ~= "table" then
		return false
	end

	for _, v in Sfx.KINDS do
		if Sfx.props(p, v.key) then
			return true
		end
	end

	return (tonumber(p.pitch) or 0) ~= 0
end

function Sfx.clean(p)
	local result = { custom = {} }

	if type(p) ~= "table" then
		return result
	end

	for _, v in Sfx.KINDS do
		local v2 = p[v.key]

		if v2 == "custom" or type(v2) == "string" and v.byPreset[v2] then
			result[v.key] = v2
		end

		local v3

		if type(p.custom) == "table" then
			v3 = p.custom[v.key]
		else
			v3 = false
		end

		if type(v3) ~= "table" then
			continue
		end

		local v4 = {}

		for _, param in v.params do
			local v5 = tonumber(v3[param[1]])

			if v5 then
				v4[param[1]] = math.clamp(v5, param[3], param[4])
			end
		end

		if next(v4) then
			result.custom[v.key] = v4
		end
	end

	local pitch = tonumber(p.pitch)

	if pitch then
		result.pitch = math.clamp(
			math.floor(pitch / Sfx.PITCH.step + 0.5) * Sfx.PITCH.step,
			Sfx.PITCH.min,
			Sfx.PITCH.max
		)
	end

	return result
end

return Sfx