
-- 防重複載入與唯一命名空間
getgenv().ZhenNaiScript = getgenv().ZhenNaiScript or {}
local ZNS = getgenv().ZhenNaiScript
if ZNS.__LOADED then
    if ZNS._CLEANUP then pcall(ZNS._CLEANUP) end
end
ZNS.__LOADED = true

-- Roblox服務
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 初始化設置

local function 初始化設置(settings)
    local default = {
        防甩飛 = false,
        甩飛 = false,
        防虛空 = false,
        ESP = false,
        隱形 = false,
        目標玩家 = nil,
        虛空閾值 = -50,
        安全高度 = 100
    }
    ZNS.settings = ZNS.settings or {}
    settings = settings or {}
    for k, v in pairs(default) do
        if settings[k] == nil then
            ZNS.settings[k] = v
        else
            ZNS.settings[k] = settings[k]
        end
    end
end

-- 創建GUI
local function 創建GUI()
    -- 清理舊GUI
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, v in pairs(pg:GetChildren()) do
                if v:IsA("ScreenGui") and v.Name:find("珍奶腳本_") then v:Destroy() end
            end
        end
    end)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "珍奶腳本_" .. math.random(1000, 9999)
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    -- 半透明+發光主框
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
    MainFrame.Size = UDim2.new(0, 270, 0, 370)
    MainFrame.Active = true
    MainFrame.Draggable = true
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 18)
    frameCorner.Parent = MainFrame
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Thickness = 2
    frameStroke.Color = Color3.fromRGB(0, 255, 255)
    frameStroke.Transparency = 0.2
    frameStroke.Parent = MainFrame

    -- 標題加底光
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = MainFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.Size = UDim2.new(1, 0, 0, 38)
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.Text = "珍奶腳本 (遠程版)"
    TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    TitleLabel.TextStrokeTransparency = 0.5
    TitleLabel.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
    TitleLabel.TextSize = 22
    local titleGlow = Instance.new("UIStroke")
    titleGlow.Thickness = 1.5
    titleGlow.Color = Color3.fromRGB(0, 255, 255)
    titleGlow.Transparency = 0.3
    titleGlow.Parent = TitleLabel

    -- 科技感按鈕生成器
    local function CreateButton(name, position, callback)
        local Button = Instance.new("TextButton")
        Button.Name = name
        Button.Parent = MainFrame
        Button.BackgroundColor3 = Color3.fromRGB(30, 60, 90)
        Button.BackgroundTransparency = 0.08
        Button.BorderSizePixel = 0
        Button.Position = position
        Button.Size = UDim2.new(1, -20, 0, 36)
        Button.Font = Enum.Font.GothamSemibold
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(0, 255, 255)
        Button.TextStrokeTransparency = 0.7
        Button.TextSize = 16
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 10)
        UICorner.Parent = Button
        local UIStroke = Instance.new("UIStroke")
        UIStroke.Thickness = 1.5
        UIStroke.Color = Color3.fromRGB(0, 255, 255)
        UIStroke.Transparency = 0.3
        UIStroke.Parent = Button
        -- hover效果
        Button.MouseEnter:Connect(function()
            Button.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            UIStroke.Transparency = 0
        end)
        Button.MouseLeave:Connect(function()
            Button.BackgroundColor3 = Color3.fromRGB(30, 60, 90)
            Button.TextColor3 = Color3.fromRGB(0, 255, 255)
            UIStroke.Transparency = 0.3
        end)
        Button.MouseButton1Click:Connect(callback)
        return Button
    end

    local 防甩飛Button = CreateButton("防甩飛: 關閉", UDim2.new(0, 5, 0, 40), function()
        ZNS.settings.防甩飛 = not ZNS.settings.防甩飛
        防甩飛Button.Text = "防甩飛: " .. (ZNS.settings.防甩飛 and "開啟" or "關閉")
    end)

    local 目標Label = Instance.new("TextLabel")
    目標Label.Parent = MainFrame
    目標Label.BackgroundTransparency = 1
    目標Label.Position = UDim2.new(0, 5, 0, 75)
    目標Label.Size = UDim2.new(1, -10, 0, 20)
    目標Label.Font = Enum.Font.Gotham
    目標Label.Text = "目標: 無"
    目標Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    目標Label.TextSize = 12

    local 目標下拉 = Instance.new("ScrollingFrame")
    目標下拉.Parent = MainFrame
    目標下拉.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    目標下拉.BorderSizePixel = 0
    目標下拉.Position = UDim2.new(0, 5, 0, 100)
    目標下拉.Size = UDim2.new(1, -10, 0, 100)
    目標下拉.CanvasSize = UDim2.new(0, 0, 0, 0)
    目標下拉.ScrollBarThickness = 6
    目標下拉.Visible = false

    local function 更新目標清單()
        目標下拉:ClearAllChildren()
        local layout = Instance.new("UIListLayout")
        layout.Parent = 目標下拉
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        local playerList = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then table.insert(playerList, player) end
        end
        for _, player in pairs(playerList) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.Text = player.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.Parent = 目標下拉
            btn.MouseButton1Click:Connect(function()
                ZNS.settings.目標玩家 = player
                目標Label.Text = "目標: " .. player.Name
                目標下拉.Visible = false
            end)
        end
        目標下拉.CanvasSize = UDim2.new(0, 0, 0, #playerList * 30)
    end

    local 選擇目標Button = CreateButton("選擇目標", UDim2.new(0, 5, 0, 130), function()
        更新目標清單()
        目標下拉.Visible = not 目標下拉.Visible
    end)

    local 甩飛Button = CreateButton("甩飛: 關閉", UDim2.new(0, 5, 0, 170), function()
        if not ZNS.settings.目標玩家 then warn("請先選擇目標!") return end
        ZNS.settings.甩飛 = not ZNS.settings.甩飛
        甩飛Button.Text = "甩飛: " .. (ZNS.settings.甩飛 and "開啟" or "關閉")
    end)

    local 防虛空Button = CreateButton("防虛空: 關閉", UDim2.new(0, 5, 0, 210), function()
        ZNS.settings.防虛空 = not ZNS.settings.防虛空
        防虛空Button.Text = "防虛空: " .. (ZNS.settings.防虛空 and "開啟" or "關閉")
    end)

    local ESPButton = CreateButton("ESP: 關閉", UDim2.new(0, 5, 0, 250), function()
        ZNS.settings.ESP = not ZNS.settings.ESP
        ESPButton.Text = "ESP: " .. (ZNS.settings.ESP and "開啟" or "關閉")
    end)

    local 隱形Button = CreateButton("隱形: 關閉", UDim2.new(0, 5, 0, 290), function()
        ZNS.settings.隱形 = not ZNS.settings.隱形
        隱形Button.Text = "隱形: " .. (ZNS.settings.隱形 and "開啟" or "關閉")
        if ZNS.settings.隱形 then 應用隱形() end
    end)
end

-- 單一Heartbeat迴圈 (優化核心)
local espConnections = {}
local function 主迴圈()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        local s = ZNS.settings
        -- 防甩飛
        if s.防甩飛 then
            for _, obj in pairs(character:GetDescendants()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyAngularVelocity") then
                    if obj.Name:find("Flung") or (obj.MaxForce and obj.MaxForce.Magnitude > 0) then
                        obj:Destroy()
                    end
                end
            end
        end
        -- 甩飛
        if s.甩飛 and s.目標玩家 and s.目標玩家.Character then
            local targetChar = s.目標玩家.Character
            local humanoidRootPart = targetChar:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Velocity = Vector3.new(0, -1000, 0)
                bv.Parent = humanoidRootPart
                game:GetService("Debris"):AddItem(bv, 0.05)
            end
        end
        -- 防虛空
        if s.防虛空 and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            if rootPart.Position.Y < s.虛空閾值 then
                rootPart.CFrame = CFrame.new(rootPart.Position.X, s.安全高度, rootPart.Position.Z)
            end
        end
        -- 隱形
        if s.隱形 then
            應用隱形()
        else
            取消隱形()
        end
        -- ESP
        if s.ESP then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    更新ESP(player)
                end
            end
        else
            清理ESP()
        end
    end)
end

-- 隱形應用函數
local function 應用隱形()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                pcall(function() part.LocalTransparencyModifier = 1 end)
            elseif part:IsA("Accessory") then
                local handle = part:FindFirstChild("Handle")
                if handle then pcall(function() handle.LocalTransparencyModifier = 1 end) end
            end
        end
    end
end

local function 取消隱形()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                pcall(function() part.LocalTransparencyModifier = 0 end)
            elseif part:IsA("Accessory") then
                local handle = part:FindFirstChild("Handle")
                if handle then pcall(function() handle.LocalTransparencyModifier = 0 end) end
            end
        end
    end
end

-- ESP 更新函數
local function 更新ESP(player)
    local head = player.Character and player.Character:FindFirstChild("Head")
    if not head then return end
    local billboard = head:FindFirstChild("ESPBillboard")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.Parent = head
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = billboard
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
        infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.TextColor3 = Color3.new(1, 1, 1)
        infoLabel.TextStrokeTransparency = 0
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.Parent = billboard
    end
    local ping = "未知"
    local device = "未知"
    pcall(function()
        ping = tostring(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        device = "PC"
    end)
    local label = billboard:FindFirstChildOfClass("TextLabel")
    if label then
        label.Text = "Ping: " .. ping .. " | 裝置: " .. device
    end
end

local function 清理ESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") then
            local esp = player.Character.Head:FindFirstChild("ESPBillboard")
            if esp then pcall(function() esp:Destroy() end) end
        end
    end
end

-- 玩家加入/角色重生處理
local function 初始化事件()
    if ZNS._connections then
        for _, c in ipairs(ZNS._connections) do pcall(function() c:Disconnect() end) end
    end
    ZNS._connections = {}
    table.insert(ZNS._connections, Players.PlayerAdded:Connect(function(player)
        if ZNS.settings.ESP then
            task.wait(1)
            更新ESP(player)
        end
    end))
    table.insert(ZNS._connections, LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if ZNS.settings.隱形 then
            應用隱形()
        end
    end))
    table.insert(ZNS._connections, RunService.Heartbeat:Connect(主迴圈))
    -- 註冊清理
    ZNS._CLEANUP = function()
        if ZNS._connections then
            for _, c in ipairs(ZNS._connections) do pcall(function() c:Disconnect() end) end
        end
        清理ESP()
        pcall(function()
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                for _, v in pairs(pg:GetChildren()) do
                    if v:IsA("ScreenGui") and v.Name:find("珍奶腳本_") then v:Destroy() end
                end
            end
        end)
    end
end

-- 主函數
return function(settings)
    初始化設置(settings)
    創建GUI()
    初始化事件()
    print("珍奶腳本 (遠程版) 已載入! 可在任何注入器中使用。")
end
