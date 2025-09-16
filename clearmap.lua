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

local function createBlackScreen()
    local placeId = game.PlaceId
    local gameName = getGameNameByPlaceId(placeId)
    
    -- Wait cho PlayerGui load (fix lỗi không load kịp)
    if not player:FindFirstChild("PlayerGui") then
        player.ChildAdded:Wait()  -- Đợi PlayerGui xuất hiện
    end
    local playerGui = player.PlayerGui
    if not playerGui then
        print("ERROR: PlayerGui not found! Black screen creation failed.")
        return
    end
    
    -- Check nếu GUI đã tồn tại (tránh tạo trùng)
    if playerGui:FindFirstChild("BlackScreenOverlay") then
        print("Black screen already exists, skipping creation.")
        return
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BlackScreenOverlay"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)  -- Che toàn màn hình
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)  -- Màu đen
    frame.BackgroundTransparency = 0  -- Không trong suốt
    frame.BorderSizePixel = 0  -- Không viền
    frame.Parent = screenGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.1, 0)  -- Kích thước chữ
    textLabel.Position = UDim2.new(0, 0, 0.45, 0)  -- Ở giữa màn hình
    textLabel.BackgroundTransparency = 1  -- Trong suốt nền chữ
    textLabel.Text = gameName  -- Tên game
    textLabel.TextColor3 = Color3.new(1, 1, 1)  -- Màu trắng
    textLabel.TextScaled = true  -- Tự điều chỉnh kích thước chữ
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0  -- Thêm viền chữ để dễ đọc trên nền đen
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = frame

    print("Black screen created successfully with game name: " .. gameName)
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

spawn(function()
    while wait(600) do
        clearMap()
    end
end)



