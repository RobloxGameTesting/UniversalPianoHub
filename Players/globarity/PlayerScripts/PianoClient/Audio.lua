local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vp = ReplicatedStorage:WaitForChild("VP")
local Instruments = require(vp:WaitForChild("Instruments"))
local Sfx = require(vp:WaitForChild("Sfx"))

local pianoGroup = Instance.new("SoundGroup")
pianoGroup.Name = "PianoGroup"
pianoGroup.Volume = 0.8
pianoGroup.Parent = SoundService
local othersGroup = Instance.new("SoundGroup")
othersGroup.Name = "OthersGroup"
othersGroup.Volume = 0.8
othersGroup.Parent = SoundService

local compressorSoundEffect = Instance.new("CompressorSoundEffect")
compressorSoundEffect.Threshold = -14
compressorSoundEffect.Ratio = 4
compressorSoundEffect.Attack = 0.003
compressorSoundEffect.Release = 0.15
compressorSoundEffect.Priority = 1
compressorSoundEffect.Parent = pianoGroup
local clone_2 = compressorSoundEffect:Clone()
clone_2.Parent = othersGroup

local instruments = {}
local Audio = {}

local v = {}
local pitchShiftSoundEffect = nil

for _, instrument in Instruments do
	instruments[instrument.key] = instrument
end

Audio.list = Instruments
Audio.byKey = instruments

local v2 = {}
local v3 = {}
local total = 0
local templateSet = {}
local v4 = {}

local v5 = {}

for i = 0, 29 do
	local v6 = i * 3 + 21
	v2[i] = v6 < 45 and 10 or v6 < 69 and 7 or 5
	v3[i] = total
	total += v2[i]
end

local function isHQ(p): boolean -- 2 equivalent calls inferred from this helper
	return p.hq ~= nil and (p.hq[1] or 0) > 0 and (p.hq[2] or 0) > 0
end

local function newTemplate(p: string, soundId: string) -- 3 equivalent calls inferred from this helper
	local sound = Instance.new("Sound")
	sound.Name = "tpl_" .. p
	sound.SoundId = soundId
	sound.SoundGroup = pianoGroup
	sound.Volume = 0
	sound.Parent = SoundService

	task.spawn(function()
		for i = 1, 2 do
			local v6 = false
			pcall(function()
				ContentProvider:PreloadAsync({ sound }, function(_, p2)
					if p2 == Enum.AssetFetchStatus.Failure then
						v6 = true
					end
				end)
			end)

			if v6 and not sound.IsLoaded and sound.Parent then
				if i == 1 then
					task.wait(3)
				end
			else
				return
			end
		end

		if not sound.IsLoaded then
			templateSet[sound] = true
		end
	end)
	return sound
end

function Audio.hasAny(): boolean
	for _, instrument in Instruments do
		if instrument.id ~= "" then
			return true
		end
	end

	return false
end

function Audio.load(p: string): boolean
	local v6 = instruments[p]

	if not v6 or v6.id == "" then
		return false
	end

	if v4[p] then
		return true
	end

	if isHQ(v6) then -- inferred equivalent call
		local v7 = p .. ":2"
		v4[v7] = newTemplate(p .. "_2", "rbxassetid://" .. v6.hq[2]) -- inferred equivalent call
		v4[p] = newTemplate(p, "rbxassetid://" .. v6.hq[1]) -- inferred equivalent call
	else
		v4[p] = newTemplate(p, v6.id) -- inferred equivalent call
	end

	return true
end

function Audio.loading(p: string)
	local v6 = v4[p]
	local v7 = v4[p .. ":2"]
	local v8 = v6 ~= nil and not v6.IsLoaded

	if not v8 then
		if v7 == nil then
			return false
		end

		return not v7.IsLoaded
	end

	return v8
end

function Audio.pending()
	local set = {}
	local v6 = {}
	local v7 = {}

	for k, v8 in v4 do
		local v9 = string.gsub(k, ":2$", "")

		if set[v9] or v8.IsLoaded then
			continue
		end

		set[v9] = true
		local v10 = instruments[v9]
		local v11 = if templateSet[v8] then v6 else v7

		if v10 then
			v9 = v10.name
		end

		table.insert(v11, v9)
	end

	table.sort(v7)
	table.sort(v6)
	return v7, v6
end

function Audio.kill(p: string, p2: number?)
	local v6 = v5[p]

	if not v6 then
		return
	end

	v5[p] = nil
	local v7 = math.max(p2 or v6.rel, 0.03)
	local snd = v6.snd
	TweenService:Create(snd, TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Volume = 0
	}):Play()
	task.delay(v7 + 0.05, function()
		snd:Destroy()
	end)
end

function Audio.on(name: string, midi: number, p: string, value: number?, p2: number?): boolean
	local v6 = instruments[p] or Instruments[1]

	if not (v4[v6.key] or Audio.load(v6.key)) then
		return false
	end

	local v7 = v4[v6.key]

	if v5[name] then
		Audio.kill(name, 0.3)
	end

	local hq = isHQ(v6) -- inferred equivalent call
	local clone

	if hq then
		local v8 = p2 or (value or 0.9) * 105
		local v9 = #v6.vel + 1

		for k, v10 in v6.vel do
			if v8 <= v10 then
				v9 = k
				break
			end
		end

		if not (v9 <= 2) then
			v7 = v4[v6.key .. ":2"]
		end

		local v10 = math.clamp(math.floor((midi - 21) / 3 + 0.5), 0, 29)
		local v11 = (v9 % 2 ~= 0 and 0 or total) + v3[v10]
		clone = v7:Clone()
		clone.PlaybackRegionsEnabled = true
		clone.PlaybackRegion = NumberRange.new(v11, v11 + v2[v10] - 0.03)
		clone.PlaybackSpeed = 2 ^ ((midi - (v10 * 3 + 21)) / 12)
	else
		local v8 = math.clamp(math.floor((midi - 36) / 3 + 0.5), 0, 20)
		clone = v7:Clone()
		clone.PlaybackRegionsEnabled = true
		local off = v6.off or 0
		clone.PlaybackRegion = NumberRange.new(off + v8 * v6.slot, off + v8 * v6.slot + v6.slot - 0.03)
		clone.PlaybackSpeed = 2 ^ ((midi - (v8 * 3 + 36)) / 12)
	end

	clone.Name = name
	local soundGroup

	if string.sub(name, 1, 1) == "R" then
		soundGroup = othersGroup
	else
		soundGroup = pianoGroup
	end

	clone.SoundGroup = soundGroup
	clone.Volume = v6.gain * (value or 0.9)
	clone.Parent = SoundService
	clone:Play()
	local now = os.clock()
	local v8 = {
		snd = clone,
		rel = v6.rel,
		key = name,
		t0 = now,
		v0 = clone.Volume,
		midi = midi,
		own = clone.SoundGroup == pianoGroup
	}
	v5[name] = v8
	clone.Ended:Once(function()
		if v5[v8.key] == v8 then
			v5[v8.key] = nil
		end

		clone:Destroy()
	end)
	local v9 = 0

	for _ in v5 do
		v9 += 1
	end

	while v9 > 48 do
		local v10 = 1e999
		local v11 = nil

		for k, v12 in v5 do
			if v12 == v8 then
				continue
			end

			local v13 = math.clamp(108 - v12.midi, 0, 88) / 88 * 5 + 2.5
			local v14 = v12.v0 * math.exp(-(now - v12.t0) / v13) * (v12.own and 1.6 or 1)

			if not (v14 < v10) then
				continue
			end

			v11 = k
			v10 = v14
		end

		if not v11 then
			break
		end

		Audio.kill(v11, 0.08)
		v9 -= 1
	end

	return true
end

function Audio.isOn(p: string): boolean
	return v5[p] ~= nil
end

function Audio.killFamily(p: string, p2: number?)
	local v6 = p .. "#"

	for k in v5 do
		if k == p or string.sub(k, 1, #v6) == v6 then
			Audio.kill(k, p2)
		end
	end
end

function Audio.killWhere(callback, p: number?)
	for k in v5 do
		if callback(k) then
			Audio.kill(k, p)
		end
	end
end

function Audio.setVolume(volume: number)
	pianoGroup.Volume = volume
	othersGroup.Volume = volume
end

function Audio.setEffects(p)
	for _, v6 in Sfx.KINDS do
		local props = Sfx.props(p, v6.key)
		local v7 = v[v6.key]

		if props then
			if not v7 then
				v7 = Instance.new(v6.class)
				v7.Priority = v6.prio
				v7.Parent = pianoGroup
				v[v6.key] = v7
			end

			for k, v8 in props do
				local v9 = k
				local v10 = v8
				pcall(function()
					v7[v9] = v10
				end)
			end

			v7.Enabled = true
		elseif v7 then
			v7.Enabled = false
		end
	end

	local pitch = tonumber(p and p.pitch) or 0

	if pitch == 0 then
		if pitchShiftSoundEffect then
			pitchShiftSoundEffect.Enabled = false
		end
	else
		if not pitchShiftSoundEffect then
			pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
			pitchShiftSoundEffect.Priority = 9
			pitchShiftSoundEffect.Parent = pianoGroup
		end

		pitchShiftSoundEffect.Octave = math.clamp(2 ^ (pitch / 12), 0.5, 2)
		pitchShiftSoundEffect.Enabled = true
	end
end
Audio.setEffects(Sfx.DEFAULT)

function Audio.loudness()
	local total2 = 0

	for _, v6 in v5 do
		total2 += v6.snd.PlaybackLoudness * v6.snd.Volume
	end

	return total2
end

return Audio