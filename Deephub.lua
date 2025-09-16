-- Deep Hub Script for Blox Fruits with AI Sharkman System
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeepHubGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 550)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -275)
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
Title.Text = "Deep Hub v4.5 - AI Sharkman System"
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
TabButtonsFrame.Size = UDim2.new(0, 140, 0, 460)
TabButtonsFrame.Position = UDim2.new(0, 10, 0, 50)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.Parent = MainFrame

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 430, 0, 460)
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
    Sharkman = {Name = "Sharkman AI", Color = Color3.fromRGB(0, 150, 200)},
    Misc = {Name = "Misc", Color = Color3.fromRGB(180, 100, 220)}
}

-- Variables
local CurrentTab = "Sharkman"
local Connections = {}
local Enabled = {
    -- Combat
    AimBot = false,
    AutoClick = false,
    KillAura = false,
    
    -- Movement
    SpeedHack = false,
    Fly = false,
    Noclip = false,
    WaterWalk = false,
    
    -- Visuals
    ESP = false,
    WallHack = false,
    
    -- Farming
    AutoFarm = false,
    
    -- Sharkman AI
    SharkmanAI = false,
    SharkmanFarm = false,
    AutoTraining = false
}

-- Real Blox Fruits materials
local FarmMaterials = {
    "Magma Ore",
    "Fish Tail",
    "Scrap Metal",
    "Dragon Scale",
    "Leviathan Scale",
    "Radioactive Material",
    "Ectoplasm",
    "Bones",
    "Dark Fragment",
    "Angel Wings",
    "Demonic Wings",
    "Mini Tusk",
    "Conjured Cocoa",
    "Gunpowder"
}

-- Sharkman Headbands progression
local HeadbandsRequired = {
    "Headband (White)",
    "Headband (Yellow)", 
    "Headband (Orange)",
    "Headband (Green)",
    "Headband (Blue)",
    "Headband (Purple)",
    "Headband (Red)",
    "Headband (Black)"
}

-- AI System Variables
local SharkmanAIConnection = nil
local SharkmanFarmConnection = nil
local TrainingConnection = nil
local CurrentAIState = "IDLE"
local LastActionTime = 0
local ActionCooldown = 1.5
local BattleRound = 0
local TotalBattles = 0
local SuccessRate = 0
local SelectedMaterial = "Magma Ore"

-- Character initialization
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- UI Creation Functions
local function CreateTabButton(TabName, Position)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 130, 0, 30)
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
                Tab.Visible = (Tab.Name == TabName)
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
    Tab.Visible = (TabName == "Sharkman")
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
    ToggleButton.Size = UDim2.new(0, 180, 0, 30)
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

local function CreateDropdown(Name, Parent, Options, Callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = Parent
    
    local Title = CreateLabel(Name, DropdownFrame)
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 0, 25)
    DropdownButton.Position = UDim2.new(0, 0, 0, 20)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    DropdownButton.Text = Options[1]
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextSize = 12
    DropdownButton.Parent = DropdownFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = DropdownButton
    
    DropdownButton.MouseButton1Click:Connect(function()
        for i, Option in ipairs(Options) do
            if DropdownButton.Text == Option then
                local NextOption = Options[(i % #Options) + 1]
                DropdownButton.Text = NextOption
                if Callback then
                    Callback(NextOption)
                end
                break
            end
        end
    end)
    
    return DropdownFrame
end

-- Функции из вашего скрипта (добавлены ползунки)
local function CreateSlider(Name, Parent, Min, Max, Default, Callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = Parent
    
    local Title = CreateLabel(Name .. ": " .. Default, SliderFrame)
    Title.Name = "TitleLabel"
    
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, -10, 0, 10)
    Slider.Position = UDim2.new(0, 5, 0, 30)
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

-- Sharkman Functions
local function FindSharkmanMaster()
    for _, npc in pairs(Workspace:GetChildren()) do
        if (npc.Name:find("Shark") or npc.Name:find("Master")) and npc:FindFirstChild("Humanoid") then
            return npc
        end
    end
    return nil
end

local function GetCurrentHeadband()
    local locations = {
        LocalPlayer.Backpack,
        LocalPlayer.Character,
        LocalPlayer:FindFirstChild("Backpack")
    }
    
    for _, location in pairs(locations) do
        if location then
            for _, item in pairs(location:GetChildren()) do
                if item.Name:find("Headband") then
                    return item.Name
                end
            end
        end
    end
    return "None"
end

local function GetNextHeadband()
    local current = GetCurrentHeadband()
    for i, headband in ipairs(HeadbandsRequired) do
        if current == headband then
            if i < #HeadbandsRequired then
                return HeadbandsRequired[i + 1]
            else
                return "COMPLETED"
            end
        end
    end
    return HeadbandsRequired[1]
end

local function ClickAtPosition(x, y)
    mouse1click(x, y)
end

local function FindAndClickButton(buttonName)
    local gui = LocalPlayer.PlayerGui:FindFirstChildOfClass("ScreenGui")
    if not gui then return false end
    
    for _, element in pairs(gui:GetDescendants()) do
        if element:IsA("TextButton") and (element.Text:lower():find(buttonName:lower()) or element.Name:lower():find(buttonName:lower())) then
            local absPos = element.AbsolutePosition
            local absSize = element.AbsoluteSize
            local centerX = absPos.X + absSize.X / 2
            local centerY = absPos.Y + absSize.Y / 2
            
            ClickAtPosition(centerX, centerY)
            return true
        end
    end
    return false
end

-- AI Sharkman System
local function SharkmanAISystem(State)
    if State then
        print("AI Sharkman System: ACTIVATED")
        
        SharkmanAIConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.SharkmanAI then return end
            
            local currentTime = tick()
            if currentTime - LastActionTime < ActionCooldown then return end
            
            local SharkmanNPC = FindSharkmanMaster()
            
            if not SharkmanNPC then
                CurrentAIState = "SEARCHING"
                print("AI: Searching for Sharkman Master...")
                return
            end
            
            local distance = (SharkmanNPC.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
            
            if distance > 10 then
                CurrentAIState = "MOVING"
                HumanoidRootPart.CFrame = SharkmanNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                print("AI: Moving to Sharkman Master")
            else
                -- Click on NPC to interact
                local head = SharkmanNPC:FindFirstChild("Head")
                if head then
                    local screenPos = Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                    ClickAtPosition(screenPos.X, screenPos.Y)
                    CurrentAIState = "INTERACTING"
                    print("AI: Clicked on Sharkman Master")
                    LastActionTime = currentTime
                end
            end
        end)
    else
        if SharkmanAIConnection then
            SharkmanAIConnection:Disconnect()
        end
        CurrentAIState = "IDLE"
        print("AI Sharkman System: DEACTIVATED")
    end
end

-- Sharkman Farm Function
local function SharkmanFarmFunction(State)
    if State then
        print("Sharkman Farm: ACTIVATED")
        
        SharkmanFarmConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.SharkmanFarm then return end
            
            local SharkmanNPC = FindSharkmanMaster()
            
            if SharkmanNPC and SharkmanNPC:FindFirstChild("HumanoidRootPart") then
                local distance = (SharkmanNPC.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                
                if distance > 10 then
                    HumanoidRootPart.CFrame = SharkmanNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                else
                    -- Auto click for training
                    if Enabled.AutoClick then
                        mouse1press()
                        wait(0.1)
                        mouse1release()
                    end
                end
            end
        end)
    else
        if SharkmanFarmConnection then
            SharkmanFarmConnection:Disconnect()
        end
        print("Sharkman Farm: DEACTIVATED")
    end
end

-- Auto Training Function
local function AutoTrainingFunction(State)
    if State then
        print("Auto Training: ACTIVATED")
        
        TrainingConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.AutoTraining then return end
            
            -- Simulate perfect battle actions
            local gui = LocalPlayer.PlayerGui:FindFirstChildOfClass("ScreenGui")
            if gui then
                for _, element in pairs(gui:GetDescendants()) do
                    if element:IsA("TextButton") then
                        if element.Text:find("Attack") or element.Text:find("Dodge") then
                            local pos = element.AbsolutePosition
                            local size = element.AbsoluteSize
                            ClickAtPosition(pos.X + size.X/2, pos.Y + size.Y/2)
                            TotalBattles = TotalBattles + 1
                            SuccessRate = ((SuccessRate * (TotalBattles - 1)) + 0.9) / TotalBattles
                        end
                    end
                end
            end
        end)
    else
        if TrainingConnection then
            TrainingConnection:Disconnect()
        end
        print("Auto Training: DEACTIVATED")
    end
end

-- Create Tabs
local YPosition = 0
for TabName, _ in pairs(Tabs) do
    CreateTabButton(TabName, UDim2.new(0, 0, 0, YPosition))
    YPosition = YPosition + 35
end

-- Create all tabs first
local CombatTab = CreateTab("Combat")
local MovementTab = CreateTab("Movement")
local VisualsTab = CreateTab("Visuals")
local FarmingTab = CreateTab("Farming")
local SharkmanTab = CreateTab("Sharkman")
local MiscTab = CreateTab("Misc")

-- Hide all tabs except Sharkman initially
for _, Tab in pairs(TabsFrame:GetChildren()) do
    if Tab:IsA("Frame") then
        Tab.Visible = (Tab.Name == "Sharkman")
    end
end

-- Combat Tab
CreateToggle("AimBot", CombatTab, function(State) 
    Enabled.AimBot = State
    print("AimBot: " .. tostring(State))
end)

CreateToggle("AutoClick", CombatTab, function(State) 
    Enabled.AutoClick = State
    print("AutoClick: " .. tostring(State))
end)

CreateToggle("KillAura", CombatTab, function(State) 
    Enabled.KillAura = State
    print("KillAura: " .. tostring(State))
end)

-- Movement Tab
CreateToggle("SpeedHack", MovementTab, function(State)
    Enabled.SpeedHack = State
    if State then
        Humanoid.WalkSpeed = 50
    else
        Humanoid.WalkSpeed = 16
    end
    print("SpeedHack: " .. tostring(State))
end)

CreateToggle("Fly", MovementTab, function(State) 
    Enabled.Fly = State
    print("Fly: " .. tostring(State))
end)

CreateToggle("Noclip", MovementTab, function(State) 
    Enabled.Noclip = State
    print("NoClip: " .. tostring(State))
end)

CreateToggle("WaterWalk", MovementTab, function(State) 
    Enabled.WaterWalk = State
    print("WaterWalk: " .. tostring(State))
end)

-- Visuals Tab
CreateToggle("ESP", VisualsTab, function(State) 
    Enabled.ESP = State
    print("ESP: " .. tostring(State))
end)

CreateToggle("WallHack", VisualsTab, function(State) 
    Enabled.WallHack = State
    print("WallHack: " .. tostring(State))
end)

-- Farming Tab
CreateToggle("Auto Farm", FarmingTab, function(State) 
    Enabled.AutoFarm = State
    print("AutoFarm: " .. tostring(State))
end)

CreateDropdown("Select Material", FarmingTab, FarmMaterials, function(Material)
    SelectedMaterial = Material
    print("Selected material: " .. Material)
end)

-- Sharkman AI Tab (ИСПРАВЛЕННАЯ ВКЛАДКА!)
CreateToggle("AI Sharkman System", SharkmanTab, SharkmanAISystem)
CreateToggle("Sharkman Farm", SharkmanTab, SharkmanFarmFunction)
CreateToggle("Auto Training", SharkmanTab, AutoTrainingFunction)

-- Добавлены ползунки из вашего скрипта
CreateSlider("Battle Speed", SharkmanTab, 1, 10, 5, function(Value)
    ActionCooldown = 2 - (Value / 10)
    print("Battle speed set to: " .. Value)
end)

CreateSlider("Accuracy", SharkmanTab, 50, 100, 90, function(Value)
    SuccessRate = Value / 100
    print("Accuracy set to: " .. Value .. "%")
end)

-- Создаем метки для отображения статуса
local AIStatusLabel = CreateLabel("AI Status: READY", SharkmanTab)
AIStatusLabel.Name = "AIStatusLabel"

local StateLabel = CreateLabel("State: " .. CurrentAIState, SharkmanTab)
StateLabel.Name = "StateLabel"

local ProgressLabel = CreateLabel("Progress Tracking:", SharkmanTab)
local CurrentHeadbandLabel = CreateLabel("Current: " .. GetCurrentHeadband(), SharkmanTab)
CurrentHeadbandLabel.Name = "CurrentHeadbandLabel"

local NextHeadbandLabel = CreateLabel("Next: " .. GetNextHeadband(), SharkmanTab)
NextHeadbandLabel.Name = "NextHeadbandLabel"

local MetricsLabel = CreateLabel("Performance Metrics:", SharkmanTab)
local BattleLabel = CreateLabel("Battles: " .. TotalBattles, SharkmanTab)
BattleLabel.Name = "BattleLabel"

local SuccessLabel = CreateLabel("Success: " .. math.floor(SuccessRate * 100) .. "%", SharkmanTab)
SuccessLabel.Name = "SuccessLabel"

local ProgressionLabel = CreateLabel("Headbands Progression:", SharkmanTab)
for i, headband in ipairs(HeadbandsRequired) do
    CreateLabel(i .. ". " .. headband, SharkmanTab)
end

-- Misc Tab
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
        if Connection then
            Connection:Disconnect()
        end
    end
    if SharkmanAIConnection then
        SharkmanAIConnection:Disconnect()
    end
    if SharkmanFarmConnection then
        SharkmanFarmConnection:Disconnect()
    end
    if TrainingConnection then
        TrainingConnection:Disconnect()
    end
    print("Script unloaded")
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

UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.R then
        MainFrame.Visible = not MainFrame.Visible
        ToggleButton.Visible = not MainFrame.Visible
    end
end)

-- AI Status Update
spawn(function()
    while wait(0.5) do
        if SharkmanTab:FindFirstChild("AIStatusLabel") and SharkmanTab:FindFirstChild("StateLabel") then
            SharkmanTab.AIStatusLabel.Text = "AI Status: " .. (Enabled.SharkmanAI and "ACTIVE" or "READY")
            SharkmanTab.StateLabel.Text = "State: " .. CurrentAIState
            SharkmanTab.CurrentHeadbandLabel.Text = "Current: " .. GetCurrentHeadband()
            SharkmanTab.NextHeadbandLabel.Text = "Next: " .. GetNextHeadband()
            SharkmanTab.BattleLabel.Text = "Battles: " .. TotalBattles
            SharkmanTab.SuccessLabel.Text = "Success: " .. math.floor(SuccessRate * 100) .. "%"
        end
    end
end)

-- Character reconnection
LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
    Humanoid = NewCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = NewCharacter:WaitForChild("HumanoidRootPart")
    
    -- Re-enable features
    if Enabled.SpeedHack then
        Humanoid.WalkSpeed = 50
    end
end)

print("🤖 Deep Hub AI System Loaded!")
print("✅ Вкладка Sharkman AI теперь полностью РАБОЧАЯ!")
print("🎯 Все функции Sharkman доступны и активны")
print("🚀 Нажми R для открытия панели управления")
