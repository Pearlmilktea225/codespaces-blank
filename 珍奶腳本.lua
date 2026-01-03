local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--------------------------------------------------------------------------------
-- 1. 系統初始化
--------------------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "珍奶腳本 ",
    LoadingTitle = "正在載入介面控制...",
    LoadingSubtitle = "By 珍奶",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ZhenNai_Ultimate",
        FileName = "Config"
    },
    Discord = { Enabled = false },
    KeySystem = false, 
})

--------------------------------------------------------------------------------
-- 2. 服務與變數
--------------------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- 功能狀態
local Config = {
    Aimbot = false,
    Aiming = false,
    FOV = 150,
    Smoothness = 0.5,
    ESP = false,
    ESPColor = Color3.fromRGB(255, 0, 0),
    HitboxSize = 2, 
    HitboxEnabled = false,
    WalkSpeed = 16,
    JumpPower = 50,
    SpeedEnabled = false,
    JumpEnabled = false,
    InfJump = false,
    Fullbright = false
}

--------------------------------------------------------------------------------
-- 3. 手機操控介面 (Overlay)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZhenNai_Overlay"
ScreenGui.Parent = game.CoreGui 

-- 自瞄按鈕
local AimButton = Instance.new("TextButton")
AimButton.Name = "AimButton"
AimButton.Parent = ScreenGui
AimButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
AimButton.BackgroundTransparency = 0.4
AimButton.Position = UDim2.new(0.85, 0, 0.55, 0) 
AimButton.Size = UDim2.new(0, 65, 0, 65) -- 預設大小
AimButton.Font = Enum.Font.GothamBold
AimButton.Text = "瞄準"
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.TextSize = 18
AimButton.Visible = false 

-- 圓角與描邊
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0) 
UICorner.Parent = AimButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = AimButton
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- 準心 (Crosshair)
local CrosshairV = Instance.new("Frame")
CrosshairV.Name = "CrosshairV"
CrosshairV.Parent = ScreenGui
CrosshairV.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
CrosshairV.BorderSizePixel = 0
CrosshairV.Position = UDim2.new(0.5, -1, 0.5, -6)
CrosshairV.Size = UDim2.new(0, 2, 0, 12)
CrosshairV.Visible = false

local CrosshairH = Instance.new("Frame")
CrosshairH.Name = "CrosshairH"
CrosshairH.Parent = ScreenGui
CrosshairH.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
CrosshairH.BorderSizePixel = 0
CrosshairH.Position = UDim2.new(0.5, -6, 0.5, -1)
CrosshairH.Size = UDim2.new(0, 12, 0, 2)
CrosshairH.Visible = false

-- 按鈕互動邏輯
AimButton.MouseButton1Down:Connect(function()
    Config.Aiming = true
    UIStroke.Color = Color3.fromRGB(255, 0, 0) 
    AimButton.Text = "鎖定"
end)
AimButton.MouseButton1Up:Connect(function()
    Config.Aiming = false
    UIStroke.Color = Color3.fromRGB(255, 255, 255) 
    AimButton.Text = "瞄準"
end)
AimButton.MouseLeave:Connect(function() 
    Config.Aiming = false
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    AimButton.Text = "瞄準"
end)

-- 拖曳功能
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    AimButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
AimButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = AimButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
AimButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

--------------------------------------------------------------------------------
-- 4. 功能選單 (Tabs)
--------------------------------------------------------------------------------
local CombatTab = Window:CreateTab("戰鬥 (Combat)", 4483362458)
local VisualsTab = Window:CreateTab("視覺 (Visuals)", 4483362458)
local CharTab = Window:CreateTab("角色 (Player)", 4483362458)
local SettingsTab = Window:CreateTab("設定 (Settings)", 4483362458) -- 新增設定分頁

-- [戰鬥功能]
CombatTab:CreateSection("自瞄輔助")
CombatTab:CreateToggle({
    Name = "啟用自瞄 (Aimbot)",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(Value)
        Config.Aimbot = Value
        AimButton.Visible = Value
    end,
})
CombatTab:CreateSlider({
    Name = "自瞄範圍 (FOV)",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Callback = function(Value) Config.FOV = Value end,
})
CombatTab:CreateSlider({
    Name = "平滑度 (Smoothness)",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(Value) Config.Smoothness = Value / 10 end,
})

CombatTab:CreateSection("暴力功能")
CombatTab:CreateToggle({
    Name = "大頭模式 (Hitbox Expander)",
    CurrentValue = false,
    Callback = function(Value)
        Config.HitboxEnabled = Value
        if not Value then 
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    player.Character.Head.Size = Vector3.new(1.2, 1.2, 1.2)
                    player.Character.Head.Transparency = 0
                end
            end
        end
    end,
})
CombatTab:CreateSlider({
    Name = "頭部大小 (Head Size)",
    Range = {2, 10},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(Value) Config.HitboxSize = Value end,
})

-- [視覺功能]
VisualsTab:CreateSection("顯示")
VisualsTab:CreateToggle({
    Name = "透視 (ESP)",
    CurrentValue = false,
    Callback = function(Value) Config.ESP = Value end,
})
VisualsTab:CreateColorPicker({
    Name = "透視顏色",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Value) Config.ESPColor = Value end,
})
VisualsTab:CreateToggle({
    Name = "顯示準心 (Crosshair)",
    CurrentValue = false,
    Callback = function(Value)
        CrosshairV.Visible = Value
        CrosshairH.Visible = Value
    end,
})
VisualsTab:CreateToggle({
    Name = "夜視模式 (Fullbright)",
    CurrentValue = false,
    Callback = function(Value)
        Config.Fullbright = Value
        if Value then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
        else
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            Lighting.Brightness = 1
        end
    end,
})

-- [角色功能]
CharTab:CreateSection("移動修改")
CharTab:CreateToggle({
    Name = "啟用速度修改",
    CurrentValue = false,
    Callback = function(Value) Config.SpeedEnabled = Value end,
})
CharTab:CreateSlider({
    Name = "移動速度 (Speed)",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value) Config.WalkSpeed = Value end,
})
CharTab:CreateToggle({
    Name = "啟用跳躍修改",
    CurrentValue = false,
    Callback = function(Value) Config.JumpEnabled = Value end,
})
CharTab:CreateSlider({
    Name = "跳躍高度 (Jump Power)",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value) Config.JumpPower = Value end,
})
CharTab:CreateToggle({
    Name = "無限跳 (Infinite Jump)",
    CurrentValue = false,
    Callback = function(Value) Config.InfJump = Value end,
})

-- [設定功能 - 縮小/隱藏介面]
SettingsTab:CreateSection("介面管理")

SettingsTab:CreateButton({
    Name = "縮小選單 (Hide Menu)",
    Callback = function()
        -- 嘗試隱藏 Rayfield 主介面
        -- 注意：Rayfield 有自己的 Toggle 邏輯，這裡我們模擬關閉
        local library = game.CoreGui:FindFirstChild("Rayfield")
        if library and library:FindFirstChild("Main") then
             library.Main.Visible = false
        end
        Rayfield:Notify({
            Title = "提示",
            Content = "選單已隱藏。點擊螢幕側邊的小綠鈕可再次開啟。",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

SettingsTab:CreateSection("按鈕自訂 (Overlay)")

SettingsTab:CreateSlider({
    Name = "按鈕大小 (Button Size)",
    Range = {40, 150},
    Increment = 5,
    CurrentValue = 65,
    Callback = function(Value)
        AimButton.Size = UDim2.new(0, Value, 0, Value)
    end,
})

SettingsTab:CreateSlider({
    Name = "按鈕透明度 (Transparency)",
    Range = {0, 100},
    Increment = 10,
    CurrentValue = 40,
    Callback = function(Value)
        AimButton.BackgroundTransparency = Value / 100
    end,
})

SettingsTab:CreateButton({
    Name = "卸載腳本 (Destroy UI)",
    Callback = function()
        ScreenGui:Destroy()
        Rayfield:Destroy()
    end,
})

--------------------------------------------------------------------------------
-- 5. 核心循環邏輯
--------------------------------------------------------------------------------

-- 無限跳邏輯
UserInputService.JumpRequest:Connect(function()
    if Config.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- 渲染循環
RunService.RenderStepped:Connect(function()
    -- ESP
    if not Config.ESP then
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v.Name == "ZN_Highlight" then v:Destroy() end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local char = player.Character
                if player.TeamColor ~= LocalPlayer.TeamColor or player.Team == nil then
                    if not char:FindFirstChild("ZN_Highlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ZN_Highlight"
                        hl.Parent = char
                        hl.FillColor = Config.ESPColor
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                    else
                        char.ZN_Highlight.FillColor = Config.ESPColor
                    end
                else
                    if char:FindFirstChild("ZN_Highlight") then char.ZN_Highlight:Destroy() end
                end
            end
        end
    end

    -- Aimbot
    if Config.Aimbot and Config.Aiming then
        local target = nil
        local shortestDist = Config.FOV
        local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if player.TeamColor ~= LocalPlayer.TeamColor or player.Team == nil then
                    local char = player.Character
                    local pos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - centerScreen).Magnitude
                        if dist < shortestDist then
                            target = char
                            shortestDist = dist
                        end
                    end
                end
            end
        end

        if target then
            local headPos = target.Head.Position
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, headPos)
            Camera.CFrame = currentCF:Lerp(targetCF, 1 - Config.Smoothness)
        end
    end

    -- Hitbox
    if Config.HitboxEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.TeamColor ~= LocalPlayer.TeamColor and player.Character and player.Character:FindFirstChild("Head") then
                player.Character.Head.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                player.Character.Head.Transparency = 0.5 
                player.Character.Head.CanCollide = false
            end
        end
    end
    
    -- Speed/Jump Keep
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if Config.SpeedEnabled then
            LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
        end
        if Config.JumpEnabled then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = Config.JumpPower
        end
    end
end)

Rayfield:Notify({
    Title = "珍奶腳本 ",
    Content = "腳本載入完成！請至「設定」調整介面。",
    Duration = 5,
    Image = 4483362458,
})
