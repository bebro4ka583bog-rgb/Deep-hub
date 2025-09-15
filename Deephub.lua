-- Deephub Script - Fixed Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeephubGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Text = "Deephub v2.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 100, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 1, -40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
ToggleButton.Text = "Open/Close"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.Gotham
ToggleButton.TextSize = 14
ToggleButton.Visible = false
ToggleButton.Parent = ScreenGui

local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Size = UDim2.new(0, 100, 0, 210)
TabButtonsFrame.Position = UDim2.new(0, 10, 0, 50)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.Parent = MainFrame

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 270, 0, 210)
TabsFrame.Position = UDim2.new(0, 120, 0, 50)
TabsFrame.BackgroundTransparency = 1
TabsFrame.ClipsDescendants = true
TabsFrame.Parent = MainFrame

-- Tabs
local Tabs = {
    Combat = {Name = "Combat", Color = Color3.fromRGB(220, 80, 80)},
    Movement = {Name = "Movement", Color = Color3.fromRGB(80, 180, 80)},
    Visuals = {Name = "Visuals", Color = Color3.fromRGB(80, 120, 220)},
    Misc = {Name = "Misc", Color = Color3.fromRGB(180, 100, 220)}
}

local CurrentTab = "Combat"
local Connections = {}
local Enabled = {
    AimBot = false,
    WallHack = false,
    SpeedHack = false,
    Noclip = false,
    Fly = false,
    ESP = false
}

-- Functions
local function CreateTabButton(TabName, Position)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 90, 0, 30)
    Button.Position = Position
    Button.BackgroundColor3 = Tabs[TabName].Color
    Button.Text = TabName
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.Parent = TabButtonsFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        CurrentTab = TabName
        for _, Tab in pairs(TabsFrame:GetChildren()) do
            if Tab:IsA("Frame") then
                Tab.Visible = Tab.Name == TabName
            end
        end
    end)
    
    return Button
end

local function CreateTab(TabName)
    local Tab = Instance.new("Frame")
    Tab.Name = TabName
    Tab.Size = UDim2.new(1, 0, 1, 0)
    Tab.BackgroundTransparency = 1
    Tab.Visible = TabName == "Combat"
    Tab.Parent = TabsFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.Parent = Tab
    
    return Tab
end

local function CreateToggle(Name, Parent, Callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = Parent
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 120, 0, 30)
    ToggleButton.Position = UDim2.new(0, 0, 0, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    ToggleButton.Text = Name
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.TextSize = 14
    ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
    ToggleButton.Parent = ToggleFrame
    
    local ToggleStatus = Instance.new("Frame")
    ToggleStatus.Size = UDim2.new(0, 20, 0, 20)
    ToggleStatus.Position = UDim2.new(1, -25, 0, 5)
    ToggleStatus.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    ToggleStatus.Parent = ToggleButton
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = ToggleStatus
    Corner.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        Enabled[Name] = not Enabled[Name]
        ToggleStatus.BackgroundColor3 = Enabled[Name] and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
        if Callback then
            Callback(Enabled[Name])
        end
    end)
    
    return ToggleButton
end

local function CreateSlider(Name, Parent, Min, Max, Default, Callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = Parent
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Text = Name .. ": " .. Default
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = SliderFrame
    
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, 0, 0, 10)
    Slider.Position = UDim2.new(0, 0, 0, 30)
    Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Slider.Parent = SliderFrame
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(80, 120, 220)
    Fill.Parent = Slider
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Slider
    Corner.Parent = Fill
    
    local Value = Default
    local Dragging = false
    
    local function UpdateSlider(X)
        local RelativeX = math.clamp(X - Slider.AbsolutePosition.X, 0, Slider.AbsoluteSize.X)
        Value = math.floor(Min + (RelativeX / Slider.AbsoluteSize.X) * (Max - Min))
        Fill.Size = UDim2.new(RelativeX / Slider.AbsoluteSize.X, 0, 1, 0)
        Title.Text = Name .. ": " .. Value
        if Callback then
            Callback(Value)
        end
    end
    
    Slider.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            UpdateSlider(Input.Position.X)
        end
    end)
    
    Slider.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(Input.Position.X)
        end
    end)
    
    return SliderFrame
end

-- Create Tabs and UI Elements
local YPosition = 0
for TabName, _ in pairs(Tabs) do
    CreateTabButton(TabName, UDim2.new(0, 0, 0, YPosition))
    YPosition = YPosition + 35
end

local CombatTab = CreateTab("Combat")
local MovementTab = CreateTab("Movement")
local VisualsTab = CreateTab("Visuals")
local MiscTab = CreateTab("Misc")

-- Combat Tab Elements
CreateToggle("AimBot", CombatTab, function(State)
    if State then
        -- AimBot logic here
        print("AimBot enabled")
    else
        print("AimBot disabled")
    end
end)

CreateToggle("WallHack", CombatTab, function(State)
    if State then
        -- WallHack logic here
        print("WallHack enabled")
    else
        print("WallHack disabled")
    end
end)

-- Movement Tab Elements
CreateToggle("SpeedHack", MovementTab, function(State)
    if State then
        -- SpeedHack logic here
        print("SpeedHack enabled")
    else
        print("SpeedHack disabled")
    end
end)

CreateToggle("Fly", MovementTab, function(State)
    if State then
        -- Fly logic here
        print("Fly enabled")
    else
        print("Fly disabled")
    end
end)

CreateToggle("Noclip", MovementTab, function(State)
    if State then
        -- Noclip logic here
        print("Noclip enabled")
    else
        print("Noclip disabled")
    end
end)

CreateSlider("Speed", MovementTab, 16, 100, 16, function(Value)
    -- Speed value changed
    print("Speed set to: " .. Value)
end)

-- Visuals Tab Elements
CreateToggle("ESP", VisualsTab, function(State)
    if State then
        -- ESP logic here
        print("ESP enabled")
    else
        print("ESP disabled")
    end
end)

-- Misc Tab Elements
local UnloadButton = Instance.new("TextButton")
UnloadButton.Size = UDim2.new(1, 0, 0, 30)
UnloadButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
UnloadButton.Text = "Unload Script"
UnloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadButton.Font = Enum.Font.Gotham
UnloadButton.TextSize = 14
UnloadButton.Parent = MiscTab

UnloadButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    for _, Connection in pairs(Connections) do
        Connection:Disconnect()
    end
end)

-- UI Controls
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleButton.Visible = true
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleButton.Visible = false
end)

-- Keybind to open/close UI
UserInputService.InputBegan:Connect(function(Input, Processed)
    if not Processed and Input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        ToggleButton.Visible = not MainFrame.Visible
    end
end)

print("Deephub loaded successfully! Press RightShift to open/close the menu.")
