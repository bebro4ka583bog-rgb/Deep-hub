-- Deephub Script for Blox Fruits with Sharkman Karate Auto Farm
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeephubGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 450)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
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
Title.Text = "Deephub v3.5 - Blox Fruits"
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
TabButtonsFrame.Size = UDim2.new(0, 130, 0, 360)
TabButtonsFrame.Position = UDim2.new(0, 10, 0, 50)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.Parent = MainFrame

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 340, 0, 360)
TabsFrame.Position = UDim2.new(0, 150, 0, 50)
TabsFrame.BackgroundTransparency = 1
TabsFrame.ClipsDescendants = true
TabsFrame.Parent = MainFrame

-- Tabs
local Tabs = {
    Combat = {Name = "Combat", Color = Color3.fromRGB(220, 80, 80)},
    Movement = {Name = "Movement", Color = Color3.fromRGB(80, 180, 80)},
    Visuals = {Name = "Visuals", Color = Color3.fromRGB(80, 120, 220)},
    Farming = {Name = "Farming", Color = Color3.fromRGB(220, 180, 60)},
    Sharkman = {Name = "Sharkman", Color = Color3.fromRGB(0, 150, 200)},
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
    ESP = false,
    AutoFarm = false,
    AutoClick = false,
    NoClip = false,
    SharkmanFarm = false,
    InfiniteEnergy = false
}

-- Blox Fruits Variables
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Sharkman Karate Variables
local SharkmanMaster = nil
local CurrentHeadband = nil
local HeadbandsRequired = {
    "Headband (Green)",
    "Headband (Blue)", 
    "Headband (Red)",
    "Headband (Yellow)",
    "Headband (Purple)",
    "Headband (Orange)",
    "Headband (Brown)",
    "Headband (White)",
    "Headband (Black)"
}

-- Redz Hub Features
local AimBotTarget = nil
local ESPObjects = {}
local FarmConnection = nil
local ClickConnection = nil
local NoclipConnection = nil
local FlyConnection = nil
local SharkmanConnection = nil

-- Functions
local function CreateTabButton(TabName, Position)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 120, 0, 30)
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
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = Tab
    
    return Tab
end

local function CreateToggle(Name, Parent, Callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = Parent
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 160, 0, 30)
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

local function CreateLabel(Text, Parent)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Parent
    return Label
end

-- Sharkman Karate Functions
local function FindSharkmanMaster()
    for _, NPC in pairs(Workspace:GetChildren()) do
        if NPC.Name == "Sharkman" and NPC:FindFirstChild("Humanoid") then
            return NPC
        end
    end
    return nil
end

local function GetCurrentHeadband()
    -- Check player's inventory for headbands
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    local Character = LocalPlayer.Character
    
    if Backpack then
        for _, Item in pairs(Backpack:GetChildren()) do
            if string.find(Item.Name, "Headband") then
                return Item.Name
            end
        end
    end
    
    if Character then
        for _, Item in pairs(Character:GetChildren()) do
            if string.find(Item.Name, "Headband") then
                return Item.Name
            end
        end
    end
    
    return nil
end

local function GetNextHeadband()
    local Current = CurrentHeadband or "None"
    
    for i, Headband in ipairs(HeadbandsRequired) do
        if Current == Headband then
            if i < #HeadbandsRequired then
                return HeadbandsRequired[i + 1]
            else
                return "COMPLETED"
            end
        end
    end
    
    return HeadbandsRequired[1] -- Start with first headband
end

local function TeleportToSharkman()
    SharkmanMaster = FindSharkmanMaster()
    if SharkmanMaster and SharkmanMaster:FindFirstChild("HumanoidRootPart") then
        HumanoidRootPart.CFrame = SharkmanMaster.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
        return true
    end
    return false
end

local function SharkmanFarmFunction(State)
    if State then
        SharkmanConnection = RunService.Heartbeat:Connect(function()
            if Enabled.SharkmanFarm then
                CurrentHeadband = GetCurrentHeadband()
                local NextHeadband = GetNextHeadband()
                
                if NextHeadband == "COMPLETED" then
                    print("Sharkman Karate training completed!")
                    Enabled.SharkmanFarm = false
                    return
                end
                
                -- Teleport to Sharkman Master
                if TeleportToSharkman() then
                    -- Simulate talking to NPC (this would need actual remote events)
                    -- For now, just show status
                    print("Training Sharkman Karate... Current: " .. (CurrentHeadband or "None") .. " | Next: " .. NextHeadband)
                    
                    -- Auto farm the required headband if not owned
                    if not CurrentHeadband or CurrentHeadband ~= NextHeadband then
                        -- This would need actual farming logic for each headband
                        print("Need to farm: " .. NextHeadband)
                    end
                else
                    print("Sharkman Master not found!")
                end
                
                wait(2) -- Prevent spamming
            end
        end)
    else
        if SharkmanConnection then
            SharkmanConnection:Disconnect()
        end
    end
end

-- Redz Hub Functions (остальные функции остаются без изменений)
local function AimBotFunction(State)
    if State then
        Connections.AimBot = RunService.RenderStepped:Connect(function()
            local ClosestPlayer = nil
            local ClosestDistance = math.huge
            
            for _, Player in pairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local Distance = (Player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                    if Distance < ClosestDistance then
                        ClosestDistance = Distance
                        ClosestPlayer = Player
                    end
                end
            end
            
            if ClosestPlayer and ClosestPlayer.Character and ClosestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                AimBotTarget = ClosestPlayer.Character.HumanoidRootPart
                if AimBotTarget then
                    local Camera = Workspace.CurrentCamera
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, AimBotTarget.Position)
                end
            end
        end)
    else
        if Connections.AimBot then
            Connections.AimBot:Disconnect()
            AimBotTarget = nil
        end
    end
end

local function ESPFunction(State)
    -- ... (остальной код ESP) ...
end

local function FlyFunction(State)
    -- ... (остальной код Fly) ...
end

local function NoclipFunction(State)
    -- ... (остальной код Noclip) ...
end

local function SpeedHackFunction(State)
    -- ... (остальной код SpeedHack) ...
end

local function AutoFarmFunction(State)
    -- ... (остальной код AutoFarm) ...
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
local FarmingTab = CreateTab("Farming")
local SharkmanTab = CreateTab("Sharkman")
local MiscTab = CreateTab("Misc")

-- Combat Tab Elements
CreateToggle("AimBot", CombatTab, AimBotFunction)
CreateToggle("AutoClick", CombatTab, function(State)
    -- Auto click function
end)

-- Movement Tab Elements
CreateToggle("SpeedHack", MovementTab, SpeedHackFunction)
CreateToggle("Fly", MovementTab, FlyFunction)
CreateToggle("Noclip", MovementTab, NoclipFunction)

-- Sharkman Tab Elements
CreateToggle("Auto Sharkman", SharkmanTab, SharkmanFarmFunction)
CreateLabel("Headbands Progression:", SharkmanTab)

for i, Headband in ipairs(HeadbandsRequired) do
    CreateLabel(i .. ". " .. Headband, SharkmanTab)
end

local StatusLabel = CreateLabel("Status: Not started", SharkmanTab)
StatusLabel.Name = "StatusLabel"

-- Visuals Tab Elements
CreateToggle("ESP", VisualsTab, ESPFunction)
CreateToggle("WallHack", VisualsTab, function(State)
    -- Wallhack function
end)

-- Farming Tab Elements
CreateToggle("AutoFarm", FarmingTab, AutoFarmFunction)

-- Misc Tab Elements
local UnloadButton = Instance.new("TextButton")
UnloadButton.Size = UDim2.new(1, -20, 0, 30)
UnloadButton.Position = UDim2.new(0, 10, 0, 0)
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
    for _, Connection in pairs({FarmConnection, ClickConnection, NoclipConnection, FlyConnection, SharkmanConnection}) do
        if Connection then
            Connection:Disconnect()
        end
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
    if not Processed and Input.KeyCode == Enum.KeyCode.R then
        MainFrame.Visible = not MainFrame.Visible
        ToggleButton.Visible = not MainFrame.Visible
    end
end)

-- Update Sharkman status
spawn(function()
    while wait(2) do
        if SharkmanTab:FindFirstChild("StatusLabel") then
            CurrentHeadband = GetCurrentHeadband()
            local NextHeadband = GetNextHeadband()
            
            if NextHeadband == "COMPLETED" then
                SharkmanTab.StatusLabel.Text = "Status: COMPLETED! 🎉"
            else
                SharkmanTab.StatusLabel.Text = "Status: Current: " .. (CurrentHeadband or "None") .. " | Next: " .. NextHeadband
            end
        end
    end
end)

print("Deephub Sharkman Edition loaded! Press R to open menu.")
print("Sharkman Karate requires 9 headbands in order:")
for i, Headband in ipairs(HeadbandsRequired) do
    print(i .. ". " .. Headband)
end
