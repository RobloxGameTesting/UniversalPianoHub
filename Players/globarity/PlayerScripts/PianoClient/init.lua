-- Script Path: game:GetService("Players").globarity.PlayerScripts.PianoClient
-- Took 0.41s to decompile.
-- Executor: Real (3.2.2)

-- Script path: game:GetService("Players").globarity.PlayerScripts.PianoClient
-- Decompile time: 414.08 ms

local __real_registers = {}
local autoTick, setTheme, v6
local Players = game:GetService("Players")
__real_registers[7] = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
__real_registers[8] = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local VP = __real_registers[7]:WaitForChild("VP")
local u1578 = require(VP:WaitForChild("Notes"))
local Sheets = require(VP:WaitForChild("Sheets"))
local Themes = require(VP:WaitForChild("Themes"))
local Levels = require(VP:WaitForChild("Levels"))
local Glyph = require(script:WaitForChild("Glyph"))
local Lay = require(script:WaitForChild("Lay"))
local Audio = require(script:WaitForChild("Audio"))
__real_registers[9] = VP:WaitForChild("Remotes")
local Note = __real_registers[9]:WaitForChild("Note")
local Pedal = __real_registers[9]:WaitForChild("Pedal")
local Run = __real_registers[9]:WaitForChild("Run")
__real_registers[10] = __real_registers[9]:WaitForChild("Notice")
__real_registers[11] = __real_registers[9]:WaitForChild("Sheets")
__real_registers[12] = __real_registers[9]:WaitForChild("Donation")
local Api = __real_registers[9]:WaitForChild("Api")
local box = Lay.box
local text = Lay.text
local NOTE = u1578.NOTE
local fx = Glyph.fx
local u1642 = {}
local u1603 = {}

task.spawn(function() -- Line: 35; upvalues: StarterGui (val)
    for i = 1, 20 do
        if pcall(function() -- Line: 37; upvalues: StarterGui (upval)
            for i, j in {
                Enum.CoreGuiType.PlayerList,
                Enum.CoreGuiType.Backpack,
                Enum.CoreGuiType.Health,
                Enum.CoreGuiType.EmotesMenu,
            } do
                StarterGui:SetCoreGuiEnabled(j, false)
            end
        end) then
            break
        end

        task.wait(0.5)
    end
end)

do
    __real_registers[13] = workspace.CurrentCamera

    if __real_registers[13] then
        __real_registers[13].CameraType = Enum.CameraType.Scriptable
        __real_registers[13].CFrame = CFrame.new(0, 2000, 0)
    end
end

local function api(a1, a2) -- Line: 49; upvalues: Api (val); types: a1: string
    local success, err, v1 = pcall(function() -- Line: 50; upvalues: Api (upval), a1 (val), a2 (val)
        return Api:InvokeServer(a1, a2)
    end)

    if not success then
        return nil, "No connection to the server."
    end

    return err, v1
end

local u1805 = {
    mode = "practice",
    text = "",
    title = "",
    idx = 1,
    mistakes = 0,
    elapsed = 0,
    finished = false,
    playing = false,
    gen = 0,
    bpm = 120,
    loop = false,
    flow = false,
    activeId = "",
    allowAuto = true,
    goodKeys = 0,
    steps = {},
    got = {},
    res = {},
    times = {},
}
local u1684 = {
    instr = "grand",
    transpose = 0,
    volume = 0.8,
    velocity = 100,
    reverb = true,
    pedalDefault = true,
    spaceDown = false,
    sustain = true,
    held = {},
    pendingOff = {},
    heldKey = {},
}
local u1631 = {
    view = "piano",
    names = false,
    theme = "graphite",
    fullscreen = false,
    collapsed = false,
    hudMin = false,
    profileReady = false,
    kb = 88,
    donChat = true,
    hist = {},
}
local u3682 = {}
local u3696 = nil
local u3710 = {
    at = 0,
    index = {},
    stars = {},
    texts = {},
    ratings = {},
    myRates = {},
}
local u3724 = {}

local function isAdmin() -- Line: 73; upvalues: LocalPlayer (val)
    return LocalPlayer:GetAttribute("Admin") == true
end

local u2003 = {}

local function pianoVol(a1) -- Line: 76; upvalues: u2003 (ref); types: a1: number
    local v1 = u2003[tostring(a1)]

    if v1 and v1.p then
        return v1.p
    end

    return 1
end

local function voiceVol(a1) -- Line: 77; upvalues: u2003 (ref); types: a1: number
    local v1 = u2003[tostring(a1)]

    if v1 and v1.v then
        return v1.v
    end

    return 1
end

local u1941 = {}

Lay.setTheme(Themes.graphite)

local function v15(a1) -- Line: 83; types: a1: number
    return a1 * 1.45
end

local function hoverText(a1, a2, a3, a4) -- Line: 85
    a1.inst.MouseEnter:Connect(function() -- Line: 86; upvalues: a2 (val), a4 (val)
        a2.c = a4
        a2:paint()
    end)

    a1.inst.MouseLeave:Connect(function() -- Line: 87; upvalues: a2 (val), a3 (val)
        a2.c = a3
        a2:paint()
    end)
end

local function v16(a1) -- Line: 91; upvalues: text (val), box (val), hoverText (val); types: a1: string
    local v1 = text({f = "s400_13_6", lh = 19.72, c = "muted", t = a1})
    local v2 = box({
        dir = "row",
        align = "center",
        justify = "center",
        h = 30,
        minW = 30,
        pad = {0, 9},
        bd = 1,
        bdc = "line",
        bg = "panel",
        r = 8,
        button = true,
        hov = {bdc = "hoverLine"},
        {v1},
    })

    v2:bindHover()
    hoverText(v2, v1, "muted", "ink")

    v2.label = v1

    return v2
end

local function btn(a1, a2) -- Line: 102; upvalues: text (val), box (val); types: a1: string, a2: string?
    local v1 = text({
        f = "s500_13_6",
        lh = 19.72,
        t = a1,
        c = if a2 ~= "primary" then if a2 ~= "danger" then "ink" else "bad" else "bg",
    })
    local v2 = box({
        dir = "row",
        align = "center",
        justify = "center",
        pad = {6, 12},
        bd = 1,
        bdc = if a2 ~= "primary" then "line" else "ink",
        bg = if a2 ~= "primary" then "panel2" else "ink",
        r = 8,
        button = true,
        hov = if a2 == "primary" then nil else {bdc = "btnHoverLine"},
        sty = {arm = {bdc = "bad", bg = "badSoft"}},
        {v1},
    })

    if a2 ~= "primary" then
        v2:bindHover()
    end

    v2.label = v1

    return v2
end

local function v17(a1, a2) -- Line: 113; upvalues: text (val), box (val); types: a1: string, a2: number?
    local v1 = text({f = "m600_13_6", t = a1})
    local v2 = box({
        dir = "row",
        align = "center",
        justify = "center",
        w = a2 or 22,
        h = a2 or 22,
        bd = 1,
        bdc = "glassLine",
        bg = "white05",
        r = 6,
        button = true,
        {v1},
    })
    v2.label = v1

    return v2
end

local function v18(a1, a2) -- Line: 122; upvalues: text (val), box (val); types: a1: string, a2: boolean?
    local v1 = text({f = "s500_12_48", lh = 18.096, t = a1, c = if not a2 then "ink" else "bg"})
    local v2 = box({
        dir = "row",
        align = "center",
        justify = "center",
        pad = {4, 9},
        bd = 1,
        bdc = "glassLine",
        bg = if not a2 then "white05" else "ink",
        r = 7,
        button = true,
        sty = {on = {bg = "brassSoft", bdc = "brass55"}},
        {v1},
    })
    v2.label = v1
    v2.primary = a2

    return v2
end

local function setPressed(a1, a2) -- Line: 130; types: a2: boolean
    a1:state("on", a2)

    a1.label.c = if not a2 then if not a1.primary then "ink" else "bg" else "brassInk"
    a1.label:paint()
end

local function eyebrow(a1, a2) -- Line: 137; upvalues: text (val); types: a1: string, a2: table?
    local v1 = {
        f = "m500_10_24",
        up = true,
        ls = 1.024,
        c = "muted",
        t = a1,
    }

    if a2 then
        for i, j in a2 do
            v1[i] = j
        end
    end

    return text(v1)
end

local function piCap(a1) -- Line: 142; upvalues: text (val); types: a1: string
    return text({
        f = "m600_8_96",
        up = true,
        ls = 0.896,
        c = "muted",
        t = a1,
    })
end

local function note(a1, a2) -- Line: 145; upvalues: text (val); types: a1: string, a2: table?
    local v1 = {
        f = "s400_12_8",
        lh = 18.56,
        c = "muted",
        wrap = true,
        t = a1,
    }

    if a2 then
        for i, j in a2 do
            v1[i] = j
        end
    end

    return text(v1)
end

local function img(a1, a2) -- Line: 152; upvalues: fx (val), Glyph (val); types: a1: string, a2: table
    local v1 = fx[a1]
    local ImageLabel = Instance.new("ImageLabel")
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.Image = Glyph.image
    ImageLabel.ImageRectOffset = Vector2.new(v1.x, v1.y)
    ImageLabel.ImageRectSize = Vector2.new(v1.w, v1.h)
    ImageLabel.Size = UDim2.fromOffset(v1.w, v1.h)

    for i, j in a2 do
        ImageLabel[i] = j
    end

    return ImageLabel
end

local function radio(a1) -- Line: 164; upvalues: box (val), Lay (val); types: a1: boolean
    local v1 = box({
        w = 13,
        h = 13,
        r = "pill",
        inheritPaint = true,
        m = {3, 3, 0, 5},
    })
    local Frame = Instance.new("Frame")
    Frame.BorderSizePixel = 0
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.fromScale(0.5, 0.5)
    Frame.Size = UDim2.fromOffset(7, 7)
    Frame.ZIndex = 3
    local v2 = Instance.new("UICorner", Frame)
    v2.CornerRadius = UDim.new(1, 0)
    Frame.Parent = v1.inst

    function v1.onPaint(a1) -- Line: 174; upvalues: Lay (upval), Frame (val)
        local TH = Lay.TH
        local c = TH.brass.c
        local c_2 = TH.ctlBg.c
        a1.inst.BackgroundTransparency = 0

        if not a1.on then
            a1.inst.BackgroundColor3 = c_2
            Frame.Visible = false
            local gap_2 = a1.inst:FindFirstChild("gap")

            if gap_2 then
                gap_2.Visible = false
            end

            local ring_2 = a1.inst:FindFirstChild("ring") or Instance.new("UIStroke")
            ring_2.Name = "ring"
            ring_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ring_2.BorderStrokePosition = Enum.BorderStrokePosition.Inner
            ring_2.Thickness = 1
            ring_2.Color = TH.ctlRing.c
            ring_2.Parent = a1.inst

            return
        end

        a1.inst.BackgroundColor3 = c
        Frame.Visible = true
        Frame.BackgroundColor3 = c
        local ring = a1.inst:FindFirstChild("ring") or Instance.new("UIStroke")
        ring.Name = "ring"
        local gap = a1.inst:FindFirstChild("gap") or Instance.new("Frame")
        gap.Name = "gap"
        gap.BorderSizePixel = 0
        gap.AnchorPoint = Vector2.new(0.5, 0.5)
        gap.Position = UDim2.fromScale(0.5, 0.5)
        gap.Size = UDim2.fromOffset(10, 10)
        gap.BackgroundColor3 = c_2
        gap.ZIndex = 2

        if not gap:FindFirstChildOfClass("UICorner") then
            local v1 = Instance.new("UICorner", gap)
            v1.CornerRadius = UDim.new(1, 0)
        end

        gap.Parent = a1.inst
        gap.Visible = true
        ring.Parent = nil
    end

    v1.on = a1

    v1:paint()

    return v1
end

local function checkbox(a1) -- Line: 217; upvalues: box (val), img (val), Lay (val); types: a1: boolean
    local v1 = box({w = 16, h = 16, r = 2, m = {3, 3, 3, 4}})
    local u16 = img(
        "tick",
        {ZIndex = 3, Size = UDim2.fromOffset(16, 16)}
    )
    u16.Parent = v1.inst

    function v1.onPaint(a1) -- Line: 221; upvalues: Lay (upval), u16 (val)
        local TH = Lay.TH
        a1.inst.BackgroundTransparency = 0
        local edge = a1.inst:FindFirstChild("edge") or Instance.new("UIStroke")
        edge.Name = "edge"
        edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        edge.BorderStrokePosition = Enum.BorderStrokePosition.Inner
        edge.Thickness = 1

        if a1.on then
            a1.inst.BackgroundColor3 = TH.brass.c
            u16.Visible = true
            u16.ImageColor3 = TH.ctlTick.c
            edge.Parent = nil

            return
        end

        a1.inst.BackgroundColor3 = TH.ctlBg.c
        u16.Visible = false
        edge.Color = TH.ctlEdge.c
        edge.Parent = a1.inst
    end

    v1.on = a1

    v1:paint()

    return v1
end

local function range(a1, a2, a3, a4, a5, a6)
    -- Line: 250
    -- upvalues: box (val), VP (val), img (val), fx (val), Lay (val), u1603 (val), UserInputService (val)
    -- types: a1: number, a2: number, a3: number, a4: number, a5: function, a6: number?
    local u6 = a6 or 90
    local u9 = box({h = 16, m = 2, button = true, w = u6})
    local Icons = require(VP:WaitForChild("Icons"))
    local u25 = false

    if type(Icons.slider) == "string" then
        u25 = false

        if Icons.slider ~= "" then
            u25 = Icons.slider ~= "rbxassetid://0"
        end
    end

    local u28 = if not u25 then 4 else 5
    local u31 = if not u25 then 8 else 6
    local Frame = Instance.new("Frame")
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.fromOffset(0, u28)
    Frame.Size = UDim2.new(1, 0, 0, u31)
    local v1 = Instance.new("UICorner", Frame)
    v1.CornerRadius = UDim.new(0, 4)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
    UIStroke.Thickness = 1
    UIStroke.Parent = Frame
    Frame.Parent = u9.inst
    local u72 = nil

    if u25 then
        u72 = Instance.new("UIGradient")
        u72.Rotation = 90
        u72.Parent = Frame
    end

    local u99 = nil

    if u25 then
        u99 = img(
            "glow",
            {
                ZIndex = 1,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(fx.glow.slice[1], fx.glow.slice[2], fx.glow.slice[3], fx.glow.slice[4]),
            }
        )
        u99.Parent = u9.inst
    end

    local Frame_2 = Instance.new("Frame")
    Frame_2.BorderSizePixel = 0
    Frame_2.Position = UDim2.fromOffset(0, u28)
    Frame_2.ZIndex = 2
    local v2 = Instance.new("UICorner", Frame_2)
    v2.CornerRadius = UDim.new(0, 4)
    local u126 = nil

    if u25 then
        u126 = Instance.new("UIGradient")
        u126.Parent = Frame_2
    end

    Frame_2.Parent = u9.inst
    local Frame_3 = Instance.new("Frame")
    Frame_3.BorderSizePixel = 0
    Frame_3.ZIndex = 3
    local u136 = nil
    local u137 = nil
    local u138 = 16

    if not u25 then
        Frame_3.Size = UDim2.fromOffset(16, 16)
        local v3 = Instance.new("UICorner", Frame_3)
        v3.CornerRadius = UDim.new(1, 0)
    else
        u138 = 11
        local v4 = 16
        Frame_3.BackgroundTransparency = 1
        Frame_3.Size = UDim2.fromOffset(u138, v4)
        local u148 = u138 / 56
        local u149 = v4 / 80

        local function layer(a1, a2, a3, a4, a5)
            -- Line: 302
            -- upvalues: Icons (val), u148 (val), u149 (val), Frame_3 (val)
            -- types: a1: number, a2: number, a3: number, a4: number, a5: number
            local ImageLabel = Instance.new("ImageLabel")
            ImageLabel.BackgroundTransparency = 1
            ImageLabel.Image = Icons.slider
            ImageLabel.ImageRectOffset = Vector2.new(a1, a2)
            ImageLabel.ImageRectSize = Vector2.new(a3, a4)
            ImageLabel.Size = UDim2.fromOffset(a3 * u148, a4 * u149)
            ImageLabel.ZIndex = a5
            ImageLabel.Parent = Frame_3

            return ImageLabel
        end

        local v5 = layer(128, 0, 104, 128, 3)
        v5.Position = UDim2.fromOffset(u148 * -24, u149 * -24)
        u136 = layer(0, 0, 56, 80, 4)

        layer(64, 0, 56, 80, 5)

        u137 = Instance.new("UIScale")
        u137.Parent = Frame_3
    end

    Frame_3.Parent = u9.inst
    u9.value = a4

    local function render()
        -- Line: 325
        -- upvalues: u9 (val), a1 (val), a2 (val), u6 (val), Frame_3 (val), u138 (ref), Frame_2 (val), u31 (val)
        -- upvalues: u99 (ref), fx (upval), u28 (val)
        local v1 = 8 + (math.clamp((u9.value - a1) / (a2 - a1), 0, 1)) * (u6 - 16)
        Frame_3.Position = UDim2.fromOffset(math.floor(v1 - u138 / 2 + 0.5), 0)
        Frame_2.Size = UDim2.fromOffset(math.floor(v1 + 0.5), u31)

        if u99 then
            local v2 = math.floor(fx.glow.margin * 0.4 + 0.5)
            u99.Visible = v1 > 3
            u99.SliceScale = math.min(1, (u31 + v2 * 2) / fx.glow.w)
            u99.Position = UDim2.fromOffset(-v2, u28 - v2)
            u99.Size = UDim2.fromOffset((math.floor(v1 + 0.5)) + v2 * 2, u31 + v2 * 2)
        end
    end

    local u242 = false
    local u243 = nil

    local function lift() -- Line: 340; upvalues: u137 (ref), u242 (ref), u243 (ref), u99 (ref)
        if not u137 then
            return
        end

        local v1 = u242 or u243 ~= nil
        local v2 = u137

        ;(game:GetService("TweenService")):Create(
            v2,
            TweenInfo.new(0.12, Enum.EasingStyle.Quad),
            {Scale = if not v1 then 1 else 1.08}
        ):Play()

        if u99 then
            u99.ImageTransparency = if not u243 then 0.86 else 0.72
        end
    end

    function u9.onPaint()
        -- Line: 346
        -- upvalues: Lay (upval), Frame (val), u25 (val), UIStroke (val), u72 (ref), u126 (ref), Frame_2 (val)
        -- upvalues: u99 (ref), u243 (ref), u136 (ref), Frame_3 (val)
        local TH = Lay.TH
        local c = TH.brass.c
        local c_2 = if not u25 then TH.ctlTrack.c else Color3.new(1, 1, 1)
        Frame.BackgroundColor3 = c_2
        UIStroke.Color = TH.ctlTrackEdge.c

        if u72 then
            u72.Color = ColorSequence.new(TH.ctlTrack.c:Lerp(Color3.new(), 0.35), TH.ctlTrack.c)
        end

        if not u126 then
            Frame_2.BackgroundColor3 = c
        else
            Frame_2.BackgroundColor3 = Color3.new(1, 1, 1)
            u126.Color = ColorSequence.new(c:Lerp(Color3.new(), 0.3), c:Lerp(Color3.new(1, 1, 1), 0.12))
        end

        if u99 then
            u99.ImageColor3 = c
            u99.ImageTransparency = if not u243 then 0.86 else 0.72
        end

        if u136 then
            u136.ImageColor3 = c
            return
        end

        Frame_3.BackgroundColor3 = c
    end

    u9:paint()
    render()

    local function setFromX(a1_2)
        -- Line: 366
        -- upvalues: u9 (val), a1 (val), a2 (val), a3 (val), render (val), a5 (val)
        -- types: a1_2: number
        local v1 = (math.floor((a1 + math.clamp((a1_2 - u9.inst.AbsolutePosition.X - 8) / math.max(1, u9.inst.AbsoluteSize.X - 16), 0, 1) * (a2 - a1)) / a3 + 0.5))
            * a3

        if v1 ~= u9.value then
            u9.value = v1
            render()
            a5(v1)
        end
    end

    local drags = u1603.drags or setmetatable(
        {},
        {__mode = "k"}
    )
    u1603.drags = drags
    u1603.drags[u9.inst] = setFromX

    u9.inst.MouseEnter:Connect(function() -- Line: 378; upvalues: u242 (ref), lift (val)
        u242 = true
        lift()
    end)

    u9.inst.MouseLeave:Connect(function() -- Line: 379; upvalues: u242 (ref), lift (val)
        u242 = false
        lift()
    end)

    u9.inst.InputBegan:Connect(function(a1) -- Line: 380; upvalues: u243 (ref), setFromX (val), lift (val)
        if a1.UserInputType == Enum.UserInputType.MouseButton1
            or a1.UserInputType == Enum.UserInputType.Touch then
            u243 = a1
            setFromX(a1.Position.X)
            lift()
        end
    end)

    UserInputService.InputChanged:Connect(function(a1) -- Line: 387; upvalues: u243 (ref), setFromX (val)
        if u243 then
            if a1.UserInputType == Enum.UserInputType.MouseMovement or a1 == u243 then
                setFromX(a1.Position.X)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(a1) -- Line: 390; upvalues: u243 (ref), lift (val)
        if u243 then
            if a1 == u243 or a1.UserInputType == Enum.UserInputType.MouseButton1 then
                u243 = nil
                lift()
            end
        end
    end)

    function u9.set(a1) -- Line: 393; upvalues: u9 (val), render (val); types: a1: number
        u9.value = a1
        render()
    end

    return u9
end

local function chevron(a1, a2) -- Line: 398; upvalues: img (val); types: a1: userdata, a2: string
    local v1 = img(
        "chev",
        {ZIndex = 3}
    )
    v1.Parent = a1

    return v1
end

__real_registers[14] = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PianoUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ScreenInsets = Enum.ScreenInsets.None
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 1
ScreenGui.Parent = __real_registers[14]
local u2190 = Instance.new("UIScale")

local function viewport() -- Line: 416; upvalues: u1603 (val), ScreenGui (val)
    local fakeSize = u1603.fakeSize or ScreenGui.AbsoluteSize
    local v1 = math.max(fakeSize.X, 1)
    local v2 = math.max(fakeSize.Y, 1)
    local v3 = math.min(1, v1 / (u1603.vpW or 1280), v2 / (u1603.vpH or 720))

    return v1 / v3, v2 / v3, v3
end

u1642.app = box({
    name = "app",
    dir = "col",
    gap = 10,
    bg = "bg",
    pad = {10, 12, 10, 12},
})
u1642.app.inst.Parent = ScreenGui
u2190.Parent = u1642.app.inst
u1642.topbar = box({
    name = "topbar",
    dir = "row",
    align = "center",
    gap = 14,
    h = 36,
    r = 8,
    bg = "topbar",
    pad = {0, 4},
    parent = u1642.app,
})
u1642.logoCol = box({dir = "col", parent = u1642.topbar})
u1642.logo = text({
    t = "Universal Piano Hub",
    f = "d700_20_8",
    ls = -0.208,
    lh = 20.8,
    parent = u1642.logoCol,
})
u1642.ver = text({t = "", f = "m500_8_32", c = "muted", parent = u1642.logoCol})

function u1603.showVer() -- Line: 435; upvalues: VP (val), u1642 (val)
    local PlaceVersion = tonumber((VP:GetAttribute("PlaceVersion"))) or game.PlaceVersion
    u1642.ver:setText(if not (PlaceVersion > 0) then "Studio" else "v" .. PlaceVersion)
end

;(VP:GetAttributeChangedSignal("PlaceVersion")):Connect(u1603.showVer)
u1603.showVer()

do
    local ImageLabel = Instance.new("ImageLabel")
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.ScaleType = Enum.ScaleType.Fit
    ImageLabel.Size = UDim2.fromScale(1, 1)
    ImageLabel.Parent = u1642.logoCol.inst

    function u1642.logoCol.onPaint() -- Line: 447; upvalues: Lay (val), ImageLabel (val), u1642 (val)
        local logo = Lay.TH.logo
        ImageLabel.Image = logo or ""
        ImageLabel.Visible = logo ~= nil
        u1642.logo.inst.Visible = logo == nil
        u1642.ver.inst.Visible = logo == nil
        local v1 = if not logo then nil else 340

        if u1642.logoCol.w ~= v1 then
            u1642.logoCol.w = v1
            Lay.dirty()
        end
    end
end

box({w = 1, h = 20, bg = "line", parent = u1642.topbar})

u1642.roomBtn = box({
    name = "roomBtn",
    dir = "row",
    align = "center",
    gap = 8,
    r = 7,
    button = true,
    shrink0 = true,
    pad = {4, 6},
    hov = {bg = "panel2"},
    parent = u1642.topbar,
})
u1642.roomBtn:bindHover()

u1642.connDot = box({
    w = 8,
    h = 8,
    r = "pill",
    bg = "dim",
    noShrink = true,
    parent = u1642.roomBtn,
})
__real_registers[15] = img(
    "dotglow",
    {ZIndex = 0, Visible = false}
)
__real_registers[16] = fx.dotglow.margin
__real_registers[15].Position = UDim2.fromOffset(-__real_registers[16], -__real_registers[16])
__real_registers[15].Parent = u1642.connDot.inst
u1642.connGlow = __real_registers[15]
u1642.roomName = text({
    t = "Lobby",
    f = "s600_16",
    lh = 23.2,
    ell = true,
    shrink0 = true,
    parent = u1642.roomBtn,
})

text({
    t = "▾",
    f = "s600_16",
    lh = 23.2,
    noShrink = true,
    parent = u1642.roomBtn,
})

box({grow = 1, h = 1, shrink0 = true, parent = u1642.topbar})

u1642.shopBtn = v16("Support")
u1642.topbar:add(u1642.shopBtn)

u1642.shopBtn.noShrink = true
u1642.reviewBtn = v16("Review sheets")

u1642.topbar:add(u1642.reviewBtn)

u1642.reviewBtn.noShrink = true
u1642.reviewBtn:show(false)

u1642.lbBtn = v16("Leaderboard")
u1642.topbar:add(u1642.lbBtn)

u1642.lbBtn.noShrink = true
u1642.muteBtn = v16("Mute all")

u1642.topbar:add(u1642.muteBtn)

u1642.muteBtn.noShrink = true
u1642.muteBtn.sty = {on = {bg = "brassSoft", bdc = "brass55"}}
u1642.setBtn = v16("⚙ Settings")

u1642.topbar:add(u1642.setBtn)

u1642.sideBtn = v16("⟨")
u1642.topbar:add(u1642.sideBtn)

u1642.body = box({
    name = "body",
    dir = "row",
    gap = 10,
    grow = 1,
    vshrink = true,
    parent = u1642.app,
})
u1642.side = box({
    name = "side",
    dir = "col",
    gap = 10,
    w = 320,
    parent = u1642.body,
})
u1642.playersCard = box({
    dir = "col",
    gap = 8,
    pad = 12,
    bg = "panel",
    bd = 1,
    bdc = "line",
    r = 12,
    parent = u1642.side,
})
u1642.cardHead = box({
    dir = "row",
    justify = "between",
    align = "center",
    gap = 8,
    parent = u1642.playersCard,
})
__real_registers[16] = {parent = u1642.cardHead}
v16 = {
    t = "1 player",
    f = "m500_10_24",
    up = true,
    ls = 1.024,
    c = "muted",
}

if __real_registers[16] then
    for i, j in __real_registers[16] do
        v16[i] = j
    end
end

u1642.playersCount = text(v16)
u1642.hostBtn = box({
    pad = {2, 4},
    r = 4,
    button = true,
    hidden = true,
    parent = u1642.cardHead,
    {
        (text({
            t = "Room settings",
            f = "m500_10_24",
            up = true,
            ls = 1.024,
            c = "brassInk",
        })),
    },
})
u1642.hostBtn.inst.Visible = false
u1642.chips = box({
    dir = "row",
    wrap = true,
    gap = 6,
    align = "center",
    clip = true,
    scroll = true,
    parent = u1642.playersCard,
})
u1642.chipsMore = box({
    dir = "row",
    align = "center",
    justify = "center",
    gap = 5,
    r = 6,
    button = true,
    hidden = true,
    pad = {2, 0},
    hov = {bg = "white05"},
    parent = u1642.playersCard,
})
u1642.chipsMore.inst.Visible = false

u1642.chipsMore:bindHover()

u1642.chipsMore.label = text({
    t = "Show all",
    f = "s500_12_48",
    lh = 18.096,
    c = "muted",
    parent = u1642.chipsMore,
})
u1642.chipsMore.arrow = text({
    t = "▾",
    f = "s500_12_48",
    lh = 18.096,
    c = "muted",
    parent = u1642.chipsMore,
})

do
    local u459 = false
    local u460 = nil
    local u461 = nil
    local u462 = false
    local Frame = Instance.new("Frame")
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(1, 0, 0, 26)
    Frame.ZIndex = 30
    Frame.Visible = false
    __real_registers[17] = Instance.new("UIGradient")
    __real_registers[17].Rotation = 90
    __real_registers[17].Transparency = NumberSequence.new(1, 0)
    __real_registers[17].Parent = Frame
    Frame.Parent = u1642.chips.inst

    u1642.chipsMore:onClick(function() -- Line: 517; upvalues: u459 (ref), u1642 (val), Lay (val)
        u459 = not u459
        u1642.chipsMore.label:setText(if not u459 then "Show all" else "Show less")

        local v1 = if not u459 then 0 else 180
        u1642.chipsMore.arrow.inst.Rotation = v1

        Lay.dirty()
    end)

    __real_registers[8].RenderStepped:Connect(function(a1)
        -- Line: 523
        -- upvalues: u1642 (val), u1603 (val), u462 (ref), Lay (val), ScreenGui (val), u459 (ref), u460 (ref)
        -- upvalues: u461 (ref), Frame (val)
        local v1, v2
        local kids = u1642.chips.kids
        local ay = u1642.chips.ay

        if not ay then
            return
        end

        local v3 = ay

        for i, j in kids do
            if j.ay and j.lh_ then
                v3 = math.max(v3, j.ay + j.lh_)
            end
        end

        local v4 = v3 - ay
        v3 = 250
        local v5 = false

        if u1603.phoneNow == true then
            v5 = #kids > 2
        end

        if v5 and kids[2].ay and kids[2].lh_ then
            v3 = kids[2].ay + kids[2].lh_ - ay
        end

        local v6 = v3 + (if not v5 then 30 else 2) < v4

        if v6 ~= u462 then
            u462 = v6
            u1642.chipsMore:show(v6)
            Lay.dirty()
        end

        local v7 = v4

        if v5 then
            local fakeSize = u1603.fakeSize or ScreenGui.AbsoluteSize
            local v8 = math.max(fakeSize.X, 1)
            local v9 = math.max(fakeSize.Y, 1)
            v2 = math.min(1, v8 / (u1603.vpW or 1280), v9 / (u1603.vpH or 720))
            v1 = v8 / v2
            v7 = math.max(v3, (math.floor(v9 / v2 * 0.32)))
        end

        v1 = v5 and u459 and v7 + 2 < v4
        v5 = if not v6 then
            if not v1 then v4 else v7
        else
            if u459 then if not v1 then v4 else v7 else v3
        local inst = u1642.chips.inst

        if inst.ScrollingEnabled ~= v1 then
            inst.ScrollingEnabled = v1
            inst.ScrollBarThickness = if not v1 then 0 else 5
            inst.ScrollBarImageTransparency = if not v1 then 1 else 0.2

            if not v1 then
                inst.CanvasPosition = Vector2.zero
            end
        end

        if v1 then
            inst.ScrollBarImageColor3 = Lay.TH.muted.c
        end

        if u460 == nil then
            u460 = v5
        end

        v6 = u460
        v6 = if not (0.5 < (math.abs(v6 - v5))) then
            v5
        else
            v6 + (v5 - v6) * math.min(1, a1 * 12)
        u460 = v6
        v5 = if not (v6 < v4 - 0.5) then nil else v6

        if v5 ~= u461 then
            u461 = v5
            u1642.chips.maxH = v5

            Lay.dirty()
        end

        v2 = false

        if v5 ~= nil then
            v2 = not v1
        end

        Frame.Visible = v2

        if Frame.Visible then
            Frame.BackgroundColor3 = Lay.TH.panel.c
            Frame.Position = UDim2.fromOffset(0, (math.floor(inst.CanvasPosition.Y + v6 - 26)))
        end
    end)
end

u1642.tabsCard = box({
    dir = "col",
    grow = 1,
    vshrink = true,
    bg = "panel",
    bd = 1,
    bdc = "line",
    r = 12,
    clip = true,
    parent = u1642.side,
})
u1642.tabbar = box({dir = "row", bdc = "line", bds = {0, 0, 1, 0}, parent = u1642.tabsCard})

local function tabBtn(a1) -- Line: 579; upvalues: text (val), box (val); types: a1: string
    local v1 = text({
        f = "s500_14",
        lh = 20.3,
        c = "muted",
        align = "c",
        t = a1,
    })
    local v2 = box({
        dir = "col",
        grow = 1,
        basis = 0,
        pad = {10, 8},
        bds = {0, 0, 2, 0},
        bdc = {a = 0, c = Color3.new()},
        bdz = 2,
        m = {0, 0, -1, 0},
        button = true,
        sty = {sel = {bdc = "brass"}},
        {v1},
    })
    v2.label = v1

    return v2
end

u1642.tabChat = tabBtn("Chat")

u1642.tabbar:add(u1642.tabChat)

u1642.tabLib = tabBtn("Notes")
u1642.tabbar:add(u1642.tabLib)

__real_registers[16] = u1642.tabChat
__real_registers[16].dir = "row"
__real_registers[16].justify = "center"
__real_registers[16].align = "center"
__real_registers[16].gap = 6

do
    local u547 = text({t = "", f = "m500_10_56", align = "c", c = {a = 1, c = Color3.new(1, 1, 1)}})
    local u567 = box({
        h = 17,
        minW = 17,
        pad = {0, 5},
        r = "pill",
        bg = {a = 1, c = Color3.fromHex("e5484d")},
        dir = "row",
        align = "center",
        justify = "center",
        noShrink = true,
        hidden = true,
        parent = __real_registers[16],
        {u547},
    })
    u567.inst.Visible = false
    local u570 = 0

    __real_registers[16] = function(a1)
        -- Line: 597
        -- upvalues: u570 (ref), u547 (val), u567 (val), Lay (val)
        -- types: a1: number
        if a1 == u570 then
            return
        end

        u570 = a1
        u547:setText(if not (a1 > 99) then tostring(a1) else "99+")
        u567:show(a1 > 0)
        Lay.dirty()
    end

    function u1603.chatVisible() -- Line: 605; upvalues: u1642 (val), u1631 (val)
        local v1 = false

        if u1642.curTab ~= "lib" then
            v1 = not u1631.collapsed and not u1631.fullscreen
        end

        return v1
    end

    function u1603.chatNew(a1)
        -- Line: 608
        -- upvalues: LocalPlayer (val), u1603 (val), u570 (ref), u547 (val), u567 (val), Lay (val)
        -- types: a1: number
        if a1 ~= LocalPlayer.UserId and not u1603.chatVisible() then
            local v1 = u570 + 1

            if v1 == u570 then
                return
            end

            u570 = v1
            u547:setText(if not (v1 > 99) then tostring(v1) else "99+")
            u567:show(v1 > 0)
            Lay.dirty()
        end
    end

    task.spawn(function() -- Line: 612; upvalues: u570 (ref), u1603 (val), u547 (val), u567 (val), Lay (val)
        while true do
            task.wait(0.25)

            if u570 > 0 and u1603.chatVisible() and u570 ~= 0 then
                u570 = 0
                u547:setText((tostring(0)))
                u567:show(false)
                Lay.dirty()
            end
        end
    end)
end

u1642.paneChat = box({dir = "col", grow = 1, vshrink = true, parent = u1642.tabsCard})
u1642.chatList = box({
    name = "chatList",
    scroll = true,
    dir = "col",
    gap = 5,
    grow = 1,
    vshrink = true,
    pad = {10, 12},
    parent = u1642.paneChat,
})
u1642.chatForm = box({
    dir = "row",
    gap = 6,
    pad = 10,
    bdc = "line",
    bds = {1, 0, 0, 0},
    m = {0, 0, 14, 0},
    parent = u1642.paneChat,
})
u1642.chatBox = box({
    grow = 1,
    shrink0 = true,
    h = 38.3,
    bg = "field",
    bd = 1,
    bdc = "line",
    r = 9,
    parent = u1642.chatForm,
})
u1642.chatSend = box({
    dir = "row",
    align = "center",
    pad = {0, 12},
    bd = 1,
    bdc = "line",
    bg = "panel2",
    r = 9,
    button = true,
    parent = u1642.chatForm,
    {(text({t = "➤", f = "s400_14", lh = 20.3, c = "muted"}))},
})

do
    local TextBox = Instance.new("TextBox")
    TextBox.Name = "chatInput"
    TextBox.BackgroundTransparency = 1
    TextBox.Position = UDim2.fromOffset(11, 0)
    TextBox.Size = UDim2.new(1, -22, 1, 0)
    TextBox.ClearTextOnFocus = false
    TextBox.Text = ""
    TextBox.PlaceholderText = "Message…"

    Glyph.fitInput(TextBox, "s400_14")

    TextBox.TextSize = Glyph.nativeSize("s400_14")
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.ClipsDescendants = true
    TextBox.ZIndex = 3
    TextBox.Parent = u1642.chatBox.inst
    u1642.chatInput = TextBox

    function u1642.chatBox.onPaint() -- Line: 643; upvalues: TextBox (val), Lay (val)
        TextBox.TextColor3 = Lay.TH.ink.c
        TextBox.PlaceholderColor3 = Lay.TH.muted.c
    end
end

u1642.chatBox:paint()

u1642.paneLib = box({
    dir = "col",
    grow = 1,
    vshrink = true,
    hidden = true,
    parent = u1642.tabsCard,
})
u1642.paneLib.inst.Visible = false
u1642.libPane = box({
    scroll = true,
    dir = "col",
    gap = 6,
    grow = 1,
    vshrink = true,
    pad = {10, 12},
    parent = u1642.paneLib,
})

do
    local inst = u1642.libPane.inst
    inst.ScrollBarThickness = 4
    inst.ScrollBarImageTransparency = 0.35

    function u1642.libPane.onPaint() -- Line: 658; upvalues: inst (val), Lay (val)
        inst.ScrollBarImageColor3 = Lay.TH.muted.c
    end
end

u1642.editBtn = btn("＋ Paste notes", "primary")
u1642.libPane:add(u1642.editBtn)

u1642.libTools = box({dir = "col", gap = 6, parent = u1642.libPane})
u1642.libList = box({dir = "col", gap = 4, parent = u1642.libPane})

function u1603.showTab(a1) -- Line: 664; upvalues: u1642 (val); types: a1: string
    local v1
    u1642.curTab = if not (a1 == "chat") then "lib" else "chat"

    u1642.paneChat:show(v1)
    u1642.paneLib:show(not v1)
    u1642.tabChat:state("sel", v1)
    u1642.tabLib:state("sel", not v1)

    local v2 = if not v1 then "muted" else "ink"
    u1642.tabChat.label.c = v2

    u1642.tabChat.label:paint()

    v2 = if not v1 then "ink" else "muted"
    u1642.tabLib.label.c = v2

    u1642.tabLib.label:paint()
end

u1642.tabChat:onClick(function() -- Line: 674; upvalues: u1603 (val)
    u1603.showTab("chat")
end)

u1642.tabLib:onClick(function() -- Line: 675; upvalues: u1603 (val), u3710 (val)
    u1603.showTab("lib")

    task.spawn(function() -- Line: 677; upvalues: u3710 (upval), u1603 (upval)
        local at = u3710.at
        u1603.loadCommunity(false)

        if u3710.at ~= at then
            u1603.renderLib()
        end
    end)
end)

u1642.main = box({
    name = "main",
    dir = "col",
    grow = 1,
    shrink0 = true,
    bg = "stage",
    bd = 1,
    bdc = "line",
    r = 12,
    clip = true,
    cover = {
        r = 12,
        c = "bg",
        w = 4,
        line = "line",
        z = 40,
    },
    parent = u1642.body,
})
u1642.kb = box({name = "kb", dir = "col", abs = {l = 0, t = 0, r = 0, b = 0}, parent = u1642.main})
u1642.stage = box({
    name = "stage",
    grow = 1,
    vshrink = true,
    clip = true,
    grad = {rot = 90, stops = {{0, "stage"}, {1, "stage2"}}},
    parent = u1642.kb,
})
u1642.piano = box({
    name = "piano",
    bdc = "pianoTop",
    bdz = 6,
    bds = {3, 0, 0, 0},
    parent = u1642.kb,
})

function u1642.piano.hf() -- Line: 690; upvalues: viewport (val)
    return (math.clamp(0.22 * select(2, viewport()), 110, 200))
end

u1642.qwerty = box({
    name = "qwerty",
    bdc = "pianoTop",
    bdz = 6,
    bg = "panel2",
    hidden = true,
    bds = {3, 0, 0, 0},
    parent = u1642.kb,
})
u1642.qwerty.inst.Visible = false

function u1642.qwerty.hf() -- Line: 693; upvalues: viewport (val)
    return (math.clamp(0.34 * select(2, viewport()), 200, 340))
end

__real_registers[16] = function(a1) -- Line: 696; upvalues: box (val), u1642 (val); types: a1: table
    return box({
        dir = "row",
        align = "center",
        gap = 16,
        bg = "glass",
        bd = 1,
        bdc = "glassLine",
        r = 10,
        z = 5,
        pad = {6, 12},
        abs = a1,
        parent = u1642.main,
    })
end

u1642.pillL = __real_registers[16]({t = 10, l = 10})
u1642.pillR = __real_registers[16]({t = 10, r = 10})
__real_registers[16] = box({dir = "col", gap = 1, parent = u1642.pillL})

__real_registers[16]:add((piCap("Sound")))

do
    __real_registers[18] = box({
        dir = "row",
        align = "center",
        h = 20,
        button = true,
        parent = __real_registers[16],
    })
    __real_registers[16] = text({
        t = "Grand piano",
        f = "s600_14_08",
        grow = 1,
        shrink0 = true,
        ell = true,
        pad = {0, 0, 0, 4},
        parent = __real_registers[18],
    })
    __real_registers[19] = __real_registers[18].inst
    local u805 = img(
        "chev",
        {ZIndex = 3}
    )
    u805.Parent = __real_registers[19]

    __real_registers[18].afterApply = function(a1) -- Line: 709; upvalues: u805 (val)
        u805.Position = UDim2.fromOffset(a1._pw - 8 - 6, math.floor(a1._ph / 2 - 0.5) - 4)
    end

    __real_registers[18].onPaint = function() -- Line: 712; upvalues: u805 (val), Lay (val)
        u805.ImageColor3 = Lay.TH.ink.c
    end

    __real_registers[18]:paint()

    u1642.instrSel = __real_registers[18]
    u1642.instrLbl = __real_registers[16]
    __real_registers[16] = 0

    for k, n in Audio.list do
        __real_registers[16] = math.max(__real_registers[16], (Glyph.width("s600_14_08", n.name)))
    end

    __real_registers[18].w = math.min(170, __real_registers[16] + 20.73)
    __real_registers[18] = box({dir = "col", gap = 1, parent = u1642.pillL})

    __real_registers[18]:add((piCap("Transpose")))

    __real_registers[20] = box({dir = "row", align = "center", gap = 6, parent = __real_registers[18]})
    u1642.trDown = v17("−")

    __real_registers[20]:add(u1642.trDown)

    u1642.trOut = text({t = "0", f = "m600_14_08", parent = __real_registers[20]})
    u1642.trUp = v17("+")

    __real_registers[20]:add(u1642.trUp)

    function u1603.velGain(a1) -- Line: 729; types: a1: number
        return math.clamp(a1, 1, 127) / 105
    end

    __real_registers[18] = box({dir = "col", gap = 1, parent = u1642.pillL})
    u1642.velCap = text({
        f = "m600_8_96",
        up = true,
        ls = 0.896,
        runs = {{t = "Velocity ", c = "muted"}, {t = "100", c = "ink"}},
        parent = __real_registers[18],
    })
    u1642.velRange = range(
        1,
        127,
        1,
        100,
        function(a1) -- Line: 733; upvalues: u1684 (val), u1642 (val), u1603 (val)
            u1684.velocity = a1
            u1642.velCap:setRuns({{t = "Velocity ", c = "muted"}, {c = "ink", t = tostring(a1)}})
            u1603.savePref("vel", a1)
        end
    )

    __real_registers[18]:add(u1642.velRange)

    u1642.loadOut = text({
        t = "",
        f = "m500_11_2",
        c = "brassInk",
        hidden = true,
        parent = u1642.pillL,
    })
    u1642.loadOut.inst.Visible = false

    __real_registers[18] = function(a1, a2)
        -- Line: 743
        -- upvalues: box (val), u1642 (val), piCap (val), img (val), fx (val), Lay (val)
        -- types: a1: string, a2: boolean
        local u6 = box({
            dir = "col",
            gap = 3,
            align = "center",
            button = true,
            parent = u1642.pillR,
        })
        u6:add((piCap(a1)))

        local u17 = box({
            w = 26,
            h = 4,
            r = 2,
            bg = "dim",
            sty = {on = {bg = "ok"}},
            parent = u6,
        })
        local u21 = img(
            "swglow",
            {ZIndex = 0, Visible = false}
        )
        local margin = fx.swglow.margin
        u21.Position = UDim2.fromOffset(-margin, -margin)
        u21.Parent = u17.inst

        function u6.set(a1) -- Line: 751; upvalues: u6 (val), u17 (val), u21 (val), Lay (upval); types: a1: boolean
            u6.on = a1
            u17:state("on", a1)

            u21.Visible = a1
            u21.ImageColor3 = Lay.TH.ok.c
            u21.ImageTransparency = 0.4
        end

        u6.set(a2)

        return u6
    end

    u1642.susBtn = __real_registers[18]("Pedal", true)
    u1642.revBtn = __real_registers[18]("SFX", true)
    __real_registers[18] = box({dir = "col", gap = 1, parent = u1642.pillR})

    __real_registers[18]:add((piCap("Volume")))

    u1642.volRange = range(
        0,
        100,
        1,
        80,
        function(a1) -- Line: 766; upvalues: u1684 (val), Audio (val), u1603 (val)
            u1684.volume = a1 / 100
            Audio.setVolume(u1684.volume)
            u1603.savePref("vol", u1684.volume)
        end
    )
    __real_registers[18]:add(u1642.volRange)

    u1642.fsBtn = v17("⛶", 28)
    u1642.pillR:add(u1642.fsBtn)

    u1642.hud = box({
        name = "hud",
        dir = "col",
        gap = 8,
        bg = "glass",
        bd = 1,
        bdc = "glassLine",
        r = 14,
        z = 6,
        button = true,
        pad = {10, 14},
        abs = {t = 62, cx = true, clamp = true},
        wf = function(a1) -- Line: 777; types: a1: number
            return (math.min(780, a1 - 20))
        end,
        parent = u1642.main,
    })
    u1642.hud.boundary = true
    u1642.hrow = box({dir = "row", align = "center", gap = 10, parent = u1642.hud})
    u1642.seg = box({
        dir = "row",
        gap = 1,
        pad = 2,
        r = "pill",
        bg = "white05",
        noShrink = true,
        parent = u1642.hrow,
    })
    u1642.modeBtns = {}

    for m, i5 in {{"practice", "Practice"}, {"auto", "Autoplay"}} do
        v17 = text({f = "s500_12_8", lh = 18.56, c = "muted", t = i5[2]})
        __real_registers[2] = box({
            dir = "row",
            pad = {4, 10},
            r = "pill",
            button = true,
            sty = {on = {bg = "ink"}},
            {v17},
        })
        __real_registers[2].label = v17

        u1642.seg:add(__real_registers[2])

        u1642.modeBtns[i5[1]] = __real_registers[2]
    end

    u1642.titleBtn = box({
        dir = "col",
        grow = 1,
        shrink0 = true,
        r = 6,
        button = true,
        pad = {2, 4},
        hov = {bg = "white05"},
        parent = u1642.hrow,
    })
    u1642.titleBtn:bindHover()

    u1642.titleLbl = text({
        t = "—",
        f = "d600_16",
        lh = 19.2,
        ell = true,
        parent = u1642.titleBtn,
    })
    u1642.secHud = v18("Section")

    u1642.hrow:add(u1642.secHud)

    u1642.editHud = v18("Edit")
    u1642.hrow:add(u1642.editHud)

    u1642.playBtn = v18("▶ Play", true)
    u1642.hrow:add(u1642.playBtn)

    function u1603.setBpm(a1, a2, a3)
        -- Line: 798
        -- upvalues: u1805 (val), u1642 (val), u1603 (val)
        -- types: a1: number, a2: boolean?, a3: boolean?
        local v1 = math.clamp(math.floor(a1 + 0.5), 1, 500)
        u1805.bpm = v1

        if not a2 then
            u1642.tempoRange.set(v1)
        end

        u1642.tempoCap:setRuns({{t = "BPM ", c = "muted"}, {c = "ink", t = tostring(v1)}})

        if not a3 then
            u1603.savePref("bpm", v1)
        end
    end

    __real_registers[20] = box({dir = "col", gap = 1, noShrink = true, parent = u1642.hrow})
    u1642.tempoCapBtn = box({dir = "row", button = true, parent = __real_registers[20]})
    u1642.tempoCap = text({
        f = "m600_8_96",
        up = true,
        ls = 0.896,
        runs = {{t = "BPM ", c = "muted"}, {t = "120", c = "ink"}},
        parent = u1642.tempoCapBtn,
    })
    u1642.tempoRange = range(
        1,
        500,
        1,
        120,
        function(a1) -- Line: 809; upvalues: u1603 (val)
            u1603.setBpm(a1, true)
        end
    )

    __real_registers[20]:add(u1642.tempoRange)

    u1642.tempoRange.inst.InputChanged:Connect(function(a1) -- Line: 811; upvalues: u1603 (val), u1805 (val)
        if a1.UserInputType == Enum.UserInputType.MouseWheel then
            u1603.setBpm(u1805.bpm + (if not (0 < a1.Position.Z) then -1 else 1))
        end
    end)

    u1642.tempoBox = __real_registers[20]
end

u1642.flowBtn = v18("Non-stop")
u1642.hrow:add(u1642.flowBtn)

u1642.loopBtn = v18("⟳")
u1642.hrow:add(u1642.loopBtn)

u1642.restartBtn = v18("↺")
u1642.hrow:add(u1642.restartBtn)

u1642.minBtn = v18("▴")
u1642.hrow:add(u1642.minBtn)

u1642.closeBtn = v18("×")
u1642.hrow:add(u1642.closeBtn)

for i6, i7 in {
    u1642.secHud,
    u1642.editHud,
    u1642.playBtn,
    u1642.flowBtn,
    u1642.loopBtn,
    u1642.restartBtn,
    u1642.minBtn,
    u1642.closeBtn,
} do
    i7.noShrink = true
end

u1642.hudTab = box({
    name = "hudTab",
    dir = "row",
    align = "center",
    gap = 8,
    bg = "glass",
    bd = 1,
    bdc = "glassLine",
    r = 10,
    z = 6,
    button = true,
    hidden = true,
    pad = {6, 12},
    abs = {t = 62, cx = true, clamp = true},
    hov = {bdc = "brass55"},
    parent = u1642.main,
})
u1642.hudTab:bindHover()

text({
    t = "▾",
    f = "s500_12_48",
    lh = 18.096,
    c = "brassInk",
    parent = u1642.hudTab,
})

u1642.hudTabTitle = text({
    t = "Practice panel",
    f = "d600_16",
    lh = 19.2,
    ell = true,
    maxW = 360,
    shrink0 = true,
    parent = u1642.hudTab,
})
box({
    pad = {1, 5},
    r = 4,
    bg = "white07",
    noShrink = true,
    parent = u1642.hudTab,
    {(text({t = "TAB", f = "m600_8_96", ls = 0.5376, c = "muted"}))},
})

u1642.hrow2 = box({dir = "row", align = "center", gap = 10, parent = u1642.hud})
u1642.cue = box({
    dir = "row",
    align = "end",
    gap = 16,
    grow = 1,
    shrink0 = true,
    clip = true,
    h = 48,
    parent = u1642.hrow2,
})
u1642.stats = box({dir = "row", gap = 14, noShrink = true, parent = u1642.hrow2})

function v18(a1, a2) -- Line: 836; upvalues: box (val), u1642 (val), text (val); types: a1: string, a2: string?
    local v1 = box({dir = "col", align = "end", parent = u1642.stats})
    local v2 = text({t = "0", f = "m600_14_72", c = a2 or "ink", parent = v1})

    text({
        f = "m500_8_64",
        up = true,
        ls = 0.6912,
        c = "muted",
        t = a1,
        parent = v1,
    })

    return v2
end

u1642.stepOut = v18("Step")
u1642.missOut = v18("Errors", "bad")
u1642.accOut = v18("Clean")
u1642.timeOut = v18("Time")
u1642.bar = box({
    h = 3,
    bg = "white08",
    r = 2,
    clip = true,
    parent = u1642.hud,
})
u1642.barFill = box({
    h = 3,
    w = 0,
    bg = "brass",
    r = 2,
    abs = {l = 0, t = 0},
    parent = u1642.bar,
})
u1642.sheet = box({name = "sheet", clip = true, parent = u1642.hud})
u1642.layer = box({name = "layer", dir = "col"})
u1642.layer.inst.Parent = ScreenGui
u1642.layer.inst.ZIndex = 10
v18 = Instance.new("UIScale")
v18.Parent = u1642.layer.inst
u1642.layerScale = v18
u1642.toast = box({
    dir = "row",
    bg = "panel2",
    bd = 1,
    bdc = "line",
    r = 10,
    z = 80,
    hidden = true,
    abs = {b = 24, cx = true},
    pad = {9, 14},
    shadow = {img = "sh30", blur = 30, y = 10},
    parent = u1642.layer,
})
u1642.toast.inst.Visible = false
u1642.toastLbl = text({t = "", f = "s400_14_08", lh = 20.416, parent = u1642.toast})
local u1226 = 0

local function toast(a1) -- Line: 866; upvalues: u1226 (ref), u1642 (val); types: a1: string
    u1226 = u1226 + 1
    local u3 = u1226

    u1642.toastLbl:setText(a1)
    u1642.toast:show(true)

    if u1642.toast.shadowInst then
        u1642.toast.shadowInst.Visible = true
    end

    task.delay(
        2.6,
        function() -- Line: 872; upvalues: u3 (val), u1226 (upval), u1642 (upval)
            if u3 == u1226 then
                u1642.toast:show(false)

                if u1642.toast.shadowInst then
                    u1642.toast.shadowInst.Visible = false
                end
            end
        end
    )
end

u1603.toast = toast

__real_registers[10].OnClientEvent:Connect(function(a1) -- Line: 880; upvalues: toast (val), u1603 (val)
    if type(a1) ~= "string" then
        return
    end

    toast(a1)

    if u1603.sysMsg then
        if string.find(a1, "kicked", 1, true) or string.find(a1, "banned", 1, true) then
            u1603.sysMsg(a1)
        end
    end

    if string.find(a1, "waiting for review", 1, true) and u1603.refreshReview then
        u1603.refreshReview()
    end
end)

do
    local function topInsets() -- Line: 888; upvalues: GuiService (val), u1603 (val), ScreenGui (val)
        local success, err = pcall(function() -- Line: 889; upvalues: GuiService (upval)
            return GuiService.TopbarInset
        end)

        if success and err then
            local fakeSize = u1603.fakeSize or ScreenGui.AbsoluteSize
            local v1 = math.max(fakeSize.X, 1)
            local v2 = math.max(fakeSize.Y, 1)
            local v3 = math.min(1, v1 / (u1603.vpW or 1280), v2 / (u1603.vpH or 720))
            local v4 = v1 / v3
            local v5 = v2 / v3
            local v6 = v3
            local X_2 = ScreenGui.AbsoluteSize.X
            v4 = err.Min.X / v6

            return v4,
                if not (0 < err.Max.X) then
                    0
                else
                    if not (err.Max.X < X_2) then 0 else (X_2 - err.Max.X) / v6
        end

        return 0, 0
    end

    local function applyInsets() -- Line: 897; upvalues: topInsets (val), u1642 (val), Lay (val)
        local v1, v2 = topInsets()
        u1642.topbar.m = {0, math.max(0, v2 - 12), 0, (math.max(0, v1))}

        Lay.dirty()
    end

    ;(GuiService:GetPropertyChangedSignal("TopbarInset")):Connect(applyInsets)
    applyInsets()

    Lay.root(
        u1642.app,
        function() -- Line: 904; upvalues: u1603 (val), ScreenGui (val), u2190 (val)
            local fakeSize = u1603.fakeSize or ScreenGui.AbsoluteSize
            local v1 = math.max(fakeSize.X, 1)
            local v2 = math.max(fakeSize.Y, 1)
            local v3 = math.min(1, v1 / (u1603.vpW or 1280), v2 / (u1603.vpH or 720))
            local v4 = v1 / v3
            local v5 = v2 / v3
            u2190.Scale = v3

            return v4, v5
        end
    )

    Lay.root(
        u1642.layer,
        function() -- Line: 909; upvalues: u1603 (val), ScreenGui (val), u1642 (val)
            local fakeSize = u1603.fakeSize or ScreenGui.AbsoluteSize
            local v1 = math.max(fakeSize.X, 1)
            local v2 = math.max(fakeSize.Y, 1)
            local v3 = math.min(1, v1 / (u1603.vpW or 1280), v2 / (u1603.vpH or 720))
            local v4 = v1 / v3
            local v5 = v2 / v3
            u1642.layerScale.Scale = v3

            return v4, v5
        end
    )

    ;(ScreenGui:GetPropertyChangedSignal("AbsoluteSize")):Connect(function()
        -- Line: 914
        -- upvalues: u1603 (val), ScreenGui (val), u1642 (val), applyInsets (val)
        local fakeSize = u1603.fakeSize or ScreenGui.AbsoluteSize
        local v1 = math.max(fakeSize.X, 1)
        local v2 = math.max(fakeSize.Y, 1)
        local v3 = math.min(1, v1 / (u1603.vpW or 1280), v2 / (u1603.vpH or 720))
        local v4 = v1 / v3
        local v5 = v2 / v3
        u1642.roomName.maxW = v4 * 0.4

        applyInsets()
    end)
end

__real_registers[21] = u1642.roomName
__real_registers[22] = u1603.fakeSize or ScreenGui.AbsoluteSize
__real_registers[23] = math.max(__real_registers[22].X, 1)
__real_registers[24] = math.max(__real_registers[22].Y, 1)
__real_registers[22] = math.min(1, __real_registers[23] / (u1603.vpW or 1280), __real_registers[24] / (u1603.vpH or 720))
__real_registers[25] = __real_registers[23] / __real_registers[22]
__real_registers[26] = __real_registers[24] / __real_registers[22]
__real_registers[21].maxW = 0.4 * __real_registers[25]

__real_registers[8].RenderStepped:Connect(function() -- Line: 921; upvalues: Lay (val)
    Lay.flush()
end)

local u1322 = {}
local u1755 = {}
local u2233 = u1322
local u1767 = nil
local u1778 = nil
local u1327 = nil
local u1328 = nil

__real_registers[26] = function(a1, a2)
    -- Line: 932
    -- upvalues: u1642 (val), u1578 (val), u1684 (val), u1767 (ref), u1327 (ref), u1328 (ref), u1778 (ref)
    -- upvalues: UserInputService (val)
    -- types: a1: userdata, a2: number
    local u2 = {}
    a1.InputBegan:Connect(function(a1)
        -- Line: 934
        -- upvalues: u1642 (upval), u1578 (upval), a2 (val), u1684 (upval), u2 (val), u1767 (upval), u1327 (upval)
        if a1.UserInputType ~= Enum.UserInputType.MouseButton1
            and a1.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        if u1642.dialog then
            return
        end

        local v1 = u1578.ORDER[a2 - u1684.transpose - 35]

        if v1 then
            u2[a1] = v1
            u1767(v1, "user")

            return
        end

        u2[a1] = true
        u1327(a2)
    end)

    local function finish(a1) -- Line: 941; upvalues: u2 (val), u1328 (upval), a2 (val), u1778 (upval)
        local v1 = u2[a1]

        if v1 then
            u2[a1] = nil

            if v1 == true then
                u1328(a2)
                return
            end

            u1778(v1)
        end
    end

    a1.InputEnded:Connect(finish)
    UserInputService.InputEnded:Connect(finish)
end

local function v32(a1, a2) -- Line: 953; upvalues: Glyph (val); types: a1: userdata, a2: string
    local Frame = Instance.new("Frame")
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.fromOffset(0, 0)
    Frame.ZIndex = 4
    Frame.Parent = a1
    local u11 = {t = "", tr = 0, holder = Frame}
    u11.pool = {}
    u11.f = a2
    u11.color = Color3.new(1, 1, 1)

    function u11.draw(a1, a2_2, a3, a4, a5)
        -- Line: 960
        -- upvalues: u11 (val), Glyph (upval), a2 (val), Frame (val)
        -- types: a1: string, a2_2: number, a3: number, a4: userdata, a5: number?
        local v1
        u11.t = a1
        local v2 = Glyph.width(a2, a1)
        local v3 = (Glyph.draw(Frame, u11.pool, 0, a2, a1, 0, a2_2 - v2 / 2, a3, a4, a5 or 0, 4))
            + 1
        local v4 = #u11.pool

        for i = v3, v4 do
            v1 = u11.pool[i]
            v1.Visible = false
        end
    end

    function u11.recolor(a1, a2) -- Line: 966; upvalues: u11 (val); types: a1: userdata, a2: number?
        for i, j in u11.pool do
            if j:IsA("ImageLabel") then
                j.ImageColor3 = a1
                j.ImageTransparency = a2 or 0
            elseif j:IsA("TextLabel") then
                j.TextColor3 = a1
            end
        end
    end

    return u11
end

local function gradOn(a1, a2) -- Line: 979; types: a1: table, a2: table?
    if not a2 then
        if a1.grad then
            a1.grad.Enabled = false
        end

        return
    end

    local grad = a1.grad

    if not grad then
        grad = Instance.new("UIGradient")
        grad.Rotation = 90
        grad.Parent = a1.f
        a1.grad = grad
    end

    local v1 = {}

    for i, j in a2 do
        table.insert(v1, (ColorSequenceKeypoint.new(j[1], j[2])))
    end

    grad.Color = ColorSequence.new(v1)
    grad.Enabled = true
end

local u2170 = Color3.fromHex("111111")

local function paintKey(a1) -- Line: 998; upvalues: Lay (val), gradOn (val), u1603 (val); types: a1: table
    local v1, v2
    local TH = Lay.TH
    local f = a1.f

    if a1.kind == "wk" then
        f.BackgroundColor3 = Color3.new(1, 1, 1)
        local c = TH.wk.c
        local v3 = nil
        local c_2 = c

        if not a1.target then
            if a1.flash == "bad" then
                c_2 = TH.badk.c
            elseif a1.flash == "ok" then
                c_2 = TH.okk.c
            elseif a1.down then
                c_2 = TH.wkDown.c
            elseif not (0 < a1.rdown) then
                if a1.got then
                    v3 = {{0, c}, {0.2, c}, {1, TH.okk.c}}
                elseif a1.target then
                    v3 = {{0, c}, {0.2, c}, {1, TH.hl.c}}
                end
            elseif a1.rcol then
                v3 = {{0, c}, {0.15, c}, {1, a1.rcol}}
            elseif a1.got then
                v3 = {{0, c}, {0.2, c}, {1, TH.okk.c}}
            elseif a1.target then
                v3 = {{0, c}, {0.2, c}, {1, TH.hl.c}}
            end
        elseif a1.down then
            v3 = {{0, TH.wkDown.c}, {0.2, TH.wkDown.c}, {1, TH.hl.c}}
        elseif a1.flash == "bad" then
            c_2 = TH.badk.c
        elseif a1.flash == "ok" then
            c_2 = TH.okk.c
        elseif a1.down then
            c_2 = TH.wkDown.c
        elseif not (0 < a1.rdown) then
            if a1.got then
                v3 = {{0, c}, {0.2, c}, {1, TH.okk.c}}
            elseif a1.target then
                v3 = {{0, c}, {0.2, c}, {1, TH.hl.c}}
            end
        elseif a1.rcol then
            v3 = {{0, c}, {0.15, c}, {1, a1.rcol}}
        elseif a1.got then
            v3 = {{0, c}, {0.2, c}, {1, TH.okk.c}}
        elseif a1.target then
            v3 = {{0, c}, {0.2, c}, {1, TH.hl.c}}
        end

        if not v3 then
            if a1.grad then
                a1.grad.Enabled = false
            end

            f.BackgroundColor3 = c_2
        else
            gradOn(a1, v3)
        end

        f.Position = UDim2.fromOffset(f.Position.X.Offset, if not a1.down then -5 else -4)

        return
    end

    if a1.kind ~= "bk" then
        u1603.paintQKey(a1)
        return
    end

    f.BackgroundColor3 = Color3.new(1, 1, 1)
    local v4 = nil
    local c_3 = nil

    if a1.flash == "bad" then
        c_3 = TH.bkBad.c
    elseif a1.flash == "ok" then
        c_3 = TH.bkOk.c
    elseif a1.down then
        c_3 = TH.bkDown.c
    else
        if not (0 < a1.rdown) then
            if not a1.target then
                v2 = {{0, TH.bkTop.c}, {0.26, TH.bk.c}, {1, TH.bk.c}}
            else
                v2 = {{0, TH.hlBk.c}, {1, TH.bkTargetEnd.c}}
            end
        elseif a1.rcol then
            v2 = {{0, a1.rcol}, {0.9, TH.bk.c}, {1, TH.bk.c}}
        elseif not a1.target then
            v2 = {{0, TH.bkTop.c}, {0.26, TH.bk.c}, {1, TH.bk.c}}
        else
            v2 = {{0, TH.hlBk.c}, {1, TH.bkTargetEnd.c}}
        end

        v4 = v2
    end

    if not v4 then
        if a1.grad then
            a1.grad.Enabled = false
        end

        f.BackgroundColor3 = c_3

        return
    end

    local hh = a1.hh or f.AbsoluteSize.Y
    local v5 = 4 / math.max(1, hh)
    v2 = {{0, v4[1][2]}}

    for i, j in v4 do
        v1 = math.clamp(v5 + j[1] * (1 - v5), 0, 1)

        if v2[#v2][1] < v1 then
            table.insert(
                v2,
                {v1, j[2]}
            )
        end
    end

    if v2[#v2][1] < 1 then
        table.insert(
            v2,
            {1, v4[#v4][2]}
        )
    end

    gradOn(a1, v2)
end

local function paintAllKeys() -- Line: 1045; upvalues: u1322 (val), paintKey (val), u1755 (val)
    for i, j in u1322 do
        paintKey(j)
    end

    for k, n in u1755 do
        paintKey(n)
    end
end

local u1663 = {}
local u1653 = {}

do
    __real_registers[27] = Instance.new("Frame")
    __real_registers[27].Name = "keys"
    __real_registers[27].BackgroundTransparency = 1
    __real_registers[27].ClipsDescendants = true
    __real_registers[27].Position = UDim2.fromOffset(0, 3)
    __real_registers[27].Parent = u1642.piano.inst
    u1642.pianoClip = __real_registers[27]

    for i8 = 21, 108 do
        __real_registers[3] = u1578.isBlack(i8)
        __real_registers[4] = Instance.new("TextButton")
        __real_registers[4].Name = tostring(i8)
        __real_registers[4].Text = ""
        __real_registers[4].AutoButtonColor = false
        __real_registers[4].BorderSizePixel = 0
        __real_registers[4].ZIndex = if not __real_registers[3] then 1 else 3
        __real_registers[5] = Instance.new("UICorner", __real_registers[4])
        __real_registers[5].CornerRadius = UDim.new(0, if not __real_registers[3] then 5 else 4)

        if not __real_registers[3] then
            __real_registers[5] = Instance.new("UIStroke")
            __real_registers[5].Name = "edge"
            __real_registers[5].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            __real_registers[5].BorderStrokePosition = Enum.BorderStrokePosition.Inner
            __real_registers[5].Thickness = 1
            __real_registers[5].Parent = __real_registers[4]
        end

        __real_registers[4].Parent = __real_registers[27]
        __real_registers[5] = {
            down = false,
            rdown = 0,
            target = false,
            got = false,
            f = __real_registers[4],
            kind = if not __real_registers[3] then "wk" else "bk",
            lb = v32(__real_registers[4], if not __real_registers[3] then "m600_12_48" else "m600_9_92"),
        }

        if not __real_registers[3] then
            __real_registers[5].nn = v32(__real_registers[4], "m500_8_32")
        end

        if i8 == 60 then
            v6 = Instance.new("Frame")
            v6.Name = "mid"
            v6.BorderSizePixel = 0
            v6.Size = UDim2.fromOffset(5, 5)
            v6.ZIndex = 2
            __real_registers[6] = Instance.new("UICorner", v6)
            __real_registers[6].CornerRadius = UDim.new(1, 0)
            v6.Parent = __real_registers[4]
        end

        if __real_registers[3] then
            v6 = img(
                "keysh",
                {
                    Name = "shadow",
                    ZIndex = 2,
                    ImageTransparency = 0.6,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(fx.keysh.slice[1], fx.keysh.slice[2], fx.keysh.slice[3], fx.keysh.slice[4]),
                    ImageColor3 = Color3.new(0, 0, 0),
                }
            )
            v6.Parent = __real_registers[27]
            __real_registers[5].shadow = v6
        end

        __real_registers[5].m = i8
        u1322[i8] = __real_registers[5]

        __real_registers[26](__real_registers[4], i8)
    end
end

u1603.CTRL_LO = "1234567890qwert"
u1603.CTRL_HI = "yuiopasdfghj"

function u1603.ctrlLabel(a1) -- Line: 1107; upvalues: u1603 (val); types: a1: number
    if a1 >= 21 and a1 <= 35 then
        return (string.sub(u1603.CTRL_LO, a1 - 20, a1 - 20))
    end

    if a1 >= 97 and a1 <= 108 then
        return (string.sub(u1603.CTRL_HI, a1 - 96, a1 - 96))
    end

    return nil
end

function u1603.keyUnderline(a1, a2, a3, a4, a5, a6)
    -- Line: 1113
    -- upvalues: Glyph (val)
    -- types: a2: boolean, a3: string, a4: number, a5: number, a6: userdata
    local ul = a1.ul

    if not a2 then
        if ul then
            ul.Visible = false
        end

        return
    end

    if not ul then
        ul = Instance.new("Frame")
        ul.Name = "ul"
        ul.BorderSizePixel = 0
        ul.ZIndex = 5
        ul.Parent = a1.f
        a1.ul = ul
    end

    local v1 = math.max(4, (Glyph.width(a3, a1.lb.t)))
    ul.Visible = true
    ul.BackgroundColor3 = a6
    ul.Size = UDim2.fromOffset(math.floor(v1 + 0.5), 1)
    ul.Position = UDim2.fromOffset(math.floor(a4 - v1 / 2 + 0.5), (math.floor(a5 + 2 + 0.5)))
end

function u1603.kbRange() -- Line: 1133; upvalues: u1631 (val)
    if u1631.kb == 61 then
        return 36, 96
    end

    return 21, 108
end

function u1603.layoutPiano()
    -- Line: 1137
    -- upvalues: u1642 (val), u1603 (val), u1578 (val), u1653 (val), u1663 (val), Lay (val), u1322 (val), u1684 (val)
    -- upvalues: u1631 (val), Glyph (val), fx (val), paintKey (val)
    local edge, f, margin, mid, v1, v2, v3, v4, v5, v6, v7, v8, v9
    local piano = u1642.piano
    local v10 = u1642.stage._pw or 0
    local v11 = math.max((piano._ph or 0) - 3, 40)

    if v10 <= 0 then
        return
    end

    u1642.pianoClip.Size = UDim2.fromOffset(v10, v11)
    local v12, v13 = u1603.kbRange()
    local v14 = 0

    for i = v12, v13 do
        if not u1578.isBlack(i) then
            v14 = v14 + 1
        end
    end

    local v15 = (v10 + v14 - 1) / v14
    local v16 = v10 / v14 * 0.62
    local v17 = 0

    table.clear(u1653)
    table.clear(u1663)

    local TH = Lay.TH

    for j = 21, 108 do
        v1 = u1322[j]
        f = v1.f
        v2 = false

        if v12 <= j then
            v2 = j <= v13
        end

        f.Visible = v2

        if v1.shadow then
            v1.shadow.Visible = v2
        end

        if v2 then
            v2 = u1578.ORDER[j - u1684.transpose - 35]
            v3 = false

            if not v2 then
                v3 = (u1603.ctrlLabel(j - u1684.transpose)) ~= nil
            end

            v2 = v2 or ""

            if v1.kind ~= "wk" then
                v4 = v17 / v14 * v10 - v16 / 2
                v5 = math.floor(v4 + 0.5)
                v6 = math.floor(v4 + v16 + 0.5)
                v8 = math.floor(v11 * 0.6 + 0.5)
                f.Size = UDim2.fromOffset(v6 - v5, v8 + 4)
                f.Position = UDim2.fromOffset(v5, -4)
                v1.hh = v8 + 4
                v9 = {x = v4 + v16 / 2, w = v16}
                u1663[j] = v9
                v7 = v8 + 4 - 5 - Glyph.style("m600_9_92").lh
                    + Glyph.baseline("m600_9_92")

                v1.lb.draw(v2, (v6 - v5) / 2, v7, TH.bkInk.c)
                u1603.keyUnderline(v1, v3, "m600_9_92", (v6 - v5) / 2, v7, TH.bkInk.c)

                margin = fx.keysh.margin
                v1.shadow.Position = UDim2.fromOffset(v5 - margin, -4 - margin + 2)
                v1.shadow.Size = UDim2.fromOffset(v6 - v5 + 2 * margin, v8 + 4 + 2 * margin)
            else
                v4 = v17 * (v15 - 1)
                v5 = math.floor(v4 + 0.5)
                v6 = math.floor(v4 + v15 + 0.5)
                f.Size = UDim2.fromOffset(v6 - v5, v11 + 5)
                f.Position = UDim2.fromOffset(v5, if not v1.down then -5 else -4)
                v8 = {x = v4 + v15 / 2, w = v15}
                u1663[j] = v8

                if j % 12 == 0 then
                    table.insert(u1653, v4)
                end

                v17 = v17 + 1
                v4 = v11 + 5
                v7 = v4 - 1 - 6

                if u1631.names then
                    v7 = v7 - (Glyph.style("m500_8_32").lh + 1)
                end

                v8 = v7 - Glyph.style("m600_12_48").lh + Glyph.baseline("m600_12_48")
                v1.lb.draw(v2, (v6 - v5) / 2, v8, TH.wkInk.c)
                u1603.keyUnderline(v1, v3, "m600_12_48", (v6 - v5) / 2, v8, TH.wkInk.c)

                if v1.nn then
                    v1.nn.holder.Visible = u1631.names

                    if u1631.names then
                        v1.nn.draw(u1578.noteName(j), (v6 - v5) / 2, v4 - 1 - 6 - Glyph.style("m500_8_32").lh + Glyph.baseline("m500_8_32"), TH.wkSub.c)
                    end
                end

                edge = f:FindFirstChild("edge")

                if edge then
                    edge.Color = TH.wkEdge.c
                end

                mid = f:FindFirstChild("mid")

                if mid then
                    mid.Position = UDim2.fromOffset(math.floor((v6 - v5) / 2 - 2.5 + 0.5), v4 - 1 - 36 - 5)
                    mid.BackgroundColor3 = TH.midDot.c
                end
            end

            paintKey(v1)
        end
    end

    u1603.layoutStage()
end

function u1642.piano.afterApply() -- Line: 1214; upvalues: u1603 (val)
    u1603.layoutPiano()
end

require(script:WaitForChild("Qwerty"))({
    B = box,
    T = text,
    U = u1642,
    F = u1603,
    P = u1631,
    Lay = Lay,
    Glyph = Glyph,
    Notes = u1578,
    NOTE = NOTE,
    keys = u1755,
    glyphLabel = v32,
    paintKey = paintKey,
    press = function(a1, a2) -- Line: 1219; upvalues: u1767 (ref); types: a1: string, a2: string
        u1767(a1, a2)
    end,
    release = function(a1) -- Line: 1219; upvalues: u1778 (ref); types: a1: string
        u1778(a1)
    end,
})

function u1642.qwerty.afterApply() -- Line: 1220; upvalues: u1603 (val)
    u1603.layoutQwerty()
end

local u1782 = {}
local u1783 = {}
local u1784 = {}

do
    local u1785 = {}
    local u1786 = {}

    __real_registers[3] = function(a1)
        -- Line: 1231
        -- upvalues: u1631 (val), u1755 (val), u1322 (val), NOTE (val), u1684 (val)
        -- types: a1: string
        if u1631.view == "qwerty" then
            return u1755[a1]
        end

        return u1322[NOTE[a1] + u1684.transpose]
    end

    __real_registers[4] = function(a1, a2)
        -- Line: 1235
        -- upvalues: NOTE (val), u1684 (val), u1663 (val)
        -- types: a1: string?, a2: number?
        local v1 = a2 or (if not a1 then nil else NOTE[a1] + u1684.transpose)

        if v1 then
            return u1663[v1]
        end

        return nil
    end

    __real_registers[5] = function() -- Line: 1239; upvalues: u1642 (val)
        return u1642.stage._ph or 0
    end

    function u1603.layoutStage()
        -- Line: 1243
        -- upvalues: Lay (val), u1642 (val), u1653 (val), u1785 (val), u1603 (val)
        local v1, v2, v3
        local TH = Lay.TH
        local v4 = u1642.stage._ph or 0
        local v5 = nil
        local v6 = nil

        for i, j in u1653, v5, v6 do
            v2 = u1785[i]

            if not v2 then
                v2 = Instance.new("Frame")
                v2.BorderSizePixel = 0
                v2.ZIndex = 1
                v2.Parent = u1642.stage.inst
                u1785[i] = v2
            end

            v2.Visible = true
            v2.Position = UDim2.fromOffset(math.floor(j + 0.5), 0)
            v2.Size = UDim2.fromOffset(1, v4)
            v3 = if not TH.light then Color3.new(1, 1, 1) else Color3.new(0, 0, 0)
            v2.BackgroundColor3 = v3
            v2.BackgroundTransparency = if not TH.light then 0.96 else 0.94
        end

        v6 = #u1653 + 1
        local v7 = #u1785

        for k = v6, v7 do
            v1 = u1785[k]
            v1.Visible = false
        end

        u1603.renderGlow()
    end

    function u1603.renderGlow()
        -- Line: 1265
        -- upvalues: u1786 (val), u1805 (val), u1642 (val), NOTE (val), u1684 (val), u1663 (val), Lay (val)
        local v1 = u1786
        local v2 = nil

        for i, j in v1, v2 do
            j.Visible = false
        end

        if u1805.mode ~= "free" and not u1805.finished and u1805.steps[u1805.idx] then
            local UIGradient, UIGradient_2, v3, v4
            v1 = u1642.stage._ph or 0
            v2 = 0
            local keys = u1805.steps[u1805.idx].keys
            local v5 = nil
            local v6 = nil

            for k, n in keys, v5, v6 do
                v4 = if not n then nil else NOTE[n] + u1684.transpose
                v3 = if not v4 then nil else u1663[v4]

                if v3 and not u1805.got[n] then
                    v2 = v2 + 1
                    v4 = u1786[v2]

                    if not v4 then
                        v4 = Instance.new("Frame")
                        v4.BorderSizePixel = 0
                        v4.ZIndex = 1
                        UIGradient = Instance.new("UIGradient")
                        UIGradient.Rotation = 90
                        UIGradient.Parent = v4
                        v4.Parent = u1642.stage.inst
                        u1786[v2] = v4
                    end

                    v4.Visible = true
                    v4.BackgroundColor3 = Lay.TH.brass.c
                    UIGradient_2 = v4:FindFirstChildOfClass("UIGradient")
                    UIGradient_2.Transparency = NumberSequence.new(1, 0.68)
                    v4.Position = UDim2.fromOffset(math.floor(v3.x - v3.w / 2 + 1 + 0.5), (math.floor(v1 * 0.35 + 0.5)))
                    v4.Size = UDim2.fromOffset(math.floor(v3.w - 2 + 0.5), (math.floor(v1 * 0.65 + 0.5)))
                end
            end
        end
    end
end

local u1806 = {}
u1806.ok = {Color3.fromHex("f2fff7"), Color3.fromHex("3fd98a"), 1}
u1806.bad = {Color3.fromHex("fff0ec"), Color3.fromHex("ff5a43"), 1}
u1806.auto = {Color3.fromHex("fff6e2"), Color3.fromHex("e3a83a"), 1}
u1806.free = {Color3.new(1, 1, 1), Color3.new(1, 1, 1), 0.85}

local function getBar() -- Line: 1301; upvalues: u1784 (val), img (val), fx (val)
    local v1 = table.remove(u1784)

    if not v1 then
        local v2 = img(
            "glow",
            {
                ZIndex = 2,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(fx.glow.slice[1], fx.glow.slice[2], fx.glow.slice[3], fx.glow.slice[4]),
            }
        )
        local Frame = Instance.new("Frame")
        Frame.BorderSizePixel = 0
        Frame.ZIndex = 3
        local v3 = Instance.new("UICorner", Frame)
        v3.CornerRadius = UDim.new(1, 0)
        v1 = {glow = v2, fill = Frame}
    end

    return v1
end

function u1603.placeBar(a1, a2, a3) -- Line: 1315; upvalues: fx (val), u1603 (val); types: a2: number, a3: number
    local v1
    local v2 = math.max(150, a2 * 0.7)
    local v3 = a2 - (a3 - a1.t0) * v2

    if (if not a1.t1 then a2 else a2 - (a3 - a1.t1) * v2) < -4 then
        return false
    end

    local gm = a1.gm or fx.glow.margin
    local v4 = v3
    local w = v1 - v3

    if w < a1.w then
        v4 = v1 - a1.w
        w = a1.w
    end

    a1.fill.Position = UDim2.fromOffset(a1.x - a1.w / 2, v4)
    a1.fill.Size = UDim2.fromOffset(a1.w, w)
    v1 = a1.w + 2 * gm
    a1.glow.SliceScale = math.min(1, v1 / fx.glow.w)
    a1.glow.Position = UDim2.fromOffset(a1.x - v1 / 2, v4 - gm)
    a1.glow.Size = UDim2.fromOffset(v1, w + 2 * gm)

    if a1.fxStep then
        a1.fxStep(a1, v4, w, a2)
    end

    if a1.rb then
        local v5 = if a1.rb ~= true then
            if not u1603.styleFlows(a1.rb, a1.bk) then
                nil
            else
                u1603.styleColor(a1.rb, a1.rx, a1.bk)
        else
            u1603.rainbow(a1.rx)

        if v5 then
            a1.glow.ImageColor3 = v5
            a1.fill.BackgroundColor3 = if a1.rb ~= true then
                v5
            else
                (Color3.new(1, 1, 1)):Lerp(v5, 0.35)
        end
    end

    return true
end

local function v34(a1) -- Line: 1340; upvalues: u1783 (val); types: a1: string
    local v1 = u1783[a1]

    if v1 then
        v1.t1 = os.clock()
        u1783[a1] = nil
    end
end

function u1603.rainbow(a1, a2) -- Line: 1348; types: a1: number, a2: number?
    return Color3.fromHSV(((a1 or 0) / 700 + os.clock() * 0.18 + (a2 or 0)) % 1, 0.72, 1)
end

function u1603.noteFx(a1) -- Line: 1352; types: a1: userdata
    return a1:GetAttribute("Rainbow") == true
end

local function spawnBar(a1, a2, a3, a4, a5, a6, a7)
    -- Line: 1354
    -- upvalues: u1642 (val), u1783 (val), u1603 (val), u1806 (val), Lay (val), getBar (val), fx (val), u1782 (val)
    -- types: a1: string, a2: table?, a3: string, a4: userdata?, a5: boolean?, a7: userdata?
    if a2 and not u1642.podiumOn then
        local v1 = u1783[a1]

        if v1 then
            v1.t1 = os.clock()
            u1783[a1] = nil
        end

        v1 = a5 == true
        local v2 = if type(a6) ~= "table" then
            if not a6 then a4 else u1603.rainbow(a2.x)
        else
            u1603.styleColor(a6, a2.x, v1)
        local v3 = math.clamp(a2.w * (if not v1 then 0.46 else 0.7), 6, 26)
        local free = u1806[a3] or u1806.free
        local v4 = free[1]
        local v5 = free[2]
        local v6 = free[3]

        if v2 then
            if type(a6) ~= "table" then
                local v7 = if not a6 then 0.15 else 0.35
                v4 = (Color3.new(1, 1, 1)):Lerp(v2, v7)
            else
                v4 = v2
            end

            v5 = v2
            v6 = 1

            if type(a6) == "table" then
                v6 = math.min(1, (u1603.styleGlow(a6, v1)))
            end
        end

        if Lay.TH.light then
            v4 = if a3 ~= "free" then v5 else if v2 then v5 else Color3.fromHex("2a2e33")
        end

        local v8 = getBar()
        v8.rb = a6 or nil
        v8.bk = v1
        v8.rx = a2.x
        v8.gm = fx.glow.margin * math.max(1, 1)
        v8.fill.BackgroundColor3 = v4
        v8.glow.ImageColor3 = v5
        v8.glow.ImageTransparency = 1 - v6
        v8.x = a2.x
        v8.w = v3
        v8.t0 = os.clock()
        v8.t1 = nil

        if u1603.barFx then
            u1603.barFx(v8, u1603.effectOf(a7))
        end

        table.insert(u1782, v8)

        u1783[a1] = v8
        v6 = u1642.stage._ph or 0

        u1603.placeBar(v8, v6, (os.clock()))

        v8.glow.Parent = u1642.stage.inst
        v8.fill.Parent = u1642.stage.inst

        if u1603.burst then
            u1603.burst(u1642.stage.inst, a2.x, v6, a2.w, v5, u1603.effectOf(a7), a6 == true)
        end
    end
end

__real_registers[8].RenderStepped:Connect(function()
    -- Line: 1398
    -- upvalues: u1782 (val), u1642 (val), u1603 (val), u1784 (val)
    local v1

    if #u1782 == 0 then
        return
    end

    local v2 = u1642.stage._ph or 0
    local v3 = os.clock()
    local v4 = 1

    while v4 <= #u1782 do
        v1 = u1782[v4]

        if not u1603.placeBar(v1, v2, v3) then
            v1.glow.Parent = nil
            v1.fill.Parent = nil

            table.insert(u1784, v1)
            table.remove(u1782, v4)
        else
            v4 = v4 + 1
        end
    end
end)

local u1865 = false

local function v35(a1, a2, a3)
    -- Line: 1418
    -- upvalues: Audio (val), NOTE (val), u1684 (val), u1865 (ref), toast (val)
    -- types: a1: string, a2: string, a3: number
    if not Audio.on(a1, NOTE[a2] + u1684.transpose, u1684.instr, a3)
        and not u1865 then
        u1865 = true
        toast("Sounds aren't connected yet.")
    end
end

local function v36(a1, a2, a3, a4)
    -- Line: 1425
    -- upvalues: Note (val), u1684 (val), NOTE (val)
    -- types: a1: string, a2: boolean, a3: boolean, a4: boolean
    Note:FireServer(a1, a2, a3, u1684.instr, NOTE[a1] + u1684.transpose, a4, u1684.velocity)
end

local function setSustain(a1) -- Line: 1428; upvalues: u1684 (val), Audio (val), Pedal (val); types: a1: boolean
    u1684.sustain = a1

    if not a1 then
        Audio.killWhere(function(a1) -- Line: 1431; upvalues: u1684 (upval)
            local v1
            local v2 = string.sub(a1, 1, 1)

            if v2 ~= "L" then
                v1 = true

                if v2 ~= "H" then
                    v1 = v2 == "M"
                end
            else
                v1 = not u1684.held[string.sub(a1, 2)]

                if not v1 then
                    v1 = true

                    if v2 ~= "H" then
                        v1 = v2 == "M"
                    end
                end
            end

            return v1
        end)

        if next(u1684.pendingOff) then
            Pedal:FireServer()
        end

        table.clear(u1684.pendingOff)
    end
end

local function v37() -- Line: 1439; upvalues: u1684 (val), setSustain (val)
    local v1 = u1684.pedalDefault ~= u1684.spaceDown

    if v1 ~= u1684.sustain then
        setSustain(v1)
    end
end

local u1925 = {}

local function flash(a1, a2)
    -- Line: 1445
    -- upvalues: u1631 (val), u1755 (val), u1322 (val), NOTE (val), u1684 (val), paintKey (val), u1925 (val)
    -- types: a1: string, a2: string
    local u12 = if u1631.view ~= "qwerty" then
        u1322[NOTE[a1] + u1684.transpose]
    else
        u1755[a1]

    if not u12 then
        return
    end

    u12.flash = a2
    paintKey(u12)

    u1925[a1] = (u1925[a1] or 0) + 1
    local u25 = u1925[a1]

    task.delay(
        0.23,
        function() -- Line: 1452; upvalues: u1925 (upval), a1 (val), u25 (val), u12 (val), paintKey (upval)
            if u1925[a1] == u25 then
                u12.flash = nil
                paintKey(u12)
            end
        end
    )
end

function u1767(a1, a2)
    -- Line: 1460
    -- upvalues: u1941 (val), LocalPlayer (val), u1603 (val), u1684 (val), Audio (val), NOTE (val), u1865 (ref)
    -- upvalues: toast (val), u1631 (val), u1755 (val), u1322 (val), paintKey (val), spawnBar (val), u1663 (val)
    -- upvalues: u1578 (val), Note (val)
    -- types: a1: string, a2: string
    local v1
    local v2 = a2 == "auto"
    u1941[LocalPlayer.UserId] = (os.clock())
    local v3 = "L" .. a1
    local v4 = u1603.velGain(u1684.velocity)

    if not Audio.on(v3, NOTE[a1] + u1684.transpose, u1684.instr, v4)
        and not u1865 then
        u1865 = true
        toast("Sounds aren't connected yet.")
    end

    u1684.held[a1] = true
    u1684.pendingOff[a1] = nil
    v3 = if u1631.view ~= "qwerty" then
        u1322[NOTE[a1] + u1684.transpose]
    else
        u1755[a1]
    u1684.heldKey[a1] = v3

    if v3 then
        v3.down = true
        paintKey(v3)
    end

    v3 = if not v2 then "free" else "auto"

    if not v2 then
        if u1603.tutKey then
            u1603.tutKey(a1)
        end

        v4 = u1603.onUserNote(a1)

        if v4 then
            v3 = v4
        end
    end

    local v5 = if not a1 then nil else NOTE[a1] + u1684.transpose
    local v6 = if not v5 then nil else u1663[v5]
    local v7 = u1578.isBlack(NOTE[a1] + u1684.transpose)

    if v3 == "free" then
        v1 = u1603.noteFx(LocalPlayer)
    else
        v1 = false

        if v3 == "auto" then
            v1 = u1603.noteFx(LocalPlayer)
        end
    end

    spawnBar("L" .. a1, v6, v3, nil, v7, v1, LocalPlayer)
    Note:FireServer(a1, true, false, u1684.instr, NOTE[a1] + u1684.transpose, v2, u1684.velocity)
end

function u1778(a1)
    -- Line: 1479
    -- upvalues: u1684 (val), paintKey (val), u1783 (val), Note (val), NOTE (val), Audio (val)
    -- types: a1: string
    if not u1684.held[a1] then
        return
    end

    u1684.held[a1] = nil
    local v1 = u1684.heldKey[a1]
    u1684.heldKey[a1] = nil

    if v1 then
        v1.down = false
        paintKey(v1)
    end

    local v2 = "L" .. a1
    v1 = u1783[v2]

    if v1 then
        v1.t1 = os.clock()
        u1783[v2] = nil
    end

    if u1684.sustain then
        u1684.pendingOff[a1] = true
        Note:FireServer(a1, false, true, u1684.instr, NOTE[a1] + u1684.transpose, false, u1684.velocity)

        return
    end

    Audio.killFamily("L" .. a1)
    Note:FireServer(a1, false, false, u1684.instr, NOTE[a1] + u1684.transpose, false, u1684.velocity)
end

function u1327(a1)
    -- Line: 1494
    -- upvalues: u1941 (val), LocalPlayer (val), Audio (val), u1684 (val), u1603 (val), u1322 (val), paintKey (val)
    -- upvalues: spawnBar (val), u1663 (val), u1578 (val), Note (val)
    -- types: a1: number
    local v1 = "M" .. a1
    u1941[LocalPlayer.UserId] = (os.clock())

    Audio.on(v1, a1, u1684.instr, u1603.velGain(u1684.velocity))

    local v2 = u1322[a1]

    if v2 then
        v2.down = true
        paintKey(v2)
    end

    spawnBar(v1, u1663[a1], "free", nil, u1578.isBlack(a1), u1603.noteFx(LocalPlayer), LocalPlayer)
    Note:FireServer(u1578.ORDER[math.clamp(a1 - 35, 1, 61)], true, false, u1684.instr, a1, false, u1684.velocity)
end

function u1328(a1)
    -- Line: 1503
    -- upvalues: u1322 (val), paintKey (val), u1783 (val), u1684 (val), Audio (val), Note (val), u1578 (val)
    -- types: a1: number
    local v1 = "M" .. a1
    local v2 = u1322[a1]

    if v2 then
        v2.down = false
        paintKey(v2)
    end

    v2 = u1783[v1]

    if v2 then
        v2.t1 = os.clock()
        u1783[v1] = nil
    end

    if not u1684.sustain then
        Audio.killFamily(v1)
    else
        u1684.pendingOff[v1] = true
    end

    Note:FireServer(u1578.ORDER[math.clamp(a1 - 35, 1, 61)], false, u1684.sustain, u1684.instr, a1, false)
end

local u1959 = {"f2c14e", "5ec8f2", "ef7aa8", "7be08a", "b48cff", "ff9d5c", "5ce1c6", "e6e6e6"}

do
    local u1969 = {}
    local u1970 = {}

    local function rpaint(a1, a2, a3)
        -- Line: 1523
        -- upvalues: u1322 (val), u1755 (val), u1578 (val), paintKey (val)
        -- types: a1: number, a2: number, a3: userdata?
        local v1
        local v2 = {u1322[a1] or false, u1755[u1578.ORDER[a1 - 35] or ""] or false}
        local v3 = nil
        local v4 = nil
        local v5, v6 = a2, a3

        for i, j in v2, v3, v4 do
            if j then
                v1 = j.rdown + v5
                j.rdown = math.max(0, v1)

                if v6 then
                    j.rcol = v6
                end

                paintKey(j)
            end
        end
    end

    function u1603.rrelease(a1, a2)
        -- Line: 1532
        -- upvalues: u1970 (val), u1969 (val), Audio (val), u1783 (val), rpaint (val)
        -- types: a1: string, a2: boolean?
        local v1 = u1970[a1]

        if not v1 then
            return
        end

        u1970[a1] = nil

        if not a2 then
            Audio.killFamily(a1)
        else
            u1969[a1] = true
        end

        local v2 = u1783[a1]

        if v2 then
            v2.t1 = os.clock()
            u1783[a1] = nil
        end

        rpaint(v1.midi, -1)
    end

    function u1603.rheldKeys() -- Line: 1541; upvalues: u1970 (val)
        return u1970
    end

    Note.OnClientEvent:Connect(function(a1, a2, a3, a4, a5, a6, a7)
        -- Line: 1542
        -- upvalues: NOTE (val), u1631 (val), LocalPlayer (val), u1959 (val), Players (val), u1603 (val), u1970 (val)
        -- upvalues: u1783 (val), u1969 (val), u1941 (val), u2003 (ref), Audio (val), u1663 (val), u1578 (val)
        -- upvalues: spawnBar (val), rpaint (val)
        if type(a2) == "string" and NOTE[a2] and type(a1) == "number" then
            local v1, v2

            if u1631.muteAll then
                return
            end

            if type(a6) ~= "number" then
                a6 = NOTE[a2]
            end

            local v3 = "R" .. a1 .. ":" .. a6
            local e6e6e6 = if a1 ~= LocalPlayer.UserId then
                Color3.fromHex(u1959[a1 % (#u1959 - 1) + 1])
            else
                Color3.fromHex("e6e6e6")
            local PlayerByUserId = Players:GetPlayerByUserId(a1)
            local v4 = false

            if PlayerByUserId ~= nil then
                v4 = u1603.noteFx(PlayerByUserId)
            end

            if not a3 then
                v1 = u1970[v3]

                if not v1 then
                    return
                end

                u1970[v3] = nil

                if not a4 then
                    Audio.killFamily(v3)
                else
                    u1969[v3] = true
                end

                v2 = u1783[v3]

                if v2 then
                    v2.t1 = os.clock()
                    u1783[v3] = nil
                end

                rpaint(v1.midi, -1)

                return
            end

            if u1970[v3] ~= nil then
                v2 = u1783[v3]

                if v2 then
                    v2.t1 = os.clock()
                    u1783[v3] = nil
                end
            end

            u1969[v3] = nil
            u1970[v3] = {midi = a6, t = os.clock()}
            u1941[a1] = (os.clock())
            local v5 = u2003[tostring(a1)]
            local p = if not v5 then 1 else if not v5.p then 1 else v5.p
            v5 = if type(a7) ~= "number" then 0.85 else u1603.velGain(a7)

            if p > 0.001 then
                Audio.on(v3, a6, a5, v5 * p, a7)
            end

            v2 = a6 or nil
            v5 = if not v2 then nil else u1663[v2]

            if v4 and v5 then
                e6e6e6 = if v4 ~= true then
                    u1603.styleColor(v4, v5.x, u1578.isBlack(a6))
                else
                    u1603.rainbow(v5.x)
            end

            spawnBar(v3, v5, "free", e6e6e6, u1578.isBlack(a6), v4, PlayerByUserId)
            rpaint(a6, if not v1 then 1 else 0, e6e6e6)
        end
    end)

    task.spawn(function() -- Line: 1569; upvalues: u1970 (val), Audio (val), u1783 (val), rpaint (val)
        local v1, v2, v3, v4, v5

        while true do
            task.wait(2)

            v1 = os.clock()
            v2 = {}

            for i, j in u1970 do
                if 20 < v1 - j.t then
                    table.insert(v2, i)
                end
            end

            v3 = nil
            v4 = nil

            for k, n in v2, v3, v4 do
                v1 = u1970[n]

                if v1 then
                    u1970[n] = nil
                    Audio.killFamily(n)

                    v5 = u1783[n]

                    if v5 then
                        v5.t1 = os.clock()
                        u1783[n] = nil
                    end

                    rpaint(v1.midi, -1)
                end
            end
        end
    end)

    function u1603.setMuteAll(a1)
        -- Line: 1580
        -- upvalues: u1631 (val), u1642 (val), Audio (val), u1969 (val), u1970 (val), u1783 (val), u1322 (val)
        -- upvalues: u1755 (val), paintKey (val), api (val)
        -- types: a1: boolean
        local v1

        if u1631.muteAll == true == a1 then
            return
        end

        u1631.muteAll = a1
        u1631.muteAt = os.clock()

        u1642.muteBtn:state("on", a1)
        u1642.muteBtn.label:setText(if not a1 then "Mute all" else "Muted all")

        if not a1 then
            v1 = a1
        else
            local v2
            Audio.killWhere(function(a1) -- Line: 1587
                return string.sub(a1, 1, 1) == "R"
            end)

            table.clear(u1969)
            table.clear(u1970)

            local v3 = {}

            for i in u1783 do
                if string.sub(i, 1, 1) == "R" then
                    table.insert(v3, i)
                end
            end

            for j, k in v3 do
                v2 = u1783[k]

                if v2 then
                    v2.t1 = os.clock()
                    u1783[k] = nil
                end
            end

            local v4 = {u1322, u1755}
            local v5 = nil
            local v6 = nil
            v1 = a1

            for n, m in v4, v5, v6 do
                for i5, i6 in m do
                    if 0 < i6.rdown then
                        i6.rdown = 0
                        paintKey(i6)
                    end
                end
            end
        end

        task.spawn(api, "setMuteAll", v1)
    end

    u1642.muteBtn:onClick(function() -- Line: 1601; upvalues: u1603 (val), u1631 (val)
        u1603.setMuteAll(not u1631.muteAll)
    end)

    ;(LocalPlayer:GetAttributeChangedSignal("MuteAll")):Connect(function()
        -- Line: 1603
        -- upvalues: LocalPlayer (val), u1631 (val), u1603 (val)
        local v1 = LocalPlayer:GetAttribute("MuteAll") == true

        if v1 ~= (u1631.muteAll == true) and 2 < os.clock() - (u1631.muteAt or 0) then
            u1603.setMuteAll(v1)
        end
    end)

    Pedal.OnClientEvent:Connect(function(a1) -- Line: 1608; upvalues: u1969 (val), Audio (val)
        local v1
        local v2 = "R" .. (tostring(a1)) .. ":"

        for i in u1969 do
            v1 = #v2

            if string.sub(i, 1, v1) == v2 then
                Audio.killFamily(i)

                u1969[i] = nil
            end
        end
    end)
end

local function v38() -- Line: 1619; upvalues: u1805 (val)
    local v1 = 0
    local v2 = 0

    for i, j in u1805.res do
        v2 = v2 + 1

        if j == "ok" then
            v1 = v1 + 1
        end
    end

    return v1, v2
end

local function v39() -- Line: 1627; upvalues: u1805 (val)
    u1805.playing = false
    u1805.gen = u1805.gen + 1
end

local function restart() -- Line: 1631; upvalues: u1805 (val), u1603 (val)
    u1805.playing = false
    u1805.gen = u1805.gen + 1
    u1805.idx = u1805.secA or 1

    table.clear(u1805.got)

    u1805.mistakes = 0
    table.clear(u1805.res)
    table.clear(u1805.times)

    u1805.goodKeys = 0
    u1805.start = nil
    u1805.elapsed = 0
    u1805.finished = false

    u1603.render()
end

do
    local function finish() -- Line: 1644; upvalues: u1805 (val), u1603 (val), Run (val), restart (val)
        u1805.elapsed = if not u1805.start then 0 else (os.clock() - u1805.start) * 1000
        u1805.finished = true
        u1805.idx = #u1805.steps + 1

        u1603.render()

        if u1805.mode == "practice" then
            local v1 = 0
            local v2 = 0

            for i, j in u1805.res do
                v2 = v2 + 1

                if j == "ok" then
                    v1 = v1 + 1
                end
            end

            Run:FireServer({
                title = u1805.title,
                steps = #u1805.steps,
                clean = v1,
                mistakes = u1805.mistakes,
                ms = u1805.elapsed,
                flow = u1805.flow,
            })

            u1603.showResult()
        end

        if u1805.loop then
            task.delay(
                1.6,
                function() -- Line: 1655; upvalues: u1805 (upval), restart (upval)
                    if u1805.finished and u1805.loop then
                        restart()
                    end
                end
            )
        end
    end

    local function advance() -- Line: 1658; upvalues: u1805 (val), u1603 (val), finish (val)
        u1805.idx = u1805.idx + 1
        table.clear(u1805.got)

        if u1805.secB and u1805.secB < u1805.idx then
            u1603.secLoop()
            return
        end

        local idx_2 = u1805.idx

        if #u1805.steps < idx_2 then
            finish()
            return
        end

        u1603.render()
    end

    function u1603.onUserNote(a1)
        -- Line: 1664
        -- upvalues: u1805 (val), u1603 (val), advance (val), flash (val)
        -- types: a1: string
        if u1805.mode == "practice" and not u1805.finished and #u1805.steps ~= 0 then
            if not u1805.start then
                u1805.start = os.clock()
            end

            local v1 = u1805.steps[u1805.idx]

            if not u1805.times[u1805.idx] then
                u1805.times[u1805.idx] = (os.clock())
            end

            if not table.find(v1.keys, a1) then
                u1805.mistakes = u1805.mistakes + 1
                u1805.res[u1805.idx] = "miss"

                flash(a1, "bad")
                u1603.shakeCue()

                if not u1805.flow then
                    u1603.render()
                else
                    advance()
                end

                return "bad"
            end

            if not u1805.got[a1] then
                u1805.goodKeys = u1805.goodKeys + 1
            end

            u1805.got[a1] = true

            for i, j in v1.keys do
                if not u1805.got[j] then
                    u1603.render()
                    return "ok"
                end
            end

            if u1805.res[u1805.idx] ~= "miss" then
                u1805.res[u1805.idx] = "ok"
            end

            advance()

            return "ok"
        end

        return nil
    end
end

local function v40(a1) -- Line: 1686; upvalues: u1805 (val), u1603 (val); types: a1: number
    if #u1805.steps == 0 then
        return
    end

    u1805.idx = math.clamp(a1, 1, #u1805.steps)
    table.clear(u1805.got)

    u1805.finished = false
    u1603.render()
end

do
    local u2064 = {}

    local function tickMs() -- Line: 1695; upvalues: u1805 (val)
        return 60000 / u1805.bpm / 2
    end

    function autoTick(a1)
        -- Line: 1696
        -- upvalues: u1805 (val), u1603 (val), u1767 (ref), u2064 (val), u1778 (ref), autoTick (val)
        -- types: a1: number
        if u1805.playing and a1 == u1805.gen then
            local v1, v2, v3

            if not u1805.allowAuto then
                u1805.playing = false
                v1 = u1805
                v1.gen = v1.gen + 1

                u1603.render()

                return
            end

            if u1805.secB then
                local idx = u1805.idx

                if u1805.secB < idx then
                    u1805.idx = u1805.secA
                end
            end

            local idx_2 = u1805.idx

            if #u1805.steps < idx_2 then
                if not u1805.loop then
                    u1805.playing = false
                    u1805.finished = true
                    v1 = u1805
                    v3 = os.clock()
                    local start = u1805.start or os.clock()
                    v1.elapsed = (v3 - start) * 1000

                    u1603.render()

                    return
                else
                    u1805.idx = 1
                end
            end

            v1 = u1805.steps[u1805.idx]
            local u59 = u1805.idx + 1
            v3 = math.max(110, (if not (u59 <= #u1805.steps) then 60000 / u1805.bpm / 2 * 2 else u1805.steps[u59].wait * (60000 / u1805.bpm / 2)) * 0.92)

            for i, j in v1.keys do
                u1767(j, "auto")

                u2064[j] = (u2064[j] or 0) + 1
                local u113 = u2064[j]

                task.delay(
                    v3 / 1000,
                    function() -- Line: 1719; upvalues: u2064 (upval), j (val), u113 (val), u1778 (upval)
                        if u2064[j] == u113 then
                            u1778(j)
                        end
                    end
                )
            end

            u1603.render()

            task.delay(
                v2 / 1000,
                function() -- Line: 1722; upvalues: a1 (val), u1805 (upval), u59 (val), autoTick (upval)
                    if a1 ~= u1805.gen then
                        return
                    end

                    u1805.idx = u59
                    autoTick(a1)
                end
            )
        end
    end

    u1603.tapHeld = {}
    u1603.tapOwner = {}

    function u1603.tapStep(a1, a2)
        -- Line: 1731
        -- upvalues: u1603 (val), u1778 (ref), u1805 (val), toast (val), u2064 (val), u1684 (val), u1767 (ref)
        -- types: a2: boolean
        local v1

        if not a2 then
            v1 = u1603.tapHeld[a1]
            u1603.tapHeld[a1] = nil

            if v1 then
                for k, n in v1 do
                    if u1603.tapOwner[n] == a1 then
                        u1603.tapOwner[n] = nil
                        u1778(n)
                    end
                end
            end

            return
        end

        if u1603.tapHeld[a1] then
            return
        end

        if u1805.mode == "auto" and #u1805.steps ~= 0 then
            if not u1805.allowAuto then
                toast("The host turned off autoplay in this room.")
                return
            end

            if u1805.playing then
                u1805.playing = false
                u1805.gen = u1805.gen + 1
            end

            local idx = u1805.idx

            if #u1805.steps < idx or u1805.finished then
                u1805.idx = 1
                u1805.finished = false
                u1805.start = nil
            end

            if not u1805.start then
                u1805.start = os.clock()
            end

            v1 = {}
            local keys = u1805.steps[u1805.idx].keys
            local v2 = nil
            local v3 = nil
            local v4 = a1

            for i, j in keys, v2, v3 do
                u2064[j] = (u2064[j] or 0) + 1

                if u1684.held[j] then
                    u1778(j)
                end

                u1767(j, "auto")

                u1603.tapOwner[j] = v4
                table.insert(v1, j)
            end

            u1603.tapHeld[v4] = v1
            u1805.idx = u1805.idx + 1
            local idx_2 = u1805.idx

            if #u1805.steps < idx_2 then
                if not u1805.loop then
                    u1805.finished = true
                    local v5 = os.clock()
                    local start = u1805.start or os.clock()
                    u1805.elapsed = (v5 - start) * 1000
                else
                    u1805.idx = 1
                end
            end

            u1603.render()
        end
    end
end

local function startAuto() -- Line: 1775; upvalues: u1805 (val), u1603 (val), autoTick (val)
    if #u1805.steps ~= 0 and u1805.allowAuto then
        local idx = u1805.idx

        if #u1805.steps < idx or u1805.finished then
            u1805.idx = 1
            u1805.finished = false
        end

        u1805.playing = true
        u1805.gen = u1805.gen + 1
        u1805.start = os.clock()

        u1603.render()
        autoTick(u1805.gen)
    end
end

do
    local function capNode(a1, a2, a3, a4)
        -- Line: 1786
        -- upvalues: u1578 (val), box (val), text (val), NOTE (val)
        -- types: a1: string, a2: boolean, a3: boolean, a4: boolean
        local v1 = u1578.physical(a1)
        local v2 = box({
            dir = "row",
            align = "center",
            justify = "center",
            bg = "cap",
            noShrink = true,
            minW = if not a2 then 46 else 28,
            h = if not a2 then 48 else 32,
            pad = {0, if not a2 then 9 else 5},
            bds = {1, 1, if a2 then 2 else if not a4 then 4 else 2, 1},
            bdc = if not a4 then if not a3 then "capEdge" else "brass" else "ok",
            r = if not a2 then 8 else 6,
        })
        v2.ty = if not a4 then 0 else 2

        text({
            z = 2,
            t = a1,
            f = if not a2 then "m600_24" else "m600_14_72",
            lh = if not a2 then 24 else 14.72,
            c = if not a4 then "ink" else "ok",
            parent = v2,
        })

        if v1 then
            box({
                abs = if not a2 then {t = 3, l = 4} else {t = 1, l = 2},
                bg = "brass",
                r = 3,
                pad = {0, if not a2 then 3 else 2},
                z = 3,
                parent = v2,
                {
                    text({
                        t = "Shift",
                        c = "dark111",
                        z = 3,
                        f = if not a2 then "m600_7_68" else "m600_6_4",
                        lh = if not a2 then 7.68 else 6.4,
                    }),
                },
            })
        end

        if not a2 then
            box({
                abs = {b = 2, r = 5},
                z = 3,
                parent = v2,
                {
                    text({
                        f = "m600_8",
                        lh = 8,
                        c = "muted",
                        z = 3,
                        t = u1578.noteName(NOTE[a1]),
                    }),
                },
            })
        end

        return v2
    end

    u1603.capPool = {}

    function u1603.takeCap(a1, a2, a3, a4)
        -- Line: 1806
        -- upvalues: u1603 (val), capNode (val)
        -- types: a1: string, a2: boolean, a3: boolean, a4: boolean
        local v1 = a1
            .. (if not a2 then "b" else "s")
                .. (if not a3 then "" else "n") .. (if not a4 then "" else "g")
        local v2 = u1603.capPool[v1]
        local v3 = v2 and table.remove(v2)

        if not v3 then
            v3 = capNode(a1, a2, a3, a4)
            v3.capKey = v1
        end

        return v3
    end
end

function u1603.recycleCue(a1) -- Line: 1816; upvalues: u1603 (val)
    local v1

    for i, j in table.clone(a1.kids) do
        if not j.capKey then
            u1603.recycleCue(j)
            j:destroy()
        else
            j:detach()

            v1 = u1603.capPool[j.capKey]

            if not v1 then
                u1603.capPool[j.capKey] = {}
            end

            table.insert(v1, j)
        end
    end
end

function u1603.renderCue()
    -- Line: 1829
    -- upvalues: u1603 (val), u1642 (val), text (val), u1805 (val), u1578 (val), box (val)
    local takeCap_3, v1, v2, v3
    u1603.recycleCue(u1642.cue)

    local function msg(a1) -- Line: 1831; upvalues: u1642 (upval), text (upval)
        u1642.cue:add(
            (text({
                f = "s400_13_6",
                c = "muted",
                wrap = true,
                grow = 1,
                shrink0 = true,
                runs = a1,
                lh = 19.72,
            }))
        )
    end

    if u1805.mode == "free" then
        msg({{t = "Free play.", f = "s600_13_6", c = "ink"}, {t = " Play anything you like."}})
        return
    end

    if #u1805.steps == 0 then
        msg({{t = "Pick a sheet in the Notes tab."}})
        return
    end

    if u1805.finished then
        local v4 = 0
        v2 = 0

        for i5, i6 in u1805.res do
            v2 = v2 + 1

            if i6 == "ok" then
                v4 = v4 + 1
            end
        end

        if u1805.mode == "practice" then
            msg({
                {t = "Done!", f = "s600_13_6", c = "ink"},
                {
                    t = string.format(" Clean %d of %d, errors: %d, %s.", v4, #u1805.steps, u1805.mistakes, u1578.fmtTime(u1805.elapsed)),
                },
            })
            return
        end

        msg({
            {t = "End of sheet.", f = "s600_13_6", c = "ink"},
            {t = " Press Play, or tap [ or ] to play it again."},
        })

        return
    end

    local v5 = u1805.steps[u1805.idx]
    local v6 = box({dir = "row", gap = 6, noShrink = true, parent = u1642.cue})
    v2 = nil
    local v7 = nil

    for i, j in v5.keys, v2, v7 do
        takeCap_3 = u1603.takeCap
        v1 = u1805.got[j] == true

        v6:add((takeCap_3(j, false, true, v1)))
    end

    v6 = box({
        dir = "row",
        gap = 5,
        align = "end",
        shrink0 = true,
        clip = true,
        parent = u1642.cue,
    })
    v7 = u1805.idx + 1
    local secB = u1805.secB or #u1805.steps

    for k = v7, (math.min(secB, u1805.idx + 7)) do
        v5 = u1805.steps[k]
        v3 = #v5.keys

        if not (v3 > 1) then
            v6:add((u1603.takeCap(v5.keys[1], true, false, false)))
        else
            v3 = box({
                dir = "row",
                gap = 2,
                pad = 2,
                r = 7,
                bg = "white06",
                noShrink = true,
                parent = v6,
            })

            for n, m in v5.keys do
                v3:add((u1603.takeCap(m, true, false, false)))
            end
        end
    end
end

do
    local u2076 = 0

    function u1603.shakeCue() -- Line: 1865; upvalues: u2076 (ref), u1642 (val)
        u2076 = u2076 + 1
        local u2 = u2076

        task.spawn(function() -- Line: 1868; upvalues: u2 (val), u2076 (upval), u1642 (upval)
            for i, j in {-5, 4, -2, 0} do
                if u2 ~= u2076 then
                    return
                end

                u1642.cue.ty_x = j
                u1642.cue.inst.Position = UDim2.fromOffset((u1642.cue._px or 0) + j, u1642.cue._py or 0)

                task.wait(0.065)
            end
        end)
    end
end

local u2078 = {
    lines = 0,
    scroll = 0,
    width = 0,
    sig = "",
    contentH = 0,
    viewH = 0,
    manual = false,
    manualCur = 0,
    toks = {},
}

do
    __real_registers[28] = Instance.new("Frame")
    __real_registers[28].Name = "content"
    __real_registers[28].BackgroundTransparency = 1
    __real_registers[28].Size = UDim2.fromScale(1, 0)
    __real_registers[28].Parent = u1642.sheet.inst
    u2078.holder = __real_registers[28]
    __real_registers[28] = Instance.new("Frame")
    __real_registers[28].Name = "scrollbar"
    __real_registers[28].BackgroundTransparency = 1
    __real_registers[28].Size = UDim2.new(0, 10, 1, -4)
    __real_registers[28].Position = UDim2.new(1, -10, 0, 2)
    __real_registers[28].ZIndex = 5
    __real_registers[28].Visible = false
    __real_registers[28].Parent = u1642.sheet.inst
    __real_registers[29] = Instance.new("Frame")
    __real_registers[29].BorderSizePixel = 0
    __real_registers[29].Size = UDim2.new(0, 4, 1, 0)
    __real_registers[29].Position = UDim2.fromOffset(4, 0)
    __real_registers[29].ZIndex = 5
    __real_registers[30] = Instance.new("UICorner", __real_registers[29])
    __real_registers[30].CornerRadius = UDim.new(0, 2)
    __real_registers[29].Parent = __real_registers[28]
    __real_registers[30] = Instance.new("Frame")
    __real_registers[30].BorderSizePixel = 0
    __real_registers[30].Size = UDim2.fromOffset(4, 20)
    __real_registers[30].ZIndex = 6
    __real_registers[31] = Instance.new("UICorner", __real_registers[30])
    __real_registers[31].CornerRadius = UDim.new(0, 2)
    __real_registers[30].Parent = __real_registers[29]
    u2078.sb = {hit = __real_registers[28], rail = __real_registers[29], thumb = __real_registers[30]}
end

do
    local u2153 = {}

    local function buildOwner() -- Line: 1918; upvalues: u2153 (val), u1805 (val)
        local e, s, v1, v2
        table.clear(u2153)

        local v3 = nil
        local v4 = nil

        for i, j in u1805.steps, v3, v4 do
            s = j.s
            e = j.e

            for k = s, e do
                u2153[k] = i
            end
        end

        local comments = u1805.comments or {}
        v3 = nil
        v4 = nil

        for n, m in comments, v3, v4 do
            v2 = m[1]
            v1 = m[2]

            for i5 = v2, v1 do
                u2153[i5] = -3
            end
        end
    end

    function u1603.buildSheet()
        -- Line: 1929
        -- upvalues: u2078 (val), u1642 (val), u1805 (val), u1603 (val), u2153 (val)
        local kind, v1, v2, v3, v4, v5, v6
        local holder = u2078.holder
        local v7 = nil
        local v8 = nil

        for i, j in u2078.toks, v7, v8 do
            if j.bg then
                j.bg:Destroy()
            end

            for k, n in j.pool do
                n:Destroy()
            end
        end

        table.clear(u2078.toks)

        local v9 = (u1642.sheet._pw or 750) - 8 - 10
        u2078.width = v9
        u2078.scroll = 0
        u2078.manual = false

        if u2078.tw then
            u2078.tw:Cancel()
        end

        holder.Position = UDim2.fromOffset(0, 0)

        if string.gsub(u1805.text, "%s", "") == "" then
            table.insert(
                u2078.toks,
                {
                    kind = "gap",
                    text = "No sheet open. Pick one in the Notes tab.",
                    x = 0,
                    line = 1,
                    sans = true,
                    pool = {},
                }
            )

            u2078.lines = 1
            u1603.indexSheet()
            u1603.paintSheet()

            return
        end

        local u121 = {}
        local u96 = -2
        local u93 = ""

        local function flush() -- Line: 1952; upvalues: u93 (ref), u121 (val), u96 (ref)
            if u93 == "" then
                return
            end

            table.insert(
                u121,
                {
                    kind = if not (u96 >= 0) then if u96 ~= -3 then "gap" else "cmt" else "tok",
                    step = u96,
                    text = u93,
                }
            )

            u93 = ""
        end

        local v10 = #u1805.text

        for m = 1, v10 do
            v6 = u2153[m] or -1

            if v6 ~= u96 then
                if u93 ~= "" then
                    table.insert(
                        u121,
                        {
                            kind = if not (u96 >= 0) then if u96 ~= -3 then "gap" else "cmt" else "tok",
                            step = u96,
                            text = u93,
                        }
                    )

                    u93 = ""
                end

                u96 = v6
            end

            v1 = u93
            u93 = v1 .. string.sub(u1805.text, m, m)
        end

        if u93 ~= "" then
            table.insert(
                u121,
                {
                    kind = if not (u96 >= 0) then if u96 ~= -3 then "gap" else "cmt" else "tok",
                    step = u96,
                    text = u93,
                }
            )

            u93 = ""
        end

        v10 = 0
        local v11 = 1
        local v12 = {}
        v6 = nil
        v1 = nil

        for i5, i6 in u121, v6, v1 do
            if i6.kind ~= "tok" then
                kind = i6.kind
                v3 = ""
                v4 = v10

                for i7 in string.gmatch(i6.text, utf8.charpattern) do
                    if i7 ~= "\n" then
                        if i7 ~= " " then
                            v5 = v10 + 9.12

                            if v9 + 0.01 < v5 and v10 > 0 then
                                if v3 ~= "" then
                                    table.insert(
                                        v12,
                                        {kind = kind, text = v3, x = v4, line = v11}
                                    )
                                end

                                v3 = ""
                                v10 = 0
                                v11 = v11 + 1
                                v4 = 0
                            end
                        end

                        if v3 == "" then
                            v4 = v10
                        end

                        v3 = v3 .. i7
                        v10 = v10 + 9.12
                    else
                        if v3 ~= "" then
                            table.insert(
                                v12,
                                {kind = kind, text = v3, x = v4, line = v11}
                            )
                        end

                        v3 = ""
                        v10 = 0
                        v11 = v11 + 1
                        v4 = 0
                    end
                end

                if v3 ~= "" then
                    table.insert(
                        v12,
                        {kind = kind, text = v3, x = v4, line = v11}
                    )
                end
            else
                v2 = #i6.text * 9.12 + 2
                v3 = v10 + v2

                if v9 + 0.01 < v3 and v10 > 0 then
                    v10 = 0
                    v11 = v11 + 1
                end

                table.insert(
                    v12,
                    {
                        kind = "tok",
                        step = i6.step,
                        text = i6.text,
                        x = v10,
                        line = v11,
                        w = v2,
                    }
                )

                v10 = v10 + v2
            end
        end

        u2078.lines = v11

        for i8, i9 in v12 do
            i9.pool = {}
            table.insert(u2078.toks, i9)
        end

        u1603.indexSheet()
        u1603.paintSheet()
    end

    function u1603.indexSheet() -- Line: 2009; upvalues: u2078 (val)
        local v1
        u2078.byLine = {}
        u2078.stepLine = {}
        u2078.live = {}
        local v2 = nil
        local v3 = nil

        for i, j in u2078.toks, v2, v3 do
            v1 = u2078.byLine[j.line]

            if not v1 then
                u2078.byLine[j.line] = {}
            end

            table.insert(v1, j)

            if j.kind == "tok" and not u2078.stepLine[j.step] then
                u2078.stepLine[j.step] = j.line
            end
        end
    end

    function u1603.releasePiece(a1) -- Line: 2020
        for i, j in a1.pool do
            j:Destroy()
        end

        table.clear(a1.pool)

        a1.drawnKey = nil

        if a1.bg then
            a1.bg:Destroy()

            a1.bg = nil
        end
    end

    function u1603.syncSheet(a1, a2)
        -- Line: 2027
        -- upvalues: u2078 (val), u1603 (val), u1805 (val)
        -- types: a1: number, a2: number
        if not u2078.byLine then
            return
        end

        local v1 = math.max(1, (math.floor(a1 / 28.12)) - 1)
        local v2 = math.floor((a2 + u2078.viewH) / 28.12) + 3
        local v3 = nil
        local v4 = nil

        for i in u2078.live, v3, v4 do
            if i < v1 then
                for j, k in u2078.byLine[i] or {} do
                    u1603.releasePiece(k)
                end

                u2078.live[i] = nil
            elseif v2 < i then
                for n, m in u2078.byLine[i] or {} do
                    u1603.releasePiece(m)
                end

                u2078.live[i] = nil
            end
        end

        local idx = if not u1805.finished then u1805.idx else -1

        for i5 = v1, (math.min(v2, u2078.lines)) do
            if not u2078.live[i5] then
                u2078.live[i5] = true

                for i6, i7 in u2078.byLine[i5] or {} do
                    u1603.paintPiece(i7, idx)
                end
            end
        end
    end

    function u1603.setSheetScroll(a1, a2)
        -- Line: 2047
        -- upvalues: u2078 (val), u1603 (val), Lay (val)
        -- types: a1: number, a2: boolean?
        local holder = u2078.holder
        local v1 = math.max(0, u2078.contentH - u2078.viewH)
        local v2 = math.clamp(a1, 0, v1)

        u1603.syncSheet(math.min(u2078.scroll, v2), (math.max(u2078.scroll, v2)))

        if v2 ~= u2078.scroll then
            u2078.scroll = v2

            if u2078.tw then
                u2078.tw:Cancel()
            end

            if not a2 then
                u2078.tw = Lay.tween(
                    holder,
                    0.18,
                    {Position = UDim2.fromOffset(0, -v2)}
                )
            else
                holder.Position = UDim2.fromOffset(0, -v2)
            end
        end

        local sb = u2078.sb
        local v3 = v1 > 1
        sb.hit.Visible = v3

        if v3 then
            local TH = Lay.TH
            sb.rail.BackgroundColor3 = TH.ink.c
            sb.rail.BackgroundTransparency = 0.9
            local thumb = sb.thumb
            local c = if not sb.drag then TH.muted.c else TH.brass.c
            thumb.BackgroundColor3 = c
            sb.thumb.BackgroundTransparency = if not sb.drag then 0.35 else 0
            local v4 = math.max(1, u2078.viewH - 4)
            local v5 = math.max(14, v4 * u2078.viewH / u2078.contentH)
            sb.thumb.Size = UDim2.fromOffset(4, (math.floor(v5 + 0.5)))
            sb.thumb.Position = UDim2.fromOffset(0, (math.floor((v4 - v5) * (u2078.scroll / v1) + 0.5)))
        end
    end

    function u1603.paintPiece(a1, a2)
        -- Line: 2078
        -- upvalues: u2078 (val), Lay (val), u1805 (val), u2170 (val), Glyph (val)
        -- types: a2: number
        local v1, v2
        local holder = u2078.holder
        local TH = Lay.TH
        local v3 = 2 + (a1.line - 1) * 28.12
        local v4 = "m500_15_2"
        local c = TH.ink.c
        local v5 = 0
        local c_2 = nil
        local a = 0

        if a1.sans then
            v4 = "s400_14"
            c = TH.ink.c
        elseif a1.kind == "gap" then
            c = TH.dim.c
        elseif a1.kind ~= "cmt" then
            local step = a1.step
            v2 = u1805.res[step]

            if step ~= a2 then
                if u1805.secMark == step then
                    c_2 = TH.brass.c
                    a = 0.35
                elseif not u1805.secA then
                    if v2 == "miss" then
                        v4 = "m600_15_2"
                        c = TH.bad.c
                        c_2 = TH.badSoft.c
                        a = TH.badSoft.a
                    elseif step < u1805.idx or u1805.finished then
                        c = TH.muted.c
                        v5 = 0.45
                    end
                elseif step < u1805.secA or u1805.secB < step then
                    c = TH.dim.c
                    v5 = 0.55
                elseif v2 == "miss" then
                    v4 = "m600_15_2"
                    c = TH.bad.c
                    c_2 = TH.badSoft.c
                    a = TH.badSoft.a
                elseif step < u1805.idx or u1805.finished then
                    c = TH.muted.c
                    v5 = 0.45
                end
            elseif u1805.mode ~= "free" then
                c_2 = TH.brass.c
                a = 1
                c = u2170
            elseif u1805.secMark == step then
                c_2 = TH.brass.c
                a = 0.35
            elseif not u1805.secA then
                if v2 == "miss" then
                    v4 = "m600_15_2"
                    c = TH.bad.c
                    c_2 = TH.badSoft.c
                    a = TH.badSoft.a
                elseif step < u1805.idx or u1805.finished then
                    c = TH.muted.c
                    v5 = 0.45
                end
            elseif step < u1805.secA or u1805.secB < step then
                c = TH.dim.c
                v5 = 0.55
            elseif v2 == "miss" then
                v4 = "m600_15_2"
                c = TH.bad.c
                c_2 = TH.badSoft.c
                a = TH.badSoft.a
            elseif step < u1805.idx or u1805.finished then
                c = TH.muted.c
                v5 = 0.45
            end
        else
            c = TH.brassInk.c
            v5 = 0.2
        end

        if c_2 then
            if not a1.bg then
                local Frame = Instance.new("Frame")
                Frame.BorderSizePixel = 0
                Frame.ZIndex = 1
                v2 = Instance.new("UICorner", Frame)
                v2.CornerRadius = UDim.new(0, 4)
                Frame.Parent = holder
                a1.bg = Frame
            end

            a1.bg.Visible = true
            a1.bg.BackgroundColor3 = c_2
            a1.bg.BackgroundTransparency = 1 - a
            v1 = v3
                + (28.12 - Glyph.style("m500_15_2").asc - Glyph.style("m500_15_2").desc)
                    / 2
                - 1
            a1.bg.Position = UDim2.fromOffset(math.floor(4 + a1.x + 0.5), (math.floor(v1 + 0.5)))
            a1.bg.Size = UDim2.fromOffset(math.floor(a1.w + 0.5), (math.floor((Glyph.style("m500_15_2")).asc + (Glyph.style("m500_15_2")).desc + 2 + 0.5)))
        elseif a1.bg then
            a1.bg.Visible = false
        end

        local v6 = v4 .. "|" .. (c:ToHex()) .. "|" .. v5

        if a1.drawnKey ~= v6 then
            local v7
            a1.drawnKey = v6
            v1 = 4 + a1.x
            local v8 = v1 + (if a1.kind ~= "tok" then 0 else 1)
            local v9 = (Glyph.draw(holder, a1.pool, 0, v4, a1.text, 0, v8, v3 + Glyph.baseline(v4, if not a1.sans then 28.12 else 20.3), c, v5, 2))
                + 1
            local v10 = #a1.pool

            for i = v9, v10 do
                v7 = a1.pool[i]
                v7.Visible = false
            end
        end
    end

    function u1603.paintSheet() -- Line: 2139; upvalues: u1805 (val), u2078 (val), u1603 (val), u1642 (val), Lay (val)
        local v1
        local idx = if not u1805.finished then u1805.idx else -1

        if u2078.byLine then
            v1 = nil
            local v2 = nil

            for i in u2078.live, v1, v2 do
                for j, k in u2078.byLine[i] or {} do
                    u1603.paintPiece(k, idx)
                end
            end
        end

        local v3 = u2078.lines * 28.12 + 4
        v1 = math.min(v3, 92.36)
        u1642.sheet.h = v1
        u2078.contentH = v3
        u2078.viewH = v1

        if u2078.manual and u2078.manualCur ~= idx then
            u2078.manual = false
        end

        local scroll = u2078.scroll

        if not u2078.manual then
            scroll = ((u2078.stepLine and u2078.stepLine[idx] or 1) - 1) * 28.12
        end

        u1603.setSheetScroll(scroll)
        Lay.dirtyFrom(u1642.hud)
    end

    function u1603.jumpTo(a1)
        -- Line: 2163
        -- upvalues: u1805 (val), u2078 (val), autoTick (val), u1603 (val)
        -- types: a1: number
        if #u1805.steps == 0 then
            return
        end

        local v1 = math.clamp(a1, 1, #u1805.steps)
        u2078.manual = false

        if u1805.playing then
            u1805.gen = u1805.gen + 1
            u1805.idx = v1

            table.clear(u1805.got)
            autoTick(u1805.gen)

            return
        end

        if #u1805.steps == 0 then
            return
        end

        u1805.idx = math.clamp(v1, 1, #u1805.steps)
        table.clear(u1805.got)

        u1805.finished = false
        u1603.render()
    end

    function u1603.overSheet(a1) -- Line: 2177; upvalues: u1642 (val)
        local inst = u1642.sheet.inst

        if inst.Visible and u1642.hud.inst.Visible then
            local AbsolutePosition = inst.AbsolutePosition
            local AbsoluteSize = inst.AbsoluteSize
            local v1 = false

            if AbsolutePosition.X <= a1.X then
                v1 = false

                if a1.X <= AbsolutePosition.X + AbsoluteSize.X then
                    v1 = false

                    if AbsolutePosition.Y <= a1.Y then
                        v1 = a1.Y <= AbsolutePosition.Y + AbsoluteSize.Y
                    end
                end
            end

            return v1
        end

        return false
    end

    u1642.sheet.inst.InputBegan:Connect(function(a1)
        -- Line: 2184
        -- upvalues: u2078 (val), u2190 (val), u1805 (val), u1603 (val)
        local v1, v2, v3

        if a1.UserInputType ~= Enum.UserInputType.MouseButton1
            and a1.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local sb = u2078.sb
        local v4 = math.max(u2190.Scale, 0.01)

        if sb.hit.Visible then
            local AbsolutePosition = sb.hit.AbsolutePosition
            local X = a1.Position.X

            if AbsolutePosition.X - 2 <= X then
                local AbsolutePosition_2 = sb.thumb.AbsolutePosition
                local AbsoluteSize = sb.thumb.AbsoluteSize
                local Y = a1.Position.Y

                if Y < AbsolutePosition_2.Y or AbsolutePosition_2.Y + AbsoluteSize.Y < Y then
                    local v5 = math.max(1, u2078.viewH - 4)
                    v2 = AbsoluteSize.Y / v4
                    v3 = math.clamp(((Y - AbsolutePosition.Y) / v4 - v2 / 2) / math.max(1, v5 - v2), 0, 1)
                    u2078.manual = true
                    u2078.manualCur = if not u1805.finished then u1805.idx else -1

                    u1603.setSheetScroll(v3 * (u2078.contentH - u2078.viewH), true)
                end

                sb.drag = {input = a1, y0 = Y, s0 = u2078.scroll}
                u1603.setSheetScroll(u2078.scroll, true)

                return
            end
        end

        local AbsolutePosition_3 = u2078.holder.AbsolutePosition
        local v6 = (a1.Position.X - AbsolutePosition_3.X) / v4 - 4
        v4 = math.floor(((a1.Position.Y - AbsolutePosition_3.Y) / v4 - 2) / 28.12)
            + 1
        local v7 = nil
        local v8 = 6
        v2 = nil
        v3 = nil

        for i, j in u2078.toks, v2, v3 do
            if j.kind == "tok" and j.line == v4 then
                v1 = if v6 < j.x then
                    j.x - v6
                else
                    if not (j.x + j.w < v6) then 0 else v6 - j.x - j.w

                if v1 < v8 then
                    v7 = j
                    v8 = v1
                end
            end
        end

        if v7 then
            if not u1603.secPick or not u1603.secPick(v7.step) then
                u1603.jumpTo(v7.step)
            end
        end
    end)

    u1642.sheet.inst.InputChanged:Connect(function(a1) -- Line: 2220; upvalues: u2078 (val), u1805 (val), u1603 (val)
        if a1.UserInputType ~= Enum.UserInputType.MouseWheel
            or u2078.contentH <= u2078.viewH then
            return
        end

        u2078.manual = true
        u2078.manualCur = if not u1805.finished then u1805.idx else -1

        u1603.setSheetScroll(u2078.scroll - a1.Position.Z * 28.12)
    end)

    UserInputService.InputChanged:Connect(function(a1)
        -- Line: 2227
        -- upvalues: u2078 (val), u2190 (val), u1805 (val), u1603 (val)
        local drag = u2078.sb.drag

        if not drag then
            return
        end

        if a1.UserInputType ~= Enum.UserInputType.MouseMovement and a1 ~= drag.input then
            return
        end

        local v1 = math.max(u2190.Scale, 0.01)
        local v2 = math.max(1, u2078.viewH - 4)
        local v3 = u2078.sb.thumb.AbsoluteSize.Y / v1
        local v4 = math.max(1, u2078.contentH - u2078.viewH)
        local v5 = (a1.Position.Y - drag.y0) / v1
        u2078.manual = true
        u2078.manualCur = if not u1805.finished then u1805.idx else -1

        u1603.setSheetScroll(drag.s0 + v5 * v4 / math.max(1, v2 - v3), true)
    end)

    UserInputService.InputEnded:Connect(function(a1) -- Line: 2240; upvalues: u2078 (val), u1603 (val)
        local drag = u2078.sb.drag

        if drag then
            if a1 == drag.input or a1.UserInputType == Enum.UserInputType.MouseButton1 then
                u2078.sb.drag = nil
                u1603.setSheetScroll(u2078.scroll, true)
            end
        end
    end)

    function u1642.sheet.afterApply(a1) -- Line: 2247; upvalues: u2078 (val), u1603 (val)
        if 0.5 < (math.abs((a1._pw or 0) - 8 - 10 - u2078.width)) then
            u1603.buildSheet()
        end
    end

    local function renderKeys()
        -- Line: 2253
        -- upvalues: u2233 (ref), paintKey (val), u1805 (val), u1631 (val), u1755 (val), u1322 (val), NOTE (val)
        -- upvalues: u1684 (val)
        local v1 = u2233
        local v2 = nil
        local v3 = nil

        for i, j in v1, v2, v3 do
            if j.target or j.got then
                j.target = false
                j.got = false

                paintKey(j)
            end
        end

        if u1805.mode ~= "free" and not u1805.finished and #u1805.steps ~= 0 then
            local v4
            v1 = u1805.steps[u1805.idx]

            if not v1 then
                return
            end

            v3 = nil
            local v5 = nil

            for k, n in v1.keys, v3, v5 do
                v4 = if u1631.view ~= "qwerty" then
                    u1322[NOTE[n] + u1684.transpose]
                else
                    u1755[n]

                if v4 then
                    if u1805.mode ~= "practice" or not u1805.got[n] then
                        v4.target = true
                    else
                        v4.got = true
                    end

                    paintKey(v4)
                end
            end
        end
    end

    local function renderStats() -- Line: 2272; upvalues: u1805 (val), u1642 (val), u1578 (val)
        local u2 = #u1805.steps
        local u8 = if not u1805.finished then u1805.idx - 1 else u2

        u1642.stepOut:setText((string.format("%d/%d", math.min(u8 + (if not u1805.finished then 1 else 0), u2), u2)))

        function u1642.barFill.wf(a1) -- Line: 2276; upvalues: u2 (val), u8 (val); types: a1: number
            if u2 > 0 then
                return a1 * u8 / u2
            end

            return 0
        end

        u1642.barFill.w = nil

        u1642.missOut:setText((tostring(u1805.mistakes)))

        local v1 = 0
        local v2 = 0

        for i, j in u1805.res do
            v2 = v2 + 1

            if j == "ok" then
                v1 = v1 + 1
            end
        end

        local v3 = v2
        u1642.accOut:setText(if not (v3 > 0) then "—" else string.format("%d%%", (math.floor(v1 / v3 * 100 + 0.5))))
        u1642.timeOut:setText((u1578.fmtTime(if not u1805.finished then if not u1805.start then 0 else (os.clock() - u1805.start) * 1000 else u1805.elapsed)))
    end

    function u1603.render()
        -- Line: 2284
        -- upvalues: u1603 (val), renderKeys (val), renderStats (val), u1642 (val), u1805 (val), Lay (val)
        u1603.renderCue()
        renderKeys()
        u1603.paintSheet()
        renderStats()
        u1603.renderGlow()
        u1642.playBtn:show(u1805.mode == "auto")
        u1642.tempoBox:show(u1805.mode == "auto")

        if not u1642.playBtn.ico then
            u1642.playBtn.label:setText(if not u1805.playing then "▶ Play" else "❚❚ Pause")
        else
            u1642.playBtn.label:setText(if not u1805.playing then "Play" else "Pause")
            u1603.setIco(u1642.playBtn.ico, if not u1805.playing then "play-fill" else "pause")
        end

        u1642.flowBtn:show(u1805.mode == "practice")
        u1642.titleLbl:setText(if u1805.title == "" then "—" else u1805.title)
        u1642.hudTabTitle:setText(if u1805.title == "" then "Practice panel" else u1805.title)
        Lay.dirtyFrom(u1642.hud)
        Lay.flush()
    end

    task.spawn(function() -- Line: 2306; upvalues: u1805 (val), u1642 (val), u1578 (val)
        while true do
            task.wait(0.5)

            if u1805.start and not u1805.finished then
                u1642.timeOut:setText((u1578.fmtTime(((os.clock()) - u1805.start) * 1000)))
            end
        end
    end)

    local u2239 = {}
    local u2240 = 0

    function u1603.savePref(a1, a2)
        -- Line: 2316
        -- upvalues: u1603 (val), u2239 (ref), u2240 (ref), Api (val)
        -- types: a1: string
        if u1603.prefsOff then
            return
        end

        u2239[a1] = a2
        u2240 = u2240 + 1
        local u7 = u2240

        task.delay(
            2,
            function() -- Line: 2321; upvalues: u7 (val), u2240 (upval), u2239 (upval), Api (upval)
                if u7 ~= u2240 then
                    return
                end

                local u2 = u2239
                u2239 = {}
                local u4 = "saveSettings"

                if not (pcall(function() -- Line: 50; upvalues: Api (upval), u4 (val), u2 (val)
                    return Api:InvokeServer(u4, u2)
                end)) then end
            end
        )
    end

    local function setMode(a1)
        -- Line: 2330
        -- upvalues: u1805 (val), toast (val), u1603 (val), u1642 (val)
        -- types: a1: string
        local v1, v2

        if a1 == "auto" and not u1805.allowAuto then
            toast("The host turned off autoplay in this room.")
            return
        end

        if u1805.playing then
            u1805.playing = false
            u1805.gen = u1805.gen + 1
        end

        if a1 == "auto" and u1805.mode ~= "auto" and not u1603.tapTipShown then
            u1603.tapTipShown = true
            toast("Tip: tap [ or ] to play the sheet at your own pace.")
        end

        u1805.mode = a1
        local v3 = nil
        local v4 = nil

        for i, j in u1642.modeBtns, v3, v4 do
            v1 = i == a1
            j:state("on", v1)

            v2 = if not v1 then "muted" else "bg"
            j.label.c = v2

            j.label:paint()
        end

        table.clear(u1805.got)

        u1805.finished = false
        local idx = u1805.idx

        if #u1805.steps < idx then
            u1805.idx = 1
        end

        u1805.start = nil
        u1603.render()
    end

    u1603.setMode = setMode

    for i9, i10 in u1642.modeBtns do
        i10:onClick(function() -- Line: 2351; upvalues: setMode (val), i9 (val)
            setMode(i9)
        end)
    end

    u1642.playBtn:onClick(function() -- Line: 2352; upvalues: u1805 (val), u1603 (val), startAuto (val)
        if not u1805.playing then
            startAuto()
            return
        end

        u1805.playing = false
        u1805.gen = u1805.gen + 1

        u1603.render()
    end)

    u1642.flowBtn:onClick(function() -- Line: 2353; upvalues: u1805 (val), u1642 (val), u1603 (val)
        u1805.flow = not u1805.flow
        local flowBtn = u1642.flowBtn
        local flow = u1805.flow

        flowBtn:state("on", flow)

        flowBtn.label.c = if not flow then if not flowBtn.primary then "ink" else "bg" else "brassInk"
        flowBtn.label:paint()
        u1603.savePref("flow", u1805.flow)
    end)

    u1642.loopBtn:onClick(function() -- Line: 2358; upvalues: u1805 (val), u1642 (val)
        u1805.loop = not u1805.loop
        local loopBtn = u1642.loopBtn
        local loop = u1805.loop

        loopBtn:state("on", loop)

        loopBtn.label.c = if not loop then if not loopBtn.primary then "ink" else "bg" else "brassInk"
        loopBtn.label:paint()
    end)

    u1642.restartBtn:onClick(restart)

    u1603.restart = restart

    local function setHudMin(a1) -- Line: 2361; upvalues: u1631 (val), u1642 (val), u1603 (val); types: a1: boolean
        u1631.hudMin = a1
        u1642.hrow2:show(not a1)
        u1642.bar:show(not a1)
        u1642.sheet:show(not a1)
        u1603.iconOr(u1642.minBtn, if not a1 then "chevron-up" else "chevron-down", if not a1 then "▴" else "▾")
    end

    u1642.minBtn:onClick(function() -- Line: 2368; upvalues: setHudMin (val), u1631 (val)
        setHudMin(not u1631.hudMin)
    end)

    local function placeTab() -- Line: 2371; upvalues: u1642 (val)
        local abs = u1642.hud.abs

        if abs.l and u1642.main.lw then
            local v1 = u1642.main.lw - 2
            local v2 = u1642.hud.lw or 780
            u1642.hudTab.abs = {
                cx = true,
                clamp = true,
                t = abs.t,
                dx = abs.l + v2 / 2 - v1 / 2,
            }

            return
        end

        u1642.hudTab.abs = {t = 62, cx = true, clamp = true}
    end

    function u1603.setHudOpen(a1, a2)
        -- Line: 2381
        -- upvalues: u1631 (val), u1805 (val), setMode (val), placeTab (val), u1642 (val), u1603 (val)
        -- types: a1: boolean, a2: boolean?
        u1631.hudOpen = a1

        if a1 then
            local v1 = u1631.modeBeforeClose or "practice"

            if v1 == "auto" and not u1805.allowAuto then
                v1 = "practice"
            end

            setMode(v1)
        else
            if u1805.mode ~= "free" then
                u1631.modeBeforeClose = u1805.mode
            end

            setMode("free")
        end

        placeTab()
        u1642.hud:show(a1)
        u1642.hudTab:show(not a1)

        if not a2 then
            u1603.savePref("hud", a1)
        end
    end

    u1642.closeBtn:onClick(function() -- Line: 2396; upvalues: u1603 (val)
        u1603.setHudOpen(false)
    end)

    function u1642.hud.limitY() -- Line: 2398; upvalues: u1642 (val)
        return u1642.stage.lh_ or 1000000000
    end

    u1642.hudTab.limitY = u1642.hud.limitY

    u1642.hudTab:onClick(function() -- Line: 2400; upvalues: u1603 (val)
        u1603.setHudOpen(true)
    end)

    local u2317 = nil
    local u2318 = 0

    local function begin(a1) -- Line: 2406; upvalues: u2317 (ref), u1642 (val); types: a1: userdata
        if a1.UserInputType ~= Enum.UserInputType.MouseButton1
            and a1.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        u2317 = {
            moved = false,
            input = a1,
            sx = a1.Position.X,
            sy = a1.Position.Y,
            x = (u1642.hud.lx or 0) - 1,
            y = (u1642.hud.ly or 0) - 1,
        }
    end

    u1642.hud.inst.InputBegan:Connect(function(a1)
        -- Line: 2410
        -- upvalues: u1603 (val), u2318 (ref), u2317 (ref), u1642 (val), u1631 (val), Lay (val), begin (val)
        if u1603.overSheet(a1.Position) then
            return
        end

        if a1.UserInputType == Enum.UserInputType.MouseButton1 then
            local v1 = os.clock()

            if v1 - u2318 < 0.35 then
                u2318 = 0
                u2317 = nil
                u1642.hud.abs = {t = 62, cx = true, clamp = true}
                u1631.hudPos = nil

                u1603.savePref("hudPos", false)
                Lay.dirty()

                return
            end

            u2318 = v1
        end

        begin(a1)
    end)

    u1642.titleBtn.inst.InputBegan:Connect(begin)

    UserInputService.InputChanged:Connect(function(a1)
        -- Line: 2428
        -- upvalues: u2317 (ref), u2190 (val), u1642 (val), Lay (val)
        if not u2317 then
            return
        end

        if a1.UserInputType ~= Enum.UserInputType.MouseMovement and a1 ~= u2317.input then
            return
        end

        local v1 = math.max(u2190.Scale, 0.01)
        local v2 = (a1.Position.X - u2317.sx) / v1
        local v3 = (a1.Position.Y - u2317.sy) / v1

        if not u2317.moved and (math.abs(v2)) + math.abs(v3) < 4 then
            return
        end

        u2317.moved = true
        u1642.hudDragAt = os.clock()
        u1642.hud.abs = {clamp = true, l = u2317.x + v2, t = u2317.y + v3}

        Lay.dirty()
    end)

    UserInputService.InputEnded:Connect(function(a1)
        -- Line: 2439
        -- upvalues: u2317 (ref), u1642 (val), Lay (val), u1631 (val), u1603 (val)
        if not u2317 then
            return
        end

        if a1 ~= u2317.input and a1.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        if u2317.moved then
            u1642.hudDragAt = os.clock()
            Lay.now()

            u1631.hudPos = {
                x = math.floor((u1642.hud.lx or 1) - 1 + 0.5),
                y = math.floor((u1642.hud.ly or 1) - 1 + 0.5),
            }
            u1642.hud.abs = {clamp = true, l = u1631.hudPos.x, t = u1631.hudPos.y}

            u1603.savePref("hudPos", u1631.hudPos)
        end

        u2317 = nil
    end)

    local function v45(a1) -- Line: 2453; upvalues: u1684 (val), u1642 (val), u1603 (val); types: a1: number
        u1684.transpose = math.clamp(a1, -12, 12)
        u1642.trOut:setText(if not (0 < u1684.transpose) then tostring(u1684.transpose) else "+" .. u1684.transpose)
        u1603.layoutPiano()
        u1603.render()
    end

    u1642.trUp:onClick(function() -- Line: 2460; upvalues: u1684 (val), u1642 (val), u1603 (val)
        u1684.transpose = math.clamp(u1684.transpose + 1, -12, 12)
        u1642.trOut:setText(if not (0 < u1684.transpose) then tostring(u1684.transpose) else "+" .. u1684.transpose)
        u1603.layoutPiano()
        u1603.render()
    end)

    u1642.trDown:onClick(function() -- Line: 2461; upvalues: u1684 (val), u1642 (val), u1603 (val)
        u1684.transpose = math.clamp(u1684.transpose - 1, -12, 12)
        u1642.trOut:setText(if not (0 < u1684.transpose) then tostring(u1684.transpose) else "+" .. u1684.transpose)
        u1603.layoutPiano()
        u1603.render()
    end)

    local function v46(a1, a2)
        -- Line: 2463
        -- upvalues: u1684 (val), u1642 (val), setSustain (val), u1603 (val)
        -- types: a1: boolean, a2: boolean?
        u1684.pedalDefault = a1
        u1642.susBtn.set(a1)

        if u1642.setPedalCheck then
            u1642.setPedalCheck(a1)
        end

        local v1 = u1684.pedalDefault ~= u1684.spaceDown

        if v1 ~= u1684.sustain then
            setSustain(v1)
        end

        if not a2 then
            u1603.savePref("pedal", a1)
        end
    end

    u1642.susBtn:onClick(function() -- Line: 2470; upvalues: u1684 (val), u1642 (val), setSustain (val), u1603 (val)
        local v1 = not u1684.pedalDefault
        u1684.pedalDefault = v1

        u1642.susBtn.set(v1)

        if u1642.setPedalCheck then
            u1642.setPedalCheck(v1)
        end

        local v2 = u1684.pedalDefault ~= u1684.spaceDown

        if v2 ~= u1684.sustain then
            setSustain(v2)
        end

        u1603.savePref("pedal", v1)
    end)

    local function v47(a1, a2)
        -- Line: 2472
        -- upvalues: u1631 (val), u1642 (val), u1603 (val)
        -- types: a1: boolean, a2: boolean?
        u1631.names = a1

        if u1642.setNamesCheck then
            u1642.setNamesCheck(a1)
        end

        u1603.layoutPiano()

        if not a2 then
            u1603.savePref("names", a1)
        end
    end

    u1603.Sfx = require(VP:WaitForChild("Sfx"))
    u1631.sfx = u1603.Sfx.clean(u1603.Sfx.DEFAULT)
    u1631.sfxSlots = {}
    u1631.ifav = {}

    function u1603.applySfx(a1)
        -- Line: 2483
        -- upvalues: Audio (val), u1631 (val), u1642 (val), u1603 (val)
        -- types: a1: boolean?
        Audio.setEffects(u1631.sfx)
        u1642.revBtn.set(u1603.Sfx.anyOn(u1631.sfx))

        if not a1 then
            u1603.savePref("sfx", u1631.sfx)
        end
    end

    u1642.revBtn:onClick(function() -- Line: 2488; upvalues: u1603 (val)
        u1603.openSfx()
    end)

    local u2388 = nil

    local function closePopup() -- Line: 2492; upvalues: u2388 (ref), Lay (val)
        if u2388 then
            u2388:destroy()

            u2388 = nil
            Lay.dirty()
        end
    end

    u1603.closePopup = closePopup

    function u1603.at(a1) -- Line: 2501; upvalues: u1642 (val)
        local Scale = u1642.layerScale.Scale
        local AbsolutePosition = u1642.layer.inst.AbsolutePosition
        local AbsolutePosition_2 = a1.inst.AbsolutePosition

        return (AbsolutePosition_2.X - AbsolutePosition.X) / Scale,
            (AbsolutePosition_2.Y - AbsolutePosition.Y) / Scale
    end

    local function openMenu(a1, a2, a3, a4)
        -- Line: 2506
        -- upvalues: u2388 (ref), Lay (val), box (val), u1642 (val)
        -- types: a1: number, a2: number, a3: number, a4: number?
        if u2388 then
            u2388:destroy()

            u2388 = nil
            Lay.dirty()
        end

        local v1 = box({
            dir = "col",
            gap = 4,
            pad = 8,
            bg = "panel2",
            bd = 1,
            bdc = "line",
            r = 12,
            z = 40,
            button = true,
            w = a3,
            abs = {l = a1, t = a2, flip = a4, clamp = a4 ~= nil},
            shadow = {img = "sh60", blur = 50, y = 18},
            parent = u1642.layer,
        })
        u2388 = v1

        Lay.dirty()

        return v1
    end

    UserInputService.InputBegan:Connect(function(a1)
        -- Line: 2514
        -- upvalues: u2388 (ref), u1603 (val), closePopup (val)
        if u2388 and not u1603.vrOn then
            if a1.UserInputType ~= Enum.UserInputType.MouseButton1
                and a1.UserInputType ~= Enum.UserInputType.Touch then
                return
            end

            local Position = a1.Position
            local AbsolutePosition = u2388.inst.AbsolutePosition
            local AbsoluteSize = u2388.inst.AbsoluteSize
            local v1 = false

            if AbsolutePosition.X <= Position.X then
                v1 = false

                if Position.X <= AbsolutePosition.X + AbsoluteSize.X then
                    v1 = false

                    if AbsolutePosition.Y <= Position.Y then
                        v1 = Position.Y <= AbsolutePosition.Y + AbsoluteSize.Y
                    end
                end
            end

            local anchor = u2388.anchor

            if anchor then
                local AbsolutePosition_2 = anchor.inst.AbsolutePosition
                local AbsoluteSize_2 = anchor.inst.AbsoluteSize

                if AbsolutePosition_2.X <= Position.X
                    and Position.X <= AbsolutePosition_2.X + AbsoluteSize_2.X
                    and AbsolutePosition_2.Y <= Position.Y
                    and Position.Y <= AbsolutePosition_2.Y + AbsoluteSize_2.Y then
                    v1 = true
                end
            end

            if not v1 then
                task.defer(closePopup)
            end
        end
    end)

    local function menuItem(a1, a2, a3, a4)
        -- Line: 2529
        -- upvalues: box (val), text (val), u2388 (ref), Lay (val)
        -- types: a2: string, a3: boolean, a4: function
        local v1 = box({
            dir = "row",
            align = "center",
            gap = 8,
            r = 8,
            button = true,
            pad = {7, 8},
            bg = if not a3 then nil else "brassSoft",
            hov = if not a3 then {bg = "white05"} else nil,
            parent = a1,
        })

        if not a3 then
            v1:bindHover()
        end

        v1.nm = text({
            f = "s500_14",
            lh = 20.3,
            grow = 1,
            shrink0 = true,
            ell = true,
            t = a2,
            parent = v1,
        })
        v1:onClick(function() -- Line: 2534; upvalues: u2388 (upval), Lay (upval), a4 (val)
            if u2388 then
                u2388:destroy()

                u2388 = nil
                Lay.dirty()
            end

            a4()
        end)

        return v1
    end

    local function tag(a1, a2, a3)
        -- Line: 2537
        -- upvalues: Lay (val), box (val), text (val)
        -- types: a2: string, a3: string?
        return box({
            pad = {1, 5},
            r = 4,
            bg = if a3 == "me" then
                "tagMe"
            else
                if a3 == "host" then
                    "brassSoft"
                else
                    if a3 == "admin" or a3 == "bad" then
                        "badSoft"
                    else
                        if a3 ~= "ok" then "white07" else {a = 0.16, c = Lay.TH.ok.c},
            noShrink = true,
            parent = a1,
            {
                text({
                    f = "m600_8_96",
                    up = true,
                    ls = 0.5376,
                    t = a2,
                    c = if a3 ~= "me" then
                        if a3 ~= "host" then
                            if a3 == "admin" then
                                "bad"
                            else
                                if a3 ~= "bad" then if a3 ~= "ok" then "muted" else "ok" else "bad"
                        else
                            "brassInk"
                    else
                        "tagMeInk",
                }),
            },
        })
    end

    local function v48(a1, a2)
        -- Line: 2545
        -- upvalues: Audio (val), u1684 (val), u1642 (val), u1603 (val)
        -- types: a1: string, a2: boolean?
        local v1 = Audio.byKey[a1]

        if not v1 or v1.id == "" then
            v1 = Audio.list[1]
        end

        u1684.instr = v1.key
        u1642.instrLbl:setText(v1.name)
        Audio.load(v1.key)

        if not a2 then
            u1603.savePref("instr", v1.key)
        end
    end

    u1642.instrSel:onClick(function()
        -- Line: 2553
        -- upvalues: u2388 (ref), u1642 (val), Lay (val), openMenu (val), Audio (val), menuItem (val), u1684 (val)
        -- upvalues: u1603 (val)
        if u2388 and u2388.anchor == u1642.instrSel then
            if u2388 then
                u2388:destroy()

                u2388 = nil
                Lay.dirty()
            end

            return
        end

        local v1 = u1642.instrSel.ax or 0
        local v2 = (u1642.instrSel.ay or 0) + (u1642.instrSel.lh_ or 20) + 4
        local v3 = openMenu(v1 - 8, v2, 220)
        v3.anchor = u1642.instrSel
        local v4 = nil
        local v5 = nil

        for i, j in Audio.list, v4, v5 do
            if j.core then
                menuItem(
                    v3,
                    j.name,
                    j.key == u1684.instr,
                    function()
                        -- Line: 2559
                        -- upvalues: j (val), Audio (upval), u1684 (upval), u1642 (upval), u1603 (upval)
                        local key = j.key
                        local v1 = Audio.byKey[key]

                        if not v1 or v1.id == "" then
                            v1 = Audio.list[1]
                        end

                        u1684.instr = v1.key
                        u1642.instrLbl:setText(v1.name)
                        Audio.load(v1.key)
                        u1603.savePref("instr", v1.key)
                    end
                )
            end
        end

        v2 = Audio.byKey[u1684.instr]

        if v2 and not v2.core then
            menuItem(
                v3,
                v2.name,
                true,
                function() -- Line: 2562
                end
            )
        end

        v2 = menuItem(
            v3,
            "More sound fonts…",
            false,
            function() -- Line: 2563; upvalues: u1603 (upval)
                u1603.openSoundFonts()
            end
        )
        v2.nm.c = "brassInk"

        v2.nm:paint()
    end)

    u1603.setInstrument = v48
    u1642.tempoCapBtn:onClick(function()
        -- Line: 2569
        -- upvalues: u2388 (ref), u1642 (val), Lay (val), openMenu (val), eyebrow (val), u1805 (val), u1603 (val)
        local u48

        if u2388 and u2388.anchor == u1642.tempoCapBtn then
            if u2388 then
                u2388:destroy()

                u2388 = nil
                Lay.dirty()
            end

            return
        end

        local v1 = openMenu((u1642.tempoCapBtn.ax or 0) - 8, (u1642.tempoCapBtn.ay or 0) + 14, 150)
        v1.anchor = u1642.tempoCapBtn

        v1:add(
            (eyebrow(
                "BPM (1–500)",
                {m = {2, 4, 0, 4}}
            ))
        )

        _, u48 = input(v1, (tostring(u1805.bpm)))
        u48.Text = tostring(u1805.bpm)

        u48.FocusLost:Connect(function() -- Line: 2576; upvalues: u48 (val), u1603 (upval), u2388 (upval), Lay (upval)
            local v1 = tonumber((string.match(u48.Text, "%d+")))

            if v1 then
                u1603.setBpm(v1)
            end

            if u2388 then
                u2388:destroy()

                u2388 = nil
                Lay.dirty()
            end
        end)

        task.defer(function() -- Line: 2581; upvalues: u48 (val)
            u48:CaptureFocus()

            u48.SelectionStart = 1
            u48.CursorPosition = #u48.Text + 1
        end)
    end)

    task.spawn(function() -- Line: 2583; upvalues: Audio (val), u1684 (val), u1642 (val)
        local v1

        while true do
            task.wait(0.4)

            v1 = Audio.loading(u1684.instr)
            u1642.loadOut:setText(if not v1 then "" else "loading…")
            u1642.loadOut:show(v1)
        end
    end)

    function u1603.closeDialog() -- Line: 2593; upvalues: u1642 (val), Lay (val)
        if u1642.dialog then
            u1642.overlay:destroy()

            u1642.overlay = nil
            u1642.dialog = nil

            Lay.dirty()
        end
    end

    local function openDialog(a1, a2, a3)
        -- Line: 2601
        -- upvalues: u1603 (val), u2388 (ref), Lay (val), box (val), u1642 (val), text (val)
        -- types: a1: string, a2: boolean?, a3: number?
        u1603.closeDialog()

        if u2388 then
            u2388:destroy()

            u2388 = nil
            Lay.dirty()
        end

        local v1 = box({
            dir = "col",
            align = "center",
            justify = "center",
            pad = 16,
            bg = "overlay",
            z = 60,
            button = true,
            abs = {l = 0, t = 0, r = 0, b = 0},
            parent = u1642.layer,
        })
        local v2 = box({
            dir = "col",
            gap = 12,
            bg = "panel",
            bd = 1,
            bdc = "line",
            r = 14,
            z = 61,
            clip = true,
            button = true,
            self = "center",
            pad = {18, 20},
            wf = function(a1) -- Line: 2606; upvalues: a2 (val); types: a1: number
                return (math.min(if not a2 then 560 else 660, a1))
            end,
            shadow = {img = "sh60", blur = 60, y = 20},
            parent = v1,
        })

        if a3 then
            function v2.hf(a1) -- Line: 2608; upvalues: a3 (val); types: a1: number?
                return (math.min(a3, a1 or a3))
            end
        end

        local v3 = box({
            dir = "row",
            justify = "between",
            align = "center",
            gap = 12,
            parent = v2,
        })
        local v4 = text({f = "d600_20", lh = 24, t = a1, parent = v3})

        ;(box({
            pad = {2, 6},
            r = 6,
            button = true,
            noShrink = true,
            parent = v3,
            {(text({t = "×", f = "s400_22_4", lh = 22.4, c = "muted"}))},
        })):onClick(u1603.closeDialog)

        v1:onClick(u1603.closeDialog)

        u1642.overlay = v1
        u1642.dialog = v2
        v2.title = v4

        Lay.dirty()

        return v2
    end

    u1603.openDialog = openDialog

    local function field(a1, a2, a3)
        -- Line: 2621
        -- upvalues: box (val), eyebrow (val)
        -- types: a2: string, a3: boolean?
        local v1 = box({
            dir = "col",
            gap = 5,
            grow = if not a3 then 0 else 1,
            vshrink = a3,
            parent = a1,
        })
        v1:add(
            (eyebrow(
                a2,
                {ls = 0.8192}
            ))
        )

        return v1
    end

    local function input_2(a1, a2, a3)
        -- Line: 2626
        -- upvalues: box (val), Glyph (val), u1642 (val), Lay (val)
        -- types: a2: string, a3: table?
        local v1 = a3 or {}
        local v2 = v1.multi == true
        local v3 = box({
            bg = "field",
            bd = 1,
            bdc = "line",
            r = 8,
            h = v1.h or 38.3,
            grow = if not v1.grow then 0 else 1,
            vshrink = v1.grow,
            parent = a1,
        })
        local u29 = Instance.new("TextBox")
        u29.BackgroundTransparency = 1
        u29.Position = UDim2.fromOffset(10, if not v2 then 0 else 8)
        local v4 = if not v2 then UDim2.new(1, -20, 1, 0) else UDim2.new(1, -20, 1, -16)
        u29.Size = v4
        local u82 = nil

        if v2 then
            local ScrollingFrame = Instance.new("ScrollingFrame")
            ScrollingFrame.BackgroundTransparency = 1
            ScrollingFrame.BorderSizePixel = 0
            ScrollingFrame.Position = UDim2.fromOffset(2, 2)
            ScrollingFrame.Size = UDim2.new(1, -4, 1, -4)
            ScrollingFrame.CanvasSize = UDim2.new()
            ScrollingFrame.ScrollBarThickness = 6
            ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            ScrollingFrame.ZIndex = 69
            ScrollingFrame.Parent = v3.inst
            u82 = ScrollingFrame
            u29.Position = UDim2.fromOffset(8, 6)
            u29.Size = UDim2.new(1, -20, 0, 0)

            ScrollingFrame.InputBegan:Connect(function(a1) -- Line: 2650; upvalues: u29 (val)
                if a1.UserInputType == Enum.UserInputType.MouseButton1 and not u29:IsFocused() then
                    u29:CaptureFocus()
                end
            end)
        end

        u29.ClearTextOnFocus = false
        u29.Text = ""
        u29.PlaceholderText = a2
        u29.MultiLine = v2
        u29.TextWrapped = v2

        if not v2 then
            Glyph.fitInput(u29, "s400_14")
        else
            u29.FontFace = Font.fromEnum(Enum.Font.RobotoMono)
        end

        u29.TextSize = if not v2 then Glyph.nativeSize("s400_14") else 15
        u29.TextXAlignment = Enum.TextXAlignment.Left
        u29.TextYAlignment = if not v2 then
            Enum.TextYAlignment.Center
        else
            Enum.TextYAlignment.Top
        u29.ClipsDescendants = true
        u29.ZIndex = 70
        local inst = u82 or v3.inst
        u29.Parent = inst

        if u82 then
            local u151 = game:GetService("TextService")
            local u152 = 0

            local function fit() -- Line: 2670; upvalues: u1642 (upval), u29 (val), u151 (val), u152 (ref), u82 (ref)
                local v1 = math.max(u1642.layerScale.Scale, 0.01)
                local u9 = u29.AbsoluteSize.X / v1

                if u9 <= 0 then
                    return
                end

                local success, err = pcall(function() -- Line: 2674; upvalues: u151 (upval), u29 (upval), u9 (val)
                    return u151:GetTextSize(u29.Text .. "\n", u29.TextSize, Enum.Font.RobotoMono, (Vector2.new(u9, 1000000)))
                end)
                local v2 = if not success then 0 else err.Y + 4
                v1 = math.max(u152, v2)
                u29.Size = UDim2.new(1, -20, 0, v1)
                u82.CanvasSize = UDim2.fromOffset(0, v1 + 12)
            end

            function v3.afterApply(a1) -- Line: 2681; upvalues: u152 (ref), fit (val)
                u152 = math.max(0, (a1._ph or 0) - 16)
                fit()
            end

            ;(u29:GetPropertyChangedSignal("Text")):Connect(fit)

            ;(u29:GetPropertyChangedSignal("AbsoluteSize")):Connect(function() -- Line: 2686; upvalues: fit (val)
                task.defer(fit)
            end)

            ;(u29:GetPropertyChangedSignal("CursorPosition")):Connect(function()
                -- Line: 2687
                -- upvalues: u29 (val), u1642 (upval), u151 (val), u82 (ref)
                local CursorPosition = u29.CursorPosition

                if CursorPosition < 1 then
                    return
                end

                local v1 = math.max(u1642.layerScale.Scale, 0.01)
                local u12 = u29.AbsoluteSize.X / v1

                if u12 <= 0 then
                    return
                end

                local success, err = pcall(function()
                    -- Line: 2693
                    -- upvalues: u151 (upval), u29 (upval), CursorPosition (val), u12 (val)
                    return u151:GetTextSize((string.sub(u29.Text, 1, CursorPosition - 1)) .. "|", u29.TextSize, Enum.Font.RobotoMono, (Vector2.new(u12, 1000000)))
                end)

                if not success then
                    return
                end

                local v2 = err.Y + 6 + 4
                local v3 = v2 - u29.TextSize * 1.3 - 8
                local v4 = u82.AbsoluteWindowSize.Y / v1
                local Y = u82.CanvasPosition.Y

                if Y + v4 < v2 then
                    u82.CanvasPosition = Vector2.new(0, v2 - v4)
                    return
                end

                if v3 < Y then
                    u82.CanvasPosition = Vector2.new(0, (math.max(0, v3)))
                end
            end)
        end

        function v3.onPaint() -- Line: 2705; upvalues: u29 (val), Lay (upval), u82 (ref)
            u29.TextColor3 = Lay.TH.ink.c
            u29.PlaceholderColor3 = Lay.TH.dim.c

            if u82 then
                u82.ScrollBarImageColor3 = Lay.TH.muted.c
            end
        end

        v3:paint()

        v3.tb = u29

        return v3, u29
    end

    local function statusLine(a1) -- Line: 2714; upvalues: text (val)
        local u4 = text({
            t = "",
            f = "s400_13_12",
            c = "muted",
            wrap = true,
            minH = 14.432,
            lh = 19.023999999999997,
            parent = a1,
        })
        return function(a1, a2) -- Line: 2716; upvalues: u4 (val); types: a1: string, a2: boolean?
            u4.c = if not a2 then "muted" else "bad"
            u4:setText(a1)
            u4:paint()
        end
    end

    local function armButton(a1, a2, a3, a4) -- Line: 2722; types: a2: string, a3: string, a4: function
        local u4 = false
        a1:onClick(function() -- Line: 2724; upvalues: u4 (ref), a1 (val), a3 (val), a2 (val), a4 (val)
            if u4 then
                u4 = false
                a4()

                return
            end

            u4 = true
            a1:state("arm", true)
            a1.label:setText(a3)

            task.delay(
                3,
                function() -- Line: 2729; upvalues: u4 (upval), a1 (upval), a2 (upval)
                    if u4 then
                        u4 = false
                        a1:state("arm", false)

                        local v1 = a2
                        a1.label:setText(v1)
                    end
                end
            )
        end)
    end

    local u2423 = ""

    function u1603.levelText(a1, a2, a3)
        -- Line: 2762
        -- upvalues: text (val), Levels (val)
        -- types: a2: string, a3: number
        return text({runs = Levels.runs(a1.name), f = a2, lh = a3})
    end

    function u1603.levelChip(a1, a2, a3) -- Line: 2766; upvalues: Levels (val); types: a3: boolean
        local v1 = Levels.at(a2, 0.5)
        a1.bdc = if not a3 then "line" else {a = 1, c = v1}
        a1.bg = if not a3 then "panel2" else {a = 0.18, c = v1}

        a1:paint()
    end

    local function levelBadge(a1) -- Line: 2773; upvalues: Levels (val), box (val), u1603 (val); types: a1: string?
        local v1 = Levels.get(a1)

        if not v1 then
            return nil
        end

        return box({
            pad = {0, 6},
            r = 4,
            bd = 1,
            bdc = "line",
            bg = "panel2",
            noShrink = true,
            {u1603.levelText(v1, "s500_12_8", 16)},
        })
    end

    local function fmtRating(a1) -- Line: 2778; upvalues: u3710 (val); types: a1: string
        local v1 = u3710.ratings[a1]

        if type(v1) == "table" and not ((v1.n or 0) <= 0) then
            return string.format("%.1f from %d vote%s", v1.s / v1.n, v1.n, if v1.n ~= 1 then "s" else "")
        end

        return "No ratings yet"
    end

    local function avgRating(a1) -- Line: 2783; upvalues: u3710 (val); types: a1: string
        local v1 = u3710.ratings[a1]

        if type(v1) == "table" and not ((v1.n or 0) <= 0) then
            return v1.s / v1.n, v1.n
        end

        return 0, 0
    end

    function u1603.loadCommunity(a1) -- Line: 2789; upvalues: u3710 (val), Api (val); types: a1: boolean?
        local v1

        if not a1 and os.clock() - u3710.at < 20 and 0 < u3710.at then
            return
        end

        u3710.at = os.clock()
        local stamp = u3710.stamp
        local u15 = "community"
        local success, err = pcall(function() -- Line: 50; upvalues: Api (upval), u15 (val), stamp (val)
            return Api:InvokeServer(u15, stamp)
        end)

        if type(if success then err else nil) ~= "table" then
            u3710.at = 0
            return
        end

        if v1.same ~= true then
            local v2
            u3710.index = if type(v1.index) ~= "table" then {} else v1.index
            local ver = u3710.ver or {}
            u3710.ver = ver
            local v3 = nil
            local v4 = nil

            for i, j in u3710.index, v3, v4 do
                v2 = tonumber(j.v) or 0

                if (u3710.ver[j.id] or 0) ~= v2 then
                    u3710.texts[j.id] = nil
                end

                u3710.ver[j.id] = v2
            end
        end

        u3710.stamp = if type(v1.stamp) ~= "string" then nil else v1.stamp
        u3710.ready = true
        u3710.stars = if type(v1.stars) ~= "table" then {} else v1.stars
        u3710.ratings = if type(v1.ratings) ~= "table" then {} else v1.ratings
    end

    task.spawn(function() -- Line: 2813; upvalues: u3710 (val), u1642 (val), Lay (val)
        local libLoading
        local v1 = 0

        while not u3710.ready do
            task.wait(0.4)

            v1 = (v1 + 1) % 4
            libLoading = u1642.libLoading

            if libLoading and libLoading.inst and libLoading.inst.Parent then
                libLoading:setText("Loading sheets" .. (string.rep(" .", v1)))
                Lay.dirty()
            end
        end
    end)

    local function loadSheet(a1, a2, a3, a4)
        -- Line: 2822
        -- upvalues: u1805 (val), u1578 (val), u1603 (val), u3682 (ref), Sheets (val), u3710 (val), u1631 (val)
        -- upvalues: buildOwner (val), restart (val), u2423 (ref)
        -- types: a1: string, a2: string, a3: string, a4: number?
        local bpm, index, index_2, pubId_2, v1, v2, v3, v4, v5, v6, v7, v8, v9
        local dispatch = 0

        while true do
            if dispatch < 31 then
                if dispatch < 18 then
                    if dispatch < 4 then
                        if dispatch < 2 then
                            if dispatch < 1 then
                                u1805.text = a2
                                u1805.title = a1
                                v6, v7 = u1578.parse(a2)
                                u1805.steps = v6
                                u1805.comments = v7
                                u1805.activeId = a3
                                dispatch = if not u1603.secClear then 2 else 1
                            else
                                u1603.secClear()

                                dispatch = 2
                            end
                        elseif dispatch < 3 then
                            dispatch = if not u1603.onSheet then 4 else 3
                        else
                            u1603.onSheet(a3)

                            dispatch = 4
                        end
                    elseif dispatch < 12 then
                        if dispatch < 8 then
                            v5 = u3682
                            v6 = nil
                            v7 = nil
                            local dispatchExit = nil

                            for i22, i23 in v5, v6, v7 do
                                local dispatch2 = 5

                                while true do
                                    if not (dispatch2 < 6) then
                                        v4 = i23
                                        dispatchExit = 13
                                        break
                                    end

                                    if i23.id ~= a3 then
                                        break
                                    else
                                        dispatch2 = 6
                                    end
                                end

                                if dispatchExit then
                                    break
                                end
                            end

                            dispatch = if dispatchExit == 13 then 13 else 8
                        else
                            v5 = Sheets
                            v6 = nil
                            v7 = nil
                            local dispatchExit2 = nil

                            for i24, i25 in v5, v6, v7 do
                                local dispatch3 = 9

                                while true do
                                    if not (dispatch3 < 10) then
                                        v4 = i25
                                        dispatchExit2 = 13
                                        break
                                    end

                                    if i25.id ~= a3 then
                                        break
                                    else
                                        dispatch3 = 10
                                    end
                                end

                                if dispatchExit2 then
                                    break
                                end
                            end

                            dispatch = if dispatchExit2 == 13 then 13 else 12
                        end
                    elseif dispatch < 13 then
                        v4 = nil
                        dispatch = 13
                    elseif dispatch < 17 then
                        index = u3710.index
                        v7 = nil
                        v8 = nil
                        local dispatchExit3 = nil

                        for i26, i27 in index, v7, v8 do
                            local dispatch4 = 14

                            while true do
                                if not (dispatch4 < 15) then
                                    v5 = i27
                                    dispatchExit3 = 18
                                    break
                                end

                                if i27.id ~= a3 then
                                    break
                                else
                                    dispatch4 = 15
                                end
                            end

                            if dispatchExit3 then
                                break
                            end
                        end

                        dispatch = if dispatchExit3 == 18 then 18 else 17
                    else
                        v5 = nil
                        dispatch = 18
                    end
                elseif dispatch < 26 then
                    if dispatch < 20 then
                        dispatch = if dispatch < 19 then
                            if v5 then 28 else 19
                        else
                            if not v4 then 27 else 20
                    elseif dispatch < 21 then
                        dispatch = if type(v4.pubId) ~= "string" then 27 else 21
                    elseif dispatch < 25 then
                        pubId_2 = v4.pubId
                        index_2 = u3710.index
                        v8 = nil
                        v9 = nil
                        local dispatchExit4 = nil

                        for i28, i29 in index_2, v8, v9 do
                            local dispatch5 = 22

                            while true do
                                if not (dispatch5 < 23) then
                                    v5 = i29
                                    dispatchExit4 = 26
                                    break
                                end

                                if i29.id ~= pubId_2 then
                                    break
                                else
                                    dispatch5 = 23
                                end
                            end

                            if dispatchExit4 then
                                break
                            end
                        end

                        dispatch = if dispatchExit4 == 26 then 26 else 25
                    else
                        v5 = nil
                        dispatch = 26
                    end
                elseif dispatch < 28 then
                    if dispatch < 27 then
                        dispatch = if v5 then 28 else 27
                    else
                        v5 = nil
                        dispatch = 28
                    end
                elseif dispatch < 29 then
                    bpm = a4
                    dispatch = if bpm then 33 else 29
                elseif dispatch < 30 then
                    dispatch = if not v4 then 31 else 30
                else
                    bpm = v4.bpm
                    dispatch = if bpm then 33 else 31
                end
            elseif dispatch < 40 then
                if dispatch < 35 then
                    if dispatch < 33 then
                        if dispatch < 32 then
                            bpm = v5
                            dispatch = if not bpm then 33 else 32
                        else
                            bpm = v5.bpm
                            dispatch = 33
                        end
                    elseif dispatch < 34 then
                        v3 = bpm
                        v6 = u1805
                        dispatch = if type(v3) ~= "number" then 35 else 34
                    else
                        v7 = v3
                        dispatch = 36
                    end
                elseif dispatch < 37 then
                    if dispatch < 36 then
                        v7 = nil
                        dispatch = 36
                    else
                        v6.sheetBpm = v7
                        dispatch = if not u1805.sheetBpm then 38 else 37
                    end
                elseif dispatch < 38 then
                    u1603.setBpm(u1805.sheetBpm, false, true)

                    dispatch = 38
                elseif dispatch < 39 then
                    if not u1631.profileReady then
                        v2 = a3
                        dispatch = 50
                    else
                        dispatch = 39
                    end
                elseif a3 == "tmp" then
                    v2 = a3
                    dispatch = 50
                else
                    dispatch = 40
                end
            elseif dispatch < 49 then
                if dispatch < 46 then
                    if not (dispatch < 41) then
                        local dispatchExit5 = nil
                        v2, v1 = a3, a1

                        for i30 = #u1631.hist, 1, -1 do
                            local dispatch6 = 42

                            while true do
                                if dispatch6 < 43 then
                                    dispatch6 = if u1631.hist[i30].id == v2 then 44 else 43
                                else
                                    if not (dispatch6 < 44) then
                                        table.remove(u1631.hist, i30)
                                        break
                                    end

                                    if not u1631.hist[i30].text then
                                        break
                                    else
                                        dispatch6 = 44
                                    end
                                end
                            end

                            if dispatchExit5 then
                                break
                            end
                        end

                        if not dispatchExit5 then end

                        dispatch = 46
                    elseif a3 == "" then
                        v2 = a3
                        dispatch = 50
                    else
                        dispatch = 41
                    end
                elseif dispatch < 47 then
                    table.insert(
                        u1631.hist,
                        1,
                        {id = v2, title = string.sub(v1, 1, 80)}
                    )

                    dispatch = 47
                elseif dispatch < 48 then
                    dispatch = if not (#u1631.hist > 15) then 49 else 48
                else
                    table.remove(u1631.hist)

                    dispatch = 47
                end
            elseif dispatch < 51 then
                if dispatch < 50 then
                    u1603.savePref("hist", u1631.hist)

                    dispatch = 50
                else
                    buildOwner()
                    u1603.buildSheet()
                    restart()
                    u1603.renderLib()

                    dispatch = if v2 == "tmp" then 53 else 51
                end
            elseif dispatch < 52 then
                dispatch = if v2 == u2423 then 53 else 52
            else
                if not (dispatch < 53) then
                    return
                end

                u2423 = v2
                u1603.savePref("lastSheet", v2)

                dispatch = 53
            end
        end
    end

    function u1603.clearSheet() -- Line: 2847; upvalues: u1805 (val), u1603 (val), buildOwner (val), restart (val)
        u1805.text = ""
        u1805.title = ""
        u1805.steps = {}
        u1805.comments = {}
        u1805.activeId = ""

        if u1603.secClear then
            u1603.secClear()
        end

        buildOwner()
        u1603.buildSheet()
        restart()
        u1603.renderLib()
    end

    local function levelPicker(a1, a2, a3)
        -- Line: 2856
        -- upvalues: box (val), u1603 (val), Levels (val)
        -- types: a2: string?, a3: function
        local v1
        local v2 = box({
            dir = "row",
            wrap = true,
            gap = 6,
            rowGap = 6,
            parent = a1,
        })
        local u6 = {}

        local function paintAll(a1)
            -- Line: 2859
            -- upvalues: u6 (val), u1603 (upval), Levels (upval)
            -- types: a1: string?
            local levelChip, v1, v2
            local v3 = nil
            local v4 = nil

            for i, j in u6, v3, v4 do
                levelChip = u1603.levelChip
                v1 = Levels.get(i)
                v2 = i == a1

                levelChip(j, v1, v2)
            end
        end

        for i, j in Levels.list do
            v1 = box({
                pad = {3, 8},
                r = 6,
                bd = 1,
                bdc = "line",
                bg = "panel2",
                button = true,
                parent = v2,
                {u1603.levelText(j, "s500_12_8", 18.56)},
            })
            u6[j.name] = v1

            v1:onClick(function() -- Line: 2868; upvalues: paintAll (val), j (val), a3 (val)
                paintAll(j.name)
                a3(j.name)
            end)
        end

        paintAll(a2)

        return v2
    end

    function u1603.openEditor(a1)
        -- Line: 2874
        -- upvalues: u3682 (ref), Sheets (val), openDialog (val), note (val), box (val), field (val), input_2 (val)
        -- upvalues: u3710 (val), Levels (val), levelPicker (val), viewport (val), text (val), statusLine (val)
        -- upvalues: btn (val), u1578 (val), u1603 (val), loadSheet (val), Api (val), toast (val), u1805 (val)
        local bpm, getBpm, getText, id, index, level, pubId_2, save, status, u127, u138, u229, u284, u316, u371, u378,
            u38, u381, u382, u383, u394, u403, u405, u406, u407, u47, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11,
            v12
        local dispatch = 0

        while true do
            if dispatch < 34 then
                if dispatch < 20 then
                    if dispatch < 13 then
                        if dispatch < 9 then
                            if dispatch < 1 then
                                u38 = a1
                                dispatch = if not u38 then 12 else 1
                            elseif dispatch < 5 then
                                id = a1.id
                                v8 = u3682
                                v9 = nil
                                v10 = nil
                                local dispatchExit = nil

                                for i20, i21 in v8, v9, v10 do
                                    local dispatch2 = 2

                                    while true do
                                        if not (dispatch2 < 3) then
                                            u38 = i21
                                            dispatchExit = 10
                                            break
                                        end

                                        if i21.id ~= id then
                                            break
                                        else
                                            dispatch2 = 3
                                        end
                                    end

                                    if dispatchExit then
                                        break
                                    end
                                end

                                dispatch = if dispatchExit == 10 then 10 else 5
                            else
                                v8 = Sheets
                                v9 = nil
                                v10 = nil
                                local dispatchExit2 = nil

                                for i22, i23 in v8, v9, v10 do
                                    local dispatch3 = 6

                                    while true do
                                        if not (dispatch3 < 7) then
                                            u38 = i23
                                            dispatchExit2 = 10
                                            break
                                        end

                                        if i23.id ~= id then
                                            break
                                        else
                                            dispatch3 = 7
                                        end
                                    end

                                    if dispatchExit2 then
                                        break
                                    end
                                end

                                dispatch = if dispatchExit2 == 10 then 10 else 9
                            end
                        elseif dispatch < 11 then
                            if dispatch < 10 then
                                u38 = nil
                                dispatch = 10
                            else
                                dispatch = if not u38 then 12 else 11
                            end
                        elseif dispatch < 12 then
                            u38 = not string.find(a1.id, "^lib")
                            dispatch = 12
                        else
                            dispatch = if not u38 then 14 else 13
                        end
                    elseif dispatch < 16 then
                        if dispatch < 14 then
                            status = a1.status
                            dispatch = 15
                        elseif dispatch < 15 then
                            status = nil
                            dispatch = 15
                        else
                            u47 = false
                            dispatch = if a1 == nil then 19 else 16
                        end
                    elseif dispatch < 18 then
                        if dispatch < 17 then
                            dispatch = if a1.id == "copy" then 18 else 17
                        else
                            u47 = false
                            dispatch = 19
                        end
                    elseif dispatch < 19 then
                        u47 = true
                        dispatch = 19
                    else
                        v9 = openDialog
                        dispatch = if not u38 then 21 else 20
                    end
                elseif dispatch < 27 then
                    if dispatch < 23 then
                        if dispatch < 21 then
                            v10 = "Edit sheet"
                            dispatch = 24
                        elseif dispatch < 22 then
                            dispatch = if not u47 then 23 else 22
                        else
                            v10 = "Copy of a sheet"
                            dispatch = 24
                        end
                    elseif dispatch < 25 then
                        if dispatch < 24 then
                            v10 = "Paste notes"
                            dispatch = 24
                        else
                            v9 = v9(v10, true)
                            dispatch = if not u47 then 26 else 25
                        end
                    elseif dispatch < 26 then
                        v9:add(
                            (note(
                                "This is a copy of \"" .. (tostring(a1.title)) .. "\". To publish your own song, open \"＋ Paste notes\" and paste your song's notes: a copy with only a new name is turned down.",
                                {c = "brassInk"}
                            ))
                        )

                        dispatch = 26
                    else
                        dispatch = if status ~= "pending" then 28 else 27
                    end
                elseif dispatch < 30 then
                    if dispatch < 28 then
                        v9:add(
                            (note(
                                "This sheet is waiting for an admin's review. You can edit it after the answer, or take it back with \"Cancel submission\".",
                                {c = "brassInk"}
                            ))
                        )

                        dispatch = 34
                    elseif dispatch < 29 then
                        dispatch = if status ~= "published" then 32 else 29
                    else
                        v9:add(
                            (note(
                                "This sheet is published in Sheet music. You can change it: press \"Submit changes\" and an admin checks it again. Until then everyone sees the published version.",
                                {c = "ok"}
                            ))
                        )

                        dispatch = if not a1.reason then 34 else 30
                    end
                elseif dispatch < 32 then
                    if dispatch < 31 then
                        dispatch = if a1.reason == "" then 34 else 31
                    else
                        v9:add(
                            (note(
                                "Your last changes were rejected: " .. tostring(a1.reason),
                                {c = "bad"}
                            ))
                        )

                        dispatch = 34
                    end
                elseif dispatch < 33 then
                    dispatch = if status ~= "rejected" then 34 else 33
                else
                    v9:add(
                        (note(
                            "An admin rejected this sheet. Their reason is in the notes field below: replace it with your notes and submit again.",
                            {c = "bad"}
                        ))
                    )

                    dispatch = 34
                end
            elseif dispatch < 51 then
                if dispatch < 44 then
                    if dispatch < 40 then
                        if dispatch < 35 then
                            v10 = box({dir = "row", gap = 10, parent = v9})
                            _, u127 = input_2(field(v10, "Title", true), "e.g. My song")
                            v11 = field(v10, "BPM")
                            v11.w = 92
                            _, u138 = input_2(v11, "1–500")
                            v12 = a1
                            dispatch = if not v12 then 41 else 35
                        elseif dispatch < 36 then
                            v12 = false
                            dispatch = if type(a1.pubId) ~= "string" then 41 else 36
                        else
                            pubId_2 = a1.pubId
                            index = u3710.index
                            v2 = nil
                            v3 = nil
                            local dispatchExit3 = nil

                            for i24, i25 in index, v2, v3 do
                                local dispatch4 = 37

                                while true do
                                    if not (dispatch4 < 38) then
                                        v12 = i25
                                        dispatchExit3 = 41
                                        break
                                    end

                                    if i25.id ~= pubId_2 then
                                        break
                                    else
                                        dispatch4 = 38
                                    end
                                end

                                if dispatchExit3 then
                                    break
                                end
                            end

                            dispatch = if dispatchExit3 == 41 then 41 else 40
                        end
                    elseif dispatch < 42 then
                        if dispatch < 41 then
                            v12 = nil
                            dispatch = 41
                        else
                            dispatch = if not a1 then 43 else 42
                        end
                    elseif dispatch < 43 then
                        bpm = a1.bpm
                        dispatch = if bpm then 45 else 43
                    else
                        bpm = v12
                        dispatch = if not bpm then 45 else 44
                    end
                elseif dispatch < 47 then
                    if dispatch < 45 then
                        bpm = v12.bpm
                        dispatch = 45
                    elseif dispatch < 46 then
                        dispatch = if type(bpm) ~= "number" then 47 else 46
                    else
                        u138.Text = tostring(bpm)
                        dispatch = 47
                    end
                elseif dispatch < 49 then
                    if dispatch < 48 then
                        function getBpm() -- Line: 2904; upvalues: u138 (val)
                            local v1 = tonumber(u138.Text)

                            if v1 and v1 == v1 then
                                return (math.clamp(math.floor(v1 + 0.5), 1, 500))
                            end

                            return nil
                        end

                        dispatch = if not a1 then 50 else 48
                    else
                        dispatch = if not Levels.valid(a1.level) then 50 else 49
                    end
                else
                    level = if dispatch < 50 then a1.level else nil
                    dispatch = 51
                end
            elseif dispatch < 60 then
                if dispatch < 56 then
                    if dispatch < 52 then
                        v3 = level
                        levelPicker(
                            field(v9, "Difficulty"),
                            v3,
                            function(a1) -- Line: 2910; upvalues: level (ref)
                                level = a1
                            end
                        )

                        _, u229 = input_2(
                            field(v9, "Notes in Virtual Piano format", true),
                            "[6p] 0 e t u p ...",
                            {
                                multi = true,
                                grow = true,
                                h = math.max(120, 0.34 * (select(2, (viewport())))),
                            }
                        )
                        dispatch = if not a1 then 53 else 52
                    elseif dispatch < 53 then
                        u127.Text = a1.title
                        u229.Text = a1.text
                        dispatch = 53
                    else
                        v1 = box({
                            dir = "row",
                            wrap = true,
                            gap = 16,
                            rowGap = 2,
                            bg = "panel2",
                            r = 8,
                            pad = {9, 11},
                            parent = v9,
                        })
                        v3 = {
                            {{t = "a s d", f = "m600_12_8", c = "ink"}, {t = " — one note per beat"}},
                            {{t = "asdf", f = "m600_12_8", c = "ink"}, {t = " — quick, half a beat"}},
                            {{t = "[tu]", f = "m600_12_8", c = "ink"}, {t = " — chord"}},
                            {{t = "[t u o]", f = "m600_12_8", c = "ink"}, {t = " — fast arpeggio"}},
                            {
                                {t = "a-s", f = "m600_12_8", c = "ink"},
                                {t = " — a bit quicker than a space"},
                            },
                            {
                                {t = "|", f = "m600_12_8", c = "ink"},
                                {t = " — pause, empty line — long pause"},
                            },
                            {
                                {t = "// text", f = "m600_12_8", c = "ink"},
                                {t = " — comment to the end of the line, not played"},
                            },
                        }
                        v4 = nil
                        v5 = nil
                        local dispatchExit4 = nil

                        for i26, i27 in v3, v4, v5 do
                            local dispatch5 = 54

                            while true do
                                v1:add(
                                    (text({f = "s400_12_8", c = "muted", runs = i27, lh = 18.56}))
                                )
                                break
                            end

                            if dispatchExit4 then
                                break
                            end
                        end

                        dispatch = 56
                    end
                elseif dispatch < 58 then
                    if dispatch < 57 then
                        u284 = statusLine(v9)
                        v10 = box({
                            dir = "row",
                            wrap = true,
                            gap = 8,
                            justify = "between",
                            align = "center",
                            parent = v9,
                        })
                        v9 = box({dir = "row", wrap = true, gap = 8, parent = v10})
                        v3 = btn("Save and play", "primary")

                        v9:add(v3)

                        v4 = btn("Play without saving")
                        v9:add(v4)

                        u316 = nil
                        dispatch = if status == "pending" then 61 else 57
                    else
                        v6 = btn
                        dispatch = if status ~= "published" then 59 else 58
                    end
                else
                    v7 = if dispatch < 59 then "Submit changes" else "Submit for review"
                    dispatch = 60
                end
            elseif dispatch < 64 then
                if dispatch < 62 then
                    if dispatch < 61 then
                        u316 = v6(v7)
                        v9:add(u316)

                        dispatch = 61
                    else
                        function getText() -- Line: 2933; upvalues: u229 (val), u284 (val), u1578 (upval)
                            local Text = u229.Text

                            if string.gsub(Text, "%s", "") == "" then
                                u284("Paste notes into the field above.", true)
                                return nil
                            end

                            if #u1578.parse(Text) ~= 0 then
                                return Text
                            end

                            u284("No notes found. Use Virtual Piano keys: 1–0, a–z and Shift symbols.", true)

                            return nil
                        end

                        v4:onClick(function()
                            -- Line: 2939
                            -- upvalues: getText (val), u1603 (upval), loadSheet (upval), u127 (val), u138 (val)
                            local v1 = getText()

                            if not v1 then
                                return
                            end

                            u1603.closeDialog()

                            local v2 = loadSheet
                            local Text = if u127.Text == "" then "My sheet" else u127.Text
                            local v3 = tonumber(u138.Text)

                            v2(Text, v1, "tmp", if not v3 or v3 ~= v3 then nil else math.clamp(math.floor(v3 + 0.5), 1, 500))
                        end)

                        function save(a1_2)
                            -- Line: 2945
                            -- upvalues: u138 (val), u38 (val), a1 (val), u127 (val), level (ref), Api (upval)
                            -- upvalues: u3682 (upval)
                            -- types: a1_2: string
                            local v1
                            local v2 = tonumber(u138.Text)
                            local v3 = if not v2 or v2 ~= v2 then
                                nil
                            else
                                math.clamp(math.floor(v2 + 0.5), 1, 500)
                            local u14 = {}
                            u14.id = if not u38 then nil else a1.id
                            u14.title = u127.Text
                            u14.text = a1_2
                            u14.level = level
                            u14.bpm = v3
                            local u29 = "saveSheet"
                            local success, err, v4 = pcall(function()
                                -- Line: 50
                                -- upvalues: Api (upval), u29 (val), u14 (val)
                                return Api:InvokeServer(u29, u14)
                            end)

                            if success then
                                v2 = err
                                v1 = v4
                            else
                                v2 = nil
                                v1 = "No connection to the server."
                            end

                            if not v2 then
                                return nil, v1
                            end

                            v1 = if u127.Text == "" then
                                "My sheet " .. #u3682 + 1
                            else
                                string.sub(u127.Text, 1, 80)
                            local v5 = nil

                            for i, j in u3682 do
                                if j.id == v2 then
                                    v5 = j
                                end
                            end

                            if not v5 then
                                table.insert(
                                    u3682,
                                    1,
                                    {
                                        id = v2,
                                        title = v1,
                                        text = a1_2,
                                        level = level,
                                        bpm = v3,
                                    }
                                )
                            else
                                if v5.status == "published" then
                                    if v5.text ~= a1_2 or v5.title ~= v1 then
                                        v5.edited = true
                                    elseif not level then
                                        if v3 and v3 ~= v5.bpm then
                                            v5.edited = true
                                        end
                                    elseif level ~= v5.level or v3 and v3 ~= v5.bpm then
                                        v5.edited = true
                                    end
                                end

                                v5.title = v1
                                v5.text = a1_2
                                v5.level = level or v5.level
                                v5.bpm = v3 or v5.bpm

                                if v5.status == "rejected" then
                                    v5.status = nil
                                    v5.reason = nil
                                end
                            end

                            return v2, v5
                        end

                        v3:onClick(function()
                            -- Line: 2962
                            -- upvalues: getText (val), u284 (val), save (val), u1603 (upval), loadSheet (upval)
                            -- upvalues: toast (upval)
                            local v1 = getText()

                            if not v1 then
                                return
                            end

                            u284("Saving…")

                            local v2, v3 = save(v1)

                            if not v2 then
                                u284(v3 or "Couldn't save.", true)
                                return
                            end

                            u1603.closeDialog()
                            loadSheet(v3.title, v1, v2)
                            toast("Sheet saved.")
                        end)

                        dispatch = if not u316 then 63 else 62
                    end
                elseif dispatch < 63 then
                    u316:onClick(function()
                        -- Line: 2973
                        -- upvalues: getText (val), level (ref), u284 (val), u47 (val), a1 (val), u138 (val), u316 (ref)
                        -- upvalues: save (val), Api (upval), u1603 (upval), toast (upval)
                        local v1, v2, v3
                        local v4 = getText()

                        if not v4 then
                            return
                        end

                        if not level then
                            u284("Pick a difficulty first.", true)
                            return
                        end

                        if u47
                            and (string.gsub(v4, "%s+", ""))
                                == string.gsub(tostring(a1.text), "%s+", "") then
                            u284("These are still the notes of \"" .. (tostring(a1.title)) .. "\". Paste your song's own notes to publish it.", true)
                            return
                        end

                        local v5 = tonumber(u138.Text)

                        if not (if not v5 or v5 ~= v5 then
                            nil
                        else
                            math.clamp(math.floor(v5 + 0.5), 1, 500)) then
                            u284("Set the BPM first: the tempo the sheet should be played at.", true)
                            return
                        end

                        if u316.busy then
                            return
                        end

                        u316.busy = true
                        u284("Sending…")

                        v1, v5 = save(v4)

                        if not v1 then
                            u316.busy = nil
                            u284(v5 or "Couldn't save.", true)

                            return
                        end

                        local u69 = {id = v1, level = level}
                        local u71 = "submitSheet"
                        local success, err, v6 = pcall(function()
                            -- Line: 50
                            -- upvalues: Api (upval), u71 (val), u69 (val)
                            return Api:InvokeServer(u71, u69)
                        end)

                        if success then
                            v2 = err
                            v3 = v6
                        else
                            v2 = nil
                            v3 = "No connection to the server."
                        end

                        u316.busy = nil

                        if not v2 then
                            u284(v3 or "Couldn't send the sheet.", true)
                            return
                        end

                        v5.status = "pending"
                        u1603.closeDialog()
                        u1603.renderLib()
                        toast("Sent. An admin will review it soon.")
                    end)

                    dispatch = 63
                else
                    dispatch = if status ~= "pending" then 65 else 64
                end
            elseif not (dispatch < 66) then
                if not (dispatch < 67) then
                    return
                end

                u394 = btn("Delete sheet", "danger")
                v10:add(u394)

                function u403()
                    -- Line: 3013
                    -- upvalues: a1 (val), Api (upval), u3682 (upval), u1603 (upval), u1805 (upval)
                    local id = a1.id
                    local u2 = "deleteSheet"

                    if (pcall(function() -- Line: 50; upvalues: Api (upval), u2 (val), id (val)
                        return Api:InvokeServer(u2, id)
                    end)) then end

                    for i, j in u3682 do
                        if j.id == a1.id then
                            table.remove(u3682, i)
                            break
                        end
                    end

                    u1603.closeDialog()

                    if u1805.activeId == a1.id then
                        u1603.clearSheet()
                        return
                    end

                    u1603.renderLib()
                end

                u405 = false
                u406 = "Click again to delete"
                u407 = "Delete sheet"

                u394:onClick(function()
                    -- Line: 2724
                    -- upvalues: u405 (ref), u394 (val), u406 (val), u407 (val), u403 (val)
                    if u405 then
                        u405 = false
                        u403()

                        return
                    end

                    u405 = true
                    u394:state("arm", true)
                    u394.label:setText(u406)

                    task.delay(
                        3,
                        function() -- Line: 2729; upvalues: u405 (upval), u394 (upval), u407 (upval)
                            if u405 then
                                u405 = false
                                u394:state("arm", false)

                                local v1 = u407
                                u394.label:setText(v1)
                            end
                        end
                    )
                end)

                dispatch = 67
            elseif dispatch < 65 then
                u371 = btn("Cancel submission", "danger")
                v9:add(u371)

                function u378()
                    -- Line: 2999
                    -- upvalues: u284 (val), a1 (val), Api (upval), u3682 (upval), u1603 (upval), toast (upval)
                    u284("Cancelling…")

                    task.spawn(function()
                        -- Line: 3001
                        -- upvalues: a1 (upval), Api (upval), u284 (upval), u3682 (upval), u1603 (upval), toast (upval)
                        local v1, v2, v3
                        local u0 = {}
                        u0.id = a1.id
                        local u3 = "cancelSubmit"
                        local success, err, v4 = pcall(function()
                            -- Line: 50
                            -- upvalues: Api (upval), u3 (val), u0 (val)
                            return Api:InvokeServer(u3, u0)
                        end)

                        if success then
                            v1 = err
                            v2 = v4
                        else
                            v1 = nil
                            v2 = "No connection to the server."
                        end

                        if not v1 then
                            u284(tostring(v2 or "Couldn't cancel."), true)
                            return
                        end

                        local v5 = nil
                        local v6 = nil

                        for i, j in u3682, v5, v6 do
                            if j.id == a1.id then
                                v3 = if v2 ~= "published" then nil else "published"
                                j.status = v3
                            end
                        end

                        u1603.closeDialog()
                        u1603.renderLib()
                        toast("Taken out of review.")
                    end)
                end

                u381 = false
                u382 = "Click again to cancel"
                u383 = "Cancel submission"

                u371:onClick(function()
                    -- Line: 2724
                    -- upvalues: u381 (ref), u371 (val), u382 (val), u383 (val), u378 (val)
                    if u381 then
                        u381 = false
                        u378()

                        return
                    end

                    u381 = true
                    u371:state("arm", true)
                    u371.label:setText(u382)

                    task.delay(
                        3,
                        function() -- Line: 2729; upvalues: u381 (upval), u371 (upval), u383 (upval)
                            if u381 then
                                u381 = false
                                u371:state("arm", false)

                                local v1 = u383
                                u371.label:setText(v1)
                            end
                        end
                    )
                end)

                dispatch = 65
            else
                dispatch = if not u38 then 67 else 66
            end
        end
    end

    u1642.editBtn:onClick(function() -- Line: 3021; upvalues: u1603 (val)
        u1603.openEditor(nil)
    end)

    u1642.editHud:onClick(function()
        -- Line: 3023
        -- upvalues: u1642 (val), u1805 (val), u3682 (ref), Sheets (val), u3710 (val), u1603 (val)
        local v1, v2

        if u1642.hudDragAt and os.clock() - u1642.hudDragAt < 0.3 then
            return
        end

        if u1805.text == "" then
            return
        end

        local activeId = u1805.activeId

        for i, j in u3682 do
            if j.id == activeId then
                v1 = j

                if not v1 then
                    for k, n in u3710.index do
                        if n.id == u1805.activeId then
                            v2 = n
                            u1603.openEditor({
                                id = "copy",
                                title = u1805.title,
                                text = u1805.text,
                                level = v2 and v2.level,
                                bpm = u1805.sheetBpm,
                            })

                            return
                        end
                    end

                    v2 = nil
                    v1 = {
                        id = "copy",
                        title = u1805.title,
                        text = u1805.text,
                        level = v2 and v2.level,
                        bpm = u1805.sheetBpm,
                    }
                end

                u1603.openEditor(v1)

                return
            end
        end

        for m, i5 in Sheets do
            if i5.id == activeId then
                v1 = i5

                if not v1 then
                    for i6, i7 in u3710.index do
                        if i7.id == u1805.activeId then
                            v2 = i7
                            u1603.openEditor({
                                id = "copy",
                                title = u1805.title,
                                text = u1805.text,
                                level = v2 and v2.level,
                                bpm = u1805.sheetBpm,
                            })

                            return
                        end
                    end

                    v2 = nil
                    v1 = {
                        id = "copy",
                        title = u1805.title,
                        text = u1805.text,
                        level = v2 and v2.level,
                        bpm = u1805.sheetBpm,
                    }
                end

                u1603.openEditor(v1)

                return
            end
        end

        v1 = nil

        if not v1 then
            for i8, i9 in u3710.index do
                if i9.id == u1805.activeId then
                    v2 = i9
                    u1603.openEditor({
                        id = "copy",
                        title = u1805.title,
                        text = u1805.text,
                        level = v2 and v2.level,
                        bpm = u1805.sheetBpm,
                    })

                    return
                end
            end

            v2 = nil
            v1 = {
                id = "copy",
                title = u1805.title,
                text = u1805.text,
                level = v2 and v2.level,
                bpm = u1805.sheetBpm,
            }
        end

        u1603.openEditor(v1)
    end)

    function u1603.openCommunity(a1) -- Line: 3035; upvalues: u3710 (val), Api (val), toast (val), loadSheet (val)
        local v1 = u3710.texts[a1.id]

        if not v1 then
            local id = a1.id
            local u6 = "communitySheet"
            local success, err = pcall(function() -- Line: 50; upvalues: Api (upval), u6 (val), id (val)
                return Api:InvokeServer(u6, id)
            end)

            if type(if success then err else nil) ~= "string" then
                toast("This sheet is no longer available.")
                return
            end

            u3710.texts[a1.id] = v1
        end

        loadSheet(a1.title, v1, a1.id)
    end

    local function toggleFav(a1)
        -- Line: 3044
        -- upvalues: u3724 (ref), u3710 (val), u1603 (val), Api (val)
        -- types: a1: string
        local u3 = not u3724[a1]
        u3724[a1] = if not u3 then nil else true
        u3710.stars[a1] = (math.max(0, (u3710.stars[a1] or 0) + (if not u3 then -1 else 1)))

        u1603.renderLib()

        task.spawn(function() -- Line: 3049; upvalues: a1 (val), u3 (val), Api (upval), u3710 (upval), u1603 (upval)
            local u0 = {id = a1, on = u3}
            local u3_2 = "star"
            local success, err = pcall(function() -- Line: 50; upvalues: Api (upval), u3_2 (val), u0 (val)
                return Api:InvokeServer(u3_2, u0)
            end)
            local v1 = if success then err else nil

            if type(v1) == "number" then
                u3710.stars[a1] = v1
                u1603.renderLib()
            end
        end)
    end

    local function smallBtn(a1, a2, a3, a4)
        -- Line: 3054
        -- upvalues: text (val), box (val)
        -- types: a2: string, a4: boolean?
        local v1 = text({f = "s400_11_84", t = a2, lh = if not a4 then 17.168 else 15, c = a3 or "muted"})
        local v2 = box({
            dir = "row",
            align = "center",
            gap = 3,
            pad = if not a4 then {4, 8} else {0, 6},
            bd = 1,
            bdc = "line",
            bg = "panel2",
            r = 7,
            button = true,
            noShrink = true,
            hov = {bdc = "btnHoverLine"},
            parent = a1,
            {v1},
        })

        v2:bindHover()

        v2.label = v1

        return v2
    end

    local function v49(a1) -- Line: 3064; types: a1: string
        return (string.gsub(string.gsub(string.gsub(a1, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"))
    end

    function u1603.bpmEditor(a1, a2, a3, a4, a5)
        -- Line: 3071
        -- upvalues: box (val), text (val), input_2 (val), smallBtn (val), toast (val), Api (val)
        -- types: a2: string, a3: boolean, a4: number?, a5: function?
        local v1 = box({
            dir = "row",
            align = "center",
            gap = 6,
            noShrink = true,
            parent = a1,
        })
        text({
            t = "BPM",
            f = "m600_8_96",
            up = true,
            ls = 0.896,
            c = "muted",
            parent = v1,
        })

        local v2, u16 = input_2(
            v1,
            "1–500",
            {h = 28}
        )
        v2.w = 58
        u16.Text = if not a4 then "" else tostring(a4)

        ;(smallBtn(v1, "Set")):onClick(function()
            -- Line: 3078
            -- upvalues: u16 (val), toast (upval), a2 (val), a3 (val), Api (upval), a5 (val)
            local u3 = tonumber(u16.Text)

            if u3 and u3 == u3 then
                task.spawn(function()
                    -- Line: 3081
                    -- upvalues: a2 (upval), u3 (val), a3 (upval), Api (upval), toast (upval), u16 (upval), a5 (upval)
                    local v1, v2
                    local u0 = {id = a2, bpm = u3, pending = a3}
                    local u4 = "setBpm"
                    local success, err, v3 = pcall(function() -- Line: 50; upvalues: Api (upval), u4 (val), u0 (val)
                        return Api:InvokeServer(u4, u0)
                    end)

                    if success then
                        v1 = err
                        v2 = v3
                    else
                        v1 = nil
                        v2 = "No connection to the server."
                    end

                    if type(v1) ~= "number" then
                        toast((tostring(v2 or "Couldn't save the BPM.")))
                        return
                    end

                    u16.Text = tostring(v1)

                    if a5 then
                        a5(v1)
                    end

                    toast("BPM set to " .. v1 .. ".")
                end)
                return
            end

            toast("Type a BPM from 1 to 500.")
        end)

        return v1
    end

    function u1603.openPreview(a1, a2)
        -- Line: 3091
        -- upvalues: openDialog (val), box (val), levelBadge (val), u1578 (val), u3710 (val), text (val)
        -- upvalues: LocalPlayer (val), toast (val), Api (val), fmtRating (val), u1603 (val), u1805 (val), u3682 (ref)
        -- upvalues: Sheets (val), Lay (val), btn (val), u3724 (ref), toggleFav (val), u1642 (val), loadSheet (val)
        -- upvalues: u1631 (val)
        -- types: a2: string
        local ScrollingFrame, TextLabel, UIPadding, id_2, paintStars, show, text_2, u140, u163, u164, u424, v1, v2,
            v3, v4, v5
        local u8 = openDialog(tostring(a1.title), true, 640)
        local v6 = box({dir = "row", align = "center", gap = 8, parent = u8})
        local v7 = levelBadge(a1.level)

        if v7 then
            v6:add(v7)
        end

        v7 = {}
        table.insert(
            v7,
            {
                t = (if a2 ~= "comm" then
                    #u1578.parse(a1.text or "")
                else
                    tonumber(a1.steps) or 0)
                    .. " steps",
            }
        )

        local v8 = false

        if a2 ~= "comm" then
            v8 = false

            if type(a1.pubId) == "string" then
                for i, j in u3710.index do
                    if j.id == a1.pubId then
                        v8 = j
                        v5 = tonumber(a1.bpm) or v8 and tonumber(v8.bpm)

                        if v5 then
                            table.insert(
                                v7,
                                {t = " · " .. v5 .. " BPM"}
                            )
                        end

                        if a2 == "comm" and a1.authorName then
                            table.insert(
                                v7,
                                {t = " · by " .. tostring(a1.authorName)}
                            )
                        end

                        if a2 == "comm" then
                            table.insert(
                                v7,
                                {
                                    t = " · ♥ " .. tostring(u3710.stars[a1.id] or 0),
                                }
                            )
                        end

                        v6:add(
                            (text({
                                f = "m400_10_88",
                                c = "muted",
                                ell = true,
                                shrink0 = true,
                                runs = v7,
                            }))
                        )

                        if a2 == "comm" then
                            u140 = a1.author == LocalPlayer.UserId
                            v6 = box({dir = "row", align = "center", gap = 2, parent = u8})

                            text({
                                t = "Your rating",
                                f = "s500_13_44",
                                c = "muted",
                                lh = 19.488,
                                m = {0, 8, 0, 0},
                                parent = v6,
                            })

                            u163 = {}
                            u164 = nil

                            function paintStars(a1) -- Line: 3114; upvalues: u163 (val); types: a1: number
                                local v1 = nil
                                local v2 = nil

                                for i, j in u163, v1, v2 do
                                    j.label.c = if not (i <= a1) then "dim" else "brass"
                                    j.label:paint()
                                end
                            end

                            for k = 1, 5 do
                                v3 = text({t = "★", f = "s400_22_4", lh = 24, c = "dim"})
                                v4 = box({pad = {0, 2}, button = true, parent = v6, {v3}})
                                v4.label = v3
                                u163[k] = v4

                                v4.inst.MouseEnter:Connect(function()
                                    -- Line: 3125
                                    -- upvalues: paintStars (val), k (val)
                                    paintStars(k)
                                end)

                                v4.inst.MouseLeave:Connect(function()
                                    -- Line: 3126
                                    -- upvalues: paintStars (val), u3710 (upval), a1 (val)
                                    paintStars(u3710.myRates[a1.id] or 0)
                                end)

                                v4:onClick(function()
                                    -- Line: 3127
                                    -- upvalues: u140 (val), toast (upval), u3710 (upval), a1 (val), k (val)
                                    -- upvalues: Api (upval), paintStars (val), u164 (ref), fmtRating (upval)
                                    -- upvalues: u1603 (upval)
                                    if u140 then
                                        toast("You can't rate your own sheet. Others will rate it.")
                                        return
                                    end

                                    local u12 = if (u3710.myRates[a1.id] or 0) ~= k then k else 0
                                    task.spawn(function()
                                        -- Line: 3130
                                        -- upvalues: a1 (upval), u12 (val), Api (upval), u3710 (upval)
                                        -- upvalues: paintStars (upval), u164 (upval), fmtRating (upval), u1603 (upval)
                                        -- upvalues: toast (upval)
                                        local v1, v2
                                        local u0 = {}
                                        u0.id = a1.id
                                        u0.r = u12
                                        local u4 = "rate"
                                        local success, err, v3 = pcall(function()
                                            -- Line: 50
                                            -- upvalues: Api (upval), u4 (val), u0 (val)
                                            return Api:InvokeServer(u4, u0)
                                        end)

                                        if success then
                                            v1 = err
                                            v2 = v3
                                        else
                                            v1 = nil
                                            v2 = "No connection to the server."
                                        end

                                        if type(v1) ~= "table" then
                                            toast((tostring(v2 or "Couldn't save the rating.")))
                                            return
                                        end

                                        u3710.ratings[a1.id] = v1
                                        local myRates = u3710.myRates
                                        local id = a1.id
                                        myRates[id] = if not (u12 > 0) then nil else u12

                                        paintStars(u12)
                                        u164:setText((fmtRating(a1.id)))
                                        u1603.renderLib()
                                    end)
                                end)
                            end

                            v1 = {f = "m400_10_88", c = "muted"}
                            id_2 = a1.id
                            v4 = u3710.ratings[id_2]
                            v1.t = if type(v4) ~= "table" then
                                "No ratings yet"
                            else
                                if not ((v4.n or 0) <= 0) then
                                    string.format("%.1f from %d vote%s", v4.s / v4.n, v4.n, if v4.n ~= 1 then "s" else "")
                                else
                                    "No ratings yet"
                            v1.m = {0, 0, 0, 10}
                            v1.parent = v6
                            u164 = (text(v1))

                            paintStars(u3710.myRates[a1.id] or 0)

                            if LocalPlayer:GetAttribute("Admin") == true then
                                box({grow = 1, parent = v6})

                                u1603.bpmEditor(
                                    v6,
                                    a1.id,
                                    false,
                                    tonumber(a1.bpm),
                                    function(a1_2)
                                        -- Line: 3148
                                        -- upvalues: a1 (val), u3710 (upval), u1805 (upval), u3682 (upval)
                                        -- upvalues: Sheets (upval), u1603 (upval)
                                        local activeId, v1
                                        a1.bpm = a1_2

                                        for i, j in u3710.index do
                                            if j.id == a1.id then
                                                v1 = j

                                                if v1 then
                                                    v1.bpm = a1_2
                                                end

                                                activeId = u1805.activeId

                                                for k, n in u3682 do
                                                    if n.id == activeId then
                                                        v1 = n

                                                        if u1805.activeId == a1.id
                                                            or v1 and v1.pubId == a1.id then
                                                            u1805.sheetBpm = a1_2
                                                            u1603.setBpm(a1_2, false, true)
                                                        end

                                                        return
                                                    end
                                                end

                                                for m, i5 in Sheets do
                                                    if i5.id == activeId then
                                                        v1 = i5

                                                        if u1805.activeId == a1.id
                                                            or v1 and v1.pubId == a1.id then
                                                            u1805.sheetBpm = a1_2
                                                            u1603.setBpm(a1_2, false, true)
                                                        end

                                                        return
                                                    end
                                                end

                                                v1 = nil

                                                if u1805.activeId == a1.id
                                                    or v1 and v1.pubId == a1.id then
                                                    u1805.sheetBpm = a1_2
                                                    u1603.setBpm(a1_2, false, true)
                                                end

                                                return
                                            end
                                        end

                                        v1 = nil

                                        if v1 then
                                            v1.bpm = a1_2
                                        end

                                        activeId = u1805.activeId

                                        for i6, i7 in u3682 do
                                            if i7.id == activeId then
                                                v1 = i7

                                                if u1805.activeId == a1.id
                                                    or v1 and v1.pubId == a1.id then
                                                    u1805.sheetBpm = a1_2
                                                    u1603.setBpm(a1_2, false, true)
                                                end

                                                return
                                            end
                                        end

                                        for i8, i9 in Sheets do
                                            if i9.id == activeId then
                                                v1 = i9

                                                if u1805.activeId == a1.id
                                                    or v1 and v1.pubId == a1.id then
                                                    u1805.sheetBpm = a1_2
                                                    u1603.setBpm(a1_2, false, true)
                                                end

                                                return
                                            end
                                        end

                                        v1 = nil

                                        if u1805.activeId == a1.id
                                            or v1 and v1.pubId == a1.id then
                                            u1805.sheetBpm = a1_2
                                            u1603.setBpm(a1_2, false, true)
                                        end
                                    end
                                )
                            end
                        end

                        v5 = box({
                            grow = 1,
                            vshrink = true,
                            minH = 120,
                            bg = "panel2",
                            bd = 1,
                            bdc = "line",
                            r = 8,
                            clip = true,
                            parent = u8,
                        })
                        ScrollingFrame = Instance.new("ScrollingFrame")
                        ScrollingFrame.BackgroundTransparency = 1
                        ScrollingFrame.BorderSizePixel = 0
                        ScrollingFrame.Size = UDim2.new(1, -8, 1, -4)
                        ScrollingFrame.Position = UDim2.fromOffset(4, 2)
                        ScrollingFrame.CanvasSize = UDim2.new()
                        ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                        ScrollingFrame.ScrollBarThickness = 6
                        ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
                        ScrollingFrame.ZIndex = 65
                        ScrollingFrame.Parent = v5.inst
                        UIPadding = Instance.new("UIPadding")
                        UIPadding.PaddingTop = UDim.new(0, 8)
                        UIPadding.PaddingBottom = UDim.new(0, 8)
                        UIPadding.PaddingLeft = UDim.new(0, 8)
                        UIPadding.PaddingRight = UDim.new(0, 8)
                        UIPadding.Parent = ScrollingFrame
                        TextLabel = Instance.new("TextLabel")
                        TextLabel.BackgroundTransparency = 1
                        TextLabel.Size = UDim2.new(1, 0, 0, 0)
                        TextLabel.AutomaticSize = Enum.AutomaticSize.Y
                        TextLabel.TextWrapped = true
                        TextLabel.RichText = true
                        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                        TextLabel.TextYAlignment = Enum.TextYAlignment.Top
                        TextLabel.FontFace = Font.fromEnum(Enum.Font.RobotoMono)
                        TextLabel.TextSize = 17
                        TextLabel.LineHeight = 1.3
                        TextLabel.ZIndex = 66
                        TextLabel.Text = "Loading…"
                        TextLabel.Parent = ScrollingFrame

                        function v5.onPaint()
                            -- Line: 3190
                            -- upvalues: TextLabel (val), Lay (upval), ScrollingFrame (val)
                            TextLabel.TextColor3 = Lay.TH.ink.c
                            ScrollingFrame.ScrollBarImageColor3 = Lay.TH.muted.c
                        end

                        v5:paint()

                        text_2 = a1.text

                        function show(a1)
                            -- Line: 3196
                            -- upvalues: u1578 (upval), Lay (upval), TextLabel (val)
                            -- types: a1: string
                            local v1
                            _, v1 = u1578.parse(a1)
                            local v2 = {}
                            local v3 = 1
                            local v4 = "#" .. Lay.TH.brassInk.c:ToHex()

                            for i, j in v1 do
                                table.insert(v2, (string.gsub(string.gsub(string.gsub(string.sub(a1, v3, j[1] - 1), "&", "&amp;"), "<", "&lt;"), ">", "&gt;")))
                                table.insert(v2, "<font color=\"" .. v4 .. "\">" .. (string.gsub(string.gsub(string.gsub(string.sub(a1, j[1], j[2]), "&", "&amp;"), "<", "&lt;"), ">", "&gt;")) .. "</font>")

                                v3 = j[2] + 1
                            end

                            table.insert(v2, (string.gsub(string.gsub(string.gsub(string.sub(a1, v3), "&", "&amp;"), "<", "&lt;"), ">", "&gt;")))

                            TextLabel.Text = table.concat(v2)
                        end

                        v1 = box({
                            dir = "row",
                            wrap = true,
                            gap = 8,
                            justify = "between",
                            align = "center",
                            parent = u8,
                        })
                        v2 = box({dir = "row", wrap = true, gap = 8, parent = v1})
                        v3 = btn("▶ Play", "primary")

                        v2:add(v3)

                        v4 = btn(if a2 ~= "mine" then "Open in editor" else "Edit")
                        v2:add(v4)

                        if a2 == "comm" then
                            u424 = btn(if not u3724[a1.id] then "♥ Add to favourites" else "♥ In favourites")
                            v1:add(u424)

                            u424:onClick(function()
                                -- Line: 3214
                                -- upvalues: toggleFav (upval), a1 (val), u424 (val), u3724 (upval)
                                toggleFav(a1.id)
                                u424.label:setText(if not u3724[a1.id] then "♥ Add to favourites" else "♥ In favourites")
                            end)
                        end

                        if not text_2 then
                            task.spawn(function()
                                -- Line: 3220
                                -- upvalues: u3710 (upval), a1 (val), Api (upval), u1642 (upval), u8 (val)
                                -- upvalues: TextLabel (val), text_2 (ref), show (val)
                                local v1 = u3710.texts[a1.id]

                                if not v1 then
                                    local id = a1.id
                                    local u7 = "communitySheet"
                                    local success, err = pcall(function()
                                        -- Line: 50
                                        -- upvalues: Api (upval), u7 (val), id (val)
                                        return Api:InvokeServer(u7, id)
                                    end)
                                    v1 = if success then err else nil
                                end

                                if u1642.dialog ~= u8 then
                                    return
                                end

                                if type(v1) ~= "string" then
                                    TextLabel.Text = "This sheet is no longer available."
                                    return
                                end

                                u3710.texts[a1.id] = v1
                                text_2 = v1

                                show(v1)
                            end)
                        else
                            show(text_2)
                        end

                        v3:onClick(function()
                            -- Line: 3229
                            -- upvalues: text_2 (ref), u1603 (upval), loadSheet (upval), a1 (val), u1631 (upval)
                            if not text_2 then
                                return
                            end

                            u1603.closeDialog()
                            loadSheet(tostring(a1.title), text_2, a1.id)

                            if u1631.hudOpen == false then
                                u1603.setHudOpen(true)
                            end
                        end)

                        v4:onClick(function() -- Line: 3235; upvalues: text_2 (ref), u1603 (upval), a2 (val), a1 (val)
                            if not text_2 then
                                return
                            end

                            u1603.closeDialog()

                            if a2 == "mine" then
                                u1603.openEditor(a1)
                                return
                            end

                            u1603.openEditor({
                                id = "copy",
                                title = a1.title,
                                text = text_2,
                                level = a1.level,
                                bpm = a1.bpm,
                            })
                        end)

                        return
                    end
                end

                v8 = nil
            end
        end

        v5 = tonumber(a1.bpm) or v8 and tonumber(v8.bpm)

        if v5 then
            table.insert(
                v7,
                {t = " · " .. v5 .. " BPM"}
            )
        end

        if a2 == "comm" and a1.authorName then
            table.insert(
                v7,
                {t = " · by " .. tostring(a1.authorName)}
            )
        end

        if a2 == "comm" then
            table.insert(
                v7,
                {t = " · ♥ " .. tostring(u3710.stars[a1.id] or 0)}
            )
        end

        v6:add(
            (text({
                f = "m400_10_88",
                c = "muted",
                ell = true,
                shrink0 = true,
                runs = v7,
            }))
        )

        if a2 == "comm" then
            u140 = a1.author == LocalPlayer.UserId
            v6 = box({dir = "row", align = "center", gap = 2, parent = u8})

            text({
                t = "Your rating",
                f = "s500_13_44",
                c = "muted",
                lh = 19.488,
                m = {0, 8, 0, 0},
                parent = v6,
            })

            u163 = {}
            u164 = nil

            function paintStars(a1) -- Line: 3114; upvalues: u163 (val); types: a1: number
                local v1 = nil
                local v2 = nil

                for i, j in u163, v1, v2 do
                    j.label.c = if not (i <= a1) then "dim" else "brass"
                    j.label:paint()
                end
            end

            for n2 = 1, 5 do
                v3 = text({t = "★", f = "s400_22_4", lh = 24, c = "dim"})
                v4 = box({pad = {0, 2}, button = true, parent = v6, {v3}})
                v4.label = v3
                u163[n2] = v4

                v4.inst.MouseEnter:Connect(function() -- Line: 3125; upvalues: paintStars (val), n2 (val)
                    paintStars(n2)
                end)

                v4.inst.MouseLeave:Connect(function()
                    -- Line: 3126
                    -- upvalues: paintStars (val), u3710 (upval), a1 (val)
                    paintStars(u3710.myRates[a1.id] or 0)
                end)

                v4:onClick(function()
                    -- Line: 3127
                    -- upvalues: u140 (val), toast (upval), u3710 (upval), a1 (val), n2 (val), Api (upval)
                    -- upvalues: paintStars (val), u164 (ref), fmtRating (upval), u1603 (upval)
                    if u140 then
                        toast("You can't rate your own sheet. Others will rate it.")
                        return
                    end

                    local u12 = if (u3710.myRates[a1.id] or 0) ~= n2 then n2 else 0
                    task.spawn(function()
                        -- Line: 3130
                        -- upvalues: a1 (upval), u12 (val), Api (upval), u3710 (upval), paintStars (upval), u164 (upval)
                        -- upvalues: fmtRating (upval), u1603 (upval), toast (upval)
                        local v1, v2
                        local u0 = {}
                        u0.id = a1.id
                        u0.r = u12
                        local u4 = "rate"
                        local success, err, v3 = pcall(function()
                            -- Line: 50
                            -- upvalues: Api (upval), u4 (val), u0 (val)
                            return Api:InvokeServer(u4, u0)
                        end)

                        if success then
                            v1 = err
                            v2 = v3
                        else
                            v1 = nil
                            v2 = "No connection to the server."
                        end

                        if type(v1) ~= "table" then
                            toast((tostring(v2 or "Couldn't save the rating.")))
                            return
                        end

                        u3710.ratings[a1.id] = v1
                        local myRates = u3710.myRates
                        local id = a1.id
                        myRates[id] = if not (u12 > 0) then nil else u12

                        paintStars(u12)
                        u164:setText((fmtRating(a1.id)))
                        u1603.renderLib()
                    end)
                end)
            end

            v1 = {f = "m400_10_88", c = "muted"}
            id_2 = a1.id
            v4 = u3710.ratings[id_2]
            v1.t = if type(v4) ~= "table" then
                "No ratings yet"
            else
                if not ((v4.n or 0) <= 0) then
                    string.format("%.1f from %d vote%s", v4.s / v4.n, v4.n, if v4.n ~= 1 then "s" else "")
                else
                    "No ratings yet"
            v1.m = {0, 0, 0, 10}
            v1.parent = v6
            u164 = (text(v1))

            paintStars(u3710.myRates[a1.id] or 0)

            if LocalPlayer:GetAttribute("Admin") == true then
                box({grow = 1, parent = v6})

                u1603.bpmEditor(
                    v6,
                    a1.id,
                    false,
                    tonumber(a1.bpm),
                    function(a1_2)
                        -- Line: 3148
                        -- upvalues: a1 (val), u3710 (upval), u1805 (upval), u3682 (upval), Sheets (upval)
                        -- upvalues: u1603 (upval)
                        local activeId, v1
                        a1.bpm = a1_2

                        for i, j in u3710.index do
                            if j.id == a1.id then
                                v1 = j

                                if v1 then
                                    v1.bpm = a1_2
                                end

                                activeId = u1805.activeId

                                for k, n in u3682 do
                                    if n.id == activeId then
                                        v1 = n

                                        if u1805.activeId == a1.id
                                            or v1 and v1.pubId == a1.id then
                                            u1805.sheetBpm = a1_2
                                            u1603.setBpm(a1_2, false, true)
                                        end

                                        return
                                    end
                                end

                                for m, i5 in Sheets do
                                    if i5.id == activeId then
                                        v1 = i5

                                        if u1805.activeId == a1.id
                                            or v1 and v1.pubId == a1.id then
                                            u1805.sheetBpm = a1_2
                                            u1603.setBpm(a1_2, false, true)
                                        end

                                        return
                                    end
                                end

                                v1 = nil

                                if u1805.activeId == a1.id
                                    or v1 and v1.pubId == a1.id then
                                    u1805.sheetBpm = a1_2
                                    u1603.setBpm(a1_2, false, true)
                                end

                                return
                            end
                        end

                        v1 = nil

                        if v1 then
                            v1.bpm = a1_2
                        end

                        activeId = u1805.activeId

                        for i6, i7 in u3682 do
                            if i7.id == activeId then
                                v1 = i7

                                if u1805.activeId == a1.id
                                    or v1 and v1.pubId == a1.id then
                                    u1805.sheetBpm = a1_2
                                    u1603.setBpm(a1_2, false, true)
                                end

                                return
                            end
                        end

                        for i8, i9 in Sheets do
                            if i9.id == activeId then
                                v1 = i9

                                if u1805.activeId == a1.id
                                    or v1 and v1.pubId == a1.id then
                                    u1805.sheetBpm = a1_2
                                    u1603.setBpm(a1_2, false, true)
                                end

                                return
                            end
                        end

                        v1 = nil

                        if u1805.activeId == a1.id or v1 and v1.pubId == a1.id then
                            u1805.sheetBpm = a1_2
                            u1603.setBpm(a1_2, false, true)
                        end
                    end
                )
            end
        end

        v5 = box({
            grow = 1,
            vshrink = true,
            minH = 120,
            bg = "panel2",
            bd = 1,
            bdc = "line",
            r = 8,
            clip = true,
            parent = u8,
        })
        ScrollingFrame = Instance.new("ScrollingFrame")
        ScrollingFrame.BackgroundTransparency = 1
        ScrollingFrame.BorderSizePixel = 0
        ScrollingFrame.Size = UDim2.new(1, -8, 1, -4)
        ScrollingFrame.Position = UDim2.fromOffset(4, 2)
        ScrollingFrame.CanvasSize = UDim2.new()
        ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        ScrollingFrame.ScrollBarThickness = 6
        ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        ScrollingFrame.ZIndex = 65
        ScrollingFrame.Parent = v5.inst
        UIPadding = Instance.new("UIPadding")
        UIPadding.PaddingTop = UDim.new(0, 8)
        UIPadding.PaddingBottom = UDim.new(0, 8)
        UIPadding.PaddingLeft = UDim.new(0, 8)
        UIPadding.PaddingRight = UDim.new(0, 8)
        UIPadding.Parent = ScrollingFrame
        TextLabel = Instance.new("TextLabel")
        TextLabel.BackgroundTransparency = 1
        TextLabel.Size = UDim2.new(1, 0, 0, 0)
        TextLabel.AutomaticSize = Enum.AutomaticSize.Y
        TextLabel.TextWrapped = true
        TextLabel.RichText = true
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.TextYAlignment = Enum.TextYAlignment.Top
        TextLabel.FontFace = Font.fromEnum(Enum.Font.RobotoMono)
        TextLabel.TextSize = 17
        TextLabel.LineHeight = 1.3
        TextLabel.ZIndex = 66
        TextLabel.Text = "Loading…"
        TextLabel.Parent = ScrollingFrame

        function v5.onPaint() -- Line: 3190; upvalues: TextLabel (val), Lay (upval), ScrollingFrame (val)
            TextLabel.TextColor3 = Lay.TH.ink.c
            ScrollingFrame.ScrollBarImageColor3 = Lay.TH.muted.c
        end

        v5:paint()

        text_2 = a1.text

        function show(a1) -- Line: 3196; upvalues: u1578 (upval), Lay (upval), TextLabel (val); types: a1: string
            local v1
            _, v1 = u1578.parse(a1)
            local v2 = {}
            local v3 = 1
            local v4 = "#" .. Lay.TH.brassInk.c:ToHex()

            for i, j in v1 do
                table.insert(v2, (string.gsub(string.gsub(string.gsub(string.sub(a1, v3, j[1] - 1), "&", "&amp;"), "<", "&lt;"), ">", "&gt;")))
                table.insert(v2, "<font color=\"" .. v4 .. "\">" .. (string.gsub(string.gsub(string.gsub(string.sub(a1, j[1], j[2]), "&", "&amp;"), "<", "&lt;"), ">", "&gt;")) .. "</font>")

                v3 = j[2] + 1
            end

            table.insert(v2, (string.gsub(string.gsub(string.gsub(string.sub(a1, v3), "&", "&amp;"), "<", "&lt;"), ">", "&gt;")))

            TextLabel.Text = table.concat(v2)
        end

        v1 = box({
            dir = "row",
            wrap = true,
            gap = 8,
            justify = "between",
            align = "center",
            parent = u8,
        })
        v2 = box({dir = "row", wrap = true, gap = 8, parent = v1})
        v3 = btn("▶ Play", "primary")

        v2:add(v3)

        v4 = btn(if a2 ~= "mine" then "Open in editor" else "Edit")
        v2:add(v4)

        if a2 == "comm" then
            u424 = btn(if not u3724[a1.id] then "♥ Add to favourites" else "♥ In favourites")
            v1:add(u424)

            u424:onClick(function() -- Line: 3214; upvalues: toggleFav (upval), a1 (val), u424 (val), u3724 (upval)
                toggleFav(a1.id)
                u424.label:setText(if not u3724[a1.id] then "♥ Add to favourites" else "♥ In favourites")
            end)
        end

        if not text_2 then
            task.spawn(function()
                -- Line: 3220
                -- upvalues: u3710 (upval), a1 (val), Api (upval), u1642 (upval), u8 (val), TextLabel (val)
                -- upvalues: text_2 (ref), show (val)
                local v1 = u3710.texts[a1.id]

                if not v1 then
                    local id = a1.id
                    local u7 = "communitySheet"
                    local success, err = pcall(function() -- Line: 50; upvalues: Api (upval), u7 (val), id (val)
                        return Api:InvokeServer(u7, id)
                    end)
                    v1 = if success then err else nil
                end

                if u1642.dialog ~= u8 then
                    return
                end

                if type(v1) ~= "string" then
                    TextLabel.Text = "This sheet is no longer available."
                    return
                end

                u3710.texts[a1.id] = v1
                text_2 = v1

                show(v1)
            end)
        else
            show(text_2)
        end

        v3:onClick(function()
            -- Line: 3229
            -- upvalues: text_2 (ref), u1603 (upval), loadSheet (upval), a1 (val), u1631 (upval)
            if not text_2 then
                return
            end

            u1603.closeDialog()
            loadSheet(tostring(a1.title), text_2, a1.id)

            if u1631.hudOpen == false then
                u1603.setHudOpen(true)
            end
        end)

        v4:onClick(function() -- Line: 3235; upvalues: text_2 (ref), u1603 (upval), a2 (val), a1 (val)
            if not text_2 then
                return
            end

            u1603.closeDialog()

            if a2 == "mine" then
                u1603.openEditor(a1)
                return
            end

            u1603.openEditor({
                id = "copy",
                title = a1.title,
                text = text_2,
                level = a1.level,
                bpm = a1.bpm,
            })
        end)
    end

    local u2469 = {
        title = "",
        author = "",
        level = "",
        sort = "fav",
        asc = false,
        favOnly = false,
        page = 1,
        hist = false,
        gen = 0,
        perPage = 25,
        boxes = {},
    }
    local boxes = u2469.boxes

    local function v50(a1, a2)
        -- Line: 3249
        -- upvalues: input_2 (val), u1642 (val), boxes (val), u2469 (val), u1603 (val)
        -- types: a1: string, a2: string
        local u7
        _, u7 = input_2(u1642.libTools, a1)
        boxes[a2] = u7

        ;(u7:GetPropertyChangedSignal("Text")):Connect(function()
            -- Line: 3252
            -- upvalues: u2469 (upval), a2 (val), u7 (val), u1603 (upval)
            local v1 = u2469
            v1.gen = v1.gen + 1
            local gen = u2469.gen

            task.delay(
                0.15,
                function() -- Line: 3255; upvalues: gen (val), u2469 (upval), a2 (upval), u7 (upval), u1603 (upval)
                    if gen ~= u2469.gen then
                        return
                    end

                    u2469[a2] = (string.lower(u7.Text))
                    u2469.page = 1
                    u2469.hist = false

                    if u1603.renderLib then
                        u1603.renderLib()
                    end
                end
            )
        end)
    end

    v50("Search by title…", "title")
    v50("Search by author…", "author")
    v50("Search by difficulty…", "level")

    v50 = box({
        dir = "row",
        align = "center",
        justify = "between",
        gap = 8,
        wrap = true,
        rowGap = 6,
        pad = {2, 2},
        parent = u1642.libTools,
    })
    __real_registers[32] = box({
        dir = "row",
        align = "center",
        gap = 8,
        button = true,
        parent = v50,
    })
    local u2499 = checkbox(false)

    __real_registers[32]:add(u2499)
    text({t = "Favourites only", f = "s500_13_44", lh = v15(13.44), parent = __real_registers[32]})

    __real_registers[32]:onClick(function() -- Line: 3274; upvalues: u2499 (val), u2469 (val), u1603 (val)
        u2499.on = not u2499.on
        u2499:paint()

        u2469.favOnly = u2499.on
        u2469.page = 1
        u2469.hist = false

        u1603.renderLib()
    end)

    __real_registers[32] = box({dir = "row", align = "center", gap = 6, parent = v50})
    text({
        t = "Sort by:",
        f = "s500_13_44",
        c = "muted",
        lh = v15(13.44),
        parent = __real_registers[32],
    })

    local u2525 = {{"none", "Newest"}, {"rating", "Rating"}, {"fav", "Favourites"}}
    local u2537 = text({t = "Favourites", f = "s500_13_6", lh = 19.72})
    local u2557 = box({
        dir = "row",
        align = "center",
        gap = 6,
        pad = {3, 10},
        bd = 1,
        bdc = "line",
        bg = "panel2",
        r = 8,
        button = true,
        hov = {bdc = "btnHoverLine"},
        parent = __real_registers[32],
        {u2537, text({t = "▾", f = "s600_16", lh = 19.72, c = "muted"})},
    })

    u2557:bindHover()

    local u2563 = text({t = "▼", f = "s500_13_6", lh = 19.72, c = "muted"})
    __real_registers[33] = box({
        pad = {3, 8},
        bd = 1,
        bdc = "line",
        bg = "panel2",
        r = 8,
        button = true,
        hov = {bdc = "btnHoverLine"},
        parent = __real_registers[32],
        {u2563},
    })

    __real_registers[33]:bindHover()

    local function setSort(a1)
        -- Line: 3292
        -- upvalues: u2469 (val), u2525 (val), u2537 (val), u1603 (val)
        -- types: a1: string
        u2469.sort = a1

        for i, j in u2525 do
            if j[1] == a1 then
                u2537:setText(j[2])
            end
        end

        u2469.page = 1
        u2469.hist = false

        if u1603.renderLib then
            u1603.renderLib()
        end
    end

    u2557:onClick(function()
        -- Line: 3299
        -- upvalues: u2388 (ref), u2557 (val), Lay (val), u1603 (val), openMenu (val), u2525 (val), menuItem (val)
        -- upvalues: u2469 (val), setSort (val)
        if u2388 and u2388.anchor == u2557 then
            if u2388 then
                u2388:destroy()

                u2388 = nil
                Lay.dirty()
            end

            return
        end

        local v1, v2 = u1603.at(u2557)
        local v3 = openMenu(v1, v2 + (u2557.lh_ or 26) + 4, 160, v2 - 4)
        v3.anchor = u2557
        local v4 = nil
        local v5 = nil

        for i, j in u2525, v4, v5 do
            menuItem(
                v3,
                j[2],
                j[1] == u2469.sort,
                function() -- Line: 3305; upvalues: setSort (upval), j (val)
                    setSort(j[1])
                end
            )
        end
    end)

    local function v53(a1) -- Line: 3308; upvalues: u2469 (val), u2563 (val); types: a1: boolean
        u2469.asc = a1
        u2563:setText(if not a1 then "▼" else "▲")
    end

    __real_registers[33]:onClick(function() -- Line: 3312; upvalues: u2469 (val), u2563 (val), u1603 (val)
        local v1 = not u2469.asc
        u2469.asc = v1

        u2563:setText(if not v1 then "▼" else "▲")

        u2469.page = 1
        u1603.renderLib()
    end)

    local u2598 = box({
        dir = "row",
        justify = "between",
        align = "center",
        pad = {2, 2},
        parent = u1642.libTools,
    })

    local function v54(a1) -- Line: 3320; upvalues: text (val), box (val), u2598 (val); types: a1: string
        local v1 = text({f = "s600_14", lh = 20.3, c = "ink", t = a1})
        local v2 = box({
            pad = {4, 10},
            r = 6,
            button = true,
            hov = {bg = "white05"},
            parent = u2598,
            {v1},
        })

        v2:bindHover()

        v2.label = v1

        return v2
    end

    __real_registers[34] = v54("RESET")
    __real_registers[35] = v54("RANDOM")
    __real_registers[36] = v54("HISTORY")
    u1642.libHistBtn = __real_registers[36]
    u1642.libResetBtn = __real_registers[34]
    u1642.libRandomBtn = __real_registers[35]

    function u2469.reset() -- Line: 3333; upvalues: boxes (val), u2469 (val), u2499 (val), u2563 (val), setSort (val)
        for i, j in boxes do
            j.Text = ""
        end

        u2469.title = ""
        u2469.author = ""
        u2469.level = ""
        u2499.on = false

        u2499:paint()

        u2469.favOnly = false
        u2469.asc = false

        u2563:setText("▼")
        setSort("fav")
    end

    __real_registers[34]:onClick(function() -- Line: 3342; upvalues: u2469 (val)
        u2469.reset()
    end)

    __real_registers[35]:onClick(function() -- Line: 3343; upvalues: u1603 (val), toast (val)
        local v1 = u1603.libFiltered()

        if #v1 == 0 then
            toast("Nothing to pick from.")
            return
        end

        u1603.openPreview(v1[math.random(1, #v1)], "comm")
    end)

    __real_registers[36]:onClick(function() -- Line: 3348; upvalues: u2469 (val), u1603 (val)
        u2469.hist = not u2469.hist
        u1603.renderLib()
    end)

    function u1603.libMatches(a1, a2) -- Line: 3354; upvalues: u2469 (val), Levels (val); types: a2: string?
        if u2469.title ~= ""
            and not string.find(string.lower((tostring(a1.title or ""))), u2469.title, 1, true) then
            return false
        end

        if u2469.author ~= "" then
            local find_2 = string.find
            local lower_2 = string.lower

            if not find_2(lower_2((tostring(a2 or a1.authorName or ""))), u2469.author, 1, true) then
                return false
            end
        end

        if u2469.level == "" then
            return true
        end

        local v1 = Levels.get(a1.level)

        if v1 and string.find(string.lower(v1.name), u2469.level, 1, true) then
            return true
        end

        return false
    end

    function u1603.libFiltered() -- Line: 3364; upvalues: u3710 (val), u1603 (val), u2469 (val), u3724 (ref)
        local v1 = {}
        local v2 = nil
        local v3 = nil

        for i, j in u3710.index, v2, v3 do
            if u1603.libMatches(j) then
                if not u2469.favOnly or u3724[j.id] then
                    table.insert(v1, j)
                end
            end
        end

        local sort = u2469.sort
        local asc = u2469.asc

        table.sort(
            v1,
            function(a1, a2) -- Line: 3370; upvalues: sort (val), u3710 (upval), asc (val)
                local v1, v2

                if sort == "fav" then
                    v1 = u3710.stars[a1.id] or 0
                    v2 = u3710.stars[a2.id] or 0
                elseif sort ~= "rating" then
                    v1 = a1.at or 0
                    v2 = a2.at or 0
                else
                    local n, n_2, v3, v4
                    local id = a1.id
                    local v5 = u3710.ratings[id]

                    if type(v5) ~= "table" then
                        v3 = 0
                        n = 0
                    elseif not ((v5.n or 0) <= 0) then
                        v3 = v5.s / v5.n
                        n = v5.n
                    else
                        v3 = 0
                        n = 0
                    end

                    local id_2 = a2.id
                    local v6 = u3710.ratings[id_2]

                    if type(v6) ~= "table" then
                        v4 = 0
                        n_2 = 0
                    elseif not ((v6.n or 0) <= 0) then
                        v4 = v6.s / v6.n
                        n_2 = v6.n
                    else
                        v4 = 0
                        n_2 = 0
                    end

                    v1 = v3 * 1000 + n
                    v2 = v4 * 1000 + n_2
                end

                if v1 == v2 then
                    local v7 = a1.at or 0
                    return (a2.at or 0) < v7
                end

                if asc then
                    return v1 < v2
                end

                return v2 < v1
            end
        )

        return v1
    end

    function u1603.renderLib()
        -- Line: 3388
        -- upvalues: u1642 (val), u2469 (val), text (val), box (val), u1805 (val), levelBadge (val), u1578 (val)
        -- upvalues: u1603 (val), smallBtn (val), u3710 (val), u3724 (ref), toggleFav (val), LocalPlayer (val)
        -- upvalues: Api (val), toast (val), u1631 (val), u3682 (ref), Sheets (val), note (val), Lay (val)
        local head, hist, id, id_2, index, label, row, u168, u364, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12,
            v13, v14
        local dispatch = 0

        while true do
            if dispatch < 44 then
                if dispatch < 30 then
                    if dispatch < 5 then
                        if dispatch < 2 then
                            if dispatch < 1 then
                                u1642.libList:clear()

                                dispatch = if not u1642.libHistBtn then 5 else 1
                            else
                                label = u1642.libHistBtn.label
                                dispatch = if not u2469.hist then 3 else 2
                            end
                        elseif dispatch < 3 then
                            v2 = "brassInk"
                            dispatch = 4
                        elseif dispatch < 4 then
                            v2 = "ink"
                            dispatch = 4
                        else
                            label.c = v2
                            u1642.libHistBtn.label:paint()

                            dispatch = 5
                        end
                    elseif dispatch < 27 then
                        if dispatch < 6 then
                            function head(a1)
                                -- Line: 3394
                                -- upvalues: u1642 (upval), text (upval)
                                -- types: a1: string
                                u1642.libList:add(
                                    (text({
                                        f = "m500_9_92",
                                        up = true,
                                        ls = 0.992,
                                        c = "muted",
                                        t = a1,
                                        m = {6, 2, 0, 2},
                                    }))
                                )
                            end

                            function row(a1, a2)
                                -- Line: 3398
                                -- upvalues: box (upval), u1642 (upval), u1805 (upval), text (upval), levelBadge (upval)
                                -- upvalues: u1578 (upval), u1603 (upval), smallBtn (upval), u3710 (upval)
                                -- upvalues: u3724 (upval), toggleFav (upval), LocalPlayer (upval), Api (upval)
                                -- upvalues: toast (upval)
                                -- types: a2: string
                                local n, v1
                                local v2 = box({dir = "row", align = "center", gap = 6, parent = u1642.libList})
                                local v3 = u1805.activeId == a1.id
                                local v4 = box
                                local v5 = {
                                    dir = "col",
                                    gap = 2,
                                    grow = 1,
                                    shrink0 = true,
                                    r = 8,
                                    bd = 1,
                                    button = true,
                                    pad = {6, 8},
                                }
                                local v6 = if not v3 then {a = 0, c = Color3.new()} else "brass50"
                                v5.bdc = v6
                                v5.bg = if not v3 then nil else "brassSoft"
                                v5.hov = if not v3 then {bg = "panel2"} else nil
                                v5.parent = v2
                                v4 = v4(v5)

                                if not v3 then
                                    v4:bindHover()
                                end

                                text({
                                    f = "s500_14_08",
                                    ell = true,
                                    t = a1.title,
                                    lh = 20.416,
                                    parent = v4,
                                })

                                v3 = box({dir = "row", align = "center", gap = 6, parent = v4})
                                v5 = levelBadge(a1.level)

                                if v5 then
                                    v3:add(v5)
                                end

                                v5 = {}

                                if a2 ~= "comm" then
                                    if a1.status ~= "rejected" then
                                        table.insert(
                                            v5,
                                            {t = #u1578.parse(a1.text) .. " steps"}
                                        )
                                    else
                                        table.insert(
                                            v5,
                                            {t = "rejected", c = "bad"}
                                        )
                                    end

                                    if a1.status == "pending" then
                                        table.insert(
                                            v5,
                                            {
                                                c = "brassInk",
                                                t = if not a1.pubId then
                                                    " · in review"
                                                else
                                                    " · changes in review",
                                            }
                                        )
                                    elseif a1.status == "published" then
                                        table.insert(
                                            v5,
                                            {t = " · published", c = "ok"}
                                        )

                                        if a1.edited then
                                            table.insert(
                                                v5,
                                                {t = ", edited", c = "brassInk"}
                                            )
                                        end
                                    end
                                else
                                    table.insert(
                                        v5,
                                        {
                                            c = "brassInk",
                                            t = tostring(a1.authorName or "?"),
                                        }
                                    )

                                    table.insert(
                                        v5,
                                        {
                                            t = " · " .. (tostring((tonumber(a1.steps)) or 0)) .. " steps",
                                        }
                                    )
                                end

                                text({
                                    f = "m400_10_88",
                                    c = "muted",
                                    ell = true,
                                    shrink0 = true,
                                    grow = 1,
                                    runs = v5,
                                    parent = v3,
                                })

                                v4:onClick(function() -- Line: 3425; upvalues: a1 (val), u1603 (upval), a2 (val)
                                    if a1.status == "rejected" then
                                        u1603.openEditor(a1)
                                        return
                                    end

                                    u1603.openPreview(a1, a2)
                                end)

                                if a2 == "mine" then
                                    (smallBtn(v2, "Edit")):onClick(function()
                                        -- Line: 3429
                                        -- upvalues: u1603 (upval), a1 (val)
                                        u1603.openEditor(a1)
                                    end)
                                    return
                                end

                                local id_2 = a1.id
                                v5 = u3710.ratings[id_2]

                                if type(v5) ~= "table" then
                                    v6 = 0
                                    n = 0
                                elseif not ((v5.n or 0) <= 0) then
                                    v6 = v5.s / v5.n
                                    n = v5.n
                                else
                                    v6 = 0
                                    n = 0
                                end

                                v4 = u3710.myRates[a1.id]
                                local v7 = if not v4 then "muted" else "brassInk"
                                local v8 = smallBtn(v3, if not (n > 0) then "★ Rate" else string.format("★ %.1f", v6), v7, true)

                                v8:onClick(function() -- Line: 3435; upvalues: u1603 (upval), a1 (val)
                                    u1603.openPreview(a1, "comm")
                                end)

                                local v9 = if not (u3724[a1.id] == true) then "muted" else "brassInk"
                                local v10 = smallBtn(v3, "♥ " .. tostring(u3710.stars[a1.id] or 0), v9, true)

                                if v1 then
                                    v10.bdc = "brass50"
                                    v10.bg = "brassSoft"

                                    v10:paint()
                                end

                                if u1603.hasIcons() then
                                    v8.label:setText(if not (n > 0) then "Rate" else string.format("%.1f", v6))

                                    v9 = if not v4 then "star" else "star-fill"
                                    u1603.iconify(v8, v9, 11)
                                    v10.label:setText((tostring(u3710.stars[a1.id] or 0)))

                                    v9 = if not v1 then "heart" else "heart-fill"
                                    u1603.iconify(v10, v9, 11)
                                end

                                v10:onClick(function() -- Line: 3445; upvalues: toggleFav (upval), a1 (val)
                                    toggleFav(a1.id)
                                end)

                                if LocalPlayer:GetAttribute("Admin") == true then
                                    (smallBtn(v2, "Edit")):onClick(function()
                                        -- Line: 3447
                                        -- upvalues: u1603 (upval), a1 (val)
                                        u1603.adminEdit(a1)
                                    end)

                                    local u373 = smallBtn(v2, "×", "bad")
                                    local u374 = false

                                    u373:onClick(function()
                                        -- Line: 3450
                                        -- upvalues: u374 (ref), u373 (val), a1 (val), Api (upval), u1603 (upval)
                                        -- upvalues: toast (upval)
                                        if u374 then
                                            u374 = false
                                            task.spawn(function()
                                                -- Line: 3458
                                                -- upvalues: a1 (upval), Api (upval), u1603 (upval), toast (upval)
                                                local id = a1.id
                                                local u2 = "unpublish"
                                                local success, err = pcall(function()
                                                    -- Line: 50
                                                    -- upvalues: Api (upval), u2 (val), id (val)
                                                    return Api:InvokeServer(u2, id)
                                                end)

                                                if if success then err else nil then
                                                    u1603.loadCommunity(true)
                                                    u1603.renderLib()
                                                    toast("Sheet removed.")
                                                end
                                            end)

                                            return
                                        end

                                        u374 = true
                                        u373.label:setText("Remove?")

                                        task.delay(
                                            3,
                                            function() -- Line: 3454; upvalues: u374 (upval), u373 (upval)
                                                if u374 then
                                                    u374 = false
                                                    u373.label:setText("×")
                                                end
                                            end
                                        )
                                    end)
                                end
                            end

                            dispatch = if not u2469.hist then 30 else 6
                        else
                            head("History")

                            v7 = 0
                            hist = u1631.hist
                            v9 = nil
                            v10 = nil
                            local dispatchExit = nil

                            for i13, i14 in hist, v9, v10 do
                                local dispatch2 = 7

                                while true do
                                    if dispatch2 < 18 then
                                        if dispatch2 < 15 then
                                            if dispatch2 < 11 then
                                                id = i14.id
                                                v3 = u3682
                                                v4 = nil
                                                v5 = nil
                                                local dispatchExit2 = nil

                                                for i15, i16 in v3, v4, v5 do
                                                    local dispatch3 = 8

                                                    while true do
                                                        if not (dispatch3 < 9) then
                                                            v13 = i16
                                                            dispatchExit2 = 16
                                                            break
                                                        end

                                                        if i16.id ~= id then
                                                            break
                                                        else
                                                            dispatch3 = 9
                                                        end
                                                    end

                                                    if dispatchExit2 then
                                                        break
                                                    end
                                                end

                                                dispatch2 = if dispatchExit2 == 16 then 16 else 11
                                            else
                                                v3 = Sheets
                                                v4 = nil
                                                v5 = nil
                                                local dispatchExit3 = nil

                                                for i17, i18 in v3, v4, v5 do
                                                    local dispatch4 = 12

                                                    while true do
                                                        if not (dispatch4 < 13) then
                                                            v13 = i18
                                                            dispatchExit3 = 16
                                                            break
                                                        end

                                                        if i18.id ~= id then
                                                            break
                                                        else
                                                            dispatch4 = 13
                                                        end
                                                    end

                                                    if dispatchExit3 then
                                                        break
                                                    end
                                                end

                                                dispatch2 = if dispatchExit3 == 16 then 16 else 15
                                            end
                                        elseif dispatch2 < 16 then
                                            v13 = nil
                                            dispatch2 = 16
                                        else
                                            dispatch2 = if dispatch2 < 17 then
                                                if not v13 then 19 else 17
                                            else
                                                if string.find(i14.id, "^lib") then 19 else 18
                                        end
                                    elseif dispatch2 < 23 then
                                        if dispatch2 < 19 then
                                            row(v13, "mine")

                                            v7 = v7 + 1
                                            break
                                        else
                                            id_2 = i14.id
                                            index = u3710.index
                                            v5 = nil
                                            v6 = nil
                                            local dispatchExit4 = nil

                                            for i19, i20 in index, v5, v6 do
                                                local dispatch5 = 20

                                                while true do
                                                    if not (dispatch5 < 21) then
                                                        v14 = i20
                                                        dispatchExit4 = 24
                                                        break
                                                    end

                                                    if i20.id ~= id_2 then
                                                        break
                                                    else
                                                        dispatch5 = 21
                                                    end
                                                end

                                                if dispatchExit4 then
                                                    break
                                                end
                                            end

                                            dispatch2 = if dispatchExit4 == 24 then 24 else 23
                                        end
                                    elseif dispatch2 < 24 then
                                        v14 = nil
                                        dispatch2 = 24
                                    else
                                        if not (dispatch2 < 25) then
                                            row(v14, "comm")

                                            v7 = v7 + 1
                                            break
                                        end

                                        if not v14 then
                                            break
                                        else
                                            dispatch2 = 25
                                        end
                                    end
                                end

                                if dispatchExit then
                                    break
                                end
                            end

                            dispatch = 27
                        end
                    elseif dispatch < 28 then
                        dispatch = if v7 ~= 0 then 29 else 28
                    else
                        if not (dispatch < 29) then
                            Lay.dirty()
                            return
                        end

                        u1642.libList:add(
                            (note(
                                "Nothing yet. Sheets you open show up here.",
                                {pad = {2, 8}}
                            ))
                        )

                        dispatch = 29
                    end
                elseif dispatch < 38 then
                    if dispatch < 35 then
                        if dispatch < 31 then
                            dispatch = if u2469.favOnly then 51 else 31
                        else
                            v7 = {}
                            v8 = u3682
                            v9 = nil
                            v10 = nil
                            local dispatchExit5 = nil

                            for i21, i22 in v8, v9, v10 do
                                local dispatch6 = 32

                                while true do
                                    if not (dispatch6 < 33) then
                                        table.insert(v7, i22)
                                        break
                                    end

                                    if not u1603.libMatches(i22, LocalPlayer.Name) then
                                        break
                                    else
                                        dispatch6 = 33
                                    end
                                end

                                if dispatchExit5 then
                                    break
                                end
                            end

                            dispatch = 35
                        end
                    elseif dispatch < 36 then
                        dispatch = if u1631.mineFold == true then 37 else 36
                    else
                        u168 = not (dispatch < 37)
                        dispatch = 38
                    end
                elseif dispatch < 41 then
                    if dispatch < 39 then
                        v9 = box({
                            dir = "row",
                            align = "center",
                            gap = 6,
                            r = 6,
                            button = true,
                            pad = {1, 6, 1, 2},
                            m = {4, 0, 0, 0},
                            hov = {bg = "panel2"},
                            parent = u1642.libList,
                        })
                        v9:bindHover()

                        v10 = text
                        v11 = {f = "m500_9_92", up = true, ls = 0.992, c = "muted"}
                        dispatch = if not (#u3682 > 0) then 40 else 39
                    else
                        v14 = if dispatch < 40 then " · " .. #u3682 else ""
                        dispatch = 41
                    end
                elseif dispatch < 42 then
                    v11.t = "My sheets" .. v14
                    v11.parent = v9

                    v10(v11)

                    v10 = text({
                        t = "▾",
                        f = "s600_16",
                        lh = 19.72,
                        c = "muted",
                        parent = v9,
                    })
                    dispatch = if not u168 then 43 else 42
                elseif dispatch < 43 then
                    v10.inst.Rotation = -90
                    dispatch = 43
                else
                    v9:onClick(function() -- Line: 3497; upvalues: u1631 (upval), u168 (val), u1603 (upval)
                        u1631.mineFold = not u168
                        u1603.savePref("mineFold", u1631.mineFold)
                        u1603.renderLib()
                    end)

                    dispatch = if u168 then 51 else 44
                end
            elseif dispatch < 58 then
                if dispatch < 51 then
                    if dispatch < 46 then
                        if dispatch < 45 then
                            dispatch = if #u3682 ~= 0 then 46 else 45
                        else
                            u1642.libList:add(
                                (note(
                                    "Nothing here yet. Press \"Paste notes\" and save a sheet.",
                                    {pad = {2, 8}}
                                ))
                            )

                            dispatch = 48
                        end
                    elseif dispatch < 47 then
                        dispatch = if #v7 ~= 0 then 48 else 47
                    elseif dispatch < 48 then
                        u1642.libList:add(
                            (note(
                                "No matches.",
                                {pad = {2, 8}}
                            ))
                        )

                        dispatch = 48
                    else
                        v11 = v7
                        v12 = nil
                        v13 = nil
                        local dispatchExit6 = nil

                        for i23, i24 in v11, v12, v13 do
                            local dispatch7 = 49

                            while true do
                                row(i24, "mine")
                                break
                            end

                            if dispatchExit6 then
                                break
                            end
                        end

                        dispatch = 51
                    end
                elseif dispatch < 53 then
                    if dispatch < 52 then
                        head("Sheet music")

                        v1 = u1603.libFiltered()
                        dispatch = if #v1 ~= 0 then 58 else 52
                    else
                        dispatch = if u3710.ready then 58 else 53
                    end
                elseif dispatch < 54 then
                    v7 = u1642
                    v9 = {pad = {2, 8}}
                    v10 = {
                        t = "Loading sheets",
                        f = "s400_12_8",
                        lh = 18.56,
                        c = "muted",
                        wrap = true,
                    }
                    dispatch = if not v9 then 57 else 54
                elseif dispatch < 57 then
                    v11 = v9
                    v12 = nil
                    v13 = nil
                    local dispatchExit7 = nil

                    for i25, i26 in v11, v12, v13 do
                        local dispatch8 = 55

                        while true do
                            v10[i25] = i26
                            break
                        end

                        if dispatchExit7 then
                            break
                        end
                    end

                    dispatch = 57
                else
                    v7.libLoading = text(v10)
                    u1642.libList:add(u1642.libLoading)

                    dispatch = 65
                end
            elseif dispatch < 63 then
                if dispatch < 60 then
                    dispatch = if dispatch < 59 then
                        if #v1 ~= 0 then 65 else 59
                    else
                        if #u3710.index ~= 0 then 61 else 60
                elseif dispatch < 61 then
                    v7 = "No sheets yet. Write one and press \"Submit for review\": after an admin approves it, it shows up here."
                    dispatch = 64
                elseif dispatch < 62 then
                    dispatch = if not u2469.favOnly then 63 else 62
                else
                    v7 = "No favourites here yet. Press ♥ on a sheet to add it."
                    dispatch = 64
                end
            elseif dispatch < 67 then
                if dispatch < 64 then
                    v7 = "Nothing found."
                    dispatch = 64
                elseif dispatch < 65 then
                    u1642.libList:add(
                        (note(
                            v7,
                            {pad = {2, 8}}
                        ))
                    )

                    dispatch = 65
                else
                    u364 = math.max(1, (math.ceil(#v1 / u2469.perPage)))
                    u2469.page = math.clamp(u2469.page, 1, u364)
                    v10 = (u2469.page - 1) * u2469.perPage + 1
                    v8 = math.min(#v1, u2469.page * u2469.perPage)
                    local dispatchExit8 = nil

                    for i27 = v10, v8 do
                        row(v1[i27], "comm")
                    end

                    dispatch = 67
                end
            elseif dispatch < 68 then
                dispatch = if not (u364 > 1) then 69 else 68
            else
                if not (dispatch < 69) then
                    Lay.dirty()
                    return
                end

                v2 = box({
                    dir = "row",
                    align = "center",
                    justify = "center",
                    gap = 10,
                    pad = {6, 0},
                    parent = u1642.libList,
                })
                v1 = smallBtn(v2, "<")

                v2:add(
                    (text({
                        f = "m500_10_24",
                        ls = 1.024,
                        c = "muted",
                        t = "PAGE " .. u2469.page .. " / " .. u364,
                    }))
                )

                v8 = smallBtn(v2, ">")
                v1:onClick(function() -- Line: 3530; upvalues: u2469 (upval), u1603 (upval)
                    if 1 < u2469.page then
                        local v1 = u2469
                        v1.page = v1.page - 1

                        u1603.renderLib()
                    end
                end)

                v8:onClick(function() -- Line: 3531; upvalues: u2469 (upval), u364 (val), u1603 (upval)
                    if u2469.page < u364 then
                        local v1 = u2469
                        v1.page = v1.page + 1

                        u1603.renderLib()
                    end
                end)

                dispatch = 69
            end
        end
    end

    __real_registers[11].OnClientEvent:Connect(function(a1) -- Line: 3535; upvalues: u3682 (ref), u1603 (val)
        if type(a1) ~= "table" then
            return
        end

        u3682 = a1
        task.spawn(function() -- Line: 3538; upvalues: u1603 (upval)
            u1603.loadCommunity(true)
            u1603.renderLib()
        end)
    end)

    u1642.titleBtn:onClick(function() -- Line: 3542; upvalues: u1631 (val), u1642 (val), u1603 (val)
        if u1631.fullscreen then
            return
        end

        if u1642.hudDragAt and os.clock() - u1642.hudDragAt < 0.3 then
            return
        end

        if u1631.collapsed then
            u1603.setCollapsed(false)
        end

        u1603.showTab("lib")
    end)

    local u2636 = 0

    __real_registers[11] = function() -- Line: 3551; upvalues: u1642 (val)
        local inst = u1642.chatList.inst
        local Y = inst.CanvasPosition.Y

        return inst.AbsoluteCanvasSize.Y - inst.AbsoluteSize.Y - 40 <= Y
    end

    function v50() -- Line: 3555; upvalues: Lay (val), u1642 (val)
        task.defer(function() -- Line: 3556; upvalues: Lay (upval), u1642 (upval)
            Lay.now()

            local inst = u1642.chatList.inst
            inst.CanvasPosition = Vector2.new(0, (math.max(0, inst.AbsoluteCanvasSize.Y - inst.AbsoluteSize.Y)))
        end)
    end

    local function addChat(a1, a2) -- Line: 3562; upvalues: u1642 (val), u2636 (ref), Lay (val); types: a2: boolean?
        local inst = u1642.chatList.inst
        local Y = inst.CanvasPosition.Y
        local v1 = inst.AbsoluteCanvasSize.Y - inst.AbsoluteSize.Y - 40 <= Y
        u2636 = u2636 + 1

        u1642.chatList:add(a1)

        if #u1642.chatList.kids > 150 then
            u1642.chatList.kids[1]:destroy()
        end

        Lay.dirty()

        if v1 or a2 then
            task.defer(function() -- Line: 3556; upvalues: Lay (upval), u1642 (upval)
                Lay.now()

                local inst = u1642.chatList.inst
                inst.CanvasPosition = Vector2.new(0, (math.max(0, inst.AbsoluteCanvasSize.Y - inst.AbsoluteSize.Y)))
            end)
        end
    end

    local function v58(a1) -- Line: 3570; upvalues: addChat (val), text (val); types: a1: string
        addChat(
            text({
                f = "si400_12_8",
                lh = 17.919999999999998,
                c = "dim",
                align = "c",
                wrap = true,
                t = a1,
            })
        )
    end

    u1603.sysMsg = v58
    local u2641 = {
        [Enum.TextChatMessageStatus.Floodchecked] = "You're sending messages too fast.",
        [Enum.TextChatMessageStatus.TextFilterFailed] = "Roblox couldn't check this message. It wasn't sent.",
        [Enum.TextChatMessageStatus.InvalidPrivacySettings] = "Your Roblox chat settings don't allow chatting here.",
        [Enum.TextChatMessageStatus.InvalidTextChannelPermissions] = "You can't chat in this channel.",
        [Enum.TextChatMessageStatus.MessageTooLong] = "The message is too long.",
        [Enum.TextChatMessageStatus.ModerationTimeout] = "The chat check timed out. Try again.",
    }

    TextChatService.MessageReceived:Connect(function(a1)
        -- Line: 3582
        -- upvalues: LocalPlayer (val), u2641 (val), addChat (val), text (val), Players (val), u1959 (val), u1603 (val)
        -- types: a1: userdata
        local TextSource = a1.TextSource

        if not TextSource then
            return
        end

        if a1.Status ~= Enum.TextChatMessageStatus.Success then
            if TextSource.UserId == LocalPlayer.UserId then
                addChat(
                    text({
                        f = "si400_12_8",
                        lh = 17.919999999999998,
                        c = "dim",
                        align = "c",
                        wrap = true,
                        t = u2641[a1.Status]
                            or "Message not delivered (" .. a1.Status.Name .. ").",
                    })
                )
            end

            return
        end

        local PlayerByUserId = Players:GetPlayerByUserId(TextSource.UserId)
        local DisplayName = if not PlayerByUserId then "Player" else PlayerByUserId.DisplayName
        local v1 = string.gsub(string.gsub(string.gsub(a1.Text, "&lt;", "<"), "&gt;", ">"), "&amp;", "&")
        local v2 = {f = "s400_14_08", lh = 19.712, wrap = true, breakAll = true}
        local v3 = {}
        local v4 = {f = "s600_14_08", t = DisplayName .. ": "}
        local v5 = {a = 1}
        local UserId_2 = TextSource.UserId
        v5.c = if UserId_2 ~= LocalPlayer.UserId then
            Color3.fromHex(u1959[UserId_2 % (#u1959 - 1) + 1])
        else
            Color3.fromHex("e6e6e6")
        v4.c = v5
        v3[1] = v4
        v3[2] = {t = v1}
        v2.runs = v3

        addChat(text(v2), TextSource.UserId == LocalPlayer.UserId)
        u1603.chatNew(TextSource.UserId)
    end)

    local function sendChat()
        -- Line: 3599
        -- upvalues: u1642 (val), Api (val), addChat (val), text (val), TextChatService (val), toast (val)
        local u6 = string.sub(u1642.chatInput.Text, 1, 200)

        if string.gsub(u6, "%s", "") == "" then
            return
        end

        u1642.chatInput.Text = ""
        local v1 = string.match(u6, "^%s*/(%a+)")

        if v1 then
            local v2 = {kick = true, ban = true, unban = true, help = true}

            if v2[string.lower(v1)] then
                task.spawn(function() -- Line: 3605; upvalues: u6 (val), Api (upval), addChat (upval), text (upval)
                    local v1, v2
                    local u4 = string.gsub(u6, "^%s+", "")
                    local u5 = "command"
                    local success, err, v3 = pcall(function() -- Line: 50; upvalues: Api (upval), u5 (val), u4 (val)
                        return Api:InvokeServer(u5, u4)
                    end)

                    if success then
                        v1 = err
                        v2 = v3
                    else
                        v1 = nil
                        v2 = "No connection to the server."
                    end

                    local v4 = if type(v1) ~= "string" then
                        tostring(v2 or "No answer from the server.")
                    else
                        v1
                    addChat(
                        text({
                            f = "si400_12_8",
                            lh = 17.919999999999998,
                            c = "dim",
                            align = "c",
                            wrap = true,
                            t = v4,
                        })
                    )
                end)
                return
            end
        end

        local TextChannels = TextChatService:FindFirstChild("TextChannels")

        if TextChannels then
            TextChannels = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        end

        if not TextChannels then
            toast("Chat isn't ready yet.")
            return
        end

        if not pcall(function() -- Line: 3613; upvalues: TextChannels (val), u6 (val)
            TextChannels:SendAsync(u6)
        end) then
            toast("Message not sent.")
        end
    end

    u1642.chatInput.FocusLost:Connect(function(a1) -- Line: 3616; upvalues: sendChat (val)
        if a1 then
            sendChat()
        end
    end)

    __real_registers[12].OnClientEvent:Connect(function(a1)
        -- Line: 3618
        -- upvalues: LocalPlayer (val), u1603 (val), u1631 (val), addChat (val), text (val)
        if type(a1) ~= "table" then
            return
        end

        if (tonumber(a1.toId)) == LocalPlayer.UserId and u1603.donationAlert then
            u1603.donationAlert(a1)
        end

        if u1631.donChat ~= false and not a1.quiet then
            if a1.gift then
                addChat(
                    text({
                        f = "s400_14_08",
                        lh = 19.712,
                        wrap = true,
                        c = "ink",
                        runs = {
                            {t = "♥ ", c = "brass"},
                            {f = "s600_14_08", c = "brassInk", t = tostring(a1.from)},
                            {t = " gifted "},
                            {f = "s600_14_08", c = "brassInk", t = tostring(a1.gift)},
                            {t = " to "},
                            {f = "s600_14_08", c = "brassInk", t = tostring(a1.to)},
                            {t = if not a1.global then "!" else " (on another server)"},
                        },
                    }),
                    true
                )
                return
            end

            local v1 = tonumber(a1.amount) or 0
            local v2 = {}
            local v3 = {f = "s600_14_08", c = "brassInk", t = tostring(a1.from)}
            local v4 = {f = "s600_14_08", c = "brassInk"}
            local v5 = if not u1603.fmtNum then tostring(v1) else u1603.fmtNum(v1)
            v4.t = v5 .. " R$"
            v5 = {f = "s600_14_08", c = "brassInk", t = tostring(a1.to)}
            local v6 = {
                t = if not a1.global then
                    if not a1.test then "!" else " (Studio test, not counted)"
                else
                    " (on another server)",
            }
            v2[1] = {t = "♥ ", c = "brass"}
            v2[2] = v3
            v2[3] = {t = " donated "}
            v2[4] = v4
            v2[5] = {t = " to "}
            v2[6] = v5
            v2[7] = v6

            addChat(
                text({
                    f = "s400_14_08",
                    lh = 19.712,
                    wrap = true,
                    c = "ink",
                    runs = v2,
                }),
                true
            )
        end
    end)

    u1642.chatSend:onClick(sendChat)

    local u2680 = {}
    local u2681 = {}

    local function renderPlayers()
        -- Line: 3652
        -- upvalues: u1642 (val), u2681 (val), Players (val), LocalPlayer (val), VP (val), u1959 (val), box (val)
        -- upvalues: u1603 (val), text (val), u1578 (val), tag (val), Lay (val)
        local UserId, v1
        u1642.chips:clear()
        table.clear(u2681)

        local Players_2 = Players:GetPlayers()
        table.sort(
            Players_2,
            function(a1, a2) -- Line: 3656; upvalues: LocalPlayer (upval)
                local v1 = false

                if a1 == LocalPlayer then
                    v1 = a2 ~= LocalPlayer
                end

                return v1
            end
        )

        local v2 = math.max(1, #Players_2)
        u1642.playersCount:setText(v2 .. " " .. (if v2 ~= 1 then "players" else "player"))

        v2 = VP:GetAttribute("IsRoom") == true
        local Attribute = VP:GetAttribute("RoomHost")
        local v3 = nil
        local v4 = nil

        for i, j in Players_2, v3, v4 do
            UserId = j.UserId
            v1 = if UserId ~= LocalPlayer.UserId then
                Color3.fromHex(u1959[UserId % (#u1959 - 1) + 1])
            else
                Color3.fromHex("e6e6e6")
            local u133 = box({
                dir = "row",
                align = "center",
                gap = 6,
                bd = 1,
                bdc = "line",
                bg = "panel2",
                r = 7,
                maxW = 294,
                pad = {3, 8},
                parent = u1642.chips,
                button = j ~= LocalPlayer,
                hov = if j == LocalPlayer then nil else {bdc = "btnHoverLine"},
                sty = {
                    talk = {bdc = "ok", bd = 2},
                    play = {bg = {a = 0.16, c = v1}, bdc = {a = 0.75, c = v1}},
                    playbg = {bg = {a = 0.16, c = v1}},
                },
            })
            u2681[j.UserId] = u133

            if j ~= LocalPlayer then
                u133:bindHover()

                u133:onClick(function() -- Line: 3669; upvalues: u1603 (upval), j (val), u133 (val)
                    u1603.openPlayerMenu(j, u133)
                end)
            end

            box({
                w = 8,
                h = 8,
                r = "pill",
                noShrink = true,
                bg = {a = 1, c = v1},
                parent = u133,
            })

            text({
                f = "s500_13_44",
                ell = true,
                shrink0 = true,
                t = j.DisplayName,
                lh = 19.488,
                parent = u133,
            })

            u133.nc = text({
                f = "m500_10_56",
                c = "muted",
                noShrink = true,
                minW = 26,
                align = "r",
                t = u1578.fmtK(j:GetAttribute("NC") or 0),
                parent = u133,
            })
            u133.nc.boundary = true

            if j == LocalPlayer then
                tag(u133, "you", "me")
            end

            if v2 and Attribute == j.UserId then
                tag(u133, "host", "host")
            end

            if j:GetAttribute("Admin") == true then
                tag(u133, "admin", "admin")
            end

            if j:GetAttribute("VIP") == true then
                tag(u133, "vip", "host")
            end

            if j:GetAttribute("MuteAll") == true then
                tag(u133, "muted all")
            end

            if j:GetAttribute("Silenced") == true then
                tag(u133, "silenced", "bad")
            end
        end

        local v5 = v2

        if v5 then
            v5 = true

            if Attribute ~= LocalPlayer.UserId then
                v5 = LocalPlayer:GetAttribute("Admin") == true
            end
        end

        u1642.hostBtn:show(v5)
        u1603.applyChipStates(true)
        Lay.dirty()
    end

    function u1603.applyChipStates(a1)
        -- Line: 3689
        -- upvalues: u2681 (val), u2680 (val), u1941 (val)
        -- types: a1: boolean?
        local v1, v2
        local v3 = os.clock()
        local v4 = nil
        local v5 = nil

        for i, j in u2681, v4, v5 do
            v1 = u2680[i] == true
            v2 = false

            if u1941[i] ~= nil then
                v2 = v3 - u1941[i] < 0.6
            end

            j:state("talk", v1)
            j:state("play", v2 and not v1)
            j:state("playbg", v2 and v1)
        end
    end

    task.spawn(function() -- Line: 3699; upvalues: u1603 (val)
        while true do
            task.wait(0.1)
            u1603.applyChipStates()
        end
    end)

    local function setPV(a1, a2, a3)
        -- Line: 3706
        -- upvalues: u2003 (ref), u1603 (val)
        -- types: a1: number, a2: string, a3: number
        local v1 = tostring(a1)
        local v2 = u2003[v1] or {}
        v2[a2] = if not (a3 >= 0.999) then math.floor(a3 * 100 + 0.5) / 100 else nil
        u2003[v1] = if not next(v2) then nil else v2

        if a2 == "v" and u1603.setVoiceVol then
            u1603.setVoiceVol(a1, a3)
        end

        u1603.savePref("pv", u2003)
    end

    function u1603.openPlayerMenu(a1, a2)
        -- Line: 3715
        -- upvalues: u2388 (ref), Lay (val), u1603 (val), openMenu (val), box (val), u1642 (val), LocalPlayer (val)
        -- upvalues: u1959 (val), text (val), range (val), u2003 (ref), setPV (val), note (val), input_2 (val)
        -- upvalues: btn (val), toast (val), Api (val), VP (val), addChat (val)
        -- types: a1: userdata
        local v1

        if u2388 and u2388.anchor == a2 then
            if u2388 then
                u2388:destroy()

                u2388 = nil
                Lay.dirty()
            end

            return
        end

        local v2, v3 = u1603.at(a2)
        local v4 = openMenu(v2, v3 + (a2.lh_ or 26) + 6, 280, v3 - 6)
        v4.anchor = a2
        local u404 = box({
            scroll = true,
            dir = "col",
            gap = 4,
            maxH = u1642.layer.inst.AbsoluteSize.Y / u1642.layerScale.Scale - 24,
            parent = v4,
        })
        v4 = box({
            dir = "row",
            align = "center",
            gap = 8,
            pad = {4, 6, 6, 6},
            parent = u404,
        })
        local v5 = box
        local v6 = {w = 8, h = 8, r = "pill", noShrink = true}
        local v7 = {a = 1}
        local UserId = a1.UserId
        v7.c = if UserId ~= LocalPlayer.UserId then
            Color3.fromHex(u1959[UserId % (#u1959 - 1) + 1])
        else
            Color3.fromHex("e6e6e6")
        v6.bg = v7
        v6.parent = v4

        v5(v6)

        text({
            f = "s600_14_08",
            ell = true,
            shrink0 = true,
            t = a1.DisplayName,
            parent = v4,
        })

        text({
            f = "s400_12_8",
            c = "muted",
            ell = true,
            shrink0 = true,
            t = "@" .. a1.Name,
            parent = v4,
        })

        v4 = u1603.DEVICES[a1:GetAttribute("Device") or ""]

        if v4 then
            v2 = box({
                dir = "row",
                align = "center",
                gap = 7,
                pad = {0, 6, 4, 6},
                parent = u404,
            })

            if u1603.hasIcons() then
                v2:add((u1603.ico(v4[1], 15, "muted")))
            end

            text({f = "s400_12_8", c = "muted", t = "Plays on " .. v4[2], parent = v2})
        end

        if u1603.podiumMenu then
            u1603.podiumMenu(u404, a1)
        end

        local function slider(a1, a2, a3)
            -- Line: 3734
            -- upvalues: box (upval), u404 (val), text (upval), range (upval)
            -- types: a1: string, a2: number, a3: function
            local v1 = box({
                dir = "row",
                align = "center",
                gap = 10,
                pad = {4, 6},
                parent = u404,
            })
            box({
                w = 96,
                noShrink = true,
                parent = v1,
                {text({f = "s500_13_44", t = a1, lh = 19.488})},
            })

            local v2 = math.floor(a2 * 100 + 0.5)
            local u29 = text({f = "m500_10_56", c = "muted", noShrink = true, t = v2 .. "%"})

            v1:add(
                (range(
                    0,
                    100,
                    5,
                    v2,
                    function(a1) -- Line: 3739; upvalues: u29 (val), a3 (val)
                        u29:setText(a1 .. "%")
                        a3(a1 / 100)
                    end
                ))
            )

            v1:add(u29)
        end

        local UserId_2 = a1.UserId
        local v8 = u2003[tostring(UserId_2)]

        slider(
            "Piano volume",
            if not v8 then 1 else if not v8.p then 1 else v8.p,
            function(a1_2) -- Line: 3743; upvalues: setPV (upval), a1 (val)
                setPV(a1.UserId, "p", a1_2)
            end
        )

        v5 = slider
        v6 = "Mic volume"
        local UserId_3 = a1.UserId
        v8 = u2003[tostring(UserId_3)]

        v5(
            v6,
            if not v8 then 1 else if not v8.v then 1 else v8.v,
            function(a1_2) -- Line: 3744; upvalues: setPV (upval), a1 (val)
                setPV(a1.UserId, "v", a1_2)
            end
        )

        if not u1603.hasVoice or not u1603.hasVoice(a1.UserId) then
            u404:add(
                (note(
                    "No voice chat from this player.",
                    {pad = {0, 6}}
                ))
            )
        end

        if a1 ~= LocalPlayer then
            local u270
            v4 = box({
                dir = "col",
                gap = 6,
                bdc = "line",
                m = {4, 0, 0, 0},
                pad = {8, 6, 2, 6},
                bds = {1, 0, 0, 0},
                parent = u404,
            })
            v5 = box({
                dir = "row",
                align = "center",
                justify = "center",
                gap = 6,
                bd = 1,
                bdc = "ink",
                bg = "ink",
                r = 8,
                button = true,
                pad = {7, 12},
                parent = v4,
            })
            v6 = box({w = 16, h = 16, noShrink = true, parent = v5})
            local TextLabel = Instance.new("TextLabel")
            TextLabel.BackgroundTransparency = 1
            TextLabel.Size = UDim2.fromScale(1, 1)
            TextLabel.Text = utf8.char(57347)
            TextLabel.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)
            TextLabel.TextSize = 16
            TextLabel.TextColor3 = Lay.TH.bg.c
            TextLabel.Parent = v6.inst

            v5:add(
                (text({t = "DONATE", f = "s500_13_6", lh = 19.72, c = "bg"}))
            )

            local u264 = box({
                dir = "row",
                align = "center",
                gap = 6,
                hidden = true,
                parent = v4,
            })
            _, u270 = input_2(
                u264,
                "Robux",
                {grow = true}
            )
            v1 = btn("Send", "primary")

            u264:add(v1)

            local function send()
                -- Line: 3766
                -- upvalues: u270 (val), toast (upval), u2388 (upval), Lay (upval), a1 (val), Api (upval)
                local u6 = tonumber((string.match(u270.Text, "%d+")))

                if not u6 then
                    toast("Enter how many Robux to send.")
                    return
                end

                if u2388 then
                    u2388:destroy()

                    u2388 = nil
                    Lay.dirty()
                end

                task.spawn(function() -- Line: 3770; upvalues: a1 (upval), u6 (val), Api (upval), toast (upval)
                    local v1, v2
                    local u0 = {}
                    u0.target = a1.UserId
                    u0.amount = u6
                    local u4 = "donate"
                    local success, err, v3 = pcall(function() -- Line: 50; upvalues: Api (upval), u4 (val), u0 (val)
                        return Api:InvokeServer(u4, u0)
                    end)

                    if success then
                        v1 = err
                        v2 = v3
                    else
                        v1 = nil
                        v2 = "No connection to the server."
                    end

                    if not v1 then
                        toast((tostring(v2 or "Couldn't start the donation.")))
                    end
                end)
            end

            v5:onClick(function() -- Line: 3775; upvalues: u264 (val), Lay (upval), u270 (val)
                u264:show(true)
                Lay.dirty()

                task.defer(function() -- Line: 3778; upvalues: u270 (upval)
                    u270:CaptureFocus()
                end)
            end)

            v1:onClick(send)

            u270.FocusLost:Connect(function(a1) -- Line: 3781; upvalues: send (val)
                if a1 then
                    send()
                end
            end)

            local shopInfo = u1603.shopInfo or {}
            v5 = {}

            if tonumber(shopInfo.giftVip) and a1:GetAttribute("VIP") ~= true then
                table.insert(
                    v5,
                    {"vip", "Gift VIP", (tonumber(shopInfo.giftVip))}
                )
            end

            if tonumber(shopInfo.giftRainbow) and a1:GetAttribute("RainbowOwned") ~= true then
                table.insert(
                    v5,
                    {"rainbow", "Gift Rainbow", (tonumber(shopInfo.giftRainbow))}
                )
            end

            if #v5 > 0 then
                local v9
                v1 = box({
                    dir = "row",
                    wrap = true,
                    gap = 6,
                    rowGap = 6,
                    parent = v4,
                })
                local v10 = nil
                local v11 = nil

                for i, j in v5, v10, v11 do
                    v9 = box({
                        dir = "row",
                        align = "center",
                        justify = "center",
                        gap = 5,
                        grow = 1,
                        bd = 1,
                        bdc = "brass55",
                        bg = "brassSoft",
                        r = 8,
                        button = true,
                        pad = {6, 10},
                        parent = v1,
                    })
                    text({
                        f = "s500_13_6",
                        lh = 19.72,
                        c = "brassInk",
                        t = j[2],
                        parent = v9,
                    })

                    if u1603.robuxIcon then
                        v9:add((u1603.robuxIcon(13, "brassInk")))
                    end

                    text({f = "s600_14_08", c = "brassInk", t = tostring(j[3]), parent = v9})

                    v9:onClick(function()
                        -- Line: 3795
                        -- upvalues: u2388 (upval), Lay (upval), a1 (val), j (val), Api (upval), toast (upval)
                        if u2388 then
                            u2388:destroy()

                            u2388 = nil
                            Lay.dirty()
                        end

                        task.spawn(function()
                            -- Line: 3797
                            -- upvalues: a1 (upval), j (upval), Api (upval), toast (upval)
                            local v1, v2
                            local u0 = {}
                            u0.target = a1.UserId
                            u0.kind = j[1]
                            local u5 = "gift"
                            local success, err, v3 = pcall(function()
                                -- Line: 50
                                -- upvalues: Api (upval), u5 (val), u0 (val)
                                return Api:InvokeServer(u5, u0)
                            end)

                            if success then
                                v1 = err
                                v2 = v3
                            else
                                v1 = nil
                                v2 = "No connection to the server."
                            end

                            if not v1 then
                                toast((tostring(v2 or "Couldn't start the gift.")))
                            end
                        end)
                    end)
                end
            end
        end

        if u1603.voteKickBtn then
            u1603.voteKickBtn(u404, a1)
        end

        v6 = VP:GetAttribute("IsRoom") == true
            and (VP:GetAttribute("RoomHost")) == LocalPlayer.UserId
        v7 = LocalPlayer:GetAttribute("Admin") == true

        if v7 then
            if a1:GetAttribute("Admin") ~= true then
                v5 = box({
                    dir = "row",
                    wrap = true,
                    gap = 8,
                    rowGap = 8,
                    bdc = "line",
                    m = {4, 0, 0, 0},
                    pad = {8, 0, 0, 0},
                    bds = {1, 0, 0, 0},
                    parent = u404,
                })
                v7 = {"kick", "ban"}
                v1 = nil
                v8 = nil

                for k, n in v7, v1, v8 do
                    local u507 = btn(if n ~= "kick" then "Ban from server" else "Kick", "danger")
                    v5:add(u507)

                    if n ~= "kick" then
                        u515 = "Ban from server"
                    else
                        local u515 = "Kick"
                    end

                    local function u516()
                        -- Line: 3813
                        -- upvalues: u2388 (upval), Lay (upval), n (val), a1 (val), Api (upval), addChat (upval)
                        -- upvalues: text (upval)
                        if u2388 then
                            u2388:destroy()

                            u2388 = nil
                            Lay.dirty()
                        end

                        task.spawn(function()
                            -- Line: 3815
                            -- upvalues: n (upval), a1 (upval), Api (upval), addChat (upval), text (upval)
                            local v1, v2
                            local u5 = "/" .. n .. " " .. a1.Name
                            local u6 = "command"
                            local success, err, v3 = pcall(function()
                                -- Line: 50
                                -- upvalues: Api (upval), u6 (val), u5 (val)
                                return Api:InvokeServer(u6, u5)
                            end)

                            if success then
                                v1 = err
                                v2 = v3
                            else
                                v1 = nil
                                v2 = "No connection to the server."
                            end

                            local v4 = if type(v1) ~= "string" then
                                tostring(v2 or "No answer from the server.")
                            else
                                v1
                            addChat(
                                text({
                                    f = "si400_12_8",
                                    lh = 17.919999999999998,
                                    c = "dim",
                                    align = "c",
                                    wrap = true,
                                    t = v4,
                                })
                            )
                        end)
                    end

                    local u520 = false
                    local u521 = "Click again"

                    u507:onClick(function()
                        -- Line: 2724
                        -- upvalues: u520 (ref), u507 (val), u521 (val), u515 (val), u516 (val)
                        if u520 then
                            u520 = false
                            u516()

                            return
                        end

                        u520 = true
                        u507:state("arm", true)
                        u507.label:setText(u521)

                        task.delay(
                            3,
                            function() -- Line: 2729; upvalues: u520 (upval), u507 (upval), u515 (upval)
                                if u520 then
                                    u520 = false
                                    u507:state("arm", false)

                                    local v1 = u515
                                    u507.label:setText(v1)
                                end
                            end
                        )
                    end)
                end

                if LocalPlayer:GetAttribute("Admin") == true and u1603.adminBtn then
                    u1603.adminBtn(v5, a1)
                end
            end
        elseif v6 and a1:GetAttribute("Admin") ~= true then
            v5 = box({
                dir = "row",
                wrap = true,
                gap = 8,
                rowGap = 8,
                bdc = "line",
                m = {4, 0, 0, 0},
                pad = {8, 0, 0, 0},
                bds = {1, 0, 0, 0},
                parent = u404,
            })
            v7 = {"kick", "ban"}
            v1 = nil
            v8 = nil

            for m, i5 in v7, v1, v8 do
                local u507 = btn(if i5 ~= "kick" then "Ban from server" else "Kick", "danger")
                v5:add(u507)

                if i5 ~= "kick" then
                    u515 = "Ban from server"
                else
                    local u515 = "Kick"
                end

                local function u516()
                    -- Line: 3813
                    -- upvalues: u2388 (upval), Lay (upval), i5 (val), a1 (val), Api (upval), addChat (upval)
                    -- upvalues: text (upval)
                    if u2388 then
                        u2388:destroy()

                        u2388 = nil
                        Lay.dirty()
                    end

                    task.spawn(function()
                        -- Line: 3815
                        -- upvalues: i5 (upval), a1 (upval), Api (upval), addChat (upval), text (upval)
                        local v1, v2
                        local u5 = "/" .. i5 .. " " .. a1.Name
                        local u6 = "command"
                        local success, err, v3 = pcall(function()
                            -- Line: 50
                            -- upvalues: Api (upval), u6 (val), u5 (val)
                            return Api:InvokeServer(u6, u5)
                        end)

                        if success then
                            v1 = err
                            v2 = v3
                        else
                            v1 = nil
                            v2 = "No connection to the server."
                        end

                        local v4 = if type(v1) ~= "string" then
                            tostring(v2 or "No answer from the server.")
                        else
                            v1
                        addChat(
                            text({
                                f = "si400_12_8",
                                lh = 17.919999999999998,
                                c = "dim",
                                align = "c",
                                wrap = true,
                                t = v4,
                            })
                        )
                    end)
                end

                local u520 = false
                local u521 = "Click again"

                u507:onClick(function()
                    -- Line: 2724
                    -- upvalues: u520 (ref), u507 (val), u521 (val), u515 (val), u516 (val)
                    if u520 then
                        u520 = false
                        u516()

                        return
                    end

                    u520 = true
                    u507:state("arm", true)
                    u507.label:setText(u521)

                    task.delay(
                        3,
                        function() -- Line: 2729; upvalues: u520 (upval), u507 (upval), u515 (upval)
                            if u520 then
                                u520 = false
                                u507:state("arm", false)

                                local v1 = u515
                                u507.label:setText(v1)
                            end
                        end
                    )
                end)
            end

            if LocalPlayer:GetAttribute("Admin") == true and u1603.adminBtn then
                u1603.adminBtn(v5, a1)
            end
        end

        Lay.dirty()
    end

    local u2692 = true

    local function markPlayers() -- Line: 3826; upvalues: u2692 (ref)
        u2692 = true
    end

    local function watchPlayer(a1)
        -- Line: 3827
        -- upvalues: u2681 (val), u1578 (val), u2692 (ref), markPlayers (val)
        -- types: a1: userdata
        (a1:GetAttributeChangedSignal("NC")):Connect(function()
            -- Line: 3828
            -- upvalues: u2681 (upval), a1 (val), u1578 (upval), u2692 (upval)
            local v1 = u2681[a1.UserId]

            if v1 and v1.nc then
                v1.nc:setText((u1578.fmtK((a1:GetAttribute("NC")) or 0)))
                return
            end

            u2692 = true
        end)

        ;(a1:GetPropertyChangedSignal("DisplayName")):Connect(markPlayers)
        ;(a1:GetAttributeChangedSignal("Admin")):Connect(markPlayers)
        ;(a1:GetAttributeChangedSignal("MuteAll")):Connect(markPlayers)
        ;(a1:GetAttributeChangedSignal("Silenced")):Connect(markPlayers)
        ;(a1:GetAttributeChangedSignal("VIP")):Connect(markPlayers)
    end

    for i11, i12 in Players:GetPlayers() do
        watchPlayer(i12)
    end

    Players.PlayerAdded:Connect(function(a1)
        -- Line: 3839
        -- upvalues: watchPlayer (val), u2692 (ref), u1631 (val), addChat (val), text (val)
        watchPlayer(a1)

        u2692 = true

        if u1631.joinMsgs ~= false then
            addChat(
                text({
                    f = "si400_12_8",
                    lh = 17.919999999999998,
                    c = "dim",
                    align = "c",
                    wrap = true,
                    t = a1.DisplayName .. " joined",
                })
            )
        end
    end)

    Players.PlayerRemoving:Connect(function(a1)
        -- Line: 3844
        -- upvalues: u2692 (ref), u1631 (val), addChat (val), text (val), u1603 (val), Audio (val), u1783 (val)
        local v1
        u2692 = true

        if u1631.joinMsgs ~= false then
            addChat(
                text({
                    f = "si400_12_8",
                    lh = 17.919999999999998,
                    c = "dim",
                    align = "c",
                    wrap = true,
                    t = a1.DisplayName .. " left",
                })
            )
        end

        local u16 = "R" .. a1.UserId .. ":"
        local v2 = {}

        for i in u1603.rheldKeys() do
            v1 = #u16

            if string.sub(i, 1, v1) == u16 then
                table.insert(v2, i)
            end
        end

        for j, k in v2 do
            u1603.rrelease(k)
        end

        Audio.killWhere(function(a1) -- Line: 3851; upvalues: u16 (val)
            return (string.sub(a1, 1, #u16)) == u16
        end)

        for n in u1783 do
            v1 = #u16

            if string.sub(n, 1, v1) == u16 then
                v2 = u1783[n]

                if v2 then
                    v2.t1 = os.clock()
                    u1783[n] = nil
                end
            end
        end

        if u1603.unhookVoice then
            u1603.unhookVoice(a1)
        end
    end)

    __real_registers[36] = game:GetService("SoundService")
    local Folder = Instance.new("Folder")
    Folder.Name = "PianoVoice"
    Folder.Parent = __real_registers[36]
    local u2735 = nil
    local u2736 = {}

    local function v59(a1, a2, a3) -- Line: 3866; types: a1: userdata, a2: userdata, a3: userdata
        local Wire = Instance.new("Wire")
        Wire.SourceInstance = a1
        Wire.TargetInstance = a2
        Wire.Parent = a3
    end

    local function hook(a1, a2)
        -- Line: 3872
        -- upvalues: u2736 (val), Folder (val), LocalPlayer (val), u2735 (ref), u2003 (ref), u2692 (ref)
        -- types: a1: userdata, a2: userdata
        if u2736[a1] then
            return
        end

        local Folder_2 = Instance.new("Folder")
        Folder_2.Name = tostring(a1.UserId)
        Folder_2.Parent = Folder
        local AudioAnalyzer = Instance.new("AudioAnalyzer")
        AudioAnalyzer.Parent = Folder_2
        local Wire = Instance.new("Wire")
        Wire.SourceInstance = a2
        Wire.TargetInstance = AudioAnalyzer
        Wire.Parent = Folder_2
        local v1 = nil

        if a1 ~= LocalPlayer then
            if not u2735 then
                u2735 = Instance.new("AudioDeviceOutput")
                u2735.Parent = Folder
            end

            v1 = Instance.new("AudioFader")
            local UserId_2 = a1.UserId
            local v2 = u2003[tostring(UserId_2)]
            v1.Volume = if not v2 then 1 else if not v2.v then 1 else v2.v
            v1.Parent = Folder_2
            local Wire_2 = Instance.new("Wire")
            Wire_2.SourceInstance = a2
            Wire_2.TargetInstance = v1
            Wire_2.Parent = Folder_2
            local v3 = u2735
            local Wire_3 = Instance.new("Wire")
            Wire_3.SourceInstance = v1
            Wire_3.TargetInstance = v3
            Wire_3.Parent = Folder_2
        end

        u2736[a1] = {
            last = 0,
            f = Folder_2,
            an = AudioAnalyzer,
            input = a2,
            fader = v1,
        }
        u2692 = true
    end

    function u1603.setVoiceVol(a1, a2) -- Line: 3895; upvalues: u2736 (val); types: a1: number, a2: number
        for i, j in u2736 do
            if i.UserId == a1 and j.fader then
                j.fader.Volume = a2
            end
        end
    end

    function u1603.hasVoice(a1) -- Line: 3900; upvalues: u2736 (val); types: a1: number
        for i in u2736 do
            if i.UserId == a1 then
                return true
            end
        end

        return false
    end

    function u1603.unhookVoice(a1) -- Line: 3904; upvalues: u2736 (val), u2680 (val); types: a1: userdata
        local v1 = u2736[a1]

        if v1 then
            v1.f:Destroy()

            u2736[a1] = nil
        end

        u2680[a1.UserId] = nil
    end

    local function v60(a1) -- Line: 3909; upvalues: hook (val); types: a1: userdata
        local AudioDeviceInput = a1:FindFirstChildOfClass("AudioDeviceInput")

        if AudioDeviceInput then
            hook(a1, AudioDeviceInput)
        end

        a1.ChildAdded:Connect(function(a1_2) -- Line: 3912; upvalues: hook (upval), a1 (val)
            if a1_2:IsA("AudioDeviceInput") then
                hook(a1, a1_2)
            end
        end)
    end

    for i13, i14 in Players:GetPlayers() do
        task.spawn(v60, i14)
    end

    Players.PlayerAdded:Connect(v60)

    task.spawn(function() -- Line: 3916; upvalues: u2736 (val), u2680 (val)
        local v1, v2, v3, v4

        while true do
            task.wait(0.1)

            v1 = os.clock()
            v3 = nil
            v4 = nil

            for i, j in u2736, v3, v4 do
                local u15 = 0
                pcall(function() -- Line: 3922; upvalues: u15 (ref), j (val)
                    u15 = j.an.RmsLevel
                end)

                if u15 > 0.01 and not j.input.Muted then
                    j.last = v1
                end

                v2 = if not (v1 - j.last < 0.35) then nil else true
                u2680[i.UserId] = v2
            end
        end
    end)

    task.spawn(function() -- Line: 3930; upvalues: u2692 (ref), renderPlayers (val)
        while true do
            task.wait(0.35)

            if u2692 then
                u2692 = false
                renderPlayers()
            end
        end
    end)

    __real_registers[36] = function() -- Line: 3941; upvalues: VP (val)
        if VP:GetAttribute("IsRoom") == true then
            return (tostring((VP:GetAttribute("RoomName")) or "Room"))
        end

        local v1 = tonumber((VP:GetAttribute("LobbyNum")))

        if v1 then
            return "Lobby " .. v1
        end

        return "Lobby"
    end

    local function v61()
        -- Line: 3948
        -- upvalues: u1642 (val), VP (val), u1805 (val), setMode (val), toast (val), u2692 (ref)
        local v1
        local roomName = u1642.roomName

        if VP:GetAttribute("IsRoom") == true then
            v1 = tostring((VP:GetAttribute("RoomName")) or "Room")
        else
            local v2 = tonumber((VP:GetAttribute("LobbyNum")))
            v1 = if not v2 then "Lobby" else "Lobby " .. v2
        end

        roomName:setText(v1)

        u1805.allowAuto = VP:GetAttribute("AllowAuto") ~= false
        local auto = u1642.modeBtns.auto
        auto.disabled = not u1805.allowAuto
        auto.op = if not u1805.allowAuto then 0.45 else nil

        auto:repaintAll()

        if not u1805.allowAuto and u1805.mode == "auto" then
            setMode("practice")
            toast("The host turned off autoplay in this room.")
        end

        u2692 = true
    end

    for i15, i16 in {"IsRoom", "RoomName", "AllowAuto", "RoomHost", "VoiceOnly", "LobbyNum"} do
        (VP:GetAttributeChangedSignal(i16)):Connect(v61)
    end

    local function v62(a1) -- Line: 3963; upvalues: u1642 (val), Lay (val); types: a1: boolean
        local v1 = if not a1 then "dim" else "ok"
        u1642.connDot.bg = v1

        u1642.connDot:paint()

        u1642.connGlow.Visible = a1
        u1642.connGlow.ImageColor3 = Lay.TH.ok.c
        u1642.connGlow.ImageTransparency = 0.4
    end

    local function enterRoom(a1, a2, a3)
        -- Line: 3971
        -- upvalues: Api (val), toast (val), u1603 (val)
        -- types: a2: string?, a3: string?
        local v1, v2
        local u3 = {host = a1, password = a2, job = a3}
        local u4 = "enterRoom"
        local success, err, v3 = pcall(function() -- Line: 50; upvalues: Api (upval), u4 (val), u3 (val)
            return Api:InvokeServer(u4, u3)
        end)

        if success then
            v1 = err
            v2 = v3
        else
            v1 = nil
            v2 = "No connection to the server."
        end

        if v1 then
            toast("Switching…")
            return true
        end

        if v2 == "need_password" then
            u1603.openPassword(a1)
            return false
        end

        toast(v2 or "Couldn't switch rooms.")

        return false, v2
    end

    function u1603.openPassword(a1, a2)
        -- Line: 3984
        -- upvalues: openDialog (val), field (val), input_2 (val), statusLine (val), box (val), btn (val), Api (val)
        -- upvalues: u1603 (val), toast (val)
        -- types: a1: number, a2: string?
        local u19
        local v1 = openDialog(if not a2 then "Password room" else "\"" .. a2 .. "\": password")
        _, u19 = input_2(field(v1, "Password"), "")
        local u23 = statusLine(v1)
        local v2 = box({dir = "row", gap = 8, m = {0, 0, 14, 0}, parent = v1})
        v1 = btn("Join", "primary")

        v2:add(v1)

        local function submit()
            -- Line: 3991
            -- upvalues: u19 (val), u23 (val), a1 (val), Api (upval), u1603 (upval), toast (upval)
            local v1, v2

            if u19.Text == "" then
                u23("Enter the password.", true)
                return
            end

            u23("Checking…")

            local u9 = {host = a1, password = u19.Text}
            local u13 = "enterRoom"
            local success, err, v3 = pcall(function() -- Line: 50; upvalues: Api (upval), u13 (val), u9 (val)
                return Api:InvokeServer(u13, u9)
            end)

            if success then
                v1 = err
                v2 = v3
            else
                v1 = nil
                v2 = "No connection to the server."
            end

            if not v1 then
                u23(if v2 ~= "need_password" then v2 or "Couldn't join." else "Enter the password.", true)
                return
            end

            u1603.closeDialog()
            toast("Switching…")
        end

        v1:onClick(submit)

        u19.FocusLost:Connect(function(a1) -- Line: 3998; upvalues: submit (val)
            if a1 then
                submit()
            end
        end)

        task.defer(function() -- Line: 3999; upvalues: u19 (val)
            u19:CaptureFocus()
        end)
    end

    local function choiceRow(a1, a2, a3, a4, a5)
        -- Line: 4002
        -- upvalues: box (val), radio (val), text (val)
        -- types: a2: table, a3: string, a4: function, a5: boolean?
        local v1, v2
        local v3 = box({dir = "row", wrap = true, gap = 8, parent = a1})
        local u57 = {}
        local v4 = nil
        local v5 = nil

        for i, j in a2, v4, v5 do
            v1 = box({
                dir = "row",
                align = "center",
                gap = 8,
                bd = 1,
                bdc = "line",
                bg = "panel2",
                r = 9,
                button = true,
                pad = {8, 12},
                parent = v3,
            })
            v2 = radio(j[1] == a3)

            v1:add(v2)

            if not v6 then
                text({f = "s500_14", lh = 20.3, t = j[2], parent = v1})
            else
                text({
                    f = "m500_10_24",
                    up = true,
                    ls = 0.8192,
                    c = "muted",
                    t = j[2],
                    parent = v1,
                })
            end

            u57[j[1]] = v2
            v1:onClick(function() -- Line: 4015; upvalues: u57 (val), j (val), a4 (val)
                local v1
                local v2 = nil
                local v3 = nil

                for i, j2 in u57, v2, v3 do
                    v1 = i == j[1]
                    j2.on = v1

                    j2:paint()
                end

                a4(j[1])
            end)
        end

        return v3,
            function(a1) -- Line: 4020; upvalues: u57 (val); types: a1: string
                local v1
                local v2 = nil
                local v3 = nil

                for i, j in u57, v2, v3 do
                    v1 = i == a1
                    j.on = v1

                    j:paint()
                end
            end
    end

    local function checkRow(a1, a2, a3, a4)
        -- Line: 4022
        -- upvalues: box (val), checkbox (val), text (val)
        -- types: a2: string, a3: boolean, a4: function
        local v1 = box({
            dir = "row",
            align = "center",
            gap = 10,
            button = true,
            parent = a1,
        })
        local u9 = checkbox(a3)

        v1:add(u9)
        text({f = "s500_14", lh = 20.3, t = a2, parent = v1})

        v1:onClick(function() -- Line: 4027; upvalues: u9 (val), a4 (val)
            u9.on = not u9.on
            u9:paint()
            a4(u9.on)
        end)

        return v1,
            function(a1) -- Line: 4032; upvalues: u9 (val); types: a1: boolean
                u9.on = a1
                u9:paint()
            end
    end

    function u1603.openRoomDialog(a1)
        -- Line: 4036
        -- upvalues: Api (val), u3696 (ref), toast (val), openDialog (val), choiceRow (val), field (val), note (val)
        -- upvalues: input_2 (val), checkRow (val), LocalPlayer (val), statusLine (val), box (val), btn (val)
        -- upvalues: u1603 (val), VP (val), enterRoom (val)
        -- types: a1: boolean?
        local u139, u86, v1

        if not a1 then
            local u1 = "myRoom"
            local u2 = nil
            local success, err = pcall(function() -- Line: 50; upvalues: Api (upval), u1 (val), u2 (val)
                return Api:InvokeServer(u1, u2)
            end)
            v1 = if success then err else nil
            u3696 = if type(v1) ~= "table" then nil else v1
        end

        if a1 then
            local u21 = "hereRoom"
            local u22 = nil
            local success_2, err_2 = pcall(function() -- Line: 50; upvalues: Api (upval), u21 (val), u22 (val)
                return Api:InvokeServer(u21, u22)
            end)

            if type(if success_2 then err_2 else nil) ~= "table" then
                toast("Couldn't load this room's settings.")
                return
            end
        end

        local v2 = openDialog(if not a1 then if not u3696 then "New room" else "Room settings" else "Room settings (admin)")
        local u50 = if not v1 then "room" else if v1.kind ~= "podium" then "room" else "podium"
        local v3 = u50

        choiceRow(
            field(v2, "Type"),
            {{"room", "Room"}, {"podium", "Podium"}},
            v3,
            function(a1) -- Line: 4049; upvalues: u50 (ref)
                u50 = a1
            end,
            true
        )

        v2:add(
            (note(
                "Podium: only the people you bring up are heard, on the piano and in voice chat. Everyone else listens and raises a hand.",
                {lh = 18.56}
            ))
        )

        _, u86 = input_2(field(v2, "Name"), "e.g. Evening jam")
        u86.Text = v1 and v1.name or ""
        local u97 = if not v1 then "public" else if v1.access ~= "password" then "public" else "password"
        local v4 = field(v2, "Access")
        local u106 = nil

        choiceRow(
            v4,
            {{"public", "Public"}, {"password", "Password"}},
            u97,
            function(a1) -- Line: 4057; upvalues: u97 (ref), u106 (ref)
                u97 = a1
                u106:show(a1 == "password")
            end,
            true
        )

        u106 = field(v2, "Password")
        local v5 = if not v1 then
            "Choose a password"
        else
            if not v1.hasPass then "Choose a password" else "Leave empty to keep it"
        _, u139 = input_2(u106, v5)
        local v6 = u97 == "password"

        u106:show(v6)

        local u157 = not v1

        if not u157 then
            u157 = v1.allowAuto ~= false
        end

        checkRow(
            v2,
            "Allow autoplay in this room",
            u157,
            function(a1) -- Line: 4065; upvalues: u157 (ref)
                u157 = a1
            end
        )

        local u173 = false

        if v1 ~= nil then
            u173 = v1.voiceOnly == true
        end

        checkRow(
            v2,
            "Voice chat only (players without voice chat can't join)",
            u173,
            function(a1) -- Line: 4067; upvalues: u173 (ref)
                u173 = a1
            end
        )

        v2:add(
            (note(
                "Each room is its own server for up to " .. (if LocalPlayer:GetAttribute("VIP") ~= true then "12 players (24 with VIP)" else "24 players (VIP)") .. ". A password keeps random guests out, but it isn't real security: don't share anything secret in a room.",
                {lh = 18.56}
            ))
        )

        local u206 = statusLine(v2)
        v4 = box({
            dir = "row",
            wrap = true,
            gap = 8,
            justify = "between",
            align = "center",
            parent = v2,
        })
        local v7 = box({dir = "row", wrap = true, gap = 8, parent = v4})
        v2 = btn(if not v1 then "Create and join" else "Save", "primary")

        v7:add(v2)

        v2:onClick(function()
            -- Line: 4073
            -- upvalues: u206 (val), u86 (val), u97 (ref), u139 (val), u157 (ref), u173 (ref), a1 (val), u50 (ref)
            -- upvalues: Api (upval), u1603 (upval), toast (upval), u3696 (upval), VP (upval), LocalPlayer (upval)
            -- upvalues: enterRoom (upval)
            local v1, v2
            u206("Saving…")

            local u3 = {
                name = u86.Text,
                access = u97,
                password = u139.Text,
                allowAuto = u157,
                voiceOnly = u173,
                here = a1,
                kind = u50,
            }
            local u13 = "saveRoom"
            local success, err, v3 = pcall(function() -- Line: 50; upvalues: Api (upval), u13 (val), u3 (val)
                return Api:InvokeServer(u13, u3)
            end)

            if success then
                v1 = err
                v2 = v3
            else
                v1 = nil
                v2 = "No connection to the server."
            end

            if not v1 then
                u206(v2 or "Couldn't save.", true)
                return
            end

            u1603.closeDialog()

            if a1 then
                toast("Room settings saved.")
                return
            end

            u3696 = {
                name = u86.Text,
                access = u97,
                allowAuto = u157,
                voiceOnly = u173,
                hasPass = u97 == "password",
                kind = u50,
            }
            v1 = false

            if VP:GetAttribute("IsRoom") == true then
                v1 = (VP:GetAttribute("RoomHost")) == LocalPlayer.UserId
            end

            if v1 or v2 ~= true then
                toast("Room settings saved.")
                return
            end

            toast("Room created. Joining…")
            enterRoom(LocalPlayer.UserId)
        end)

        if v1 then
            local u287 = btn("Close room", "danger")
            v4:add(u287)

            local function u293()
                -- Line: 4092
                -- upvalues: a1 (val), Api (upval), u3696 (upval), u1603 (upval), toast (upval)
                local u0 = {here = a1}
                local u2 = "closeRoom"

                if (pcall(function() -- Line: 50; upvalues: Api (upval), u2 (val), u0 (val)
                    return Api:InvokeServer(u2, u0)
                end)) then end

                if not a1 then
                    u3696 = nil
                end

                u1603.closeDialog()
                toast("Room closed.")
            end

            local u294 = false
            local u295 = "Click again — everyone goes to the lobby"
            local u296 = "Close room"

            u287:onClick(function()
                -- Line: 2724
                -- upvalues: u294 (ref), u287 (val), u295 (val), u296 (val), u293 (val)
                if u294 then
                    u294 = false
                    u293()

                    return
                end

                u294 = true
                u287:state("arm", true)
                u287.label:setText(u295)

                task.delay(
                    3,
                    function() -- Line: 2729; upvalues: u294 (upval), u287 (upval), u296 (upval)
                        if u294 then
                            u294 = false
                            u287:state("arm", false)

                            local v1 = u296
                            u287.label:setText(v1)
                        end
                    end
                )
            end)
        end
    end

    u1642.hostBtn:onClick(function() -- Line: 4100; upvalues: VP (val), u1603 (val), LocalPlayer (val)
        local v1 = VP:GetAttribute("IsRoom") == true
        local openRoomDialog = u1603.openRoomDialog
        local v2 = v1

        if v2 then
            v2 = false

            if (VP:GetAttribute("RoomHost")) ~= LocalPlayer.UserId then
                v2 = LocalPlayer:GetAttribute("Admin") == true
            end
        end

        openRoomDialog(v2)
    end)

    u1642.roomBtn:onClick(function()
        -- Line: 4105
        -- upvalues: u2388 (ref), u1642 (val), Lay (val), u1603 (val), ScreenGui (val), openMenu (val), eyebrow (val)
        -- upvalues: box (val), btn (val), u3696 (ref), text (val), Api (val), menuItem (val), tag (val)
        -- upvalues: LocalPlayer (val), enterRoom (val)
        if u2388 and u2388.anchor == u1642.roomBtn then
            if u2388 then
                u2388:destroy()

                u2388 = nil
                Lay.dirty()
            end

            return
        end

        local v1 = u1642.roomBtn.ax or 0
        local u27 = (u1642.roomBtn.ay or 0) + (u1642.roomBtn.lh_ or 31) + 6
        local fakeSize = u1603.fakeSize or ScreenGui.AbsoluteSize
        local v2 = math.max(fakeSize.X, 1)
        local v3 = math.max(fakeSize.Y, 1)
        local v4 = math.min(1, v2 / (u1603.vpW or 1280), v3 / (u1603.vpH or 720))
        local v5 = v2 / v4
        local v6 = v3 / v4
        local u65 = openMenu(v1, u27, (math.min(340, v5 * 0.86)))
        u65.anchor = u1642.roomBtn

        u65:add(
            (eyebrow(
                "Rooms",
                {m = {4, 6, 2, 6}}
            ))
        )

        v5 = box({
            dir = "row",
            wrap = true,
            gap = 8,
            rowGap = 8,
            bdc = "line",
            pad = {0, 0, 8, 0},
            bds = {0, 0, 1, 0},
            parent = u65,
        })
        v1 = btn(if not u3696 then "＋ Create room" else "My room settings", "primary")

        v5:add(v1)

        v1:onClick(function() -- Line: 4117; upvalues: u2388 (upval), Lay (upval), u1603 (upval)
            if u2388 then
                u2388:destroy()

                u2388 = nil
                Lay.dirty()
            end

            u1603.openRoomDialog()
        end)

        local u115 = btn("All rooms")
        v5:add(u115)

        u115:onClick(function() -- Line: 4121; upvalues: u2388 (upval), Lay (upval), u1603 (upval)
            if u2388 then
                u2388:destroy()

                u2388 = nil
                Lay.dirty()
            end

            u1603.openRoomBrowser()
        end)

        local u132 = text({
            t = "Loading…",
            f = "s400_13_44",
            c = "muted",
            lh = 19.488,
            pad = {6, 8},
            parent = u65,
        })
        task.spawn(function()
            -- Line: 4123
            -- upvalues: Api (upval), u2388 (upval), u65 (val), u132 (val), u1642 (upval), Lay (upval), u1603 (upval)
            -- upvalues: ScreenGui (upval), box (upval), u27 (val), menuItem (upval), tag (upval), text (upval)
            -- upvalues: LocalPlayer (upval), enterRoom (upval), u115 (val)
            local lobbies_2, rooms_2, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11
            local u0 = "listRooms"
            local u1 = nil
            local success, err = pcall(function() -- Line: 50; upvalues: Api (upval), u0 (val), u1 (val)
                return Api:InvokeServer(u0, u1)
            end)

            if u2388 ~= u65 then
                return
            end

            u132:destroy()

            local v12 = if not (type(if success then err else nil) == "table") then "dim" else "ok"
            u1642.connDot.bg = v12

            u1642.connDot:paint()

            u1642.connGlow.Visible = v2
            u1642.connGlow.ImageColor3 = Lay.TH.ok.c
            u1642.connGlow.ImageTransparency = 0.4
            local here = if type(v1) ~= "table" then "lobby" else v1.here
            local fakeSize = u1603.fakeSize or ScreenGui.AbsoluteSize
            local v13 = math.max(fakeSize.X, 1)
            local v14 = math.max(fakeSize.Y, 1)
            local v15 = math.min(1, v13 / (u1603.vpW or 1280), v14 / (u1603.vpH or 720))
            local v16 = v13 / v15
            local u448 = v14 / v15
            local u440 = box({
                scroll = true,
                dir = "col",
                gap = 4,
                pad = {0, 10, 0, 0},
                maxH = math.min(304, (math.max(150, u448 - u27 - 110))),
                parent = u65,
            })
            local inst = u440.inst
            inst.ScrollBarThickness = 5
            inst.ScrollBarImageTransparency = 0.2
            inst.ScrollBarImageColor3 = Lay.TH.muted.c
            local u464 = nil

            local function item(a1, a2, a3, a4, a5, a6, a7, a8, a9)
                -- Line: 4139
                -- upvalues: menuItem (upval), u440 (val), u464 (ref), tag (upval), text (upval)
                -- types: a1: string, a2: number, a3: boolean, a4: boolean, a5: boolean, a6: boolean, a7: function
                -- types: a8: boolean?, a9: boolean?
                local v1 = menuItem(u440, (if not a4 then "" else "🔒 ") .. a1, a3, a7)

                if a3 then
                    u464 = v1
                end

                if a9 then
                    tag(v1, "podium", "host")
                end

                if a8 then
                    tag(v1, "voice", "ok")
                end

                if a5 then
                    tag(v1, "no autoplay")
                end

                if a6 then
                    tag(v1, "yours", "host")
                end

                text({
                    f = "m500_11_52",
                    c = "muted",
                    noShrink = true,
                    t = a2 .. " 👤",
                    parent = v1,
                })
            end

            table.sort(
                if type(v1) ~= "table" then
                    {}
                else
                    if type(v1.rooms) ~= "table" then {} else v1.rooms,
                function(a1, a2) -- Line: 4149
                    local v1 = a1.players or 0
                    return (a2.players or 0) < v1
                end
            )

            local v17 = nil
            local v18 = nil

            for i, j in rooms_2, v17, v18 do
                v4 = tostring(j.name)
                v5 = j.players or 0
                v6 = here == "room_" .. j.host
                v7 = j.access == "password"
                v8 = j.allowAuto == false
                v9 = j.host == LocalPlayer.UserId
                v10 = j.voiceOnly == true
                v11 = j.kind == "podium"

                item(
                    v4,
                    v5,
                    v6,
                    v7,
                    v8,
                    v9,
                    function()
                        -- Line: 4151
                        -- upvalues: here (val), j (val), LocalPlayer (upval), u1603 (upval), enterRoom (upval)
                        if here ~= "room_" .. j.host then
                            if j.access == "password"
                                and j.host ~= LocalPlayer.UserId
                                and not (LocalPlayer:GetAttribute("Admin") == true) then
                                u1603.openPassword(j.host, (tostring(j.name)))
                                return
                            end

                            enterRoom(j.host)
                        end
                    end,
                    v10,
                    v11
                )
            end

            if #rooms_2 == 0 then
                text({
                    t = "No other rooms with players right now.",
                    f = "s400_13_44",
                    c = "muted",
                    wrap = true,
                    lh = 19.488,
                    pad = {6, 8},
                    parent = u440,
                })
            end

            if #(if type(v1) ~= "table" then
                {}
            else
                if type(v1.lobbies) ~= "table" then {} else v1.lobbies)
                == 0 then
                local lobbyHere = if type(v1) ~= "table" then
                    0
                else
                    if not v1.lobbyHere then 0 else v1.lobbyHere
                v17 = here == "lobby"
                local v19 = menuItem(
                    u440,
                    "Lobby",
                    v17,
                    function() -- Line: 4164; upvalues: here (val), enterRoom (upval)
                        if here ~= "lobby" then
                            enterRoom("lobby")
                        end
                    end
                )

                if v17 then
                    u464 = v19
                end

                text({
                    f = "m500_11_52",
                    c = "muted",
                    noShrink = true,
                    t = lobbyHere .. " 👤",
                    parent = v19,
                })
            end

            table.sort(
                lobbies_2,
                function(a1, a2) -- Line: 4166
                    local v1 = tonumber(a1.n) or 0
                    local v2 = tonumber(a2.n) or 0

                    if v1 ~= v2 then
                        return v2 < v1
                    end

                    return (tonumber(a1.num) or 0) < (tonumber(a2.num) or 0)
                end
            )

            v17 = nil
            v18 = nil

            for k, n2 in lobbies_2, v17, v18 do
                v3 = "Lobby " .. tostring(n2.num)
                v4 = tonumber(n2.n) or 0
                v5 = n2.here == true
                v7 = menuItem(
                    u440,
                    "" .. v3,
                    v5,
                    function() -- Line: 4172; upvalues: n2 (val), enterRoom (upval)
                        if n2.here ~= true then
                            enterRoom("lobby", nil, n2.job)
                        end
                    end
                )

                if v5 then
                    u464 = v7
                end

                text({
                    f = "m500_11_52",
                    c = "muted",
                    noShrink = true,
                    t = v4 .. " 👤",
                    parent = v7,
                })
            end

            local v20 = type(v1) == "table" and tonumber(v1.total) or 0

            if v20 > 0 then
                u115.label:setText("All rooms (" .. v20 .. ")")
            end

            Lay.dirty()

            task.defer(function()
                -- Line: 4180
                -- upvalues: Lay (upval), u440 (val), u448 (val), u27 (upval), u464 (ref), inst (val)
                pcall(function()
                    -- Line: 4181
                    -- upvalues: Lay (upval), u440 (upval), u448 (upval), u27 (upval), u464 (upval), inst (upval)
                    Lay.now()

                    local kids = u440.kids and u440.kids[1]

                    if kids and kids.lh_ and 10 < kids.lh_ then
                        u440.maxH = math.min(8 * kids.lh_ + 28, (math.max(150, u448 - u27 - 110)))
                        Lay.now()
                    end

                    if u464 and u464.ay and u440.ay then
                        local v1 = u464.ay - u440.ay
                        inst.CanvasPosition = Vector2.new(0, (math.clamp(v1 - (u440.lh_ or 300) / 2, 0, (math.max(0, inst.AbsoluteCanvasSize.Y - inst.AbsoluteWindowSize.Y)))))
                    end
                end)
            end)
        end)
    end)

    local function v63(a1) -- Line: 4199; types: a1: number
        local v1 = math.floor(a1 / 60000)

        if v1 < 60 then
            return v1 .. " min"
        end

        return (math.floor(v1 / 60)) .. " h " .. v1 % 60 .. " min"
    end

    local function v64(a1) -- Line: 4204; types: a1: number
        local success, err = pcall(function() -- Line: 4205; upvalues: a1 (val)
            return DateTime.fromUnixTimestampMillis(a1):FormatLocalTime("MMM D, HH:mm", "en-us")
        end)

        if success then
            return err
        end

        return ""
    end

    function setTheme(a1, a2)
        -- Line: 4208
        -- upvalues: Themes (val), LocalPlayer (val), setTheme (val), u1631 (val), Lay (val), paintAllKeys (val)
        -- upvalues: u1603 (val), u2078 (val)
        -- types: a1: string, a2: boolean?
        if not Themes[a1] or a1 == "order" or a1 == "names" or a1 == "vipOnly" then
            a1 = "graphite"
        end

        if Themes.vipOnly and Themes.vipOnly[a1] and LocalPlayer:GetAttribute("VIP") ~= true then
            if a2 then
                local u18 = nil
                u18 = (LocalPlayer:GetAttributeChangedSignal("VIP")):Connect(function()
                    -- Line: 4214
                    -- upvalues: LocalPlayer (upval), u18 (ref), setTheme (upval), a1 (ref)
                    if LocalPlayer:GetAttribute("VIP") == true then
                        u18:Disconnect()
                        setTheme(a1, true)
                    end
                end)

                task.delay(
                    30,
                    function() -- Line: 4217; upvalues: u18 (ref)
                        if u18.Connected then
                            u18:Disconnect()
                        end
                    end
                )
            end

            a1 = "dark"
        end

        u1631.theme = a1
        Lay.setTheme(Themes[a1])
        paintAllKeys()
        u1603.layoutPiano()
        u1603.layoutQwerty()
        u1603.layoutStage()

        u2078.width = -1
        Lay.dirty()

        if not a2 then
            u1603.savePref("theme", a1)
        end
    end

    function u1603.setCollapsed(a1)
        -- Line: 4232
        -- upvalues: u1631 (val), u1642 (val), u1603 (val)
        -- types: a1: boolean
        u1631.collapsed = a1
        u1642.side:show(not a1 and not u1631.fullscreen)
        u1603.iconOr(u1642.sideBtn, if not a1 then "panel-left-close" else "panel-left-open", if not a1 then "⟨" else "⟩")
    end

    u1642.sideBtn:onClick(function() -- Line: 4237; upvalues: u1603 (val), u1631 (val)
        u1603.setCollapsed(not u1631.collapsed)
    end)

    local function toggleFullscreen() -- Line: 4238; upvalues: u1631 (val), u1642 (val), u1603 (val), Lay (val)
        u1631.fullscreen = not u1631.fullscreen
        local fullscreen = u1631.fullscreen

        u1642.topbar:show(not fullscreen)
        u1642.side:show(not fullscreen and not u1631.collapsed)

        local v1 = if not fullscreen then {10, 12, 10, 12} else {0, 0, 0, 0}
        u1642.app.pad = v1
        v1 = if not fullscreen then 10 else 0
        u1642.app.gap = v1
        v1 = if not fullscreen then 12 else 0
        u1642.main.r = v1
        v1 = if not fullscreen then 1 else 0
        u1642.main.bd = v1
        v1 = if not fullscreen then {
            r = 12,
            c = "bg",
            w = 4,
            line = "line",
            z = 40,
        } else nil
        u1642.main.cover = v1

        if u1642.main.extras then
            local v2

            for i, j in {"cover", "coverLine"} do
                v2 = u1642.main.extras[j]

                if v2 then
                    v2.Visible = not fullscreen
                end
            end
        end

        u1642.main:paint()
        u1603.iconOr(u1642.fsBtn, if not fullscreen then "maximize" else "minimize", if not fullscreen then "⛶" else "✕")
        Lay.dirty()
    end

    u1642.fsBtn:onClick(toggleFullscreen)

    u1603.toggleFullscreen = toggleFullscreen

    local function srow(a1, a2, a3, a4)
        -- Line: 4262
        -- upvalues: box (val), text (val), note (val), Glyph (val)
        -- types: a2: string, a3: string?, a4: boolean?
        local v1 = box({
            dir = "row",
            wrap = true,
            justify = "between",
            align = "center",
            gap = 20,
            rowGap = 10,
            bdc = "line",
            pad = {12, 0},
            bds = if not a4 then {0, 0, 1, 0} else nil,
            parent = a1,
        })
        local v2 = box({dir = "col", parent = v1})

        text({f = "s600_14", lh = 20.3, t = a2, parent = v2})

        if a3 then
            v2:add(
                (note(
                    a3,
                    {m = {2, 0, 0, 0}, maxTW = 44 * Glyph.width("s400_12_8", "0")}
                ))
            )
        end

        return v1
    end

    function u1603.renderStatsPane(a1)
        -- Line: 4273
        -- upvalues: text (val), Lay (val), Api (val), box (val), u1578 (val), note (val), eyebrow (val), NOTE (val)
        -- upvalues: u1631 (val), u3682 (ref), Sheets (val), u3710 (val), levelBadge (val), u1603 (val), loadSheet (val)
        -- upvalues: btn (val)
        local err, err_2, err_3, hist, id, id_2, index, keys, level, runRow, runs, sh5, since, success, success_2,
            success_3, u10, u11, u153, u345, u346, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15
        local dispatch = 0

        while true do
            if dispatch < 25 then
                if dispatch < 8 then
                    if dispatch < 4 then
                        if dispatch < 2 then
                            if dispatch < 1 then
                                a1:clear()

                                v1 = text({
                                    t = "Loading…",
                                    f = "s400_14",
                                    lh = 20.3,
                                    c = "muted",
                                    parent = a1,
                                })
                                Lay.dirty()

                                u10 = "stats"
                                u11 = nil
                                success, err = pcall(function()
                                    -- Line: 50
                                    -- upvalues: Api (upval), u10 (val), u11 (val)
                                    return Api:InvokeServer(u10, u11)
                                end)
                                dispatch = if success then 2 else 1
                            else
                                v8 = nil
                                dispatch = 3
                            end
                        elseif dispatch < 3 then
                            v8 = err
                            dispatch = 3
                        else
                            dispatch = if a1.inst.Parent then 5 else 4
                        end
                    elseif dispatch < 6 then
                        if dispatch < 5 then
                            return
                        else
                            v1:destroy()

                            dispatch = if type(v8) == "table" then 7 else 6
                        end
                    elseif dispatch < 7 then
                        text({
                            t = "Statistics aren't available yet.",
                            f = "s400_14",
                            lh = 20.3,
                            c = "muted",
                            parent = a1,
                        })

                        Lay.dirty()

                        return
                    else
                        runs = v8.runs
                        dispatch = if runs then 9 else 8
                    end
                elseif dispatch < 18 then
                    if dispatch < 10 then
                        if dispatch < 9 then
                            runs = {}
                            dispatch = 9
                        else
                            v9 = "—"
                            dispatch = if not (#runs > 0) then 18 else 10
                        end
                    elseif dispatch < 17 then
                        v10 = 0
                        v11 = runs
                        v12 = nil
                        v13 = nil
                        local dispatchExit = nil

                        for i13, i14 in v11, v12, v13 do
                            local dispatch2 = 11

                            while true do
                                if dispatch2 < 13 then
                                    dispatch2 = if dispatch2 < 12 then
                                        if not i14.steps then 14 else 12
                                    else
                                        if not (0 < i14.steps) then 14 else 13
                                else
                                    if dispatch2 < 14 then
                                        v2 = i14.clean / i14.steps
                                    else
                                        if not (dispatch2 < 15) then
                                            v10 = v10 + v2
                                            break
                                        end

                                        v2 = 0
                                    end

                                    dispatch2 = 15
                                end
                            end

                            if dispatchExit then
                                break
                            end
                        end

                        dispatch = 17
                    else
                        v9 = (math.floor(v10 / #runs * 100 + 0.5)) .. "%"
                        dispatch = 18
                    end
                elseif dispatch < 20 then
                    if dispatch < 19 then
                        v10 = box({dir = "row", gap = 8, parent = a1})
                        v11 = {}
                        v14 = {u1578.fmtK(v8.presses or 0), "Presses"}
                        v15 = {}
                        v4 = math.floor((v8.playMs or 0) / 60000)
                        dispatch = if not (v4 < 60) then 20 else 19
                    else
                        v2 = v4 .. " min"
                        dispatch = 21
                    end
                elseif dispatch < 21 then
                    v2 = (math.floor(v4 / 60)) .. " h " .. v4 % 60 .. " min"
                    dispatch = 21
                elseif dispatch < 24 then
                    v15[1] = v2
                    v15[2] = "Play time"
                    v2 = {tostring(#runs), "Sheets finished"}
                    v11[1] = v14
                    v11[2] = v15
                    v11[3] = v2
                    v11[4] = {v9, "Avg. clean"}
                    v12 = nil
                    v13 = nil
                    local dispatchExit2 = nil

                    for i15, i16 in v11, v12, v13 do
                        local dispatch3 = 22

                        while true do
                            v2 = box({
                                dir = "col",
                                gap = 2,
                                grow = 1,
                                basis = 0,
                                bg = "panel2",
                                bd = 1,
                                bdc = "line",
                                r = 10,
                                pad = {10, 12},
                                parent = v10,
                            })
                            text({f = "m600_21_6", t = i16[1], parent = v2})

                            text({
                                f = "m500_9_92",
                                up = true,
                                ls = 0.7936,
                                c = "muted",
                                t = i16[2],
                                parent = v2,
                            })
                            break
                        end

                        if dispatchExit2 then
                            break
                        end
                    end

                    dispatch = 24
                else
                    v13 = note
                    since = v8.since
                    dispatch = if since then 26 else 25
                end
            elseif dispatch < 37 then
                if dispatch < 29 then
                    if dispatch < 27 then
                        if dispatch < 26 then
                            since = os.time()
                            dispatch = 26
                        else
                            u153 = since * 1000
                            success_2, err_2 = pcall(function() -- Line: 4205; upvalues: u153 (val)
                                return DateTime.fromUnixTimestampMillis(u153):FormatLocalTime("MMM D, HH:mm", "en-us")
                            end)
                            dispatch = if not success_2 then 28 else 27
                        end
                    else
                        v2 = if dispatch < 28 then err_2 else ""
                        dispatch = 29
                    end
                elseif dispatch < 31 then
                    if dispatch < 30 then
                        v13 = v13(
                            "Counted since " .. v2 .. ". Only your own presses count; autoplay doesn't.",
                            {m = {4, 0, 0, 0}}
                        )
                        a1:add(v13)

                        function sh5(a1_2) -- Line: 4299; upvalues: a1 (val), eyebrow (upval); types: a1_2: string
                            a1:add(
                                (eyebrow(
                                    a1_2,
                                    {m = {14, 0, 6, 0}}
                                ))
                            )
                        end

                        sh5("Favourite keys")

                        v9 = {}
                        keys = v8.keys
                        dispatch = if keys then 31 else 30
                    else
                        keys = {}
                        dispatch = 31
                    end
                elseif dispatch < 35 then
                    v12 = nil
                    v13 = nil
                    local dispatchExit3 = nil

                    for i17, i18 in keys, v12, v13 do
                        local dispatch4 = 32

                        while true do
                            if not (dispatch4 < 33) then
                                table.insert(
                                    v9,
                                    {i17, i18}
                                )
                                break
                            end

                            if not NOTE[i17] then
                                break
                            else
                                dispatch4 = 33
                            end
                        end

                        if dispatchExit3 then
                            break
                        end
                    end

                    dispatch = 35
                elseif dispatch < 36 then
                    table.sort(
                        v9,
                        function(a1, a2) -- Line: 4303
                            local v1 = a1[2]
                            return a2[2] < v1
                        end
                    )

                    dispatch = if #v9 ~= 0 then 37 else 36
                else
                    a1:add((note("Nothing yet — play something.")))

                    dispatch = 39
                end
            elseif dispatch < 63 then
                if dispatch < 61 then
                    if dispatch < 39 then
                        v8 = box({dir = "col", gap = 4, parent = a1})
                        v11 = v9[1][2]
                        v12 = math.min(10, #v9)
                        local dispatchExit4 = nil

                        for i19 = 1, v12 do
                            v15 = v9[i19][1]
                            v2 = v9[i19][2]
                            v3 = box({dir = "row", align = "center", gap = 8, parent = v8})

                            box({
                                w = 34,
                                pad = {1, 0},
                                bg = "cap",
                                bd = 1,
                                bdc = "capEdge",
                                r = 6,
                                parent = v3,
                                {text({f = "m600_16", align = "c", t = v15})},
                            })

                            text({
                                f = "m500_13_12",
                                c = "muted",
                                w = 46,
                                t = u1578.noteName(NOTE[v15]),
                                parent = v3,
                            })

                            v15 = box({
                                h = 8,
                                r = 4,
                                bg = "line",
                                grow = 1,
                                shrink0 = true,
                                clip = true,
                                parent = v3,
                            })
                            local u268 = math.max(0.03, v2 / v11)

                            box({
                                h = 8,
                                bg = "brass",
                                r = 4,
                                abs = {l = 0, t = 0},
                                wf = function(a1) -- Line: 4316; upvalues: u268 (val); types: a1: number
                                    return a1 * u268
                                end,
                                parent = v15,
                            })

                            text({
                                f = "m500_13_12",
                                w = 56,
                                align = "r",
                                t = u1578.fmtK(v2),
                                parent = v3,
                            })
                        end

                        if not dispatchExit4 then end

                        dispatch = 39
                    else
                        sh5("Note history")

                        v9 = {}
                        hist = u1631.hist
                        v12 = nil
                        v13 = nil
                        local dispatchExit5 = nil

                        for i20, i21 in hist, v12, v13 do
                            local dispatch5 = 40

                            while true do
                                if dispatch5 < 51 then
                                    if dispatch5 < 48 then
                                        if dispatch5 < 44 then
                                            id = i21.id
                                            v4 = u3682
                                            v5 = nil
                                            v6 = nil
                                            local dispatchExit6 = nil

                                            for i22, i23 in v4, v5, v6 do
                                                local dispatch6 = 41

                                                while true do
                                                    if not (dispatch6 < 42) then
                                                        v2 = i23
                                                        dispatchExit6 = 49
                                                        break
                                                    end

                                                    if i23.id ~= id then
                                                        break
                                                    else
                                                        dispatch6 = 42
                                                    end
                                                end

                                                if dispatchExit6 then
                                                    break
                                                end
                                            end

                                            dispatch5 = if dispatchExit6 == 49 then 49 else 44
                                        else
                                            v4 = Sheets
                                            v5 = nil
                                            v6 = nil
                                            local dispatchExit7 = nil

                                            for i24, i25 in v4, v5, v6 do
                                                local dispatch7 = 45

                                                while true do
                                                    if not (dispatch7 < 46) then
                                                        v2 = i25
                                                        dispatchExit7 = 49
                                                        break
                                                    end

                                                    if i25.id ~= id then
                                                        break
                                                    else
                                                        dispatch7 = 46
                                                    end
                                                end

                                                if dispatchExit7 then
                                                    break
                                                end
                                            end

                                            dispatch5 = if dispatchExit7 == 49 then 49 else 48
                                        end
                                    elseif dispatch5 < 49 then
                                        v2 = nil
                                        dispatch5 = 49
                                    elseif dispatch5 < 50 then
                                        dispatch5 = if not v2 then 51 else 50
                                    else
                                        v3 = nil
                                        dispatch5 = 56
                                    end
                                elseif dispatch5 < 57 then
                                    if dispatch5 < 55 then
                                        id_2 = i21.id
                                        index = u3710.index
                                        v6 = nil
                                        v7 = nil
                                        local dispatchExit8 = nil

                                        for i26, i27 in index, v6, v7 do
                                            local dispatch8 = 52

                                            while true do
                                                if not (dispatch8 < 53) then
                                                    v3 = i27
                                                    dispatchExit8 = 56
                                                    break
                                                end

                                                if i27.id ~= id_2 then
                                                    break
                                                else
                                                    dispatch8 = 53
                                                end
                                            end

                                            if dispatchExit8 then
                                                break
                                            end
                                        end

                                        dispatch5 = if dispatchExit8 == 56 then 56 else 55
                                    elseif dispatch5 < 56 then
                                        v3 = nil
                                        dispatch5 = 56
                                    else
                                        dispatch5 = if v2 then 59 else 57
                                    end
                                elseif dispatch5 < 58 then
                                    dispatch5 = if v3 then 59 else 58
                                else
                                    if not (dispatch5 < 59) then
                                        table.insert(
                                            v9,
                                            {h = i21, mine = v2, pub = v3}
                                        )
                                        break
                                    end

                                    if not i21.text then
                                        break
                                    else
                                        dispatch5 = 59
                                    end
                                end
                            end

                            if dispatchExit5 then
                                break
                            end
                        end

                        dispatch = 61
                    end
                elseif dispatch < 62 then
                    dispatch = if #v9 ~= 0 then 63 else 62
                else
                    a1:add((note("The sheets you open show up here, the last one first.")))

                    dispatch = 81
                end
            elseif dispatch < 82 then
                if dispatch < 81 then
                    v11 = box({dir = "col", gap = 4, parent = a1})
                    v12 = v9
                    v13 = nil
                    v14 = nil
                    local dispatchExit9 = nil

                    for i28, i29 in v12, v13, v14 do
                        local title
                        local dispatch9 = 64

                        while true do
                            if dispatch9 < 72 then
                                if dispatch9 < 68 then
                                    if dispatch9 < 66 then
                                        if dispatch9 < 65 then
                                            dispatch9 = if not i29.mine then 66 else 65
                                        else
                                            title = i29.mine.title
                                            dispatch9 = if title then 70 else 66
                                        end
                                    elseif dispatch9 < 67 then
                                        dispatch9 = if not i29.pub then 68 else 67
                                    else
                                        title = i29.pub.title
                                        dispatch9 = if title then 70 else 68
                                    end
                                elseif dispatch9 < 70 then
                                    if dispatch9 < 69 then
                                        title = i29.h.title
                                        dispatch9 = if title then 70 else 69
                                    else
                                        title = "Sheet"
                                        dispatch9 = 70
                                    end
                                elseif dispatch9 < 71 then
                                    dispatch9 = if not i29.mine then 72 else 71
                                else
                                    level = i29.mine.level
                                    dispatch9 = if level then 74 else 72
                                end
                            elseif dispatch9 < 76 then
                                if dispatch9 < 74 then
                                    if dispatch9 < 73 then
                                        level = i29.pub
                                        dispatch9 = if not level then 74 else 73
                                    else
                                        level = i29.pub.level
                                        dispatch9 = 74
                                    end
                                elseif dispatch9 < 75 then
                                    v5 = box({
                                        dir = "row",
                                        align = "center",
                                        gap = 8,
                                        bg = "panel2",
                                        r = 8,
                                        button = true,
                                        pad = {6, 10},
                                        hov = {bg = "white05"},
                                        parent = v11,
                                    })
                                    v5:bindHover()

                                    v5:add(
                                        (text({
                                            f = "s500_14",
                                            lh = 20.3,
                                            ell = true,
                                            grow = 1,
                                            shrink0 = true,
                                            t = title,
                                        }))
                                    )

                                    v6 = levelBadge(level)
                                    dispatch9 = if not v6 then 76 else 75
                                else
                                    v5:add(v6)

                                    dispatch9 = 76
                                end
                            elseif dispatch9 < 78 then
                                dispatch9 = if dispatch9 < 77 then
                                    if not i29.pub then 79 else 77
                                else
                                    if not i29.pub.authorName then 79 else 78
                            else
                                if not (dispatch9 < 79) then
                                    v5:onClick(
                                        ((function(title) -- upvalues: u1603 (upval), i29 (val), loadSheet (upval)
                                            return function()
                                                -- Line: 4343
                                                -- upvalues: u1603 (upval), i29 (val), loadSheet (upval), title (val)
                                                u1603.closeDialog()

                                                if i29.mine then
                                                    loadSheet(i29.mine.title, i29.mine.text, i29.mine.id)
                                                    return
                                                end

                                                if i29.pub then
                                                    u1603.openCommunity(i29.pub)
                                                    return
                                                end

                                                if i29.h.text then
                                                    loadSheet(title, i29.h.text, "tmp")
                                                end
                                            end
                                        end)(title))
                                    )
                                    break
                                end

                                v5:add(
                                    (text({
                                        f = "m400_10_88",
                                        c = "muted",
                                        noShrink = true,
                                        t = tostring(i29.pub.authorName),
                                    }))
                                )

                                dispatch9 = 79
                            end
                        end

                        if dispatchExit9 then
                            break
                        end
                    end

                    if not dispatchExit9 then end

                    dispatch = 81
                else
                    sh5("Sheet runs")

                    dispatch = if #runs ~= 0 then 83 else 82
                end
            else
                if dispatch < 83 then
                    a1:add((note("Finish a sheet in Practice mode and the result will appear here.")))
                else
                    if not (dispatch < 95) then
                        v1 = box({dir = "row", m = {14, 0, 0, 0}, parent = a1})
                        v11 = btn("Reset statistics", "danger")

                        v1:add(v11)
                        v11:onClick(u1603.openStartOver)
                        Lay.dirty()

                        return
                    end

                    u345 = box({dir = "col", parent = a1})
                    u346 = {120, 0, 60, 60, 56}

                    function runRow(a1, a2)
                        -- Line: 4361
                        -- upvalues: box (upval), u345 (val), text (upval), u346 (val)
                        -- types: a1: table, a2: boolean
                        local v1 = box({dir = "row", bdc = "line", bds = {0, 0, 1, 0}, parent = u345})
                        local v2 = nil
                        local v3 = nil
                        local v4 = a2

                        for i, j in a1, v2, v3 do
                            _ = text({
                                ell = true,
                                shrink0 = true,
                                t = j,
                                f = if not v4 then "s400_13_44" else "m500_9_92",
                                up = v4,
                                ls = if not v4 then nil else 0.7936,
                                lh = if not v4 then 19.488 else nil,
                                c = if not v4 then "ink" else "muted",
                                pad = if not v4 then 6 else {4, 6},
                                w = if not (0 < u346[i]) then nil else u346[i],
                                grow = if u346[i] ~= 0 then 0 else 1,
                                parent = v1,
                            })
                        end
                    end

                    runRow(
                        {"When", "Sheet", "Clean", "Errors", "Time"},
                        true
                    )

                    v14 = #runs
                    v12 = math.max(1, #runs - 19)
                    local dispatchExit10 = nil

                    for i30 = v14, v12, -1 do
                        local dispatch10 = 84

                        while true do
                            if dispatch10 < 89 then
                                if dispatch10 < 86 then
                                    if dispatch10 < 85 then
                                        v15 = runs[i30]
                                        v2 = runRow
                                        v3 = {}
                                        local u380 = (v15.at or 0) * 1000
                                        success_3, err_3 = pcall(function() -- Line: 4205; upvalues: u380 (val)
                                            return DateTime.fromUnixTimestampMillis(u380):FormatLocalTime("MMM D, HH:mm", "en-us")
                                        end)
                                        dispatch10 = if not success_3 then 86 else 85
                                    else
                                        v4 = err_3
                                        dispatch10 = 87
                                    end
                                elseif dispatch10 < 87 then
                                    v4 = ""
                                    dispatch10 = 87
                                elseif dispatch10 < 88 then
                                    v6 = v15.title or "—"
                                    dispatch10 = if not v15.flow then 89 else 88
                                else
                                    v7 = " · non-stop"
                                    dispatch10 = 90
                                end
                            elseif not (dispatch10 < 91) then
                                if not (dispatch10 < 92) then
                                    if not (dispatch10 < 93) then
                                        v6 = "—"
                                        break
                                    end

                                    v6 = (math.floor(v15.clean / v15.steps * 100 + 0.5))
                                        .. "%"
                                    break
                                end

                                dispatch10 = if not (0 < v15.steps) then 93 else 92
                            elseif dispatch10 < 90 then
                                v7 = ""
                                dispatch10 = 90
                            else
                                v5 = v6 .. v7
                                dispatch10 = if not v15.steps then 93 else 91
                            end
                        end

                        if dispatchExit10 then
                            break
                        end

                        v7 = tostring(v15.mistakes or 0)
                        v3[1] = v4
                        v3[2] = v5
                        v3[3] = v6
                        v3[4] = v7
                        v3[5] = u1578.fmtTime(v15.ms or 0)

                        v2(v3, false)
                    end

                    if not dispatchExit10 then end
                end

                dispatch = 95
            end
        end
    end

    function u1603.prefsHold(a1) -- Line: 4385; upvalues: u1603 (val), u2239 (ref), u2240 (ref); types: a1: boolean
        u1603.prefsOff = a1
        table.clear(u2239)

        u2240 = u2240 + 1
    end

    function u1603.openSettings(a1)
        -- Line: 4391
        -- upvalues: openDialog (val), box (val), tabBtn (val), u1603 (val), srow (val), range (val), choiceRow (val)
        -- upvalues: u1631 (val), u1642 (val), checkRow (val), u1684 (val), setSustain (val), Themes (val), Glyph (val)
        -- upvalues: text (val), img (val), Lay (val), u2388 (ref), setTheme (val), LocalPlayer (val), VP (val)
        -- upvalues: api (val), openMenu (val), input_2 (val), btn (val), toggleFullscreen (val)
        -- types: a1: string?
        local v1, v2
        local v3 = openDialog("Settings", true, 640)
        local v4 = box({
            dir = "row",
            bdc = "line",
            bds = {0, 0, 1, 0},
            pad = {0, 12},
            m = {0, -20, 0, -20},
            parent = v3,
        })
        local Settings = tabBtn("Settings")

        v4:add(Settings)

        local Statistics = tabBtn("Statistics")
        v4:add(Statistics)

        local u39 = box({
            scroll = true,
            dir = "col",
            gap = 4,
            grow = 1,
            vshrink = true,
            parent = v3,
        })
        local u42 = box({
            scroll = true,
            dir = "col",
            gap = 4,
            grow = 1,
            vshrink = true,
            hidden = true,
            parent = v3,
        })
        u42.inst.Visible = false
        local u45 = false

        local function show(a1)
            -- Line: 4400
            -- upvalues: u39 (val), u42 (val), Settings (val), Statistics (val), u45 (ref), u1603 (upval)
            -- types: a1: boolean
            u39:show(not a1)
            u42:show(a1)
            Settings:state("sel", not a1)
            Statistics:state("sel", a1)

            local v1 = if not a1 then "ink" else "muted"
            Settings.label.c = v1

            Settings.label:paint()

            v1 = if not a1 then "muted" else "ink"
            Statistics.label.c = v1

            Statistics.label:paint()

            if a1 and not u45 then
                u45 = true
                task.spawn(u1603.renderStatsPane, u42)
            end
        end

        Settings:onClick(function() -- Line: 4412; upvalues: u39 (val), u42 (val), Settings (val), Statistics (val)
            u39:show(true)
            u42:show(false)
            Settings:state("sel", true)
            Statistics:state("sel", false)

            Settings.label.c = "ink"
            Settings.label:paint()

            Statistics.label.c = "muted"
            Statistics.label:paint()
        end)

        Statistics:onClick(function() -- Line: 4413; upvalues: show (val)
            show(true)
        end)

        if u1603.vrRows then
            u1603.vrRows(u39, srow, range)
        end

        local v5 = srow(u39, "Keyboard view", "The computer keyboard is bigger and shows right away which note is on which key.")
        choiceRow(
            v5,
            {{"piano", "Piano"}, {"qwerty", "Computer keyboard"}},
            u1631.view,
            function(a1) -- Line: 4417; upvalues: u1603 (upval)
                u1603.setView(a1)
            end
        )

        u1642.viewRow = v5
        _, v2 = checkRow(
            srow(u39, "Default pedal", "On: notes ring on, and holding Space mutes them. Off: the opposite, Space makes them ring."),
            "On",
            u1684.pedalDefault,
            function(a1) -- Line: 4420; upvalues: u1684 (upval), u1642 (upval), setSustain (upval), u1603 (upval)
                u1684.pedalDefault = a1
                u1642.susBtn.set(a1)

                if u1642.setPedalCheck then
                    u1642.setPedalCheck(a1)
                end

                local v1 = u1684.pedalDefault ~= u1684.spaceDown

                if v1 ~= u1684.sustain then
                    setSustain(v1)
                end

                u1603.savePref("pedal", a1)
            end
        )
        u1642.setPedalCheck = v2
        _, v1 = checkRow(
            srow(u39, "Note names on piano keys"),
            "Show",
            u1631.names,
            function(a1) -- Line: 4423; upvalues: u1631 (upval), u1642 (upval), u1603 (upval)
                u1631.names = a1

                if u1642.setNamesCheck then
                    u1642.setNamesCheck(a1)
                end

                u1603.layoutPiano()
                u1603.savePref("names", a1)
            end
        )
        u1642.setNamesCheck = v1
        v1 = srow(u39, "Theme")
        u1642.themeRow = v1
        local u121 = box({
            dir = "row",
            align = "center",
            h = 38,
            bg = "panel2",
            bd = 1,
            bdc = "line",
            r = 8,
            button = true,
            pad = {8, 10},
            parent = v1,
        })
        v2 = 0

        for i, j in Themes.order do
            v2 = math.max(v2, (Glyph.width("s400_14", Themes.names[j])))
        end

        u121.w = v2 + 42.2
        local u151 = text({
            f = "s400_14",
            lh = 20,
            grow = 1,
            t = Themes.names[u1631.theme] or "Dark stage",
            pad = {0, 0, 0, 4},
            parent = u121,
        })
        local inst = u121.inst
        local u157 = img(
            "chev",
            {ZIndex = 3}
        )
        u157.Parent = inst

        function u121.afterApply(a1) -- Line: 4434; upvalues: u157 (val)
            u157.Position = UDim2.fromOffset(a1._pw - 8 - 6, 14)
        end

        function u121.onPaint() -- Line: 4435; upvalues: u157 (val), Lay (upval)
            u157.ImageColor3 = Lay.TH.ink.c
        end

        u121:paint()

        u121:onClick(function()
            -- Line: 4437
            -- upvalues: u2388 (upval), u121 (val), Lay (upval), u1603 (upval), u1631 (upval), setTheme (upval)
            -- upvalues: u151 (val), Themes (upval)
            if u2388 and u2388.anchor == u121 then
                if u2388 then
                    u2388:destroy()

                    u2388 = nil
                    Lay.dirty()
                end

                return
            end

            u1603.themeMenu(
                u121,
                u1631.theme,
                function(a1) -- Line: 4440; upvalues: setTheme (upval), u151 (upval), Themes (upval)
                    setTheme(a1)
                    u151:setText(Themes.names[a1])
                end
            )
        end)

        if u1603.keyRow then
            u1603.keyRow(u39, srow)
        end

        v1 = srow(u39, "Piano size", "88 keys show the whole piano. 61 keys are bigger; notes outside them still sound.")
        v1:show(not u1603.touchUI)

        choiceRow(
            v1,
            {{"88", "88 keys"}, {"61", "61 keys"}},
            tostring(u1631.kb),
            function(a1) -- Line: 4449; upvalues: u1631 (upval), u1603 (upval)
                u1631.kb = tonumber(a1) or 88
                u1603.layoutPiano()
                u1603.render()
                u1603.savePref("kb", u1631.kb)
            end
        )

        checkRow(
            srow(u39, "Donations in chat", "Show a line in the chat when someone donates."),
            "Show",
            u1631.donChat ~= false,
            function(a1) -- Line: 4456; upvalues: u1631 (upval), u1603 (upval)
                u1631.donChat = a1
                u1603.savePref("donChat", a1)
            end
        )

        v1 = srow(u39, "Rainbow Notes", "Your notes shine in every colour, for everyone to see. A game pass.")
        local u226 = nil
        local v6, v7 = checkRow(
            v1,
            "On",
            LocalPlayer:GetAttribute("Rainbow") == true,
            function(a1) -- Line: 4459; upvalues: LocalPlayer (upval), u226 (ref), VP (upval), api (upval)
                if LocalPlayer:GetAttribute("RainbowOwned") == true then
                    task.spawn(api, "setRainbow", a1)
                    return
                end

                u226(false)

                local v1 = tonumber((VP:GetAttribute("RainbowPass"))) or 0

                if v1 > 0 then
                    (game:GetService("MarketplaceService")):PromptGamePassPurchase(LocalPlayer, v1)
                end
            end
        )
        u226 = v7
        local u256 = (LocalPlayer:GetAttributeChangedSignal("Rainbow")):Connect(function()
            -- Line: 4470
            -- upvalues: u226 (ref), LocalPlayer (upval)
            u226(LocalPlayer:GetAttribute("Rainbow") == true)
        end)

        v1.inst.Destroying:Connect(function() -- Line: 4471; upvalues: u256 (val)
            u256:Disconnect()
        end)

        if u1603.noteStyleRow then
            u1603.noteStyleRow(u39, srow, checkRow, choiceRow, openMenu, input_2, range)
        end

        checkRow(
            srow(u39, "Join and leave messages", "Show a line in the chat when someone joins or leaves."),
            "Show",
            u1631.joinMsgs ~= false,
            function(a1) -- Line: 4474; upvalues: u1631 (upval), u1603 (upval)
                u1631.joinMsgs = a1
                u1603.savePref("joinMsgs", a1)
            end
        )

        checkRow(
            srow(u39, "Donation alerts", "Show a big message in the middle of the screen when someone donates to you."),
            "Show",
            u1631.donAlert ~= false,
            function(a1) -- Line: 4476; upvalues: u1631 (upval), u1603 (upval)
                u1631.donAlert = a1
                u1603.savePref("donAlert", a1)
            end
        )

        v1 = srow(u39, "Tour", "The short tour of the game from your first visit.")
        v5 = btn("Take the tour")

        v1:add(v5)

        v5:onClick(function() -- Line: 4480; upvalues: u1603 (upval)
            u1603.closeDialog()
            u1603.startTutorial()
        end)

        v1 = srow(u39, "Fullscreen", "Only the stage, the practice panel and the keyboard stay. Exit with the fullscreen button on the stage.", true)
        v5 = btn(if not u1631.fullscreen then "Open fullscreen" else "Exit fullscreen")

        v1:add(v5)

        v5:onClick(function() -- Line: 4484; upvalues: u1603 (upval), toggleFullscreen (upval)
            u1603.closeDialog()
            toggleFullscreen()
        end)

        show(a1 == "stats")
    end

    require(script:WaitForChild("Shop"))({
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        P = u1631,
        api = api,
        Lay = Lay,
        LP = LocalPlayer,
        L145 = v15,
        btn = btn,
        note = note,
        eyebrow = eyebrow,
        openDialog = openDialog,
        input = input_2,
        statusLine = statusLine,
        toast = toast,
        gui = ScreenGui,
        Glyph = Glyph,
    })

    require(script:WaitForChild("NoteStyle"))({
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        Lay = Lay,
        LP = LocalPlayer,
        api = api,
        btn = btn,
        note = note,
        img = img,
        FX = fx,
    })

    require(script:WaitForChild("ThemeMenu"))({
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        Lay = Lay,
        LP = LocalPlayer,
        Themes = Themes,
        openMenu = openMenu,
        toast = toast,
    })

    require(script:WaitForChild("Section"))({
        U = u1642,
        F = u1603,
        S = u1805,
        toast = toast,
        setPressed = setPressed,
    })

    require(script:WaitForChild("Hotkeys"))({
        B = box,
        U = u1642,
        F = u1603,
        S = u1805,
        btn = btn,
        toast = toast,
    })

    require(script:WaitForChild("LoadNotice"))({
        U = u1642,
        F = u1603,
        Audio = Audio,
        Lay = Lay,
        Glyph = Glyph,
        viewport = viewport,
    })

    require(script:WaitForChild("Moderation"))({
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        P = u1631,
        Lay = Lay,
        LP = LocalPlayer,
        api = api,
        btn = btn,
        note = note,
        eyebrow = eyebrow,
        openDialog = openDialog,
        input = input_2,
        statusLine = statusLine,
        toast = toast,
        L145 = v15,
        VP = VP,
    })

    require(script:WaitForChild("Rooms"))({
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        api = api,
        Lay = Lay,
        LP = LocalPlayer,
        L145 = v15,
        btn = btn,
        note = note,
        openDialog = openDialog,
        input = input_2,
        statusLine = statusLine,
        tag = tag,
        isAdmin = isAdmin,
        enterRoom = enterRoom,
    })

    require(script:WaitForChild("Panels"))({
        RunService = __real_registers[8],
        LP = LocalPlayer,
        Levels = Levels,
        Lay = Lay,
        Audio = Audio,
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        api = api,
        S = u1805,
        A = u1684,
        P = u1631,
        L145 = v15,
        btn = btn,
        eyebrow = eyebrow,
        note = note,
        radio = radio,
        range = range,
        restart = restart,
        openDialog = openDialog,
        input = input_2,
        statusLine = statusLine,
        findSheet = function(a1) -- Line: 2746; upvalues: u3682 (ref), Sheets (val); types: a1: string
            for i, j in u3682 do
                if j.id == a1 then
                    return j
                end
            end

            for k, n in Sheets do
                if n.id == a1 then
                    return n
                end
            end

            return nil
        end,
        findCommunity = function(a1) -- Line: 2751; upvalues: u3710 (val); types: a1: string
            for i, j in u3710.index do
                if j.id == a1 then
                    return j
                end
            end

            return nil
        end,
        smallBtn = smallBtn,
    })

    require(script:WaitForChild("Review"))({
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        P = u1631,
        S = u1805,
        Lay = Lay,
        LP = LocalPlayer,
        api = api,
        btn = btn,
        smallBtn = smallBtn,
        note = note,
        tag = tag,
        openDialog = openDialog,
        input = input_2,
        field = field,
        statusLine = statusLine,
        toast = toast,
        L145 = v15,
        levelRun = function(a1) -- Line: 2756; upvalues: Levels (val); types: a1: string?
            local v1 = Levels.get(a1)

            if not v1 then
                return nil
            end

            return Levels.runs(v1.name)
        end,
        levelPicker = levelPicker,
        viewport = viewport,
        loadSheet = loadSheet,
        isAdmin = isAdmin,
        Notes = u1578,
        Levels = Levels,
        COMM = u3710,
        Glyph = Glyph,
    })

    require(script:WaitForChild("RestartNotice"))({
        U = u1642,
        F = u1603,
        Lay = Lay,
        Glyph = Glyph,
        viewport = viewport,
        VP = VP,
    })

    require(script:WaitForChild("Effects"))({
        B = box,
        F = u1603,
        Lay = Lay,
        FX = fx,
        img = img,
    })

    require(script:WaitForChild("VipDemo"))({
        B = box,
        U = u1642,
        F = u1603,
        Lay = Lay,
        Notes = u1578,
        COMM = u3710,
        api = api,
        FX = fx,
        img = img,
        Glyph = Glyph,
    })

    require(script:WaitForChild("Tips"))({
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        S = u1805,
        P = u1631,
        Lay = Lay,
        btn = btn,
        L145 = v15,
        Glyph = Glyph,
    })

    u1642.setBtn:onClick(function() -- Line: 4506; upvalues: u1603 (val)
        u1603.openSettings()
    end)

    function u1603.setView(a1, a2)
        -- Line: 4508
        -- upvalues: u1684 (val), u1778 (ref), u2233 (ref), paintKey (val), u1631 (val), u1755 (val), u1322 (val)
        -- upvalues: u1642 (val), Lay (val), u1603 (val)
        -- types: a1: string, a2: boolean?
        local v1 = a1 == "qwerty"

        for i in u1684.held do
            u1778(i)
        end

        for j, k in u2233 do
            k.down = false
            k.target = false
            k.got = false
            k.rdown = 0
            k.flash = nil

            paintKey(k)
        end

        u1631.view = if not v1 then "piano" else "qwerty"
        u2233 = if not v1 then u1322 else u1755

        u1642.piano:show(not v1)
        u1642.qwerty:show(v1)
        Lay.now()
        u1603.layoutQwerty()
        u1603.layoutStage()
        task.defer(u1603.render)

        if not a2 then
            u1603.savePref("view", u1631.view)
        end
    end

    local u3029 = {
        One = "1",
        Two = "2",
        Three = "3",
        Four = "4",
        Five = "5",
        Six = "6",
        Seven = "7",
        Eight = "8",
        Nine = "9",
        Zero = "0",
    }

    local function charFor(a1) -- Line: 4528; upvalues: UserInputService (val), u3029 (val), u1578 (val), NOTE (val)
        local v1
        local Name = a1.Name
        local v2 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

        if u3029[Name] then
            v1 = u3029[Name]
            local v3 = if not v2 then v1 else u1578.DIGSHIFT[v1]

            if NOTE[v3] then
                return v3
            end

            if NOTE[v1] then
                return v1
            end

            return nil
        end

        if #Name == 1 and Name >= "A" and Name <= "Z" then
            v1 = if not v2 then string.lower(Name) else Name

            if NOTE[v1] then
                return v1
            end

            v1 = string.lower(Name)

            if NOTE[v1] then
                return v1
            end

            return nil
        end

        return nil
    end

    u1603.ctrlHeld = {}

    function u1603.ctrlMidi(a1) -- Line: 4546; upvalues: UserInputService (val), u3029 (val), u1603 (val)
        if not UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            and not UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            return nil
        end

        local Name = a1.Name
        local v1 = u3029[Name] or (if #Name ~= 1 then nil else string.lower(Name))

        if not v1 then
            return nil
        end

        local v2 = string.find(u1603.CTRL_LO, v1, 1, true)

        if v2 then
            return 20 + v2
        end

        v2 = string.find(u1603.CTRL_HI, v1, 1, true)

        if v2 then
            return 96 + v2
        end

        return nil
    end

    local u3034 = {}

    UserInputService.InputBegan:Connect(function(a1, a2)
        -- Line: 4558
        -- upvalues: u1642 (val), UserInputService (val), GuiService (val), u1603 (val), u1631 (val), u1684 (val)
        -- upvalues: setSustain (val), Audio (val), toast (val), u3034 (val), u1327 (ref), charFor (val), u1767 (ref)
        if a1.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end

        if u1642.dialog and not u1642.dialog.playable then
            return
        end

        if not UserInputService:GetFocusedTextBox() and not GuiService.MenuIsOpen then
            local v1

            if a1.KeyCode == Enum.KeyCode.Tab then
                u1603.setHudOpen(u1631.hudOpen == false)
                return
            end

            local KeyCode = a1.KeyCode

            if KeyCode == Enum.KeyCode.Space then
                u1684.spaceDown = true
                v1 = u1684.pedalDefault ~= u1684.spaceDown

                if v1 ~= u1684.sustain then
                    setSustain(v1)
                end

                return
            end

            if KeyCode == Enum.KeyCode.Up then
                u1684.transpose = math.clamp(u1684.transpose + 1, -12, 12)
                u1642.trOut:setText(if not (0 < u1684.transpose) then tostring(u1684.transpose) else "+" .. u1684.transpose)
                u1603.layoutPiano()
                u1603.render()

                return
            end

            if KeyCode == Enum.KeyCode.Down then
                u1684.transpose = math.clamp(u1684.transpose - 1, -12, 12)
                u1642.trOut:setText(if not (0 < u1684.transpose) then tostring(u1684.transpose) else "+" .. u1684.transpose)
                u1603.layoutPiano()
                u1603.render()

                return
            end

            if KeyCode ~= Enum.KeyCode.Right and KeyCode ~= Enum.KeyCode.Left then
                if KeyCode == Enum.KeyCode.Return then
                    if not u1631.fullscreen then
                        if u1631.collapsed then
                            u1603.setCollapsed(false)
                        end

                        u1603.showTab("chat")

                        task.defer(function() -- Line: 4581; upvalues: u1642 (upval)
                            u1642.chatInput:CaptureFocus()
                        end)
                    end

                    return
                end

                if KeyCode ~= Enum.KeyCode.LeftBracket
                    and KeyCode ~= Enum.KeyCode.RightBracket then
                    v1 = u1603.ctrlMidi(KeyCode)

                    if v1 then
                        if not u1603.ctrlHeld[KeyCode] and not u3034[KeyCode] then
                            local v2 = math.clamp(v1 + u1684.transpose, 21, 108)
                            u1603.ctrlHeld[KeyCode] = v2

                            u1327(v2)

                            return
                        end

                        return
                    end

                    v1 = charFor(KeyCode)

                    if v1 and not u3034[KeyCode] then
                        u3034[KeyCode] = v1
                        u1767(v1, "user")

                        return
                    end

                    return
                end

                u1603.tapStep(KeyCode, true)

                return
            end

            v1 = math.clamp((math.floor(u1684.volume * 100 + 0.5)) + (if KeyCode ~= Enum.KeyCode.Right then -5 else 5), 0, 100)
            u1684.volume = v1 / 100

            Audio.setVolume(u1684.volume)
            u1642.volRange.set(v1)
            u1603.savePref("vol", u1684.volume)
            toast("Volume " .. v1 .. "%")
        end
    end)

    UserInputService.InputEnded:Connect(function(a1)
        -- Line: 4599
        -- upvalues: u1684 (val), setSustain (val), u1603 (val), u1328 (ref), u3034 (val), u1778 (ref)
        local v1

        if a1.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end

        local KeyCode = a1.KeyCode

        if KeyCode == Enum.KeyCode.Space then
            u1684.spaceDown = false
            v1 = u1684.pedalDefault ~= u1684.spaceDown

            if v1 ~= u1684.sustain then
                setSustain(v1)
            end

            return
        end

        if KeyCode ~= Enum.KeyCode.LeftBracket and KeyCode ~= Enum.KeyCode.RightBracket then
            v1 = u1603.ctrlHeld[KeyCode]

            if v1 then
                u1603.ctrlHeld[KeyCode] = nil
                u1328(v1)

                return
            end

            v1 = u3034[KeyCode]

            if v1 then
                u3034[KeyCode] = nil
                u1778(v1)
            end

            return
        end

        u1603.tapStep(KeyCode, false)
    end)

    UserInputService.WindowFocusReleased:Connect(function()
        -- Line: 4616
        -- upvalues: u3034 (val), u1778 (ref), u1603 (val), u1328 (ref), u1684 (val), setSustain (val)
        for i, j in u3034 do
            u3034[i] = nil
            u1778(j)
        end

        for k, n in u1603.ctrlHeld do
            u1603.ctrlHeld[k] = nil
            u1328(n)
        end

        for m in u1603.tapHeld do
            u1603.tapStep(m, false)
        end

        u1684.spaceDown = false
        local v1 = u1684.pedalDefault ~= u1684.spaceDown

        if v1 ~= u1684.sustain then
            setSustain(v1)
        end
    end)

    u1603.Icons = require(VP:WaitForChild("Icons"))

    function u1603.hasIcons() -- Line: 4628; upvalues: u1603 (val)
        local v1 = false

        if u1603.Icons.image ~= "rbxassetid://0" then
            v1 = u1603.Icons.image ~= ""
        end

        return v1
    end

    function u1603.setIco(a1, a2) -- Line: 4631; upvalues: u1603 (val); types: a2: string
        local v1 = a1 and u1603.Icons.cells[a2]

        if not v1 then
            return
        end

        a1.im.ImageRectOffset = Vector2.new(v1[1], v1[2])
        a1.im.ImageRectSize = Vector2.new(v1[3], v1[3])
    end

    function u1603.ico(a1, a2, a3)
        -- Line: 4638
        -- upvalues: box (val), u1603 (val), Lay (val)
        -- types: a1: string, a2: number
        local v1 = box({noShrink = true, w = a2, h = a2})
        local ImageLabel = Instance.new("ImageLabel")
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.Size = UDim2.fromScale(1, 1)
        ImageLabel.Image = u1603.Icons.image
        ImageLabel.ScaleType = Enum.ScaleType.Fit
        ImageLabel.Parent = v1.inst
        v1.im = ImageLabel
        v1.c = a3

        function v1.onPaint(a1) -- Line: 4648; upvalues: ImageLabel (val), Lay (upval)
            if a1.c == false then
                ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
                ImageLabel.ImageTransparency = 0

                return
            end

            local v1, v2 = Lay.col(a1.c or "muted")

            if v1 then
                ImageLabel.ImageColor3 = v1
                ImageLabel.ImageTransparency = 1 - (v2 or 1)
            end
        end

        u1603.setIco(v1, a1)
        v1:paint()

        return v1
    end

    function u1603.iconify(a1, a2, a3, a4)
        -- Line: 4665
        -- upvalues: u1603 (val), Lay (val)
        -- types: a2: string, a3: number?, a4: boolean?
        if u1603.hasIcons() and a1 then
            local label = a1.label
            local u18 = u1603.ico(a2, a3 or 16, if not label then "muted" else label.c)

            a1:add(u18)
            table.remove(a1.kids)
            table.insert(a1.kids, 1, u18)

            a1.ico = u18

            if (a1.gap or 0) < 5 then
                a1.gap = 5
            end

            if label then
                if a4 then
                    label:show(false)
                end

                local onPaint = label.onPaint

                function label.onPaint(a1) -- Line: 4677; upvalues: onPaint (val), u18 (val)
                    if onPaint then
                        onPaint(a1)
                    end

                    u18.c = a1.c
                    u18:paint()
                end
            end

            Lay.dirty()

            return u18
        end

        return nil
    end

    function u1603.iconOr(a1, a2, a3) -- Line: 4687; upvalues: u1603 (val); types: a2: string, a3: string
        if a1 and a1.ico then
            u1603.setIco(a1.ico, a2)
            return
        end

        if a1 and a1.label then
            a1.label:setText(a3)
        end
    end

    function u1603.applyIcons() -- Line: 4690; upvalues: u1603 (val), Lay (val), u1642 (val), u1631 (val), u1805 (val)
        if not u1603.hasIcons() then
            return
        end

        local v1 = u1603.ico("logo", 26, false)
        v1.m = Lay.pad4({0, -5, 0, 0})

        u1642.topbar:add(v1)
        table.remove(u1642.topbar.kids)
        table.insert(u1642.topbar.kids, 1, v1)
        u1603.iconify(u1642.reviewBtn, "clipboard-check", 15)
        u1603.iconify(u1642.lbBtn, "trophy", 15)
        u1603.iconify(u1642.muteBtn, "volume-2", 15)
        u1642.setBtn.label:setText("Settings")
        u1603.iconify(u1642.setBtn, "settings", 15)
        u1603.iconify(u1642.sideBtn, if not u1631.collapsed then "panel-left-close" else "panel-left-open", 16, true)

        for i, j in {{u1642.tabChat, "message-circle"}, {u1642.tabLib, "list-music"}} do
            j[1].dir = "row"
            j[1].justify = "center"
            j[1].align = "center"

            u1603.iconify(j[1], j[2], 15)
        end

        u1642.chatSend.label = u1642.chatSend.kids[1]
        u1603.iconify(u1642.chatSend, "send", 16, true)
        u1603.iconify(u1642.secHud, "list-filter", 13)
        u1603.iconify(u1642.editHud, "pencil", 13)
        u1642.playBtn.label:setText(if not u1805.playing then "Play" else "Pause")
        u1603.iconify(u1642.playBtn, if not u1805.playing then "play-fill" else "pause", 12)
        u1603.iconify(u1642.loopBtn, "repeat", 14, true)
        u1603.iconify(u1642.restartBtn, "rotate-ccw", 14, true)
        u1603.iconify(u1642.minBtn, if not u1631.hudMin then "chevron-up" else "chevron-down", 14, true)
        u1603.iconify(u1642.closeBtn, "x", 14, true)
        u1603.iconify(u1642.fsBtn, if not u1631.fullscreen then "maximize" else "minimize", 15, true)

        for k, n in {
            {u1642.libResetBtn, "rotate-ccw"},
            {u1642.libRandomBtn, "shuffle"},
            {u1642.libHistBtn, "history"},
        } do
            if n[1] then
                n[1].dir = "row"
                n[1].align = "center"

                u1603.iconify(n[1], n[2], 13)
            end
        end

        Lay.dirty()
    end

    u1603.applyIcons()

    if __real_registers[8]:IsStudio() then
        __real_registers[37] = Instance.new("BindableFunction")
        __real_registers[37].Name = "VPDebug"

        __real_registers[37].OnInvoke = function(a1, a2, a3)
            -- Line: 4741
            -- upvalues: u1642 (val), Lay (val)
            -- types: a1: number, a2: number, a3: table
            local parent, v1, v2, v3
            local m = u1642.topbar.m
            u1642.topbar.m = {0, 0, 0, 0}

            Lay.layoutNode(u1642.app, a1, a2)

            local v4 = {}

            local function abs(a1) -- Line: 4746
                local v1 = 0
                local v2 = 0
                local parent = a1

                while parent do
                    v1 = v1 + (parent.lx or 0)
                    v2 = v2 + (parent.ly or 0)
                    parent = parent.parent
                end

                return v1, v2
            end

            local v5 = nil
            local v6 = nil

            for i, j in a3, v5, v6 do
                v1 = u1642[j]

                if v1 and v1.lw then
                    v2 = 0
                    v3 = 0
                    parent = v1

                    while parent do
                        v2 = v2 + (parent.lx or 0)
                        v3 = v3 + (parent.ly or 0)
                        parent = parent.parent
                    end

                    v4[j] = (string.format("%.2f,%.2f %.2fx%.2f", v2, v3, v1.lw, v1.lh_ or -1))
                end
            end

            u1642.topbar.m = m
            Lay.now()

            return v4
        end

        __real_registers[37].Parent = ScreenGui
    end

    u1603.showTab("chat")
    setMode("practice")
    setPressed(u1642.flowBtn, false)
    setPressed(u1642.loopBtn, false)
    v48("grand", true)
    v45(0)

    if not Sheets[1] then
        u1603.clearSheet()
    else
        loadSheet(Sheets[1].title, Sheets[1].text, Sheets[1].id)
    end

    v61()
    renderPlayers()
    v58(if not VP:GetAttribute("IsRoom") then "You're in the lobby. Everyone here can hear you." else "You're in room \"" .. __real_registers[36]() .. "\"")
    Lay.now()

    require(script:WaitForChild("Mobile"))({
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        P = u1631,
        A = u1684,
        S = u1805,
        Lay = Lay,
        LP = LocalPlayer,
        Glyph = Glyph,
        Notes = u1578,
        pianoKeys = u1322,
        paintKey = paintKey,
        press = u1767,
        release = u1778,
        pressRaw = u1327,
        releaseRaw = u1328,
        img = img,
        FX = fx,
        viewport = viewport,
        gui = ScreenGui,
    })

    require(script:WaitForChild("VR"))({
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        P = u1631,
        A = u1684,
        Lay = Lay,
        Notes = u1578,
        Glyph = Glyph,
        pianoKeys = u1322,
        press = u1767,
        release = u1778,
        pressRaw = u1327,
        releaseRaw = u1328,
        btn = btn,
        glyphLabel = v32,
        img = img,
        FX = fx,
    })

    require(script:WaitForChild("Podium"))({
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        P = u1631,
        A = u1684,
        Lay = Lay,
        LP = LocalPlayer,
        api = api,
        btn = btn,
        note = note,
        toast = toast,
        L145 = v15,
        VP = VP,
        Notes = u1578,
        pianoKeys = u1322,
        gui = ScreenGui,
        talking = u2680,
        lastPlay = u1941,
        colorOf = function(a1) -- Line: 1514; upvalues: LocalPlayer (val), u1959 (val); types: a1: number
            if a1 == LocalPlayer.UserId then
                return Color3.fromHex("e6e6e6")
            end

            return Color3.fromHex(u1959[a1 % (#u1959 - 1) + 1])
        end,
        Audio = Audio,
        openDialog = openDialog,
        input = input_2,
        eyebrow = eyebrow,
    })

    require(script:WaitForChild("Tutorial"))({
        B = box,
        T = text,
        U = u1642,
        F = u1603,
        S = u1805,
        P = u1631,
        Lay = Lay,
        btn = btn,
        note = note,
        eyebrow = eyebrow,
        L145 = v15,
        toast = toast,
        COMM = u3710,
        press = u1767,
        release = u1778,
    })

    u1603.DEVICES = {
        phone = {"smartphone", "a phone"},
        tablet = {"tablet", "a tablet"},
        computer = {"monitor", "a computer"},
        console = {"gamepad-2", "a console"},
        vr = {"vr", "VR"},
    }
    local u3313 = ""

    function v61() -- Line: 4797; upvalues: UserInputService (val), GuiService (val), u1603 (val)
        if UserInputService.VREnabled then
            return "vr"
        end

        if GuiService:IsTenFootInterface() then
            return "console"
        end

        if not u1603.touchUI then
            return "computer"
        end

        if u1603.phoneNow then
            return "phone"
        end

        return "tablet"
    end

    local function send()
        -- Line: 4803
        -- upvalues: UserInputService (val), GuiService (val), u1603 (val), u3313 (ref), api (val)
        local v1 = if not UserInputService.VREnabled then
            if not GuiService:IsTenFootInterface() then
                if not u1603.touchUI then
                    "computer"
                else
                    if not u1603.phoneNow then "tablet" else "phone"
            else
                "console"
        else
            "vr"

        if v1 ~= u3313 then
            u3313 = v1
            task.spawn(api, "setDevice", v1)
        end
    end

    task.delay(2, send)

    ;(ScreenGui:GetPropertyChangedSignal("AbsoluteSize")):Connect(function() -- Line: 4811; upvalues: send (val)
        task.delay(1, send)
    end)

    task.spawn(function()
        -- Line: 4814
        -- upvalues: Api (val), u1642 (val), Lay (val), u3682 (ref), u3724 (ref), u3696 (ref), u2003 (ref), u1603 (val)
        -- upvalues: u1631 (val), u3710 (val), setTheme (val), u1684 (val), setSustain (val), u1805 (val), Audio (val)
        -- upvalues: Sheets (val), loadSheet (val)
        local activeId, lastSheet, v1, v2, v3
        local u0 = "profile"
        local u1 = nil
        local success, err = pcall(function() -- Line: 50; upvalues: Api (upval), u0 (val), u1 (val)
            return Api:InvokeServer(u0, u1)
        end)
        local v4 = if not (type(if success then err else nil) == "table") then "dim" else "ok"
        u1642.connDot.bg = v4

        u1642.connDot:paint()

        u1642.connGlow.Visible = v2
        u1642.connGlow.ImageColor3 = Lay.TH.ok.c
        u1642.connGlow.ImageTransparency = 0.4

        if type(v1) ~= "table" then
            return
        end

        local settings = v1.settings or {}
        u3682 = if type(v1.sheets) ~= "table" then {} else v1.sheets
        u3724 = if type(v1.favs) ~= "table" then {} else v1.favs
        u3696 = v1.myRoom

        if type(settings.pv) == "table" then
            local v5

            for i, j in settings.pv do
                if type(j) == "table"
                    and type(j.v) == "number"
                    and u1603.setVoiceVol
                    and tonumber(i) then
                    v5 = tonumber(i)
                    u1603.setVoiceVol(v5, j.v)
                end
            end
        end

        u1631.hist = if type(settings.hist) ~= "table" then {} else settings.hist
        u1631.rating = tonumber(v1.rating)
        u1631.profileReady = true
        u3710.myRates = if type(v1.rates) ~= "table" then {} else v1.rates

        if settings.donChat == false then
            u1631.donChat = false
        end

        if settings.donAlert == false then
            u1631.donAlert = false
        end

        if settings.joinMsgs == false then
            u1631.joinMsgs = false
        end

        if settings.mineFold == true then
            u1631.mineFold = true
            u1603.renderLib()
        end

        task.spawn(function() -- Line: 4837; upvalues: Api (upval), u1603 (upval)
            local u0 = "shop"
            local u1 = nil
            local success, err = pcall(function() -- Line: 50; upvalues: Api (upval), u0 (val), u1 (val)
                return Api:InvokeServer(u0, u1)
            end)
            local v1 = if success then err else nil

            if type(v1) == "table" then
                u1603.shopInfo = v1
            end
        end)

        if settings.kb == 61 then
            u1631.kb = 61
            u1603.layoutPiano()
        end

        if u1603.mobPrefs then
            u1603.mobPrefs(settings.mob)
        end

        if u1603.vrPrefs then
            u1603.vrPrefs(settings.vr)
        end

        if u1603.nsPrefs then
            u1603.nsPrefs(settings)
        end

        local u175 = false
        task.spawn(function() -- Line: 4844; upvalues: u1603 (upval), u175 (ref)
            u1603.loadCommunity(true)

            u175 = true
            u1603.renderLib()
        end)

        local function waitLib() -- Line: 4845; upvalues: u175 (ref)
            local v1 = os.clock()

            while not u175 do
                if not (os.clock() - v1 < 15) then
                    break
                end

                task.wait(0.1)
            end
        end

        u1603.refreshReview()

        if type(settings.theme) == "string" then
            setTheme(settings.theme, true)
        end

        if u1603.keyPrefs then
            u1603.keyPrefs(settings)
        end

        if settings.view == "qwerty" then
            u1603.setView("qwerty", true)
        end

        if settings.sshift == true then
            u1603.setStickyShift(true, true)
        end

        if type(settings.pedal) == "boolean" then
            local pedal_2 = settings.pedal
            u1684.pedalDefault = pedal_2

            u1642.susBtn.set(pedal_2)

            if u1642.setPedalCheck then
                u1642.setPedalCheck(pedal_2)
            end

            v3 = u1684.pedalDefault ~= u1684.spaceDown

            if v3 ~= u1684.sustain then
                setSustain(v3)
            end
        end

        if type(settings.names) == "boolean" then
            local names_2 = settings.names
            u1631.names = names_2

            if u1642.setNamesCheck then
                u1642.setNamesCheck(names_2)
            end

            u1603.layoutPiano()
        end

        if type(settings.flow) == "boolean" then
            u1805.flow = settings.flow
            local flowBtn = u1642.flowBtn
            local flow_2 = u1805.flow

            flowBtn:state("on", flow_2)

            flowBtn.label.c = if not flow_2 then
                if not flowBtn.primary then "ink" else "bg"
            else
                "brassInk"
            flowBtn.label:paint()
        end

        if type(settings.instr) == "string" then
            v3 = Audio.byKey[settings.instr]

            if not v3 or v3.id == "" then
                v3 = Audio.list[1]
            end

            u1684.instr = v3.key
            u1642.instrLbl:setText(v3.name)
            Audio.load(v3.key)
        end

        if type(settings.vel) == "number" then
            u1684.velocity = math.clamp(math.floor(settings.vel), 1, 127)
            u1642.velRange.set(u1684.velocity)
            u1642.velCap:setRuns({{t = "Velocity ", c = "muted"}, {c = "ink", t = tostring(u1684.velocity)}})
        end

        if type(settings.sfx) == "table" then
            u1631.sfx = u1603.Sfx.clean(settings.sfx)
        elseif settings.reverb == false then
            u1631.sfx = u1603.Sfx.clean({})
        end

        if type(settings.sfxSlots) == "table" then
            u1631.sfxSlots = settings.sfxSlots
        end

        if type(settings.ifav) == "table" then
            u1631.ifav = settings.ifav
        end

        u1603.applySfx(true)

        if type(settings.bpm) == "number" then
            u1603.setBpm(settings.bpm, false, true)
        end

        if type(settings.vol) == "number" then
            u1684.volume = settings.vol
            Audio.setVolume(settings.vol)
            u1642.volRange.set((math.floor(settings.vol * 100 + 0.5)))
        end

        if type(settings.hudPos) == "table"
            and type(settings.hudPos.x) == "number"
            and type(settings.hudPos.y) == "number" then
            u1631.hudPos = {x = settings.hudPos.x, y = settings.hudPos.y}
            u1642.hud.abs = {clamp = true, l = settings.hudPos.x, t = settings.hudPos.y}

            Lay.dirty()
        end

        if settings.hud == false then
            u1603.setHudOpen(false, true)
        end

        if type(settings.lastSheet) == "string" then
            local lastSheet_3 = settings.lastSheet

            for k, n in u3682 do
                if n.id == lastSheet_3 then
                    v4 = n

                    if not v4 then
                        if type(settings.lastSheet) ~= "string" then
                            u1603.renderLib()
                        else
                            lastSheet = settings.lastSheet
                            activeId = u1805.activeId

                            task.spawn(function()
                                -- Line: 4877
                                -- upvalues: waitLib (val), lastSheet (val), u3710 (upval), u1805 (upval)
                                -- upvalues: activeId (val), u1603 (upval)
                                local v1
                                waitLib()

                                for i, j in u3710.index do
                                    if j.id == lastSheet then
                                        v1 = j

                                        if v1 and u1805.activeId == activeId then
                                            u1603.autoOpening = true
                                            pcall(u1603.openCommunity, v1)

                                            u1603.autoOpening = nil
                                        end

                                        return
                                    end
                                end

                                v1 = nil

                                if v1 and u1805.activeId == activeId then
                                    u1603.autoOpening = true
                                    pcall(u1603.openCommunity, v1)

                                    u1603.autoOpening = nil
                                end
                            end)
                        end
                    elseif v4.status ~= "rejected" then
                        loadSheet(v4.title, v4.text, v4.id)
                    elseif type(settings.lastSheet) ~= "string" then
                        u1603.renderLib()
                    else
                        lastSheet = settings.lastSheet
                        activeId = u1805.activeId

                        task.spawn(function()
                            -- Line: 4877
                            -- upvalues: waitLib (val), lastSheet (val), u3710 (upval), u1805 (upval), activeId (val)
                            -- upvalues: u1603 (upval)
                            local v1
                            waitLib()

                            for i, j in u3710.index do
                                if j.id == lastSheet then
                                    v1 = j

                                    if v1 and u1805.activeId == activeId then
                                        u1603.autoOpening = true
                                        pcall(u1603.openCommunity, v1)

                                        u1603.autoOpening = nil
                                    end

                                    return
                                end
                            end

                            v1 = nil

                            if v1 and u1805.activeId == activeId then
                                u1603.autoOpening = true
                                pcall(u1603.openCommunity, v1)

                                u1603.autoOpening = nil
                            end
                        end)
                    end

                    if settings.tut ~= true and not u1603.vrOn then
                        u1631.firstTour = true
                        task.spawn(function() -- Line: 4890; upvalues: waitLib (val), u1603 (upval)
                            waitLib()
                            task.wait(1.2)
                            u1603.startTutorial()
                        end)
                    end

                    if u1603.tipPrefs then
                        u1603.tipPrefs(settings)
                    end

                    return
                end
            end

            for m, i5 in Sheets do
                if i5.id == lastSheet_3 then
                    v4 = i5

                    if not v4 then
                        if type(settings.lastSheet) ~= "string" then
                            u1603.renderLib()
                        else
                            lastSheet = settings.lastSheet
                            activeId = u1805.activeId

                            task.spawn(function()
                                -- Line: 4877
                                -- upvalues: waitLib (val), lastSheet (val), u3710 (upval), u1805 (upval)
                                -- upvalues: activeId (val), u1603 (upval)
                                local v1
                                waitLib()

                                for i, j in u3710.index do
                                    if j.id == lastSheet then
                                        v1 = j

                                        if v1 and u1805.activeId == activeId then
                                            u1603.autoOpening = true
                                            pcall(u1603.openCommunity, v1)

                                            u1603.autoOpening = nil
                                        end

                                        return
                                    end
                                end

                                v1 = nil

                                if v1 and u1805.activeId == activeId then
                                    u1603.autoOpening = true
                                    pcall(u1603.openCommunity, v1)

                                    u1603.autoOpening = nil
                                end
                            end)
                        end
                    elseif v4.status ~= "rejected" then
                        loadSheet(v4.title, v4.text, v4.id)
                    elseif type(settings.lastSheet) ~= "string" then
                        u1603.renderLib()
                    else
                        lastSheet = settings.lastSheet
                        activeId = u1805.activeId

                        task.spawn(function()
                            -- Line: 4877
                            -- upvalues: waitLib (val), lastSheet (val), u3710 (upval), u1805 (upval), activeId (val)
                            -- upvalues: u1603 (upval)
                            local v1
                            waitLib()

                            for i, j in u3710.index do
                                if j.id == lastSheet then
                                    v1 = j

                                    if v1 and u1805.activeId == activeId then
                                        u1603.autoOpening = true
                                        pcall(u1603.openCommunity, v1)

                                        u1603.autoOpening = nil
                                    end

                                    return
                                end
                            end

                            v1 = nil

                            if v1 and u1805.activeId == activeId then
                                u1603.autoOpening = true
                                pcall(u1603.openCommunity, v1)

                                u1603.autoOpening = nil
                            end
                        end)
                    end

                    if settings.tut ~= true and not u1603.vrOn then
                        u1631.firstTour = true
                        task.spawn(function() -- Line: 4890; upvalues: waitLib (val), u1603 (upval)
                            waitLib()
                            task.wait(1.2)
                            u1603.startTutorial()
                        end)
                    end

                    if u1603.tipPrefs then
                        u1603.tipPrefs(settings)
                    end

                    return
                end
            end
        end

        v4 = nil

        if not v4 then
            if type(settings.lastSheet) ~= "string" then
                u1603.renderLib()
            else
                lastSheet = settings.lastSheet
                activeId = u1805.activeId

                task.spawn(function()
                    -- Line: 4877
                    -- upvalues: waitLib (val), lastSheet (val), u3710 (upval), u1805 (upval), activeId (val)
                    -- upvalues: u1603 (upval)
                    local v1
                    waitLib()

                    for i, j in u3710.index do
                        if j.id == lastSheet then
                            v1 = j

                            if v1 and u1805.activeId == activeId then
                                u1603.autoOpening = true
                                pcall(u1603.openCommunity, v1)

                                u1603.autoOpening = nil
                            end

                            return
                        end
                    end

                    v1 = nil

                    if v1 and u1805.activeId == activeId then
                        u1603.autoOpening = true
                        pcall(u1603.openCommunity, v1)

                        u1603.autoOpening = nil
                    end
                end)
            end
        elseif v4.status ~= "rejected" then
            loadSheet(v4.title, v4.text, v4.id)
        elseif type(settings.lastSheet) ~= "string" then
            u1603.renderLib()
        else
            lastSheet = settings.lastSheet
            activeId = u1805.activeId

            task.spawn(function()
                -- Line: 4877
                -- upvalues: waitLib (val), lastSheet (val), u3710 (upval), u1805 (upval), activeId (val), u1603 (upval)
                local v1
                waitLib()

                for i, j in u3710.index do
                    if j.id == lastSheet then
                        v1 = j

                        if v1 and u1805.activeId == activeId then
                            u1603.autoOpening = true
                            pcall(u1603.openCommunity, v1)

                            u1603.autoOpening = nil
                        end

                        return
                    end
                end

                v1 = nil

                if v1 and u1805.activeId == activeId then
                    u1603.autoOpening = true
                    pcall(u1603.openCommunity, v1)

                    u1603.autoOpening = nil
                end
            end)
        end

        if settings.tut ~= true and not u1603.vrOn then
            u1631.firstTour = true
            task.spawn(function() -- Line: 4890; upvalues: waitLib (val), u1603 (upval)
                waitLib()
                task.wait(1.2)
                u1603.startTutorial()
            end)
        end

        if u1603.tipPrefs then
            u1603.tipPrefs(settings)
        end
    end)
end
