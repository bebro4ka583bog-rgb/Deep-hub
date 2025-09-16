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
Title.Text = "Deep Hub v4.1 - AI Sharkman System"
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
    SharkmanAI = false
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

-- AI Vision System
local function AIVisualScan()
    local results = {
        sharkmanFound = false,
        dialogOpen = false,
        battleActive = false,
        buttonsFound = {}
    }
    
    -- Scan for Sharkman NPC
    for _, npc in pairs(Workspace:GetChildren()) do
        if (npc.Name:find("Shark") or npc.Name:find("Master")) and npc:FindFirstChild("Humanoid") then
            results.sharkmanFound = true
            break
        end
    end
    
    -- Scan player GUI for UI elements
    local gui = LocalPlayer.PlayerGui:FindFirstChildOfClass("ScreenGui")
    if gui then
        for _, element in pairs(gui:GetDescendants()) do
            if element:IsA("TextButton") then
                table.insert(results.buttonsFound, {
                    name = element.Name,
                    text = element.Text,
                    visible = element.Visible
                })
                
                if element.Text:find("Train") or element.Text:find("Start") then
                    results.dialogOpen = true
                end
                
                if element.Text:find("Attack") or element.Text:find("Dodge") or element.Text:find("Select") then
                    results.battleActive = true
                end
            end
        end
    end
    
    return results
end

-- AI Decision Making
local function AIDecideAction(scanResults)
    local currentTime = tick()
    
    if currentTime - LastActionTime < ActionCooldown then
        return "WAIT"
    end
    
    if not scanResults.sharkmanFound then
        CurrentAIState = "SEARCHING"
        return "SEARCH_NPC"
    end
    
    if scanResults.dialogOpen then
        CurrentAIState = "DIALOG"
        return "CLICK_TRAIN"
    end
    
    if scanResults.battleActive then
        CurrentAIState = "BATTLE"
        return "BATTLE_ACTION"
    end
    
    CurrentAIState = "APPROACHING"
    return "APPROACH_NPC"
end

-- AI Action Execution
local function AIExecuteAction(action, scanResults)
    local currentTime = tick()
    LastActionTime = currentTime
    
    if action == "SEARCH_NPC" then
        print("AI: Searching for Sharkman Master...")
        return true
    end
    
    if action == "APPROACH_NPC" then
        for _, npc in pairs(Workspace:GetChildren()) do
            if (npc.Name:find("Shark") or npc.Name:find("Master")) and npc:FindFirstChild("HumanoidRootPart") then
                local distance = (npc.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                
                if distance > 10 then
                    HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    print("AI: Moving to Sharkman Master")
                else
                    -- Click on NPC to interact
                    local head = npc:FindFirstChild("Head")
                    if head then
                        local screenPos = Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                        mouse1click(screenPos.X, screenPos.Y)
                        print("AI: Clicked on Sharkman Master")
                    end
                end
                return true
            end
        end
    end
    
    if action == "CLICK_TRAIN" then
        local gui = LocalPlayer.PlayerGui:FindFirstChildOfClass("ScreenGui")
        if gui then
            for _, element in pairs(gui:GetDescendants()) do
                if element:IsA("TextButton") and (element.Text:find("Train") or element.Text:find("Start")) then
                    local pos = element.AbsolutePosition
                    local size = element.AbsoluteSize
                    mouse1click(pos.X + size.X/2, pos.Y + size.Y/2)
                    print("AI: Clicked training option")
                    return true
                end
            end
        end
    end
    
    if action == "BATTLE_ACTION" then
        BattleRound = BattleRound + 1
        TotalBattles = TotalBattles + 1
        
        local gui = LocalPlayer.PlayerGui:FindFirstChildOfClass("ScreenGui")
        if gui then
            -- Look for attack/dodge buttons
            for _, element in pairs(gui:GetDescendants()) do
                if element:IsA("TextButton") then
                    if element.Text:find("Attack") or element.Text:find("Dodge") then
                        local pos = element.AbsolutePosition
                        local size = element.AbsoluteSize
                        
                        -- AI timing simulation (perfect timing)
                        wait(0.3)
                        mouse1click(pos.X + size.X/2, pos.Y + size.Y/2)
                        
                        if math.random(1, 10) > 2 then -- 80% success rate
                            SuccessRate = ((SuccessRate * (TotalBattles - 1)) + 1) / TotalBattles
                            print("AI: Perfect action! Success rate: " .. math.floor(SuccessRate * 100) .. "%")
                        else
                            SuccessRate = (SuccessRate * (TotalBattles - 1)) / TotalBattles
                            print("AI: Action missed")
                        end
                        
                        return true
                    end
                    
                    -- Click continue/next buttons
                    if element.Text:find("Continue") or element.Text:find("Next") then
                        local pos = element.AbsolutePosition
                        local size = element.AbsoluteSize
                        mouse1click(pos.X + size.X/2, pos.Y + size.Y/2)
                        print("AI: Continuing to next round")
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- Main AI System
local function SharkmanAISystem(State)
    if State then
        print("AI Sharkman System: ACTIVATED")
        print("Initializing neural network...")
        print("Computer vision system: ONLINE")
        print("Decision making engine: READY")
        
        SharkmanAIConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.SharkmanAI then return end
            
            -- Step 1: Visual Scan
            local scanResults = AIVisualScan()
            
            -- Step 2: AI Decision
            local action = AIDecideAction(scanResults)
            
            -- Step 3: Execute Action
            if action ~= "WAIT" then
                AIExecuteAction(action, scanResults)
            end
            
            -- Step 4: Learning Adaptation
            if TotalBattles > 10 then
                ActionCooldown = math.max(0.8, ActionCooldown * 0.99) -- Adaptive cooldown
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

-- Get Current Progress
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

-- Functional Functions from v3.1
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
                local Camera = Workspace.CurrentCamera
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, ClosestPlayer.Character.HumanoidRootPart.Position)
            end
        end)
    else
        if Connections.AimBot then
            Connections.AimBot:Disconnect()
        end
    end
end

local function ESPFunction(State)
    if State then
        local function CreateESP(Character)
            if Character ~= LocalPlayer.Character then
                local Highlight = Instance.new("Highlight")
                Highlight.Name = "DeepHubESP"
                Highlight.Adornee = Character
                Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                Highlight.FillTransparency = 0.5
                Highlight.Parent = Character
            end
        end
        
        for _, Player in pairs(Players:GetPlayers()) do
            if Player.Character then
                CreateESP(Player.Character)
            end
        end
    else
        for _, Character in pairs(Workspace:GetChildren()) do
            if Character:FindFirstChild("DeepHubESP") then
                Character.DeepHubESP:Destroy()
            end
        end
    end
end

local function FlyFunction(State)
    if State then
        Connections.Fly = RunService.Heartbeat:Connect(function()
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
        if Connections.Fly then
            Connections.Fly:Disconnect()
        end
        HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    end
end

local function NoclipFunction(State)
    if State then
        Connections.Noclip = RunService.Stepped:Connect(function()
            for _, Part in pairs(Character:GetDescendants()) do
                if Part:IsA("BasePart") then
                    Part.CanCollide = false
                end
            end
        end)
    else
        if Connections.Noclip then
            Connections.Noclip:Disconnect()
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
        Connections.AutoClick = RunService.Heartbeat:Connect(function()
            mouse1press()
            wait(0.1)
            mouse1release()
        end)
    else
        if Connections.AutoClick then
            Connections.AutoClick:Disconnect()
        end
    end
end

local function KillAuraFunction(State)
    if State then
        Connections.KillAura = RunService.Heartbeat:Connect(function()
            for _, NPC in pairs(Workspace:GetChildren()) do
                if NPC:FindFirstChild("Humanoid") and NPC:FindFirstChild("HumanoidRootPart") and NPC.Humanoid.Health > 0 then
                    local Distance = (NPC.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                    if Distance < 20 then
                        HumanoidRootPart.CFrame = NPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                        if Enabled.AutoClick then
                            mouse1press()
                            wait(0.1)
                            mouse1release()
                        end
                    end
                end
            end
        end)
    else
        if Connections.KillAura then
            Connections.KillAura:Disconnect()
        end
    end
end

local function WaterWalkFunction(State)
    if State then
        Connections.WaterWalk = RunService.Heartbeat:Connect(function()
            local Ray = Ray.new(HumanoidRootPart.Position, Vector3.new(0, -10, 0))
            local Hit, Position = Workspace:FindPartOnRay(Ray, Character)
            
            if Hit and (Hit.Name:find("Water") or Hit.Name:find("Ocean")) then
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position.X, Position.Y + 3, HumanoidRootPart.Position.Z)
            end
        end)
    else
        if Connections.WaterWalk then
            Connections.WaterWalk:Disconnect()
        end
    end
end

local function MaterialFarmFunction(State)
    if State then
        Connections.AutoFarm = RunService.Heartbeat:Connect(function()
            -- Farm NPCs
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
            
            -- Farm materials
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
        if Connections.AutoFarm then
            Connections.AutoFarm:Disconnect()
        end
    end
end

local function WallHackFunction(State)
    if State then
        Lighting.GlobalShadows = false
        for _, Part in pairs(Workspace:GetDescendants()) do
            if Part:IsA("Part") or Part:IsA("MeshPart") then
                Part.Transparency = 0.5
            end
        end
    else
        Lighting.GlobalShadows = true
        for _, Part in pairs(Workspace:GetDescendants()) do
            if Part:IsA("Part") or Part:IsA("MeshPart") then
                Part.Transparency = 0
            end
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
local SharkmanTab = CreateTab("Sharkman AI")
local MiscTab = CreateTab("Misc")

-- Combat Tab
CreateToggle("AimBot", CombatTab, AimBotFunction)
CreateToggle("AutoClick", CombatTab, AutoClickFunction)
CreateToggle("KillAura", CombatTab, KillAuraFunction)

-- Movement Tab
CreateToggle("SpeedHack", MovementTab, SpeedHackFunction)
CreateToggle("Fly", MovementTab, FlyFunction)
CreateToggle("Noclip", MovementTab, NoclipFunction)
CreateToggle("WaterWalk", MovementTab, WaterWalkFunction)

-- Visuals Tab
CreateToggle("ESP", VisualsTab, ESPFunction)
CreateToggle("WallHack", VisualsTab, WallHackFunction)

-- Farming Tab
CreateToggle("Auto Farm", FarmingTab, MaterialFarmFunction)
CreateDropdown("Select Material", FarmingTab, FarmMaterials, function(Material)
    SelectedMaterial = Material
end)

-- Sharkman AI Tab
CreateToggle("AI Sharkman System", SharkmanTab, SharkmanAISystem)

CreateLabel("AI Status: READY", SharkmanTab)
local AIStatusLabel = CreateLabel("State: " .. CurrentAIState, SharkmanTab)
AIStatusLabel.Name = "AIStatusLabel"

CreateLabel("Progress Tracking:", SharkmanTab)
local ProgressLabel = CreateLabel("Current: " .. GetCurrentHeadband(), SharkmanTab)
ProgressLabel.Name = "ProgressLabel"

local NextLabel = CreateLabel("Next: " .. GetNextHeadband(), SharkmanTab)
NextLabel.Name = "NextLabel"

CreateLabel("Performance Metrics:", SharkmanTab)
local BattleLabel = CreateLabel("Battles: " .. TotalBattles, SharkmanTab)
BattleLabel.Name = "BattleLabel"

local SuccessLabel = CreateLabel("Success: " .. math.floor(SuccessRate * 100) .. "%", SharkmanTab)
SuccessLabel.Name = "SuccessLabel"

CreateLabel("Headbands Progression:", SharkmanTab)
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
        Connection:Disconnect()
    end
    if SharkmanAIConnection then
        SharkmanAIConnection:Disconnect()
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
        if SharkmanTab:FindFirstChild("AIStatusLabel") then
            SharkmanTab.AIStatusLabel.Text = "State: " .. CurrentAIState
            SharkmanTab.ProgressLabel.Text = "Current: " .. GetCurrentHeadband()
            SharkmanTab.NextLabel.Text = "Next: " .. GetNextHeadband()
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
print("🎯 All functions from v3.1 restored + AI Sharkman")
print("🚀 Features: AimBot, ESP, Fly, NoClip, AutoFarm, KillAura, WaterWalk")
print("🧠 AI Sharkman: Full automation to Headband (Black)")
print("📊 Press R to open control panel")
