return function(data)
	local b = data.B
	local u = data.U
	local f = data.F
	local lay = data.Lay
	local notes = data.Notes
	local comm = data.COMM
	local api = data.api
	local fx = data.FX
	local img = data.img
	local glyph = data.Glyph
	local RunService = game:GetService("RunService")

	local function hx(p: string) -- 7 equivalent calls inferred from this helper
		return Color3.fromHex(p)
	end
	local v = {
		{
			"Sunset",
			"a gradient that flows along the keys",
			{
				w = { hx("ff5f6d"), hx("ffc371") }, -- inferred equivalent call
				fw = { "along", 1 }
			}
		},
		{
			"Neon",
			"every key on its own beat, black keys apart",
			{
				w = { hx("f72585"), hx("4cc9f0") }, -- inferred equivalent call
				fw = { "each", 1.4 },
				b = { hx("b14dff"), hx("ffe14d") }, -- inferred equivalent call
				fb = { "each", 1.6 }
			}
		},
		{
			"Aurora",
			"one gradient for the white keys, another for the black",
			{
				w = { hx("43e97b"), hx("38f9d7") }, -- inferred equivalent call
				fw = { "along", 0.6 },
				b = { hx("a18cd1"), hx("fbc2eb") }, -- inferred equivalent call
				fb = { "each", 1 }
			}
		},
		{
			"Your colour",
			"or just one colour you pick",
			{
				w = { hx("ff7ad9") }
			}
		},
		{
			"VIP Gold",
			"shimmering gold, deeper on the black keys",
			{
				w = { hx("ffb800"), hx("fff4c2") }, -- inferred equivalent call
				fw = { "along", 1.7 },
				b = { hx("a8740f"), hx("ffd54a") }, -- inferred equivalent call
				fb = { "along", 1.7 }
			}
		}
	}

	local function fromSteps(parsed)
		local total = 0
		local result = {}

		for i = 1, #parsed do
			local item = parsed[i]
			total += (item.wait or 0) * 0.14
			local keys = {}

			for _, key in item.keys do
				local v2 = notes.NOTE[key]

				if v2 then
					table.insert(keys, v2)
				end
			end

			if #keys > 0 then
				table.insert(result, { t = total, keys = keys })
			end
		end

		for k, v2 in result do
			local v3 = result[k + 1]
			v2.len = math.clamp(not v3 and 0.14 or v3.t - v2.t, 0.06, 0.35)
		end

		return result, total + 1
	end

	local function opening()
		local total = 0
		local result = {}

		for _, v2 in {
			{ 49, 56, 61, 64 },
			{ 49, 56, 61, 64 },
			{ 45, 52, 57, 61 },
			{ 44, 51, 56, 60 }
		} do
			for i = 0, 3 do
				for j = 0, 3 do
					local v3 = i + j
					table.insert(result, {
						t = total,
						keys = { v2[v3 % 4 + 1] + v3 // 4 * 12 },
						len = 0.08
					})
					total += 0.07
				end
			end

			for _ = 1, 2 do
				table.insert(result, {
					t = total,
					keys = {
						v2[2] + 12,
						v2[3] + 12,
						v2[4] + 12,
						v2[1] + 24
					},
					len = 0.12
				})
				total += 0.14
			end

			total += 0.14
		end

		return result, total + 0.5
	end

	local v2 = nil
	local v3 = 0
	local v4 = false
	local function fetchSheet()
		if not v2 then
			local success, result, v5 = pcall(function()
				return fromSteps(notes.parse("//Transposition: -8\n6 0 [0e] t [6u] e [0t] u [6p] t [0u] p [6s] u [0p] s\n[6f] p [0s] f [6j] s [0f] j [6l] f [0j] l [6efjlx] [0fjlx]\n% 0 [0W] r [%u] W [0r] u [%O] r [0u] O [%a] u [0O] a\n[%f] O [0a] f [%H] a [0f] H [%k] f [0H] k [%WHfkx] [H0fkx]\n5 e [0T] u [5p] T [0u] p [5S] u [0p] S [5f] p [0S] f\n[5j] S [0f] j [5L] f [0j] L [5x] j [0L] x [L5wjxb] [L0jxb]\n4 e [qy] i [4p] p [qd] g [4j] j [qz] c [4jzb] [qjzb]\n4 e [qt] i [4p] p [qs] D [4j] j [ql] Z [Z4jb] [Zqjb]\n[30xHV] [Ouf] x [Of] x [pG] x [aH] x [sj] x [dk] x [aH] x\n[dk] x [sj] x [gz] x [fl] x [dk] x [sj] x [aH] x [pg] Z\n[Ouf] x [Of] x [Of] x [pG] x [aH] x [sj] x [dk] x [aH] x\n[dk] x [sj] x [gz] x [fl] x [dk] x [sj] x [aH] x [pg] Z\n[Ouf] x [upg] Z [Ouf] x [upg] Z [Ouf] x [upg] Z [Ouf] x [upg] Z\n[Oufx] [30u]\n6 0 [0e] t [6u] e [0t] u [6p] t [0u] p [6s] u [0p] s\n[6f] p [0s] f [6j] s [0f] j [6l] l [0x] b [6elm] [0lm]\n$ t [eY] p [Qs] t [ep] s [QD] p [es] D [Qj] s [eD] j\n[Ql] D [ej] l [QZ] j [el] Z [Qb] l [eZ] b [$Qlm] [elm]\n@ r [rI] p [(a] I [rp] a [(G] p [ra] G [(j] a [rG] j\n[(k] G [rj] k [(C] j [rk] C [(b] C [rk] j [(C] k [rj] G\n[0h] r w r [0k] r w r 0 r w r [0h] r w [rf]\n[QD] f r G [ef] r [QD] r e r Q r [eD] r [Qk] r e [rD]\n[wG] r w r [wf] r w r w r [wf] r [wk] r w [rf]\n[(h] r ( r [(G] r ( r ( r [(G] r [(k] r ( [rG]\n[0h] r [wkn] r 0 r [wkn] r 0 r [wkn] r [0hv] r [wfx] r\n[Qfx] r [eDZ] r Q r [eDZ] r Q r [eDZ] r [Qkn] r [eDZ] r\n[wGC] r [wfx] r w r [wfx] r w r [wfx] r [wkn] r [wfx] r\n[(hv] r [(GC] r ( r [(GC] r ( r [(GC] r [(kn] r [(GC] r\n[9HV] r 0 r 9 r 0 r [8jb] e 0 e 8 e 0 e\n[8GC] e 9 e [7x] w 9 w C 7 w 9 w [7hv] w 9 w\n[^fx] w 8 w ^ w 8 w [6gc] q 8 q 6 q 8 q\n[6DZ] Q 7 Q [5L] 0 7 0 Z 5 0 7 0 [5fx] 0 7 0\n[68qegjlc] l z x c v b v\n[psgc] l z x c v b v [psgc] l z x c v b v\n[psgc] l z x [psgc] v b B [psgm] n m n [psgm] b v c\n[ax] h f h a h f h [aC] j D j a j D j\nx [68qepsgj] s d f g h j h\ng s d f [etig] h j h g s d f [etig] h j h\ng s [etid] f g h [etij] h g s [etid] f g h [etij] h\n[etig] s d f g h j J l z x c v b B n\n[elm] i t i e i t i [Efx] o T o E o T o\n[rhv] o u o r o u o [7pYD] r E r E r E r\n[0uof] [uah] [uah] [uah] [uah] [uah] [aIG] [oaf]\n[rpaD] [Dpak] [Dpak] [Dpak] [Dpak] [Dpak] [oafk] [IGak]\n[0uhk] [uah] [uah] [uah] [uah] [uah] [aIG] [oaf]\n[rpaD] [Dpak] [Dpak] [Dpak] [Dpak] [Dpak] [oafk] [IGak]\n[0hk] [uohk] [uohk] [oafh] e [upjl] [upjl] [psfj]\nr [uohk] [uohk] [oafh] r [YIGk] [YIGk] [aIDG]\n[30fh] [0rhkv] [0rhkv] [0rhkv] [0rhkv] [0rhkv] [rjQGC] [wrfhx]\n[7erDGZ] [Zrplm] [Zrplm] [Zrplm] [Zrplm] [Zrplm] [Zrokn] [IZrjb]\n[30hkv] [0rhkv] [0rhkv] [0rhkv] [0rhkv] [0rhkv] [rjQGC] [wrfhx]\n[7erDGZ] [Zrplm] [Zrplm] [Zrplm] [Zrplm] [Zrplm] [Zrokn] [IZrjb]\n[0uhxv] [oaxv] [oaxv] [uovn] e [psxb] [psxb] [upbm]\nr [oaxv] [oaxv] [uovn] e [aIZC] [aIZC] [YICn]\nw [afkv] [afkv] [oaxn] e [sgjc] [sgjc] [pslb]\nr [afhx] [afhx] [oakv] r [pDGZ] [pDGZ] [pjIC]\n[0hx] u r u 0 u r u 0 u r u [0h] u r [uf]\n[0D] I r I [D0pk] I r I [D0pk] I r I [D0pk] I r I\n[0o] u r u f 0 u r u [0k] u r u [0v] u r [ux]\n[0Z] I r I [Z0jn] I r I [Z0jn] I r I [Z0jn] I r I\n[0h] u [rx] u [0n] u r u [0j] I [rZ] I [0n] I r I\n[0h] u [rx] u [0n] u r u [0j] I [rZ] I [0n] I r I\n[0o] [uf] [ra] [uf] [0o] [uf] [ra] [uf] [0o] [uf] [ra] [uf] [0o] [uf] [ra] [uf]\n[0O] [yd] [ra] [yd] [0O] [yd] [ra] [yd] [0O] [yd] [ra] [yd] [0O] [yd] [ra] [yd]\n[6tups] 0 [0e] t [6u] e [0t] u [6p] t [0u] p [6s] u [0p] s\n[6f] p [0s] f [6j] s [0f] j [6l] f [0j] l [6efjlx] [0fjlx]\n% 0 [0W] r [%u] W [0r] u [%O] r [0u] O [%a] u [0O] a\n[%f] O [0a] f [%H] a [0f] H [%k] f [0H] k [%WHfkx] [H0fkx]\n5 e [0T] u [5p] T [0u] p [5S] u [0p] S [5f] p [0S] f\n[5j] S [0f] j [5L] f [0j] L [5x] j [0L] x [L5wjxb] [L0jxb]\n4 e [qy] i [4p] p [qd] g [4j] j [qz] c [4jzb] [qjzb]\n4 e [qt] i [4p] p [qs] D [4j] j [ql] Z [Z4jb] [Zqjb]\n[30xHV] [Ouf] x [Of] x [pG] x [aH] x [sj] x [dk] x [aH] x\n[dk] x [sj] x [gz] x [fl] x [dk] x [sj] x [aH] x [pg] Z\n[Ouf] x [Of] x [Of] x [pG] x [aH] x [sj] x [dk] x [aH] x\n[dk] x [sj] x [gz] x [fl] x [dk] x [sj] x [aH] x [pg] Z\n[Ouf] x [upg] Z [Ouf] x [upg] Z [Ouf] x [upg] Z [Ouf] x [upg] Z\n[Oufx] [30u]\n6 0 [0e] t [6u] e [0t] u [6p] t [0u] p [6s] u [0p] s\n[6f] p [0s] f [6j] s [0f] j [6l] l [0x] b [6elm] [0lm]\n$ t [eY] p [Qs] t [ep] s [QD] p [es] D [Qj] s [eD] j\n[Ql] D [ej] l [QZ] j [el] Z [Qb] l [eZ] b [$Qlm] [elm]\n@ r [rI] p [(a] I [rp] a [(G] p [ra] G [(j] a [rG] j\n[(k] G [rj] k [(C] j [rk] C [(b] C [rk] j [(C] k [rj] G\n[0h] r w r [0k] r w r 0 r w r [0h] r w [rf]\n[QD] f r G [ef] r [QD] r e r Q r [eD] r [Qk] r e [rD]\n[wG] r w r [wf] r w r w r [wf] r [wk] r w [rf]\n[(h] r ( r [(G] r ( r ( r [(G] r [(k] r ( [rG]\n[0h] r [wkn] r 0 r [wkn] r 0 r [wkn] r [0hv] r [wfx] r\n[Qfx] r [eDZ] r Q r [eDZ] r Q r [eDZ] r [Qkn] r [eDZ] r\n[wGC] r [wfx] r w r [wfx] r w r [wfx] r [wkn] r [wfx] r\n[(hv] r [(GC] r ( r [(GC] r ( r [(GC] r [(kn] r [(GC] r\n[9HV] r 0 r 9 r 0 r [8jb] e 0 e 8 e 0 e\n[8GC] e 9 e [7x] w 9 w C 7 w 9 w [7hv] w 9 w\n[^fx] w 8 w ^ w 8 w [6gc] q 8 q 6 q 8 q\n[6DZ] Q 7 Q [5L] 0 7 0 Z 5 0 7 0 [5fx] 0 7 0\n[68qegjlc] l z x c v b v\n[psgc] l z x c v b v [psgc] l z x c v b v\n[psgc] l z x [psgc] v b B [psgm] n m n [psgm] b v c\n[ax] h f h a h f h [aC] j D j a j D j\nx [68qepsgj] s d f g h j h\ng s d f [etig] h j h g s d f [etig] h j h\ng s [etid] f g h [etij] h g s [etid] f g h [etij] h\n[etig] s d f g h j J l z x c v b B n\n[elm] i t i e i t i [Efx] o T o E o T o\n[rhv] o u o r o u o [7pYD] r E r E r E r\n[0uof] [uah] [uah] [uah] [uah] [uah] [aIG] [oaf]\n[rpaD] [Dpak] [Dpak] [Dpak] [Dpak] [Dpak] [oafk] [IGak]\n[0uhk] [uah] [uah] [uah] [uah] [uah] [aIG] [oaf]\n[rpaD] [Dpak] [Dpak] [Dpak] [Dpak] [Dpak] [oafk] [IGak]\n[0hk] [uohk] [uohk] [oafh] e [upjl] [upjl] [psfj]\nr [uohk] [uohk] [oafh] r [YIGk] [YIGk] [aIDG]\n[30fh] [0rhkv] [0rhkv] [0rhkv] [0rhkv] [0rhkv] [rjQGC] [wrfhx]\n[7erDGZ] [Zrplm] [Zrplm] [Zrplm] [Zrplm] [Zrplm] [Zrokn] [IZrjb]\n[30hkv] [0rhkv] [0rhkv] [0rhkv] [0rhkv] [0rhkv] [rjQGC] [wrfhx]\n[7erDGZ] [Zrplm] [Zrplm] [Zrplm] [Zrplm] [Zrplm] [Zrokn] [IZrjb]\n[0uhxv] [oaxv] [oaxv] [uovn] e [psxb] [psxb] [upbm]\nr [oaxv] [oaxv] [uovn] e [aIZC] [aIZC] [YICn]\nw [afkv] [afkv] [oaxn] e [sgjc] [sgjc] [pslb]\nr [afhx] [afhx] [oakv] r [pDGZ] [pDGZ] [pjIC]\n[0hx] u r u 0 u r u 0 u r u [0h] u r [uf]\n[0D] I r I [D0pk] I r I [D0pk] I r I [D0pk] I r I\n[0o] u r u f 0 u r u [0k] u r u [0v] u r [ux]\n[0Z] I r I [Z0jn] I r I [Z0jn] I r I [Z0jn] I r I\n[0h] u [rx] u [0n] u r u [0j] I [rZ] I [0n] I r I\n[0h] u [rx] u [0n] u r u [0j] I [rZ] I [0n] I r I\n[0o] [uf] [ra] [uf] [0o] [uf] [ra] [uf] [0o] [uf] [ra] [uf] [0o] [uf] [ra] [uf]\n[0O] [yd] [ra] [yd] [0O] [yd] [ra] [yd] [0O] [yd] [ra] [yd] [0O] [yd] [ra] [yd]\n[6upTS] e [0T] u [6p] T [0u] p [6S] u [0p] S [6f] p [0S] f\n[6j] S [0f] j [6L] f [0j] L [6x] j [0L] x [L6ejxb] [L0jxb]\n5 e [0T] u [5p] T [0u] p [5S] u [0p] S [5f] p [0S] f\n[5j] S [0f] j [5L] f [0j] L [5x] j [0L] x [L5wjxb] [L0jxb]\n4 e [qy] i [4p] p [qd] g [4j] j [qz] c [4jzb] [qjzb]\n! e [*u] o [!p] p [*f] h [!j] j [*x] v [!jxvb] [*jxvb]\n[29jzcb] p i p [yj] p i p y p i p [yg] p i [pd]\n[ud] p o p [uS] p o p u p [oS] p [uj] p o [pS]\n[if] p i p [id] p i p i p [id] p [ij] p i [pd]\n[Tg] p T p [Tf] p T p T p [Tf] p [Tj] p T [pf]\n[yg] j g j [pd] j g j d j g j [id] j g [yj]\n[yf] j h j [Tf] j h j f j [Th] j [pf] j h [Tj]\n[ud] j g j [yd] j g j d j [yg] j [pd] j g [yj]\n[yd] J [yg] J [Pd] J g [yJ] [yg] J [yH] J [Pg] J H [yJ]\n[YD] J h J [ED] J h J D J h J [wD] J h [(J]\n[(g] J H J [9g] J H J g J [9H] J [Eg] J H [9J]\n[qD] J h J [(D] J h J D J [(h] J [Ed] J h [9J]\n[9f] J h J [*f] j h j f j [*h] j [ef] j h [*j]\n[9d] j [9g] j [qd] j [9g] j [^d] z [^j] z [9d] z [^j] z\n[%d] z [fk] z d z [fk] z d z [%fk] z [7d] z [%fk] z\n[6s] l [6j] l [8s] l [6j] l [4s] l [4j] l [6s] l [4j] l\n[2a] k [2j] k [4a] k [2j] k [@a] k [@j] k [$a] k [@j] k\n[H3ak] 0 3 0 [3f] 0 3 0 3 0 3 0 [3g] 0 [3f] 0\n[3ipd] 0 3 0 [3f] 0 [3d] 0 [3uos] 0 3 0 [3d] 0 [3s] 0\n[3yia] 0 3 0 [3s] 0 [3a] 0 [3tup] 0 3 0 [3a] 0 [3p] 0\n[3ryO] 0 3 0 3 0 3 0 [3etp] 0 3 0 3 0 3 0\n[3W] [0u] [3a] 0 [3x] 0 3 0 3 0 [3x] 0 [3c] 0 [3x] 0\n[3z] 0 [3gjz] 0 [3hkx] 0 [3gjz] 0 [3fhl] 0 [3fhl] 0 [3gjz] 0 [3fhl] 0\n[3dgk] 0 [3dgk] 0 [3fhl] 0 [3dgk] 0 [3sfj] 0 [3sfj] 0 [3dgk] 0 [3sfj] 0\n[3adH] 0 3 0 3 0 3 0 [3psj] 0 3 0 3 0 3 0\n[3O] 0 3 0 d 3 0 3 0 [3k] 0 3 0 [3psj] 0 3 0\n[3adH] 0 3 0 [3adH] 0 3 0 [3psj] 0 3 0 [3psj] 0 3 0\n[3O] 0 3 0 d 3 0 3 0 [3k] 0 3 0 [3ps] 0 [3j] 0\n[3ad] 0 [3H] 0 [3ad] 0 [3H] 0 [3ps] 0 [3j] 0 [3ps] 0 [3j] 0\n[O3d] 0 [3k] 0 [O3d] 0 [3k] 0 [4ps] q [4j] q [4ps] q [4j] q\n[29ipag]\n[O30uaf]\n6 0 [0e] t [6u] e [0t] u [6p] t [0u] p [6s] u [0p] s\n[6f] p [0s] f [6j] s [0f] j [6l] f [0j] l [6efjlx] [0fjlx]\n% 0 [0W] r [%u] W [0r] u [%O] r [0u] O [%a] u [0O] a\n[%f] O [0a] f [%H] a [0f] H [%k] f [0H] k [%WHfkx] [H0fkx]\n5 e [0T] u [5p] T [0u] p [5S] u [0p] S [5f] p [0S] f\n[5j] S [0f] j [5L] f [0j] L [5x] j [0L] x [L5wjxb] [L0jxb]\n4 e [qy] i [4p] p [qd] g [4j] j [qz] c [4jzb] [qjzb]\n4 e [qt] i [4p] p [qs] D [4j] j [ql] Z [Z4jb] [Zqjb]\n[30xHV] [Ouf] x [Of] x [pG] x [aH] x [sj] x [dk] x [aH] x\n[dk] x [sj] x [gz] x [fl] x [dk] x [sj] x [aH] x [pg] Z\n[Ouf] x [Of] x [Of] x [pG] x [aH] x [sj] x [dk] x [aH] x\n[dk] x [sj] x [gz] x [fl] x [dk] x [sj] x [aH] x [pg] Z\n[Ouf] x [upg] Z [Ouf] x [upg] Z [Ouf] x [upg] Z [Ouf] x [upg] Z\n[Oufx] [30u]\ne u t u [ef] u t u e u t u [es] u t [up]\n[rO] p u a [yp] u [rO] u y u r u [yO] u [rf] u y [uO]\n[ta] u t u [tp] u t u t u [tp] u [tf] u t [up]\n[Ws] u W u [Wa] u W u W u [Wa] u [Wf] u W [ua]\n[es] u [tfx] u e u [tfx] u e u [tfx] u [esl] u [tpj] u\n[rpj] u [yOH] u r u [yOH] u r u [yOH] u [rfx] u [yOH] u\n[tak] u [tpj] u t u [tpj] u t u [tpj] u [tfx] u [tpj] u\n[Wsl] u [Wak] u W u [Wak] u W u [Wak] u [Wfx] u [Wak] u\n[wSL] u e u w u e u [qdz] y e y q y e y\n[qak] y w y [0j] t w t k 0 t w t [0sl] t w t\n[(pj] t q t ( t q t [9PJ] E q E 9 E q E\n[9OH] r 0 r [8G] e 0 e H 8 e 0 e [8pj] e 0 e\n[9qydgEPJ] g h j J l z l\n[Pyik] g h j J l z l [yiPJ] g h j J l z l\n[yiPJ] g h j [yiPJ] l z Z [Pyic] x v c [Pyix] z l J\n[uj] s p s u s p s [uk] d O d u d O d\n[ipsj] [249yi^EP] i o p P s d s\nP i o p [9qEP] s d s P i o p [9qEP] s d s\nP i [E9qo] p P s [E9qd] D g h [E9qj] J l z [9qEZ] x\n[9gc] E q E 9 E q E [(pj] t Q t ( t Q t\n[0sl] t e t 0 t e t [3yWO] 0 ( 0 ( 0 ( 0\n[6etp] [eus] [eus] [eus] [eus] [eus] [rua] [tup]\n[0yuO] [Oyuf] [Oyuf] [Oyuf] [Oyuf] [Oyuf] [tupf] [ruaf]\n[6esf] [eus] [eus] [eus] [eus] [eus] [rua] [tup]\n[0yuO] [Oyuf] [Oyuf] [Oyuf] [Oyuf] [Oyuf] [tupf] [ruaf]\n[6esf] [etsf] [etsf] [tups] 9 [eydg] [eydg] [yipd]\n0 [etsf] [etsf] [tups] 0 [Wraf] [Wraf] [Orua]\n[eps] [eusfl] [eusfl] [eusfl] [eusfl] [eusfl] [ruadk] [tupsj]\n[0yuaOH] [udkHV] [udkHV] [udkHV] [udkHV] [udkHV] [usjlb] [uakzn]\n[6elxm] [eusfl] [eusfl] [eusfl] [eusfl] [eusfl] [ruadk] [tupsj]\n[0yuaOH] [udkHV] [udkHV] [udkHV] [udkHV] [udkHV] [usjlb] [uakzn]\n[6elxm] [psxb] [psxb] [sflx] y [pdcb] [pdcb] [dgzc]\nu [pslx] [pslx] [sfjl] y [Oakx] [Oakx] [Hafk]\nt [upjx] [upjx] [psfl] 9 [yigz] [yigz] [ydPJ]\n0 [tufl] [tufl] [upsj] 0 [rydk] [rydk] [yaOH]\n[6sj] e 0 e 6 e 0 e 6 e 0 e [6s] e 0 [ep]\n[6O] r 0 r [O6yf] r 0 r [O6yf] r 0 r [O6yf] r 0 r\n[6t] e 0 e p 6 e 0 e [6f] e 0 e [6l] e 0 [ej]\n[6H] r 0 r [H6dx] r 0 r [H6dx] r 0 r [H6dx] r 0 r\n[6s] e [0j] e [6x] e 0 e [6d] r [0H] r [6x] r 0 r\n[6s] e [0j] e [6x] e 0 e [6d] r [0H] r [6x] r 0 r\n[6t] [ep] [0u] [ep] [6t] [ep] [0u] [ep] [6t] [ep] [0u] [ep] [6t] [ep] [0u] [ep]\n[5eT] [wp] [6u] [wp] [5eT] [wp] [6u] [wp] [5eT] [wp] [6u] [wp] [5eT] [wp] [6u] [wp]\n[4qeyip] e [9y] i [4p] y [9i] p [4d] i [9p] d [4g] p [9d] g\n[4j] d [9g] j [4z] g [9j] z [4c] j [9z] c [4qjzcb] [9jzcb]\n3 e [8t] u [3p] t [8u] p [3s] u [8p] s [3f] p [8s] f\n[3j] s [8f] j [3l] f [8j] l [3x] j [8l] x [30jlxb] [8jlxb]\n@ e t Y I p @ $ 6 8 ( p s D G j ( Q e t\nY j l Z C [YIpsb]\n2 q W r y i 2 4 % 7 * i O a d g 9 q W r\ny g H k [Oyiac]\ne f s f [up] f s f p f s f [tp] f s [ef]\n[ea] f d f [Wa] f d f a f [Wd] f [ua] f d [Wf]\n[rp] f s f [ep] f s f p f [es] f [up] f s [ef]\n[tO] f d f [rO] f d f O f [rd] f [uO] f d [rf]\n[tpsf] u t u [tfx] u t u t u t u [tsl] u t [upj]\n[ypj] u y u [yOH] u y u y u [yOH] u [yfx] u y [uOH]\n[tak] u t u [tpj] u t u t u [tpj] u [tfx] u t [upj]\n[Wsl] u W u [Wak] u W u W u [Wak] u [Wfx] u W [uak]\n[edz] u [esl] u [ejb] u [esl] u [wdz] e [wSL] e [wjb] e [wSL] e\n[qfx] e [qdz] e [qjb] e [qdz] e [*gc] e [*fx] e [*jb] e [*fx] e\n[269c] z j g d p g d p i y e\ni y e q e y i p d g j z c z j g\n[^29c] z J g d P g d P i y E\ni y E q E y i P d g J z c z J g\n[@(6b] C Z l j G l j G D s p I\ns p I Y t e t Y I p s D G j l Z C b C Z\n[360m] b x l j f l j f s j f s\np f s p u s p u t p u t e u t e\n0 q Q w W e E r t T y Y u i I o\nO p P a s S d D f g G h H j J k l L z Z x\n[Oudc]\n[@(]\n[30]\n[6e] e 0 e 6 e 0 e 6 e 0 e [6s] e 0 [ep]\n[6O] r 0 r [O6yf] r 0 r [O6yf] r 0 r [O6yf] r 0 r\n[6t] e 0 e p 6 e 0 e [6f] e 0 e [6l] e 0 [ej]\n[6H] r 0 r [H6dx] r 0 r [H6dx] r 0 r [H6dx] r 0 r\n[6s] e [0j] e [6x] e 0 e [6d] r [0H] r [6x] r 0 r\n[6s] e [0j] e [6x] e 0 e [6d] r [0H] r [6x] r 0 r\n[60es] j x [es] [uf] [pj] [sl] [uf] [pj] [sl] [fx] [pj] [sl] [fx] [jb] [sl] [fx] [jb]\n[lm] [jb] [fx] [sl] [jb] [fx] [sl] [pj] [fx] [sl] [pj] [uf] [sl] [pj] [uf] [ts]\n[pj] [uf] [ts] [ep] [uf] [ts] [ep] [0u] [ts] [ep] [0u] [8t] [ep] [0u] [8t] [0u]\n[6e] [680ejlxb]\n[680epsfj]"))
			end)

			if success and type(result) == "table" and #result > 20 then
				v2 = result
				v3 = v5
			end
		end

		if v2 or v4 then
			return
		end

		v4 = true
		task.spawn(function()
			local v5 = -1
			local v6 = nil

			for _, v7 in comm.index do
				local title = string.lower((tostring(v7.title)))

				if not string.find(title, "moonlight", 1, true) then
					continue
				end

				if not (string.find(title, "3", 1, true) or string.find(title, "third", 1, true)) then
					continue
				end

				local v8 = comm.stars[v7.id] or 0

				if not (v5 < v8) then
					continue
				end

				v6 = v7
				v5 = v8
			end

			if v6 then
				local v7 = comm.texts[v6.id] or api("communitySheet", v6.id)

				if type(v7) == "string" then
					comm.texts[v6.id] = v7
					local v8, v9 = fromSteps(notes.parse(v7))

					if #v8 > 20 then
						v2 = v8
						v3 = v9
					end
				end
			end

			v4 = false
		end)
	end

	function f.vipDemo(parent)
		fetchSheet()
		local v5 = b({
			h = 134,
			r = 10,
			bg = "stage",
			bd = 1,
			bdc = "line",
			clip = true,
			parent = parent
		})
		local inst = v5.inst
		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 1)
		frame.ClipsDescendants = true
		frame.ZIndex = 66
		frame.Parent = inst
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Position = UDim2.fromOffset(10, 6)
		textLabel.Size = UDim2.new(1, -20, 0, 16)
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.FontFace = glyph.nativeFont("s500_12_8")
		textLabel.TextSize = glyph.nativeSize("s500_12_8")
		textLabel.ZIndex = 70
		textLabel.Parent = frame

		local v6 = {}
		local v7 = 0
		local function buildKeys(lw: number)
			v7 = lw

			for _, v8 in v6 do
				v8.f:Destroy()
			end

			table.clear(v6)
			local v8 = lw / 36

			local th = lay.TH
			local count = 0

			for i = notes.LOW, notes.LOW + 60 do
				local black = notes.isBlack(i)
				local frame2 = Instance.new("Frame")
				frame2.BorderSizePixel = 0
				local v9 = { f = frame2, black = black }

				if black then
					local v10 = count * v8
					local v11 = v8 * 0.62
					v9.x = v10
					v9.w = v11
					frame2.Position = UDim2.fromOffset(math.floor(v9.x - v9.w / 2 + 0.5), 112)
					frame2.Size = UDim2.fromOffset(math.max(2, (math.floor(v9.w + 0.5))), 13)
					frame2.ZIndex = 69
					v9.base = th.bk.c
				else
					v9.x = (count + 0.5) * v8
					v9.w = v8
					frame2.Position = UDim2.fromOffset(math.floor(count * v8 + 0.5), 112)
					frame2.Size = UDim2.fromOffset(math.max(1, math.floor(v8 + 0.5) - 1), 22)
					frame2.ZIndex = 68
					v9.base = th.wk.c
					count += 1
				end

				frame2.BackgroundColor3 = v9.base
				frame2.Parent = frame
				v6[i] = v9
			end
		end

		local v8 = {}
		local bars = {}
		local v9 = {}
		local function getBar()
			local bar = table.remove(v8)

			if not bar then
				local glow = img("glow", {
					ZIndex = 66,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(fx.glow.slice[1], fx.glow.slice[2], fx.glow.slice[3], fx.glow.slice[4])
				})
				local frame2 = Instance.new("Frame")
				frame2.BorderSizePixel = 0
				frame2.ZIndex = 67
				local uiCorner = Instance.new("UICorner", frame2)
				uiCorner.CornerRadius = UDim.new(1, 0)
				bar = { glow = glow, fill = frame2 }
			end

			bar.glow.Parent = frame
			bar.fill.Parent = frame
			return bar
		end

		local function dropBar(i: number) -- 2 equivalent calls inferred from this helper
			local v10 = table.remove(bars, i)
			v10.glow.Parent = nil
			v10.fill.Parent = nil
			table.insert(v8, v10)
		end

		local v10 = 1
		local v11 = os.clock()
		local function setCaption() -- 2 equivalent calls inferred from this helper
			local v12 = v[v10]
			textLabel.Text = v12[1] .. "  ·  " .. v12[2]
		end

		setCaption() -- inferred equivalent call
		local v12, v13

		if v2 then
			v12 = v2
			v13 = v3
		else
			v12, v13 = opening()
		end

		local v14 = os.clock()
		local v15 = 1

		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if not inst.Parent then
				renderSteppedConnection:Disconnect()
				return
			end

			local lw = v5.lw or 0

			if lw <= 40 or not inst.Visible then
				return
			end

			if math.abs(lw - v7) > 1 then
				buildKeys(lw)

				for i = #bars, 1, -1 do
					dropBar(i) -- inferred equivalent call
				end
			end

			textLabel.TextColor3 = lay.TH.muted.c
			local now = os.clock()

			if now - v11 > 4.5 then
				v10 = v10 % #v + 1
				v11 = now
				setCaption() -- inferred equivalent call
			end

			local v16 = v[v10][3]
			local v17 = math.max(1, u.stage._pw or 1000)

			local v18 = now - v14

			if v2 and v12 ~= v2 and v18 < 1.5 then
				v12 = v2
				v13 = v3
				v18 = 0
				v14 = now
				v15 = 1
			end

			if v15 > #v12 and v13 < v18 then
				if v2 then
					v12 = v2
					v13 = v3
				end

				v18 = 0
				v14 = now
				v15 = 1
			end

			local count = 0

			while v12[v15] and v12[v15].t <= v18 and count < 12 do
				local v19 = v12[v15]
				v15 += 1

				for _, key in v19.keys do
					local v20 = v6[key]

					if not v20 then
						continue
					end

					count += 1
					local bar = getBar()
					local x = v20.x
					local black = v20.black
					local t1 = now + v19.len
					bar.x = x
					bar.black = black
					bar.t0 = now
					bar.t1 = t1
					bar.w = math.clamp(v20.w * (v20.black and 0.8 or 0.5), 3, 12)
					local styleGlow = f.styleGlow(v16, v20.black)
					bar.gm = fx.glow.margin * 0.55 * math.max(1, styleGlow)
					bar.glow.ImageTransparency = 1 - math.min(1, styleGlow)
					table.insert(bars, bar)
					v20.until_ = now + 0.12
					v9[v20] = true
				end
			end

			for i = #bars, 1, -1 do
				local v19 = bars[i]
				local v20 = 112 - (now - v19.t0) * 95
				local v21 = now < v19.t1 and 112 or 112 - (now - v19.t1) * 95

				if v21 < -6 then
					dropBar(i) -- inferred equivalent call
				else
					local v22 = v21 - v20

					if v22 < v19.w then
						v20 = v21 - v19.w
						v22 = v19.w
					end

					local styleColor = f.styleColor(v16, v19.x / lw * v17, v19.black)
					v19.fill.BackgroundColor3 = styleColor
					v19.fill.Position = UDim2.fromOffset(v19.x - v19.w / 2, v20)
					v19.fill.Size = UDim2.fromOffset(v19.w, v22)
					local v23 = v19.w + 2 * v19.gm
					v19.glow.ImageColor3 = styleColor
					v19.glow.SliceScale = math.min(1, v23 / fx.glow.w)
					v19.glow.Position = UDim2.fromOffset(v19.x - v23 / 2, v20 - v19.gm)
					v19.glow.Size = UDim2.fromOffset(v23, v22 + 2 * v19.gm)
				end
			end

			for k in v9 do
				if now < k.until_ then
					k.f.BackgroundColor3 = k.base:Lerp(f.styleColor(v16, k.x / lw * v17, k.black), 0.7)
				else
					k.f.BackgroundColor3 = k.base
					v9[k] = nil
				end
			end
		end)
		inst.Destroying:Connect(function()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end
		end)
		return v5
	end
end