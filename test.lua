-- Hapus GUI lama
if getgenv().PlayerLoggerGui then
    pcall(function() getgenv().PlayerLoggerGui:Destroy() end)
end
getgenv().PlayerLoggerRunning = false

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local WEBHOOK_URL = "" -- Ganti dengan webhook kamu
local connections = {}

-- Kirim ke webhook
local function sendToWebhook(title, player)
    local username, displayName, userId = player.Name, player.DisplayName, player.UserId
    local avatar = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"

    local success, pingVal = pcall(function()
        local raw = player:GetNetworkPing()
        if typeof(raw) ~= "number" or raw < 0 or raw > 10 then return "Unavailable" end
        return math.floor(raw * 1000) .. " ms"
    end)
    local ping = success and pingVal or "Unavailable"

    local embed = {
        title = title,
        color = title:find("Join") and 0x32CD32 or 0xDC143C,
        thumbnail = { url = avatar },
        fields = {
            { name = "Username", value = "`" .. username .. "`", inline = true },
            { name = "Display Name", value = "`" .. displayName .. "`", inline = true },
            { name = "User ID", value = "`" .. userId .. "`", inline = true },
            { name = "Ping", value = "`" .. ping .. "`", inline = true },
        },
        timestamp = DateTime.now():ToIsoDate()
    }

    task.spawn(function()
        local req = http_request or request or (syn and syn.request)
        if req then
            pcall(function()
                req({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HttpService:JSONEncode({
                        username = "Private Server LOG",
                        embeds = { embed }
                    })
                })
            end)
        end
    end)
end

local function connect()
    table.insert(connections, Players.PlayerAdded:Connect(function(p)
        sendToWebhook("Join", p)
    end))
    table.insert(connections, Players.PlayerRemoving:Connect(function(p)
        sendToWebhook("Leave", p)
    end))
end

local function disconnect()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    connections = {}
end

-- GUI
local Gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
Gui.Name = "PlayerLoggerGui"
Gui.ResetOnSpawn = false
getgenv().PlayerLoggerGui = Gui

local Frame = Instance.new("Frame", Gui)
Frame.Size = UDim2.new(0, 120, 0, 40)
Frame.Position = UDim2.new(0, 20, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Frame).Color = Color3.fromRGB(60, 60, 60)

-- Label LOG
local label = Instance.new("TextLabel", Frame)
label.Size = UDim2.new(0, 30, 0, 20)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 1
label.Text = "LOG"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 13

-- Toggle ON/OFF
local toggle = Instance.new("TextButton", Frame)
toggle.Size = UDim2.new(0, 36, 0, 20)
toggle.Position = UDim2.new(0, 45, 0, 10)
toggle.Text = "OFF"
toggle.Font = Enum.Font.Gotham
toggle.TextSize = 12
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
toggle.AutoButtonColor = false
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

toggle.MouseButton1Click:Connect(function()
    getgenv().PlayerLoggerRunning = not getgenv().PlayerLoggerRunning
    if getgenv().PlayerLoggerRunning then
        toggle.Text = "ON"
        toggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        connect()
    else
        toggle.Text = "OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        disconnect()
    end
end)

-- Tombol "X" kecil di pojok
local closeBtn = Instance.new("TextButton", Frame)
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -25, 0, 10)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

closeBtn.MouseButton1Click:Connect(function()
    getgenv().PlayerLoggerRunning = false
    disconnect()
    if getgenv().PlayerLoggerGui then
        getgenv().PlayerLoggerGui:Destroy()
        getgenv().PlayerLoggerGui = nil
    end
end)
