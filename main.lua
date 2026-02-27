-- [[ GEMINI ULTIMATE KEYSTROKE SYSTEM V4 ]] --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Config = {
    ImageID = "rbxassetid://6073763318",
    RainbowSpeed = 3,
    KeySize = 35,
    DefaultKeys = {"W", "A", "S", "D", "Space", "LeftControl", "LeftShift", "F", "G", "T", "B", "V", "M", "Escape", "Tab"}
}

-- GUI生成
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "Gemini_Ultimate_Keystroke"

-- メインフレーム (中身に合わせて自動リサイズ)
local mainFrame = Instance.new("Frame", sg)
mainFrame.Name = "MainFrame"
mainFrame.Position = UDim2.new(0.85, 0, 0.4, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.AutomaticSize = Enum.AutomaticSize.XY
mainFrame.Active = true

-- 背景画像 & 虹色枠
local bg = Instance.new("ImageLabel", mainFrame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Image = Config.ImageID
bg.ImageTransparency = 0.5
bg.BackgroundTransparency = 1
bg.ScaleType = Enum.ScaleType.Slice
bg.SliceCenter = Rect.new(100, 100, 100, 100)

local stroke = Instance.new("UIStroke", bg)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- レイアウト
local layout = Instance.new("UIGridLayout", mainFrame)
layout.CellSize = UDim2.new(0, Config.KeySize, 0, Config.KeySize)
layout.CellPadding = UDim2.new(0, 5, 0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ==========================================
-- 設定メニューUI
-- ==========================================
local menu = Instance.new("Frame", sg)
menu.Name = "ConfigMenu"
menu.Size = UDim2.new(0, 300, 0, 400)
menu.Position = UDim2.new(0.5, -150, 0.5, -200)
menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menu.Visible = false
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", menu)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "SYSTEM SETTINGS [P]"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold

local scroll = Instance.new("ScrollingFrame", menu)
scroll.Size = UDim2.new(0.9, 0, 0.8, 0)
scroll.Position = UDim2.new(0.05, 0, 0.15, 0)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
scroll.ScrollBarThickness = 2

local menuLayout = Instance.new("UIListLayout", scroll)
menuLayout.Padding = UDim.new(0, 5)

-- ==========================================
-- キー管理システム
-- ==========================================
local activeKeys = {}
local keyStates = {}

local function toggleKey(name)
    keyStates[name] = not keyStates[name]
    if keyStates[name] then
        local k = Instance.new("TextLabel", mainFrame)
        k.Name = name
        k.Text = name:sub(1,3)
        k.Size = UDim2.new(0, Config.KeySize, 0, Config.KeySize)
        k.BackgroundColor3 = Color3.new(1,1,1)
        k.BackgroundTransparency = 0.8
        k.TextColor3 = Color3.new(1,1,1)
        k.Font = Enum.Font.GothamMedium
        k.TextSize = 10
        Instance.new("UICorner", k).CornerRadius = UDim.new(0, 5)
        activeKeys[name] = k
    else
        if activeKeys[name] then
            activeKeys[name]:Destroy()
            activeKeys[name] = nil
        end
    end
end

-- メニューにトグルボタンを追加する関数
local function addMenuToggle(name)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = "Toggle: " .. name
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        toggleKey(name)
        btn.BackgroundColor3 = keyStates[name] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
end

-- 初期化
for _, kName in pairs(Config.DefaultKeys) do
    keyStates[kName] = false
    toggleKey(kName)
    addMenuToggle(kName)
end

-- ==========================================
-- ドラッグ & 統計 & 虹色
-- ==========================================
local dragging, dragInput, dragStart, startPos
local clickTimes = {}

mainFrame.InputBegan:Connect(function(input)
    if menu.Visible and (input.UserInputType == Enum.UserInputType.MouseButton1) then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.P then
        menu.Visible = not menu.Visible
        bg.ImageTransparency = menu.Visible and 0.2 or 0.5
    end
    if gpe then return end
    local name = input.KeyCode.Name
    if activeKeys[name] then
        TweenService:Create(activeKeys[name], TweenInfo.new(0.1), {BackgroundTransparency = 0.4}):Play()
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then table.insert(clickTimes, tick()) end
end)

UserInputService.InputEnded:Connect(function(input)
    local name = input.KeyCode.Name
    if activeKeys[name] then
        TweenService:Create(activeKeys[name], TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
    end
end)

RunService.RenderStepped:Connect(function()
    local hue = tick() % Config.RainbowSpeed / Config.RainbowSpeed
    stroke.Color = Color3.fromHSV(hue, 1, 1)
    
    local now = tick()
    for i = #clickTimes, 1, -1 do
        if now - clickTimes[i] > 1 then table.remove(clickTimes, i) end
    end
end)

print("ULTIMATE KEYSTROKE LOADED. PRESS 'P' TO CONFIGURE.")
