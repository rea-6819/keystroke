local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- ==========================================
-- カスタム設定
-- ==========================================
local Config = {
    ImageID = "rbxassetid://6073763318", -- 200x300で作った画像でも自動で合います
    RainbowSpeed = 3,
    KeySize = 32, -- ★ここを小さくしました
    Padding = 4,  -- キー同士の間隔
}

-- GUI構築
local sg = Instance.new("ScreenGui", CoreGui)
local mainFrame = Instance.new("Frame", sg)
mainFrame.Position = UDim2.new(0.85, 0, 0.5, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.AutomaticSize = Enum.AutomaticSize.XY -- 中身に合わせて伸びる

-- 背景画像
local bg = Instance.new("ImageLabel", mainFrame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Image = Config.ImageID
bg.ImageTransparency = 0.5
bg.BackgroundTransparency = 1
bg.ScaleType = Enum.ScaleType.Slice
bg.SliceCenter = Rect.new(100, 100, 100, 100) -- 角が歪まない設定

-- 虹色枠
local stroke = Instance.new("UIStroke", bg)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- レイアウト（自動整列）
local layout = Instance.new("UIGridLayout", mainFrame)
layout.CellSize = UDim2.new(0, Config.KeySize, 0, Config.KeySize)
layout.CellPadding = UDim2.new(0, Config.Padding, 0, Config.Padding)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- FPS/CPS 表示（枠の下に固定）
local stats = Instance.new("TextLabel", sg)
stats.Size = UDim2.new(0, 150, 0, 30)
stats.BackgroundTransparency = 1
stats.TextColor3 = Color3.new(1, 1, 1)
stats.Font = Enum.Font.Code
stats.TextSize = 12

-- ==========================================
-- 機能：キー追加と状態管理
-- ==========================================
local activeKeys = {}

local function createKey(name)
    local btn = Instance.new("TextLabel", mainFrame)
    btn.Name = name
    btn.Text = name
    btn.Size = UDim2.new(0, Config.KeySize, 0, Config.KeySize)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.8
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 10
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    
    activeKeys[name] = btn
end

-- 初期キーセット
local defaultKeys = {"W", "A", "S", "D", "F", "G", "T", "B", "V", "M", "Esc", "Tab", "Ctrl", "Space"}
for _, k in pairs(defaultKeys) do createKey(k) end

-- 虹色 & 統計更新
RunService.RenderStepped:Connect(function(dt)
    local hue = tick() % Config.RainbowSpeed / Config.RainbowSpeed
    stroke.Color = Color3.fromHSV(hue, 1, 1)
    
    stats.Position = mainFrame.Position + UDim2.new(0, 0, 0, mainFrame.AbsoluteSize.Y + 5)
    stats.Text = string.format("FPS: %d", math.floor(1/dt))
end)

-- 入力反応
UserInputService.InputBegan:Connect(function(input, gpe)
    local keyName = input.KeyCode.Name
    if activeKeys[keyName] then
        activeKeys[keyName].BackgroundTransparency = 0.4
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local keyName = input.KeyCode.Name
    if activeKeys[keyName] then
        activeKeys[keyName].BackgroundTransparency = 0.8
    end
end)

print("Compact Keystrokes Loaded! Keys are small and elegant.")
