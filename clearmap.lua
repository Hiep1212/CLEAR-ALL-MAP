local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

-- Danh sách vật thể cần clear (chỉ vật thừa nhỏ)
local clearNames = {
    "Rock", "Stone", "Debris", "Rubble", "Tree", "Bush", "Grass", 
    "Chest", "Barrel", "Crate", "Fruit", "DevilFruit", "Quest", 
    "Boat", "Ship", "House", "Building"
}

-- Danh sách loại trừ (giữ lại để đứng được)
local excludeNames = {
    "Player", "NPC", "Humanoid", "HumanoidRootPart", 
    "Terrain", "SpawnLocation", "Platform", "Ground", 
    "Base", "Floor", "Water", "Island", "Dock", 
    "IslandBase", "Main", "Surface", "BasePlate", 
    "Foundation", "Sea", "Land"
}

-- Hàm kiểm tra xem object có nên clear không
local function shouldClear(obj)
    if not obj or not obj.Parent then return false end
    -- Loại trừ block nền, player, NPC
    for _, name in pairs(excludeNames) do
        if string.find(string.lower(obj.Name), string.lower(name)) or 
           (obj.Parent and string.find(string.lower(obj.Parent.Name), string.lower(name))) or 
           obj:FindFirstChildOfClass("Humanoid") or
           obj:IsDescendantOf(Players) or
           obj:IsA("Terrain") then
            return false
        end
    end
    -- Giữ block lớn, anchored (nền đảo)
    if obj:IsA("BasePart") and (obj.CanCollide and obj.Size.Magnitude > 20 or obj.Anchored) then
        return false
    end
    -- Clear vật thể nhỏ trong danh sách
    for _, name in pairs(clearNames) do
        if string.find(string.lower(obj.Name), string.lower(name)) then
            return true
        end
    end
    return false
end

-- Hàm làm vật thể không hiển thị hoặc xóa
local function clearObject(obj)
    if (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) and shouldClear(obj) then
        if obj.Parent == Workspace or obj.Parent:IsDescendantOf(Workspace) then
            obj.Transparency = 1  -- Làm trong suốt
            obj.CanCollide = false  -- Không va chạm
        end
    elseif obj:IsA("Model") and shouldClear(obj) then
        Debris:AddItem(obj, 0)  -- Xóa model thừa (nhà, cây, vật phẩm)
    end
end

-- Hàm clear map nhẹ
local function clearMap()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(Workspace:GetDescendants()) do
            clearObject(obj)
        end
        print("Map cleared lightly! Debris hidden, island blocks remain - no falling.")
    else
        print("Player not loaded, cannot clear map.")
        return
    end
end

-- Clear một lần duy nhất
clearMap()
