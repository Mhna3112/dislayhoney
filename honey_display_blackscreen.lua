-- Honey Display UI for Bee Swarm Simulator - Black Screen Version
-- Auto Black Screen khi execute, hiển thị đầy đủ số không viết tắt
-- Version: 1.2 - Updated: 04/02/2026

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Variables for honey per second calculation
local honeyPerSecond = 0
local honeyHistory = {}

-- Server time tracking
local serverJoinTime = tick()

-- Create the UI
local HoneyDisplayGui = Instance.new("ScreenGui")
HoneyDisplayGui.Name = "HoneyDisplayBlackScreen"
HoneyDisplayGui.ResetOnSpawn = false
HoneyDisplayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
HoneyDisplayGui.Parent = game.CoreGui

-- Black Screen Frame (full screen overlay)
local BlackScreen = Instance.new("Frame")
BlackScreen.Name = "BlackScreen"
BlackScreen.Size = UDim2.new(2, 0, 2, 0)
BlackScreen.Position = UDim2.new(-0.5, 0, -0.5, 0)
BlackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackScreen.BorderSizePixel = 0
BlackScreen.Visible = true -- Auto visible khi execute
BlackScreen.ZIndex = 100
BlackScreen.Parent = HoneyDisplayGui

-- Container chính để căn giữa nội dung
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(0, 500, 0, 300)
ContentContainer.Position = UDim2.new(0.5, -250, 0.5, -150)
ContentContainer.BackgroundTransparency = 0.8
ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ContentContainer.BorderSizePixel = 0
ContentContainer.ZIndex = 101
ContentContainer.Parent = BlackScreen

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 15)
ContentCorner.Parent = ContentContainer

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Position = UDim2.new(0, 0, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🐝 Honey Display 🐝"
TitleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
TitleLabel.TextSize = 28
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.ZIndex = 102
TitleLabel.Parent = ContentContainer

-- Server Time Display
local ServerTimeLabel = Instance.new("TextLabel")
ServerTimeLabel.Name = "ServerTimeLabel"
ServerTimeLabel.Size = UDim2.new(1, -40, 0, 35)
ServerTimeLabel.Position = UDim2.new(0, 20, 0, 55)
ServerTimeLabel.BackgroundTransparency = 0.7
ServerTimeLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
ServerTimeLabel.Text = "⏱️ Server Time: 00:00:00"
ServerTimeLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
ServerTimeLabel.TextSize = 22
ServerTimeLabel.Font = Enum.Font.GothamSemibold
ServerTimeLabel.ZIndex = 102
ServerTimeLabel.Parent = ContentContainer

local ServerTimeCorner = Instance.new("UICorner")
ServerTimeCorner.CornerRadius = UDim.new(0, 8)
ServerTimeCorner.Parent = ServerTimeLabel

-- Honey Total Display
local HoneyTotalLabel = Instance.new("TextLabel")
HoneyTotalLabel.Name = "HoneyTotalLabel"
HoneyTotalLabel.Size = UDim2.new(1, -40, 0, 40)
HoneyTotalLabel.Position = UDim2.new(0, 20, 0, 100)
HoneyTotalLabel.BackgroundTransparency = 0.7
HoneyTotalLabel.BackgroundColor3 = Color3.fromRGB(60, 50, 20)
HoneyTotalLabel.Text = "🍯 Honey: 0"
HoneyTotalLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
HoneyTotalLabel.TextSize = 26
HoneyTotalLabel.Font = Enum.Font.GothamBold
HoneyTotalLabel.ZIndex = 102
HoneyTotalLabel.Parent = ContentContainer

local HoneyTotalCorner = Instance.new("UICorner")
HoneyTotalCorner.CornerRadius = UDim.new(0, 8)
HoneyTotalCorner.Parent = HoneyTotalLabel

-- Honey Per Second Display
local HoneyPerSecLabel = Instance.new("TextLabel")
HoneyPerSecLabel.Name = "HoneyPerSecLabel"
HoneyPerSecLabel.Size = UDim2.new(1, -40, 0, 35)
HoneyPerSecLabel.Position = UDim2.new(0, 20, 0, 150)
HoneyPerSecLabel.BackgroundTransparency = 0.7
HoneyPerSecLabel.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
HoneyPerSecLabel.Text = "⚡ Honey/s: 0"
HoneyPerSecLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
HoneyPerSecLabel.TextSize = 22
HoneyPerSecLabel.Font = Enum.Font.GothamSemibold
HoneyPerSecLabel.ZIndex = 102
HoneyPerSecLabel.Parent = ContentContainer

local HoneyPerSecCorner = Instance.new("UICorner")
HoneyPerSecCorner.CornerRadius = UDim.new(0, 8)
HoneyPerSecCorner.Parent = HoneyPerSecLabel

-- Pollen Display
local PollenLabel = Instance.new("TextLabel")
PollenLabel.Name = "PollenLabel"
PollenLabel.Size = UDim2.new(1, -40, 0, 35)
PollenLabel.Position = UDim2.new(0, 20, 0, 195)
PollenLabel.BackgroundTransparency = 0.7
PollenLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 30)
PollenLabel.Text = "🌸 Pollen: 0 / 0 (0%)"
PollenLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
PollenLabel.TextSize = 20
PollenLabel.Font = Enum.Font.GothamSemibold
PollenLabel.ZIndex = 102
PollenLabel.Parent = ContentContainer

local PollenCorner = Instance.new("UICorner")
PollenCorner.CornerRadius = UDim.new(0, 8)
PollenCorner.Parent = PollenLabel

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 150, 0, 40)
CloseButton.Position = UDim2.new(0.5, -75, 0, 245)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseButton.Text = "❌ Tắt Black Screen"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 102
CloseButton.Parent = ContentContainer

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

-- Hover effect cho close button
CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)

CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 60, 60)}):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    BlackScreen.Visible = false
end)

-- Toggle Button (nhỏ ở góc để bật lại black screen)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 120, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -15)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.Text = "🖥️ Black Screen"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 12
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.ZIndex = 10
ToggleButton.Parent = HoneyDisplayGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    BlackScreen.Visible = not BlackScreen.Visible
end)

-- Function to format numbers with commas (KHÔNG viết tắt)
local function formatNumberFull(num)
    local formatted = tostring(math.floor(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Function to format time (seconds to HH:MM:SS)
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

-- Function to calculate honey per second (using rolling average over 5 seconds)
local function calculateHoneyPerSecond(currentHoney)
    local currentTime = tick()
    
    -- Add current data point
    table.insert(honeyHistory, {time = currentTime, honey = currentHoney})
    
    -- Keep only last 5 seconds of data for smooth average
    while #honeyHistory > 0 and (currentTime - honeyHistory[1].time) > 5 do
        table.remove(honeyHistory, 1)
    end
    
    -- Calculate average rate
    if #honeyHistory >= 2 then
        local firstEntry = honeyHistory[1]
        local lastEntry = honeyHistory[#honeyHistory]
        local timeDiff = lastEntry.time - firstEntry.time
        local honeyDiff = lastEntry.honey - firstEntry.honey
        
        if timeDiff > 0 and honeyDiff >= 0 then
            honeyPerSecond = honeyDiff / timeDiff
        end
    end
    
    return honeyPerSecond
end

-- Update loop
local function updateDisplay()
    local success, err = pcall(function()
        -- Update server time
        local elapsedTime = tick() - serverJoinTime
        ServerTimeLabel.Text = "⏱️ Server Time: " .. formatTime(elapsedTime)
        
        -- Get honey and pollen from CoreStats
        local coreStats = LocalPlayer:FindFirstChild("CoreStats")
        if coreStats then
            -- Get Honey
            local honey = coreStats:FindFirstChild("Honey")
            if honey then
                -- Hiển thị đầy đủ số với dấu phẩy
                HoneyTotalLabel.Text = "🍯 Honey: " .. formatNumberFull(honey.Value)
                
                -- Calculate and display honey per second
                local hps = calculateHoneyPerSecond(honey.Value)
                HoneyPerSecLabel.Text = "⚡ Honey/s: " .. formatNumberFull(hps)
                
                -- Color based on rate
                if hps >= 1e6 then
                    HoneyPerSecLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold for high rates
                elseif hps >= 1e3 then
                    HoneyPerSecLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green for good rates
                else
                    HoneyPerSecLabel.TextColor3 = Color3.fromRGB(200, 200, 200) -- Gray for low rates
                end
            end
            
            -- Get Pollen
            local pollen = coreStats:FindFirstChild("Pollen")
            local capacity = coreStats:FindFirstChild("Capacity")
            if pollen and capacity then
                local percentage = math.floor((pollen.Value / capacity.Value) * 100)
                PollenLabel.Text = "🌸 Pollen: " .. formatNumberFull(pollen.Value) .. " / " .. formatNumberFull(capacity.Value) .. " (" .. percentage .. "%)"
                
                -- Change color based on capacity
                if percentage >= 90 then
                    PollenLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red when almost full
                elseif percentage >= 70 then
                    PollenLabel.TextColor3 = Color3.fromRGB(255, 200, 100) -- Orange
                else
                    PollenLabel.TextColor3 = Color3.fromRGB(255, 255, 100) -- Yellow
                end
            end
        end
    end)
end

-- Run update loop
RunService.Heartbeat:Connect(function()
    updateDisplay()
end)

print("Honey Display Black Screen Loaded! Auto Black Screen: ON")
