-- AUTO KILL BOSS BLOX FRUITS
-- By Astraa

-- SERVICES
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer

-- JOIN TEAM
pcall(function()
    if getgenv().join == "Pirates" then
        RS.Remotes.CommF_:InvokeServer("SetTeam","Pirates")
    elseif getgenv().join == "Marines" then
        RS.Remotes.CommF_:InvokeServer("SetTeam","Marines")
    end
end)

-- FAST ATTACK (MELEE & SWORD)
local Enemies = workspace:WaitForChild("Enemies")
local Characters = workspace:WaitForChild("Characters")
local Net = RS:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

local Distance = 150
local ClickDelay = 0.1

local function IsAlive(char)
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function GetTargets()
    local list = {}
    local BasePart

    for _,folder in pairs({Enemies, Characters}) do
        for _,enemy in pairs(folder:GetChildren()) do
            local head = enemy:FindFirstChild("Head")
            if head and IsAlive(enemy)
            and Player:DistanceFromCharacter(head.Position) < Distance
            and enemy ~= Player.Character then
                table.insert(list, {enemy, head})
                BasePart = head
            end
        end
    end
    return BasePart, list
end

task.spawn(function()
    while task.wait(ClickDelay) do
        if not getgenv().AutoKillBoss then continue end
        if getgenv().weapon == "Blox Fruit" then continue end

        local character = Player.Character
        if not IsAlive(character) then continue end

        local tool = character:FindFirstChildOfClass("Tool")
        if not tool or tool.ToolTip == "Gun" then continue end

        local BasePart, targets = GetTargets()
        if #targets == 0 then continue end

        if tool:FindFirstChild("LeftClickRemote") then
            for _,data in ipairs(targets) do
                local enemy = data[1]
                local dir = (enemy.HumanoidRootPart.Position - character:GetPivot().Position).Unit
                pcall(function()
                    tool.LeftClickRemote:FireServer(dir, 1)
                end)
            end
        else
            RegisterAttack:FireServer(ClickDelay)
            RegisterHit:FireServer(BasePart, targets)
        end
    end
end)

-- GET BOSS
local function GetBoss()
    for _,v in pairs(workspace._WorldOrigin.EnemySpawns:GetChildren()) do
        if v:FindFirstChild("Humanoid") then
            return v
        end
    end
end

-- TELEPORT
local function TP(cf)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cf
    end
end

-- AUTO KILL BOSS
task.spawn(function()
    while task.wait() do
        if not getgenv().AutoKillBoss then continue end

        local boss = GetBoss()
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            TP(boss.HumanoidRootPart.CFrame * CFrame.new(0,10,-8))

            -- BLOX FRUIT
            if getgenv().weapon == "Blox Fruit" then
                local fruitName = Player.Data.DevilFruit.Value
                local char = Player.Character
                local fruit = char and char:FindFirstChild(fruitName)

                if fruit then
                    fruit.MousePos.Value = boss.HumanoidRootPart.Position

                    for _,key in pairs({"Z","X","C","V","F"}) do
                        pcall(function()
                            VIM:SendKeyEvent(true,key,false,game)
                            task.wait()
                            VIM:SendKeyEvent(false,key,false,game)
                        end)
                    end
                end
            end
        end
    end
end)

-- UI
local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "BossUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,160)
frame.Position = UDim2.new(0.5,-160,0.5,-80)
frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "AUTO KILL BOSS"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local bossText = Instance.new("TextLabel", frame)
bossText.Position = UDim2.new(0,15,0,55)
bossText.Size = UDim2.new(1,-30,0,30)
bossText.BackgroundTransparency = 1
bossText.Text = "Boss:"
bossText.TextColor3 = Color3.fromRGB(200,200,200)
bossText.Font = Enum.Font.Gotham
bossText.TextSize = 14
bossText.TextXAlignment = Left

local buyText = Instance.new("TextLabel", frame)
buyText.Position = UDim2.new(0,15,0,90)
buyText.Size = UDim2.new(1,-30,0,30)
buyText.BackgroundTransparency = 1
buyText.Text = "Beli:"
buyText.TextColor3 = Color3.fromRGB(200,200,200)
buyText.Font = Enum.Font.Gotham
buyText.TextSize = 14
buyText.TextXAlignment = Left
