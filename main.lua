-- [[ GAMI FINAL COMPLETED SCRIPT - WITH SPC & CPS ]] --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- 1. 指定されたキーのみを物理配置（座標）に基づき配置
-- SPCは長く、LMB/RMBは右側にCPS付きで配置
local KeyPositions = {
    ["Escape"]      = {x = 0, y = 0, w = 1},
    ["Tab"]         = {x = 0, y = 1, w = 1.2}, ["W"] = {x = 1.3, y = 1, w = 1}, ["E"] = {x = 2.4, y = 1, w = 1}, ["R"] = {x = 3.5, y = 1, w = 1}, ["T"] = {x = 4.6, y = 1, w = 1},
    ["LeftShift"]   = {x = 0, y = 2, w = 1.5}, ["A"] = {x = 1.6, y = 2, w = 1}, ["S"] = {x = 2.7, y = 2, w = 1}, ["D"] = {x = 3.8, y = 2, w = 1}, ["F"] = {x = 4.9, y = 2, w = 1}, ["G"] = {x = 6, y = 2, w = 1},
    ["LeftControl"] = {x = 0, y = 3, w = 1.5}, ["C"] = {x = 1.6, y = 3, w = 1}, ["V"] = {x = 2.7, y = 3, w = 1}, ["B"] = {x = 3.8, y = 3, w = 1}, ["M"] = {x = 4.9, y = 3, w = 1},
    ["Space"]       = {x = 1.6, y = 4, w = 4.3}, -- スペースキーを長く配置
    -- マウス & CPS
    ["LMB"]         = {x = 7.5, y = 1, w = 1.2}, ["RMB"] = {x = 8.8, y = 1, w = 1.2}
}

local Config = {
    ImageID = "rbxassetid://6073763318",
    KeySize = 35,
    Spacing = 5,
    RainbowSpeed = 3
}

-- GUI構築
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "Keystroke"

local mainFrame = Instance.new("Frame", sg)
mainFrame.Position = UDim2.new(0.02, 0, 0.7, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.new(0, 480, 0, 230)
mainFrame.Active = true

-- 背景 & 虹色枠
local bg = Instance.new("ImageLabel", mainFrame)
bg.Size = UDim2.new(1, 20, 1, 20)
bg.Position = UDim2.new(0, -10, 0, -10)
bg.Image = Config.ImageID
bg.ImageTransparency = 0.5
bg.BackgroundTransparency = 1
bg.ScaleType = Enum.ScaleType.Slice
bg.SliceCenter = Rect.new(100, 100, 100, 100)
bg.ZIndex = 0

local stroke = Instance.new("UIStroke", bg)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- CPS管理
local leftClicks = {}
local rightClicks = {}
local function getCPS(clickTable)
    local now = tick()
    for i = #clickTable, 1, -1 do
        if now - clickTable[i] > 1 then table.remove(clickTable, i) end
    end
    return #clickTable
end

-- キー生成
local activeKeys = {}
for name, pos in pairs(KeyPositions) do
    local k = Instance.new("Frame", mainFrame)
    k.Name = name
    k.Size = UDim2.new(0, pos.w * Config.KeySize, 0, Config.KeySize)
    k.Position = UDim2.new(0, pos.x * (Config.KeySize + Config.Spacing), 0, pos.y * (Config.KeySize + Config.Spacing))
    k.BackgroundColor3 = Color3.new(1, 1, 1)
    k.BackgroundTransparency = 0.8
    Instance.new("UICorner", k).CornerRadius = UDim.new(0, 4)

    local txt = Instance.new("TextLabel", k)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 9
    
    if name == "LMB" or name == "RMB" then
        txt.Text = name .. "\n0"
    else
        txt.Text = (name == "LeftControl") and "CTRL" or (name == "LeftShift") and "SHIFT" or (name == "Escape") and "ESC" or (name == "Space") and "SPC" or name:upper()
    end
    activeKeys[name] = {frame = k, label = txt}
end

-- ループ更新
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

-- Pキーでドラッグ移動モードの切り替え
local moveMode = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then 
        moveMode = not moveMode
        bg.ImageTransparency = moveMode and 0.2 or 0.5
    end
end)

mainFrame.InputBegan:Connect(function(input)
    if moveMode and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local dragStart = input.Position
        local startPos = mainFrame.Position
        local moveConn
        moveConn = UserInputService.InputChanged:Connect(function(move)
            if move.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = move.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(ended)
            if ended.UserInputType == Enum.UserInputType.MouseButton1 then moveConn:Disconnect() end
        end)
    end
end)
