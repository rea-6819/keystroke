-- [[ GAMI INTELLIGENT KEYSTROKE - GITHUB VERSION ]] --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- 1. キーの「優先順位」を定義（この順番通りに並ぶ）
local KeyOrder = {
    "Escape", "Tab", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
    "A", "S", "D", "F", "G", "H", "J", "K", "L",
    "LeftShift", "Z", "X", "C", "V", "B", "N", "M",
    "LeftControl", "Space"
}

local Config = {
    ImageID = "rbxassetid://94143377880990",
    KeySize = 35,
    Spacing = 5,
    RainbowSpeed = 3,
    MaxWidth = 220 -- 200x300に近い幅。これを超えると自動で次の行へ
}

-- GUI生成
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "Keystroke"

local mainFrame = Instance.new("Frame", sg)
mainFrame.Position = UDim2.new(0.8, 0, 0.4, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.AutomaticSize = Enum.AutomaticSize.XY
mainFrame.Active = true

-- 背景 & 虹色
local bg = Instance.new("ImageLabel", mainFrame)
bg.Size = UDim2.new(1, 10, 1, 10)
bg.Position = UDim2.new(0, -5, 0, -5)
bg.Image = Config.ImageID
bg.ImageTransparency = 0.5
bg.BackgroundTransparency = 1
bg.ScaleType = Enum.ScaleType.Slice
bg.SliceCenter = Rect.new(100, 100, 100, 100)
bg.ZIndex = 0

local stroke = Instance.new("UIStroke", bg)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- レイアウト（UIGridLayoutを賢く使う）
local layout = Instance.new("UIGridLayout", mainFrame)
layout.CellSize = UDim2.new(0, Config.KeySize, 0, Config.KeySize)
layout.CellPadding = UDim2.new(0, Config.Spacing, 0, Config.Spacing)
layout.SortOrder = Enum.SortOrder.LayoutOrder -- LayoutOrder順に並べる

-- 横幅制限（これで「一列」を防ぐ）
local constraint = Instance.new("UISizeConstraint", mainFrame)
constraint.MaxSize = Vector2.new(Config.MaxWidth, 9999)

-- 設定メニュー
local menu = Instance.new("Frame", sg)
menu.Size = UDim2.new(0, 250, 0, 350)
menu.Position = UDim2.new(0.5, -125, 0.5, -175)
menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menu.Visible = false
Instance.new("UICorner", menu)

local scroll = Instance.new("ScrollingFrame", menu)
scroll.Size = UDim2.new(0.9, 0, 0.8, 0)
scroll.Position = UDim2.new(0.05, 0, 0.15, 0)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 3, 0)
scroll.ScrollBarThickness = 2
Instance.new("UIListLayout", scroll)

-- ==========================================
-- キー生成ロジック
-- ==========================================
local activeKeys = {}
local keyStates = {}

for i, name in ipairs(KeyOrder) do
    local k = Instance.new("TextLabel", mainFrame)
    k.Name = name
    k.LayoutOrder = i -- ここが重要！KeyOrderの順番を強制する
    k.Text = (name == "LeftControl") and "CTRL" or (name == "LeftShift") and "SFT" or (name == "Space") and "SPC" or name:sub(1,3):upper()
    k.Size = UDim2.new(0, Config.KeySize, 0, Config.KeySize)
    k.BackgroundColor3 = Color3.new(1, 1, 1)
    k.BackgroundTransparency = 0.8
    k.TextColor3 = Color3.new(1, 1, 1)
    k.Font = Enum.Font.GothamBold
    k.TextSize = 10
    k.ZIndex = 2
    Instance.new("UICorner", k).CornerRadius = UDim.new(0, 4)
    
    activeKeys[name] = k
    -- 初期表示設定 (WASD, Space, Tab, Esc など)
    local isDefault = string.find("WASD Space Tab Escape", name)
    k.Visible = isDefault ~= nil
    
    -- メニューボタン
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = "Show: " .. name
    btn.BackgroundColor3 = k.Visible and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        k.Visible = not k.Visible
        btn.BackgroundColor3 = k.Visible and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
    end)
end

-- 虹色 & 入力反応
RunService.RenderStepped:Connect(function()
    stroke.Color = Color3.fromHSV(tick() % Config.RainbowSpeed / Config.RainbowSpeed, 1, 1)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.P then menu.Visible = not menu.Visible end
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

-- 移動機能 (Pメニュー時のみ)
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if menu.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

print("--- INTELLIGENT LAYOUT LOADED ---")
