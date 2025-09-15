
**SharkmanFarmer.lua** (основной скрипт):
```lua
-- Deep Hub - Sharkman Master Farmer v1.0
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/uwuware-ui/main/library.lua"))()

-- Configuration
local Config = {
    FishBoxPosition = Vector3.new(-1250, 50, 750),
    RequiredWins = 8,
    AttackDamage = 1000
}

local State = {
    IsFarming = false,
    WinsCount = 0,
    TotalAttempts = 0,
    AutoRestart = false
}

local Colors = {
    SchemeColor = Color3.fromRGB(0, 132, 255),
    Background = Color3.fromRGB(0, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255)
}

-- Create UI
local Window = Library:CreateWindow("Deep Hub - Sharkman Farmer", Colors)
local MainTab = Window:CreateTab("Основное")
local StatsTab = Window:CreateTab("Статистика")

local StatusLabel = MainTab:CreateLabel("🟢 Статус: Ожидание")
local WinsLabel = StatsTab:CreateLabel("🎯 Побед подряд: 0/" .. Config.RequiredWins)

-- Functions
local function FindSharkmanMaster()
    for _, npc in ipairs(workspace.NPCs:GetChildren()) do
        if npc.Name == "Sharkman Master" and npc:FindFirstChild("Humanoid") then
            return npc
        end
    end
    return nil
end

local function TeleportTo(position)
    pcall(function()
        local Char = LocalPlayer.Character
        if Char and Char:FindFirstChild("HumanoidRootPart") then
            Char.HumanoidRootPart.CFrame = CFrame.new(position)
        end
    end)
end

local function AttackTarget(target)
    if not target or not target:FindFirstChild("Humanoid") then return false end
    pcall(function() target.Humanoid:TakeDamage(Config.AttackDamage) end)
    wait(1)
    return not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0
end

local function StartFarming()
    coroutine.wrap(function()
        while State.IsFarming do
            StatusLabel:UpdateText("🔍 Поиск Sharkman Master...")
            TeleportTo(Config.FishBoxPosition)
            wait(2)
            
            local master = FindSharkmanMaster()
            if master then
                StatusLabel:UpdateText("⚔️ Атака...")
                local success = AttackTarget(master)
                
                if success then
                    State.WinsCount += 1
                    WinsLabel:UpdateText("🎯 Побед подряд: " .. State.WinsCount .. "/" .. Config.RequiredWins)
                    
                    if State.WinsCount >= Config.RequiredWins then
                        Library:CreateNotification("🎉 Успех!", "Headband (Black) получен!")
                        State.IsFarming = false
                        StatusLabel:UpdateText("🎉 Завершено!")
                        break
                    end
                else
                    State.WinsCount = 0
                    WinsLabel:UpdateText("🎯 Побед подряд: 0/" .. Config.RequiredWins)
                end
            end
            wait(State.AutoRestart and 5 or 2)
        end
    end)()
end

-- UI Controls
MainTab:CreateToggle("Авто-телепорт", false, function(state)
    State.AutoRestart = state
end)

MainTab:CreateButton("Начать фарм", function()
    State.IsFarming = not State.IsFarming
    if State.IsFarming then
        StartFarming()
        StatusLabel:UpdateText("🟢 Статус: Активен")
    else
        StatusLabel:UpdateText("🟠 Статус: Остановлен")
    end
end)

-- Initialize
Library:Init()
Library:CreateNotification("Deep Hub", "Sharkman Farmer запущен! 🚀")
