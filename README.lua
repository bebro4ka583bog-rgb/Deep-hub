-- Deep Hub Script for Blox Fruits with Sharkman Farmer and Slow Motion
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
MainFrame.Size = UDim2.new(0, 500, 0, 450) -- Increased size for new features
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
Title.Text = "Deep Hub v2.5 - Slow Motion Edition"
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
TabsFrame.Size = UDim2.new(0, 350, 0, 360)
TabsFrame.Position = UDim2.new(0, 130, 0, 50)
TabsFrame.BackgroundTransparency = 1
TabsFrame.ClipsDescendants = true
TabsFrame.Parent = MainFrame

-- Tabs
local Tabs = {
    Combat = {Name = "Combat", Color = Color3.fromRGB(220, 80, 80)},
    Movement = {Name = "Movement", Color = Color3.fromRGB(80, 180, 80)},
    Visuals = {Name = "Visuals", Color = Color3.fromRGB(80, 120, 220)},
    Time = {Name = "Time", Color = Color3.fromRGB(160, 100, 220)}, -- New Time tab
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
    SharkmanFarm = false,
    SlowMotion = false, -- New variable
    BulletTime = false  -- New variable
}

-- Time control variables
local OriginalTimeScale = 1
local SlowMotionIntensity = 0.5
local BulletTimeIntensity = 0.2
local TimeConnection = nil

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

-- Sharkman Farm variables
local SharkmanWins = 0
local SharkmanAttempts = 0
local SharkmanConnection = nil
local FishBoxPosition = Vector3.new(-1250, 50, 750)

local SelectedMaterial = "Magma Ore"
local AimBotTarget = nil
local ESPObjects = {}
local FarmConnection = nil
local ClickConnection = nil
local NoclipConnection = nil
local FlyConnection = nil

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

local function CreateSlider(Name, Parent, Min, Max, Default, Callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = Parent
    
    local Title = CreateLabel(Name, SliderFrame)
    
    local ValueLabel = CreateLabel("Value: " .. Default, SliderFrame)
    ValueLabel.Position = UDim2.new(0, 0, 0, 20)
    
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, 0, 0, 10)
    Slider.Position = UDim2.new(0, 0, 0, 40)
    Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Slider.Parent = SliderFrame
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    Fill.Parent = Slider
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.BackgroundTransparency = 1
    SliderButton.Text = ""
    SliderButton.Parent = Slider
    
    SliderButton.MouseButton1Down:Connect(function()
        local function UpdateSlider(X)
            local RelativeX = math.clamp(X - Slider.AbsolutePosition.X, 0, Slider.AbsoluteSize.X)
            local Value = math.floor(Min + (RelativeX / Slider.AbsoluteSize.X) * (Max - Min))
            Fill.Size = UDim2.new(RelativeX / Slider.AbsoluteSize.X, 0, 1, 0)
            ValueLabel.Text = "Value: " .. Value
            if Callback then
                Callback(Value)
            end
        end
        
        UpdateSlider(UserInputService:GetMouseLocation().X)
        
        local MoveConnection
        MoveConnection = UserInputService.MouseMove:Connect(function()
            UpdateSlider(UserInputService:GetMouseLocation().X)
        end)
        
        local ReleaseConnection
        ReleaseConnection = UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                MoveConnection:Disconnect()
                ReleaseConnection:Disconnect()
            end
        end)
    end)
    
    return SliderFrame
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

-- Time Control Functions
local function ApplyTimeScale(Scale)
    -- Apply to physics
    Workspace.Gravity = 196.2 * Scale
    
    -- Apply to humanoid animations and movements
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = Character.Humanoid.WalkSpeed * (Scale / OriginalTimeScale)
        Character.Humanoid.JumpPower = Character.Humanoid.JumpPower * (Scale / OriginalTimeScale)
    end
    
    -- Visual effects
    Lighting.ClockTime = Lighting.ClockTime
    Lighting.ExposureCompensation = 1 - Scale
    
    -- Sound pitch adjustment (if possible)
    for _, Sound in pairs(Workspace:GetDescendants()) do
        if Sound:IsA("Sound") then
            Sound.PlaybackSpeed = Scale
        end
    end
end

local function SlowMotionFunction(State)
    if State then
        OriginalTimeScale = 1
        TimeConnection = RunService.Heartbeat:Connect(function()
            if Enabled.SlowMotion then
                ApplyTimeScale(SlowMotionIntensity)
            elseif Enabled.BulletTime then
                ApplyTimeScale(BulletTimeIntensity)
            else
                ApplyTimeScale(OriginalTimeScale)
            end
        end)
        print("⏰ Slow Motion активирован: " .. SlowMotionIntensity .. "x")
    else
        if TimeConnection then
            TimeConnection:Disconnect()
        end
        ApplyTimeScale(OriginalTimeScale)
        print("⏰ Slow Motion деактивирован")
    end
end

local function BulletTimeFunction(State)
    if State then
        if not Enabled.SlowMotion then
            SlowMotionFunction(true)
        end
        print("🌀 Bullet Time активирован: " .. BulletTimeIntensity .. "x")
    else
        if not Enabled.SlowMotion then
            SlowMotionFunction(false)
        end
        print("🌀 Bullet Time деактивирован")
    end
end

-- Sharkman Farm Functions
local function FindSharkmanMaster()
    for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
        if npc.Name == "Sharkman Master" and npc:FindFirstChild("Humanoid") then
            return npc
        end
    end
    return nil
end

local function TeleportTo(position)
    pcall(function()
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = CFrame.new(position)
        end
    end)
end

local function AttackSharkman(target)
    if not target or not target:FindFirstChild("Humanoid") then return false end
    
    pcall(function()
        target.Humanoid:TakeDamage(10000)
    end)
    
    wait(1)
    return not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0
end

local function SharkmanFarmFunction(State)
    if State then
        SharkmanConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.SharkmanFarm then return end
            
            TeleportTo(FishBoxPosition)
            wait(2)
            
            local master = FindSharkmanMaster()
            
            if master then
                local success = AttackSharkman(master)
                SharkmanAttempts = SharkmanAttempts + 1
                
                if success then
                    SharkmanWins = SharkmanWins + 1
                    print("✅ Sharkman Master defeated! Wins: " .. SharkmanWins .. "/8")
                    
                    if SharkmanWins >= 8 then
                        print("🎉 Headband (Black) получен!")
                        Enabled.SharkmanFarm = false
                        if SharkmanConnection then
                            SharkmanConnection:Disconnect()
                        end
                    end
                else
                    SharkmanWins = 0
                    print("❌ Поражение! Сброс счетчика побед")
                end
            else
                print("🔍 Sharkman Master не найден, ожидание...")
            end
            
            wait(3)
        end)
    else
        if SharkmanConnection then
            SharkmanConnection:Disconnect()
        end
    end
end

-- Other existing functions (AimBotFunction, ESPFunction, FlyFunction, etc.) remain the same
-- [Все остальные функции остаются без изменений, как в вашем оригинальном скрипте]
-- Combat functions
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
        MaterialFarmConnection = RunService.Heartbeat:Connect(function()
            if not Enabled.AutoFarm then return end
            
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
        if MaterialFarmConnection then
            MaterialFarmConnection:Disconnect()
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

-- Create Tabs and UI
local YPosition = 0
for TabName, _ in pairs(Tabs) do
    CreateTabButton(TabName, UDim2.new(0, 0, 0, YPosition))
    YPosition = YPosition + 35
end

local CombatTab = CreateTab("Combat")
local MovementTab = CreateTab("Movement")
local VisualsTab = CreateTab("Visuals")
local TimeTab = CreateTab("Time") -- New Time tab
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

-- Time Tab (NEW)
CreateToggle("Slow Motion", TimeTab, SlowMotionFunction)
CreateToggle("Bullet Time", TimeTab, BulletTimeFunction)

CreateSlider("Slow Motion Intensity", TimeTab, 0.1, 0.9, 50, function(Value)
    SlowMotionIntensity = Value / 100
    print("⚡ Интенсивность Slow Motion: " .. SlowMotionIntensity .. "x")
end)

CreateSlider("Bullet Time Intensity", TimeTab, 0.05, 0.3, 20, function(Value)
    BulletTimeIntensity = Value / 100
    print("🌀 Интенсивность Bullet Time: " .. BulletTimeIntensity .. "x")
end)

CreateLabel("Slow Motion: Замедление игры", TimeTab)
CreateLabel("Bullet Time: Сильное замедление", TimeTab)

-- Farming Tab
CreateToggle("Auto Farm", FarmingTab, MaterialFarmFunction)
CreateDropdown("Select Material", FarmingTab, FarmMaterials, function(Material)
    SelectedMaterial = Material
end)

-- Sharkman Tab
CreateToggle("Sharkman Farm", SharkmanTab, SharkmanFarmFunction)

local WinsLabel = CreateLabel("Wins: 0/8", SharkmanTab)
local AttemptsLabel = CreateLabel("Attempts: 0", SharkmanTab)

local ResetButton = Instance.new("TextButton")
ResetButton.Size = UDim2.new(1, -20, 0, 25)
ResetButton.Position = UDim2.new(0, 10, 0, 60)
ResetButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
ResetButton.Text = "Reset Counter"
ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetButton.Font = Enum.Font.Gotham
ResetButton.TextSize = 12
ResetButton.Parent = SharkmanTab

ResetButton.MouseButton1Click:Connect(function()
    SharkmanWins = 0
    SharkmanAttempts = 0
    WinsLabel.Text = "Wins: 0/8"
    AttemptsLabel.Text = "Attempts: 0"
    print("Счетчик сброшен")
end)

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
    for _, Connection in pairs({FarmConnection, ClickConnection, NoclipConnection, FlyConnection, MaterialFarmConnection, SharkmanConnection, TimeConnection}) do
        if Connection then
            Connection:Disconnect()
        end
    end
    -- Reset time scale
    ApplyTimeScale(1)
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
    
    -- Time control hotkeys
    if not Processed then
        if Input.KeyCode == Enum.KeyCode.T then
            Enabled.SlowMotion = not Enabled.SlowMotion
            SlowMotionFunction(Enabled.SlowMotion)
        elseif Input.KeyCode == Enum.KeyCode.Y then
            Enabled.BulletTime = not Enabled.BulletTime
            BulletTimeFunction(Enabled.BulletTime)
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

-- Update sharkman stats
RunService.Heartbeat:Connect(function()
    WinsLabel.Text = "Wins: " .. SharkmanWins .. "/8"
    AttemptsLabel.Text = "Attempts: " .. SharkmanAttempts
end)

print("Deep Hub with Time Control loaded successfully! Press R to open menu")
print("Hotkeys: T - Slow Motion, Y - Bullet Time")
print("⏰ Time Control features added - control the flow of time!")
