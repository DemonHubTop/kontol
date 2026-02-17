-- ZygardeUI Library for Roblox
-- Exact recreation of the Zygarde UI design
-- Author: ZygardeUI v1.0

local ZygardeUI = {}
ZygardeUI.__index = ZygardeUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Color Palette
local Colors = {
    Background      = Color3.fromRGB(10, 25, 20),
    Sidebar         = Color3.fromRGB(12, 28, 22),
    SidebarHover    = Color3.fromRGB(18, 45, 32),
    SidebarActive   = Color3.fromRGB(22, 110, 55),
    Content         = Color3.fromRGB(13, 32, 24),
    Header          = Color3.fromRGB(16, 38, 28),
    Element         = Color3.fromRGB(18, 48, 34),
    ElementHover    = Color3.fromRGB(22, 60, 42),
    Border          = Color3.fromRGB(30, 80, 55),
    BorderBright    = Color3.fromRGB(40, 130, 75),
    TextPrimary     = Color3.fromRGB(220, 255, 235),
    TextSecondary   = Color3.fromRGB(140, 200, 165),
    TextDim         = Color3.fromRGB(80, 140, 105),
    Accent          = Color3.fromRGB(40, 200, 100),
    AccentDark      = Color3.fromRGB(25, 130, 65),
    AccentGlow      = Color3.fromRGB(20, 180, 80),
    SliderBg        = Color3.fromRGB(15, 40, 28),
    SliderFill      = Color3.fromRGB(35, 175, 90),
    ToggleOff       = Color3.fromRGB(40, 70, 55),
    ToggleOn        = Color3.fromRGB(35, 175, 90),
    ToggleKnob      = Color3.fromRGB(255, 255, 255),
    TitleBar        = Color3.fromRGB(8, 20, 15),
    WindowBorder    = Color3.fromRGB(25, 75, 50),
}

-- Utility Functions
local function Tween(obj, props, dur, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local info = TweenInfo.new(dur or 0.2, style, dir)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
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

local function CreateInstance(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function AddPadding(parent, top, bottom, left, right)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, top or 4)
    pad.PaddingBottom = UDim.new(0, bottom or 4)
    pad.PaddingLeft = UDim.new(0, left or 8)
    pad.PaddingRight = UDim.new(0, right or 8)
    pad.Parent = parent
    return pad
end

local function AddListLayout(parent, padding, fillDir, halign, valign)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, padding or 4)
    layout.FillDirection = fillDir or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = valign or Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

-- Icon: Home (simplified triangle house shape using TextLabel)
local function CreateHomeIcon(parent, size)
    local icon = CreateInstance("TextLabel", {
        Size = UDim2.new(0, size or 16, 0, size or 16),
        BackgroundTransparency = 1,
        Text = "⌂",
        TextSize = size or 16,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextSecondary,
        Parent = parent,
    })
    return icon
end

-- ScreenGui Setup
local function GetScreenGui()
    local existing = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ZygardeUI")
    if existing then existing:Destroy() end

    local screenGui = CreateInstance("ScreenGui", {
        Name = "ZygardeUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = LocalPlayer.PlayerGui,
    })
    return screenGui
end

-- Main Window Creator
function ZygardeUI.new(config)
    config = config or {}
    local self = setmetatable({}, ZygardeUI)

    self.Title = config.Title or "Zygarde"
    self.Tabs = {}
    self.ActiveTab = nil
    self.ScreenGui = GetScreenGui()

    -- Main Window Frame
    self.Window = CreateInstance("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 610, 0, 390),
        Position = UDim2.new(0.5, -305, 0.5, -195),
        BackgroundColor3 = Colors.Background,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
    })
    AddCorner(self.Window, 8)
    AddStroke(self.Window, Colors.WindowBorder, 1.5)

    -- Drop shadow effect
    local shadow = CreateInstance("ImageLabel", {
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = self.Window,
    })

    -- Title Bar
    self.TitleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Colors.TitleBar,
        ZIndex = 10,
        Parent = self.Window,
    })

    -- Title Bar bottom border
    local titleBorder = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Colors.WindowBorder,
        BorderSizePixel = 0,
        Parent = self.TitleBar,
    })

    -- Zygarde logo / icon area
    local logoFrame = CreateInstance("Frame", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 6, 0.5, -14),
        BackgroundColor3 = Colors.AccentDark,
        Parent = self.TitleBar,
    })
    AddCorner(logoFrame, 5)

    local logoInner = CreateInstance("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0.5, -10, 0.5, -10),
        BackgroundColor3 = Colors.Accent,
        Parent = logoFrame,
    })
    AddCorner(logoInner, 3)

    local logoIcon = CreateInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Z",
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(5, 15, 10),
        Parent = logoInner,
    })

    -- Title Text
    self.TitleLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 42, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
    })

    -- Minimize Button
    local minBtn = CreateInstance("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -58, 0.5, -14),
        BackgroundTransparency = 1,
        Text = "—",
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextDim,
        Parent = self.TitleBar,
    })
    minBtn.MouseEnter:Connect(function()
        Tween(minBtn, {TextColor3 = Colors.TextPrimary}, 0.15)
    end)
    minBtn.MouseLeave:Connect(function()
        Tween(minBtn, {TextColor3 = Colors.TextDim}, 0.15)
    end)

    -- Close Button
    local closeBtn = CreateInstance("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -30, 0.5, -14),
        BackgroundTransparency = 1,
        Text = "✕",
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextDim,
        Parent = self.TitleBar,
    })
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {TextColor3 = Color3.fromRGB(255, 80, 80)}, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {TextColor3 = Colors.TextDim}, 0.15)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)

    -- Minimized toggle
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(self.Window, {Size = UDim2.new(0, 610, 0, 36)}, 0.25, Enum.EasingStyle.Quad)
        else
            Tween(self.Window, {Size = UDim2.new(0, 610, 0, 390)}, 0.25, Enum.EasingStyle.Quad)
        end
    end)

    MakeDraggable(self.Window, self.TitleBar)

    -- Main Body
    self.Body = CreateInstance("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = self.Window,
    })

    -- Sidebar
    self.Sidebar = CreateInstance("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = Colors.Sidebar,
        Parent = self.Body,
    })

    -- Sidebar right border
    local sidebarBorder = CreateInstance("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Colors.WindowBorder,
        BorderSizePixel = 0,
        Parent = self.Sidebar,
    })

    -- Sidebar tab list
    self.TabList = CreateInstance("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -70),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.Sidebar,
    })
    AddPadding(self.TabList, 8, 8, 0, 0)
    local tabListLayout = AddListLayout(self.TabList, 2)

    tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabList.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 16)
    end)

    -- User Profile Section at bottom of sidebar
    self.UserFrame = CreateInstance("Frame", {
        Name = "UserFrame",
        Size = UDim2.new(1, 0, 0, 68),
        Position = UDim2.new(0, 0, 1, -68),
        BackgroundColor3 = Colors.TitleBar,
        Parent = self.Sidebar,
    })

    local userBorderTop = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Colors.WindowBorder,
        BorderSizePixel = 0,
        Parent = self.UserFrame,
    })

    -- Avatar
    local avatarFrame = CreateInstance("Frame", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 10, 0.5, -20),
        BackgroundColor3 = Colors.AccentDark,
        Parent = self.UserFrame,
    })
    AddCorner(avatarFrame, 20)
    AddStroke(avatarFrame, Colors.Accent, 1.5)

    -- Avatar thumbnail
    local avatarImg = CreateInstance("ImageLabel", {
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 1,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=48&h=48",
        Parent = avatarFrame,
    })
    AddCorner(avatarImg, 20)

    -- Online indicator dot
    local onlineDot = CreateInstance("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(1, -10, 1, -10),
        BackgroundColor3 = Colors.Accent,
        Parent = avatarFrame,
    })
    AddCorner(onlineDot, 5)
    AddStroke(onlineDot, Colors.TitleBar, 2)

    -- Display Name
    local displayName = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -58, 0, 18),
        Position = UDim2.new(0, 56, 0, 16),
        BackgroundTransparency = 1,
        Text = "DIsplay",
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.UserFrame,
    })

    local usernameLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -58, 0, 14),
        Position = UDim2.new(0, 56, 0, 34),
        BackgroundTransparency = 1,
        Text = "@" .. LocalPlayer.Name,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.UserFrame,
    })

    -- Update display name from player
    local success, result = pcall(function()
        return LocalPlayer.DisplayName
    end)
    if success and result then
        displayName.Text = result
    end

    -- Content Area
    self.ContentArea = CreateInstance("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -180, 1, 0),
        Position = UDim2.new(0, 180, 0, 0),
        BackgroundColor3 = Colors.Content,
        Parent = self.Body,
    })

    -- Scrollbar visual
    local scrollbarTrack = CreateInstance("Frame", {
        Size = UDim2.new(0, 4, 1, -10),
        Position = UDim2.new(1, -6, 0, 5),
        BackgroundColor3 = Colors.Border,
        Parent = self.ContentArea,
    })
    AddCorner(scrollbarTrack, 2)

    local scrollbarThumb = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 80),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Colors.BorderBright,
        Parent = scrollbarTrack,
    })
    AddCorner(scrollbarThumb, 2)

    -- Content holder (scrollable)
    self.ContentHolder = CreateInstance("ScrollingFrame", {
        Name = "ContentHolder",
        Size = UDim2.new(1, -12, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.ContentArea,
    })
    AddPadding(self.ContentHolder, 12, 12, 12, 12)
    local contentLayout = AddListLayout(self.ContentHolder, 8)

    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentHolder.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 24)
        -- Update scrollbar
        local ratio = self.ContentHolder.AbsoluteWindowSize.Y / math.max(1, self.ContentHolder.CanvasSize.Y.Offset)
        scrollbarThumb.Size = UDim2.new(1, 0, math.min(1, ratio), 0)
    end)

    self.ContentHolder:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        local maxScroll = self.ContentHolder.CanvasSize.Y.Offset - self.ContentHolder.AbsoluteWindowSize.Y
        if maxScroll > 0 then
            local scrollRatio = self.ContentHolder.CanvasPosition.Y / maxScroll
            local trackHeight = scrollbarTrack.AbsoluteSize.Y
            local thumbHeight = scrollbarThumb.AbsoluteSize.Y
            scrollbarThumb.Position = UDim2.new(0, 0, 0, scrollRatio * (trackHeight - thumbHeight))
        end
    end)

    return self
end

-- Add Tab
function ZygardeUI:AddTab(config)
    config = config or {}
    local tabName = config.Name or "Tab"
    local tab = {}

    -- Tab Button in Sidebar
    local tabBtn = CreateInstance("TextButton", {
        Name = tabName .. "Tab",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Colors.Sidebar,
        AutoButtonColor = false,
        Text = "",
        Parent = self.TabList,
    })
    AddCorner(tabBtn, 6)

    -- Active indicator bar on left
    local activeBar = CreateInstance("Frame", {
        Size = UDim2.new(0, 3, 0, 22),
        Position = UDim2.new(0, 0, 0.5, -11),
        BackgroundColor3 = Colors.Accent,
        BackgroundTransparency = 1,
        Parent = tabBtn,
    })
    AddCorner(activeBar, 2)

    -- Home icon
    local iconLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 12, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "⌂",
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextDim,
        Parent = tabBtn,
    })

    -- Tab name
    local tabLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1,
        Text = tabName,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn,
    })

    -- Content Section Header
    local sectionLabel = CreateInstance("TextLabel", {
        Name = "SectionHeader",
        Size = UDim2.new(1, -12, 0, 28),
        BackgroundTransparency = 1,
        Text = "Content Section",
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
        Visible = false,
        Parent = self.ContentHolder,
    })

    tab.SectionLabel = sectionLabel
    tab.Elements = {}
    tab.LayoutOrder = 1

    -- Hover effect
    tabBtn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tabBtn, {BackgroundColor3 = Colors.SidebarHover}, 0.15)
            Tween(iconLabel, {TextColor3 = Colors.TextSecondary}, 0.15)
            Tween(tabLabel, {TextColor3 = Colors.TextSecondary}, 0.15)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tabBtn, {BackgroundColor3 = Colors.Sidebar}, 0.15)
            Tween(iconLabel, {TextColor3 = Colors.TextDim}, 0.15)
            Tween(tabLabel, {TextColor3 = Colors.TextDim}, 0.15)
        end
    end)

    -- Click to activate
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    tab._button = tabBtn
    tab._icon = iconLabel
    tab._label = tabLabel
    tab._activeBar = activeBar
    tab._window = self
    tab._order = 0

    table.insert(self.Tabs, tab)

    -- Auto-select first tab
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

-- Select Tab
function ZygardeUI:SelectTab(tab)
    -- Deactivate all
    for _, t in pairs(self.Tabs) do
        Tween(t._button, {BackgroundColor3 = Colors.Sidebar}, 0.2)
        Tween(t._icon, {TextColor3 = Colors.TextDim}, 0.2)
        Tween(t._label, {TextColor3 = Colors.TextDim, Font = Enum.Font.Gotham}, 0.2)
        Tween(t._activeBar, {BackgroundTransparency = 1}, 0.2)
        if t.SectionLabel then t.SectionLabel.Visible = false end
        for _, elem in pairs(t.Elements) do
            if elem then elem.Visible = false end
        end
    end

    -- Activate selected
    self.ActiveTab = tab
    Tween(tab._button, {BackgroundColor3 = Colors.SidebarActive}, 0.2)
    Tween(tab._icon, {TextColor3 = Colors.TextPrimary}, 0.2)
    Tween(tab._label, {TextColor3 = Colors.TextPrimary}, 0.2)
    Tween(tab._activeBar, {BackgroundTransparency = 0}, 0.2)

    if tab.SectionLabel then tab.SectionLabel.Visible = true end
    for _, elem in pairs(tab.Elements) do
        if elem then elem.Visible = true end
    end
end

-- Add Section Header inside tab
function ZygardeUI:AddSection(tab, name)
    local sectionHeader = CreateInstance("TextLabel", {
        Name = "SectionLabel_" .. name,
        Size = UDim2.new(1, -12, 0, 28),
        BackgroundTransparency = 1,
        Text = name,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = tab._order,
        Visible = self.ActiveTab == tab,
        Parent = self.ContentHolder,
    })
    tab._order = tab._order + 1
    table.insert(tab.Elements, sectionHeader)
    return sectionHeader
end

-- Add Dropdown
function ZygardeUI:AddDropdown(tab, config)
    config = config or {}
    local label = config.Label or "Dropdown"
    local options = config.Options or {}
    local placeholder = config.Placeholder or "Select an option"
    local callback = config.Callback or function() end

    -- Outer container
    local container = CreateInstance("Frame", {
        Name = "DropdownContainer",
        Size = UDim2.new(1, 0, 0, 68),
        BackgroundColor3 = Colors.Header,
        LayoutOrder = tab._order,
        Visible = self.ActiveTab == tab,
        Parent = self.ContentHolder,
    })
    AddCorner(container, 6)
    tab._order = tab._order + 1

    -- Label
    local labelEl = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -12, 0, 24),
        Position = UDim2.new(0, 10, 0, 4),
        BackgroundTransparency = 1,
        Text = label,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    -- Dropdown button
    local dropBtn = CreateInstance("TextButton", {
        Size = UDim2.new(1, -12, 0, 32),
        Position = UDim2.new(0, 6, 0, 28),
        BackgroundColor3 = Colors.Element,
        AutoButtonColor = false,
        Text = "",
        Parent = container,
    })
    AddCorner(dropBtn, 6)
    AddStroke(dropBtn, Colors.Border, 1)

    local selectedText = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = placeholder,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropBtn,
    })

    -- Arrow indicator
    local arrowLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(1, -26, 0, 0),
        BackgroundTransparency = 1,
        Text = "⌃\n⌄",
        TextSize = 10,
        LineHeight = 1,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.Accent,
        Parent = dropBtn,
    })

    -- Dropdown options panel
    local isOpen = false
    local optionHolder = CreateInstance("Frame", {
        Name = "OptionsHolder",
        Size = UDim2.new(1, -12, 0, 0),
        Position = UDim2.new(0, 6, 1, 2),
        BackgroundColor3 = Colors.Element,
        ClipsDescendants = true,
        ZIndex = 50,
        Visible = false,
        Parent = container,
    })
    AddCorner(optionHolder, 6)
    AddStroke(optionHolder, Colors.Border, 1)

    local optLayout = AddListLayout(optionHolder, 1)
    AddPadding(optionHolder, 4, 4, 0, 0)

    local optionHeight = #options * 30 + 8

    for _, opt in ipairs(options) do
        local optBtn = CreateInstance("TextButton", {
            Size = UDim2.new(1, -8, 0, 28),
            BackgroundColor3 = Colors.Element,
            AutoButtonColor = false,
            Text = "",
            Parent = optionHolder,
        })
        AddCorner(optBtn, 4)

        local optText = CreateInstance("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = opt,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextColor3 = Colors.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = optBtn,
        })

        optBtn.MouseEnter:Connect(function()
            Tween(optBtn, {BackgroundColor3 = Colors.ElementHover}, 0.1)
            Tween(optText, {TextColor3 = Colors.TextPrimary}, 0.1)
        end)
        optBtn.MouseLeave:Connect(function()
            Tween(optBtn, {BackgroundColor3 = Colors.Element}, 0.1)
            Tween(optText, {TextColor3 = Colors.TextSecondary}, 0.1)
        end)

        optBtn.MouseButton1Click:Connect(function()
            selectedText.Text = opt
            selectedText.TextColor3 = Colors.TextPrimary
            isOpen = false
            Tween(optionHolder, {Size = UDim2.new(1, -12, 0, 0)}, 0.2)
            optionHolder.Visible = false
            Tween(container, {Size = UDim2.new(1, 0, 0, 68)}, 0.2)
            callback(opt)
        end)
    end

    dropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            optionHolder.Visible = true
            Tween(optionHolder, {Size = UDim2.new(1, -12, 0, optionHeight)}, 0.2)
            Tween(container, {Size = UDim2.new(1, 0, 0, 68 + optionHeight + 4)}, 0.2)
        else
            Tween(optionHolder, {Size = UDim2.new(1, -12, 0, 0)}, 0.2)
            Tween(container, {Size = UDim2.new(1, 0, 0, 68)}, 0.2)
            task.delay(0.2, function() optionHolder.Visible = false end)
        end
    end)

    dropBtn.MouseEnter:Connect(function()
        Tween(dropBtn, {BackgroundColor3 = Colors.ElementHover}, 0.15)
    end)
    dropBtn.MouseLeave:Connect(function()
        Tween(dropBtn, {BackgroundColor3 = Colors.Element}, 0.15)
    end)

    table.insert(tab.Elements, container)

    local dropdownObj = {}
    function dropdownObj:Set(value)
        selectedText.Text = value
        selectedText.TextColor3 = Colors.TextPrimary
        callback(value)
    end
    return dropdownObj
end

-- Add TextBox
function ZygardeUI:AddTextBox(tab, config)
    config = config or {}
    local label = config.Label or "TextBox"
    local placeholder = config.Placeholder or ""
    local default = config.Default or ""
    local callback = config.Callback or function() end

    local container = CreateInstance("Frame", {
        Name = "TextBoxContainer",
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundColor3 = Colors.Header,
        LayoutOrder = tab._order,
        Visible = self.ActiveTab == tab,
        Parent = self.ContentHolder,
    })
    AddCorner(container, 6)
    tab._order = tab._order + 1

    local labelEl = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -12, 0, 24),
        Position = UDim2.new(0, 10, 0, 4),
        BackgroundTransparency = 1,
        Text = label,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    local inputFrame = CreateInstance("Frame", {
        Size = UDim2.new(1, -12, 0, 32),
        Position = UDim2.new(0, 6, 0, 28),
        BackgroundColor3 = Colors.Element,
        Parent = container,
    })
    AddCorner(inputFrame, 6)
    local stroke = AddStroke(inputFrame, Colors.Border, 1)

    local textbox = CreateInstance("TextBox", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = default,
        PlaceholderText = placeholder,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = Colors.TextPrimary,
        PlaceholderColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputFrame,
    })

    textbox.Focused:Connect(function()
        Tween(stroke, {Color = Colors.Accent, Thickness = 1.5}, 0.2)
        Tween(inputFrame, {BackgroundColor3 = Colors.ElementHover}, 0.2)
    end)
    textbox.FocusLost:Connect(function(enter)
        Tween(stroke, {Color = Colors.Border, Thickness = 1}, 0.2)
        Tween(inputFrame, {BackgroundColor3 = Colors.Element}, 0.2)
        if enter then callback(textbox.Text) end
    end)

    table.insert(tab.Elements, container)

    local tbObj = {}
    function tbObj:Get() return textbox.Text end
    function tbObj:Set(v) textbox.Text = v end
    return tbObj
end

-- Add Button
function ZygardeUI:AddButton(tab, config)
    config = config or {}
    local label = config.Label or "Button"
    local callback = config.Callback or function() end

    local container = CreateInstance("Frame", {
        Name = "ButtonContainer",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Colors.Header,
        LayoutOrder = tab._order,
        Visible = self.ActiveTab == tab,
        Parent = self.ContentHolder,
    })
    AddCorner(container, 6)
    tab._order = tab._order + 1

    local labelEl = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    -- Arrow/execute button icon on right
    local execBtn = CreateInstance("TextButton", {
        Size = UDim2.new(0, 32, 0, 26),
        Position = UDim2.new(1, -40, 0.5, -13),
        BackgroundColor3 = Colors.AccentDark,
        AutoButtonColor = false,
        Text = "▶",
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.Accent,
        Parent = container,
    })
    AddCorner(execBtn, 5)

    local clickable = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container,
    })

    clickable.MouseEnter:Connect(function()
        Tween(container, {BackgroundColor3 = Colors.SidebarHover}, 0.15)
        Tween(execBtn, {BackgroundColor3 = Colors.AccentGlow}, 0.15)
    end)
    clickable.MouseLeave:Connect(function()
        Tween(container, {BackgroundColor3 = Colors.Header}, 0.15)
        Tween(execBtn, {BackgroundColor3 = Colors.AccentDark}, 0.15)
    end)
    clickable.MouseButton1Click:Connect(function()
        Tween(container, {BackgroundColor3 = Colors.SidebarActive}, 0.08)
        task.delay(0.08, function()
            Tween(container, {BackgroundColor3 = Colors.Header}, 0.15)
        end)
        callback()
    end)

    table.insert(tab.Elements, container)
end

-- Add Slider
function ZygardeUI:AddSlider(tab, config)
    config = config or {}
    local label = config.Label or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or 50
    local callback = config.Callback or function() end

    local container = CreateInstance("Frame", {
        Name = "SliderContainer",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Colors.Header,
        LayoutOrder = tab._order,
        Visible = self.ActiveTab == tab,
        Parent = self.ContentHolder,
    })
    AddCorner(container, 6)
    tab._order = tab._order + 1

    local labelEl = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -50, 0, 20),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = label,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    local valueLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(0, 10, 0, 24),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    -- Track BG
    local trackBg = CreateInstance("Frame", {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 1, -18),
        BackgroundColor3 = Colors.SliderBg,
        Parent = container,
    })
    AddCorner(trackBg, 3)
    AddStroke(trackBg, Colors.Border, 1)

    -- Fill
    local fill = CreateInstance("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.SliderFill,
        Parent = trackBg,
    })
    AddCorner(fill, 3)

    -- Knob
    local knob = CreateInstance("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = trackBg,
    })
    AddCorner(knob, 7)
    AddStroke(knob, Colors.AccentDark, 1.5)

    local current = default
    local draggingSlider = false

    local function updateSlider(inputX)
        local trackPos = trackBg.AbsolutePosition.X
        local trackWidth = trackBg.AbsoluteSize.X
        local relX = math.clamp((inputX - trackPos) / trackWidth, 0, 1)
        current = math.floor(min + relX * (max - min))
        valueLabel.Text = tostring(current)
        Tween(fill, {Size = UDim2.new(relX, 0, 1, 0)}, 0.05)
        Tween(knob, {Position = UDim2.new(relX, -7, 0.5, -7)}, 0.05)
        callback(current)
    end

    local inputArea = CreateInstance("TextButton", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 1, -26),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 5,
        Parent = container,
    })

    inputArea.MouseButton1Down:Connect(function()
        draggingSlider = true
        updateSlider(Mouse.X)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if draggingSlider then
            updateSlider(Mouse.X)
        end
    end)

    trackBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            updateSlider(Mouse.X)
        end
    end)

    table.insert(tab.Elements, container)

    local sliderObj = {}
    function sliderObj:Get() return current end
    function sliderObj:Set(v)
        v = math.clamp(v, min, max)
        current = v
        local relX = (v - min) / (max - min)
        valueLabel.Text = tostring(v)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -7, 0.5, -7)
    end
    return sliderObj
end

-- Add Toggle
function ZygardeUI:AddToggle(tab, config)
    config = config or {}
    local label = config.Label or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end

    local container = CreateInstance("Frame", {
        Name = "ToggleContainer",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Colors.Header,
        LayoutOrder = tab._order,
        Visible = self.ActiveTab == tab,
        Parent = self.ContentHolder,
    })
    AddCorner(container, 6)
    tab._order = tab._order + 1

    local labelEl = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -64, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    -- Toggle track
    local track = CreateInstance("Frame", {
        Size = UDim2.new(0, 42, 0, 22),
        Position = UDim2.new(1, -52, 0.5, -11),
        BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff,
        Parent = container,
    })
    AddCorner(track, 11)

    -- Knob
    local knob = CreateInstance("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = Colors.ToggleKnob,
        Parent = track,
    })
    AddCorner(knob, 8)

    local toggled = default
    local clickable = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container,
    })

    clickable.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Tween(track, {BackgroundColor3 = Colors.ToggleOn}, 0.2)
            Tween(knob, {Position = UDim2.new(1, -19, 0.5, -8)}, 0.2, Enum.EasingStyle.Back)
        else
            Tween(track, {BackgroundColor3 = Colors.ToggleOff}, 0.2)
            Tween(knob, {Position = UDim2.new(0, 3, 0.5, -8)}, 0.2, Enum.EasingStyle.Back)
        end
        callback(toggled)
    end)

    clickable.MouseEnter:Connect(function()
        Tween(container, {BackgroundColor3 = Colors.SidebarHover}, 0.15)
    end)
    clickable.MouseLeave:Connect(function()
        Tween(container, {BackgroundColor3 = Colors.Header}, 0.15)
    end)

    table.insert(tab.Elements, container)

    local toggleObj = {}
    function toggleObj:Get() return toggled end
    function toggleObj:Set(v)
        toggled = v
        if toggled then
            track.BackgroundColor3 = Colors.ToggleOn
            knob.Position = UDim2.new(1, -19, 0.5, -8)
        else
            track.BackgroundColor3 = Colors.ToggleOff
            knob.Position = UDim2.new(0, 3, 0.5, -8)
        end
        callback(toggled)
    end
    return toggleObj
end

-- Notify function
function ZygardeUI:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local text = config.Text or ""
    local duration = config.Duration or 3

    local notif = CreateInstance("Frame", {
        Size = UDim2.new(0, 260, 0, 60),
        Position = UDim2.new(1, -270, 1, -70),
        BackgroundColor3 = Colors.Header,
        Parent = self.ScreenGui,
    })
    AddCorner(notif, 8)
    AddStroke(notif, Colors.Accent, 1)

    local accent = CreateInstance("Frame", {
        Size = UDim2.new(0, 3, 1, -12),
        Position = UDim2.new(0, 0, 0, 6),
        BackgroundColor3 = Colors.Accent,
        Parent = notif,
    })
    AddCorner(accent, 2)

    local titleLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })

    local textLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -16, 0, 18),
        Position = UDim2.new(0, 12, 0, 30),
        BackgroundTransparency = 1,
        Text = text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })

    notif.Position = UDim2.new(1, 10, 1, -70)
    Tween(notif, {Position = UDim2.new(1, -270, 1, -70)}, 0.3, Enum.EasingStyle.Back)

    task.delay(duration, function()
        Tween(notif, {Position = UDim2.new(1, 10, 1, -70)}, 0.3)
        task.delay(0.3, function()
            notif:Destroy()
        end)
    end)
end

return ZygardeUI
