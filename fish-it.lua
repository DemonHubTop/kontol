
local FuncAutoFishV2 = {
	REReplicateTextEffectV2 = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateTextEffect"],
	autofishV2 = false,
	perfectCastV2 = true,
	fishingActiveV2 = false,
	delayInitializedV2 = false
}

local RodDelaysV2 = {
    ["Ares Rod"] = {custom = 1.12, bypass = 1.45},
    ["Angler Rod"] = {custom = 1.12, bypass = 1.45},
    ["Ghostfinn Rod"] = {custom = 1.12, bypass = 1.45},
    ["Astral Rod"] = {custom = 1.9, bypass = 1.45},
    ["Chrome Rod"] = {custom = 2.3, bypass = 2},
    ["Steampunk Rod"] = {custom = 2.5, bypass = 2.3},
    ["Lucky Rod"] = {custom = 3.5, bypass = 3.6},
    ["Midnight Rod"] = {custom = 3.3, bypass = 3.4},
    ["Demascus Rod"] = {custom = 3.9, bypass = 3.8},
    ["Grass Rod"] = {custom = 3.8, bypass = 3.9},
    ["Luck Rod"] = {custom = 4.2, bypass = 4.1},
    ["Carbon Rod"] = {custom = 4, bypass = 3.8},
    ["Lava Rod"] = {custom = 4.2, bypass = 4.1},
    ["Starter Rod"] = {custom = 4.3, bypass = 4.2},
}

local customDelayV2 = 1
local BypassDelayV2 = 0.5

local function getValidRodNameV2()
    local player = Players.LocalPlayer
    local display = player.PlayerGui:WaitForChild("Backpack"):WaitForChild("Display")
    for _, tile in ipairs(display:GetChildren()) do
        local success, itemNamePath = pcall(function()
            return tile.Inner.Tags.ItemName
        end)
        if success and itemNamePath and itemNamePath:IsA("TextLabel") then
            local name = itemNamePath.Text
            if RodDelaysV2[name] then
                return name
            end
        end
    end
    return nil
end

local function updateDelayBasedOnRodV2(showNotify)
    if FuncAutoFishV2.delayInitializedV2 then return end
    local rodName = getValidRodNameV2()
    if rodName and RodDelaysV2[rodName] then
        customDelayV2 = RodDelaysV2[rodName].custom
        BypassDelayV2 = RodDelaysV2[rodName].bypass
        FuncAutoFishV2.delayInitializedV2 = true
        if showNotify and FuncAutoFishV2.autofishV2 then
            NotifySuccess("Rod Detected", string.format("Detected Rod: %s | Delay: %.2fs | Bypass: %.2fs", rodName, customDelayV2, BypassDelayV2))
        end
    else
        customDelayV2 = 10
        BypassDelayV2 = 1
        FuncAutoFishV2.delayInitializedV2 = true
        if showNotify and FuncAutoFishV2.autofishV2 then
            NotifyWarning("Rod Detection Failed", "No valid rod found. Default delay applied.")
        end
    end
end

local function setupRodWatcher()
    local player = Players.LocalPlayer
    local display = player.PlayerGui:WaitForChild("Backpack"):WaitForChild("Display")
    display.ChildAdded:Connect(function()
        task.wait(0.05)
        if not FuncAutoFishV2.delayInitializedV2 then
            updateDelayBasedOnRodV2(true)
        end
    end)
end
setupRodWatcher()

-- NEW AUTO SELL
local lastSellTime = 0
local AUTO_SELL_THRESHOLD = 60 -- Sell when non-favorited fish > 60
local AUTO_SELL_DELAY = 60 -- Minimum seconds between sells

local function getNetFolder() return net end

local function startAutoSell()
    task.spawn(function()
        while state.AutoSell do
            pcall(function()
                if not Replion then return end
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items) ~= "table" then return end

                -- Count non-favorited fish
                local unfavoritedCount = 0
                for _, item in ipairs(items) do
                    if not item.Favorited then
                        unfavoritedCount = unfavoritedCount + (item.Count or 1)
                    end
                end

                -- Only sell if above threshold and delay passed
                if unfavoritedCount >= AUTO_SELL_THRESHOLD and os.time() - lastSellTime >= AUTO_SELL_DELAY then
                    local netFolder = getNetFolder()
                    if netFolder then
                        local sellFunc = netFolder:FindFirstChild("RF/SellAllItems")
                        if sellFunc then
                            task.spawn(sellFunc.InvokeServer, sellFunc)
							NotifyInfo("Auto Sell", "Selling non-favorited items...")
                            lastSellTime = os.time()
                        end
                    end
                end
            end)
            task.wait(10) -- check every 10 seconds
        end
    end)
end

FuncAutoFishV2.REReplicateTextEffectV2.OnClientEvent:Connect(function(data)
    if FuncAutoFishV2.autofishV2 and FuncAutoFishV2.fishingActiveV2
    and data
    and data.TextData
    and data.TextData.EffectType == "Exclaim" then

        local myHead = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head")
        if myHead and data.Container == myHead then
            task.spawn(function()
                for i = 1, 3 do
                    task.wait(BypassDelayV2)
                    finishRemote:FireServer()
                    rconsoleclear()
                end
            end)
        end
    end
end)

function StartAutoFishV2()
    if FuncAutoFishV2.autofishV2 then return end
    
    FuncAutoFishV2.autofishV2 = true
    updateDelayBasedOnRodV2(true)
    task.spawn(function()
        while FuncAutoFishV2.autofishV2 do
            pcall(function()
                FuncAutoFishV2.fishingActiveV2 = true

                local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
                equipRemote:FireServer(1)
                task.wait(0.1)

                local chargeRemote = ReplicatedStorage
                    .Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
                chargeRemote:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.5)

                local timestamp = workspace:GetServerTimeNow()
                RodShakeAnim:Play()
                rodRemote:InvokeServer(timestamp)

                local baseX, baseY = -0.7499996423721313, 1
                local x, y
                if FuncAutoFishV2.perfectCastV2 then
                    x = baseX + (math.random(-500, 500) / 10000000)
                    y = baseY + (math.random(-500, 500) / 10000000)
                else
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end

                RodIdleAnim:Play()
                miniGameRemote:InvokeServer(x, y)

                task.wait(customDelayV2)
                FuncAutoFishV2.fishingActiveV2 = false
            end)
        end
    end)
end

function StopAutoFishV2()
    FuncAutoFishV2.autofishV2 = false
    FuncAutoFishV2.fishingActiveV2 = false
    FuncAutoFishV2.delayInitializedV2 = false
    RodIdleAnim:Stop()
    RodShakeAnim:Stop()
    RodReelAnim:Stop()
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Zynix Hub",
    SubTitle = "Fishing System",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- Matikan acrylic agar lebih kompatibel
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- 4. MASUKKAN ELEMENT UI
do
    -- Input Delay
    Tabs.Main:AddInput("BypassDelay", {
        Title = "Bypass Delay",
        Default = "1.45",
        Placeholder = "Example: 1.45",
        Callback = function(Value)
            _G.BypassDelayV2 = tonumber(Value) or 1.45
        end
    })

    -- Toggle Auto Sell (Gunakan ID Unik)
    local Toggle1 = Tabs.Main:AddToggle("TglAutoSell", {Title = "Auto Sell", Default = false})
    Toggle1:OnChanged(function()
        state.AutoSell = Options.TglAutoSell.Value
    end)

    -- Toggle Auto Fish (Gunakan ID Unik)
    local Toggle2 = Tabs.Main:AddToggle("TglAutoFish", {Title = "Auto Fish V2", Default = false})
    Toggle2:OnChanged(function()
        if Options.TglAutoFish.Value then StartAutoFishV2() else StopAutoFishV2() end
    end)

    -- Toggle Perfect Cast
    local Toggle3 = Tabs.Main:AddToggle("TglPerfect", {Title = "Auto Perfect Cast", Default = true})
    Toggle3:OnChanged(function()
        FuncAutoFishV2.perfectCastV2 = Options.TglPerfect.Value
    end)

    Tabs.Main:AddParagraph({
        Title = "Protection",
        Content = "Auto Favorite protects your rare fishes."
    })

    -- Button Manual Sell
    Tabs.Main:AddButton({
        Title = "Sell All Fishes",
        Callback = function()
            sellAllFishes()
        end
    })
end

-- 5. FINALIZE
Window:SelectTab(1)
Fluent:Notify({
    Title = "Zynix Hub",
    Content = "Script Loaded! Press Left Control to Toggle Menu",
    Duration = 5
})
