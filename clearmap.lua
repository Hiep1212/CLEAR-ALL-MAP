local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local clearRadius = math.huge  -- Bán kính vô cực (xóa cả map)

-- Danh sách loại trừ (giữ lại để tránh reset character)
local excludeNames = {
    "Player", "NPC", "Humanoid", "HumanoidRootPart", "SpawnLocation", 
    "Terrain", "Camera", "Core"  -- Thêm bảo vệ spawn, terrain, core
}

-- Hàm kiểm tra xem object có nên xóa không
local function shouldClear(obj)
    if not obj or not obj.Parent then return false end
    for _, name in pairs(excludeNames) do
        if string.find(string.lower(obj.Name), string.lower(name)) or 
           (obj.Parent and string.find(string.lower(obj.Parent.Name), string.lower(name))) or 
           obj:FindFirstChildOfClass("Humanoid") or
           obj:IsDescendantOf(Players) or
           obj:IsA("Terrain") or
           obj:IsDescendantOf(game:GetService("Camera")) then
            return false
        end
    end
    return true
end

-- Hàm clear object
local function clearObject(obj)
    if (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) and shouldClear(obj) then
        if obj.Parent == Workspace or obj.Parent:IsDescendantOf(Workspace) then
            Debris:AddItem(obj, 0)  -- Destroy tức thì
            -- print("Cleared: " .. obj.Name)  -- Bỏ comment nếu muốn debug
        end
    end
end

-- Hàm clear toàn map
local function clearMap()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(Workspace:GetDescendants()) do
            clearObject(obj)
        end
        print("Map cleared! Only Players/NPCs remain.")
    else
        print("Player not loaded, cannot clear map.")
        return
    end
end

-- Clear một lần duy nhất
clearMap()
