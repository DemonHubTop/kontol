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

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,45)
Title.BackgroundTransparency = 1
Title.Text = "🌙 Demon Hub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(180,255,255)
Title.Active = true
Title.Selectable = true

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
-- DRAG (FIXED)
--------------------------------------------------
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

--------------------------------------------------
-- FREEZE / UNFREEZE
--------------------------------------------------
local function freezeChar(state)
    local char = LP.Character
    if not char then return end
    for _,v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = state
            v.CanCollide = not state
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = state
        hum.AutoRotate = not state
    end
end

--------------------------------------------------
-- TWEEN FUNCTION (SMOOTH)
--------------------------------------------------
local function tweenTo(cf, speed)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local dist = (hrp.Position - cf.Position).Magnitude
    local time = dist / (speed or 250)

    freezeChar(true)

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = cf}
    )

    tween:Play()
    tween.Completed:Wait()

    freezeChar(false)
end

--------------------------------------------------
-- FLAGS
--------------------------------------------------
_G.AutoMirage = true
_G.LockMoon = false
_G.TweenGear = false

--------------------------------------------------
-- MIRAGE CHECK + TWEEN
--------------------------------------------------
task.spawn(function()
    print("[THREAD] Mirage detector")
    while task.wait(1.5) do
        pcall(function()
            local mirage = workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
            if mirage then
                MirageLabel.Text = "Mirage: Spawn ✅"
                MirageLabel.TextColor3 = Color3.fromRGB(120,255,120)

                if _G.AutoMirage then
                    print("[→] Tween to Mirage (freeze)")
                    tweenTo(mirage.CFrame * CFrame.new(0,300,0), 260)
                    _G.AutoMirage = false
                    _G.LockMoon = true
                end
            else
                MirageLabel.Text = "Mirage: No Spawn ❌"
                MirageLabel.TextColor3 = Color3.fromRGB(255,120,120)
            end
        end)
    end
end)

--------------------------------------------------
-- LOCK MOON + V3
--------------------------------------------------
task.spawn(function()
    print("[THREAD] Moon lock")
    while task.wait(2) do
        pcall(function()
            if _G.LockMoon then
                local dir = Lighting:GetMoonDirection()
                local cam = workspace.CurrentCamera
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + dir*100)

                print("[→] Press T (V3)")
                VIM:SendKeyEvent(true,"T",false,game)
                task.wait(0.1)
                VIM:SendKeyEvent(false,"T",false,game)

                _G.LockMoon = false
                _G.TweenGear = true
            end
        end)
    end
end)

--------------------------------------------------
-- MOON STATUS
--------------------------------------------------
task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            local id = Lighting.Sky.MoonTextureId:match("%d+")
            local stage = ({
                ["9709149680"]="1/4",
                ["9709150401"]="2/4",
                ["9709143733"]="3/4",
                ["9709149431"]="4/4"
            })[id] or "0/4"
            MoonLabel.Text = "Moon: "..stage
        end)
    end
end)

--------------------------------------------------
-- TWEEN TO MYSTIC GEAR
--------------------------------------------------
task.spawn(function()
    print("[THREAD] Mystic gear")
    while task.wait(1) do
        pcall(function()
            if _G.TweenGear and workspace.Map:FindFirstChild("MysticIsland") then
                for _,v in pairs(workspace.Map.MysticIsland:GetChildren()) do
                    if v:IsA("MeshPart") and v.Material == Enum.Material.Neon then
                        print("[✓] Tween to Mystic Gear")
                        tweenTo(v.CFrame, 220)
                        _G.TweenGear = false
                        break
                    end
                end
            end
        end)
    end
end)

print("=== DEMON HUB LOADED ===")
