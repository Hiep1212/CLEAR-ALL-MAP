local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local clearRadius = math.huge  -- Bán kính vô cực (xóa cả map)
local excludeNames = {
    "Terrain", "Platform", "Ground", "Base", "Floor", 
    "Water", "Island", "Dock", "IslandBase", "Main", 
    "Surface", "BasePlate", "Foundation", "Sea", "Land"
}
local function shouldClear(obj)
    if not obj or not obj.Parent then return false end
    for _, name in pairs(excludeNames) do
        if string.find(string.lower(obj.Name), string.lower(name)) or 
           (obj.Parent and string.find(string.lower(obj.Parent.Name), string.lower(name))) or 
           obj:IsA("Terrain") then
            return false
        end
    end
    if obj:IsA("BasePart") and obj.CanCollide and obj.Anchored and obj.Size.Magnitude > 50 then
        return false
    end
    return true
end

local function clearObject(obj)
    if (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) and shouldClear(obj) then
        if obj.Parent == Workspace or obj.Parent:IsDescendantOf(Workspace) then
            obj.Transparency = 1  -- Làm trong suốt
            obj.CanCollide = false  -- Không va chạm
            print("Hidden: " .. obj.Name .. " at " .. tostring(obj.Position))  -- Debug vị trí
        end
    elseif obj:IsA("Model") and shouldClear(obj) then
        Debris:AddItem(obj, 0)  -- Xóa model (nhà, cây, Player, NPC, v.v.)
        print("Removed: " .. obj.Name .. " at " .. tostring(obj:GetPivot().Position))  -- Debug vị trí
    end
end
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
local function createBlackScreen()
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
        print("ERROR: PlayerGui not found after waiting! Black screen creation failed.")
        return
    end
    
    if playerGui:FindFirstChild("BlackScreenOverlay") then
        print("Black screen already exists, updating text...")
        local frame = playerGui.BlackScreenOverlay:FindFirstChild("Frame")
        if frame and frame:FindFirstChild("TextLabel") then
            frame.TextLabel.Text = gameName .. " - Level: " .. level
        end
        return
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BlackScreenOverlay"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.ZIndex = 1000
    frame.Parent = screenGui

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
    textLabel.Parent = frame

    print("Black screen created successfully with game name: " .. gameName .. " and level: " .. level)
end
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
spawn(function()
    player.CharacterAdded:Connect(function()
        player.Character:WaitForChild("HumanoidRootPart")
        clearMap()
        createBlackScreen()
    end)
    
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        clearMap()
        createBlackScreen()
    end
end)

-- Lặp clear mỗi 600 giây và cập nhật level
spawn(function()
    while true do
        clearMap()
        if player.PlayerGui and player.PlayerGui:FindFirstChild("BlackScreenOverlay") then
            local level = checkPlayerLevel()
            local frame = player.PlayerGui.BlackScreenOverlay:FindFirstChild("Frame")
            if frame and frame:FindFirstChild("TextLabel") then
                frame.TextLabel.Text = getGameNameByPlaceId(game.PlaceId) .. " - Level: " .. level
                print("Black screen updated with level: " .. level)
            end
        else
            print("WARNING: Black screen not found, recreating...")
            createBlackScreen()
        end
        wait(600)
    end
end)



