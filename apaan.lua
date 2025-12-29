print("=== DEMON HUB START ===")

-- SERVICES
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

-- CLEAN OLD UI
pcall(function()
    game.CoreGui.DemonHubUI:Destroy()
end)

--------------------------------------------------
-- GUI
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DemonHubUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0,420,0,240)
Main.Position = UDim2.new(0.5,-210,0.5,-120)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(160,100,255)
Stroke.Thickness = 2

-- TITLE
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1,0,0,45)
Title.BackgroundTransparency = 1
Title.Text = "🌙 Demon Hub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(180,255,255)
Title.Active = true -- 🔴 PENTING UNTUK DRAG
Title.Selectable = true

-- MIRAGE LABEL
local MirageLabel = Instance.new("TextLabel")
MirageLabel.Parent = Main
MirageLabel.Position = UDim2.new(0,10,0,60)
MirageLabel.Size = UDim2.new(1,-20,0,40)
MirageLabel.BackgroundColor3 = Color3.fromRGB(30,30,40)
MirageLabel.Font = Enum.Font.Gotham
MirageLabel.TextSize = 16
MirageLabel.Text = "Mirage: Checking..."
MirageLabel.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MirageLabel).CornerRadius = UDim.new(0,8)

-- MOON LABEL
local MoonLabel = Instance.new("TextLabel")
MoonLabel.Parent = Main
MoonLabel.Position = UDim2.new(0,10,0,110)
MoonLabel.Size = UDim2.new(1,-20,0,40)
MoonLabel.BackgroundColor3 = Color3.fromRGB(30,30,40)
MoonLabel.Font = Enum.Font.Gotham
MoonLabel.TextSize = 16
MoonLabel.Text = "Moon: 0/4"
MoonLabel.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MoonLabel).CornerRadius = UDim.new(0,8)

--------------------------------------------------
-- DRAG SYSTEM (FIXED & STABLE)
--------------------------------------------------
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

--------------------------------------------------
-- TELEPORT FUNCTION
--------------------------------------------------
local function topos(cf)
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
    end
end

--------------------------------------------------
-- FLAGS
--------------------------------------------------
_G.AutoMirage = true
_G.LockMoon = false
_G.TweenGear = false

--------------------------------------------------
-- MIRAGE CHECK + TELEPORT
--------------------------------------------------
task.spawn(function()
    print("[THREAD] Mirage detector running")
    while task.wait(1.5) do
        pcall(function()
            local mirage = workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
            if mirage then
                MirageLabel.Text = "Mirage: Spawn ✅"
                MirageLabel.TextColor3 = Color3.fromRGB(120,255,120)

                if _G.AutoMirage then
                    print("[✓] Teleport to Mirage")
                    topos(mirage.CFrame * CFrame.new(0,300,0))
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
    print("[THREAD] Moon lock running")
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
                ["9709149680"] = "1/4",
                ["9709150401"] = "2/4",
                ["9709143733"] = "3/4",
                ["9709149431"] = "4/4"
            })[id] or "0/4"

            MoonLabel.Text = "Moon: "..stage
        end)
    end
end)

--------------------------------------------------
-- TWEEN TO MYSTIC GEAR
--------------------------------------------------
task.spawn(function()
    print("[THREAD] Mystic gear finder running")
    while task.wait(1) do
        pcall(function()
            if _G.TweenGear and workspace.Map:FindFirstChild("MysticIsland") then
                for _,v in pairs(workspace.Map.MysticIsland:GetChildren()) do
                    if v:IsA("MeshPart") and v.Material == Enum.Material.Neon then
                        print("[✓] Mystic Gear FOUND")
                        topos(v.CFrame)
                        _G.TweenGear = false
                    end
                end
            end
        end)
    end
end)

print("=== DEMON HUB LOADED SUCCESS ===")
