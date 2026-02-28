-- [[ GAMI ULTIMATE KEYSTROKE - HYPER MOUSE & RAINBOW EDITION ]] --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- 1. 物理配置データ（指定を完璧に反映）
local KeyPositions = {
    -- 1段目: ESCを1つ右へ
    ["Escape"]      = {x = 1.3, y = 0, w = 1.2, h = 1},
    -- 2段目: Tabの横にQ、W列を右にシフト
    ["Tab"]         = {x = 0, y = 1.2, w = 1.2, h = 1}, 
    ["Q"]           = {x = 1.3, y = 1.2, w = 1, h = 1}, 
    ["W"]           = {x = 2.4, y = 1.2, w = 1, h = 1}, 
    ["E"]           = {x = 3.5, y = 1.2, w = 1, h = 1}, 
    ["R"]           = {x = 4.6, y = 1.2, w = 1, h = 1}, 
    ["T"]           = {x = 5.7, y = 1.2, w = 1, h = 1},
    -- 3段目: ホーム行
    ["LeftShift"]   = {x = 0, y = 2.4, w = 1.5, h = 1}, 
    ["A"]           = {x = 1.6, y = 2.4, w = 1, h = 1}, 
    ["S"]           = {x = 2.7, y = 2.4, w = 1, h = 1}, 
    ["D"]           = {x = 3.8, y = 2.4, w = 1, h = 1}, 
    ["F"]           = {x = 4.9, y = 2.4, w = 1, h = 1}, 
    ["G"]           = {x = 6, y = 2.4, w = 1, h = 1},
    -- 4段目
    ["LeftControl"] = {x = 0, y = 3.6, w = 1.5, h = 1}, 
    ["C"]           = {x = 1.6, y = 3.6, w = 1, h = 1}, 
    ["V"]           = {x = 2.7, y = 3.6, w = 1, h = 1}, 
    ["B"]           = {x = 3.8, y = 3.6, w = 1, h = 1}, 
    ["M"]           = {x = 4.9, y = 3.6, w = 1, h = 1},
    -- 5段目: スペース
    ["Space"]       = {x = 1.6, y = 4.8, w = 4.3, h = 0.8},
    -- マウス: 本間にデカく配置（横2.5倍、縦1.5倍）
    ["LMB"]         = {x = 7.5, y = 1.2, w = 2.5, h = 1.5}, 
    ["RMB"]         = {x = 10.2, y = 1.2, w = 2.5, h = 1.5}
}

local Config = {
    BaseImage = "rbxassetid://87263696220840",
    KeySize = 35,
    Spacing = 6,
    RainbowSpeed = 3
}

-- GUI構築
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "Keystroke"

local mainFrame = Instance.new("Frame", sg)
mainFrame.Position = UDim2.new(0.02, 0, 0.65, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.new(0, 650, 0, 300)
mainFrame.Active = true

-- 背景画像（全体）
local bgImg = Instance.new("ImageLabel", mainFrame)
bgImg.Size = UDim2.new(1, 40, 1, 40)
bgImg.Position = UDim2.new(0, -20, 0, -20)
bgImg.Image = Config.BaseImage
bgImg.ImageTransparency = 0.6
bgImg.BackgroundTransparency = 1
bgImg.ScaleType = Enum.ScaleType.Slice
bgImg.SliceCenter = Rect.new(100, 100, 100, 100)
bgImg.ZIndex = 0

-- CPS用
local leftClicks, rightClicks = {}, {}
local function getCPS(clicks)
    local now = tick()
    for i = #clicks, 1, -1 do if now - clicks[i] > 1 then table.remove(clicks, i) end end
    return #clicks
end

-- キー個別構築
local activeKeys, strokes = {}, {}

for name, pos in pairs(KeyPositions) do
    local k = Instance.new("Frame", mainFrame)
    k.Name = name
    k.Size = UDim2.new(0, pos.w * Config.KeySize, 0, pos.h * Config.KeySize)
    k.Position = UDim2.new(0, pos.x * (Config.KeySize + Config.Spacing), 0, pos.y * (Config.KeySize + Config.Spacing))
    k.BackgroundColor3 = Color3.new(0, 0, 0)
    k.BackgroundTransparency = 0.4
    k.ZIndex = 2
    Instance.new("UICorner", k).CornerRadius = UDim.new(0, 6)

    local s = Instance.new("UIStroke", k)
    s.Thickness = 2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    table.insert(strokes, s)

    local txt = Instance.new("TextLabel", k)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = (name == "LMB" or name == "RMB") and 14 or 10
    txt.ZIndex = 3
    
    local display = {["LeftControl"]="CTRL", ["LeftShift"]="SHIFT", ["Space"]="SPC", ["Escape"]="ESC"}
    txt.Text = display[name] or name:upper()
    activeKeys[name] = {frame = k, label = txt}
end

-- 虹色 & CPS
RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % Config.RainbowSpeed / Config.RainbowSpeed, 0.8, 1)
    for _, s in pairs(strokes) do s.Color = color end
    if activeKeys["LMB"] then activeKeys["LMB"].label.Text = "LMB\n" .. getCPS(leftClicks) .. " CPS" end
    if activeKeys["RMB"] then activeKeys["RMB"].label.Text = "RMB\n" .. getCPS(rightClicks) .. " CPS" end
end)

-- 入力反応
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local name = input.KeyCode.Name
    if input.UserInputType == Enum.UserInputType.MouseButton1 then name = "LMB" table.insert(leftClicks, tick()) end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then name = "RMB" table.insert(rightClicks, tick()) end
    if activeKeys[name] then
        TweenService:Create(activeKeys[name].frame, TweenInfo.new(0.05), {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(50,50,50)}):Play()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local name = input.KeyCode.Name
    if input.UserInputType == Enum.UserInputType.MouseButton1 then name = "LMB" end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then name = "RMB" end
    if activeKeys[name] then
        TweenService:Create(activeKeys[name].frame, TweenInfo.new(0.1), {BackgroundTransparency = 0.4, BackgroundColor3 = Color3.new(0, 0, 0)}):Play()
    end
end)

-- Pキー移動
local moveMode = false
UserInputService.InputBegan:Connect(function(input) if input.KeyCode == Enum.KeyCode.P then moveMode = not moveMode end end)
mainFrame.InputBegan:Connect(function(input)
    if moveMode and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local dragStart, startPos = input.Position, mainFrame.Position
        local moveConn
        moveConn = UserInputService.InputChanged:Connect(function(move)
            if move.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = move.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(ended) if ended.UserInputType == Enum.UserInputType.MouseButton1 then moveConn:Disconnect() end end)
    end
end)
