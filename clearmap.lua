
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local clearRadius = math.huge  -- Bán kính vô cực (xóa cả map)

-- Danh sách loại trừ (giữ lại để đứng được)
local excludeNames = {
    "Player", "NPC", "Humanoid", "HumanoidRootPart", 
    "Terrain", "SpawnLocation", "Platform", "Ground", 
    "Base", "Floor", "Water", "Island", "Dock"  -- Giữ nền đảo
}

-- Hàm kiểm tra xem object có nên xóa/không hiển thị không
local function shouldClear(obj)
    if not obj or not obj.Parent then return false end
    for _, name in pairs(excludeNames) do
        if string.find(string.lower(obj.Name), string.lower(name)) or 
           (obj.Parent and string.find(string.lower(obj.Parent.Name), string.lower(name))) or 
           obj:FindFirstChildOfClass("Humanoid") or
           obj:IsDescendantOf(Players) or
           obj:IsA("Terrain") then
            return false
        end
    end
    -- Giữ block nền lớn (CanCollide, kích thước lớn)
    if obj:IsA("BasePart") and obj.CanCollide and obj.Size.Magnitude > 100 then
        return false
    end
    return true
end

-- Hàm làm vật thể không hiển thị hoặc xóa
local function clearObject(obj)
    if (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) and shouldClear(obj) then
        if obj.Parent == Workspace or obj.Parent:IsDescendantOf(Workspace) then
            -- Làm trong suốt nếu là BasePart
            if obj:IsA("BasePart") then
                obj.Transparency = 1  -- Không hiển thị
                obj.CanCollide = false  -- Không va chạm
            else
                Debris:AddItem(obj, 0)  -- Xóa các model/vật thể khác
            end
            -- print("Cleared: " .. obj.Name)  -- Bỏ comment nếu muốn debug
        end
    elseif obj:IsA("Model") and shouldClear(obj) then
        Debris:AddItem(obj, 0)  -- Xóa model (nhà, cây, v.v.)
    end
end

-- Hàm clear map
local function clearMap()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(Workspace:GetDescendants()) do
            clearObject(obj)
        end
        print("Map cleared! Objects hidden, island blocks remain.")
    else
        print("Player not loaded, cannot clear map.")
        return
    end
end

-- Clear một lần duy nhất
clearMap()
