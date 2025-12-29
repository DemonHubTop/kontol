print("=== DEMON HUB START ===")

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

--------------------------------------------------
-- GLOBAL FLAGS
--------------------------------------------------
getgenv().MirageIslandESP = true
getgenv().AutoMirage = true
getgenv().AutoDooHee = true
getgenv().TweenMGear = true

local MirageArrived = false
local MoonActivated = false

--------------------------------------------------
-- TWEEN FUNCTION
--------------------------------------------------
local function topos(cf)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local dist = (hrp.Position - cf.Position).Magnitude
    local time = dist / 300

    TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = cf}
    ):Play()
end

--------------------------------------------------
-- MIRAGE ESP (CUSTOM STYLE)
--------------------------------------------------
function UpdateIslandMirageESP()
    for _,v in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
        pcall(function()
            if MirageIslandESP and v.Name == "Mirage Island" then
                if not v:FindFirstChild("NameEsp") then
                    local bill = Instance.new("BillboardGui", v)
                    bill.Name = "NameEsp"
                    bill.Size = UDim2.new(0,220,0,40)
                    bill.AlwaysOnTop = true
                    bill.StudsOffset = Vector3.new(0,3,0)

                    local frame = Instance.new("Frame", bill)
                    frame.Size = UDim2.new(1,0,1,0)
                    frame.BackgroundColor3 = Color3.fromRGB(15,20,35)
                    frame.BackgroundTransparency = 0.15
                    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

                    local txt = Instance.new("TextLabel", frame)
                    txt.Name = "Text"
                    txt.Size = UDim2.new(1,0,1,0)
                    txt.BackgroundTransparency = 1
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 14
                    txt.TextColor3 = Color3.fromRGB(120,200,255)
                else
                    local dist = math.floor(
                        (LP.Character.Head.Position - v.Position).Magnitude/3
                    )
                    v.NameEsp.Frame.Text.Text =
                        "🌙 MIRAGE ISLAND\n"..dist.." M"
                end
            elseif v:FindFirstChild("NameEsp") then
                v.NameEsp:Destroy()
            end
        end)
    end
end

task.spawn(function()
    while task.wait(1) do
        UpdateIslandMirageESP()
    end
end)

--------------------------------------------------
-- GUI
--------------------------------------------------
pcall(function() LP.PlayerGui.DemonHubUI:Destroy() end)

local GUI = Instance.new("ScreenGui", LP.PlayerGui)
GUI.Name = "DemonHubUI"

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0,320,0,180)
Main.Position = UDim2.new(0.5,-160,0.5,-90)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35)
Title.Text = "Demon Hub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(180,255,255)
Title.BackgroundTransparency = 1
Title.Active = true

local MirageLabel = Instance.new("TextLabel", Main)
MirageLabel.Position = UDim2.new(0,10,0,50)
MirageLabel.Size = UDim2.new(1,-20,0,35)
MirageLabel.BackgroundColor3 = Color3.fromRGB(30,30,40)
MirageLabel.TextColor3 = Color3.new(1,1,1)
MirageLabel.Text = "Mirage: Checking..."
Instance.new("UICorner", MirageLabel)

local MoonLabel = Instance.new("TextLabel", Main)
MoonLabel.Position = UDim2.new(0,10,0,95)
MoonLabel.Size = UDim2.new(1,-20,0,35)
MoonLabel.BackgroundColor3 = Color3.fromRGB(30,30,40)
MoonLabel.TextColor3 = Color3.new(1,1,1)
MoonLabel.Text = "Moon: 0"
Instance.new("UICorner", MoonLabel)

--------------------------------------------------
-- DRAG
--------------------------------------------------
local drag, dragStart, startPos
Title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dragStart = i.Position
        startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = false
    end
end)

--------------------------------------------------
-- MIRAGE CHECK + TWEEN
--------------------------------------------------
task.spawn(function()
    while task.wait(1.5) do
        local mirage = workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
        if mirage then
            MirageLabel.Text = "Mirage: Spawn ✅"
            if AutoMirage and not MirageArrived then
                MirageArrived = true
                topos(mirage.CFrame * CFrame.new(0,300,0))
            end
        else
            MirageLabel.Text = "Mirage: No Spawn ❌"
        end
    end
end)

--------------------------------------------------
-- LOCK MOON + V3
--------------------------------------------------
task.spawn(function()
    while task.wait(2) do
        if AutoDooHee and MirageArrived and not MoonActivated then
            local dir = Lighting:GetMoonDirection()
            local cam = workspace.CurrentCamera
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + dir*100)
            task.wait(1)
            VIM:SendKeyEvent(true,"T",false,game)
            task.wait(0.1)
            VIM:SendKeyEvent(false,"T",false,game)
            MoonActivated = true
        end
    end
end)

--------------------------------------------------
-- MOON STATUS (ID BASED)
--------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        local id = Lighting.Sky.MoonTextureId
        if id:find("9709149431") then MoonLabel.Text="Moon: 100%"
        elseif id:find("9709149052") then MoonLabel.Text="Moon: 75%"
        elseif id:find("9709143733") then MoonLabel.Text="Moon: 50%"
        elseif id:find("9709150401") then MoonLabel.Text="Moon: 25%"
        elseif id:find("9709149680") then MoonLabel.Text="Moon: 15%"
        else MoonLabel.Text="Moon: 0%" end
    end
end)

--------------------------------------------------
-- TWEEN MYSTIC GEAR
--------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if TweenMGear and MoonActivated then
            local map = workspace.Map:FindFirstChild("MysticIsland")
            if map then
                for _,v in pairs(map:GetChildren()) do
                    if v:IsA("MeshPart") and v.Material == Enum.Material.Neon then
                        topos(v.CFrame)
                        TweenMGear = false
                        break
                    end
                end
            end
        end
    end
end)

print("=== DEMON HUB READY ===")
