print("=== DEMON HUB GUI LOADING ===")

-- SERVICES
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- CLEAN OLD UI
pcall(function()
    game.CoreGui.DemonHubUI:Destroy()
end)

-- SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DemonHubUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- MAIN FRAME
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,420,0,220)
Main.Position = UDim2.new(0.5,-210,0.5,-110)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Main.BorderSizePixel = 0

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

-- STROKE
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(170,100,255)
Stroke.Thickness = 2

-- TITLE BAR
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,45)
Title.BackgroundTransparency = 1
Title.Text = "🌙 Demon Hub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(180,255,255)

-- CONTENT
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,0,0,50)
Content.Size = UDim2.new(1,0,1,-50)
Content.BackgroundTransparency = 1

-- MIRAGE STATUS
local MirageLabel = Instance.new("TextLabel", Content)
MirageLabel.Size = UDim2.new(1,-20,0,40)
MirageLabel.Position = UDim2.new(0,10,0,10)
MirageLabel.BackgroundColor3 = Color3.fromRGB(30,30,40)
MirageLabel.Text = "Mirage: Checking..."
MirageLabel.Font = Enum.Font.Gotham
MirageLabel.TextSize = 16
MirageLabel.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", MirageLabel).CornerRadius = UDim.new(0,8)

-- MOON STATUS
local MoonLabel = Instance.new("TextLabel", Content)
MoonLabel.Size = UDim2.new(1,-20,0,40)
MoonLabel.Position = UDim2.new(0,10,0,60)
MoonLabel.BackgroundColor3 = Color3.fromRGB(30,30,40)
MoonLabel.Text = "Moon: 0/4"
MoonLabel.Font = Enum.Font.Gotham
MoonLabel.TextSize = 16
MoonLabel.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", MoonLabel).CornerRadius = UDim.new(0,8)

--------------------------------------------------
-- DRAG FUNCTION
--------------------------------------------------
local dragging = false
local dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--------------------------------------------------
-- MIRAGE CHECK
--------------------------------------------------
task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            if workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island") then
                MirageLabel.Text = "Mirage: Spawn ✅"
                MirageLabel.TextColor3 = Color3.fromRGB(120,255,120)
            else
                MirageLabel.Text = "Mirage: No Spawn ❌"
                MirageLabel.TextColor3 = Color3.fromRGB(255,120,120)
            end
        end)
    end
end)

--------------------------------------------------
-- MOON CHECK (1/4, 2/4, 3/4, 4/4)
--------------------------------------------------
task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            local id = Lighting.Sky.MoonTextureId
            local stage = ({
                ["9709149680"] = "1/4",
                ["9709150401"] = "2/4",
                ["9709143733"] = "3/4",
                ["9709149431"] = "4/4"
            })[id:match("%d+")] or "0/4"

            MoonLabel.Text = "Moon: "..stage
        end)
    end
end)

print("=== DEMON HUB GUI LOADED SUCCESS ===")
