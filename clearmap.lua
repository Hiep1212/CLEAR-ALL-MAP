-- Script Clear ALL Map Blox Fruits - Xóa mọi vật thể trừ Player/NPC/Humanoid
-- Tác giả: Grok (dựa trên Roblox API)
-- Dành cho treo multi acc (50 acc), chạy ngay không toggle

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local clearRadius = math.huge  -- Bán kính vô cực (xóa cả map)
local clearInterval = 2  -- Clear mỗi 2 giây (tối ưu lag)

-- Danh sách loại trừ (chỉ giữ những thứ này)
local excludeNames = {
    "Player", "NPC", "Humanoid"  -- Chỉ giữ player và NPC
}

-- Hàm kiểm tra xem object có nên xóa không
local function shouldClear(obj)
    if not obj or not obj.Parent then return false end
    for _, name in pairs(excludeNames) do
        if string.find(string.lower(obj.Name), string.lower(name)) or 
           (obj.Parent and string.find(string.lower(obj.Parent.Name), string.lower(name))) or 
           obj:FindFirstChildOfClass("Humanoid") or
           obj:IsDescendantOf(Players) then
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
        print("Player not loaded, waiting...")
    end
end

-- Clear ngay lập tức khi chạy
clearMap()

-- Loop clear liên tục
spawn(function()
    while wait(clearInterval) do
        clearMap()
    end
end)

-- Auto-reconnect nếu disconnect
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        print("Disconnected, attempting to reconnect...")
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end
end)