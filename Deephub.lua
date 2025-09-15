-- Deephub Script for Blox Fruits with Redz Hub features
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
MainFrame.Size = UDim2.new(0, 450, 0, 400)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
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
Title.Text = "Deephub v3.0 - Blox Fruits"
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
TabButtonsFrame.Size = UDim2.new(0, 120, 0, 310)
TabButtonsFrame.Position = UDim2.new(0, 10, 0, 50)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.Parent = MainFrame

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 300, 0, 310)
TabsFrame.Position = UDim2.new(0, 140, 0, 50)
TabsFrame.BackgroundTransparency = 1
TabsFrame.ClipsDescendants = true
TabsFrame.Parent = MainFrame

-- Tabs
local Tabs = {
    Combat = {Name = "Combat", Color = Color3.fromRGB(220, 80, 80)},
    Movement = {Name = "Movement", Color = Color3.fromRGB(80, 180, 80)},
    Visuals = {Name = "Visuals", Color = Color3.fromRGB(80, 120, 220)},
    Farming = {Name = "Farming", Color = Color3.fromRGB(220, 180, 60)},
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
    InfiniteEnergy = false
}

-- Blox Fruits Variables
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Redz Hub Features
local AimBotTarget = nil
local ESPObjects = {}
local FarmConnection = nil
local ClickConnection = nil
local NoclipConnection = nil
local FlyConnection = nil

-- Functions
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

-- Redz Hub Functions
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
    if State then
        local function CreateESP(Character)
            if Character ~= LocalPlayer.Character then
                local Highlight = Instance.new("Highlight")
                Highlight.Name = "DeephubESP"
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
        
        Connections.ESPRemoved = Players.PlayerRemoving:Connect(function(Player)
            if Player.Character and ESPObjects[Player.Character] then
                ESPObjects[Player.Character]:Destroy()
                ESPObjects[Player.Character] = nil
            end
        end)
    else
        for Character, Highlight in pairs(ESPObjects) do
            Highlight:Destroy()
        end
        ESPObjects = {}
        
        if Connections.ESPAdded then
            Connections.ESPAdded:Disconnect()
        end
        if Connections.ESPRemoved then
            Connections.ESPRemoved:Disconnect()
        end
    end
end

local function FlyFunction(State)
    if State then
        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = HumanoidRootPart
        
        FlyConnection = RunService.Heartbeat:Connect(function()
            if Enabled.Fly then
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                
                local Camera = Workspace.CurrentCamera
                local LookVector = Camera.CFrame.LookVector
                local RightVector = Camera.CFrame.RightVector
                
                local FlySpeed = 50
                local Velocity = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    Velocity = Velocity + LookVector * FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    Velocity = Velocity - LookVector * FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    Velocity = Velocity + RightVector * FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    Velocity = Velocity - RightVector * FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    Velocity = Velocity + Vector3.new(0, FlySpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    Velocity = Velocity - Vector3.new(0, FlySpeed, 0)
                end
                
                BodyVelocity.Velocity = Velocity
                HumanoidRootPart.Velocity = Velocity
            else
                BodyVelocity:Destroy()
            end
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
        end
        for _, Part in pairs(Character:GetDescendants()) do
            if Part:IsA("BodyVelocity") then
                Part:Destroy()
            end
        end
    end
end

local function NoclipFunction(State)
    if State then
        NoclipConnection = RunService.Stepped:Connect(function()
            if Enabled.Noclip and Character then
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

local function AutoFarmFunction(State)
    if State then
        FarmConnection = RunService.Heartbeat:Connect(function()
            if Enabled.AutoFarm then
                local ClosestMob = nil
                local ClosestDistance = math.huge
                
                for _, Mob in pairs(Workspace:GetChildren()) do
                    if Mob:FindFirstChild("Humanoid") and Mob:FindFirstChild("HumanoidRootPart") and Mob.Humanoid.Health > 0 then
                        local Distance = (Mob.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                        if Distance < ClosestDistance then
                            ClosestDistance = Distance
                            ClosestMob = Mob
                        end
                    end
                end
                
                if ClosestMob then
                    HumanoidRootPart.CFrame = ClosestMob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    -- Auto attack would go here
                end
            end
        end)
    else
        if FarmConnection then
            FarmConnection:Disconnect()
        end
    end
end

local function AutoClickFunction(State)
    if State then
        ClickConnection = RunService.Heartbeat:Connect(function()
            if Enabled.AutoClick then
                -- Simulate mouse click
                if AimBotTarget then
                    mouse1click()
                end
            end
        end)
    else
        if ClickConnection then
            ClickConnection:Disconnect()
        end
    end
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
local MiscTab = CreateTab("Misc")

-- Combat Tab Elements
CreateToggle("AimBot", CombatTab, AimBotFunction)
CreateToggle("AutoClick", CombatTab, AutoClickFunction)

-- Movement Tab Elements
CreateToggle("SpeedHack", MovementTab, SpeedHackFunction)
CreateToggle("Fly", MovementTab, FlyFunction)
CreateToggle("Noclip", MovementTab, NoclipFunction)
CreateSlider("Speed", MovementTab, 16, 150, 50, function(Value)
    if Enabled.SpeedHack then
        Humanoid.WalkSpeed = Value
    end
end)
CreateSlider("FlySpeed", MovementTab, 20, 200, 50, function(Value)
    -- Fly speed adjustment
end)

-- Visuals Tab Elements
CreateToggle("ESP", VisualsTab, ESPFunction)
CreateToggle("WallHack", VisualsTab, function(State)
    if State then
        Lighting.GlobalShadows = false
        for _, Part in pairs(Workspace:GetDescendants()) do
            if Part:IsA("Part") or Part:IsA("MeshPart") then
                Part.Material = Enum.Material.ForceField
                Part.Transparency = 0.5
            end
        end
    else
        Lighting.GlobalShadows = true
        for _, Part in pairs(Workspace:GetDescendants()) do
            if Part:IsA("Part") or Part:IsA("MeshPart") then
                Part.Material = Enum.Material.Plastic
                Part.Transparency = 0
            end
        end
    end
end)

-- Farming Tab Elements
CreateToggle("AutoFarm", FarmingTab, AutoFarmFunction)
CreateSlider("FarmRange", FarmingTab, 10, 100, 50, function(Value)
    -- Farm range adjustment
end)

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
    for _, Connection in pairs({FarmConnection, ClickConnection, NoclipConnection, FlyConnection}) do
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

-- Character reconnection
LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
    Humanoid = NewCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = NewCharacter:WaitForChild("HumanoidRootPart")
    
    -- Reapply enabled features
    if Enabled.SpeedHack then
        Humanoid.WalkSpeed = 50
    end
end)

print("Deephub Redz Edition loaded successfully! Press R to open/close the menu.")
