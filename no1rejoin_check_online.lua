-- ==============================================================================
-- No1rejoin - Auto Heartbeat & Online Check Script (A-Z)
-- Tương thích 100% với hàm read_no1rejoin_ping() trong tool rejoin roblox.py
-- Đặt file này vào thư mục autoexec của Executor
-- ==============================================================================

if getgenv().No1RejoinLoaded then
    return
end
getgenv().No1RejoinLoaded = true

-- 1. Đợi game và LocalPlayer load hoàn tất
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- 2. Cấu hình đường dẫn & thông số theo đúng chuẩn của tool Python:
--    - Folder: <workspace>/No1rejoin
--    - File:   <workspace>/No1rejoin/No1rejoin-<username>.json
--    - Ngưỡng tool check: delta <= 7 giây (cập nhật mỗi 2 giây để luôn an toàn)
local FOLDER_NAME = "No1rejoin"
local USERNAME = LocalPlayer.Name
local FILE_PATH = FOLDER_NAME .. "/No1rejoin-" .. USERNAME .. ".json"
local UPDATE_INTERVAL = 2 -- giây (phải < 7s theo điều kiện delta <= 7 của tool)

-- Kiểm tra các hàm filesystem của Executor
local hasFileSystem = (type(writefile) == "function")
    and (type(isfolder) == "function")
    and (type(makefolder) == "function")

if not hasFileSystem then
    warn("[No1rejoin] Executor không hỗ trợ writefile/isfolder/makefolder!")
    return
end

-- 3. Đảm bảo thư mục No1rejoin tồn tại trong workspace
local function ensureFolder()
    local ok, exists = pcall(isfolder, FOLDER_NAME)
    if ok and not exists then
        pcall(makefolder, FOLDER_NAME)
    end
end

-- 4. Kiểm tra xem acc có bị văng / Kick / Mất kết nối (ErrorPrompt) hay không
--    Nếu bị kick/disconnect, lập tức ngừng ghi file (và xóa file cũ) để tool Python
--    phát hiện OFFLINE ngay lập tức và tiến hành kill PID + Rejoin.
local isDisconnected = false

local function checkDisconnection()
    if isDisconnected then
        return true
    end

    -- Kiểm tra qua GuiService ErrorCode
    local okErr, errCode = pcall(function()
        return GuiService:GetErrorCode()
    end)
    if okErr and errCode and errCode ~= Enum.ConnectionError.OK then
        isDisconnected = true
        return true
    end

    -- Kiểm tra qua RobloxPromptGui (cửa sổ báo Disconnected / Kick)
    local okPrompt, hasErrorPrompt = pcall(function()
        local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
        local overlay = promptGui and promptGui:FindFirstChild("promptOverlay")
        local errPrompt = overlay and overlay:FindFirstChild("ErrorPrompt")
        return errPrompt ~= nil and errPrompt.Visible
    end)
    if okPrompt and hasErrorPrompt then
        isDisconnected = true
        return true
    end

    return false
end

-- Bắt sự kiện ErrorMessageChanged và TeleportInitFailed để phản ứng tức thì
pcall(function()
    GuiService.ErrorMessageChanged:Connect(function()
        isDisconnected = true
        if type(delfile) == "function" and type(isfile) == "function" then
            local ok, exists = pcall(isfile, FILE_PATH)
            if ok and exists then
                pcall(delfile, FILE_PATH)
            end
        end
    end)
end)

-- 5. Hàm ghi dữ liệu ping JSON theo đúng định dạng tool Python đọc:
--    - "date": "%d/%m/%Y" (ví dụ: "09/11/2026")
--    - "time": "%H:%M:%S" (tool split(":") lấy index [1] là phút, [2] là giây)
local function writeHeartbeat()
    ensureFolder()

    local payload = {
        date = os.date("%d/%m/%Y"),
        time = os.date("%H:%M:%S"),
        username = USERNAME,
        placeId = game.PlaceId,
        jobId = game.JobId
    }

    local okEncode, jsonStr = pcall(function()
        return HttpService:JSONEncode(payload)
    end)

    if okEncode and jsonStr then
        pcall(writefile, FILE_PATH, jsonStr)
    else
        -- Fallback tạo chuỗi JSON thủ công nếu HttpService gặp lỗi
        local fallbackJson = string.format(
            '{"date":"%s","time":"%s"}',
            os.date("%d/%m/%Y"),
            os.date("%H:%M:%S")
        )
        pcall(writefile, FILE_PATH, fallbackJson)
    end
end

-- 6. Ghi nhịp ping đầu tiên ngay khi vào game và chạy vòng lặp ngầm
writeHeartbeat()
print(string.format("[No1rejoin] Đã kích hoạt cho %s -> %s", USERNAME, FILE_PATH))

task.spawn(function()
    while task.wait(UPDATE_INTERVAL) do
        if checkDisconnection() then
            warn("[No1rejoin] Phát hiện mất kết nối / bị kick! Ngừng cập nhật để tool tự động Rejoin.")
            if type(delfile) == "function" and type(isfile) == "function" then
                local ok, exists = pcall(isfile, FILE_PATH)
                if ok and exists then
                    pcall(delfile, FILE_PATH)
                end
            end
            break
        end

        writeHeartbeat()
    end
end)
