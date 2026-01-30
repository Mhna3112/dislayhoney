-- Honey Display UI for Bee Swarm Simulator
-- This script creates a UI that displays your current honey amount while farming

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Variables for honey per second calculation
local honeyPerSecond = 0
local honeyHistory = {}

-- Black Screen variables
local blackScreenEnabled = false

-- Create the UI
local HoneyDisplayGui = Instance.new("ScreenGui")
HoneyDisplayGui.Name = "HoneyDisplayGui"
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
BlackScreen.Visible = false
BlackScreen.ZIndex = 100
BlackScreen.Parent = HoneyDisplayGui

-- Black Screen Honey Per Second Display
local BlackScreenHoneyLabel = Instance.new("TextLabel")
BlackScreenHoneyLabel.Name = "BlackScreenHoneyLabel"
BlackScreenHoneyLabel.Size = UDim2.new(1, 0, 0, 60)
BlackScreenHoneyLabel.Position = UDim2.new(0, 0, 0.35, -30)
BlackScreenHoneyLabel.BackgroundTransparency = 1
BlackScreenHoneyLabel.Text = "Honey/s: 0"
BlackScreenHoneyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
BlackScreenHoneyLabel.TextSize = 48
BlackScreenHoneyLabel.Font = Enum.Font.GothamBold
BlackScreenHoneyLabel.ZIndex = 101
BlackScreenHoneyLabel.Parent = BlackScreen

-- Black Screen Pollen Display
local BlackScreenPollenLabel = Instance.new("TextLabel")
BlackScreenPollenLabel.Name = "BlackScreenPollenLabel"
BlackScreenPollenLabel.Size = UDim2.new(1, 0, 0, 50)
BlackScreenPollenLabel.Position = UDim2.new(0, 0, 0.35, 40)
BlackScreenPollenLabel.BackgroundTransparency = 1
BlackScreenPollenLabel.Text = "Pollen: 0/0 (0%)"
BlackScreenPollenLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
BlackScreenPollenLabel.TextSize = 36
BlackScreenPollenLabel.Font = Enum.Font.GothamSemibold
BlackScreenPollenLabel.ZIndex = 101
BlackScreenPollenLabel.Parent = BlackScreen

-- Black Screen Honey Total Display
local BlackScreenHoneyTotalLabel = Instance.new("TextLabel")
BlackScreenHoneyTotalLabel.Name = "BlackScreenHoneyTotalLabel"
BlackScreenHoneyTotalLabel.Size = UDim2.new(1, 0, 0, 40)
BlackScreenHoneyTotalLabel.Position = UDim2.new(0, 0, 0.35, 100)
BlackScreenHoneyTotalLabel.BackgroundTransparency = 1
BlackScreenHoneyTotalLabel.Text = "Honey: 0"
BlackScreenHoneyTotalLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
BlackScreenHoneyTotalLabel.TextSize = 28
BlackScreenHoneyTotalLabel.Font = Enum.Font.GothamSemibold
BlackScreenHoneyTotalLabel.ZIndex = 101
BlackScreenHoneyTotalLabel.Parent = BlackScreen

-- Black Screen Strawberry Display
local BlackScreenStrawberryLabel = Instance.new("TextLabel")
BlackScreenStrawberryLabel.Name = "BlackScreenStrawberryLabel"
BlackScreenStrawberryLabel.Size = UDim2.new(1, 0, 0, 40)
BlackScreenStrawberryLabel.Position = UDim2.new(0, 0, 0.35, 150)
BlackScreenStrawberryLabel.BackgroundTransparency = 1
BlackScreenStrawberryLabel.Text = "🍓 Strawberry: Loading..."
BlackScreenStrawberryLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
BlackScreenStrawberryLabel.TextSize = 28
BlackScreenStrawberryLabel.Font = Enum.Font.GothamSemibold
BlackScreenStrawberryLabel.ZIndex = 101
BlackScreenStrawberryLabel.Parent = BlackScreen

-- Black Screen Snowflake Display
local BlackScreenSnowflakeLabel = Instance.new("TextLabel")
BlackScreenSnowflakeLabel.Name = "BlackScreenSnowflakeLabel"
BlackScreenSnowflakeLabel.Size = UDim2.new(1, 0, 0, 40)
BlackScreenSnowflakeLabel.Position = UDim2.new(0, 0, 0.35, 190)
BlackScreenSnowflakeLabel.BackgroundTransparency = 1
BlackScreenSnowflakeLabel.Text = "❄️ Snowflake: Loading..."
BlackScreenSnowflakeLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
BlackScreenSnowflakeLabel.TextSize = 28
BlackScreenSnowflakeLabel.Font = Enum.Font.GothamSemibold
BlackScreenSnowflakeLabel.ZIndex = 101
BlackScreenSnowflakeLabel.Parent = BlackScreen

-- Black Screen Coconut Display
local BlackScreenCoconutLabel = Instance.new("TextLabel")
BlackScreenCoconutLabel.Name = "BlackScreenCoconutLabel"
BlackScreenCoconutLabel.Size = UDim2.new(1, 0, 0, 40)
BlackScreenCoconutLabel.Position = UDim2.new(0, 0, 0.35, 230)
BlackScreenCoconutLabel.BackgroundTransparency = 1
BlackScreenCoconutLabel.Text = "🥥 Coconut: Loading..."
BlackScreenCoconutLabel.TextColor3 = Color3.fromRGB(139, 90, 43)
BlackScreenCoconutLabel.TextSize = 28
BlackScreenCoconutLabel.Font = Enum.Font.GothamSemibold
BlackScreenCoconutLabel.ZIndex = 101
BlackScreenCoconutLabel.Parent = BlackScreen

-- Black Screen Pineapple Display
local BlackScreenPineappleLabel = Instance.new("TextLabel")
BlackScreenPineappleLabel.Name = "BlackScreenPineappleLabel"
BlackScreenPineappleLabel.Size = UDim2.new(1, 0, 0, 40)
BlackScreenPineappleLabel.Position = UDim2.new(0, 0, 0.35, 270)
BlackScreenPineappleLabel.BackgroundTransparency = 1
BlackScreenPineappleLabel.Text = "🍍 Pineapple: Loading..."
BlackScreenPineappleLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
BlackScreenPineappleLabel.TextSize = 28
BlackScreenPineappleLabel.Font = Enum.Font.GothamSemibold
BlackScreenPineappleLabel.ZIndex = 101
BlackScreenPineappleLabel.Parent = BlackScreen

-- Black Screen Blueberry Display
local BlackScreenBlueberryLabel = Instance.new("TextLabel")
BlackScreenBlueberryLabel.Name = "BlackScreenBlueberryLabel"
BlackScreenBlueberryLabel.Size = UDim2.new(1, 0, 0, 40)
BlackScreenBlueberryLabel.Position = UDim2.new(0, 0, 0.35, 310)
BlackScreenBlueberryLabel.BackgroundTransparency = 1
BlackScreenBlueberryLabel.Text = "🫐 Blueberry: Loading..."
BlackScreenBlueberryLabel.TextColor3 = Color3.fromRGB(100, 100, 255)
BlackScreenBlueberryLabel.TextSize = 28
BlackScreenBlueberryLabel.Font = Enum.Font.GothamSemibold
BlackScreenBlueberryLabel.ZIndex = 101
BlackScreenBlueberryLabel.Parent = BlackScreen

-- Black Screen Sunflower Seed Display
local BlackScreenSunflowerLabel = Instance.new("TextLabel")
BlackScreenSunflowerLabel.Name = "BlackScreenSunflowerLabel"
BlackScreenSunflowerLabel.Size = UDim2.new(1, 0, 0, 40)
BlackScreenSunflowerLabel.Position = UDim2.new(0, 0, 0.35, 350)
BlackScreenSunflowerLabel.BackgroundTransparency = 1
BlackScreenSunflowerLabel.Text = "🌻 Sunflower Seed: Loading..."
BlackScreenSunflowerLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
BlackScreenSunflowerLabel.TextSize = 28
BlackScreenSunflowerLabel.Font = Enum.Font.GothamSemibold
BlackScreenSunflowerLabel.ZIndex = 101
BlackScreenSunflowerLabel.Parent = BlackScreen

-- Thông báo hướng dẫn mở menu
local BlackScreenNoticeLabel = Instance.new("TextLabel")
BlackScreenNoticeLabel.Name = "BlackScreenNoticeLabel"
BlackScreenNoticeLabel.Size = UDim2.new(1, 0, 0, 30)
BlackScreenNoticeLabel.Position = UDim2.new(0, 0, 0.35, 390)
BlackScreenNoticeLabel.BackgroundTransparency = 1
BlackScreenNoticeLabel.Text = "⚠️ Mở menu Eggs/Items 1 lần để load dữ liệu ⚠️"
BlackScreenNoticeLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
BlackScreenNoticeLabel.TextSize = 16
BlackScreenNoticeLabel.Font = Enum.Font.GothamSemibold
BlackScreenNoticeLabel.ZIndex = 101
BlackScreenNoticeLabel.Parent = BlackScreen

-- Biến để theo dõi đã load data chưa
local itemsDataLoaded = false

-- Black Screen Close Button (to turn off black screen)
local BlackScreenCloseButton = Instance.new("TextButton")
BlackScreenCloseButton.Name = "BlackScreenCloseButton"
BlackScreenCloseButton.Size = UDim2.new(0, 200, 0, 50)
BlackScreenCloseButton.Position = UDim2.new(0.5, -100, 0.35, 430)
BlackScreenCloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
BlackScreenCloseButton.Text = "Black Screen"
BlackScreenCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BlackScreenCloseButton.TextSize = 18
BlackScreenCloseButton.Font = Enum.Font.GothamBold
BlackScreenCloseButton.ZIndex = 101
BlackScreenCloseButton.Parent = BlackScreen

local BlackScreenCloseCorner = Instance.new("UICorner")
BlackScreenCloseCorner.CornerRadius = UDim.new(0, 10)
BlackScreenCloseCorner.Parent = BlackScreenCloseButton

-- Main Frame (increased height for new display)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 200)
MainFrame.Position = UDim2.new(0, 10, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 10
MainFrame.Parent = HoneyDisplayGui

-- Corner rounding
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Fix bottom corners of title bar
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Honey Display"
TitleText.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

-- Honey Icon and Amount
local HoneyFrame = Instance.new("Frame")
HoneyFrame.Name = "HoneyFrame"
HoneyFrame.Size = UDim2.new(1, -20, 0, 35)
HoneyFrame.Position = UDim2.new(0, 10, 0, 40)
HoneyFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
HoneyFrame.BorderSizePixel = 0
HoneyFrame.Parent = MainFrame

local HoneyCorner = Instance.new("UICorner")
HoneyCorner.CornerRadius = UDim.new(0, 8)
HoneyCorner.Parent = HoneyFrame

local HoneyLabel = Instance.new("TextLabel")
HoneyLabel.Name = "HoneyLabel"
HoneyLabel.Size = UDim2.new(1, -10, 1, 0)
HoneyLabel.Position = UDim2.new(0, 5, 0, 0)
HoneyLabel.BackgroundTransparency = 1
HoneyLabel.Text = "Honey: Loading..."
HoneyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
HoneyLabel.TextSize = 18
HoneyLabel.Font = Enum.Font.GothamBold
HoneyLabel.TextXAlignment = Enum.TextXAlignment.Left
HoneyLabel.Parent = HoneyFrame

-- Honey Per Second Display
local HoneyPerSecFrame = Instance.new("Frame")
HoneyPerSecFrame.Name = "HoneyPerSecFrame"
HoneyPerSecFrame.Size = UDim2.new(1, -20, 0, 35)
HoneyPerSecFrame.Position = UDim2.new(0, 10, 0, 80)
HoneyPerSecFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
HoneyPerSecFrame.BorderSizePixel = 0
HoneyPerSecFrame.Parent = MainFrame

local HoneyPerSecCorner = Instance.new("UICorner")
HoneyPerSecCorner.CornerRadius = UDim.new(0, 8)
HoneyPerSecCorner.Parent = HoneyPerSecFrame

local HoneyPerSecLabel = Instance.new("TextLabel")
HoneyPerSecLabel.Name = "HoneyPerSecLabel"
HoneyPerSecLabel.Size = UDim2.new(1, -10, 1, 0)
HoneyPerSecLabel.Position = UDim2.new(0, 5, 0, 0)
HoneyPerSecLabel.BackgroundTransparency = 1
HoneyPerSecLabel.Text = "Honey/s: 0"
HoneyPerSecLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
HoneyPerSecLabel.TextSize = 16
HoneyPerSecLabel.Font = Enum.Font.GothamSemibold
HoneyPerSecLabel.TextXAlignment = Enum.TextXAlignment.Left
HoneyPerSecLabel.Parent = HoneyPerSecFrame

-- Pollen Display
local PollenFrame = Instance.new("Frame")
PollenFrame.Name = "PollenFrame"
PollenFrame.Size = UDim2.new(1, -20, 0, 35)
PollenFrame.Position = UDim2.new(0, 10, 0, 120)
PollenFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PollenFrame.BorderSizePixel = 0
PollenFrame.Parent = MainFrame

local PollenCorner = Instance.new("UICorner")
PollenCorner.CornerRadius = UDim.new(0, 8)
PollenCorner.Parent = PollenFrame

local PollenLabel = Instance.new("TextLabel")
PollenLabel.Name = "PollenLabel"
PollenLabel.Size = UDim2.new(1, -10, 1, 0)
PollenLabel.Position = UDim2.new(0, 5, 0, 0)
PollenLabel.BackgroundTransparency = 1
PollenLabel.Text = "Pollen: Loading..."
PollenLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
PollenLabel.TextSize = 16
PollenLabel.Font = Enum.Font.GothamSemibold
PollenLabel.TextXAlignment = Enum.TextXAlignment.Left
PollenLabel.Parent = PollenFrame

-- Black Screen Toggle Button
local BlackScreenFrame = Instance.new("Frame")
BlackScreenFrame.Name = "BlackScreenFrame"
BlackScreenFrame.Size = UDim2.new(1, -20, 0, 35)
BlackScreenFrame.Position = UDim2.new(0, 10, 0, 160)
BlackScreenFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
BlackScreenFrame.BorderSizePixel = 0
BlackScreenFrame.ZIndex = 10
BlackScreenFrame.Parent = MainFrame

local BlackScreenFrameCorner = Instance.new("UICorner")
BlackScreenFrameCorner.CornerRadius = UDim.new(0, 8)
BlackScreenFrameCorner.Parent = BlackScreenFrame

local BlackScreenToggleButton = Instance.new("TextButton")
BlackScreenToggleButton.Name = "BlackScreenToggleButton"
BlackScreenToggleButton.Size = UDim2.new(1, 0, 1, 0)
BlackScreenToggleButton.BackgroundTransparency = 1
BlackScreenToggleButton.Text = "Black Screen: OFF"
BlackScreenToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
BlackScreenToggleButton.TextSize = 14
BlackScreenToggleButton.Font = Enum.Font.GothamSemibold
BlackScreenToggleButton.ZIndex = 10
BlackScreenToggleButton.Parent = BlackScreenFrame

BlackScreenToggleButton.MouseButton1Click:Connect(function()
    blackScreenEnabled = not blackScreenEnabled
    BlackScreen.Visible = blackScreenEnabled
    if blackScreenEnabled then
        BlackScreenToggleButton.Text = "Black Screen: ON"
        BlackScreenToggleButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        -- Hide other UI elements, only show black screen toggle
        HoneyFrame.Visible = false
        HoneyPerSecFrame.Visible = false
        PollenFrame.Visible = false
        TitleBar.Visible = false
        -- Resize main frame to only show toggle button
        MainFrame.Size = UDim2.new(0, 220, 0, 55)
        BlackScreenFrame.Position = UDim2.new(0, 10, 0, 10)
    else
        BlackScreenToggleButton.Text = "Black Screen: OFF"
        BlackScreenToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        -- Show all UI elements again
        HoneyFrame.Visible = true
        HoneyPerSecFrame.Visible = true
        PollenFrame.Visible = true
        TitleBar.Visible = true
        -- Restore main frame size
        MainFrame.Size = UDim2.new(0, 220, 0, 200)
        BlackScreenFrame.Position = UDim2.new(0, 10, 0, 160)
    end
end)

-- Function to turn off black screen (used by both buttons)
local function turnOffBlackScreen()
    blackScreenEnabled = false
    BlackScreen.Visible = false
    BlackScreenToggleButton.Text = "Black Screen: OFF"
    BlackScreenToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    -- Show all UI elements again
    HoneyFrame.Visible = true
    HoneyPerSecFrame.Visible = true
    PollenFrame.Visible = true
    TitleBar.Visible = true
    -- Restore main frame size
    MainFrame.Size = UDim2.new(0, 220, 0, 200)
    BlackScreenFrame.Position = UDim2.new(0, 10, 0, 160)
end

-- Connect black screen close button
BlackScreenCloseButton.MouseButton1Click:Connect(turnOffBlackScreen)

-- Auto enable black screen on execute
blackScreenEnabled = true
BlackScreen.Visible = true
BlackScreenToggleButton.Text = "Black Screen: ON"
BlackScreenToggleButton.TextColor3 = Color3.fromRGB(100, 255, 100)
HoneyFrame.Visible = false
HoneyPerSecFrame.Visible = false
PollenFrame.Visible = false
TitleBar.Visible = false
MainFrame.Size = UDim2.new(0, 220, 0, 55)
BlackScreenFrame.Position = UDim2.new(0, 10, 0, 10)

-- Function to format numbers
local function formatNumber(num)
    if num >= 1e15 then
        return string.format("%.2fQ", num / 1e15)
    elseif num >= 1e12 then
        return string.format("%.2fT", num / 1e12)
    elseif num >= 1e9 then
        return string.format("%.2fB", num / 1e9)
    elseif num >= 1e6 then
        return string.format("%.2fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.2fK", num / 1e3)
    else
        return tostring(math.floor(num))
    end
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

-- Function to get item count by name (Bee Swarm Simulator specific)
local function getItemCount(itemName)
    local count = "0"
    
    -- Tìm trong EggRows - cấu trúc chính xác của Bee Swarm Simulator
    pcall(function()
        local screenGui = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
        if not screenGui then print("No ScreenGui") return end
        
        local menus = screenGui:FindFirstChild("Menus")
        if not menus then print("No Menus") return end
        
        local children = menus:FindFirstChild("Children")
        if not children then print("No Children") return end
        
        local eggs = children:FindFirstChild("Eggs")
        if not eggs then print("No Eggs") return end
        
        local content = eggs:FindFirstChild("Content")
        if not content then print("No Content") return end
        
        local eggRows = content:FindFirstChild("EggRows")
        if not eggRows then print("No EggRows") return end
        
        -- Duyệt qua tất cả EggRow
        for _, eggRow in pairs(eggRows:GetChildren()) do
            -- Tìm TypeName trong tất cả descendants
            for _, desc in pairs(eggRow:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Name == "TypeName" and desc.Text == itemName then
                    -- Tìm Count - có thể ở cùng level hoặc khác level
                    -- Thử tìm trong parent của TypeName
                    local parent = desc.Parent
                    while parent and parent ~= eggRow.Parent do
                        local countLabel = parent:FindFirstChild("Count")
                        if countLabel and countLabel:IsA("TextLabel") then
                            local text = countLabel.Text
                            local numMatch = text:match("x?([%d,]+)")
                            if numMatch then
                                count = numMatch:gsub(",", "")
                                return
                            end
                        end
                        parent = parent.Parent
                    end
                    
                    -- Thử tìm trong toàn bộ eggRow
                    for _, child in pairs(eggRow:GetDescendants()) do
                        if child:IsA("TextLabel") and child.Name == "Count" then
                            local text = child.Text
                            local numMatch = text:match("x?([%d,]+)")
                            if numMatch then
                                count = numMatch:gsub(",", "")
                                return
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return count
end

-- Biến để lưu cache items (sau khi mở menu 1 lần)
local itemsCache = {}
local itemsCacheLoaded = false

-- Function để load tất cả items vào cache
local function loadItemsCache()
    pcall(function()
        local screenGui = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
        if not screenGui then return end
        
        local menus = screenGui:FindFirstChild("Menus")
        if not menus then return end
        
        local children = menus:FindFirstChild("Children")
        if not children then return end
        
        local eggs = children:FindFirstChild("Eggs")
        if not eggs then return end
        
        local content = eggs:FindFirstChild("Content")
        if not content then return end
        
        local eggRows = content:FindFirstChild("EggRows")
        if not eggRows then return end
        
        for _, eggRow in pairs(eggRows:GetChildren()) do
            -- Tìm trong descendants
            local typeName = nil
            local countLabel = nil
            
            for _, desc in pairs(eggRow:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    if desc.Name == "TypeName" then
                        typeName = desc
                    elseif desc.Name == "Count" then
                        countLabel = desc
                    end
                end
            end
            
            if typeName and countLabel then
                local name = typeName.Text
                local text = countLabel.Text
                local numMatch = text:match("x?([%d,]+)")
                if numMatch and name and name ~= "" then
                    itemsCache[name] = numMatch:gsub(",", "")
                    itemsCacheLoaded = true
                end
            end
        end
    end)
end

-- Function để lấy item từ cache hoặc trực tiếp
local function getItemCountCached(itemName)
    -- Load cache mỗi lần để cập nhật số mới nhất
    loadItemsCache()
    
    -- Trả về từ cache nếu có
    if itemsCache[itemName] then
        return itemsCache[itemName]
    end
    
    -- Fallback: lấy trực tiếp
    return getItemCount(itemName)
end

-- Debug đã hoàn thành, tắt debug
local debugRan = true

-- Update loop
local function updateDisplay()
    local success, err = pcall(function()
        -- Get honey and pollen from CoreStats
        local coreStats = LocalPlayer:FindFirstChild("CoreStats")
        if coreStats then
            -- Get Honey
            local honey = coreStats:FindFirstChild("Honey")
            if honey then
                HoneyLabel.Text = "Honey: " .. formatNumber(honey.Value)
                
                -- Calculate and display honey per second
                local hps = calculateHoneyPerSecond(honey.Value)
                HoneyPerSecLabel.Text = "Honey/s: " .. formatNumber(hps)
                
                -- Update Black Screen displays
                BlackScreenHoneyLabel.Text = "Honey/s: " .. formatNumber(hps)
                BlackScreenHoneyTotalLabel.Text = "Honey: " .. formatNumber(honey.Value)
                
                -- Color based on rate
                if hps >= 1e6 then
                    HoneyPerSecLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold for high rates
                    BlackScreenHoneyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                elseif hps >= 1e3 then
                    HoneyPerSecLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green for good rates
                    BlackScreenHoneyLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                else
                    HoneyPerSecLabel.TextColor3 = Color3.fromRGB(200, 200, 200) -- Gray for low rates
                    BlackScreenHoneyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            
            -- Get Pollen
            local pollen = coreStats:FindFirstChild("Pollen")
            local capacity = coreStats:FindFirstChild("Capacity")
            if pollen and capacity then
                local percentage = math.floor((pollen.Value / capacity.Value) * 100)
                local pollenText = "Pollen: " .. formatNumber(pollen.Value) .. "/" .. formatNumber(capacity.Value) .. " (" .. percentage .. "%)"
                PollenLabel.Text = pollenText
                BlackScreenPollenLabel.Text = pollenText
                
                -- Change color based on capacity
                if percentage >= 90 then
                    PollenLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red when almost full
                    BlackScreenPollenLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                elseif percentage >= 70 then
                    PollenLabel.TextColor3 = Color3.fromRGB(255, 200, 100) -- Orange
                    BlackScreenPollenLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                else
                    PollenLabel.TextColor3 = Color3.fromRGB(255, 255, 100) -- Yellow
                    BlackScreenPollenLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                end
            end
        end
        
        -- Load cache từ menu Eggs nếu chưa có
        loadItemsCache()
        
        -- Update Strawberry count on Black Screen
        local strawberryCount = getItemCountCached("Strawberry")
        BlackScreenStrawberryLabel.Text = "🍓 Strawberry: " .. strawberryCount
        
        -- Update Snowflake count on Black Screen
        local snowflakeCount = getItemCountCached("Snowflake")
        BlackScreenSnowflakeLabel.Text = "❄️ Snowflake: " .. snowflakeCount
        
        -- Update Coconut count on Black Screen
        local coconutCount = getItemCountCached("Coconut")
        BlackScreenCoconutLabel.Text = "🥥 Coconut: " .. coconutCount
        
        -- Update Pineapple count on Black Screen
        local pineappleCount = getItemCountCached("Pineapple")
        BlackScreenPineappleLabel.Text = "🍍 Pineapple: " .. pineappleCount
        
        -- Update Blueberry count on Black Screen
        local blueberryCount = getItemCountCached("Blueberry")
        BlackScreenBlueberryLabel.Text = "🫐 Blueberry: " .. blueberryCount
        
        -- Update Sunflower Seed count on Black Screen
        local sunflowerCount = getItemCountCached("Sunflower Seed")
        BlackScreenSunflowerLabel.Text = "🌻 Sunflower Seed: " .. sunflowerCount
        
        -- Ẩn thông báo nếu đã load được dữ liệu (bất kỳ item nào khác "0")
        if not itemsDataLoaded then
            if strawberryCount ~= "0" or snowflakeCount ~= "0" or coconutCount ~= "0" or 
               pineappleCount ~= "0" or blueberryCount ~= "0" or sunflowerCount ~= "0" then
                itemsDataLoaded = true
                BlackScreenNoticeLabel.Visible = false
            end
        end
    end)
end

-- Run update loop
RunService.Heartbeat:Connect(function()
    updateDisplay()
end)

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 12
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    HoneyDisplayGui:Destroy()
end)

-- Minimize button
local minimized = false
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -50, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 14
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 5)
MinCorner.Parent = MinimizeButton

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 220, 0, 30)}):Play()
        HoneyFrame.Visible = false
        HoneyPerSecFrame.Visible = false
        PollenFrame.Visible = false
        BlackScreenFrame.Visible = false
        MinimizeButton.Text = "+"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 220, 0, 200)}):Play()
        task.wait(0.3)
        HoneyFrame.Visible = true
        HoneyPerSecFrame.Visible = true
        PollenFrame.Visible = true
        BlackScreenFrame.Visible = true
        MinimizeButton.Text = "-"
    end
end)

print("Honey Display UI Loaded Successfully!")