-- Deep Hub Script for Blox Fruits
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
MainFrame.Size = UDim2.new(0, 450, 0, 450)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -225)
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
Title.Text = "Deep Hub v2.5"
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
TabButtonsFrame.Size = UDim2.new(0, 120, 0, 360)
TabButtonsFrame.Position = UDim2.new(0, 10, 0, 50)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.Parent = MainFrame

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 300, 0, 360)
TabsFrame.Position = UDim2.new(0, 130, 0, 50)
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

-- Variables
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
    SharkmanFarm = false
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

local SelectedMaterial = "Magma Ore"
local AimBotTarget = nil
local ESPObjects = {}
local FarmConnection = nil
local ClickConnection = nil
local NoclipConnection = nil
local FlyConnection = nil
local SharkmanConnection = nil

-- Character initialization
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- UI Creation Functions
local function CreateTabButton(TabName, Position)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 110, 0, 30)
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
    ToggleButton.Size = UDim2.new(0, 140, 0, 30)
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

-- Functional Functions
local function AimBotFunction(State)
    if State then
        Connections.AimBot = RunService.RenderStepped:Connect(function()
            local ClosestPlayer = nil
            local ClosestDistance = math.huge
            
            for _, Player in pairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
                    local Distance = (Player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                    if Distance < ClosestDistance then
                        ClosestDistance = Distance
                        ClosestPlayer = Player
                    end
                end
            end
            
            if ClosestPlayer and ClosestPlayer.Character and ClosestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                AimBotTarget = ClosestPlayer.Character.HumanoidRootPart
            end
        end)
    else
        if Connections.AimBot then
            Connections.AimBot:Disconnect()
        end
        AimBotTarget = nil
    end
end

local function ESPFunction(State)
    if State then
        local function CreateESP(Character)
            if Character ~= LocalPlayer.Character and not ESPObjects[Character] then
                local Highlight = Instance.new("Highlight")
                Highlight.Name = "DeepHubESP"
                Highlight.Adornee = Character
                Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                Highlight.FillTransparency = 0.5
                Highlight.Parent = Character
                ESPObjects[Character] = Highlight
            end
        end
        
        for _, Player in pairs(Players:GetPlayers()) do
            if Player.Character then
                CreateESP(Player.Character)
            end
        end
        
        Connections.ESPAdded = Players.PlayerAdded:Connect(function(Player)
            Player.CharacterAdded:Connect(function(Character)
                if Enabled.ESP then
                    CreateESP(Character)
                end
            end)
        end)
    else
        for Character, Highlight in pairs(ESPObjects) do
            if Highlight then
                Highlight:Destroy()
            end
        end
        ESPObjects = {}
        
        if Connections.ESPAdded then
            Connections.ESPAdded:Disconnect()
        end
    end
end

local function FlyFunction(State)
    if State then
        FlyConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.Fly then return end
            
            local Camera = Workspace.CurrentCamera
            local FlySpeed = 50
            local Velocity = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                Velocity = Velocity + Camera.CFrame.LookVector * FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                Velocity = Velocity - Camera.CFrame.LookVector * FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                Velocity = Velocity - Camera.CFrame.RightVector * FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                Velocity = Velocity + Camera.CFrame.RightVector * FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                Velocity = Velocity + Vector3.new(0, FlySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                Velocity = Velocity - Vector3.new(0, FlySpeed, 0)
            end
            
            HumanoidRootPart.Velocity = Velocity
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
        end
        HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    end
end

local function NoclipFunction(State)
    if State then
        NoclipConnection = RunService.Stepped:Connect(function()
            if Character then
                for _, Part in pairs(Character:GetDescendants()) do
                    if Part:IsA("BasePart") then
                        Part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
        end
    end
end

local function SpeedHackFunction(State)
    if State then
        Humanoid.WalkSpeed = 50
    else
        Humanoid.WalkSpeed = 16
    end
end

local function AutoClickFunction(State)
    if State then
        ClickConnection = RunService.Heartbeat:Connect(function()
            if Enabled.AutoClick then
                mouse1press()
                wait(0.1)
                mouse1release()
            end
        end)
    else
        if ClickConnection then
            ClickConnection:Disconnect()
        end
    end
end

local function MaterialFarmFunction(State)
    if State then
        FarmConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.AutoFarm then return end
            
            -- Farm NPCs for materials
            for _, NPC in pairs(Workspace:GetChildren()) do
                if NPC:FindFirstChild("Humanoid") and NPC:FindFirstChild("HumanoidRootPart") and NPC.Humanoid.Health > 0 then
                    local Distance = (NPC.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                    if Distance < 100 then
                        HumanoidRootPart.CFrame = NPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        if Enabled.AutoClick then
                            mouse1press()
                            wait(0.1)
                            mouse1release()
                        end
                        break
                    end
                end
            end
            
            -- Farm actual material items
            for _, Item in pairs(Workspace:GetChildren()) do
                if table.find(FarmMaterials, Item.Name) and Item:IsA("Part") then
                    local Distance = (Item.Position - HumanoidRootPart.Position).Magnitude
                    if Distance < 50 then
                        HumanoidRootPart.CFrame = Item.CFrame
                        break
                    end
                end
            end
        end)
    else
        if FarmConnection then
            FarmConnection:Disconnect()
        end
    end
end

local function WallHackFunction(State)
    if State then
        Lighting.GlobalShadows = false
        for _, Part in pairs(Workspace:GetDescendants()) do
            if Part:IsA("Part") or Part:IsA("MeshPart") then
                if Part.Transparency < 0.5 then
                    Part.Transparency = 0.5
                end
            end
        end
    else
        Lighting.GlobalShadows = true
        for _, Part in pairs(Workspace:GetDescendants()) do
            if Part:IsA("Part") or Part:IsA("MeshPart") then
                if Part.Transparency == 0.5 then
                    Part.Transparency = 0
                end
            end
        end
    end
end

-- Sharkman Functions
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

local function FindSharkmanMaster()
    for _, NPC in pairs(Workspace:GetChildren()) do
        if NPC.Name:find("Sharkman") and NPC:FindFirstChild("Humanoid") then
            return NPC
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

local function SharkmanFarmFunction(State)
    if State then
        SharkmanConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.SharkmanFarm then return end
            
            local SharkmanNPC = FindSharkmanMaster()
            
            if SharkmanNPC and SharkmanNPC:FindFirstChild("HumanoidRootPart") then
                -- Teleport to Sharkman Master
                HumanoidRootPart.CFrame = SharkmanNPC.HumanoidRootPart.CFrame * CFrame.new(0, 3, 5)
                
                -- Get current progress
                local CurrentHeadband = GetCurrentHeadband()
                local NextHeadband = GetNextHeadband()
                
                if NextHeadband == "COMPLETED" then
                    print("Sharkman Karate training completed!")
                    return
                end
                
                -- Simulate interaction (this would need actual remote events)
                -- For now, just show status
                print("Training with Sharkman Master...")
                print("Current: " .. (CurrentHeadband or "None"))
                print("Next: " .. NextHeadband)
                
                -- Auto attack to train
                if Enabled.AutoClick then
                    mouse1press()
                    wait(0.1)
                    mouse1release()
                end
            else
                print("Sharkman Master not found!")
            end
            
            wait(2) -- Prevent spamming
        end)
    else
        if SharkmanConnection then
            SharkmanConnection:Disconnect()
        end
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
local FarmingTab = CreateTab("Farming")
local SharkmanTab = CreateTab("Sharkman")
local MiscTab = CreateTab("Misc")

-- Combat Tab
CreateToggle("AimBot", CombatTab, AimBotFunction)
CreateToggle("AutoClick", CombatTab, AutoClickFunction)

-- Movement Tab
CreateToggle("SpeedHack", MovementTab, SpeedHackFunction)
CreateToggle("Fly", MovementTab, FlyFunction)
CreateToggle("Noclip", MovementTab, NoclipFunction)

-- Visuals Tab
CreateToggle("ESP", VisualsTab, ESPFunction)
CreateToggle("WallHack", VisualsTab, WallHackFunction)

-- Farming Tab
CreateToggle("Auto Farm", FarmingTab, MaterialFarmFunction)
CreateDropdown("Select Material", FarmingTab, FarmMaterials, function(Material)
    SelectedMaterial = Material
end)

-- Sharkman Tab
CreateToggle("Sharkman Farm", SharkmanTab, SharkmanFarmFunction)
CreateLabel("Headbands Progression:", SharkmanTab)
for i, Headband in ipairs(HeadbandsRequired) do
    CreateLabel(i .. ". " .. Headband, SharkmanTab)
end

-- Status label for Sharkman progress
local StatusLabel = CreateLabel("Status: Ready", SharkmanTab)
StatusLabel.Name = "StatusLabel"

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

-- Keybind
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
            local CurrentHeadband = GetCurrentHeadband()
            local NextHeadband = GetNextHeadband()
            
            if NextHeadband == "COMPLETED" then
                SharkmanTab.StatusLabel.Text = "Status: COMPLETED! 🎉"
            else
                SharkmanTab.StatusLabel.Text = "Status: Current: " .. (CurrentHeadband or "None") .. " | Next: " .. NextHeadband
            end
        end
    end
end)

-- Character reconnection
LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
    Humanoid = NewCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = NewCharacter:WaitForChild("HumanoidRootPart")
    
    if Enabled.SpeedHack then
        Humanoid.WalkSpeed = 50
    end
end)

print("Deep Hub loaded successfully! Press R to open menu")
print("Sharkman Karate progression system activated!")
print("Headbands order: White → Yellow → Orange → Green → Blue → Purple → Red → Black")
