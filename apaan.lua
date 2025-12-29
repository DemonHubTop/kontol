print("=== DEMON HUB START ===")

-- SERVICES
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- CLEAN UI
pcall(function()
    game.CoreGui.DemonHubUI:Destroy()
end)

--------------------------------------------------
-- GUI
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DemonHubUI"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,420,0,240)
Main.Position = UDim2.new(0.5,-210,0.5,-120)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(160,100,255)
Stroke.Thickness = 2

-- TITLE
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,-40,0,45)
Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1
Title.Text = "🌙 Demon Hub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(180,255,255)
Title.TextXAlignment = Left
Title.Active = true

-- CLOSE BUTTON
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0,35,0,35)
Close.Position = UDim2.new(1,-40,0,5)
Close.Text = "✕"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 20
Close.BackgroundColor3 = Color3.fromRGB(35,35,45)
Close.TextColor3 = Color3.fromRGB(255,120,120)
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,8)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- LABELS
local MirageLabel = Instance.new("TextLabel", Main)
MirageLabel.Position = UDim2.new(0,10,0,60)
MirageLabel.Size = UDim2.new(1,-20,0,40)
MirageLabel.BackgroundColor3 = Color3.fromRGB(30,30,40)
MirageLabel.Font = Enum.Font.Gotham
MirageLabel.TextSize = 16
MirageLabel.Text = "Mirage: Checking..."
MirageLabel.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MirageLabel).CornerRadius = UDim.new(0,8)

local MoonLabel = Instance.new("TextLabel", Main)
MoonLabel.Position = UDim2.new(0,10,0,110)
MoonLabel.Size = UDim2.new(1,-20,0,40)
MoonLabel.BackgroundColor3 = Color3.fromRGB(30,30,40)
MoonLabel.Font = Enum.Font.Gotham
MoonLabel.TextSize = 16
MoonLabel.Text = "Moon: 0/4"
MoonLabel.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MoonLabel).CornerRadius = UDim.new(0,8)

--------------------------------------------------
-- DRAG
--------------------------------------------------
local dragging, dragStart, startPos
Title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = Main.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--------------------------------------------------
-- TWEEN (NO FREEZE, NO SNAP BACK)
--------------------------------------------------
local function tweenTo(cf, speed)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local dist = (hrp.Position - cf.Position).Magnitude
    local time = dist / (speed or 250)

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = cf}
    )
    tween:Play()
    tween.Completed:Wait()
end

--------------------------------------------------
-- FLAGS
--------------------------------------------------
_G.AutoMirage = true
_G.MirageDone = false
_G.LockMoon = false
_G.TweenGear = false

--------------------------------------------------
-- MIRAGE → TWEEN (ONCE)
--------------------------------------------------
task.spawn(function()
    while task.wait(1.5) do
        local mirage = workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
        if mirage then
            MirageLabel.Text = "Mirage: Spawn ✅"
            MirageLabel.TextColor3 = Color3.fromRGB(120,255,120)

            if _G.AutoMirage and not _G.MirageDone then
                _G.MirageDone = true
                tweenTo(mirage.CFrame * CFrame.new(0,300,0), 260)
                _G.AutoMirage = false
                _G.LockMoon = true
                break
            end
        else
            MirageLabel.Text = "Mirage: No Spawn ❌"
            MirageLabel.TextColor3 = Color3.fromRGB(255,120,120)
        end
    end
end)

--------------------------------------------------
-- LOCK MOON + V3
--------------------------------------------------
task.spawn(function()
    while task.wait(2) do
        if _G.LockMoon then
            local cam = workspace.CurrentCamera
            local dir = Lighting:GetMoonDirection()
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + dir*100)

            VIM:SendKeyEvent(true,"T",false,game)
            task.wait(0.1)
            VIM:SendKeyEvent(false,"T",false,game)

            _G.LockMoon = false
            _G.TweenGear = true
        end
    end
end)

--------------------------------------------------
-- MOON STATUS
--------------------------------------------------
task.spawn(function()
    while task.wait(1.5) do
        local id = Lighting.Sky.MoonTextureId:match("%d+")
        MoonLabel.Text = "Moon: "..({
            ["9709149680"]="1/4",
            ["9709150401"]="2/4",
            ["9709143733"]="3/4",
            ["9709149431"]="4/4"
        })[id] or "0/4"
    end
end)

--------------------------------------------------
-- TWEEN TO MYSTIC GEAR
--------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if _G.TweenGear and workspace.Map:FindFirstChild("MysticIsland") then
            for _,v in pairs(workspace.Map.MysticIsland:GetChildren()) do
                if v:IsA("MeshPart") and v.Material == Enum.Material.Neon then
                    tweenTo(v.CFrame, 220)
                    _G.TweenGear = false
                    break
                end
            end
        end
    end
end)

print("=== DEMON HUB LOADED (NO FREEZE) ===")
