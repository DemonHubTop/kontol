local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function UpdateIslandMirageESP()
    for _,v in pairs(game:GetService("Workspace")._WorldOrigin.Locations:GetChildren()) do
        pcall(function()
            if MirageIslandESP and v.Name == "Mirage Island" then
                if not v:FindFirstChild("NameEsp") then
                    local gui = Instance.new("BillboardGui", v)
                    gui.Name = "NameEsp"
                    gui.Adornee = v
                    gui.Size = UDim2.new(0,220,0,60)
                    gui.ExtentsOffset = Vector3.new(0,3,0)
                    gui.AlwaysOnTop = true

                    local frame = Instance.new("Frame", gui)
                    frame.Size = UDim2.new(1,0,1,0)
                    frame.BackgroundColor3 = Color3.fromRGB(25,25,35)
                    frame.BackgroundTransparency = 0.1

                    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

                    local stroke = Instance.new("UIStroke", frame)
                    stroke.Thickness = 2
                    stroke.Color = Color3.fromRGB(180,100,255)

                    local text = Instance.new("TextLabel", frame)
                    text.Name = "Text"
                    text.Size = UDim2.new(1,0,1,0)
                    text.BackgroundTransparency = 1
                    text.Font = Enum.Font.GothamBold
                    text.TextColor3 = Color3.fromRGB(150,255,255)
                    text.TextScaled = true
                    text.TextStrokeTransparency = 0.4
                end

                local dist = math.floor(
                    (LocalPlayer.Character.Head.Position - v.Position).Magnitude/3
                )
                v.NameEsp.Frame.Text.Text =
                    "🌙 MIRAGE ISLAND\n"..dist.." M"

            else
                if v:FindFirstChild("NameEsp") then
                    v.NameEsp:Destroy()
                end
            end
        end)
    end
end
