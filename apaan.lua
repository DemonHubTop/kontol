--////////////////////////////////////////////////////
-- SERVICES
--////////////////////////////////////////////////////
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer

--////////////////////////////////////////////////////
-- GLOBAL STATE (ANTI BALIK)
--////////////////////////////////////////////////////
_G.State = {
    MirageDone = false,
    LockMoon = false,
    TweenGear = false
}

--////////////////////////////////////////////////////
-- FREEZE CHARACTER
--////////////////////////////////////////////////////
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

--////////////////////////////////////////////////////
-- TWEEN FUNCTION (NO TP)
--////////////////////////////////////////////////////
local function tweenTo(cf, speed)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local dist = (hrp.Position - cf.Position).Magnitude
    local time = dist / (speed or 300)

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

--////////////////////////////////////////////////////
-- GUI
--////////////////////////////////////////////////////
local gui = Instance.new("ScreenGui")
gui.Name = "DemonHub"
gui.Parent = LP.PlayerGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,320,0,180)
main.Position = UDim2.new(0.35,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)

Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- DRAG SYSTEM (FIXED)
do
    local dragging, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "🔥 Demon Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,80,80)

local MirageLabel = Instance.new("TextLabel", main)
MirageLabel.Position = UDim2.new(0,10,0,45)
MirageLabel.Size = UDim2.new(1,-20,0,30)
MirageLabel.BackgroundTransparency = 1
MirageLabel.Text = "Mirage: Checking..."
MirageLabel.Font = Enum.Font.Gotham
MirageLabel.TextSize = 14
MirageLabel.TextXAlignment = Left

local MoonLabel = Instance.new("TextLabel", main)
MoonLabel.Position = UDim2.new(0,10,0,80)
MoonLabel.Size = UDim2.new(1,-20,0,30)
MoonLabel.BackgroundTransparency = 1
MoonLabel.Text = "Moon: 0"
MoonLabel.Font = Enum.Font.Gotham
MoonLabel.TextSize = 14
MoonLabel.TextXAlignment = Left
MoonLabel.TextColor3 = Color3.fromRGB(180,180,255)

--////////////////////////////////////////////////////
-- MIRAGE ESP (BOX STYLE)
--////////////////////////////////////////////////////
local function UpdateIslandMirageESP()
    for _,v in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
        if v.Name == "Mirage Island" then
            if not v:FindFirstChild("NameEsp") then
                local bill = Instance.new("BillboardGui", v)
                bill.Name = "NameEsp"
                bill.Size = UDim2.new(0,220,0,55)
                bill.AlwaysOnTop = true
                bill.StudsOffset = Vector3.new(0,6,0)

                local frame = Instance.new("Frame", bill)
                frame.Size = UDim2.new(1,0,1,0)
                frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
                frame.BackgroundTransparency = 0.25
                Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

                local txt = Instance.new("TextLabel", frame)
                txt.Name = "Text"
                txt.Size = UDim2.new(1,0,1,0)
                txt.BackgroundTransparency = 1
                txt.Font = Enum.Font.Code
                txt.TextSize = 14
                txt.TextColor3 = Color3.fromRGB(0,255,255)
                txt.TextWrapped = true
            else
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = math.floor((hrp.Position - v.Position).Magnitude)
                    v.NameEsp.Frame.Text.Text = "🌴 MIRAGE ISLAND\n"..d.." m"
                end
            end
        end
    end
end
RunService.RenderStepped:Connect(UpdateIslandMirageESP)

--////////////////////////////////////////////////////
-- MIRAGE DETECT + TWEEN (ONCE)
--////////////////////////////////////////////////////
task.spawn(function()
    while task.wait(1.5) do
        if _G.State.MirageDone then return end
        local mirage = workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
        if mirage then
            MirageLabel.Text = "Mirage: Spawn ✅"
            MirageLabel.TextColor3 = Color3.fromRGB(120,255,120)

            _G.State.MirageDone = true
            tweenTo(mirage.CFrame * CFrame.new(0,300,0), 260)
            _G.State.LockMoon = true
            break
        else
            MirageLabel.Text = "Mirage: No Spawn ❌"
            MirageLabel.TextColor3 = Color3.fromRGB(255,120,120)
        end
    end
end)

--////////////////////////////////////////////////////
-- LOCK MOON + V3
--////////////////////////////////////////////////////
task.spawn(function()
    while task.wait(1) do
        if _G.State.LockMoon then
            local cam = workspace.CurrentCamera
            local dir = Lighting:GetMoonDirection()
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + dir * 100)

            VirtualInputManager:SendKeyEvent(true,"T",false,game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false,"T",false,game)

            _G.State.LockMoon = false
            _G.State.TweenGear = true
        end
    end
end)

--////////////////////////////////////////////////////
-- TWEEN KE MYSTIC GEAR
--////////////////////////////////////////////////////
task.spawn(function()
    while task.wait(1) do
        if _G.State.TweenGear then
            if workspace.Map:FindFirstChild("MysticIsland") then
                for _,v in pairs(workspace.Map.MysticIsland:GetChildren()) do
                    if v:IsA("MeshPart") and v.Material == Enum.Material.Neon then
                        tweenTo(v.CFrame, 220)
                        _G.State.TweenGear = false
                        return
                    end
                end
            end
        end
    end
end)

--////////////////////////////////////////////////////
-- MOON STATUS UI
--////////////////////////////////////////////////////
task.spawn(function()
    while task.wait(1) do
        local id = Lighting.Sky.MoonTextureId
        local map = {
            ["9709149431"] = "100",
            ["9709149052"] = "75",
            ["9709143733"] = "50",
            ["9709150401"] = "25",
            ["9709149680"] = "15"
        }
        local v = "0"
        for k,val in pairs(map) do
            if string.find(id,k) then v = val end
        end
        MoonLabel.Text = "Moon: "..v
    end
end)
