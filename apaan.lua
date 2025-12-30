-- AUTO KILL ALL BOSS (JOIN + TWEEN SLOW + FAST ATTACK + FRUIT)
-- By Astraa

-- ===================== SERVICES =====================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer

-- ===================== JOIN TEAM =====================
pcall(function()
    if getgenv().join == "Pirates" then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam","Pirates")
    elseif getgenv().join == "Marines" then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam","Marines")
    end
end)

-- ===================== FOLDERS =====================
local EnemySpawns = workspace._WorldOrigin.EnemySpawns
local Enemies = workspace:WaitForChild("Enemies")
local Characters = workspace:WaitForChild("Characters")

-- ===================== TWEEN (PELAAAN) =====================
local function TweenTo(cf)
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local dist = (hrp.Position - cf.Position).Magnitude
    local time = dist / 80 -- MAKIN KECIL = MAKIN PELAN (60–100 aman)

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = cf}
    )
    tween:Play()
    tween.Completed:Wait()
end

-- ===================== FAST ATTACK =====================
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
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

        local char = Player.Character
        if not IsAlive(char) then continue end

        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or tool.ToolTip == "Gun" then continue end

        local BasePart, targets = GetTargets()
        if #targets == 0 then continue end

        if tool:FindFirstChild("LeftClickRemote") then
            for _,data in ipairs(targets) do
                local enemy = data[1]
                local dir = (enemy.HumanoidRootPart.Position - char:GetPivot().Position).Unit
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

-- ===================== BLOX FRUIT (SEMUA SKILL) =====================
task.spawn(function()
    while task.wait(0.25) do
        if not getgenv().AutoKillBoss then continue end
        if getgenv().weapon ~= "Blox Fruit" then continue end

        local fruitName = Player.Data.DevilFruit.Value
        local char = Player.Character
        local fruit = char and char:FindFirstChild(fruitName)

        if fruit then
            for _,enemy in pairs(Enemies:GetChildren()) do
                if enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                    fruit.MousePos.Value = enemy.HumanoidRootPart.Position

                    for _,key in pairs({"Z","X","C","V","F"}) do
                        pcall(function()
                            VIM:SendKeyEvent(true, key, false, game)
                            task.wait()
                            VIM:SendKeyEvent(false, key, false, game)
                        end)
                    end
                end
            end
        end
    end
end)

-- ===================== MAIN LOOP (ALL BOSS) =====================
while task.wait() do
    if not getgenv().AutoKillBoss then continue end

    for _,spawn in pairs(EnemySpawns:GetChildren()) do
        if string.find(spawn.Name, "[Boss]") then
            TweenTo(spawn.CFrame * CFrame.new(0, 10, -8))
            task.wait(0.5)
        end
    end
end
