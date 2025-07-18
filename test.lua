-- Hapus GUI lama
if getgenv().PlayerLoggerGui then
    pcall(function() getgenv().PlayerLoggerGui:Destroy() end)
end
getgenv().PlayerLoggerRunning = false

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local WEBHOOK_URL = ""

local connections = {}

-- Kirim data ke Discord
local function sendToWebhook(title, player)
    local username = player.Name or "Unknown"
    local displayName = player.DisplayName or "Unknown"
    local userId = player.UserId or 0
    local avatar = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"

    local success, pingVal = pcall(function()
        local raw = player:GetNetworkPing()
        if typeof(raw) ~= "number" or raw < 0 or raw > 10 then return "Unavailable" end
        return math.floor(raw * 1000) .. " ms"
    end)
    local ping = success and pingVal or "Unavailable"

    local embed = {
        title = title,
        color = title:find("Join") and 0x32CD32 or 0xDC143C, -- hijau/merah
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

-- Sambungkan event player
local function connect()
    table.insert(connections, Players.PlayerAdded:Connect(function(p)
        sendToWebhook("Player Join", p)
    end))
    table.insert(connections, Players.PlayerRemoving:Connect(function(p)
        sendToWebhook("Player Leave", p)
    end))
end

local function disconnect()
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

-- GUI
local Gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
Gui.Name = "PlayerLoggerGui"
Gui.ResetOnSpawn = false
getgenv().PlayerLoggerGui = Gui

local Frame = Instance.new("Frame", Gui)
Frame.Size = UDim2.new(0, 210, 0, 90)
Frame.Position = UDim2.new(0, 20, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Frame).Color = Color3.fromRGB(60, 60, 60)

-- Label
local label = Instance.new("TextLabel", Frame)
label.Size = UDim2.new(0.7, 0, 0, 20)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 1
label.Text = "Player Logger"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Slider
local toggle = Instance.new("TextButton", Frame)
toggle.Size = UDim2.new(0, 60, 0, 24)
toggle.Position = UDim2.new(1, -70, 0, 8)
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

-- Tombol Destroy
local destroy = Instance.new("TextButton", Frame)
destroy.Size = UDim2.new(1, -20, 0, 28)
destroy.Position = UDim2.new(0, 10, 0, 50)
destroy.Text = "Destroy GUI"
destroy.Font = Enum.Font.GothamSemibold
destroy.TextSize = 13
destroy.TextColor3 = Color3.fromRGB(255, 255, 255)
destroy.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Instance.new("UICorner", destroy).CornerRadius = UDim.new(0, 6)

destroy.MouseButton1Click:Connect(function()
    getgenv().PlayerLoggerRunning = false
    disconnect()
    if getgenv().PlayerLoggerGui then
        getgenv().PlayerLoggerGui:Destroy()
        getgenv().PlayerLoggerGui = nil
    end
end)
