

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Danh sách debris nhỏ cần clear (đá, vật phẩm rơi, cây nhỏ)
local debrisNames = {
    "Rock", "Stone", "Debris", "Rubble", "Tree", "Bush", "Grass", 
    "Chest", "Barrel", "Crate", "Fruit", "DevilFruit"
}

-- Hàm clear debris
local function clearDebris(obj)
    if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") then
        for _, name in pairs(debrisNames) do
            if string.find(string.lower(obj.Name), string.lower(name)) then
                if obj.Size.Magnitude < 50 then  -- Chỉ clear vật nhỏ, giữ block lớn
                    obj.Transparency = 1  -- Làm trong suốt
                    obj.CanCollide = false  -- Không va chạm
                end
            end
        end
    end
end

-- Hàm clear map nhẹ
local function clearMap()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(Workspace:GetDescendants()) do
            clearDebris(obj)
        end
        print("Debris cleared! Small objects hidden, no falling.")
    else
        print("Player not loaded, cannot clear.")
    end
end

-- Clear một lần
clearMap()
