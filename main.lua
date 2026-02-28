-- [[ GAMI ULTIMATE KEYSTROKE - FINAL REFINED VERSION ]] --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- 1. 厳選されたキー配置データ (キーボードの物理配置を再現)
local KeyPositions = {
    -- 1段目
    ["Escape"]      = {x = 0, y = 0}, 
    -- 2段目
    ["Tab"]         = {x = 0, y = 1}, ["W"] = {x = 1, y = 1}, ["T"] = {x = 2, y = 1},
    -- 3段目
    ["A"]           = {x = 0, y = 2}, ["S"] = {x = 1, y = 2}, ["D"] = {x = 2, y = 2}, ["F"] = {x = 3, y = 2}, ["G"] = {x = 4, y = 2},
    -- 4段目
    ["LeftShift"]   = {x = 0, y = 3}, ["V"] = {x = 2, y = 3}, ["B"] = {x = 3, y = 3}, ["M"] = {x = 4, y = 3},
    -- 5段目
    ["LeftControl"] = {x = 0, y = 4},
    -- マウス (右側に配置)
    ["LMB"]         = {x = 6, y = 1}, ["RMB"] = {x = 7, y = 1}
}

local Config = {
    ImageID = "rbxassetid://6073763318",
    KeySize = 38,
    Spacing = 5,
    RainbowSpeed = 3
}

-- GUI生成
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "Keystroke"

local mainFrame = Instance.new("Frame", sg)
mainFrame.Position = UDim2.new(0.05, 0, 0.8, 0) -- 左下に配置
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Active = true

-- 背景 & 虹色
local bg = Instance.new("ImageLabel", mainFrame)
bg.Size = UDim2.new(1.1, 0, 1.1, 0)
bg.Position = UDim2.new(-0.05, 0, -0.05, 0)
bg.Image = Config.ImageID
bg.ImageTransparency = 0.5
bg.BackgroundTransparency = 1
bg.ScaleType = Enum.ScaleType.Slice
bg.SliceCenter = Rect.new(100, 100, 100, 100)
bg.ZIndex = 0

local stroke = Instance.new("UIStroke", bg)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- CPSロジック
local leftClicks = {}
local rightClicks = {}

local function getCPS(clickTable)
    local now = tick()
    for i = #clickTable, 1, -1 do
        if now - clickTable[i] > 1 then table.remove(clickTable, i) end
    end
    return #clickTable
end

-- キー生成関数
local activeKeys = {}
local function createKey(name, pos)
    local k = Instance.new("Frame", mainFrame)
    k.Name = name
    k.Size = UDim2.new(0, (name == "LeftShift" or name == "LeftControl") and Config.KeySize * 1.5 or Config.KeySize, 0, Config.KeySize)
    k.Position = UDim2.new(0, pos.x * (Config.KeySize + Config.Spacing), 0, pos.y * (Config.KeySize + Config.Spacing))
    k.BackgroundColor3 = Color3.new(1, 1, 1)
    k.BackgroundTransparency = 0.8
    Instance.new("UICorner", k).CornerRadius = UDim.new(0, 6)

    local txt = Instance.new("TextLabel", k)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 10
    
    if name == "LMB" or name == "RMB" then
        txt.Text = name .. "\n0"
    else
        txt.Text = (name == "LeftControl") and "CTRL" or (name == "LeftShift") and "SFT" or (name == "Escape") and "ESC" or name:sub(1,3):upper()
    end
    
    activeKeys[name] = {frame = k, label = txt}
end

for name, pos in pairs(KeyPositions) do createKey(name, pos) end

-- 毎フレーム更新
RunService.RenderStepped:Connect(function()
    stroke.Color = Color3.fromHSV(tick() % Config.RainbowSpeed / Config.RainbowSpeed, 1, 1)
    
    if activeKeys["LMB"] then activeKeys["LMB"].label.Text = "LMB\n" .. getCPS(leftClicks) end
    if activeKeys["RMB"] then activeKeys["RMB"].label.Text = "RMB\n" .. getCPS(rightClicks) end
end)

-- 入力検知
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local name = input.KeyCode.Name
    if input.UserInputType == Enum.UserInputType.MouseButton1 then name = "LMB" table.insert(leftClicks, tick()) end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then name = "RMB" table.insert(rightClicks, tick()) end
    
    if activeKeys[name] then
        TweenService:Create(activeKeys[name].frame, TweenInfo.new(0.05), {BackgroundTransparency = 0.4}):Play()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local name = input.KeyCode.Name
    if input.UserInputType == Enum.UserInputType.MouseButton1 then name = "LMB" end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then name = "RMB" end
    
    if activeKeys[name] then
        TweenService:Create(activeKeys[name].frame, TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
    end
end)
