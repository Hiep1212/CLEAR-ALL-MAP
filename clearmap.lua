local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

print("Script started! Time: " .. os.date("%H:%M:%S")) -- Debug: Xác nhận script chạy

local player = Players.LocalPlayer
local clearRadius = math.huge  -- Bán kính vô cực (xóa cả map)

-- Danh sách loại trừ (mở rộng để giữ Súng, Kiếm, Melee, Fruit, Tộc V3/V4, v.v.)
local excludeNames = {
    "Terrain", "Platform", "Ground", "Base", "Floor", 
    "Water", "Island", "Dock", "IslandBase", "Main", 
    "Surface", "BasePlate", "Foundation", "Sea", "Land",
    "Quest", "Giver", "Board", "Chest", "Treasure",
    "Gun", "Pistol", "Rifle", "Shotgun", -- Súng
    "Sword", "Katana", "Blade", "Cutlass", -- Kiếm
    "Melee", -- Melee
    "Fruit", "DevilFruit", "BloxFruit", -- Fruit
    "V3", "V4", "RaceV3", "RaceV4" -- Tộc V3/V4
}

-- Hàm kiểm tra xem object có nên xử lý không
local function shouldClear(obj)
    if not obj or not obj.Parent then
        return false
    end
    -- Loại trừ Terrain, quest, bot, rương, Súng, Kiếm, Melee, Fruit, Tộc V3/V4
    for _, name in pairs(excludeNames) do
        if string.find(string.lower(obj.Name), string.lower(name)) or 
           (obj.Parent and string.find(string.lower(obj.Parent.Name), string.lower(name))) then
            print("Kept excluded object: " .. obj.Name .. " (reason: excludeNames match)")
            return false
        end
    end
    -- Loại trừ Terrain
    if obj:IsA("Terrain") then
        print("Kept excluded object: " .. obj.Name .. " (reason: Terrain)")
        return false
    end
    -- Giữ block lớn, anchored (nền đảo) để không rớt nước
    if obj:IsA("BasePart") and obj.CanCollide and obj.Anchored and obj.Size.Magnitude > 25 then
        print("Kept island block: " .. obj.Name .. " at " .. tostring(obj.Position))
        return false
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
    -- Giữ vật phẩm cầm được (Tool hoặc có Handle)
    if obj:IsA("Tool") or obj:FindFirstChild("Handle") then
        print("Kept item/tool: " .. obj.Name .. " (reason: Tool or Handle)")
        return false
    end
    -- Xử lý object vặt (cây, đá, nhà, Boat, Ship, v.v.)
    print("Will process object: " .. obj.Name .. " at " .. tostring(obj.Position or obj:GetPivot().Position))
    return true
end

-- Hàm xử lý object (ẩn, di chuyển, hoặc vô hiệu hóa)
local function clearObject(obj)
    pcall(function()
        if (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) and shouldClear(obj) then
            if obj.Parent == Workspace or obj.Parent:IsDescendantOf(Workspace) then
                -- Thử ẩn bằng LocalTransparencyModifier
                obj.LocalTransparencyModifier = 1
                obj.CanCollide = false
                print("Hidden: " .. obj.Name .. " at " .. tostring(obj.Position))
                -- Nếu ẩn không được, thử di chuyển
                if obj.LocalTransparencyModifier ~= 1 then
                    obj.Position = Vector3.new(0, -1000, 0)
                    print("Moved: " .. obj.Name .. " to " .. tostring(obj.Position))
                    -- Nếu di chuyển không được, vô hiệu hóa rendering
                    if obj.Position.Y > -500 then
                        obj.Parent = nil
                        print("Disabled rendering: " .. obj.Name)
                    end
                end
            end
        elseif obj:IsA("Model") and shouldClear(obj) then
            -- Xử lý tất cả BasePart trong Model
            for _, part in pairs(obj:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
                    part.LocalTransparencyModifier = 1
                    part.CanCollide = false
                    print("Hidden: " .. part.Name .. " in Model " .. obj.Name .. " at " .. tostring(part.Position))
                    if part.LocalTransparencyModifier ~= 1 then
                        part.Position = Vector3.new(0, -1000, 0)
                        print("Moved: " .. part.Name .. " in Model " .. obj.Name .. " to " .. tostring(part.Position))
                        if part.Position.Y > -500 then
                            part.Parent = nil
                            print("Disabled rendering: " .. part.Name .. " in Model " .. obj.Name)
                        end
                    end
                end
                wait(0.02) -- Delay để né anti-cheat
            end
        end
        wait(0.02) -- Delay để né anti-cheat
    end, function(err)
        print("ERROR processing object " .. obj.Name .. ": " .. tostring(err))
    end)
end

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

-- Hàm tạo và update TextLabel
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
    
    local screenGui = playerGui:FindFirstChild("GameInfoLabel")
    if screenGui then
        local textLabel = screenGui:FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = gameName .. " - Level: " .. level
            print("TextLabel updated with game name: " .. gameName .. " and level: " .. level)
        end
        return
    end
    
    screenGui = Instance.new("ScreenGui")
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

    print("TextLabel created with game name: " .. gameName .. " and level: " .. level)
    
    -- Theo dõi thay đổi level
    if player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") then
        player.Data.Level.Changed:Connect(function(newLevel)
            textLabel.Text = gameName .. " - Level: " .. tostring(newLevel)
            print("TextLabel updated on level change: " .. tostring(newLevel))
        end)
    end
end

-- Hàm clear map (duyệt Workspace:GetChildren để nhẹ hơn)
local function clearMap()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        print("ERROR: Player or HumanoidRootPart not loaded, cannot clear map.")
        return
    end
    local total = 0
    local processed = 0
    for _, obj in pairs(Workspace:GetChildren()) do
        total = total + 1
        if shouldClear(obj) then
            clearObject(obj)
            processed = processed + 1
        end
    end
    print("Map cleared! Total objects: " .. total .. ", Processed: " .. processed)
end

-- Clear lần đầu và tạo TextLabel
spawn(function()
    player.CharacterAdded:Connect(function()
        player.Character:WaitForChild("HumanoidRootPart")
        wait(3)  -- Đợi map load đầy đủ
        print("Character loaded, starting initial clear...")
        clearMap()
        createTextLabel()
    end)
    
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        wait(3)  -- Đợi map load đầy đủ
        print("Player loaded, starting initial clear...")
        clearMap()
        createTextLabel()
    else
        print("ERROR: Player or HumanoidRootPart not loaded on start.")
    end
end)

-- Lặp clear mỗi 600 giây và cập nhật TextLabel
spawn(function()
    while true do
        print("Starting periodic map clear...")
        clearMap()
        if player.PlayerGui and player.PlayerGui:FindFirstChild("GameInfoLabel") then
            local level = checkPlayerLevel()
            local textLabel = player.PlayerGui.GameInfoLabel:FindFirstChild("TextLabel")
            if textLabel then
                textLabel.Text = getGameNameByPlaceId(game.PlaceId) .. " - Level: " .. level
                print("TextLabel updated with level: " .. level)
            else
                print("WARNING: TextLabel not found, recreating...")
                createTextLabel()
            end
        else
            print("WARNING: GameInfoLabel not found, recreating...")
            createTextLabel()
        end
        wait(600)
    end
end)
