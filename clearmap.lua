local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

-- Danh sách loại trừ (thu hẹp để clear mạnh hơn)
local excludeNames = {
    "Terrain", "Quest", "Giver", "Board", "Bot", "Enemy", "Chest", "Treasure",
    "IslandBase", "IslandFloor", "Main", "Floor", "Base"
}

-- Hàm ánh xạ Place ID sang tên game
local function getGameNameByPlaceId(placeId)
    local gameNames = {
        ["2753915549"] = "BLOX FRUIT SEA 1",
        ["4442272183"] = "BLOX FRUIT SEA 2",
        ["7449423635"] = "BLOX FRUIT SEA 3"
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

-- Hàm check tên đảo player đang đứng
local function getCurrentIsland()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        print("ERROR: HumanoidRootPart not found for island check.")
        return nil
    end
    local rootPart = player.Character.HumanoidRootPart
    local ray = Ray.new(rootPart.Position, Vector3.new(0, -100, 0))
    local ignoreList = {player.Character}
    local part = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    if part then
        local island = part:FindFirstAncestorOfClass("Model")
        if island and island.Parent == Workspace:FindFirstChild("Islands") then
            print("Current island: " .. island.Name)
            return island.Name:lower()
        end
    end
    print("WARNING: Current island not detected.")
    return nil
end

-- Hàm điều chỉnh ngưỡng Size.Magnitude theo Place ID và đảo
local function getIslandThreshold(obj, placeId)
    local islandName = obj.Name:lower()
    local parent = obj.Parent
    while parent and parent ~= Workspace do
        if parent.Parent == Workspace:FindFirstChild("Islands") then
            islandName = parent.Name:lower()
            break
        end
        parent = parent.Parent
    end

    if placeId == "2753915549" then  -- Sea 1
        if string.find(islandName, "jungle") then
            return 10  -- Block rất nhỏ cho Jungle
        elseif string.find(islandName, "windmill") then
            return 20  -- Block trung bình cho Windmill Village
        elseif string.find(islandName, "marine") then
            return 40  -- Block lớn cho Marine Starter
        end
    elseif placeId == "4442272183" then  -- Sea 2
        if string.find(islandName, "marineford") then
            return 50  -- Block lớn cho Marineford
        elseif string.find(islandName, "desert") then
            return 15  -- Block nhỏ cho Desert
        elseif string.find(islandName, "dressrosa") then
            return 30  -- Block trung bình cho Dressrosa
        end
    elseif placeId == "7449423635" then  -- Sea 3
        if string.find(islandName, "skypiea") then
            return 30  -- Block trung bình cho Skypiea
        elseif string.find(islandName, "turtle") then
            return 40  -- Block lớn cho Turtle Island
        end
    end
    return 25  -- Mặc định cho các đảo khác
end

-- Hàm kiểm tra xem object có nên xóa không
local function shouldClear(obj)
    if not obj or not obj.Parent then
        print("Skipped null object or no parent: " .. tostring(obj))
        return false
    end
    -- Loại trừ Terrain, quest, bot, rương
    for _, name in pairs(excludeNames) do
        if string.find(string.lower(obj.Name), string.lower(name)) or 
           (obj.Parent and string.find(string.lower(obj.Parent.Name), string.lower(name))) or 
           obj:IsA("Terrain") then
            print("Kept excluded object: " .. obj.Name)
            return false
        end
    end
    -- Giữ block lớn, anchored (nền đảo) theo ngưỡng của đảo
    if obj:IsA("BasePart") and obj.CanCollide and obj.Anchored then
        local currentIsland = getCurrentIsland()
        local threshold = getIslandThreshold(obj, tostring(game.PlaceId))
        -- Chỉ giữ block thuộc đảo player đang đứng
        local objIsland = obj.Parent
        while objIsland and objIsland ~= Workspace do
            if objIsland.Parent == Workspace:FindFirstChild("Islands") and objIsland.Name:lower() == currentIsland then
                if obj.Size.Magnitude > threshold then
                    print("Kept island block (threshold " .. threshold .. "): " .. obj.Name .. " at " .. tostring(obj.Position))
                    return false
                end
            end
            objIsland = objIsland.Parent
        end
    end
    -- Giữ player và NPC quest/bot/quái (Model có Humanoid)
    if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
        print("Kept player/NPC quest/bot/quai: " .. obj.Name)
        return false
    end
    -- Giữ rương (Model hoặc BasePart có ClickDetector)
    if (obj:IsA("Model") or obj:IsA("BasePart")) and obj:FindFirstChildOfClass("ClickDetector") then
        print("Kept rương: " .. obj.Name)
        return false
    end
    return true
end

-- Hàm xóa hoặc làm trong suốt object
local function clearObject(obj)
    if (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) and shouldClear(obj) then
        if obj.Parent == Workspace or obj.Parent:IsDescendantOf(Workspace) then
            obj.Transparency = 1  -- Làm trong suốt
            obj.CanCollide = false  -- Không va chạm
            print("Hidden: " .. obj.Name .. " at " .. tostring(obj.Position))
        end
    elseif obj:IsA("Model") and shouldClear(obj) then
        Debris:AddItem(obj, 0)  -- Xóa model (nhà, cây, v.v.)
        print("Removed: " .. obj.Name .. " at " .. tostring(obj:GetPivot().Position))
    end
end

-- Hàm clear toàn map
local function clearMap()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        print("Player not loaded, cannot clear map.")
        return
    end

    local totalObjects = 0
    local keptObjects = 0
    local removedObjects = 0
    local objectsToClear = Workspace:GetDescendants()  -- Duyệt toàn Workspace

    for _, obj in pairs(objectsToClear) do
        totalObjects = totalObjects + 1
        if shouldClear(obj) then
            clearObject(obj)
            removedObjects = removedObjects + 1
        else
            keptObjects = keptObjects + 1
        end
    end
    print(string.format("Map cleared! Total objects: %d, Kept: %d, Removed: %d", totalObjects, keptObjects, removedObjects))
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
        wait(2)  -- Đợi thêm để đảm bảo map load
        clearMap()
        createTextLabel()
    end)
    
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        wait(2)  -- Đợi thêm để đảm bảo map load
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
