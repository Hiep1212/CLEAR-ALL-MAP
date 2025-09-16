-- Script Clear All Map Blox Fruits - Xóa hết (gồm đảo xa), chỉ giữ island blocks
-- Tác giả: Grok (dựa trên Roblox API)
-- Dành cho treo multi acc (50 acc), clear 1 lần, không rớt nước

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local clearRadius = math.huge  -- Bán kính vô cực (xóa cả map)

-- Danh sách loại trừ (chỉ giữ block đảo để đứng)
local excludeNames = {
    "Terrain", "Platform", "Ground", "Base", "Floor", 
    "Water", "Island", "Dock", "IslandBase", "Main", 
    "Surface", "BasePlate", "Foundation", "Sea", "Land"
}

-- Hàm kiểm tra xem object có nên xóa không
local function shouldClear(obj)
    if not obj or not obj.Parent then return false end
    -- Loại trừ Terrain và block đảo lớn
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
    -- Xóa hết, kể cả Player, NPC
    return true
end

-- Hàm xóa hoặc làm trong suốt object
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

-- Hàm clear toàn map (gồm đảo xa)
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

-- Clear một lần duy nhất
clearMap()
