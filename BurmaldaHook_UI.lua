--[[
	Burmalda.hook · копия меню (ТОЛЬКО интерфейс и анимации) · Roblox / Luau
	────────────────────────────────────────────────────────────────────────
	Куда класть : Roblox Studio → StarterPlayer → StarterPlayerScripts → LocalScript, вставить этот код.
	Что внутри  : окно с 7 вкладками, HUD (ватермарк, Hotkeys, Target, нижняя подсказка), тосты справа
	              снизу, выпадающие списки, палитра цвета, перетаскивание окна (двойной клик = сброс).
	Чего НЕТ    : никаких игровых функций. Тумблеры, слайдеры, бинды и кнопки меняют только вид меню.
	Клавиша     : RightShift открывает/закрывает меню (меняется в Settings → Menu key).
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Stats            = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

do -- повторный запуск удаляет старую копию
	local prev = PlayerGui:FindFirstChild("BurmaldaHookUI")
	if prev then prev:Destroy() end
end

-- ═══════════════════════ НАСТРОЙКИ ═══════════════════════
local CFG = {
	Title     = "Burmalda.hook",
	Version   = "v1.0 beta",
	UserName  = "aquabeary-hvh",           -- nil = ник твоего игрока
	License   = "lifetime",
	Scale     = 1.5,                       -- общий размер интерфейса (1.5 ≈ как в видео на Full HD)
	MenuKey   = Enum.KeyCode.RightShift,
	ShowHud   = true,                      -- ватермарк, Hotkeys, Target, подсказка снизу
	Backdrop  = false,                     -- true = тёмный фон как в видео (закрывает игру!)
	StartOpen = true,
}
local USER = CFG.UserName or LocalPlayer.Name
local S = CFG.Scale

-- ═══════════════════════ ТЕМА ═══════════════════════
local C = {
	window  = Color3.fromRGB(17, 16, 25),
	sidebar = Color3.fromRGB(13, 12, 19),
	topbar  = Color3.fromRGB(15, 14, 22),
	card    = Color3.fromRGB(21, 20, 29),
	line    = Color3.fromRGB(30, 30, 42),
	line2   = Color3.fromRGB(44, 46, 62),
	field   = Color3.fromRGB(25, 25, 35),
	fieldHi = Color3.fromRGB(34, 35, 48),
	pop     = Color3.fromRGB(18, 18, 26),
	text    = Color3.fromRGB(204, 210, 224),
	textHi  = Color3.fromRGB(238, 241, 249),
	nav     = Color3.fromRGB(150, 156, 174),
	dim     = Color3.fromRGB(104, 109, 128),
	dimmer  = Color3.fromRGB(70, 73, 90),
	chip    = Color3.fromRGB(160, 165, 182),
	off     = Color3.fromRGB(34, 34, 46),
	knobOff = Color3.fromRGB(92, 94, 110),
	track   = Color3.fromRGB(32, 32, 44),
	scroll  = Color3.fromRGB(44, 46, 60),
	toast   = Color3.fromRGB(13, 13, 19),
	hud     = Color3.fromRGB(11, 12, 18),
	dark    = Color3.fromRGB(10, 24, 48),
	green   = Color3.fromRGB(60, 190, 130),
}
local COL = {
	blue   = Color3.fromRGB(30, 144, 255),
	red    = Color3.fromRGB(232, 112, 108),
	green  = Color3.fromRGB(58, 179, 122),
	violet = Color3.fromRGB(139, 92, 246),
	gray   = Color3.fromRGB(135, 135, 142),
	white  = Color3.fromRGB(255, 255, 255),
	black  = Color3.fromRGB(0, 0, 0),
	lav    = Color3.fromRGB(168, 164, 255),
}
local ACCENTS = {
	Blue   = Color3.fromRGB(30, 144, 255),
	Purple = Color3.fromRGB(139, 92, 246),
	Green  = Color3.fromRGB(46, 204, 130),
	Red    = Color3.fromRGB(240, 84, 90),
	Orange = Color3.fromRGB(255, 150, 50),
}
local accent = ACCENTS.Blue

local FAMILY = "rbxasset://fonts/families/GothamSSm.json"
local F = {
	reg  = Font.new(FAMILY, Enum.FontWeight.Regular),
	med  = Font.new(FAMILY, Enum.FontWeight.Medium),
	bold = Font.new(FAMILY, Enum.FontWeight.Bold),
}

-- ═══════════════════════ УТИЛИТЫ ═══════════════════════
local QUAD, QUINT, LIN = Enum.EasingStyle.Quad, Enum.EasingStyle.Quint, Enum.EasingStyle.Linear
local OUT, IN = Enum.EasingDirection.Out, Enum.EasingDirection.In

local function clamp(v, a, b)
	if v < a then return a elseif v > b then return b end
	return v
end

local function px(n) return n * S end

local function hex(c)
	return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function tween(o, t, props, style, dir)
	local tw = TweenService:Create(o, TweenInfo.new(t, style or QUAD, dir or OUT), props)
	tw:Play()
	return tw
end

local function make(class, props, parent)
	local o = Instance.new(class)
	if props then
		for k, v in pairs(props) do o[k] = v end
	end
	o.Parent = parent
	return o
end

local function frame(parent, x, y, w, h, color, transp)
	return make("Frame", {
		BackgroundColor3 = color or C.card, BackgroundTransparency = transp or 0, BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
	}, parent)
end

local function corner(o, r) return make("UICorner", {CornerRadius = UDim.new(0, r)}, o) end
local function circle(o) return make("UICorner", {CornerRadius = UDim.new(1, 0)}, o) end

local function outline(o, color, th, tr)
	return make("UIStroke", {
		Color = color, Thickness = th or 1, Transparency = tr or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, o)
end

local function padding(o, l, r)
	return make("UIPadding", {PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r or l)}, o)
end

local function text(parent, str, x, y, w, h, font, size, color, align)
	return make("TextLabel", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = str, FontFace = font, TextSize = size,
		TextColor3 = color, TextXAlignment = align or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
	}, parent)
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function inside(g, pos)
	local p, s = g.AbsolutePosition, g.AbsoluteSize
	return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
end

-- смена акцента: каждый элемент подписывается и перекрашивается плавно
local accentSubs = {}
local function onAccent(fn)
	accentSubs[#accentSubs + 1] = fn
	fn(accent, true)
end
local function bindAccent(obj, prop)
	onAccent(function(c, instant)
		if instant then obj[prop] = c else tween(obj, 0.25, {[prop] = c}) end
	end)
end
local function setAccent(c)
	accent = c
	for _, fn in ipairs(accentSubs) do fn(c, false) end
end

-- ═══════════════════════ GUI + ФОН ═══════════════════════
local gui = make("ScreenGui", {
	Name = "BurmaldaHookUI", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 1000,
}, PlayerGui)

if CFG.Backdrop then
	local bd = make("Frame", {
		Name = "Backdrop", BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1), ZIndex = 0,
	}, gui)
	make("UIGradient", {
		Rotation = 55,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 26, 50)),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(19, 20, 36)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(44, 29, 28)),
		}),
	}, bd)
end

local state = {open = false, tab = 0, notifications = true, menuScale = 1, menuKey = CFG.MenuKey, listening = nil}
local conns = {}
local function connect(sig, fn)
	local c = sig:Connect(fn)
	conns[#conns + 1] = c
	return c
end

local hooks = {}
local function emit(id, ...)
	local h = id and hooks[id]
	if h then h(...) end
end

local searchReg = {}
local hud = {}

-- ═══════════════════════ ИКОНКИ (из примитивов) ═══════════════════════
local function makeIcon(kind, parent, x, y)
	local box = make("Frame", {
		Name = "Icon", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(12, 12),
	}, parent)
	local fills, strokes = {}, {}
	local white = Color3.new(1, 1, 1)

	local function ring(cx, cy, d, th)
		local f = make("Frame", {
			BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx, cy), Size = UDim2.fromOffset(d, d),
		}, box)
		circle(f)
		strokes[#strokes + 1] = outline(f, white, th)
	end
	local function dot(cx, cy, d)
		local f = make("Frame", {
			BackgroundColor3 = white, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx, cy), Size = UDim2.fromOffset(d, d),
		}, box)
		circle(f)
		fills[#fills + 1] = f
	end
	local function bar(cx, cy, w, h, rot)
		local f = make("Frame", {
			BackgroundColor3 = white, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx, cy), Size = UDim2.fromOffset(w, h), Rotation = rot or 0,
		}, box)
		fills[#fills + 1] = f
	end
	local function rbox(cx, cy, w, h, r, th)
		local f = make("Frame", {
			BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx, cy), Size = UDim2.fromOffset(w, h),
		}, box)
		corner(f, r)
		strokes[#strokes + 1] = outline(f, white, th)
	end

	if kind == "target" then
		ring(6, 6, 10.5, 1.2); dot(6, 6, 3.6)
	elseif kind == "eye" then
		rbox(6, 6, 12, 7, 3.5, 1.2); dot(6, 6, 3.4)
	elseif kind == "home" then
		bar(3.6, 4.4, 6.4, 1.2, -40); bar(8.4, 4.4, 6.4, 1.2, 40); rbox(6, 8.6, 7.4, 5, 1, 1.2)
	elseif kind == "sun" then
		ring(6, 6, 5, 1.2)
		for i = 0, 7 do
			local a = math.rad(i * 45)
			bar(6 + math.cos(a) * 4.9, 6 + math.sin(a) * 4.9, 1.2, 2, i * 45 + 90)
		end
	elseif kind == "bag" then
		rbox(6, 7.6, 9, 7, 1.6, 1.2); rbox(6, 3.6, 4.4, 4, 2, 1.2)
	elseif kind == "sliders" then
		bar(6, 2.5, 10, 1.2); bar(6, 6, 10, 1.2); bar(6, 9.5, 10, 1.2)
		dot(3.6, 2.5, 3.4); dot(8.4, 6, 3.4); dot(5, 9.5, 3.4)
	elseif kind == "gear" then
		ring(6, 6, 6.6, 1.5)
		for i = 0, 7 do
			local a = math.rad(i * 45)
			bar(6 + math.cos(a) * 4.6, 6 + math.sin(a) * 4.6, 2, 2.2, i * 45 + 90)
		end
	elseif kind == "search" then
		ring(5, 5, 7, 1.2); bar(9.6, 9.6, 4.4, 1.2, 45)
	elseif kind == "plus" then
		bar(6, 6, 8, 1.2, 0); bar(6, 6, 1.2, 8, 0)
	elseif kind == "close" then
		bar(6, 6, 8.4, 1.2, 45); bar(6, 6, 8.4, 1.2, -45)
	elseif kind == "chevron" then
		bar(3.9, 5, 4.6, 1.2, 40); bar(8.1, 5, 4.6, 1.2, -40)
	end

	local icon = {frame = box}
	function icon.setColor(c, animate, t)
		for _, f in ipairs(fills) do
			if animate then tween(f, t or 0.2, {BackgroundColor3 = c}) else f.BackgroundColor3 = c end
		end
		for _, s in ipairs(strokes) do
			if animate then tween(s, t or 0.2, {Color = c}) else s.Color = c end
		end
	end
	icon.setColor(white)
	return icon
end

-- ═══════════════════════ АВАТАР (headshot игрока) ═══════════════════════
local avatarImage, avatarLabels = nil, {}
task.spawn(function()
	local ok, img = pcall(function()
		return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if ok and img then
		avatarImage = img
		for _, l in ipairs(avatarLabels) do l.Image = img end
	end
end)

local function makeAvatar(parent, x, y, d)
	local f = make("ImageLabel", {
		BackgroundColor3 = Color3.fromRGB(58, 40, 40), BorderSizePixel = 0, Image = avatarImage or "",
		Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(d, d),
	}, parent)
	circle(f)
	avatarLabels[#avatarLabels + 1] = f
	return f
end

-- ═══════════════════════ ТОСТЫ (справа снизу) ═══════════════════════
local TOAST_W, TOAST_H, TOAST_GAP = 140, 21, 8
local toastHolder = make("Frame", {
	Name = "Toasts", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -px(38), 1, -px(30)), Size = UDim2.fromOffset(TOAST_W, 200),
}, gui)
make("UIScale", {Scale = S}, toastHolder)
local toasts = {}

local function relayoutToasts()
	for i, t in ipairs(toasts) do
		tween(t.frame, 0.28, {Position = UDim2.new(1, 0, 1, -(i - 1) * (TOAST_H + TOAST_GAP))}, QUINT, OUT)
	end
end

local function removeToast(t)
	if t.dead then return end
	t.dead = true
	for i, v in ipairs(toasts) do
		if v == t then table.remove(toasts, i) break end
	end
	tween(t.frame, 0.22, {GroupTransparency = 1, Position = UDim2.new(1, 28, t.frame.Position.Y.Scale, t.frame.Position.Y.Offset)}, QUAD, IN)
	task.delay(0.26, function() t.frame:Destroy() end)
	relayoutToasts()
end

-- msg — RichText-строка, например: 'Config <font color="#1E90FF">legit</font> loaded'
local function toast(msg, life)
	if not state.notifications then return end
	life = life or 3
	local f = make("CanvasGroup", {
		BackgroundColor3 = C.toast, BorderSizePixel = 0, GroupTransparency = 1,
		AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 36, 1, 0),
		Size = UDim2.fromOffset(TOAST_W, TOAST_H),
	}, toastHolder)
	corner(f, 4)
	frame(f, 0, 4, 2, TOAST_H - 8, accent)
	make("TextLabel", {
		BackgroundTransparency = 1, BorderSizePixel = 0, RichText = true, Text = msg, FontFace = F.med,
		TextSize = 7, TextColor3 = C.textHi, TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(TOAST_W - 14, TOAST_H - 2),
	}, f)
	local prog = frame(f, 2, TOAST_H - 2, TOAST_W - 4, 2, accent)
	local t = {frame = f, dead = false}
	table.insert(toasts, 1, t)
	if #toasts > 5 then removeToast(toasts[#toasts]) end
	tween(f, 0.3, {GroupTransparency = 0}, QUAD, OUT)
	relayoutToasts()
	tween(prog, life, {Size = UDim2.fromOffset(0, 2)}, LIN)
	task.delay(life, function() removeToast(t) end)
end

local function accentWord(word)
	return '<font color="' .. hex(accent) .. '">' .. word .. "</font>"
end

-- ═══════════════════════ DRAG / POPUP ═══════════════════════
local dragFn, dragEnd = nil, nil
local function beginDrag(fn, onEnd)
	dragFn, dragEnd = fn, onEnd
	fn(UserInputService:GetMouseLocation())
end
connect(UserInputService.InputChanged, function(input)
	if dragFn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		dragFn(UserInputService:GetMouseLocation())
	end
end)
connect(UserInputService.InputEnded, function(input)
	if dragFn and isPress(input) then
		local e = dragEnd
		dragFn, dragEnd = nil, nil
		if e then e() end
	end
end)

local openPopup = nil
local function closePopup()
	if openPopup then
		local p = openPopup
		openPopup = nil
		p.close()
	end
end

-- ═══════════════════════ ОКНО ═══════════════════════
local WIN_W, WIN_H, SIDE_W, BAR_H = 602, 408, 136, 44
local MAIN_X, MAIN_W = SIDE_W + 1, WIN_W - SIDE_W - 1

local winRoot = make("Frame", {
	Name = "Window", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(WIN_W, WIN_H), Visible = false,
}, gui)
local winScale = make("UIScale", {Scale = S}, winRoot)

local shadows = {}
for i, e in ipairs({{6, 0.90}, {14, 0.935}, {26, 0.96}, {42, 0.978}}) do
	local f = make("Frame", {
		BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = e[2], BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 6),
		Size = UDim2.new(1, e[1] * 2, 1, e[1] * 2),
	}, winRoot)
	corner(f, 8 + e[1])
	shadows[i] = {frame = f, a = e[2]}
end

local win = make("CanvasGroup", {
	Name = "Body", BackgroundColor3 = C.window, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
}, winRoot)
corner(win, 8)

local edge = make("Frame", {
	Name = "Edge", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 10,
}, winRoot)
corner(edge, 8)
local edgeStroke = outline(edge, C.line2, 1, 0.25)

local sidebar = frame(win, 0, 0, SIDE_W, WIN_H, C.sidebar)
frame(win, SIDE_W, 0, 1, WIN_H, C.line)
local main = make("Frame", {
	Name = "Main", BackgroundTransparency = 1, BorderSizePixel = 0,
	Position = UDim2.fromOffset(MAIN_X, 0), Size = UDim2.fromOffset(MAIN_W, WIN_H),
}, win)
local overlay = make("Frame", {
	Name = "Overlay", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 30,
}, win)

-- тонкая светящаяся линия сверху окна
do
	local glow = frame(win, 0, 0, WIN_W, 1, accent)
	make("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.45), NumberSequenceKeypoint.new(1, 1),
		}),
	}, glow)
	bindAccent(glow, "BackgroundColor3")
end

-- ═══ сайдбар: бренд ═══
makeAvatar(sidebar, 12, 12, 20)
text(sidebar, CFG.Title, 38, 11, 94, 12, F.bold, 7, C.textHi)
text(sidebar, CFG.Version, 38, 24, 94, 9, F.reg, 6, C.dim)
frame(sidebar, 0, BAR_H, SIDE_W, 1, C.line)

-- ═══ сайдбар: профиль внизу ═══
frame(sidebar, 0, 368, SIDE_W, 1, C.line)
makeAvatar(sidebar, 10, 376, 20)
text(sidebar, USER, 36, 376, 76, 11, F.bold, 7, C.textHi)
text(sidebar, "license: " .. CFG.License, 36, 388, 76, 9, F.reg, 6, C.dim)
do
	local d = frame(sidebar, 118, 386, 5, 5, C.green)
	circle(d)
	outline(d, C.green, 2, 0.75)
end

-- ═══ верхняя панель ═══
frame(main, 0, 0, MAIN_W, BAR_H, C.topbar)
frame(main, 0, BAR_H, MAIN_W, 1, C.line)

local titleBox = make("Frame", {
	BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0), Size = UDim2.fromOffset(220, BAR_H),
}, main)
make("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8),
}, titleBox)
local titleLbl = make("TextLabel", {
	BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 16),
	Text = "", FontFace = F.bold, TextSize = 11, TextColor3 = C.textHi, LayoutOrder = 1,
}, titleBox)
local subLbl = make("TextLabel", {
	BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18),
	Text = "", FontFace = F.reg, TextSize = 6, TextColor3 = C.dim, LayoutOrder = 2,
}, titleBox)

-- поиск
local searchBox
do
	local sb = frame(main, 244, 11, 145, 22, C.field)
	corner(sb, 5)
	local sst = outline(sb, C.line, 1, 0)
	local sic = makeIcon("search", sb, 8, 5)
	sic.setColor(C.dim)
	searchBox = make("TextBox", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", PlaceholderText = "Search features...",
		PlaceholderColor3 = C.dimmer, TextColor3 = C.textHi, FontFace = F.med, TextSize = 7,
		ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(25, 0), Size = UDim2.fromOffset(116, 22),
	}, sb)
	searchBox.Focused:Connect(function()
		tween(sst, 0.15, {Color = accent}); sic.setColor(accent, true, 0.15)
	end)
	searchBox.FocusLost:Connect(function()
		tween(sst, 0.2, {Color = C.line}); sic.setColor(C.dim, true, 0.2)
	end)
end

-- ═══════════════════════ КОМПОНЕНТЫ ═══════════════════════
local ROW_H = 26
local buildingPage = 0

local function baseRow(card, y, w, h)
	local row = make("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(4, y), Size = UDim2.fromOffset(w - 8, h),
	}, card)
	corner(row, 4)
	row.MouseEnter:Connect(function() tween(row, 0.12, {BackgroundTransparency = 0.975}) end)
	row.MouseLeave:Connect(function() tween(row, 0.18, {BackgroundTransparency = 1}) end)
	return row
end

local function regSearch(lbl, str)
	searchReg[#searchReg + 1] = {label = lbl, text = string.lower(str), page = buildingPage}
end

local function rowLabel(row, str, sub)
	local l = text(row, str, 8, sub and 2 or 0, 130, sub and 12 or ROW_H, F.med, 8, C.text)
	regSearch(l, str)
	if sub then text(row, sub, 8, 14, 150, 9, F.reg, 6, C.dimmer) end
	return l
end

-- ─── переключатель ───
local function makeToggle(parent, x, y, init, onChange)
	local TW, TH = 27, 14
	local track = make("TextButton", {
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = C.off,
		Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(TW, TH),
	}, parent)
	circle(track)
	local halo = outline(track, accent, 2.5, 1)
	local knob = make("Frame", {
		BackgroundColor3 = C.knobOff, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(10, 10),
	}, track)
	circle(knob)
	local obj = {value = init}
	local function apply(v, animate)
		local pt = {BackgroundColor3 = v and accent or C.off}
		local pk = {Position = UDim2.new(0, v and (TW - 12) or 2, 0.5, 0), BackgroundColor3 = v and Color3.new(1, 1, 1) or C.knobOff}
		local ph = {Transparency = v and 0.72 or 1}
		if animate then
			tween(track, 0.18, pt); tween(knob, 0.2, pk, QUINT); tween(halo, 0.18, ph)
		else
			for k, val in pairs(pt) do track[k] = val end
			for k, val in pairs(pk) do knob[k] = val end
			for k, val in pairs(ph) do halo[k] = val end
		end
	end
	function obj.set(v, animate)
		obj.value = v
		apply(v, animate)
	end
	apply(init, false)
	onAccent(function(c, instant)
		halo.Color = c
		if obj.value then
			if instant then track.BackgroundColor3 = c else tween(track, 0.25, {BackgroundColor3 = c}) end
		end
	end)
	track.MouseButton1Click:Connect(function()
		obj.set(not obj.value, true)
		if onChange then onChange(obj.value) end
	end)
	return obj
end

-- ─── слайдер ───
local function makeSlider(parent, x, cy, width, d, onChange)
	local PADK = 4
	local track = make("Frame", {
		BackgroundColor3 = C.track, BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, cy - 1.5), Size = UDim2.fromOffset(width, 3),
	}, parent)
	circle(track)
	local fill = make("Frame", {BackgroundColor3 = accent, BorderSizePixel = 0, Size = UDim2.fromOffset(PADK, 3)}, track)
	circle(fill)
	bindAccent(fill, "BackgroundColor3")
	local knob = make("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(PADK, 1.5), Size = UDim2.fromOffset(8, 8),
	}, track)
	circle(knob)
	local halo = outline(knob, accent, 2.5, 1)
	bindAccent(halo, "Color")
	local hit = make("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(x - 4, cy - 9), Size = UDim2.fromOffset(width + 8, 18),
	}, parent)

	local obj = {value = d.v}
	local function place(f)
		local p = PADK + f * (width - PADK * 2)
		fill.Size = UDim2.fromOffset(p, 3)
		knob.Position = UDim2.fromOffset(p, 1.5)
	end
	function obj.set(v)
		v = clamp(v, d.min, d.max)
		obj.value = v
		place((v - d.min) / (d.max - d.min))
	end
	local function fromMouse(pos)
		local sc = track.AbsoluteSize.X / width
		local f = clamp((pos.X - track.AbsolutePosition.X - PADK * sc) / ((width - PADK * 2) * sc), 0, 1)
		local v = d.min + (d.max - d.min) * f
		v = d.min + math.floor((v - d.min) / d.step + 0.5) * d.step
		v = clamp(v, d.min, d.max)
		if v ~= obj.value then
			obj.set(v)
			if onChange then onChange(v) end
		end
	end
	hit.InputBegan:Connect(function(input)
		if isPress(input) then
			tween(knob, 0.12, {Size = UDim2.fromOffset(10, 10)})
			tween(halo, 0.12, {Transparency = 0.6})
			beginDrag(fromMouse, function()
				tween(knob, 0.15, {Size = UDim2.fromOffset(8, 8)})
				tween(halo, 0.15, {Transparency = 1})
			end)
		end
	end)
	hit.MouseEnter:Connect(function() tween(halo, 0.12, {Transparency = 0.75}) end)
	hit.MouseLeave:Connect(function()
		if dragFn == nil then tween(halo, 0.15, {Transparency = 1}) end
	end)
	obj.set(d.v)
	return obj
end

-- ─── кнопки ───
local function makeButton(parent, label, style)
	local solid = style == "solid"
	local b = make("TextButton", {
		Text = label, AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0,
		BackgroundColor3 = solid and accent or C.field, FontFace = F.bold, TextSize = 6,
		TextColor3 = solid and C.dark or C.textHi, Size = UDim2.fromOffset(0, 18),
	}, parent)
	corner(b, 4)
	padding(b, 9)
	local st = outline(b, solid and accent or C.line, 1, solid and 1 or 0)
	local function base() return solid and accent or C.field end
	local function hover() return solid and accent:Lerp(Color3.new(1, 1, 1), 0.18) or C.fieldHi end
	if solid then
		onAccent(function(c, instant)
			if instant then b.BackgroundColor3 = c else tween(b, 0.25, {BackgroundColor3 = c}) end
		end)
	end
	b.MouseEnter:Connect(function()
		tween(b, 0.12, {BackgroundColor3 = hover()})
		if not solid then tween(st, 0.12, {Color = C.line2}) end
	end)
	b.MouseLeave:Connect(function()
		tween(b, 0.15, {BackgroundColor3 = base()})
		if not solid then tween(st, 0.15, {Color = C.line}) end
	end)
	b.MouseButton1Down:Connect(function() tween(b, 0.08, {BackgroundColor3 = base()}) end)
	return b
end

-- ─── выпадающий список ───
local function openDropdown(btn, st, chev, opts, current, onPick)
	closePopup()
	local sc = winScale.Scale
	local ap, as, base = btn.AbsolutePosition, btn.AbsoluteSize, overlay.AbsolutePosition
	local x = (ap.X - base.X) / sc
	local y = (ap.Y - base.Y + as.Y) / sc + 3
	local bw = as.X / sc
	local ih = 18
	local hh = #opts * ih + 8
	if y + hh > WIN_H - 4 then y = (ap.Y - base.Y) / sc - hh - 3 end

	local list = make("CanvasGroup", {
		BackgroundColor3 = C.pop, BorderSizePixel = 0, GroupTransparency = 1, Active = true,
		Position = UDim2.fromOffset(x, y + 5), Size = UDim2.fromOffset(bw, hh),
	}, overlay)
	corner(list, 5)
	outline(list, C.line2, 1, 0)
	for i, o in ipairs(opts) do
		local it = make("TextButton", {
			Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
			BorderSizePixel = 0, Position = UDim2.fromOffset(4, 4 + (i - 1) * ih), Size = UDim2.fromOffset(bw - 8, ih),
		}, list)
		corner(it, 4)
		local lb = text(it, o, 7, 0, bw - 20, ih, F.med, 8, o == current and accent or C.text)
		it.MouseEnter:Connect(function() tween(it, 0.1, {BackgroundTransparency = 0.94}) end)
		it.MouseLeave:Connect(function() tween(it, 0.12, {BackgroundTransparency = 1}) end)
		it.MouseButton1Click:Connect(function()
			lb.TextColor3 = accent
			onPick(o)
			closePopup()
		end)
	end
	tween(list, 0.18, {GroupTransparency = 0, Position = UDim2.fromOffset(x, y)}, QUINT, OUT)
	tween(st, 0.15, {Color = accent})
	tween(chev.frame, 0.22, {Rotation = 180}, QUINT, OUT)
	chev.setColor(accent, true, 0.15)
	openPopup = {
		frame = list, owner = btn,
		close = function()
			tween(list, 0.12, {GroupTransparency = 1})
			tween(st, 0.15, {Color = C.line})
			tween(chev.frame, 0.18, {Rotation = 0}, QUAD, OUT)
			chev.setColor(C.dim, true, 0.15)
			task.delay(0.14, function() list:Destroy() end)
		end,
	}
end

-- ─── палитра цвета ───
local function openPicker(swatch, current, onChange)
	closePopup()
	local sc = winScale.Scale
	local ap, as, base = swatch.AbsolutePosition, swatch.AbsoluteSize, overlay.AbsolutePosition
	local PW, PH = 132, 112
	local x = (ap.X - base.X) / sc + as.X / sc - PW
	local y = (ap.Y - base.Y) / sc + as.Y / sc + 4
	if y + PH > WIN_H - 4 then y = (ap.Y - base.Y) / sc - PH - 4 end
	x = clamp(x, 4, WIN_W - PW - 4)

	local pop = make("CanvasGroup", {
		BackgroundColor3 = C.pop, BorderSizePixel = 0, GroupTransparency = 1, Active = true,
		Position = UDim2.fromOffset(x, y + 5), Size = UDim2.fromOffset(PW, PH),
	}, overlay)
	corner(pop, 6)
	outline(pop, C.line2, 1, 0)

	local h, s, v = current:ToHSV()
	local sv = make("Frame", {
		BackgroundColor3 = Color3.fromHSV(h, 1, 1), BorderSizePixel = 0, Active = true,
		Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(PW - 16, 62),
	}, pop)
	corner(sv, 4)
	local wh = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1)}, sv)
	corner(wh, 4)
	make("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})}, wh)
	local bk = make("Frame", {BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1)}, sv)
	corner(bk, 4)
	make("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})}, bk)
	local svKnob = make("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(8, 8),
	}, sv)
	circle(svKnob)
	outline(svKnob, Color3.new(1, 1, 1), 1.5, 0)

	local hue = make("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Active = true,
		Position = UDim2.fromOffset(8, 78), Size = UDim2.fromOffset(PW - 16, 8),
	}, pop)
	circle(hue)
	make("UIGradient", {Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	})}, hue)
	local hueKnob = make("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(5, 11),
	}, hue)
	corner(hueKnob, 2)

	local hexLbl = text(pop, "", 8, 92, 80, 14, F.bold, 7, C.dim)
	local prev = frame(pop, PW - 8 - 14, 93, 14, 12, current)
	corner(prev, 3)

	local function apply(fire)
		local c = Color3.fromHSV(h, s, v)
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svKnob.Position = UDim2.new(s, 0, 1 - v, 0)
		hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
		hexLbl.Text = hex(c)
		prev.BackgroundColor3 = c
		if fire then onChange(c) end
	end
	apply(false)

	sv.InputBegan:Connect(function(input)
		if isPress(input) then
			beginDrag(function(pos)
				local p2, s2 = sv.AbsolutePosition, sv.AbsoluteSize
				s = clamp((pos.X - p2.X) / s2.X, 0, 1)
				v = 1 - clamp((pos.Y - p2.Y) / s2.Y, 0, 1)
				apply(true)
			end)
		end
	end)
	hue.InputBegan:Connect(function(input)
		if isPress(input) then
			beginDrag(function(pos)
				local p2, s2 = hue.AbsolutePosition, hue.AbsoluteSize
				h = clamp((pos.X - p2.X) / s2.X, 0, 1)
				apply(true)
			end)
		end
	end)

	tween(pop, 0.18, {GroupTransparency = 0, Position = UDim2.fromOffset(x, y)}, QUINT, OUT)
	openPopup = {
		frame = pop, owner = swatch,
		close = function()
			tween(pop, 0.12, {GroupTransparency = 1})
			task.delay(0.14, function() pop:Destroy() end)
		end,
	}
end

-- ─── бинды клавиш ───
local KEYNAMES = {
	LeftShift = "LSHIFT", RightShift = "RSHIFT", LeftControl = "LCTRL", RightControl = "RCTRL",
	LeftAlt = "LALT", RightAlt = "RALT", Return = "ENTER", Space = "SPACE", Backquote = "~",
	CapsLock = "CAPS", Insert = "INS", Delete = "DEL", PageUp = "PGUP", PageDown = "PGDN",
}
local function keyName(kc) return KEYNAMES[kc.Name] or string.upper(kc.Name) end

local function stopListening()
	local L = state.listening
	if L then
		state.listening = nil
		L.chip.Text = L.prev
		L.chip.TextColor3 = C.chip
	end
end

local function finishListening(name, input)
	local L = state.listening
	if not L then return end
	state.listening = nil
	L.chip.TextColor3 = C.chip
	if L.id == "menu_key" and (name == "NONE" or not input or input.UserInputType ~= Enum.UserInputType.Keyboard) then
		L.chip.Text = L.prev -- у меню должна оставаться клавиша
		return
	end
	L.chip.Text = name
	emit(L.id, name, input)
end

-- ═══════════════════════ ТИПЫ СТРОК ═══════════════════════
local ROWS = {}
local PREVIEW = {}

ROWS.toggle = function(card, d, y, w)
	local row = baseRow(card, y, w, ROW_H)
	rowLabel(row, d.text, d.sub)
	makeToggle(row, (w - 8) - 7 - 27, 6, d.v, function(v) emit(d.id, v) end)
	return ROW_H
end

ROWS.slider = function(card, d, y, w)
	local hasSub = d.sub ~= nil
	local h = hasSub and 50 or 40
	local row = baseRow(card, y, w, h)
	local lbl = text(row, d.text, 8, 0, 130, 12, F.med, 8, C.text)
	regSearch(lbl, d.text)
	if hasSub then text(row, d.sub, 8, 12, 150, 9, F.reg, 6, C.dimmer) end
	local function fmt(v) return string.format("%." .. d.dec .. "f", v) .. d.suffix end
	local val = text(row, fmt(d.v), 8, hasSub and 4 or 0, w - 23, 12, F.bold, 7, accent, Enum.TextXAlignment.Right)
	bindAccent(val, "TextColor3")
	makeSlider(row, 8, hasSub and 36.5 or 26.5, w - 23, d, function(v)
		val.Text = fmt(v)
		emit(d.id, v)
	end)
	return h
end

ROWS.seg = function(card, d, y, w)
	local row = baseRow(card, y, w, ROW_H)
	rowLabel(row, d.text)
	local widths, offs, total = {}, {}, 0
	for i, o in ipairs(d.opts) do
		widths[i] = math.max(34, #o * 5 + 16)
		total = total + widths[i]
	end
	local x0 = (w - 8) - 7 - total
	local x = x0
	for i = 1, #d.opts do
		offs[i] = x
		x = x + widths[i]
	end
	local ind = make("Frame", {
		BackgroundColor3 = accent, BorderSizePixel = 0,
		Position = UDim2.fromOffset(offs[d.v], 5), Size = UDim2.fromOffset(widths[d.v], 16),
	}, row)
	corner(ind, 4)
	local glow = outline(ind, accent, 2.5, 0.72)
	bindAccent(ind, "BackgroundColor3")
	bindAccent(glow, "Color")
	local btns = {}
	local function choose(i, animate)
		d.v = i
		if animate then
			tween(ind, 0.22, {Position = UDim2.fromOffset(offs[i], 5), Size = UDim2.fromOffset(widths[i], 16)}, QUINT)
		else
			ind.Position = UDim2.fromOffset(offs[i], 5)
			ind.Size = UDim2.fromOffset(widths[i], 16)
		end
		for k, b in ipairs(btns) do
			local c = (k == i) and C.dark or C.dim
			if animate then tween(b, 0.18, {TextColor3 = c}) else b.TextColor3 = c end
		end
	end
	for i, o in ipairs(d.opts) do
		local b = make("TextButton", {
			Text = o, AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
			FontFace = F.bold, TextSize = 7, TextColor3 = C.dim,
			Position = UDim2.fromOffset(offs[i], 5), Size = UDim2.fromOffset(widths[i], 16), ZIndex = 2,
		}, row)
		btns[i] = b
		b.MouseButton1Click:Connect(function()
			if d.v ~= i then
				choose(i, true)
				emit(d.id, o)
			end
		end)
	end
	choose(d.v, false)
	return ROW_H
end

ROWS.drop = function(card, d, y, w)
	local row = baseRow(card, y, w, ROW_H)
	rowLabel(row, d.text)
	local bw, bh = 92, 20
	local btn = make("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundColor3 = C.field, BorderSizePixel = 0,
		Position = UDim2.fromOffset((w - 8) - 7 - bw, 3), Size = UDim2.fromOffset(bw, bh),
	}, row)
	corner(btn, 4)
	local st = outline(btn, C.line, 1, 0)
	local val = text(btn, d.v, 8, 0, bw - 26, bh, F.med, 8, C.textHi)
	local chev = makeIcon("chevron", btn, bw - 17, 4)
	chev.setColor(C.dim)
	local cur = d.v
	btn.MouseEnter:Connect(function()
		if not (openPopup and openPopup.owner == btn) then tween(st, 0.12, {Color = C.line2}) end
	end)
	btn.MouseLeave:Connect(function()
		if not (openPopup and openPopup.owner == btn) then tween(st, 0.15, {Color = C.line}) end
	end)
	btn.MouseButton1Click:Connect(function()
		if openPopup and openPopup.owner == btn then closePopup() return end
		openDropdown(btn, st, chev, d.opts, cur, function(opt)
			cur = opt
			val.Text = opt
			emit(d.id, opt)
		end)
	end)
	return ROW_H
end

ROWS.key = function(card, d, y, w)
	local row = baseRow(card, y, w, ROW_H)
	rowLabel(row, d.text)
	local chip = make("TextButton", {
		Text = d.v, AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0,
		BackgroundColor3 = C.field, FontFace = F.bold, TextSize = 6, TextColor3 = C.chip,
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromOffset((w - 8) - 7, 4), Size = UDim2.fromOffset(0, 18),
	}, row)
	corner(chip, 4)
	padding(chip, 8)
	chip.MouseEnter:Connect(function() tween(chip, 0.12, {BackgroundColor3 = C.fieldHi}) end)
	chip.MouseLeave:Connect(function() tween(chip, 0.15, {BackgroundColor3 = C.field}) end)
	chip.MouseButton1Click:Connect(function()
		stopListening()
		state.listening = {chip = chip, prev = chip.Text, id = d.id}
		chip.Text = "..."
		chip.TextColor3 = accent
	end)
	return ROW_H
end

ROWS.color = function(card, d, y, w)
	local row = baseRow(card, y, w, ROW_H)
	rowLabel(row, d.text)
	local sw = make("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundColor3 = d.v, BorderSizePixel = 0,
		Position = UDim2.fromOffset((w - 8) - 7 - 15, 5.5), Size = UDim2.fromOffset(15, 15),
	}, row)
	corner(sw, 4)
	local st = outline(sw, Color3.new(1, 1, 1), 1, 0.88)
	sw.MouseEnter:Connect(function() tween(st, 0.12, {Transparency = 0.5}) end)
	sw.MouseLeave:Connect(function() tween(st, 0.15, {Transparency = 0.88}) end)
	sw.MouseButton1Click:Connect(function()
		if openPopup and openPopup.owner == sw then closePopup() return end
		openPicker(sw, sw.BackgroundColor3, function(c)
			sw.BackgroundColor3 = c
			emit(d.id, c)
		end)
	end)
	return ROW_H
end

ROWS.button = function(card, d, y, w)
	local row = baseRow(card, y, w, ROW_H)
	rowLabel(row, d.text)
	local b = makeButton(row, d.label, "ghost")
	b.AnchorPoint = Vector2.new(1, 0)
	b.Position = UDim2.fromOffset((w - 8) - 7, 4)
	b.MouseButton1Click:Connect(function() emit(d.id) end)
	return ROW_H
end

ROWS.tag = function(card, d, y, w)
	local row = baseRow(card, y, w, ROW_H)
	rowLabel(row, d.text)
	local tg = make("TextLabel", {
		Text = d.tag, AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0, BackgroundColor3 = accent,
		BackgroundTransparency = 0.86, FontFace = F.bold, TextSize = 6, TextColor3 = accent,
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromOffset((w - 8) - 7, 6), Size = UDim2.fromOffset(0, 14),
	}, row)
	corner(tg, 3)
	padding(tg, 6)
	bindAccent(tg, "BackgroundColor3")
	bindAccent(tg, "TextColor3")
	return ROW_H
end

ROWS.preview = function(card, d, y, w)
	local box = make("Frame", {
		BackgroundColor3 = Color3.fromRGB(14, 14, 21), BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, y + 2), Size = UDim2.fromOffset(w - 24, 84),
	}, card)
	corner(box, 5)
	outline(box, C.line, 1, 0)
	local ring = make("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, -3, 0.5, 0), Size = UDim2.fromOffset(39, 39),
	}, box)
	circle(ring)
	local rs = outline(ring, accent, 1.2, 0.05)
	make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(7, 1)}, ring)
	make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(1, 7)}, ring)
	local pb = make("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0.5, 30, 0.5, -19), Size = UDim2.fromOffset(21, 38),
	}, box)
	outline(pb, Color3.new(1, 1, 1), 1, 0.1)
	frame(box, 0, 0, 0, 0, C.card, 1)
	local hb = frame(box, 0, 0, 2, 32, C.green)
	hb.Position = UDim2.new(0.5, 26, 0.5, -16)
	text(box, "Player", 0, 0, 30, 8, F.reg, 5, C.textHi).Position = UDim2.new(0.5, 29, 0.5, -28)
	PREVIEW.ring, PREVIEW.stroke = ring, rs
	return 92
end

-- ═══════════════════════ КАРТОЧКИ И СТРАНИЦЫ ═══════════════════════
local PAD_TOP, COL_W, COL_X1, COL_X2, GAP = 14, 209, 16, 237, 12

local function buildCard(parent, x, y, w, sec)
	local card = make("Frame", {
		BackgroundColor3 = C.card, BorderSizePixel = 0, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, 60),
	}, parent)
	corner(card, 6)
	outline(card, C.line, 1, 0.3)
	local dot = frame(card, 12, 12, 5, 5, accent)
	corner(dot, 1.5)
	bindAccent(dot, "BackgroundColor3")
	local dg = outline(dot, accent, 2, 0.75)
	bindAccent(dg, "Color")
	text(card, sec.title, 22, 7, w - 40, 15, F.bold, 8, C.textHi)
	frame(card, 12, 28, w - 24, 1, C.line, 0.4)
	local cy = 31
	for _, d in ipairs(sec.rows) do
		cy = cy + ROWS[d.t](card, d, cy, w)
	end
	cy = cy + 6
	card.Size = UDim2.fromOffset(w, cy)
	return cy, card
end

local pagesFrame = make("Frame", {
	Name = "Pages", BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
	Position = UDim2.fromOffset(0, BAR_H + 1), Size = UDim2.fromOffset(MAIN_W, WIN_H - BAR_H - 1),
}, main)

local pages = {}
local function newPage(index)
	buildingPage = index
	local holder = make("CanvasGroup", {
		Name = "Page" .. index, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		Visible = false, GroupTransparency = 1,
	}, pagesFrame)
	local sc = make("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.fromOffset(0, 600), ScrollBarThickness = 3, ScrollBarImageColor3 = C.scroll,
		ScrollingDirection = Enum.ScrollingDirection.Y, ElasticBehavior = Enum.ElasticBehavior.Never,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
	}, holder)
	sc:GetPropertyChangedSignal("CanvasPosition"):Connect(closePopup)
	local pg = {holder = holder, scroll = sc}
	pages[index] = pg
	return pg
end

local function buildColumns(sc, def)
	local yL, yR = PAD_TOP, PAD_TOP
	for _, sec in ipairs(def.left) do
		yL = yL + buildCard(sc, COL_X1, yL, COL_W, sec) + GAP
	end
	for _, sec in ipairs(def.right) do
		yR = yR + buildCard(sc, COL_X2, yR, COL_W, sec) + GAP
	end
	sc.CanvasSize = UDim2.fromOffset(0, math.max(yL, yR) + 2)
end

-- ═══════════════════════ ДАННЫЕ ВКЛАДОК ═══════════════════════
local function T(text_, v, sub, id) return {t = "toggle", text = text_, v = v, sub = sub, id = id} end
local function SL(text_, v, mn, mx, step, suffix, dec, sub, id)
	return {t = "slider", text = text_, v = v, min = mn, max = mx, step = step, suffix = suffix or "", dec = dec or 0, sub = sub, id = id}
end
local function SG(text_, opts, v, id) return {t = "seg", text = text_, opts = opts, v = v, id = id} end
local function DD(text_, opts, v, id) return {t = "drop", text = text_, opts = opts, v = v, id = id} end
local function KB(text_, v, id) return {t = "key", text = text_, v = v, id = id} end
local function CP(text_, c, id) return {t = "color", text = text_, v = c, id = id} end
local function BT(text_, label, id) return {t = "button", text = text_, label = label, id = id} end
local function TG(text_, tag) return {t = "tag", text = text_, tag = tag} end

local PAGES = {
	{name = "Combat", sub = "aimbot, fov, crosshair", icon = "target",
		left = {
			{title = "AIMBOT", rows = {
				T("Enabled", true),
				SG("Mode", {"Smooth", "Snap"}, 1),
				SL("Smoothness", 6, 1, 20, 1, "", 0, "lower = faster"),
				KB("Aim key", "MB2"),
				T("Always target", false, "works without a key"),
				T("Visibility check", true),
				DD("Hit part", {"Head", "Chest", "Stomach", "Closest"}, "Head"),
				T("Target players", true),
				T("Target AI", false),
				T("Target bosses", false),
			}},
			{title = "ARMOR VIEWER", rows = {
				T("Enabled", true, "shows target armor + weapon", "armor_on"),
				DD("Position", {"Top right", "Top left", "Bottom right", "Bottom left"}, "Top right"),
				SL("Scale", 100, 50, 150, 5, "%", 0, nil, "armor_scale"),
			}},
		},
		right = {
			{title = "FOV", rows = {
				T("Visualize FOV", true),
				T("Dynamic radius", true),
				SL("Radius", 110, 20, 300, 1, "px", 0, nil, "fov_radius"),
				CP("Color", COL.blue, "fov_color"),
				CP("Target color", COL.red),
				{t = "preview"},
			}},
			{title = "CROSSHAIR", rows = {
				T("Crosshair", true),
				SL("Size", 8, 1, 30, 1, "px"),
				SL("Gap", 9, 0, 20, 1, "px"),
				SL("Width", 1.5, 0.5, 10, 0.5, "px", 1),
				CP("Color", COL.white),
				CP("Outline", COL.black),
			}},
		},
	},
	{name = "Players ESP", sub = "players, ai, bosses", icon = "eye",
		left = {
			{title = "MAIN", rows = {
				T("Enabled", true),
				T("Bounding box", true),
				DD("Box type", {"Corner", "Full", "3D"}, "Corner"),
				T("Skeleton", false),
				T("Name", true),
				T("Distance", true),
				T("Health bar", true),
				T("Only if damaged", false),
				T("Weapon image", true),
				SL("Max distance", 600, 50, 2000, 10, "m"),
			}},
			{title = "TRACERS / OFFSCREEN", rows = {
				T("Tracers", false),
				T("Teammate tracers", false),
				T("Offscreen arrows", true),
				SL("Arrow size", 12, 4, 30, 1, "px"),
				SL("Arrow radius", 220, 50, 500, 10, "px"),
			}},
			{title = "SMART ESP", rows = {
				T("Fade near crosshair", true),
				SL("Fade radius", 90, 20, 300, 1, "px"),
				KB("Combat hide key", "NONE"),
				T("Lock-on indicator", true),
				SL("Danger threshold", 15, 5, 90, 1, "°"),
			}},
		},
		right = {
			{title = "CHAMS", rows = {
				T("Enabled", true),
				DD("Style", {"Glow", "Flat", "Outline"}, "Glow"),
				CP("Visible", COL.blue),
				CP("Occluded", COL.violet),
				SL("Refresh rate", 20, 1, 60, 1, "hz"),
			}},
			{title = "COLORS", rows = {
				CP("Visible", COL.white),
				CP("Occluded", COL.gray),
				CP("Teammate", COL.green),
				CP("Low health", COL.red),
				CP("High health", COL.green),
			}},
			{title = "FLAGS", rows = {
				T("VIP / Staff", true),
				T("Clan", true),
				T("Aiming", true),
				T("Healing", true),
				T("Reloading", true),
				T("Safezone", false),
			}},
		},
	},
	{name = "World ESP", sub = "resources, raids, bases", icon = "home",
		left = {
			{title = "RESOURCES", rows = {
				T("Nodes", true),
				T("Stone", true),
				T("Metal", true),
				T("Sulfur", true),
				T("Phosphate", false),
				SL("Max distance", 300, 50, 1000, 10, "m"),
			}},
			{title = "PLAYERS ITEMS", rows = {
				T("Body bags", true),
				T("Sleepers", true),
				T("Tools", false),
				T("Looting", true),
			}},
		},
		right = {
			{title = "EVENTS", rows = {
				T("Care packages", true),
				T("Timed crates", true),
				T("Raids", true),
				CP("Raid color", COL.red),
			}},
			{title = "STRUCTURES", rows = {
				T("Bases", true),
				T("Benches", false),
				T("Locks", false),
				T("Building", false),
			}},
		},
	},
	{name = "Visuals", sub = "camera, world, viewmodel", icon = "sun",
		left = {
			{title = "CAMERA", rows = {
				T("Zoom", true),
				SL("Zoom level", 3, 1, 8, 0.5, "x", 1),
				KB("Zoom key", "C"),
				T("Custom FOV", true),
				SL("Field of view", 95, 30, 120, 1, "°"),
				T("Remove bobbing", true),
				T("Camera effects", false),
			}},
			{title = "SKY", rows = {
				T("Skybox", true),
				DD("Preset", {"Space", "Sunset", "Night", "Clear"}, "Space"),
				SL("Star count", 3000, 0, 5000, 100, ""),
				T("Change time", true),
				SL("Time", 21, 0, 24, 1, "h"),
			}},
			{title = "VIEWMODEL", rows = {
				T("Remove sleeves", true),
				T("Highlight arms", true),
				CP("Fill", COL.blue),
				CP("Outline", COL.white),
				SL("Rotation", 0, -180, 180, 1, "°"),
				T("Random rotation", false),
			}},
		},
		right = {
			{title = "WORLD", rows = {
				T("Fullbright", false),
				SL("Brightness", 2, 0, 10, 1, ""),
				CP("Ambient", COL.lav),
				T("XRay", false),
				SL("XRay transparency", 60, 0, 100, 1, "%"),
				KB("XRay key", "X"),
				T("Remove grass", true),
				T("Remove fog", true),
				T("Bloom", false),
			}},
			{title = "HITMARKERS", rows = {
				T("Enabled", true),
				DD("Hit sound", {"Rust", "Bell", "Pop", "Click"}, "Rust"),
				DD("Headshot sound", {"Bell", "Rust", "Pop", "Ding"}, "Bell"),
				SL("Volume", 60, 0, 100, 1, "%"),
			}},
			{title = "TRACERS", rows = {
				T("Bullet tracers", true),
				SL("Lifetime", 0.8, 0.1, 3, 0.1, "s", 1),
				SL("Speed", 4, 1, 10, 1, ""),
				CP("Color", COL.blue),
			}},
		},
	},
	{name = "Skins", sub = "skin changer", icon = "bag",
		left = {
			{title = "SKIN CHANGER", rows = {
				T("Enabled", true),
				T("Sandbox armor models", false),
				T("Show weapon image", true),
			}},
			{title = "ARMOR", rows = {
				DD("Chestplate", {"Default", "Gold", "Dark", "Carbon"}, "Gold"),
				DD("Helmet", {"Default", "Dark", "Gold", "Carbon"}, "Dark"),
				DD("Hazmat", {"Default", "Dark", "Gold"}, "Default"),
			}},
		},
		right = {
			{title = "WEAPONS", rows = {
				DD("AK-47", {"Default", "Glory", "Tempered", "Frostbite", "Neon"}, "Frostbite"),
				DD("LR-300", {"Default", "Carbon", "Blackout", "Dragon"}, "Carbon"),
				DD("MP5", {"Default", "Tempered", "Gold", "Neon"}, "Tempered"),
				DD("Python", {"Default", "Gold", "Carbon", "Neon"}, "Gold"),
				DD("Bolt rifle", {"Default", "Arctic", "Dragon"}, "Dragon"),
			}},
		},
	},
	{name = "Misc", sub = "sound, movement helpers", icon = "sliders",
		left = {
			{title = "SOUND", rows = {
				SL("Master volume", 80, 0, 100, 1, "%"),
				SL("Hit volume", 60, 0, 100, 1, "%"),
				SL("Headshot volume", 70, 0, 100, 1, "%"),
				T("Silent step", true),
			}},
		},
		right = {
			{title = "HOTKEYS PANEL", rows = {
				T("Enabled", true, nil, "hk_on"),
				DD("Position", {"Left", "Right"}, "Left", "hk_pos"),
				T("Show inactive", false),
			}},
			{title = "MODERATOR PANEL", rows = {
				T("Enabled", true, "warns when staff joins"),
				T("Sound alert", true),
				BT("Test alert", "TEST", "test_alert"),
			}},
		},
	},
	{name = "Settings", sub = "configs, hud, keybinds", icon = "gear", custom = true,
		left = {
			{title = "INTERFACE", rows = {
				KB("Menu key", keyName(CFG.MenuKey), "menu_key"),
				T("Watermark", true, nil, "wm"),
				T("Notifications", true, nil, "notif"),
				DD("Accent", {"Blue", "Purple", "Green", "Red", "Orange"}, "Blue", "accent"),
				SL("Menu scale", 100, 70, 120, 5, "%", 0, nil, "menu_scale"),
			}},
		},
		right = {
			{title = "INFO", rows = {
				TG("Build", "1.0 beta"),
				TG("Game", USER),
				TG("License", CFG.License),
				BT("Discord", "COPY INVITE", "copy_invite"),
				BT("Unload", "UNLOAD", "unload"),
			}},
		},
	},
}

-- ─── страница Settings: Configs + Interface + Info ───
local function buildSettings(def, index)
	local pg = newPage(index)
	local sc = pg.scroll
	local fullW = COL_W * 2 + GAP
	local rowsTop = 60

	local card = make("Frame", {
		BackgroundColor3 = C.card, BorderSizePixel = 0, Position = UDim2.fromOffset(COL_X1, PAD_TOP), Size = UDim2.fromOffset(fullW, 100),
	}, sc)
	corner(card, 6)
	outline(card, C.line, 1, 0.3)
	local dot = frame(card, 12, 12, 5, 5, accent)
	corner(dot, 1.5)
	bindAccent(dot, "BackgroundColor3")
	local dg = outline(dot, accent, 2, 0.75)
	bindAccent(dg, "Color")
	text(card, "CONFIGS", 22, 7, 120, 15, F.bold, 8, C.textHi)
	frame(card, 12, 28, fullW - 24, 1, C.line, 0.4)

	-- поле + SAVE
	local inp = frame(card, 12, 33, 100, 20, C.field)
	corner(inp, 4)
	local ist = outline(inp, C.line, 1, 0)
	local nameBox = make("TextBox", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", PlaceholderText = "config name", PlaceholderColor3 = C.dimmer,
		TextColor3 = C.textHi, FontFace = F.med, TextSize = 7, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(9, 0), Size = UDim2.fromOffset(86, 20),
	}, inp)
	nameBox.Focused:Connect(function() tween(ist, 0.15, {Color = accent}) end)
	nameBox.FocusLost:Connect(function() tween(ist, 0.2, {Color = C.line}) end)
	local save = makeButton(card, "SAVE", "solid")
	save.Position = UDim2.fromOffset(120, 34)

	local cfgRows = {}
	local cardsBelow = {}
	local belowH = 0

	local function relayout(animate)
		local y = rowsTop
		for _, r in ipairs(cfgRows) do
			local target = UDim2.fromOffset(4, y)
			if animate then tween(r.frame, 0.24, {Position = target}, QUINT) else r.frame.Position = target end
			y = y + 26
		end
		local h = y + 6
		local size = UDim2.fromOffset(fullW, h)
		if animate then tween(card, 0.24, {Size = size}, QUINT) else card.Size = size end
		local ny = PAD_TOP + h + GAP
		for _, c2 in ipairs(cardsBelow) do
			local pos = UDim2.fromOffset(c2.Position.X.Offset, ny)
			if animate then tween(c2, 0.24, {Position = pos}, QUINT) else c2.Position = pos end
		end
		sc.CanvasSize = UDim2.fromOffset(0, ny + belowH + 16)
	end

	local function addConfig(name, sub, flash)
		local fr = make("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(4, rowsTop + #cfgRows * 26), Size = UDim2.fromOffset(fullW - 8, 26),
		}, card)
		corner(fr, 4)
		fr.MouseEnter:Connect(function() tween(fr, 0.12, {BackgroundTransparency = 0.975}) end)
		fr.MouseLeave:Connect(function() tween(fr, 0.18, {BackgroundTransparency = 1}) end)
		local letter = text(fr, string.upper(string.sub(name, 1, 1)), 10, 0, 12, 26, F.bold, 7, accent)
		bindAccent(letter, "TextColor3")
		text(fr, name, 28, 2, 200, 12, F.med, 8, C.text)
		text(fr, sub, 28, 14, 200, 9, F.reg, 6, C.dimmer)
		local del = makeButton(fr, "DEL", "ghost")
		del.AnchorPoint = Vector2.new(1, 0)
		del.Position = UDim2.fromOffset(fullW - 8 - 7, 4)
		local load = makeButton(fr, "LOAD", "ghost")
		load.AnchorPoint = Vector2.new(1, 0)
		load.Position = UDim2.fromOffset(fullW - 8 - 7 - 32 - 6, 4)
		local r = {frame = fr, name = name}
		cfgRows[#cfgRows + 1] = r
		load.MouseButton1Click:Connect(function()
			toast("Config " .. accentWord(name) .. " loaded")
			fr.BackgroundColor3 = accent
			fr.BackgroundTransparency = 0.85
			tween(fr, 0.7, {BackgroundTransparency = 1})
		end)
		del.MouseButton1Click:Connect(function()
			for i, v in ipairs(cfgRows) do
				if v == r then table.remove(cfgRows, i) break end
			end
			toast("Config " .. accentWord(name) .. " deleted")
			tween(fr, 0.18, {Size = UDim2.fromOffset(fullW - 8, 0)}, QUAD, IN)
			task.delay(0.2, function() fr:Destroy() end)
			relayout(true)
		end)
		if flash then
			fr.BackgroundColor3 = accent
			fr.BackgroundTransparency = 0.8
			tween(fr, 0.8, {BackgroundTransparency = 1})
		end
	end

	addConfig("legit", "today 14:02")
	addConfig("rage hvh", "yesterday")
	addConfig("esp only", "2 days ago")

	save.MouseButton1Click:Connect(function()
		local nm = string.gsub(nameBox.Text, "^%s*(.-)%s*$", "%1")
		if nm == "" then nm = "config " .. (#cfgRows + 1) end
		addConfig(nm, "today " .. os.date("%H:%M"), true)
		nameBox.Text = ""
		toast("Config " .. accentWord(nm) .. " saved")
		relayout(true)
	end)

	-- Interface / Info
	local h1, c1 = buildCard(sc, COL_X1, 0, COL_W, def.left[1])
	local h2, c2 = buildCard(sc, COL_X2, 0, COL_W, def.right[1])
	cardsBelow = {c1, c2}
	belowH = math.max(h1, h2)
	relayout(false)
end

for i, def in ipairs(PAGES) do
	if def.custom then
		buildSettings(def, i)
	else
		local pg = newPage(i)
		buildColumns(pg.scroll, def)
	end
end

-- поиск по меткам: совпадения подсвечиваются, остальные тускнеют
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local q = string.lower(searchBox.Text)
	for _, e in ipairs(searchReg) do
		local match = (q == "") or (string.find(e.text, q, 1, true) ~= nil)
		tween(e.label, 0.15, {
			TextTransparency = match and 0 or 0.72,
			TextColor3 = (q ~= "" and match) and accent or C.text,
		})
	end
end)

-- ═══════════════════════ НАВИГАЦИЯ ═══════════════════════
local navHolder = make("Frame", {
	BackgroundTransparency = 1, Position = UDim2.fromOffset(7, 54), Size = UDim2.fromOffset(122, #PAGES * 30),
}, sidebar)
local navHi = make("Frame", {
	BackgroundColor3 = C.sidebar, BorderSizePixel = 0, Size = UDim2.fromOffset(122, 26),
}, navHolder)
corner(navHi, 6)
local navStroke = outline(navHi, accent, 1, 0.55)
local navBar = frame(navHi, 0, 6, 2, 14, accent)
corner(navBar, 1)
onAccent(function(c, instant)
	local bg = C.sidebar:Lerp(c, 0.16)
	if instant then
		navHi.BackgroundColor3 = bg; navStroke.Color = c; navBar.BackgroundColor3 = c
	else
		tween(navHi, 0.25, {BackgroundColor3 = bg}); tween(navStroke, 0.25, {Color = c}); tween(navBar, 0.25, {BackgroundColor3 = c})
	end
end)

local NAV = {}
for i, def in ipairs(PAGES) do
	local b = make("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, (i - 1) * 30), Size = UDim2.fromOffset(122, 26), ZIndex = 2,
	}, navHolder)
	corner(b, 6)
	local ic = makeIcon(def.icon, b, 11, 7)
	ic.setColor(C.nav)
	local lb = text(b, def.name, 32, 0, 86, 26, F.med, 8, C.nav)
	local item = {active = false}
	function item.setActive(on, animate)
		item.active = on
		local tc = on and C.textHi or C.nav
		local ac = on and accent or C.dim
		if animate then
			tween(lb, 0.2, {TextColor3 = tc}); ic.setColor(ac, true, 0.2)
		else
			lb.TextColor3 = tc; ic.setColor(ac)
		end
		if on then tween(b, 0.12, {BackgroundTransparency = 1}) end
	end
	b.MouseEnter:Connect(function()
		if not item.active then tween(b, 0.12, {BackgroundTransparency = 0.96}); tween(lb, 0.12, {TextColor3 = C.text}) end
	end)
	b.MouseLeave:Connect(function()
		if not item.active then tween(b, 0.15, {BackgroundTransparency = 1}); tween(lb, 0.15, {TextColor3 = C.nav}) end
	end)
	b.MouseButton1Click:Connect(function() hooks.selectTab(i) end)
	item.setActive(false, false)
	onAccent(function(c)
		if item.active then ic.setColor(c, true, 0.25) end
	end)
	NAV[i] = item
end

local function selectTab(i, instant)
	if i == state.tab then return end
	closePopup()
	local oldI = state.tab
	state.tab = i
	local def = PAGES[i]
	for k, n in ipairs(NAV) do n.setActive(k == i, not instant) end
	local target = UDim2.fromOffset(0, (i - 1) * 30)
	if instant then navHi.Position = target else tween(navHi, 0.3, {Position = target}, QUINT) end

	if instant then
		titleLbl.Text = def.name
		subLbl.Text = def.sub
	else
		tween(titleLbl, 0.08, {TextTransparency = 1})
		tween(subLbl, 0.08, {TextTransparency = 1})
		task.delay(0.09, function()
			if state.tab ~= i then return end
			titleLbl.Text = def.name
			subLbl.Text = def.sub
			tween(titleLbl, 0.16, {TextTransparency = 0})
			tween(subLbl, 0.16, {TextTransparency = 0})
		end)
	end

	local new, old = pages[i], pages[oldI]
	if instant then
		new.holder.Visible = true
		new.holder.GroupTransparency = 0
		if old then old.holder.Visible = false end
	else
		if old then
			tween(old.holder, 0.12, {GroupTransparency = 1}, QUAD, IN)
			task.delay(0.13, function()
				if state.tab ~= oldI then old.holder.Visible = false end
			end)
		end
		new.holder.Position = UDim2.fromOffset(0, 10)
		new.holder.GroupTransparency = 1
		new.holder.Visible = true
		tween(new.holder, 0.26, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)}, QUINT, OUT)
	end
end
hooks.selectTab = selectTab

-- ═══════════════════════ ОТКРЫТИЕ / ЗАКРЫТИЕ ═══════════════════════
local dragX, dragY = 0, 0
local winToken = 0

local function baseScale() return S * state.menuScale end

local function setOpen(v)
	if state.open == v then return end
	state.open = v
	closePopup()
	stopListening()
	winToken = winToken + 1
	local tok = winToken
	if v then
		winRoot.Visible = true
		win.GroupTransparency = 1
		winScale.Scale = baseScale() * 0.94
		winRoot.Position = UDim2.new(0.5, dragX, 0.5, dragY + 10)
		edgeStroke.Transparency = 1
		tween(win, 0.22, {GroupTransparency = 0}, QUAD, OUT)
		tween(winScale, 0.28, {Scale = baseScale()}, QUINT, OUT)
		tween(winRoot, 0.28, {Position = UDim2.new(0.5, dragX, 0.5, dragY)}, QUINT, OUT)
		tween(edgeStroke, 0.25, {Transparency = 0.25})
		for _, s in ipairs(shadows) do
			s.frame.BackgroundTransparency = 1
			tween(s.frame, 0.28, {BackgroundTransparency = s.a})
		end
	else
		tween(win, 0.16, {GroupTransparency = 1}, QUAD, IN)
		tween(winScale, 0.18, {Scale = baseScale() * 0.96}, QUAD, IN)
		tween(winRoot, 0.18, {Position = UDim2.new(0.5, dragX, 0.5, dragY + 6)}, QUAD, IN)
		tween(edgeStroke, 0.16, {Transparency = 1})
		for _, s in ipairs(shadows) do tween(s.frame, 0.16, {BackgroundTransparency = 1}) end
		task.delay(0.2, function()
			if tok == winToken and not state.open then winRoot.Visible = false end
		end)
	end
end

-- перетаскивание окна за шапку; двойной клик = сброс позиции
local lastClick = 0
local function makeDragHandle(parent, x, y, w, h)
	local hit = make("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
	}, parent)
	hit.InputBegan:Connect(function(input)
		if not isPress(input) then return end
		local now = os.clock()
		if now - lastClick < 0.3 then
			lastClick = 0
			dragX, dragY = 0, 0
			tween(winRoot, 0.32, {Position = UDim2.new(0.5, 0, 0.5, 0)}, QUINT, OUT)
			toast("Position reset")
			return
		end
		lastClick = now
		local start = UserInputService:GetMouseLocation()
		local sx, sy = dragX, dragY
		beginDrag(function(pos)
			local sz = gui.AbsoluteSize
			dragX = clamp(sx + (pos.X - start.X), -sz.X / 2 + 90, sz.X / 2 - 90)
			dragY = clamp(sy + (pos.Y - start.Y), -sz.Y / 2 + 40, sz.Y / 2 - 40)
			winRoot.Position = UDim2.new(0.5, dragX, 0.5, dragY)
		end)
	end)
end
makeDragHandle(main, 0, 0, 238, BAR_H)
makeDragHandle(sidebar, 0, 0, SIDE_W, BAR_H)

-- кнопки "+" и "×"
local function iconButton(parent, x, y, kind, onClick)
	local b = make("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundColor3 = C.field, BackgroundTransparency = 0.35, BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(22, 22),
	}, parent)
	corner(b, 5)
	local ic = makeIcon(kind, b, 5, 5)
	ic.setColor(C.dim)
	b.MouseEnter:Connect(function() tween(b, 0.12, {BackgroundTransparency = 0}); ic.setColor(C.textHi, true, 0.12) end)
	b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0.35}); ic.setColor(C.dim, true, 0.15) end)
	b.MouseButton1Click:Connect(function() if onClick then onClick() end end)
	return b
end
iconButton(main, 397, 11, "plus", nil)
iconButton(main, 430, 11, "close", function() setOpen(false) end)

-- ═══════════════════════ HUD ═══════════════════════
local function hudPanel(name, w, h, title)
	local p = make("Frame", {
		Name = name, BackgroundColor3 = C.hud, BackgroundTransparency = 0.18, BorderSizePixel = 0, Size = UDim2.fromOffset(w, h),
	}, gui)
	make("UIScale", {Scale = S}, p)
	corner(p, 5)
	outline(p, C.line, 1, 0.45)
	local band = make("Frame", {BackgroundColor3 = accent, BorderSizePixel = 0, Size = UDim2.fromOffset(w, 17)}, p)
	corner(band, 5)
	make("UIGradient", {Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(0.65, 0.95), NumberSequenceKeypoint.new(1, 1),
	})}, band)
	bindAccent(band, "BackgroundColor3")
	text(p, title, 6, 0, w - 12, 17, F.bold, 6, C.textHi)
	return p
end

-- ватермарк (слева сверху)
local wm = make("Frame", {
	Name = "Watermark", BackgroundColor3 = C.hud, BackgroundTransparency = 0.15, BorderSizePixel = 0,
	Position = UDim2.fromOffset(px(10), px(8)), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18),
}, gui)
make("UIScale", {Scale = S}, wm)
corner(wm, 4)
outline(wm, C.line, 1, 0.45)
padding(wm, 5, 9)
make("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 9),
}, wm)
do
	local av = makeAvatar(wm, 0, 0, 11)
	av.LayoutOrder = 1
	local function wl(str, font, color, order)
		return make("TextLabel", {
			BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18),
			Text = str, FontFace = font, TextSize = 6, TextColor3 = color, LayoutOrder = order,
		}, wm)
	end
	wl(CFG.Title, F.bold, C.textHi, 2)
	wl(CFG.Version, F.reg, C.dim, 3)
	hud.fps = wl("144 fps", F.reg, C.dim, 4)
	hud.ms = wl("31 ms", F.reg, C.dim, 5)
	hud.clock = wl(os.date("%H:%M"), F.reg, C.dim, 6)
end
hud.wm = wm

-- TARGET (справа сверху)
local tp = hudPanel("Target", 105, 53, "TARGET")
tp.AnchorPoint = Vector2.new(1, 0)
tp.Position = UDim2.new(1, -px(12), 0, px(10))
text(tp, "Armor", 6, 20, 40, 13, F.med, 6, C.dim)
do
	local trk = frame(tp, 47, 24.5, 51, 3.6, C.track)
	circle(trk)
	local fl = frame(trk, 0, 0, 32, 3.6, accent)
	circle(fl)
	bindAccent(fl, "BackgroundColor3")
end
text(tp, "Weapon", 6, 37, 40, 13, F.med, 6, C.dim)
text(tp, "LR-300", 40, 37, 59, 13, F.bold, 7, C.textHi, Enum.TextXAlignment.Right)
hud.target = tp
hud.targetScale = tp:FindFirstChildOfClass("UIScale")

-- HOTKEYS (слева по центру)
local hp = hudPanel("Hotkeys", 106, 51, "HOTKEYS")
hp.AnchorPoint = Vector2.new(0, 0.5)
hp.Position = UDim2.new(0, px(11), 0.5, px(27))
text(hp, "Aimbot", 6, 18, 50, 13, F.med, 6, C.text)
text(hp, "[MB2 hold]", 40, 18, 60, 13, F.med, 6, accent, Enum.TextXAlignment.Right)
text(hp, "Zoom", 6, 35, 50, 13, F.med, 6, C.text)
text(hp, "[C toggle]", 40, 35, 60, 13, F.med, 6, accent, Enum.TextXAlignment.Right)
for _, l in ipairs(hp:GetChildren()) do
	if l:IsA("TextLabel") and l.TextColor3 == accent then bindAccent(l, "TextColor3") end
end
hud.hotkeys = hp

-- подсказка снизу
local hint = make("Frame", {
	Name = "Hint", BackgroundColor3 = C.hud, BackgroundTransparency = 0.25, BorderSizePixel = 0,
	AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -px(15)),
	AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 23),
}, gui)
make("UIScale", {Scale = S}, hint)
corner(hint, 8)
padding(hint, 6)
make("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8),
}, hint)
do
	local chip = make("TextLabel", {
		Text = CFG.MenuKey.Name, AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0, BackgroundColor3 = C.fieldHi,
		FontFace = F.med, TextSize = 6, TextColor3 = C.text, Size = UDim2.fromOffset(0, 12), LayoutOrder = 1,
	}, hint)
	corner(chip, 4)
	padding(chip, 5)
	hud.hintKey = chip
	make("TextLabel", {
		Text = "open / close", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, FontFace = F.reg,
		TextSize = 6, TextColor3 = C.dim, Size = UDim2.fromOffset(0, 12), LayoutOrder = 2,
	}, hint)
	local tb = make("TextButton", {
		Text = "TOGGLE MENU", AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(10, 22, 40), BackgroundTransparency = 0.1, FontFace = F.bold, TextSize = 6,
		TextColor3 = accent, Size = UDim2.fromOffset(0, 17), LayoutOrder = 3,
	}, hint)
	circle(tb)
	padding(tb, 9)
	local tst = outline(tb, accent, 1, 0.35)
	bindAccent(tb, "TextColor3")
	bindAccent(tst, "Color")
	tb.MouseEnter:Connect(function() tween(tb, 0.12, {BackgroundTransparency = 0}); tween(tst, 0.12, {Transparency = 0}) end)
	tb.MouseLeave:Connect(function() tween(tb, 0.15, {BackgroundTransparency = 0.1}); tween(tst, 0.15, {Transparency = 0.35}) end)
	tb.MouseButton1Click:Connect(function() setOpen(not state.open) end)
end
hud.hint = hint

if not CFG.ShowHud then
	for _, o in ipairs({wm, tp, hp, hint}) do o.Visible = false end
end

-- ═══════════════════════ ХУКИ (только визуальные реакции самого меню) ═══════════════════════
hooks.wm = function(v) wm.Visible = v end
hooks.notif = function(v) state.notifications = v end
hooks.accent = function(opt) setAccent(ACCENTS[opt] or accent) end
hooks.menu_scale = function(v)
	state.menuScale = v / 100
	tween(winScale, 0.15, {Scale = baseScale()})
end
hooks.hk_on = function(v) hp.Visible = v end
hooks.hk_pos = function(opt)
	local target = (opt == "Right") and UDim2.new(1, -px(11) - px(106), 0.5, px(27)) or UDim2.new(0, px(11), 0.5, px(27))
	tween(hp, 0.35, {Position = target}, QUINT, OUT)
end
hooks.armor_on = function(v) tp.Visible = v end
hooks.armor_scale = function(v) tween(hud.targetScale, 0.12, {Scale = S * v / 100}) end
hooks.fov_radius = function(v)
	local d = 24 + (v - 20) / 280 * 46.7
	tween(PREVIEW.ring, 0.1, {Size = UDim2.fromOffset(d, d)})
end
hooks.fov_color = function(c) tween(PREVIEW.stroke, 0.12, {Color = c}) end
hooks.test_alert = function() toast("Moderator alert " .. accentWord("test")) end
hooks.copy_invite = function() toast("Invite " .. accentWord("copied")) end
hooks.menu_key = function(name, input)
	state.menuKey = input.KeyCode
	hud.hintKey.Text = input.KeyCode.Name
	toast("Menu key set to " .. accentWord(name))
end

local function destroyAll()
	closePopup()
	for _, c in ipairs(conns) do c:Disconnect() end
	gui:Destroy()
end
hooks.unload = function()
	toast("Unloading...")
	setOpen(false)
	task.delay(0.6, destroyAll)
end

-- ═══════════════════════ ВВОД / ЦИКЛЫ ═══════════════════════
connect(UserInputService.InputBegan, function(input, gpe)
	local L = state.listening
	if L then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape then
				stopListening()
			elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
				finishListening("NONE", input)
			else
				finishListening(keyName(input.KeyCode), input)
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			finishListening("MB1", input)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			finishListening("MB2", input)
		elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
			finishListening("MB3", input)
		end
		return
	end
	if openPopup and isPress(input) then
		local pos = UserInputService:GetMouseLocation()
		if not inside(openPopup.frame, pos) and not inside(openPopup.owner, pos) then closePopup() end
	end
	if gpe then return end
	if input.KeyCode == state.menuKey then setOpen(not state.open) end
end)

-- fps / ping / время в ватермарке
do
	local frames, acc = 0, 0
	connect(RunService.RenderStepped, function(dt)
		frames = frames + 1
		acc = acc + dt
		if acc >= 0.5 then
			hud.fps.Text = math.floor(frames / acc + 0.5) .. " fps"
			local ok, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
			hud.ms.Text = ((ok and ping) and math.floor(ping + 0.5) or 31) .. " ms"
			hud.clock.Text = os.date("%H:%M")
			frames, acc = 0, 0
		end
	end)
end

-- ═══════════════════════ СТАРТ ═══════════════════════
selectTab(1, true)
if CFG.StartOpen then
	task.delay(0.35, function() setOpen(true) end)
end
