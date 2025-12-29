print("=== MIRAGE AUTO SCRIPT START ===")

-- SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

-- FLAGS
_G.AutoMirage = true
_G.LockMoonV3 = true
_G.TweenGear = true

print("Player:", LocalPlayer.Name)

--------------------------------------------------
-- SIMPLE TOPOS (Tween Teleport)
--------------------------------------------------
function topos(cf)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    char.HumanoidRootPart.CFrame = cf
end

--------------------------------------------------
-- STEP 1: FIND MIRAGE + TELEPORT
--------------------------------------------------
task.spawn(function()
    print("[THREAD] Mirage Detector Started")
    while task.wait(1) do
        pcall(function()
            if _G.AutoMirage then
                for _,v in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
                    if v.Name == "Mirage Island" then
                        print("[✓] Mirage Island FOUND")
                        print("[→] Teleporting to Mirage...")
                        topos(v.CFrame * CFrame.new(0,300,0))
                        _G.AutoMirage = false
                        _G.LockMoonV3 = true
                    end
                end
            end
        end)
    end
end)

--------------------------------------------------
-- STEP 2: LOCK MOON + ACTIVATE V3
--------------------------------------------------
task.spawn(function()
    print("[THREAD] Moon Lock Started")
    while task.wait(2) do
        pcall(function()
            if _G.LockMoonV3 then
                local moonDir = Lighting:GetMoonDirection()
                local cam = workspace.CurrentCamera

                cam.CFrame = CFrame.lookAt(
                    cam.CFrame.Position,
                    cam.CFrame.Position + moonDir * 100
                )

                print("[→] Locking moon & pressing T (V3)")
                VIM:SendKeyEvent(true,"T",false,game)
                task.wait(0.1)
                VIM:SendKeyEvent(false,"T",false,game)

                -- setelah aktif, lanjut ke gear
                _G.LockMoonV3 = false
                _G.TweenGear = true
            end
        end)
    end
end)

--------------------------------------------------
-- STEP 3: TWEEN TO MYSTIC GEAR
--------------------------------------------------
task.spawn(function()
    print("[THREAD] Mystic Gear Finder Started")
    while task.wait(1) do
        pcall(function()
            if _G.TweenGear then
                if workspace.Map:FindFirstChild("MysticIsland") then
                    for _,v in pairs(workspace.Map.MysticIsland:GetChildren()) do
                        if v:IsA("MeshPart") and v.Material == Enum.Material.Neon then
                            print("[✓] Mystic Gear FOUND → Teleport")
                            topos(v.CFrame)
                            _G.TweenGear = false
                        end
                    end
                end
            end
        end)
    end
end)

--------------------------------------------------
-- MOON STATUS DEBUG
--------------------------------------------------
task.spawn(function()
    while task.wait(3) do
        local moon = Lighting.Sky.MoonTextureId
        if moon then
            print("[MOON ID]:", moon)
        end
    end
end)

print("=== MIRAGE AUTO SCRIPT LOADED ===")
