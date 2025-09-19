local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

print("Script started! Time: " .. os.date("%H:%M:%S")) -- Debug: Xác nhận script chạy

local player = Players.LocalPlayer

local itemsToCheck = {
    "GodHuman",  
    "Cursed Dual Katana","Shark Anchor", 
    "Skull Guitar" 
}

local function getGameNameByPlaceId(placeId)
    local gameNames = {
        ["2753915549"] = "BLOX FRUIT SEA 1",
        ["4442272183"] = "BLOX FRUIT SEA 2",
        ["7449423635"] = "BLOX FRUIT SEA 3",
        ["7436755782"] = "GROW A GARDEN",
        ["7709344486"] = "STEAL A BRAINROT"
    }
    return gameNames[tostring(placeId)] or "Unknown Game"
end
local function checkPlayerLevel()
    local placeId = tostring(game.PlaceId)
    local isBloxFruits = placeId == "2753915549" or placeId == "4442272183" or placeId == "7449423635"
    
    if not isBloxFruits then
        return "N/A"
    end
    
    local level = "N/A"
    if player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") then
        level = tostring(player.Data.Level.Value)
        print("Player level: " .. level)
    else
        print("ERROR: Level not found in player.Data.Level")
    end
    return level
end
local function checkInventoryForItem(itemName)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") and (string.find(string.lower(tool.Name), string.lower(itemName)) or tool.Name == itemName) then
                return true
            end
        end
    end
    if player:FindFirstChild("Backpack") then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (string.find(string.lower(tool.Name), string.lower(itemName)) or tool.Name == itemName) YY then
                return true
            end
        end
    end
    return false
end
local function optimizePerformance()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
                print("Disabled effect: " .. v.Name)
            end
        end
        settings().Rendering.QualityLevel = 1
        print("Performance optimized: Shadows OFF, Particles OFF, QualityLevel = 1")
    end, function(err)
        print("ERROR optimizing performance: " .. tostring(err))
    end)
end
local function createItemChecker()
    local maxWaitTime = 10
    local waitTime = 0
    while not player:FindFirstChild("PlayerGui") and waitTime < maxWaitTime do
        wait(0.5)
        waitTime = waitTime + 0.5
    end
    local playerGui = player.PlayerGui
    if not playerGui then
        print("ERROR: PlayerGui not found! Item checker creation failed.")
        return
    end
    
    local screenGui = playerGui:FindFirstChild("ItemCheckerGui")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ItemCheckerGui"
        screenGui.IgnoreGuiInset = true
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        screenGui.Parent = playerGui
    end
    
    local mainFrame = screenGui:FindFirstChild("MainFrame")
    if not mainFrame then
        mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 300, 0, 180)
        mainFrame.Position = UDim2.new(0, 10, 0, 10)
        mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
        mainFrame.BackgroundTransparency = 0.3
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = mainFrame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "TitleLabel"
        titleLabel.Size = UDim2.new(1, 0, 0, 30)
        titleLabel.Position = UDim2.new(0, 0, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = getGameNameByPlaceId(game.PlaceId) .. " - Item Checker"
        titleLabel.TextColor3 = Color3.new(1, 1, 1)
        titleLabel.TextScaled = true
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextStrokeTransparency = 0
        titleLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        titleLabel.ZIndex = 2
        titleLabel.Parent = mainFrame
    end
    local levelLabel = mainFrame:FindFirstChild("LevelLabel")
    if not levelLabel then
        levelLabel = Instance.new("TextLabel")
        levelLabel.Name = "LevelLabel"
        levelLabel.Size = UDim2.new(1, -10, 0, 25)
        levelLabel.Position = UDim2.new(0, 5, 0, 30)
        levelLabel.BackgroundTransparency = 1
        levelLabel.Text = "Level: " .. checkPlayerLevel()
        levelLabel.TextColor3 = Color3.new(1, 1, 1)
        levelLabel.TextScaled = true
        levelLabel.Font = Enum.Font.SourceSans
        levelLabel.TextStrokeTransparency = 0
        levelLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        levelLabel.ZIndex = 2
        levelLabel.Parent = mainFrame
    else
        levelLabel.Text = "Level: " .. checkPlayerLevel()
    end
    for i, itemName in pairs(itemsToCheck) do
        local itemLabel = mainFrame:FindFirstChild(itemName .. "Label")
        if not itemLabel then
            itemLabel = Instance.new("TextLabel")
            itemLabel.Name = itemName .. "Label"
            itemLabel.Size = UDim2.new(1, -10, 0, 25)
            itemLabel.Position = UDim2.new(0, 5, 0, 60 + (i-1)*30)
            itemLabel.BackgroundTransparency = 1
            itemLabel.Text = itemName
            itemLabel.TextColor3 = Color3.new(1, 1, 1)
            itemLabel.TextScaled = true
            itemLabel.Font = Enum.Font.SourceSans
            itemLabel.TextStrokeTransparency = 0
            itemLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            itemLabel.ZIndex = 2
            itemLabel.Parent = mainFrame
        end

        local hasItem = checkInventoryForItem(itemName)
        if hasItem then
            itemLabel.TextColor3 = Color3.new(0, 1, 0) 
            itemLabel.Text = itemName .. " 🟢"
        else
            itemLabel.TextColor3 = Color3.new(1, 0, 0) 
            itemLabel.Text = itemName .. " 🔴"
        end
    end 
    print("Item and level checker GUI created/updated")
    if player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") then
        player.Data.Level.Changed:Connect(function(newLevel)
            local levelLabel = mainFrame:FindFirstChild("LevelLabel")
            if levelLabel then
                levelLabel.Text = "Level: " .. tostring(newLevel)
                print("Level updated: " .. tostring(newLevel))
            end
        end)
    end
end
spawn(function()
    player.CharacterAdded:Connect(function()
        player.Character:WaitForChild("HumanoidRootPart")
        wait(2)  -- Đợi inventory và level load
        print("Character loaded, starting optimization and item checker...")
        optimizePerformance()
        createItemChecker()
    end)
    
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        wait(2)  -- Đợi inventory và level load
        print("Player loaded, starting optimization and item checker...")
        optimizePerformance()
        createItemChecker()
    else
        print("ERROR: Player or HumanoidRootPart not loaded on start.")
    end
end)
spawn(function()
    while true do
        optimizePerformance()
        createItemChecker()
        wait(5)
    end
end)

print("Item and level checker script running. Check GUI in top-left corner for GodHuman, Cursed Dual Katana, Skull Guitar, and Level status!")