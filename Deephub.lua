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
Title.Text = "Deep Hub v3.2 - Sharkman Auto"
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
local LastActionTime = 0
local ActionCooldown = 2

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
    for _, NPC in pairs(Workspace.NPCs:GetChildren()) do
        if (NPC.Name:find("Sharkman") or NPC.Name:find("Shark") or NPC.Name:find("Master")) and NPC:FindFirstChild("Humanoid") then
            return NPC
        end
    end
    
    -- Search in entire workspace as fallback
    for _, NPC in pairs(Workspace:GetChildren()) do
        if (NPC.Name:find("Sharkman") or NPC.Name:find("Shark") or NPC.Name:find("Master")) and NPC:FindFirstChild("Humanoid") then
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

local function ClickAtPosition(x, y)
    -- Simulate mouse click at screen position
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

local function IsDialogOpen()
    local gui = LocalPlayer.PlayerGui:FindFirstChildOfClass("ScreenGui")
    if not gui then return false end
    
    for _, element in pairs(gui:GetDescendants()) do
        if element:IsA("TextLabel") and (element.Text:find("Train") or element.Text:find("Sharkman") or element.Text:find("Master")) then
            return true
        end
    end
    return false
end

local function IsFishBattleActive()
    local gui = LocalPlayer.PlayerGui:FindFirstChildOfClass("ScreenGui")
    if not gui then return false end
    
    for _, element in pairs(gui:GetDescendants()) do
        if element:IsA("TextButton") and (element.Text:find("Attack") or element.Text:find("Dodge") or element.Text:find("Select")) then
            return true
        end
    end
    return false
end

local function PerformRandomBattleAction()
    if math.random(1, 2) == 1 then
        FindAndClickButton("Attack")
    else
        FindAndClickButton("Dodge")
    end
end

local function SharkmanAutoFunction(State)
    if State then
        SharkmanConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.SharkmanAuto then return end
            
            local currentTime = tick()
            if currentTime - LastActionTime < ActionCooldown then return end
            
            local SharkmanNPC = FindSharkmanMaster()
            
            if not SharkmanNPC then
                print("Sharkman Master not found! Searching...")
                return
            end
            
            -- Check if we're in dialog or battle
            if IsDialogOpen() then
                -- In dialog, click Train options
                if FindAndClickButton("Train") or FindAndClickButton("Start") or FindAndClickButton("Training") then
                    LastActionTime = currentTime
                    CurrentBattleState = "InDialog"
                    print("Clicked dialog option")
                end
            elseif IsFishBattleActive() then
                -- In fish battle, perform actions
                PerformRandomBattleAction()
                LastActionTime = currentTime
                CurrentBattleState = "InBattle"
                print("Performed battle action")
            else
                -- Not in dialog or battle, move to Sharkman and interact
                local distance = (SharkmanNPC.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                
                if distance > 10 then
                    -- Move closer to Sharkman
                    HumanoidRootPart.CFrame = SharkmanNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    CurrentBattleState = "MovingToNPC"
                    print("Moving to Sharkman Master")
                else
                    -- Close enough, try to interact
                    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, SharkmanNPC.HumanoidRootPart.Position)
                    
                    -- Click on NPC to start dialog
                    local npcHead = SharkmanNPC:FindFirstChild("Head")
                    if npcHead then
                        local screenPoint = Workspace.CurrentCamera:WorldToViewportPoint(npcHead.Position)
                        if screenPoint.Z > 0 then
                            ClickAtPosition(screenPoint.X, screenPoint.Y)
                            LastActionTime = currentTime
                            CurrentBattleState = "Interacting"
                            print("Clicked on Sharkman Master")
                        end
                    end
                end
            end
        end)
    else
        if SharkmanConnection then
            SharkmanConnection:Disconnect()
        end
        CurrentBattleState = "Idle"
        print("Sharkman Auto disabled")
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
CreateToggle("AimBot", CombatTab, function(State) 
    Enabled.AimBot = State
    print("AimBot: " .. tostring(State))
end)

CreateToggle("AutoClick", CombatTab, function(State) 
    Enabled.AutoClick = State
    print("AutoClick: " .. tostring(State))
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

-- Visuals Tab
CreateToggle("ESP", VisualsTab, function(State) 
    Enabled.ESP = State
    print("ESP: " .. tostring(State))
end)

CreateToggle("WallHack", VisualsTab, function(State) 
    Enabled.WallHack = State
    print("WallHack: " .. tostring(State))
end)

-- Sharkman Tab
CreateToggle("Sharkman Auto", SharkmanTab, SharkmanAutoFunction)
CreateLabel("Headbands Progression:", SharkmanTab)
for i, Headband in ipairs(HeadbandsRequired) do
    CreateLabel(i .. ". " .. Headband, SharkmanTab)
end

-- Status label for Sharkman progress
local StatusLabel = CreateLabel("Status: Ready", SharkmanTab)
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 30)

local BattleStatusLabel = CreateLabel("State: Idle", SharkmanTab)
BattleStatusLabel.Name = "BattleStatusLabel"
BattleStatusLabel.Size = UDim2.new(1, 0, 0, 30)

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
            
            SharkmanTab.BattleStatusLabel.Text = "State: " .. CurrentBattleState
        end
    end
end)

-- Character reconnection
LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
    Humanoid = NewCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = NewCharacter:WaitForChild("HumanoidRootPart")
    print("Character reconnected")
end)

print("Deep Hub Sharkman Auto loaded!")
print("Press R to open menu")
print("Sharkman Auto Features:")
print("- Auto find Sharkman Master")
print("- Auto interact with NPC")
print("- Auto click dialog options")
print("- Auto perform battle actions")
print("- Headband progression tracking")
