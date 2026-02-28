-- [[ GAMI ULTIMATE VISIBILITY - INVERTED COLOR EDITION ]] --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- 1. コンパクトな物理配置データ
local KeyPositions = {
    ["Escape"]      = {x = 1.3, y = 0, w = 1.2, h = 0.9},
    ["Tab"]         = {x = 0, y = 1.0, w = 1.2, h = 1}, 
    ["Q"]           = {x = 1.3, y = 1.0, w = 1, h = 1}, 
    ["W"]           = {x = 2.4, y = 1.0, w = 1, h = 1}, 
    ["E"]           = {x = 3.5, y = 1.0, w = 1, h = 1}, 
    ["R"]           = {x = 4.6, y = 1.0, w = 1, h = 1}, 
    ["T"]           = {x = 5.7, y = 1.0, w = 1, h = 1},
    
    ["LeftShift"]   = {x = 0, y = 2.1, w = 1.5, h = 1}, 
    ["A"]           = {x = 1.6, y = 2.1, w = 1, h = 1}, 
    ["S"]           = {x = 2.7, y = 2.1, w = 1, h = 1}, 
    ["D"]           = {x = 3.8, y = 2.1, w = 1, h = 1}, 
    ["F"]           = {x = 4.9, y = 2.1, w = 1, h = 1}, 
    ["G"]           = {x = 6.0, y = 2.1, w = 1, h = 1},

    ["LeftControl"] = {x = 0, y = 3.2, w = 1.5, h = 1}, 
    ["C"]           = {x = 1.6, y = 3.2, w = 1, h = 1}, 
    ["V"]           = {x = 2.7, y = 3.2, w = 1, h = 1}, 
    ["B"]           = {x = 3.8, y = 3.2, w = 1, h = 1}, 
    ["M"]           = {x = 4.9, y = 3.2, w = 1, h = 1},
    
    ["Space"]       = {x = 1.6, y = 4.3, w = 4.3, h = 0.8},

    ["LMB"]         = {x = 7.2, y = 1.0, w = 1.8, h = 1.5}, 
    ["RMB"]         = {x = 7.2, y = 2.7, w = 1.8, h = 1.5}
}

local Config = {
    BaseImage = "rbxassetid://6073763318",
    KeySize = 34,
    Spacing = 5,
    RainbowSpeed = 3
}

-- GUI構築
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "Keystroke"

local mainFrame = Instance.new("Frame", sg)
mainFrame.Position = UDim2.new(0.5, -150, 0.75, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.new(0, 350, 0, 220)
mainFrame.Active = true

-- 背景画像
local bgImg = Instance.new("ImageLabel", mainFrame)
bgImg.Size = UDim2.new(1, 40, 1, 40)
bgImg.Position = UDim2.new(0, -20, 0, -20)
bgImg.Image = Config.BaseImage
bgImg.ImageTransparency = 0.7
bgImg.BackgroundTransparency = 1
bgImg.ScaleType = Enum.ScaleType.Slice
bgImg.SliceCenter = Rect.new(100, 100, 100, 100)
bgImg.ZIndex = 0

-- CPSロジック
local clicks = {LMB = {}, RMB = {}}
local function updateCPS(cTable)
    local now = tick()
    for i = #cTable, 1, -1 do if now - cTable[i] > 1 then table.remove(cTable, i) end end
    return #cTable
end

-- キー個別構築
local activeKeys, strokes = {}, {}
for name, pos in pairs(KeyPositions) do
    local k = Instance.new("Frame", mainFrame)
    k.Name = name
    k.Size = UDim2.new(0, pos.w * Config.KeySize, 0, pos.h * Config.KeySize)
    k.Position = UDim2.new(0, pos.x * (Config.KeySize + Config.Spacing), 0, pos.y * (Config.KeySize + Config.Spacing))
    k.BackgroundColor3 = Color3.new(0, 0, 0)
    k.BackgroundTransparency = 0.5
    k.ZIndex = 2
    Instance.new("UICorner", k).CornerRadius = UDim.new(0, 5)

    local s = Instance.new("UIStroke", k)
    s.Thickness = 1.8
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    table.insert(strokes, s)

    local txt = Instance.new("TextLabel", k)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = (name == "LMB" or name == "RMB") and 12 or 9
    txt.ZIndex = 3
    
    local dNames = {["LeftControl"]="CTRL", ["LeftShift"]="SFT", ["Space"]="SPC", ["Escape"]="ESC"}
    txt.Text = dNames[name] or name:upper()
    activeKeys[name] = {frame = k, label = txt}
end

-- ループ（虹色 & CPS）
RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % Config.RainbowSpeed / Config.RainbowSpeed, 0.7, 1)
    for _, s in pairs(strokes) do s.Color = color end
    if activeKeys.LMB then activeKeys.LMB.label.Text = "LMB\n" .. updateCPS(clicks.LMB) end
    if activeKeys.RMB then activeKeys.RMB.label.Text = "RMB\n" .. updateCPS(clicks.RMB) end
end)

-- 入力アクション
local function pressEffect(name, isPressed)
    local targetKey = activeKeys[name]
    if targetKey then
        if isPressed then
            -- 押したとき：背景を白、文字を黒に反転
            TweenService:Create(targetKey.frame, TweenInfo.new(0.05), {BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.1}):Play()
            targetKey.label.TextColor3 = Color3.new(0, 0, 0)
        else
            -- 離したとき：元の黒半透明に戻す
            TweenService:Create(targetKey.frame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5}):Play()
            targetKey.label.TextColor3 = Color3.new(1, 1, 1)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local name = input.KeyCode.Name
    if input.UserInputType == Enum.UserInputType.MouseButton1 then name = "LMB" table.insert(clicks.LMB, tick()) end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then name = "RMB" table.insert(clicks.RMB, tick()) end
    pressEffect(name, true)
end)

UserInputService.InputEnded:Connect(function(input)
    local name = input.KeyCode.Name
    if input.UserInputType == Enum.UserInputType.MouseButton1 then name = "LMB" end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then name = "RMB" end
    pressEffect(name, false)
end)

-- Pキー移動
local mMode = false
UserInputService.InputBegan:Connect(function(input) if input.KeyCode == Enum.KeyCode.P then mMode = not mMode end end)
mainFrame.InputBegan:Connect(function(input)
    if mMode and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local dS, sP = input.Position, mainFrame.Position
        local conn; conn = UserInputService.InputChanged:Connect(function(move)
            if move.UserInputType == Enum.UserInputType.MouseMovement then
                local del = move.Position - dS
                mainFrame.Position = UDim2.new(sP.X.Scale, sP.X.Offset + del.X, sP.Y.Scale, sP.Y.Offset + del.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(e) if e.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end end)
    end
end)
