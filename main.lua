-- [[ GAMI ULTIMATE KEYSTROKE SYSTEM - GITHUB VERSION ]] --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ==========================================
-- 初期設定
-- ==========================================
local Config = {
    ImageID = "rbxassetid://94143377880990", -- あなたの背景画像
    RainbowSpeed = 3,
    KeySize = 32,
    Padding = 4,
    Transparency = 0.5,
    -- 登録する全てのキー（Q, E, R, Y, U, I など網羅）
    AllKeys = {
        "W","A","S","D","Q","E","R","T","Y","U","I","O","P",
        "F","G","H","J","K","L","Z","X","C","V","B","N","M",
        "Space","LeftControl","LeftShift","Tab","Escape"
    }
}

-- GUI生成
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "Keystroke"

-- メイン枠（200x300に近い比率を維持するための自動リサイズ）
local mainFrame = Instance.new("Frame", sg)
mainFrame.Name = "MainFrame"
mainFrame.Position = UDim2.new(0.8, 0, 0.4, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.AutomaticSize = Enum.AutomaticSize.XY
mainFrame.Active = true

-- 横幅を200pxに制限（これでキーが増えると自動で折り返して複数行になる）
local constraint = Instance.new("UISizeConstraint", mainFrame)
constraint.MaxSize = Vector2.new(200, 9999)

-- 背景画像 & 虹色枠
local bg = Instance.new("ImageLabel", mainFrame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Image = Config.ImageID
bg.ImageTransparency = Config.Transparency
bg.BackgroundTransparency = 1
bg.ScaleType = Enum.ScaleType.Slice
bg.SliceCenter = Rect.new(100, 100, 100, 100)
bg.ZIndex = 0

local stroke = Instance.new("UIStroke", bg)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- レイアウト（グリッド形式）
local layout = Instance.new("UIGridLayout", mainFrame)
layout.CellSize = UDim2.new(0, Config.KeySize, 0, Config.KeySize)
layout.CellPadding = UDim2.new(0, Config.Padding, 0, Config.Padding)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- ==========================================
-- 設定メニュー（Pキーで開く）
-- ==========================================
local menu = Instance.new("Frame", sg)
menu.Name = "ConfigMenu"
menu.Size = UDim2.new(0, 250, 0, 350)
menu.Position = UDim2.new(0.5, -125, 0.5, -175)
menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menu.Visible = false
Instance.new("UICorner", menu)

local title = Instance.new("TextLabel", menu)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "SETTINGS [P] - DRAG TO MOVE"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold

local scroll = Instance.new("ScrollingFrame", menu)
scroll.Size = UDim2.new(0.9, 0, 0.8, 0)
scroll.Position = UDim2.new(0.05, 0, 0.15, 0)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
scroll.ScrollBarThickness = 2
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

-- ==========================================
-- キー生成とロジック
-- ==========================================
local activeKeys = {}
local keyVisible = {}

local function createKey(name)
    local k = Instance.new("TextLabel", mainFrame)
    k.Name = name
    k.Text = name:sub(1,3):upper()
    k.Size = UDim2.new(0, Config.KeySize, 0, Config.KeySize)
    k.BackgroundColor3 = Color3.new(1, 1, 1)
    k.BackgroundTransparency = 0.8
    k.TextColor3 = Color3.new(1, 1, 1)
    k.Font = Enum.Font.GothamBold
    k.TextSize = 10
    k.ZIndex = 2
    Instance.new("UICorner", k).CornerRadius = UDim.new(0, 4)
    
    activeKeys[name] = k
    keyVisible[name] = (name == "W" or name == "A" or name == "S" or name == "D") -- WASDのみ初期ON
    k.Visible = keyVisible[name]

    -- メニュー用トグル
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = "Toggle Key: " .. name
    btn.BackgroundColor3 = k.Visible and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        keyVisible[name] = not keyVisible[name]
        k.Visible = keyVisible[name]
        btn.BackgroundColor3 = keyVisible[name] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
    end)
end

for _, name in pairs(Config.AllKeys) do createKey(name) end

-- 虹色更新
RunService.RenderStepped:Connect(function()
    local hue = tick() % Config.RainbowSpeed / Config.RainbowSpeed
    stroke.Color = Color3.fromHSV(hue, 1, 1)
end)

-- 入力反応
UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.P then
        menu.Visible = not menu.Visible
        bg.ImageTransparency = menu.Visible and 0.2 or Config.Transparency
    end
    if gpe then return end
    local name = input.KeyCode.Name
    if activeKeys[name] then
        TweenService:Create(activeKeys[name], TweenInfo.new(0.05), {BackgroundTransparency = 0.4}):Play()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local name = input.KeyCode.Name
    if activeKeys[name] then
        TweenService:Create(activeKeys[name], TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
    end
end)

-- 移動機能
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if menu.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
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

print("--- FULL GAMI EDITION LOADED ---")
