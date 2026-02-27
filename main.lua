-- [[ GAMI FINAL COMPLETED SCRIPT ]] --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ==========================================
-- 設定（ここを書き換えるだけでカスタム完了）
-- ==========================================
local Config = {
    ImageID = "rbxassetid://6073763318", -- 200x300の背景画像ID
    RainbowSpeed = 3,                    -- 虹色が一周する秒数
    KeySize = 32,                        -- キー1つの大きさ（小さめでプロ仕様）
    Padding = 4,                         -- キー同士の隙間
    Transparency = 0.5,                  -- 背景画像の透明度
}

-- 初期キーリスト
local KeysToDisplay = {
    "W", "A", "S", "D", "F", "G", "T", "B", "V", "M", 
    "Escape", "Tab", "LeftControl", "Space"
}

-- ==========================================
-- GUI構築
-- ==========================================
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "Final_Keystroke_System"

-- メイン枠（自動リサイズ）
local mainFrame = Instance.new("Frame", sg)
mainFrame.Position = UDim2.new(0.85, 0, 0.4, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.AutomaticSize = Enum.AutomaticSize.XY
mainFrame.Active = true

-- 背景画像（画像背景カスタム）
local bg = Instance.new("ImageLabel", mainFrame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Image = Config.ImageID
bg.ImageTransparency = Config.Transparency
bg.BackgroundTransparency = 1
bg.ScaleType = Enum.ScaleType.Slice
bg.SliceCenter = Rect.new(100, 100, 100, 100) -- 200x300画像が綺麗に伸びる設定

-- 虹色枠（RGB）
local stroke = Instance.new("UIStroke", bg)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- レイアウト設定
local layout = Instance.new("UIGridLayout", mainFrame)
layout.CellSize = UDim2.new(0, Config.KeySize, 0, Config.KeySize)
layout.CellPadding = UDim2.new(0, Config.Padding, 0, Config.Padding)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ==========================================
-- 設定メニューUI
-- ==========================================
local menu = Instance.new("Frame", sg)
menu.Size = UDim2.new(0, 250, 0, 350)
menu.Position = UDim2.new(0.5, -125, 0.5, -175)
menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menu.Visible = false
Instance.new("UICorner", menu)

local title = Instance.new("TextLabel", menu)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "CONFIG: DRAG TO MOVE [P]"
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
-- ロジック実行
-- ==========================================
local activeKeys = {}
local keyStates = {}

local function createKey(name)
    keyStates[name] = true
    local k = Instance.new("TextLabel", mainFrame)
    k.Name = name
    k.Text = name:sub(1,3):upper()
    k.Size = UDim2.new(0, Config.KeySize, 0, Config.KeySize)
    k.BackgroundColor3 = Color3.new(1, 1, 1)
    k.BackgroundTransparency = 0.8
    k.TextColor3 = Color3.new(1, 1, 1)
    k.Font = Enum.Font.GothamBold
    k.TextSize = 10
    Instance.new("UICorner", k).CornerRadius = UDim.new(0, 4)
    activeKeys[name] = k
    
    -- メニュー用ボタン
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = "Show: " .. name
    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        keyStates[name] = not keyStates[name]
        k.Visible = keyStates[name]
        btn.BackgroundColor3 = keyStates[name] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end)
end

for _, k in pairs(KeysToDisplay) do createKey(k) end

-- 虹色 & 更新
RunService.RenderStepped:Connect(function()
    local hue = tick() % Config.RainbowSpeed / Config.RainbowSpeed
    stroke.Color = Color3.fromHSV(hue, 1, 1)
end)

-- 入力反応 (GitHubロジック準拠)
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

-- ドラッグ移動
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

print("--- FULL VERSION LOADED ---")
