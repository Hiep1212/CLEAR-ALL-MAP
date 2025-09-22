local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local function GetChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function GetRoot()
    local char = GetChar()
    return char:FindFirstChild("HumanoidRootPart")
end

local Modules = RS:WaitForChild("Modules")
local CombatUtil = require(Modules:WaitForChild("CombatUtil"))
local RE_Attack = Modules.Net:WaitForChild("RE/RegisterAttack")

local HIT_FUNCTION
local RunHitDetection = CombatUtil.RunHitDetection
pcall(function()
    local env = getsenv(Modules.CombatUtil)
    if env and env._G and env._G.SendHitsToServer then
        HIT_FUNCTION = env._G.SendHitsToServer
    end
end)

local FastAttack = {}

function FastAttack:IsAlive(mob)
    return mob
        and mob:FindFirstChild("Humanoid")
        and mob.Humanoid.Health > 0
        and mob:FindFirstChild("HumanoidRootPart")
end

function FastAttack:GetTargets(radius)
    local res = {}
    local root = GetRoot()
    if not root then return res end

    local pos = root.Position
    for _, mob in ipairs(workspace.Enemies:GetChildren()) do
        if self:IsAlive(mob) then
            if (mob.HumanoidRootPart.Position - pos).Magnitude <= (radius or 60) then
                table.insert(res, mob)
            end
        end
    end
    return res
end

function FastAttack:GetHitbox(mob)
    local list = {
        "RightLowerArm","RightUpperArm","LeftLowerArm","LeftUpperArm",
        "RightHand","LeftHand","HumanoidRootPart","Head"
    }
    return mob:FindFirstChild(list[math.random(1,#list)]) or mob.HumanoidRootPart
end

function FastAttack:Attack()
    local char = GetChar()
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    if tool.ToolTip == "Blox Fruit" then
        local remote = tool:FindFirstChild("LeftClickRemote")
        if remote then
            remote:FireServer(Vector3.new(0,-500,0),1,true)
            remote:FireServer(false)
        end
        return
    end

    local targets = self:GetTargets(65)
    if #targets == 0 then return end

    local args = {[1]=nil,[2]={}}
    for _, mob in ipairs(targets) do
        local hit = self:GetHitbox(mob)
        if not args[1] then args[1] = hit end
        table.insert(args[2], {mob, hit})
    end

    RE_Attack:FireServer(0)
    if HIT_FUNCTION then
        HIT_FUNCTION(unpack(args))
    end
end

_G.FastAttackToggle = true
RunService.Heartbeat:Connect(function()
    if _G.FastAttackToggle then
        pcall(function()
            FastAttack:Attack()
        end)
    end
end)
