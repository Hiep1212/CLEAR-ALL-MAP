local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local clearRadius = math.huge  -- Bán kính vô cực (xóa cả map)

-- Danh sách loại trừ (chỉ giữ block đảo để đứng)
local excludeNames = {
    "Terrain", "Platform", "Ground", "Base", "Floor", 
    "Water", "Island", "Dock", "IslandBase", "Main", 
    "Surface", "BasePlate", "Foundation", "Sea", "Land",
    "Quest", "Giver", "Board", "Chest", "Treasure"
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

-- Hàm check level cho Blox Fruits
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

-- Hàm kiểm tra xem object có nên xóa không
local function shouldClear(obj)
    if not obj or not obj.Parent then return false end
    -- Loại trừ Terrain, block đảo lớn, quest, và chest
    for _, name in pairs(excludeNames) do
        if string.find(string.lower(obj.Name), string.lower(name)) or 
           (obj.Parent and string.find(string.lower(obj.Parent.Name), string.lower(name))) or 
           obj:IsA("Terrain") then
            return false
        end
    end
    -- Giữ block lớn, anchored (nền đảo)
    if obj:IsA("BasePart") and obj.CanCollide and obj.Anchored and obj.Size.Magnitude > 50 then
        return false
    end
    -- Bảo vệ HumanoidRootPart của player
    if obj == player.Character or (player.Character and obj == player.Character:FindFirstChild("HumanoidRootPart")) then
        return false
    end
    -- Giữ quái và Quest Giver (Model có Humanoid)
    if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
        print("Kept NPC/Quest Giver: " .. obj.Name)
        return false
    end
    -- Giữ rương (Model hoặc BasePart có ClickDetector hoặc tên Chest/Treasure)
    if obj:IsA("Model") or obj:IsA("BasePart") then
        if obj:FindFirstChildOfClass("ClickDetector") then
            print("Kept Chest: " .. obj.Name)
            return false
        end
    end
    return true
end

-- Hàm xóa hoặc làm trong suốt object
local function clearObject(obj)
    if (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) and shouldClear(obj) then
        if obj.Parent == Workspace or obj.Parent:IsDescendantOf(Workspace) then
            obj.Transparency = 1
            obj.CanCollide = false
            print("Hidden: " .. obj.Name .. " at " .. tostring(obj.Position))
        end
    elseif obj:IsA("Model") and shouldClear(obj) then
        Debris:AddItem(obj, 0)
        print("Removed: " .. obj.Name .. " at " .. tostring(obj:GetPivot().Position))
    end
end

-- Hàm clear toàn map (tối giản)
local function clearMap()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(Workspace:GetDescendants()) do
            clearObject(obj)
        end
        print("Map cleared! All objects hidden/removed (including far islands), only large island blocks remain.")
    else
        print("Player not loaded, cannot clear map.")
        return
    end
end

-- Hàm tạo TextLabel hiển thị tên game và level
local function createTextLabel()
    local placeId = game.PlaceId
    local gameName = getGameNameByPlaceId(placeId)
    local level = checkPlayerLevel()
    
    local maxWaitTime = 10
    local waitTime = 0
    while not player:FindFirstChild("PlayerGui") and waitTime < maxWaitTime do
        wait(0.5)
        waitTime = waitTime + 0.5
    end
    local playerGui = player.PlayerGui
    if not playerGui then
        print("ERROR: PlayerGui not found after waiting! TextLabel creation failed.")
        return
    end
    
    if playerGui:FindFirstChild("GameInfoLabel") then
        print("TextLabel already exists, updating text...")
        local textLabel = playerGui.GameInfoLabel:FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = gameName .. " - Level: " .. level
        end
        return
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameInfoLabel"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = playerGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TextLabel"
    textLabel.Size = UDim2.new(1, 0, 0.1, 0)
    textLabel.Position = UDim2.new(0, 0, 0.45, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = gameName .. " - Level: " .. level
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.ZIndex = 1001
    textLabel.Parent = screenGui

    print("TextLabel created successfully with game name: " .. gameName .. " and level: " .. level)
end

-- Clear lần đầu và tạo TextLabel
spawn(function()
    player.CharacterAdded:Connect(function()
        player.Character:WaitForChild("HumanoidRootPart")
        clearMap()
        createTextLabel()
    end)
    
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        clearMap()
        createTextLabel()
    end
end)

-- Lặp clear mỗi 600 giây và cập nhật level
spawn(function()
    while true do
        clearMap()
        if player.PlayerGui and player.PlayerGui:FindFirstChild("GameInfoLabel") then
            local level = checkPlayerLevel()
            local textLabel = player.PlayerGui.GameInfoLabel:FindFirstChild("TextLabel")
            if textLabel then
                textLabel.Text = getGameNameByPlaceId(game.PlaceId) .. " - Level: " .. level
                print("TextLabel updated with level: " .. level)
            end
        else
            print("WARNING: TextLabel not found, recreating...")
            createTextLabel()
        end
        wait(600)
    end
end)




