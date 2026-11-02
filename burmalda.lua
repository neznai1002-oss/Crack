--[[
	BurmaldaVisual · меню визуалов (ТОЛЬКО интерфейс и анимации) · Roblox / Luau
	────────────────────────────────────────────────────────────────────────
	Куда класть : Roblox Studio → StarterPlayer → StarterPlayerScripts → LocalScript, вставить этот код.
	Что внутри  : компактное окно с одной вкладкой «Визуалы» (ауры, частицы, трейлы,
	              комфорт-эффекты, интерфейс), HUD (ватермарк + подсказка снизу),
	              тосты, выпадающие списки, палитра цвета, перетаскивание окна.
	Лого        : буква «B» (BurmaldaVisual) с пульсирующей анимацией.
	Чего НЕТ    : никаких игровых функций. Тумблеры/слайдеры меняют только вид меню
	              и анимированное превью ауры.
	Клавиша     : RightShift открывает/закрывает меню (меняется в разделе «Интерфейс»).
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Stats            = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

do -- повторный запуск удаляет старую копию
	local prev = PlayerGui:FindFirstChild("BurmaldaVisualUI")
	if prev then prev:Destroy() end
end

-- ═══════════════════════ НАСТРОЙКИ ═══════════════════════
local CFG = {
	Title     = "BurmaldaVisual",
	Version   = "v1.0",
	UserName  = nil,                       -- nil = ник твоего игрока
	License   = "lifetime",
	Scale     = 1.2,                       -- общий размер интерфейса
	MenuKey   = Enum.KeyCode.RightShift,
	ShowHud   = true,
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
local SINE, BACK = Enum.EasingStyle.Sine, Enum.EasingStyle.Back
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

-- круговая рябь по клику (внутри любого элемента)
local function ripple(parent, x, y, maxD)
	local r = make("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.82, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(4, 4), ZIndex = 20,
	}, parent)
	circle(r)
	tween(r, 0.45, {Size = UDim2.fromOffset(maxD or 56, maxD or 56), BackgroundTransparency = 1}, QUAD, OUT)
	task.delay(0.5, function() r:Destroy() end)
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

-- ═══════════════════════ GUI ═══════════════════════
local gui = make("ScreenGui", {
	Name = "BurmaldaVisualUI", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 1000,
}, PlayerGui)

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
local FX = {} -- ссылки на анимированные элементы (превью ауры, лого и т.п.)

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

	if kind == "sun" then
		ring(6, 6, 5, 1.2)
		for i = 0, 7 do
			local a = math.rad(i * 45)
			bar(6 + math.cos(a) * 4.9, 6 + math.sin(a) * 4.9, 1.2, 2, i * 45 + 90)
		end
	elseif kind == "sparkle" then
		bar(6, 6, 1.4, 10, 0); bar(6, 6, 10, 1.4, 0)
		bar(6, 6, 1.2, 7, 45); bar(6, 6, 1.2, 7, -45)
		dot(6, 6, 2.2)
	elseif kind == "gear" then
		ring(6, 6, 6.6, 1.5)
		for i = 0, 7 do
			local a = math.rad(i * 45)
			bar(6 + math.cos(a) * 4.6, 6 + math.sin(a) * 4.6, 2, 2.2, i * 45 + 90)
		end
	elseif kind == "search" then
		ring(5, 5, 7, 1.2); bar(9.6, 9.6, 4.4, 1.2, 45)
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

-- ═══════════════════════ ЛОГОТИП «B» ═══════════════════════
local function makeLogo(parent, x, y, d, letterSize)
	local box = make("Frame", {
		Name = "Logo", BackgroundColor3 = accent, BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(d, d),
	}, parent)
	corner(box, math.max(4, d * 0.28))
	local grad = make("UIGradient", {
		Rotation = 60,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 130)),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.55),
			NumberSequenceKeypoint.new(1, 0.82),
		}),
	}, box)
	local st = outline(box, accent, 1.5, 0.4)
	local letter = make("TextLabel", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = "B",
		FontFace = F.bold, TextSize = letterSize or d * 0.62, TextColor3 = Color3.new(1, 1, 1),
		Size = UDim2.fromScale(1, 1),
	}, box)
	bindAccent(box, "BackgroundColor3")
	bindAccent(st, "Color")
	local sc = make("UIScale", {Scale = 1}, box)

	-- мягкое «дыхание» лого
	task.spawn(function()
		while box.Parent do
			tween(sc, 1.3, {Scale = 1.1}, SINE, OUT); task.wait(1.3)
			if not box.Parent then break end
			tween(sc, 1.3, {Scale = 1.0}, SINE, OUT); task.wait(1.3)
		end
	end)
	-- блик, скользящий по лого
	task.spawn(function()
		while box.Parent do
			grad.Offset = Vector2.new(-0.7, 0)
			tween(grad, 1.6, {Offset = Vector2.new(0.7, 0)}, SINE, IN); task.wait(1.7)
		end
	end)
	return box
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
local TOAST_W, TOAST_H, TOAST_GAP = 150, 21, 8
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

-- msg — RichText-строка, например: 'Аура <font color="#1E90FF">включена</font>'
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
	-- появление с лёгким «перелётом» (back)
	tween(f, 0.38, {Position = UDim2.new(1, 0, 1, 0)}, BACK, OUT)
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

-- ═══════════════════════ ОКНО (компактное) ═══════════════════════
local WIN_W, WIN_H, SIDE_W, BAR_H = 470, 330, 118, 38
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

-- светящаяся линия сверху окна + анимированный шиммер (бегущий блик)
do
	local glow = frame(win, 0, 0, WIN_W, 1, accent)
	local grad = make("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.45), NumberSequenceKeypoint.new(1, 1),
		}),
	}, glow)
	bindAccent(glow, "BackgroundColor3")
	task.spawn(function()
		while glow.Parent do
			grad.Offset = Vector2.new(-1, 0)
			tween(grad, 2.4, {Offset = Vector2.new(1, 0)}, LIN)
			task.wait(2.5)
		end
	end)
end

-- ═══ сайдбар: бренд с лого «B» ═══
makeLogo(sidebar, 10, 9, 22)
text(sidebar, "Burmalda", 38, 9, 74, 11, F.bold, 7, C.textHi)
text(sidebar, "Visual", 38, 20, 74, 9, F.med, 6, accent)
text(sidebar, CFG.Version, 38, 29, 74, 8, F.reg, 5, C.dim)
frame(sidebar, 0, BAR_H, SIDE_W, 1, C.line)

-- ═══ сайдбар: профиль внизу ═══
local PROF_Y = WIN_H - 42
frame(sidebar, 0, PROF_Y - 8, SIDE_W, 1, C.line)
makeAvatar(sidebar, 10, PROF_Y, 20)
text(sidebar, USER, 36, PROF_Y, 76, 11, F.bold, 7, C.textHi)
text(sidebar, "license: " .. CFG.License, 36, PROF_Y + 12, 76, 9, F.reg, 6, C.dim)
do
	local d = frame(sidebar, 106, PROF_Y + 10, 5, 5, C.green)
	circle(d)
	outline(d, C.green, 2, 0.75)
end

-- ═══ верхняя панель ═══
frame(main, 0, 0, MAIN_W, BAR_H, C.topbar)
frame(main, 0, BAR_H, MAIN_W, 1, C.line)

local titleBox = make("Frame", {
	BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.fromOffset(200, BAR_H),
}, main)
make("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8),
}, titleBox)
local titleLbl = make("TextLabel", {
	BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 15),
	Text = "", FontFace = F.bold, TextSize = 10, TextColor3 = C.textHi, LayoutOrder = 1,
}, titleBox)
local subLbl = make("TextLabel", {
	BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 14),
	Text = "", FontFace = F.reg, TextSize = 6, TextColor3 = C.dim, LayoutOrder = 2,
}, titleBox)

-- поиск
local searchBox
do
	local sb = frame(main, 196, 9, 120, 20, C.field)
	corner(sb, 5)
	local sst = outline(sb, C.line, 1, 0)
	local sic = makeIcon("search", sb, 7, 4)
	sic.setColor(C.dim)
	searchBox = make("TextBox", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", PlaceholderText = "Поиск...",
		PlaceholderColor3 = C.dimmer, TextColor3 = C.textHi, FontFace = F.med, TextSize = 7,
		ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(23, 0), Size = UDim2.fromOffset(90, 20),
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
	local l = text(row, str, 8, sub and 2 or 0, 108, sub and 12 or ROW_H, F.med, 8, C.text)
	regSearch(l, str)
	if sub then text(row, sub, 8, 14, 120, 9, F.reg, 6, C.dimmer) end
	return l
end

-- ─── переключатель (с пружинной анимацией ручки) ───
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
			tween(track, 0.18, pt); tween(knob, 0.26, pk, BACK, OUT); tween(halo, 0.18, ph)
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
	track.InputBegan:Connect(function(input)
		if isPress(input) then ripple(track, input.Position.X - track.AbsolutePosition.X, input.Position.Y - track.AbsolutePosition.Y, 26) end
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
				tween(knob, 0.2, {Size = UDim2.fromOffset(8, 8)}, BACK, OUT)
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

-- ─── кнопки (с рябью) ───
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
	b.InputBegan:Connect(function(input)
		if isPress(input) then ripple(b, input.Position.X - b.AbsolutePosition.X, input.Position.Y - b.AbsolutePosition.Y, 40) end
	end)
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

-- ─── выпадающий список (пункты появляются каскадом) ───
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
			BorderSizePixel = 0, Position = UDim2.fromOffset(4, 4 + (i - 1) * ih + 4), Size = UDim2.fromOffset(bw - 8, ih),
		}, list)
		corner(it, 4)
		it.ClipsDescendants = true
		local lb = text(it, o, 7, 0, bw - 20, ih, F.med, 8, o == current and accent or C.text)
		lb.TextTransparency = 1
		it.BackgroundTransparency = 1
		task.delay(i * 0.035, function()
			if it.Parent then
				tween(it, 0.18, {Position = UDim2.fromOffset(4, 4 + (i - 1) * ih)}, QUAD, OUT)
				tween(lb, 0.18, {TextTransparency = 0})
				tween(it, 0.18, {BackgroundTransparency = 0.96 + 0.04})
			end
		end)
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
	local lbl = text(row, d.text, 8, 0, 108, 12, F.med, 8, C.text)
	regSearch(lbl, d.text)
	if hasSub then text(row, d.sub, 8, 12, 120, 9, F.reg, 6, C.dimmer) end
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
		widths[i] = math.max(30, #o * 5 + 14)
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
	local bw, bh = 76, 20
	local btn = make("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundColor3 = C.field, BorderSizePixel = 0,
		Position = UDim2.fromOffset((w - 8) - 7 - bw, 3), Size = UDim2.fromOffset(bw, bh),
	}, row)
	corner(btn, 4)
	local st = outline(btn, C.line, 1, 0)
	local val = text(btn, d.v, 8, 0, bw - 24, bh, F.med, 7, C.textHi)
	local chev = makeIcon("chevron", btn, bw - 15, 4)
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

-- превью ауры: вращающееся кольцо, орбитальные искры, пульсирующее ядро
ROWS.preview = function(card, d, y, w)
	local box = make("Frame", {
		BackgroundColor3 = Color3.fromRGB(14, 14, 21), BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, y + 2), Size = UDim2.fromOffset(w - 24, 78),
	}, card)
	corner(box, 5)
	outline(box, C.line, 1, 0)

	local core = make("Frame", {
		BackgroundColor3 = accent, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(10, 10),
	}, box)
	circle(core)
	local coreGlow = outline(core, accent, 3, 0.55)
	corner(make("Frame", {
		BackgroundColor3 = accent, BackgroundTransparency = 0.6, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(22, 22),
	}, box), 11)

	local ring = make("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(46, 46),
	}, box)
	circle(ring)
	local rs = outline(ring, accent, 1.2, 0.15)

	-- орбитальные искры на кольце
	local orbiters = {}
	for i = 1, 3 do
		local o = make("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(4, 4), ZIndex = 3,
		}, ring)
		circle(o)
		orbiters[i] = o
	end

	-- вращение кольца + дыхание ядра + искры по орбите
	local t0 = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not box.Parent then conn:Disconnect() return end
		local t = os.clock() - t0
		ring.Rotation = (t * 40) % 360
		local pulse = 1 + math.sin(t * 2.4) * 0.18
		core.Size = UDim2.fromOffset(10 * pulse, 10 * pulse)
		coreGlow.Transparency = 0.4 + math.sin(t * 2.4) * 0.25
		for i, o in ipairs(orbiters) do
			local a = math.rad(t * 90 + i * 120)
			o.Position = UDim2.new(0.5, math.cos(a) * 23, 0.5, math.sin(a) * 23)
			local tw = 0.55 + 0.45 * math.sin(t * 3 + i * 2)
			o.BackgroundTransparency = 1 - tw * 0.8
			o.Size = UDim2.fromOffset(3 + tw * 2, 3 + tw * 2)
		end
	end)

	FX.auraCore, FX.auraRingStroke, FX.auraRing = core, rs, ring
	text(box, "превью ауры", 6, 3, 70, 9, F.reg, 5, C.dimmer)
	return 86
end

-- ═══════════════════════ КАРТОЧКИ И СТРАНИЦЫ ═══════════════════════
local PAD_TOP, COL_W, COL_X1, COL_X2, GAP = 12, 158, 12, 182, 12

local function buildCard(parent, x, y, w, sec)
	local card = make("Frame", {
		BackgroundColor3 = C.card, BorderSizePixel = 0, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, 60),
	}, parent)
	corner(card, 6)
	local cst = outline(card, C.line, 1, 0.3)
	card.MouseEnter:Connect(function() tween(cst, 0.15, {Color = C.line2, Transparency = 0.1}) end)
	card.MouseLeave:Connect(function() tween(cst, 0.2, {Color = C.line, Transparency = 0.3}) end)
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

-- ═══════════════════════ ДАННЫЕ ВКЛАДКИ «ВИЗУАЛЫ» ═══════════════════════
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
	{name = "Визуалы", sub = "ауры, частицы, комфорт", icon = "sparkle",
		left = {
			{title = "АУРА", rows = {
				T("Включить", true, nil, "aura_on"),
				DD("Стиль", {"Пульс", "Орбита", "Пламя", "Нимб"}, "Пульс", "aura_style"),
				CP("Цвет", COL.violet, "aura_color"),
				SL("Радиус", 8, 2, 20, 1, "", 0, "размер ауры вокруг персонажа", "aura_radius"),
				SL("Скорость", 5, 1, 10, 1, "", 0, "темп анимации", "aura_speed"),
				SL("Прозрачность", 30, 0, 100, 5, "%", 0, nil, "aura_trans"),
				{t = "preview"},
			}},
			{title = "ЧАСТИЦЫ", rows = {
				T("Включить", true, nil, "parts_on"),
				DD("Тип", {"Искры", "Светлячки", "Кольца", "Снежинки"}, "Искры", "parts_type"),
				CP("Цвет", COL.blue, "parts_color"),
				SL("Количество", 40, 5, 150, 5, "", 0, nil, "parts_count"),
				SL("Размер", 3, 1, 8, 1, "", 0, nil, "parts_size"),
			}},
		},
		right = {
			{title = "ТРЕЙЛЫ", rows = {
				T("Включить", false, nil, "trail_on"),
				DD("Стиль", {"Лента", "Мерцание", "Радуга"}, "Лента", "trail_style"),
				CP("Цвет", COL.blue, "trail_color"),
				SL("Жизнь", 1.2, 0.2, 3, 0.1, "s", 1, nil, "trail_life"),
				SL("Толщина", 2, 1, 6, 1, "", 0, nil, "trail_w"),
			}},
			{title = "КОМФОРТ", rows = {
				T("Мягкое свечение", true, "сглаживает картинку", "bloom"),
				SL("Интенсивность", 35, 0, 100, 5, "%", 0, nil, "bloom_i"),
				T("Тёплый тон", false, "приятный оттенок экрана", "warm"),
				T("Виньетка", false, "затемнение краёв", "vig"),
				CP("Цвет свечения", COL.lav, "glow_color"),
			}},
			{title = "ИНТЕРФЕЙС", rows = {
				KB("Клавиша меню", keyName(CFG.MenuKey), "menu_key"),
				DD("Акцент", {"Blue", "Purple", "Green", "Red", "Orange"}, "Blue", "accent"),
				SL("Масштаб меню", 100, 70, 120, 5, "%", 0, nil, "menu_scale"),
				T("Ватермарк", true, nil, "wm"),
				T("Уведомления", true, nil, "notif"),
				BT("Discord", "COPY", "copy_invite"),
				BT("Выгрузить", "UNLOAD", "unload"),
			}},
		},
	},
}

for i, def in ipairs(PAGES) do
	local pg = newPage(i)
	buildColumns(pg.scroll, def)
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
	BackgroundTransparency = 1, Position = UDim2.fromOffset(7, 48), Size = UDim2.fromOffset(104, #PAGES * 30),
}, sidebar)
local navHi = make("Frame", {
	BackgroundColor3 = C.sidebar, BorderSizePixel = 0, Size = UDim2.fromOffset(104, 26),
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
		Position = UDim2.fromOffset(0, (i - 1) * 30), Size = UDim2.fromOffset(104, 26), ZIndex = 2,
	}, navHolder)
	corner(b, 6)
	b.ClipsDescendants = true
	local ic = makeIcon(def.icon, b, 11, 7)
	ic.setColor(C.nav)
	local lb = text(b, def.name, 32, 0, 68, 26, F.med, 8, C.nav)
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
	b.InputBegan:Connect(function(input)
		if isPress(input) then ripple(b, input.Position.X - b.AbsolutePosition.X, input.Position.Y - b.AbsolutePosition.Y, 34) end
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
			toast("Позиция сброшена")
			return
		end
		lastClick = now
		local start = UserInputService:GetMouseLocation()
		local sx, sy = dragX, dragY
		beginDrag(function(pos)
			local sz = gui.AbsoluteSize
			dragX = clamp(sx + (pos.X - start.X), -sz.X / 2 + 80, sz.X / 2 - 80)
			dragY = clamp(sy + (pos.Y - start.Y), -sz.Y / 2 + 40, sz.Y / 2 - 40)
			winRoot.Position = UDim2.new(0.5, dragX, 0.5, dragY)
		end)
	end)
end
makeDragHandle(main, 0, 0, 180, BAR_H)
makeDragHandle(sidebar, 0, 0, SIDE_W, BAR_H)

-- кнопка «×»
local function iconButton(parent, x, y, kind, onClick)
	local b = make("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundColor3 = C.field, BackgroundTransparency = 0.35, BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(22, 22),
	}, parent)
	corner(b, 5)
	b.ClipsDescendants = true
	local ic = makeIcon(kind, b, 5, 5)
	ic.setColor(C.dim)
	b.InputBegan:Connect(function(input)
		if isPress(input) then ripple(b, input.Position.X - b.AbsolutePosition.X, input.Position.Y - b.AbsolutePosition.Y, 28) end
	end)
	b.MouseEnter:Connect(function() tween(b, 0.12, {BackgroundTransparency = 0}); ic.setColor(C.textHi, true, 0.12) end)
	b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0.35}); ic.setColor(C.dim, true, 0.15) end)
	b.MouseButton1Click:Connect(function() if onClick then onClick() end end)
	return b
end
iconButton(main, MAIN_W - 11 - 22, 8, "close", function() setOpen(false) end)

-- ═══════════════════════ HUD ═══════════════════════
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
	local lg = makeLogo(wm, 0, 0, 11, 8)
	lg.LayoutOrder = 1
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
		Text = "открыть / закрыть", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, FontFace = F.reg,
		TextSize = 6, TextColor3 = C.dim, Size = UDim2.fromOffset(0, 12), LayoutOrder = 2,
	}, hint)
	local tb = make("TextButton", {
		Text = "МЕНЮ", AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0,
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
	for _, o in ipairs({wm, hint}) do o.Visible = false end
end

-- ═══════════════════════ ХУКИ (визуальные реакции меню и превью) ═══════════════════════
hooks.wm = function(v) wm.Visible = v end
hooks.notif = function(v) state.notifications = v end
hooks.accent = function(opt) setAccent(ACCENTS[opt] or accent) end
hooks.menu_scale = function(v)
	state.menuScale = v / 100
	tween(winScale, 0.15, {Scale = baseScale()})
end
hooks.menu_key = function(name, input)
	state.menuKey = input.KeyCode
	hud.hintKey.Text = input.KeyCode.Name
	toast("Клавиша меню: " .. accentWord(name))
end
-- перекраска превью ауры
hooks.aura_color = function(c)
	if FX.auraCore then tween(FX.auraCore, 0.15, {BackgroundColor3 = c}) end
	if FX.auraRingStroke then tween(FX.auraRingStroke, 0.15, {Color = c}) end
end
hooks.aura_on = function(v) toast(v and ("Аура " .. accentWord("включена")) or ("Аура " .. accentWord("выключена"))) end
hooks.parts_on = function(v) toast(v and ("Частицы " .. accentWord("включены")) or ("Частицы " .. accentWord("выключены"))) end
hooks.trail_on = function(v) toast(v and ("Трейлы " .. accentWord("включены")) or ("Трейлы " .. accentWord("выключены"))) end
hooks.bloom = function(v) toast("Мягкое свечение " .. accentWord(v and "вкл" or "выкл")) end
hooks.copy_invite = function() toast("Приглашение " .. accentWord("скопировано")) end

local function destroyAll()
	closePopup()
	for _, c in ipairs(conns) do c:Disconnect() end
	gui:Destroy()
end
hooks.unload = function()
	toast("Выгрузка...")
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
	task.delay(0.35, function()
		setOpen(true)
		task.delay(0.4, function()
			toast("Добро пожаловать в " .. accentWord("BurmaldaVisual"))
		end)
	end)
end