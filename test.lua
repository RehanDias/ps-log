-- Hapus GUI lama
if getgenv().PlayerLoggerGui then
    pcall(function() getgenv().PlayerLoggerGui:Destroy() end)
end
getgenv().PlayerLoggerRunning = false

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local WEBHOOK_URL = "" -- Ganti ini

local connections = {}

-- Webhook
local function sendToWebhook(title, player)
    local embed = {
        title = title,
        color = title:find("Join") and 0x32CD32 or 0xDC143C,
        fields = {
            { name = "Username", value = player.Name, inline = true },
            { name = "DisplayName", value = player.DisplayName, inline = true },
            { name = "UserId", value = tostring(player.UserId), inline = true },
        },
        timestamp = DateTime.now():ToIsoDate()
    }

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
Frame.Size = UDim2.new(0, 100, 0, 30)
Frame.Position = UDim2.new(0, 20, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

-- Label
local label = Instance.new("TextLabel", Frame)
label.Size = UDim2.new(0, 30, 0, 30)
label.Position = UDim2.new(0, 5, 0, 0)
label.BackgroundTransparency = 1
label.Text = "LOG"
label.TextColor3 = Color3.new(1,1,1)
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Button
local toggle = Instance.new("TextButton", Frame)
toggle.Size = UDim2.new(0, 30, 0, 20)
toggle.Position = UDim2.new(0, 40, 0, 5)
toggle.Text = "OFF"
toggle.Font = Enum.Font.Gotham
toggle.TextSize = 12
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
toggle.AutoButtonColor = false

toggle.MouseButton1Click:Connect(function()
    getgenv().PlayerLoggerRunning = not getgenv().PlayerLoggerRunning
    if getgenv().PlayerLoggerRunning then
        toggle.Text = "ON"
        toggle.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        connect()
    else
        toggle.Text = "OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
        disconnect()
    end
end)

-- Close Button (X)
local close = Instance.new("TextButton", Frame)
close.Size = UDim2.new(0, 20, 0, 20)
close.Position = UDim2.new(1, -25, 0, 5)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 12
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
close.MouseButton1Click:Connect(function()
    getgenv().PlayerLoggerRunning = false
    disconnect()
    Gui:Destroy()
    getgenv().PlayerLoggerGui = nil
end)
