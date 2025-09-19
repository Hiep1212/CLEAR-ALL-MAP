local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

print("Script started! Time: " .. os.date("%H:%M:%S")) -- Debug: Xác nhận script chạy

local player = Players.LocalPlayer

-- Danh sách items cần check
local itemsToCheck = {
    "GodHuman",
    "Cursed Dual Katana",
    "Skull Guitar"
}

-- Hàm ánh xạ Place ID sang tên game
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

-- Hàm check level
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

-- Hàm check inventory có item không
local function checkInventoryForItem(itemName)
    local hasItem = false
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            for _, tool in pairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), string.lower(itemName)) or tool.Name == itemName) then
                    hasItem = true
                    print("Found item in Character: " .. itemName)
                    return
                end
            end
        end
        if player:FindFirstChild("Backpack") then
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), string.lower(itemName)) or tool.Name == itemName) then
                    hasItem = true
                    print("Found item in Backpack: " .. itemName)
                    return
                end
            end
        end
    end, function(err)
        print("ERROR checking inventory for " .. itemName .. ": " .. tostring(err))
    end)
    if not hasItem then
        print("Item not found: " .. itemName)
    end
    return hasItem
end

-- Hàm tối ưu hiệu suất
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

-- Hàm update GUI
local function updateGui(mainFrame)
    local levelLabel = mainFrame:FindFirstChild("LevelLabel")
    if levelLabel then
        levelLabel.Text = "Level: " .. checkPlayerLevel()
        print("Updated LevelLabel: " .. levelLabel.Text)
    end
    
    for _, itemName in pairs(itemsToCheck) do
        local itemLabel = mainFrame:FindFirstChild(itemName .. "Label")
        if itemLabel then
            local hasItem = checkInventoryForItem(itemName)
            if hasItem then
                itemLabel.TextColor3 = Color3.new(0, 1, 0)
                itemLabel.Text = itemName .. " 🟢"
            else
                itemLabel.TextColor3 = Color3.new(1, 0, 0)
                itemLabel.Text = itemName .. " 🔴"
            end
            print("Updated " .. itemName .. "Label: " .. itemLabel.Text)
        end
    end
end

-- Hàm tạo GUI trong suốt ở giữa màn hình
local function createTransparentGui()
    local maxWaitTime = 15
    local waitTime = 0
    while not player:FindFirstChild("PlayerGui") and waitTime < maxWaitTime do
        wait(0.5)
        waitTime = waitTime + 0.5
        print("Waiting for PlayerGui... Time elapsed: " .. waitTime .. "s")
    end
    local playerGui = player.PlayerGui
    if not playerGui then
        print("ERROR: PlayerGui not found after waiting " .. maxWaitTime .. "s!")
        return
    end
    
    -- Tạo ScreenGui
    local screenGui = playerGui:FindFirstChild("TransparentGui")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "TransparentGui"
        screenGui.IgnoreGuiInset = true
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        screenGui.Parent = playerGui
        print("Created ScreenGui: TransparentGui")
    end
    
    -- Tạo Frame trong suốt ở giữa màn hình
    local mainFrame = screenGui:FindFirstChild("MainFrame")
    if not mainFrame then
        mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(1, 0, 0.3, 0)
        mainFrame.Position = UDim2.new(0, 0, 0.45, 0) -- Giữa màn hình
        mainFrame.BackgroundTransparency = 1
        mainFrame.ZIndex = 1001
        mainFrame.Parent = screenGui
        print("Created MainFrame for item and level checker in center")
    end
    
    -- Tạo TextLabel cho title
    local titleLabel = mainFrame:FindFirstChild("TitleLabel")
    if not titleLabel then
        titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "TitleLabel"
        titleLabel.Size = UDim2.new(1, 0, 0, 40)
        titleLabel.Position = UDim2.new(0, 0, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = getGameNameByPlaceId(game.PlaceId)
        titleLabel.TextColor3 = Color3.new(1, 1, 1)
        titleLabel.TextScaled = true
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextStrokeTransparency = 0
        titleLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        titleLabel.ZIndex = 1002
        titleLabel.Parent = mainFrame
        print("Created TitleLabel: " .. titleLabel.Text)
    end
    
    -- Tạo TextLabel cho level
    local levelLabel = mainFrame:FindFirstChild("LevelLabel")
    if not levelLabel then
        levelLabel = Instance.new("TextLabel")
        levelLabel.Name = "LevelLabel"
        levelLabel.Size = UDim2.new(1, 0, 0, 30)
        levelLabel.Position = UDim2.new(0, 0, 0, 40)
        levelLabel.BackgroundTransparency = 1
        levelLabel.Text = "Level: " .. checkPlayerLevel()
        levelLabel.TextColor3 = Color3.new(1, 1, 1)
        levelLabel.TextScaled = true
        levelLabel.Font = Enum.Font.SourceSans
        levelLabel.TextStrokeTransparency = 0
        levelLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        levelLabel.ZIndex = 1002
        levelLabel.Parent = mainFrame
        print("Created LevelLabel: " .. levelLabel.Text)
    end
    
    -- Tạo TextLabel cho items
    for i, itemName in pairs(itemsToCheck) do
        local itemLabel = mainFrame:FindFirstChild(itemName .. "Label")
        if not itemLabel then
            itemLabel = Instance.new("TextLabel")
            itemLabel.Name = itemName .. "Label"
            itemLabel.Size = UDim2.new(1, 0, 0, 30)
            itemLabel.Position = UDim2.new(0, 0, 0, 70 + (i-1)*30)
            itemLabel.BackgroundTransparency = 1
            itemLabel.Text = itemName
            itemLabel.TextColor3 = Color3.new(1, 1, 1)
            itemLabel.TextScaled = true
            itemLabel.Font = Enum.Font.SourceSans
            itemLabel.TextStrokeTransparency = 0
            itemLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            itemLabel.ZIndex = 1002
            itemLabel.Parent = mainFrame
        end
    end
    
    -- Update GUI lần đầu
    updateGui(mainFrame)
    
    -- Theo dõi thay đổi level
    if player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") then
        player.Data.Level.Changed:Connect(function(newLevel)
            local levelLabel = mainFrame:FindFirstChild("LevelLabel")
            if levelLabel then
                levelLabel.Text = "Level: " .. tostring(newLevel)
                print("Level updated: " .. tostring(newLevel))
            end
        end)
    end
    
    -- Theo dõi thay đổi inventory
    if player:FindFirstChild("Backpack") then
        player.Backpack.ChildAdded:Connect(function()
            updateGui(mainFrame)
            print("Backpack changed, updating GUI")
        end)
        player.Backpack.ChildRemoved:Connect(function()
            updateGui(mainFrame)
            print("Backpack changed, updating GUI")
        end)
    end
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid")
        character.ChildAdded:Connect(function()
            updateGui(mainFrame)
            print("Character inventory changed, updating GUI")
        end)
        character.ChildRemoved:Connect(function()
            updateGui(mainFrame)
            print("Character inventory changed, updating GUI")
        end)
    end)
    
    print("Transparent GUI created/updated in center")
end

-- Tối ưu và tạo GUI lần đầu
spawn(function()
    player.CharacterAdded:Connect(function()
        player.Character:WaitForChild("HumanoidRootPart")
        wait(3)
        print("Character loaded, starting optimization and GUI creation...")
        optimizePerformance()
        createTransparentGui()
    end)
    
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        wait(3)
        print("Player loaded, starting optimization and GUI creation...")
        optimizePerformance()
        createTransparentGui()
    else
        print("ERROR: Player or HumanoidRootPart not loaded on start.")
    end
end)

-- Tối ưu định kỳ mỗi 600 giây
spawn(function()
    while true do
        optimizePerformance()
        wait(600)
    end
end)

print("Transparent GUI script running. Check GUI in center of screen with real-time updates for level and items!")
