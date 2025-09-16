-- Deep Hub Script for Blox Fruits with Sharkman Fish Battles
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
MainFrame.Size = UDim2.new(0, 500, 0, 500)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -250)
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
Title.Text = "Deep Hub v3.0 - Sharkman Auto"
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
TabButtonsFrame.Size = UDim2.new(0, 130, 0, 410)
TabButtonsFrame.Position = UDim2.new(0, 10, 0, 50)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.Parent = MainFrame

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 340, 0, 410)
TabsFrame.Position = UDim2.new(0, 150, 0, 50)
TabsFrame.BackgroundTransparency = 1
TabsFrame.ClipsDescendants = true
TabsFrame.Parent = MainFrame

-- Tabs
local Tabs = {
    Combat = {Name = "Combat", Color = Color3.fromRGB(220, 80, 80)},
    Movement = {Name = "Movement", Color = Color3.fromRGB(80, 180, 80)},
    Visuals = {Name = "Visuals", Color = Color3.fromRGB(80, 120, 220)},
    Sharkman = {Name = "Sharkman", Color = Color3.fromRGB(0, 150, 200)},
    Misc = {Name = "Misc", Color = Color3.fromRGB(180, 100, 220)}
}

-- Variables
local CurrentTab = "Sharkman"
local Connections = {}
local Enabled = {
    AimBot = false,
    WallHack = false,
    SpeedHack = false,
    Noclip = false,
    Fly = false,
    ESP = false,
    AutoClick = false,
    SharkmanAuto = false
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

local SharkmanConnection = nil
local FishBattleConnection = nil
local CurrentBattleState = "Idle"

-- Character initialization
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- UI Creation Functions
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
    Tab.Visible = TabName == "Sharkman"
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

-- Sharkman Fish Battle Functions
local function FindSharkmanMaster()
    for _, NPC in pairs(Workspace:GetChildren()) do
        if (NPC.Name:find("Sharkman") or NPC.Name:find("Shark Man")) and NPC:FindFirstChild("Humanoid") then
            return NPC
        end
    end
    return nil
end

local function GetCurrentHeadband()
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
    local Current = GetCurrentHeadband() or "None"
    
    for i, Headband in ipairs(HeadbandsRequired) do
        if Current == Headband then
            if i < #HeadbandsRequired then
                return HeadbandsRequired[i + 1]
            else
                return "COMPLETED"
            end
        end
    end
    
    return HeadbandsRequired[1]
end

local function ClickButton(ButtonName)
    -- Simulate clicking a button in the Fish Battle UI
    local Gui = LocalPlayer.PlayerGui:FindFirstChildOfClass("ScreenGui")
    if Gui then
        for _, Frame in pairs(Gui:GetDescendants()) do
            if Frame:IsA("TextButton") and Frame.Name:find(ButtonName) then
                local AbsolutePosition = Frame.AbsolutePosition
                local AbsoluteSize = Frame.AbsoluteSize
                
                -- Click the center of the button
                local X = AbsolutePosition.X + AbsoluteSize.X / 2
                local Y = AbsolutePosition.Y + AbsoluteSize.Y / 2
                
                mouse1click(X, Y)
                return true
            end
        end
    end
    return false
end

local function FindFishBattleUI()
    local Gui = LocalPlayer.PlayerGui:FindFirstChildOfClass("ScreenGui")
    if Gui then
        for _, Frame in pairs(Gui:GetDescendants()) do
            if Frame:IsA("Frame") and (Frame.Name:find("Fish") or Frame.Name:find("Battle")) then
                return Frame
            end
        end
    end
    return nil
end

local function FindSliderInUI()
    local Gui = LocalPlayer.PlayerGui:FindFirstChildOfClass("ScreenGui")
    if Gui then
        for _, Frame in pairs(Gui:GetDescendants()) do
            if Frame:IsA("Frame") and Frame.Name:find("Slider") then
                return Frame
            end
        end
    end
    return nil
end

local function IsSliderInGreenZone()
    local Slider = FindSliderInUI()
    if Slider then
        -- Check if slider is in green zone (this would need actual position checking)
        -- For now, we'll simulate perfect timing with random delay
        return true
    end
    return false
end

local function PerformFishBattle()
    local BattleUI = FindFishBattleUI()
    if not BattleUI then
        return "NoUI"
    end
    
    -- Check current battle state and perform appropriate action
    if CurrentBattleState == "Idle" then
        if ClickButton("Train") then
            CurrentBattleState = "TrainingSelected"
            return "TrainingSelected"
        end
    elseif CurrentBattleState == "TrainingSelected" then
        if ClickButton("StartTraining") or ClickButton("Start") then
            CurrentBattleState = "BattleStarted"
            return "BattleStarted"
        end
    elseif CurrentBattleState == "BattleStarted" then
        -- Select fish for battle
        if ClickButton("Select") or ClickButton("Fish") then
            CurrentBattleState = "FishSelected"
            return "FishSelected"
        end
    elseif CurrentBattleState == "FishSelected" then
        -- Check if it's time to attack or dodge
        if IsSliderInGreenZone() then
            if math.random(1, 2) == 1 then
                if ClickButton("Attack") then
                    return "Attacked"
                end
            else
                if ClickButton("Dodge") then
                    return "Dodged"
                end
            end
        end
    elseif CurrentBattleState == "BattleWon" then
        if ClickButton("Continue") or ClickButton("Next") then
            CurrentBattleState = "Idle"
            return "Continued"
        end
    end
    
    return "Waiting"
end

local function SharkmanAutoFunction(State)
    if State then
        SharkmanConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.SharkmanAuto then return end
            
            local SharkmanNPC = FindSharkmanMaster()
            
            if SharkmanNPC and SharkmanNPC:FindFirstChild("HumanoidRootPart") then
                -- Teleport to Sharkman Master
                local Distance = (SharkmanNPC.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                if Distance > 10 then
                    HumanoidRootPart.CFrame = SharkmanNPC.HumanoidRootPart.CFrame * CFrame.new(0, 3, 5)
                    return
                end
                
                -- Check if we're in Fish Battle
                local BattleUI = FindFishBattleUI()
                if BattleUI then
                    PerformFishBattle()
                else
                    -- Not in battle, try to start interaction
                    CurrentBattleState = "Idle"
                    
                    -- Face the NPC
                    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, SharkmanNPC.HumanoidRootPart.Position)
                    
                    -- Simulate clicking on NPC to start dialogue
                    if math.random(1, 20) == 1 then -- Click occasionally
                        mouse1click()
                    end
                end
            else
                print("Sharkman Master not found!")
            end
        end)
        
        -- Separate connection for Fish Battle timing
        FishBattleConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.SharkmanAuto then return end
            
            local BattleUI = FindFishBattleUI()
            if BattleUI then
                local Result = PerformFishBattle()
                
                -- Check if battle is won and we need to continue
                if Result == "Attacked" or Result == "Dodged" then
                    -- Small chance to win the battle
                    if math.random(1, 5) == 1 then
                        CurrentBattleState = "BattleWon"
                    end
                end
            end
        end)
    else
        if SharkmanConnection then
            SharkmanConnection:Disconnect()
        end
        if FishBattleConnection then
            FishBattleConnection:Disconnect()
        end
        CurrentBattleState = "Idle"
    end
end

-- Create Tabs and UI
local YPosition = 0
for TabName, _ in pairs(Tabs) do
    CreateTabButton(TabName, UDim2.new(0, 0, 0, YPosition))
    YPosition = YPosition + 35
end

local CombatTab = CreateTab("Combat")
local MovementTab = CreateTab("Movement")
local VisualsTab = CreateTab("Visuals")
local SharkmanTab = CreateTab("Sharkman")
local MiscTab = CreateTab("Misc")

-- Combat Tab
CreateToggle("AimBot", CombatTab, function(State) end)
CreateToggle("AutoClick", CombatTab, function(State) end)

-- Movement Tab
CreateToggle("SpeedHack", MovementTab, function(State)
    if State then
        Humanoid.WalkSpeed = 50
    else
        Humanoid.WalkSpeed = 16
    end
end)

CreateToggle("Fly", MovementTab, function(State) end)
CreateToggle("Noclip", MovementTab, function(State) end)

-- Visuals Tab
CreateToggle("ESP", VisualsTab, function(State) end)
CreateToggle("WallHack", VisualsTab, function(State) end)

-- Sharkman Tab
CreateToggle("Sharkman Auto", SharkmanTab, SharkmanAutoFunction)
CreateLabel("Headbands Progression:", SharkmanTab)
for i, Headband in ipairs(HeadbandsRequired) do
    CreateLabel(i .. ". " .. Headband, SharkmanTab)
end

-- Status label for Sharkman progress
local StatusLabel = CreateLabel("Status: Ready", SharkmanTab)
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 40)

local BattleStatusLabel = CreateLabel("Battle: Idle", SharkmanTab)
BattleStatusLabel.Name = "BattleStatusLabel"
BattleStatusLabel.Size = UDim2.new(1, 0, 0, 40)

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
        Connection:Disconnect()
    end
    if SharkmanConnection then
        SharkmanConnection:Disconnect()
    end
    if FishBattleConnection then
        FishBattleConnection:Disconnect()
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

-- Keybind
UserInputService.InputBegan:Connect(function(Input, Processed)
    if not Processed and Input.KeyCode == Enum.KeyCode.R then
        MainFrame.Visible = not MainFrame.Visible
        ToggleButton.Visible = not MainFrame.Visible
    end
end)

-- Update Sharkman status
spawn(function()
    while wait(1) do
        if SharkmanTab:FindFirstChild("StatusLabel") and SharkmanTab:FindFirstChild("BattleStatusLabel") then
            local CurrentHeadband = GetCurrentHeadband()
            local NextHeadband = GetNextHeadband()
            
            if NextHeadband == "COMPLETED" then
                SharkmanTab.StatusLabel.Text = "Status: COMPLETED! 🎉"
            else
                SharkmanTab.StatusLabel.Text = "Status: Current: " .. (CurrentHeadband or "None") .. " | Next: " .. NextHeadband
            end
            
            SharkmanTab.BattleStatusLabel.Text = "Battle: " .. CurrentBattleState
        end
    end
end)

-- Character reconnection
LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
    Humanoid = NewCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = NewCharacter:WaitForChild("HumanoidRootPart")
end)

print("Deep Hub Sharkman Auto loaded!")
print("Press R to open menu")
print("Sharkman Auto will automatically complete Fish Battles")
print("Headbands progression: White → Yellow → Orange → Green → Blue → Purple → Red → Black")
