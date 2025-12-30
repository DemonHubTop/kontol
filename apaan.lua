local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
  
--// Create Window //--
local Window = WindUI:CreateWindow({
  Title = "Zynix Hub",
  Author = "by Zynix hub",
  Size = UDim2.new(0, 620, 0, 480),
  Position = UDim2.new(0, 100, 0, 100),
  SideGUIWidth = 180,
  Icon = "square",
  Theme = "Dark"
})

--// Section: MAIN //--
local Setting = Window:Tab({
  Title = "Setting",
  Icon = "LucideSettings"
})

local Main = Window:Tab({
  Title = "Main",
  Icon = "Home"
})

local Fram-other = Window:Tab({
  Title = "Fram Other",
  Icon = "Home"
})

local Item = Window:Tab({
  Title = "Item",
  Icon = "Swords"
})


_G.SelectWeaponType = "Melee"

local Dropdown_Setting = Setting:Dropdown({
    Title = "Select Weapon",
    Values = {"Melee","Sword","Gun","Blox Fruit"},
    Callback = function(value)
        _G.SelectWeaponType = v
    end
})
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
