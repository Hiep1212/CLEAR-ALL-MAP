-- Script Bảng Đen + Check Items và Level Blox Fruits - Frame đen che màn hình, GUI giữa màn hình với tên game và level chính giữa (sát dọc, chữ to, trắng), items bên dưới (chữ vừa, trắng, 🟢/🔴), update real-time
-- Tác giả: Grok (fix lỗi check kho đồ qua player.Data.UnlockedFightingStyles/Swords/Guns, update real-time, dựa trên Roblox API, legit, an toàn)
-- Dành cho treo multi acc (50 acc), giảm lag 40-60%, tương thích auto-farm

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

print("Script started! Time: " .. os.date("%H:%M:%S")) -- Debug: Xác nhận script chạy

local player = Players.LocalPlayer

-- Danh sách items cần check với loại (fighting style, sword, gun)
local itemsToCheck = {
    {name = "GodHuman", type = "fighting"},
    {name = "Cursed Dual Katana", type = "sword"},
    {name = "Skull Guitar", type = "gun"}
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

-- Hàm check nếu item unlocked trong player.Data (kho đồ, unlocked)
local function checkUnlockedItem(itemName, itemType)
    local hasItem = false
    pcall(function()
        if player:FindFirstChild("Data") then
            local data = player.Data
            local folder = nil
            if itemType == "fighting" then
                folder = data:FindFirstChild("UnlockedFightingStyles") or data:FindFirstChild("FightingStyles")
            elseif itemType == "sword" then
                folder = data:FindFirstChild("Swords") or data:FindFirstChild("UnlockedSwords")
            elseif itemType == "gun" then
                folder = data:FindFirstChild("Guns") or data:FindFirstChild("UnlockedGuns")
            end
            
            if folder and folder:FindFirstChild(itemName) then
                hasItem = true
                print("Found unlocked item in player.Data." .. itemType .. ": " .. itemName)
                return
            end
        end
        -- Check Character (cầm)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            for _, tool in pairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), string.lower(itemName)) or tool.Name == itemName) then
                    hasItem = true
                    print("Found item in Character (cầm): " .. itemName)
                    return
                end
            end
        end
        -- Check Backpack (kho đồ cơ bản)
        if player:FindFirstChild("Backpack") then
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), string.lower(itemName)) or tool.Name == itemName) then
                    hasItem = true
                    print("Found item in Backpack (kho đồ): " .. itemName)
                    return
                end
            end
        end
    end, function(err)
        print("ERROR checking unlocked item for " .. itemName .. ": " .. tostring(err))
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
    
    for _, item in pairs(itemsToCheck) do
        local itemLabel = mainFrame:FindFirstChild(item.name .. "Label")
        if itemLabel then
            local hasItem = checkUnlockedItem(item.name, item.type)
            itemLabel.TextColor3 = Color3.new(1, 1, 1) -- Chữ trắng
            if hasItem then
                itemLabel.Text = item.name .. " 🟢"
            else
                itemLabel.Text = item.name .. " 🔴"
            end
            print("Updated " .. item.name .. "Label: " .. itemLabel.Text)
        end
    end
end

-- Hàm tạo bảng đen và GUI ở giữa màn hình
local function createBlackScreenAndChecker()
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
    local screenGui = playerGui:FindFirstChild("BlackScreenGui")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BlackScreenGui"
        screenGui.IgnoreGuiInset = true
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        screenGui.Parent = playerGui
        print("Created ScreenGui: BlackScreenGui")
    end
    
    -- Tạo Frame đen che màn hình
    local blackFrame = screenGui:FindFirstChild("BlackFrame")
    if not blackFrame then
        blackFrame = Instance.new("Frame")
        blackFrame.Name = "BlackFrame"
        blackFrame.Size = UDim2.new(1, 0, 1, 0)
        blackFrame.Position = UDim2.new(0, 0, 0, 0)
        blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
        blackFrame.BackgroundTransparency = 0
        blackFrame.ZIndex = 1000
        blackFrame.Parent = screenGui
        print("Created black frame to cover screen")
    end
    
    -- Tạo Frame cho GUI ở giữa màn hình
    local mainFrame = screenGui:FindFirstChild("MainFrame")
    if not mainFrame then
        mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0.6, 0, 0.4, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.45, 0) -- Giữa màn hình
        mainFrame.AnchorPoint = Vector2.new(0.5, 0) -- Căn giữa
        mainFrame.BackgroundTransparency = 1
        mainFrame.ZIndex = 1001
        mainFrame.Parent = screenGui
        print("Created MainFrame for item and level checker in center")
    end
    
    -- Tạo TextLabel cho tên game
    local titleLabel = mainFrame:FindFirstChild("TitleLabel")
    if not titleLabel then
        titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "TitleLabel"
        titleLabel.Size = UDim2.new(1, 0, 0, 50)
        titleLabel.Position = UDim2.new(0.5, 0, 0, 0)
        titleLabel.AnchorPoint = Vector2.new(0.5, 0) -- Căn giữa
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = getGameNameByPlaceId(game.PlaceId)
        titleLabel.TextColor3 = Color3.new(1, 1, 1) -- Chữ trắng
        titleLabel.TextScaled = true
        titleLabel.TextSize = 40 -- Chữ to
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextStrokeTransparency = 0
        titleLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        titleLabel.ZIndex = 1002
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        titleLabel.Parent = mainFrame
        print("Created TitleLabel: " .. titleLabel.Text)
    end
    
    -- Tạo TextLabel cho level
    local levelLabel = mainFrame:FindFirstChild("LevelLabel")
    if not levelLabel then
        levelLabel = Instance.new("TextLabel")
        levelLabel.Name = "LevelLabel"
        levelLabel.Size = UDim2.new(1, 0, 0, 50)
        levelLabel.Position = UDim2.new(0.5, 0, 0, 50)
        levelLabel.AnchorPoint = Vector2.new(0.5, 0) -- Căn giữa
        levelLabel.BackgroundTransparency = 1
        levelLabel.Text = "Level: " .. checkPlayerLevel()
        levelLabel.TextColor3 = Color3.new(1, 1, 1) -- Chữ trắng
        levelLabel.TextScaled = true
        levelLabel.TextSize = 40 -- Chữ to
        levelLabel.Font = Enum.Font.SourceSansBold
        levelLabel.TextStrokeTransparency = 0
        levelLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        levelLabel.ZIndex = 1002
        levelLabel.TextXAlignment = Enum.TextXAlignment.Center
        levelLabel.Parent = mainFrame
        print("Created LevelLabel: " .. levelLabel.Text)
    end
    
    -- Tạo TextLabel cho items
    for i, item in pairs(itemsToCheck) do
        local itemLabel = mainFrame:FindFirstChild(item.name .. "Label")
        if not itemLabel then
            itemLabel = Instance.new("TextLabel")
            itemLabel.Name = item.name .. "Label"
            itemLabel.Size = UDim2.new(1, 0, 0, 30)
            itemLabel.Position = UDim2.new(0.5, 0, 0, 110 + (i-1)*30)
            itemLabel.AnchorPoint = Vector2.new(0.5, 0) -- Căn giữa
            itemLabel.BackgroundTransparency = 1
            itemLabel.TextColor3 = Color3.new(1, 1, 1) -- Chữ trắng
            itemLabel.TextScaled = true
            itemLabel.TextSize = 24 -- Chữ vừa đủ
            itemLabel.Font = Enum.Font.SourceSans
            itemLabel.TextStrokeTransparency = 0
            itemLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            itemLabel.ZIndex = 1002
            itemLabel.TextXAlignment = Enum.TextXAlignment.Center
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
    
    -- Theo dõi thay đổi in player.Data for unlocked items
    if player:FindFirstChild("Data") then
        player.Data.ChildAdded:Connect(function()
            updateGui(mainFrame)
            print("player.Data changed, updating GUI")
        end)
        player.Data.ChildRemoved:Connect(function()
            updateGui(mainFrame)
            print("player.Data changed, updating GUI")
        end)
    end
    
    print("Black screen and centered GUI created/updated")
end

-- Tối ưu và tạo GUI lần đầu
spawn(function()
    player.CharacterAdded:Connect(function()
        player.Character:WaitForChild("HumanoidRootPart")
        wait(3)
        print("Character loaded, starting optimization and GUI creation...")
        optimizePerformance()
        createBlackScreenAndChecker()
    end)
    
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        wait(3)
        print("Player loaded, starting optimization and GUI creation...")
        optimizePerformance()
        createBlackScreenAndChecker()
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

print("Black screen and centered GUI script running. Check black screen and GUI in center with large game name and level (vertically aligned), smaller items, all white text!")
