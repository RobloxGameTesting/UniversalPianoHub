local function c(p: string, value: number?) -- 252 equivalent calls inferred from this helper
	return {
		c = Color3.fromHex(p),
		a = value or 1
	}
end

local v = {
	bg = c("0a0b0e"), -- inferred equivalent call
	panel = c("111318"), -- inferred equivalent call
	panel2 = c("171a20"), -- inferred equivalent call
	line = c("23272f"), -- inferred equivalent call
	ink = c("e8eaed"), -- inferred equivalent call
	muted = c("8b939d"), -- inferred equivalent call
	dim = c("5d646d"), -- inferred equivalent call
	brass = c("d8a646"), -- inferred equivalent call
	brassInk = c("e9bd62"), -- inferred equivalent call
	brassSoft = c("d8a646", 0.16), -- inferred equivalent call
	ok = c("56c488"), -- inferred equivalent call
	bad = c("f2705a"), -- inferred equivalent call
	badSoft = c("f2705a", 0.18), -- inferred equivalent call
	glass = c("101217", 0.74), -- inferred equivalent call
	glassLine = c("ffffff", 0.08), -- inferred equivalent call
	stage = c("060709"), -- inferred equivalent call
	stage2 = c("0e1014"), -- inferred equivalent call
	cap = c("1f232a"), -- inferred equivalent call
	capEdge = c("363c46"), -- inferred equivalent call
	wk = c("ebe9e3"), -- inferred equivalent call
	wkEdge = c("8a9097"), -- inferred equivalent call
	wkInk = c("2a2e33"), -- inferred equivalent call
	wkSub = c("7b828b"), -- inferred equivalent call
	wkDown = c("c7c4bb"), -- inferred equivalent call
	bk = c("08090b"), -- inferred equivalent call
	bkTop = c("2c3036"), -- inferred equivalent call
	bkInk = c("d8dbdf"), -- inferred equivalent call
	bkDown = c("3f454e"), -- inferred equivalent call
	hl = c("efcd7c"), -- inferred equivalent call
	hlBk = c("c48d1f"), -- inferred equivalent call
	okk = c("a6dcbc"), -- inferred equivalent call
	badk = c("f2a698"), -- inferred equivalent call
	white05 = c("ffffff", 0.05), -- inferred equivalent call
	white06 = c("ffffff", 0.06), -- inferred equivalent call
	white07 = c("ffffff", 0.07), -- inferred equivalent call
	white08 = c("ffffff", 0.08), -- inferred equivalent call
	black20 = c("000000", 0.2), -- inferred equivalent call
	pianoTop = c("2a2017"), -- inferred equivalent call
	midDot = c("946512"), -- inferred equivalent call
	dark111 = c("111111"), -- inferred equivalent call
	dark222 = c("222222"), -- inferred equivalent call
	qnTarget = c("3a3020"), -- inferred equivalent call
	tagMe = c("b48cff", 0.18), -- inferred equivalent call
	tagMeInk = c("c9b2ff"), -- inferred equivalent call
	brass50 = c("d8a646", 0.5), -- inferred equivalent call
	brass55 = c("d8a646", 0.55), -- inferred equivalent call
	hoverLine = c("353a44"), -- inferred equivalent call
	btnHoverLine = c("3a404b"), -- inferred equivalent call
	overlay = c("030406", 0.6), -- inferred equivalent call
	bkOk = c("2a7d4d"), -- inferred equivalent call
	bkBad = c("c23a26"), -- inferred equivalent call
	bkTargetEnd = c("8a6012"), -- inferred equivalent call
	ctlBg = c("3b3b3b"), -- inferred equivalent call
	ctlEdge = c("858585"), -- inferred equivalent call
	ctlTick = c("3b3b3b"), -- inferred equivalent call
	ctlRing = c("767676"), -- inferred equivalent call
	light = false
}

local function over(p, items) -- 7 equivalent calls inferred from this helper
	local clone = table.clone(p)

	for k, item in items do
		clone[k] = item
	end

	return clone
end

local light = over(v, { -- inferred equivalent call
	bg = c("eceef1"), -- inferred equivalent call
	panel = c("ffffff"), -- inferred equivalent call
	panel2 = c("f3f4f6"), -- inferred equivalent call
	line = c("d8dce1"), -- inferred equivalent call
	ink = c("16191d"), -- inferred equivalent call
	muted = c("5b646e"), -- inferred equivalent call
	dim = c("8a929b"), -- inferred equivalent call
	brass = c("a87414"), -- inferred equivalent call
	brassInk = c("875c0b"), -- inferred equivalent call
	brassSoft = c("a87414", 0.14), -- inferred equivalent call
	ok = c("2a8a55"), -- inferred equivalent call
	bad = c("c9412c"), -- inferred equivalent call
	badSoft = c("c9412c", 0.12), -- inferred equivalent call
	glass = c("ffffff", 0.8), -- inferred equivalent call
	glassLine = c("000000", 0.09), -- inferred equivalent call
	stage = c("f8f9fb"), -- inferred equivalent call
	stage2 = c("e6e9ee"), -- inferred equivalent call
	cap = c("ffffff"), -- inferred equivalent call
	capEdge = c("c9cfd6"), -- inferred equivalent call
	ctlBg = c("ffffff"), -- inferred equivalent call
	ctlEdge = c("767676"), -- inferred equivalent call
	ctlTick = c("ffffff"), -- inferred equivalent call
	ctlRing = c("767676"), -- inferred equivalent call
	ctlTrack = c("efefef"), -- inferred equivalent call
	ctlTrackEdge = c("b2b2b2"), -- inferred equivalent call
	light = true
})

v.ctlTrack = c("3b3b3b") -- inferred equivalent call
v.ctlTrackEdge = c("858585") -- inferred equivalent call

local function skin(data, items)
	local accent = data.accent
	local result = over(v, { -- inferred equivalent call
		bg = c(data.bg), -- inferred equivalent call
		panel = c(data.panel), -- inferred equivalent call
		panel2 = c(data.panel2), -- inferred equivalent call
		line = c(data.line), -- inferred equivalent call
		muted = c(data.muted), -- inferred equivalent call
		dim = c(data.dim), -- inferred equivalent call
		brass = c(accent), -- inferred equivalent call
		brassInk = c(data.accentInk), -- inferred equivalent call
		brassSoft = c(accent, 0.16), -- inferred equivalent call
		brass50 = c(accent, 0.5), -- inferred equivalent call
		brass55 = c(accent, 0.55), -- inferred equivalent call
		glass = c(data.panel, 0.76), -- inferred equivalent call
		stage = c(data.stage), -- inferred equivalent call
		stage2 = c(data.stage2), -- inferred equivalent call
		cap = c(data.cap), -- inferred equivalent call
		capEdge = c(data.capEdge), -- inferred equivalent call
		hl = c(data.hl), -- inferred equivalent call
		hlBk = c(data.hlBk), -- inferred equivalent call
		midDot = c(data.hlBk), -- inferred equivalent call
		bkTargetEnd = c(data.hlBk), -- inferred equivalent call
		pianoTop = c(data.capEdge), -- inferred equivalent call
		hoverLine = c(data.capEdge), -- inferred equivalent call
		btnHoverLine = c(data.capEdge) -- inferred equivalent call
	})

	if items then
		for k, item in items do
			result[k] = item
		end
	end

	return result
end

local midnight = over(v, { -- inferred equivalent call
	bg = c("080d18"), -- inferred equivalent call
	panel = c("0e1524"), -- inferred equivalent call
	panel2 = c("142036"), -- inferred equivalent call
	line = c("1f2c46"), -- inferred equivalent call
	muted = c("8e9bb3"), -- inferred equivalent call
	dim = c("5a6a88"), -- inferred equivalent call
	brass = c("6ea8ff"), -- inferred equivalent call
	brassInk = c("9cc3ff"), -- inferred equivalent call
	brassSoft = c("6ea8ff", 0.16), -- inferred equivalent call
	glass = c("0c1220", 0.76), -- inferred equivalent call
	stage = c("050a14"), -- inferred equivalent call
	stage2 = c("0b1426"), -- inferred equivalent call
	cap = c("16213a"), -- inferred equivalent call
	capEdge = c("2a3a5c"), -- inferred equivalent call
	hl = c("a9cbff"), -- inferred equivalent call
	hlBk = c("3d7bd9") -- inferred equivalent call
})

local sakura = over(v, { -- inferred equivalent call
	bg = c("130a0f"), -- inferred equivalent call
	panel = c("1a0f15"), -- inferred equivalent call
	panel2 = c("24151d"), -- inferred equivalent call
	line = c("3a2230"), -- inferred equivalent call
	muted = c("b59aa8"), -- inferred equivalent call
	dim = c("7d5e6d"), -- inferred equivalent call
	brass = c("ff8fb8"), -- inferred equivalent call
	brassInk = c("ffb3cf"), -- inferred equivalent call
	brassSoft = c("ff8fb8", 0.16), -- inferred equivalent call
	glass = c("1b0f15", 0.76), -- inferred equivalent call
	stage = c("0c0508"), -- inferred equivalent call
	stage2 = c("1a0c13"), -- inferred equivalent call
	cap = c("2a1820"), -- inferred equivalent call
	capEdge = c("4a2a3a"), -- inferred equivalent call
	hl = c("ffc2d8"), -- inferred equivalent call
	hlBk = c("e0608f") -- inferred equivalent call
})

local ocean = skin({
	bg = "06121a",
	panel = "0b1a24",
	panel2 = "10232f",
	line = "1a3442",
	muted = "8fb0bf",
	dim = "557887",
	accent = "3fd0c9",
	accentInk = "7ae6df",
	stage = "040c12",
	stage2 = "0a1820",
	cap = "12283a",
	capEdge = "24465a",
	hl = "a8f0ea",
	hlBk = "1f9e98"
})

local forest = skin({
	bg = "0a110b",
	panel = "0f1811",
	panel2 = "152217",
	line = "22342a",
	muted = "98ad9c",
	dim = "5e7563",
	accent = "7fcf6a",
	accentInk = "a6e394",
	stage = "060b07",
	stage2 = "0d160f",
	cap = "18261b",
	capEdge = "2d4433",
	hl = "c4ecb6",
	hlBk = "4f9e3c"
})

local ember = skin({
	bg = "120807",
	panel = "1a0d0b",
	panel2 = "241310",
	line = "3a1f1a",
	muted = "b8a09a",
	dim = "7d625b",
	accent = "ff7a45",
	accentInk = "ffa37b",
	stage = "0b0504",
	stage2 = "190b08",
	cap = "2a1612",
	capEdge = "4a2a22",
	hl = "ffbf9e",
	hlBk = "e0552a"
})

local synthwave = skin({
	bg = "0d0717",
	panel = "140b22",
	panel2 = "1c1030",
	line = "2e1b4a",
	muted = "a99bc7",
	dim = "6c5c8c",
	accent = "ff4fd8",
	accentInk = "ff8fe6",
	stage = "07040e",
	stage2 = "160a2a",
	cap = "21123a",
	capEdge = "3d2466",
	hl = "ffb3f1",
	hlBk = "c22aa8"
}, { ok = c("2fe0d0") }) -- inferred equivalent call
local royal = skin({
	bg = "0e0a14",
	panel = "15101e",
	panel2 = "1d1629",
	line = "2e2440",
	muted = "a59cb8",
	dim = "6c6382",
	accent = "f2c14e",
	accentInk = "ffd77a",
	stage = "08060c",
	stage2 = "141020",
	cap = "211a30",
	capEdge = "3a2f52",
	hl = "ffe39a",
	hlBk = "c9971f"
})

local graphite = skin({
	bg = "0b0b0b",
	panel = "131313",
	panel2 = "1a1a1a",
	line = "2a2a2a",
	muted = "9a9a9a",
	dim = "616161",
	accent = "e6e6e6",
	accentInk = "ffffff",
	stage = "060606",
	stage2 = "101010",
	cap = "1f1f1f",
	capEdge = "3a3a3a",
	hl = "efcd7c",
	hlBk = "c48d1f"
}, { midDot = c("9a9a9a"), bkTargetEnd = c("8a6012") }) -- inferred equivalent call

local vip = skin({
	bg = "0d0904",
	panel = "17110a",
	panel2 = "21180c",
	line = "4a3612",
	muted = "c4b089",
	dim = "84704a",
	accent = "ffc53d",
	accentInk = "ffd970",
	stage = "0a0703",
	stage2 = "33230a",
	cap = "2a1f0e",
	capEdge = "6b4e12",
	hl = "ffe08a",
	hlBk = "e0a01a"
}, {
	wk = c("f3e8c9"), -- inferred equivalent call
	wkEdge = c("a8873e"), -- inferred equivalent call
	wkDown = c("dcc68e"), -- inferred equivalent call
	wkSub = c("9a8558"), -- inferred equivalent call
	bkTop = c("4a3612"), -- inferred equivalent call
	bkDown = c("5a4418"), -- inferred equivalent call
	pianoTop = c("b8841f"), -- inferred equivalent call
	glassLine = c("ffc53d", 0.14) -- inferred equivalent call
})

local ice = over(light, { -- inferred equivalent call
	bg = c("e6eef5"), -- inferred equivalent call
	panel = c("ffffff"), -- inferred equivalent call
	panel2 = c("eef4f9"), -- inferred equivalent call
	line = c("cfdde8"), -- inferred equivalent call
	muted = c("557089"), -- inferred equivalent call
	dim = c("8aa2b5"), -- inferred equivalent call
	brass = c("1f7fcf"), -- inferred equivalent call
	brassInk = c("145f9e"), -- inferred equivalent call
	brassSoft = c("1f7fcf", 0.14), -- inferred equivalent call
	brass50 = c("1f7fcf", 0.5), -- inferred equivalent call
	brass55 = c("1f7fcf", 0.55), -- inferred equivalent call
	glass = c("ffffff", 0.82), -- inferred equivalent call
	stage = c("f4f8fb"), -- inferred equivalent call
	stage2 = c("dde8f1"), -- inferred equivalent call
	cap = c("ffffff"), -- inferred equivalent call
	capEdge = c("c3d3e0"), -- inferred equivalent call
	hl = c("8cc4f2"), -- inferred equivalent call
	hlBk = c("2b7fc4"), -- inferred equivalent call
	midDot = c("2b7fc4"), -- inferred equivalent call
	bkTargetEnd = c("1d5d94"), -- inferred equivalent call
	pianoTop = c("9fb6c9") -- inferred equivalent call
})

local wood = skin({
	bg = "2b1c11",
	panel = "4a3019",
	panel2 = "573a20",
	line = "6e4a2c",
	muted = "dcc6a8",
	dim = "a48a6c",
	accent = "f0b264",
	accentInk = "f8d29a",
	stage = "1d130b",
	stage2 = "2a1b10",
	cap = "5a3c22",
	capEdge = "7a5434",
	hl = "f7d9a6",
	hlBk = "c8822e"
}, {
	ink = c("f6ecdd"), -- inferred equivalent call
	wk = c("f2e7d0"), -- inferred equivalent call
	wkEdge = c("9c8462"), -- inferred equivalent call
	wkDown = c("dccbab"), -- inferred equivalent call
	wkSub = c("8f7a5c"), -- inferred equivalent call
	wkInk = c("3a2a1a"), -- inferred equivalent call
	bk = c("140d08"), -- inferred equivalent call
	bkTop = c("3a281a"), -- inferred equivalent call
	bkDown = c("4a3424"), -- inferred equivalent call
	pianoTop = c("7a1f1a"), -- inferred equivalent call
	glass = c("4a3019", 0.88), -- inferred equivalent call
	glassLine = c("f5c98a", 0.1), -- inferred equivalent call
	overlay = c("0d0805", 0.6), -- inferred equivalent call
	tex = {
		image = "rbxassetid://139322343434655",
		size = 320,
		lift = 100 / 87,
		roles = {
			bg = 1,
			panel = 1,
			glass = 1,
			cap = 1,
			stage = 0.55
		}
	}
})

local v2 = {
	dirt = "rbxassetid://76478785477613",
	stone = "rbxassetid://126069506730760",
	planks = "rbxassetid://93090733532268",
	grass = "rbxassetid://120836256523967",
	bevel = "rbxassetid://125206410384943",
	header = "rbxassetid://75375125518103",
	logo = "rbxassetid://90034320524788",
	gloss = "rbxassetid://92790004644926"
}

local v3 = {
	dirt = 500 / 373,
	stone = 100 / 77,
	planks = 1000 / 773
}
local function px(p: string, value: number?, size: number?) -- 2 equivalent calls inferred from this helper
	return {
		img = v2[p],
		lift = v3[p],
		a = value or 1,
		size = size
	}
end

local slice = { img = "rbxassetid://125206410384943", c = 12, w = 64, scale = 0.5 }
local minecraft = skin({
	bg = "3b2a1d",
	panel = "7a5434",
	panel2 = "6f6f6f",
	line = "000000",
	muted = "eae0d2",
	dim = "b8a896",
	accent = "7ccf3a",
	accentInk = "a6ef6a",
	stage = "222222",
	stage2 = "171717",
	cap = "6f6f6f",
	capEdge = "000000",
	hl = "b9f28e",
	hlBk = "4f9e2a"
}, {
	ink = c("ffffff"), -- inferred equivalent call
	square = true,
	wk = c("f0f0f0"), -- inferred equivalent call
	wkEdge = c("8a8a8a"), -- inferred equivalent call
	wkDown = c("cfcfcf"), -- inferred equivalent call
	bk = c("1e1a2b"), -- inferred equivalent call
	bkTop = c("3a3350"), -- inferred equivalent call
	bkDown = c("4a4260"), -- inferred equivalent call
	pianoTop = c("5b9e34"), -- inferred equivalent call
	glass = c("8a6a42", 0.97), -- inferred equivalent call
	glassLine = c("000000", 0.7), -- inferred equivalent call
	overlay = c("000000", 0.55), -- inferred equivalent call
	hoverLine = c("ffffff"), -- inferred equivalent call
	btnHoverLine = c("ffffff"), -- inferred equivalent call
	field = c("101010"), -- inferred equivalent call
	tex = {
		pixel = true,
		size = 32,
		roles = {
			bg = {
				img = "rbxassetid://76478785477613",
				lift = 500 / 373,
				size = 40,
				top = { img = "rbxassetid://120836256523967", size = 40 }
			},
			panel = {
				img = "rbxassetid://76478785477613",
				lift = 500 / 373,
				top = { img = "rbxassetid://120836256523967", size = 32 }
			},
			panel2 = { img = "rbxassetid://125206410384943", tint = false, slice = slice },
			cap = { img = "rbxassetid://125206410384943", tint = false, slice = slice },
			glass = px("planks"), -- inferred equivalent call
			stage = px("stone", 0.7, 48) -- inferred equivalent call
		}
	}
})

local classic = over(light, { -- inferred equivalent call
	bg = c("cdecff"), -- inferred equivalent call
	panel = c("cdecff"), -- inferred equivalent call
	panel2 = c("bfdcf1"), -- inferred equivalent call
	line = c("b3d6ee"), -- inferred equivalent call
	ink = c("393b3d"), -- inferred equivalent call
	muted = c("5b6b7a"), -- inferred equivalent call
	dim = c("8a99a8"), -- inferred equivalent call
	brass = c("0b78c5"), -- inferred equivalent call
	brassInk = c("0a6ab0"), -- inferred equivalent call
	brassSoft = c("0b78c5", 0.14), -- inferred equivalent call
	brass50 = c("0b78c5", 0.5), -- inferred equivalent call
	brass55 = c("0b78c5", 0.55), -- inferred equivalent call
	glass = c("ffffff", 0.97), -- inferred equivalent call
	glassLine = c("ffffff", 0), -- inferred equivalent call
	stage = c("ffffff"), -- inferred equivalent call
	stage2 = c("ffffff"), -- inferred equivalent call
	cap = c("ffffff"), -- inferred equivalent call
	capEdge = c("c9dced"), -- inferred equivalent call
	hl = c("9fd3f7"), -- inferred equivalent call
	hlBk = c("2b8fd6"), -- inferred equivalent call
	midDot = c("2b8fd6"), -- inferred equivalent call
	bkTargetEnd = c("1a6fae"), -- inferred equivalent call
	pianoTop = c("cdecff"), -- inferred equivalent call
	hoverLine = c("8fc1e3"), -- inferred equivalent call
	btnHoverLine = c("8fc1e3"), -- inferred equivalent call
	white05 = c("ffffff", 0), -- inferred equivalent call
	white06 = c("ffffff", 0.35), -- inferred equivalent call
	white07 = c("ffffff", 0.5), -- inferred equivalent call
	logo = "rbxassetid://90034320524788",
	tex = {
		roles = {
			bg = {
				top = { img = "rbxassetid://75375125518103", stretch = true, h = 56 }
			}
		}
	}
})

local marble = over(light, { -- inferred equivalent call
	bg = c("e6e3de"), -- inferred equivalent call
	panel = c("fbfaf8"), -- inferred equivalent call
	panel2 = c("f1eee9"), -- inferred equivalent call
	line = c("d5d0c6"), -- inferred equivalent call
	ink = c("1d1b18"), -- inferred equivalent call
	muted = c("5f5a52"), -- inferred equivalent call
	dim = c("8d877d"), -- inferred equivalent call
	brass = c("a8812a"), -- inferred equivalent call
	brassInk = c("85621a"), -- inferred equivalent call
	brassSoft = c("a8812a", 0.14), -- inferred equivalent call
	brass50 = c("a8812a", 0.5), -- inferred equivalent call
	brass55 = c("a8812a", 0.55), -- inferred equivalent call
	glass = c("fdfcfa", 0.86), -- inferred equivalent call
	stage = c("f6f4f0"), -- inferred equivalent call
	stage2 = c("e6e2da"), -- inferred equivalent call
	cap = c("ffffff"), -- inferred equivalent call
	capEdge = c("cdc6ba"), -- inferred equivalent call
	hl = c("e2bd62"), -- inferred equivalent call
	hlBk = c("b08326"), -- inferred equivalent call
	midDot = c("b08326"), -- inferred equivalent call
	bkTargetEnd = c("8a6012"), -- inferred equivalent call
	pianoTop = c("bdb3a2"), -- inferred equivalent call
	hoverLine = c("c3bcae"), -- inferred equivalent call
	btnHoverLine = c("c3bcae"), -- inferred equivalent call
	tex = {
		image = "rbxassetid://137285902403765",
		size = 384,
		lift = 1000 / 879,
		roles = {
			bg = 1,
			panel = 0.7,
			glass = 0.7,
			cap = 0.55,
			stage = 0.4
		}
	}
})

return {
	dark = v,
	light = light,
	auto = v,
	midnight = midnight,
	sakura = sakura,
	ocean = ocean,
	forest = forest,
	ember = ember,
	synthwave = synthwave,
	royal = royal,
	graphite = graphite,
	ice = ice,
	vip = vip,
	wood = wood,
	minecraft = minecraft,
	classic = classic,
	marble = marble,
	starlight = skin({
		bg = "0b1020",
		panel = "111733",
		panel2 = "182042",
		line = "283163",
		muted = "9ea6c9",
		dim = "636c93",
		accent = "a9b8ff",
		accentInk = "cbd5ff",
		stage = "070a16",
		stage2 = "0e1430",
		cap = "1a2246",
		capEdge = "303b70",
		hl = "9fb4ff",
		hlBk = "5b6fd6"
	}, {
		glass = c("10163a", 0.8), -- inferred equivalent call
		glassLine = c("a9b8ff", 0.12), -- inferred equivalent call
		overlay = c("03040b", 0.6), -- inferred equivalent call
		tex = {
			image = "rbxassetid://83877231847383",
			size = 512,
			roles = {
				bg = { tint = false },
				stage = { tint = false },
				panel = { tint = false, a = 0.55 },
				glass = { tint = false, a = 0.45 }
			}
		}
	}),
	order = {
		"dark",
		"light",
		"midnight",
		"sakura",
		"ocean",
		"forest",
		"ember",
		"synthwave",
		"royal",
		"graphite",
		"ice",
		"wood",
		"minecraft",
		"classic",
		"marble",
		"starlight",
		"vip"
	},
	vipOnly = { vip = true },
	names = {
		dark = "Dark stage",
		light = "Light",
		midnight = "Midnight",
		sakura = "Sakura",
		ocean = "Ocean",
		forest = "Forest",
		ember = "Ember",
		synthwave = "Synthwave",
		royal = "Royal",
		graphite = "Graphite",
		ice = "Ice",
		wood = "Wood",
		minecraft = "Minecraft",
		classic = "Roblox Classic",
		marble = "Marble",
		starlight = "Starlight",
		vip = "VIP Gold"
	}
}