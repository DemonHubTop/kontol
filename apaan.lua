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
local Tweening = false

--------------------------------------------------
-- PHYSICS FIX (ANTI NAIK TURUN)
--------------------------------------------------
local function setPhysics(state)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(state and Enum.HumanoidStateType.Physics 
            or Enum.HumanoidStateType.GettingUp)
    end
end

--------------------------------------------------
-- TWEEN FUNCTION (STABIL)
--------------------------------------------------
local function topos(cf)
    if Tweening then return end
    Tweening = true

    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local dist = (hrp.Position - cf.Position).Magnitude
    local time = dist / 300

    setPhysics(true)

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = cf}
    )
    tween:Play()
    tween.Completed:Wait()

    setPhysics(false)
    Tweening = false
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
                    bill.Size = UDim2.new(0,230,0,42)
                    bill.AlwaysOnTop = true
                    bill.StudsOffset = Vector3.new(0,3,0)

                    local frame = Instance.new("Frame", bill)
                    frame.Size = UDim2.new(1,0,1,0)
                    frame.BackgroundColor3 = Color3.fromRGB(10,15,30)
                    frame.BackgroundTransparency = 0.1
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
Main.Size = UDim2.new(0,330,0,200)
Main.Position = UDim2.new(0.5,-165,0.5,-100)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,-40,0,35)
Title.Position = UDim2.new(0,10,0,0)
Title.Text = "Demon Hub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(180,255,255)
Title.BackgroundTransparency = 1
Title.Active = true

local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-35,0,3)
Close.Text = "X"
Close.Font = Enum.Font.GothamBold
Close.TextColor3 = Color3.fromRGB(255,100,100)
Close.BackgroundTransparency = 1
Close.MouseButton1Click:Connect(function()
    GUI:Destroy()
end)

local MirageLabel = Instance.new("TextLabel", Main)
MirageLabel.Position = UDim2.new(0,10,0,45)
MirageLabel.Size = UDim2.new(1,-20,0,35)
MirageLabel.BackgroundColor3 = Color3.fromRGB(30,30,40)
MirageLabel.TextColor3 = Color3.new(1,1,1)
MirageLabel.Text = "Mirage: Checking..."
Instance.new("UICorner", MirageLabel)

local MoonLabel = Instance.new("TextLabel", Main)
MoonLabel.Position = UDim2.new(0,10,0,90)
MoonLabel.Size = UDim2.new(1,-20,0,35)
MoonLabel.BackgroundColor3 = Color3.fromRGB(30,30,40)
MoonLabel.TextColor3 = Color3.new(1,1,1)
MoonLabel.Text = "Moon: 0%"
Instance.new("UICorner", MoonLabel)

--------------------------------------------------
-- DRAG GUI
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
-- MIRAGE CHECK + TWEEN (ONCE)
--------------------------------------------------
task.spawn(function()
    while task.wait(1.5) do
        local mirage = workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
        if mirage then
            MirageLabel.Text = "Mirage: Spawn ✅"
            if AutoMirage and not MirageArrived then
                MirageArrived = true
                AutoMirage = false
                topos(mirage.CFrame * CFrame.new(0,300,0))
            end
        else
            MirageLabel.Text = "Mirage: No Spawn ❌"
        end
    end
end)

--------------------------------------------------
-- LOCK MOON + V3 (ONCE)
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
-- TWEEN TO MYSTIC GEAR (ONCE)
--------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if TweenMGear and MoonActivated then
            local map = workspace.Map:FindFirstChild("MysticIsland")
            if map then
                for _,v in pairs(map:GetChildren()) do
                    if v:IsA("MeshPart") and v.Material == Enum.Material.Neon then
                        TweenMGear = false
                        topos(v.CFrame)
                        break
                    end
                end
            end
        end
    end
end)

print("=== DEMON HUB READY ===")
