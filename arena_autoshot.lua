-- Arena (Zombie Survival) Auto-Shot / Kill Aura Script
-- Game: Arena by Nectarforge Studios
-- Features: Kill Aura, Auto Buy Weapon, Auto Equip, Anti-AFK, Auto Collect Shards, Fixed Spawn TP, Auto Play Again

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

getgenv().ArenaAutoShotConfig = getgenv().ArenaAutoShotConfig or {
    Enabled = true,
    KillDistance = 500,
    AttackDelay = 0.1,
    AutoBuyWeapon = true,
    MaxWeaponPurchases = 1,
    AutoEquip = true,
    AntiAFK = true,
    AutoCollect = true,
    AutoPlayAgain = true,
    ScriptPath = "D:/robloxluau/alime.lua/arena_autoshot.lua",
    SettingsFile = "ArenaAutoShotSettings.json",

    Lobby = {
        Enabled = true,
        ShipName = "Ship1",
        PartySize = 1,
        Difficulty = "Normal",
        Map = "Default",
        TweenSpeed = 45
    },

    FixedSpawn = {
        Enabled = true,
        Position = Vector3.new(-265.59295654297, 478.25930786133, -335.0315246582)
    }
}

local Config = getgenv().ArenaAutoShotConfig
Config.SettingsFile = Config.SettingsFile or "ArenaAutoShotSettings.json"
Config.ScriptPath = Config.ScriptPath or "D:/robloxluau/alime.lua/arena_autoshot.lua"
Config.Lobby = Config.Lobby or {
    Enabled = true,
    ShipName = "Ship1",
    PartySize = 1,
    Difficulty = "Normal",
    Map = "Default",
    TweenSpeed = 45
}
Config.FixedSpawn = Config.FixedSpawn or {
    Enabled = true,
    Position = Vector3.new(-265.59295654297, 478.25930786133, -335.0315246582)
}
getgenv().ArenaAutoShotState = getgenv().ArenaAutoShotState or {
    LobbyStarted = false,
    WeaponPurchases = 0
}
local State = getgenv().ArenaAutoShotState
State.WeaponPurchases = State.WeaponPurchases or 0

local function can_use_files()
    return type(isfile) == "function"
        and type(readfile) == "function"
        and type(writefile) == "function"
end

local function apply_saved_settings(settings)
    if type(settings) ~= "table" then
        return
    end

    local scalar_keys = {
        "Enabled",
        "KillDistance",
        "AttackDelay",
        "AutoBuyWeapon",
        "MaxWeaponPurchases",
        "AutoEquip",
        "AntiAFK",
        "AutoCollect",
        "AutoPlayAgain"
    }

    for i = 1, #scalar_keys do
        local key = scalar_keys[i]
        if settings[key] ~= nil then
            Config[key] = settings[key]
        end
    end

    if type(settings.Lobby) == "table" then
        Config.Lobby = Config.Lobby or {}
        for key, value in pairs(settings.Lobby) do
            Config.Lobby[key] = value
        end
    end
end

local function load_settings()
    if not can_use_files() or not isfile(Config.SettingsFile) then
        return
    end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(Config.SettingsFile))
    end)

    if ok then
        apply_saved_settings(decoded)
    else
        warn("Arena Settings: failed to load settings file")
    end
end

local function save_settings()
    if not can_use_files() then
        return false
    end

    local settings = {
        Enabled = Config.Enabled,
        KillDistance = Config.KillDistance,
        AttackDelay = Config.AttackDelay,
        AutoBuyWeapon = Config.AutoBuyWeapon,
        MaxWeaponPurchases = Config.MaxWeaponPurchases,
        AutoEquip = Config.AutoEquip,
        AntiAFK = Config.AntiAFK,
        AutoCollect = Config.AutoCollect,
        AutoPlayAgain = Config.AutoPlayAgain,
        Lobby = {
            Enabled = Config.Lobby.Enabled,
            ShipName = Config.Lobby.ShipName,
            PartySize = Config.Lobby.PartySize,
            Difficulty = Config.Lobby.Difficulty,
            Map = Config.Lobby.Map,
            TweenSpeed = Config.Lobby.TweenSpeed
        }
    }

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(settings)
    end)

    if ok then
        writefile(Config.SettingsFile, encoded)
        return true
    end

    return false
end

load_settings()
Config.MaxWeaponPurchases = Config.MaxWeaponPurchases or 1

local function queue_self_after_teleport()
    local source = string.format([[
        task.wait(3)
        pcall(function()
            loadstring(readfile(%q))()
        end)
    ]], Config.ScriptPath)

    if syn and syn.queue_on_teleport then
        syn.queue_on_teleport(source)
    elseif queue_on_teleport then
        queue_on_teleport(source)
    end
end

local function get_root_part()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart", 10)
end

local function is_lobby()
    return Config.Lobby.Enabled
        and ReplicatedStorage:FindFirstChild("QueueRemotes") ~= nil
        and workspace:FindFirstChild("Queues") ~= nil
end

local function run_lobby()
    if State.LobbyStarted then
        print("Arena Lobby: already started, waiting for teleport")
        return
    end

    local queue_remotes = ReplicatedStorage:WaitForChild("QueueRemotes", 10)
    local queues = workspace:WaitForChild("Queues", 10)
    if not queue_remotes or not queues then
        warn("Arena Lobby: QueueRemotes or Queues not found")
        return
    end

    local create_party = queue_remotes:WaitForChild("CreateParty", 10)
    if not create_party then
        warn("Arena Lobby: CreateParty not found")
        return
    end

    queue_self_after_teleport()
    State.LobbyStarted = true

    local hrp = get_root_part()
    local ship = queues:FindFirstChild(Config.Lobby.ShipName)
    local touch_part = ship and ship:FindFirstChild("TouchPart")
    if not hrp or not touch_part then
        warn("Arena Lobby: failed to find ship " .. tostring(Config.Lobby.ShipName))
        return
    end

    local distance = (hrp.Position - touch_part.Position).Magnitude
    local duration = distance / Config.Lobby.TweenSpeed
    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = touch_part.CFrame
    })

    print("Arena Lobby: moving to " .. Config.Lobby.ShipName)
    tween:Play()
    tween.Completed:Wait()
    tween:Destroy()

    if firetouchinterest then
        firetouchinterest(hrp, touch_part, 0)
        task.wait(0.1)
        firetouchinterest(hrp, touch_part, 1)
    end

    task.wait(1.5)
    print("Arena Lobby: creating party")
    create_party:FireServer(Config.Lobby.PartySize, Config.Lobby.Difficulty, Config.Lobby.Map)
end

if is_lobby() then
    run_lobby()
    return
end

-- REMOTES
local GunRemotes = ReplicatedStorage:WaitForChild("GunRemotes")
local GunFire = GunRemotes:WaitForChild("GunFire")
local GunHit = GunRemotes:WaitForChild("GunHit")

local UpgradeRemotes = ReplicatedStorage:WaitForChild("UpgradeRemotes")
local PurchaseWeaponUpgrade = UpgradeRemotes:WaitForChild("PurchaseWeaponUpgrade")
local GetUpgrades = UpgradeRemotes:WaitForChild("GetUpgrades")

local DataRemotes = ReplicatedStorage:WaitForChild("DataRemotes")
local GetMinerals = DataRemotes:WaitForChild("GetMinerals")

local EventRemotes = ReplicatedStorage:WaitForChild("EventRemotes")
local GalacticShardCollect = EventRemotes:WaitForChild("GalacticShardCollect")
local GalacticShardDrop = EventRemotes:WaitForChild("GalacticShardDrop")

local function create_weapon_purchase_ui()
    local player_gui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not player_gui then
        return
    end

    local old_gui = player_gui:FindFirstChild("ArenaAutoShotUI")
    if old_gui then
        old_gui:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ArenaAutoShotUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player_gui

    if syn and syn.protect_gui then
        pcall(syn.protect_gui, gui)
    end

    local frame = Instance.new("Frame")
    frame.Name = "WeaponPurchasePanel"
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -16, 0, 96)
    frame.Size = UDim2.new(0, 230, 0, 118)
    frame.BackgroundColor3 = Color3.fromRGB(24, 25, 28)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 12, 0, 8)
    title.Size = UDim2.new(1, -24, 0, 22)
    title.Font = Enum.Font.GothamBold
    title.Text = "Auto Buy Gun"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local function make_button(name, text, x)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Position = UDim2.new(0, x, 0, 42)
        button.Size = UDim2.new(0, 34, 0, 30)
        button.BackgroundColor3 = Color3.fromRGB(48, 50, 56)
        button.BorderSizePixel = 0
        button.Font = Enum.Font.GothamBold
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 18
        button.Parent = frame

        local button_corner = Instance.new("UICorner")
        button_corner.CornerRadius = UDim.new(0, 6)
        button_corner.Parent = button

        return button
    end

    local minus = make_button("Minus", "-", 12)
    local plus = make_button("Plus", "+", 184)

    local input = Instance.new("TextBox")
    input.Name = "MaxPurchases"
    input.Position = UDim2.new(0, 54, 0, 42)
    input.Size = UDim2.new(0, 122, 0, 30)
    input.BackgroundColor3 = Color3.fromRGB(34, 36, 42)
    input.BorderSizePixel = 0
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.GothamBold
    input.PlaceholderText = "0 = unlimited"
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 14
    input.Text = tostring(Config.MaxWeaponPurchases)
    input.Parent = frame

    local input_corner = Instance.new("UICorner")
    input_corner.CornerRadius = UDim.new(0, 6)
    input_corner.Parent = input

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.BackgroundTransparency = 1
    status.Position = UDim2.new(0, 12, 0, 82)
    status.Size = UDim2.new(1, -86, 0, 22)
    status.Font = Enum.Font.Gotham
    status.TextColor3 = Color3.fromRGB(210, 214, 222)
    status.TextSize = 13
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    local reset = Instance.new("TextButton")
    reset.Name = "Reset"
    reset.Position = UDim2.new(1, -70, 0, 80)
    reset.Size = UDim2.new(0, 58, 0, 26)
    reset.BackgroundColor3 = Color3.fromRGB(65, 45, 45)
    reset.BorderSizePixel = 0
    reset.Font = Enum.Font.GothamBold
    reset.Text = "Reset"
    reset.TextColor3 = Color3.fromRGB(255, 235, 235)
    reset.TextSize = 12
    reset.Parent = frame

    local reset_corner = Instance.new("UICorner")
    reset_corner.CornerRadius = UDim.new(0, 6)
    reset_corner.Parent = reset

    local function set_limit(value)
        value = math.max(0, math.floor(tonumber(value) or Config.MaxWeaponPurchases or 1))
        Config.MaxWeaponPurchases = value
        input.Text = tostring(value)
        status.Text = string.format("Bought: %d / %s", State.WeaponPurchases, value == 0 and "inf" or tostring(value))
        save_settings()
    end

    minus.MouseButton1Click:Connect(function()
        set_limit((tonumber(input.Text) or Config.MaxWeaponPurchases or 1) - 1)
    end)

    plus.MouseButton1Click:Connect(function()
        set_limit((tonumber(input.Text) or Config.MaxWeaponPurchases or 1) + 1)
    end)

    input.FocusLost:Connect(function()
        set_limit(input.Text)
    end)

    reset.MouseButton1Click:Connect(function()
        State.WeaponPurchases = 0
        set_limit(Config.MaxWeaponPurchases)
    end)

    task.spawn(function()
        while gui.Parent do
            status.Text = string.format(
                "Bought: %d / %s",
                State.WeaponPurchases,
                Config.MaxWeaponPurchases == 0 and "inf" or tostring(Config.MaxWeaponPurchases)
            )
            task.wait(0.5)
        end
    end)

    set_limit(Config.MaxWeaponPurchases)
end

create_weapon_purchase_ui()

-- 0. ANTI-AFK
if Config.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- 0.1 AUTO COLLECT (Listener)
if Config.AutoCollect then
    GalacticShardDrop.OnClientEvent:Connect(function(zId, amount, pos)
        task.wait(0.5)
        for i = 1, amount do
            GalacticShardCollect:FireServer(zId)
        end
    end)
end

-- 0.2 FIXED SPAWN TP
task.spawn(function()
    while task.wait(1) do
        if Config.FixedSpawn.Enabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                if (hrp.Position - Config.FixedSpawn.Position).Magnitude > 5 then
                    hrp.CFrame = CFrame.new(Config.FixedSpawn.Position)
                end
            end
        end
    end
end)

-- 0.3 AUTO PLAY AGAIN
task.spawn(function()
    while task.wait(3) do
        if Config.AutoPlayAgain then
            local gameOverGui = LocalPlayer.PlayerGui:FindFirstChild("GameOver")
            if gameOverGui and gameOverGui.Enabled then
                local playAgainBtn = gameOverGui:FindFirstChild("PlayAgain", true)
                if playAgainBtn then
                    print("Game Over! Clicking Play Again...")
                    for _, signal in pairs({"Activated", "MouseButton1Click"}) do
                        for _, connection in pairs(getconnections(playAgainBtn[signal])) do
                            connection:Fire()
                        end
                    end
                end
            end
        end
    end
end)

-- Helper: Get Equipped Gun Name
local function GetEquippedGunName()
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildWhichIsA("Tool")
        if tool then
            return tool.Name
        end
    end
    return nil
end

-- Helper: Extract ID from "Zombie_ID"
local function GetZombieId(name)
    local id = name:match("Zombie_(%d+)")
    return id and tonumber(id) or nil
end

-- 1. KILL AURA LOOP
task.spawn(function()
    while task.wait(Config.AttackDelay) do
        if not Config.Enabled then continue end
        
        local gunName = GetEquippedGunName()
        if not gunName then continue end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local myPos = char.HumanoidRootPart.Position
        
        local zombiesLocal = workspace:FindFirstChild("Zombies_Local")
        if not zombiesLocal then continue end
        
        for _, zombie in pairs(zombiesLocal:GetChildren()) do
            if zombie:IsA("Model") and zombie.PrimaryPart then
                local dist = (myPos - zombie.PrimaryPart.Position).Magnitude
                if dist <= Config.KillDistance then
                    local zId = GetZombieId(zombie.Name)
                    if zId then
                        GunHit:FireServer(gunName, zId, zombie.PrimaryPart.Position)
                        
                        if Config.AutoCollect then
                            task.spawn(function()
                                task.wait(1)
                                GalacticShardCollect:FireServer(zId)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- 2. AUTO BUY WEAPON LOOP
task.spawn(function()
    while task.wait(5) do
        if not Config.AutoBuyWeapon then continue end
        if Config.MaxWeaponPurchases > 0 and State.WeaponPurchases >= Config.MaxWeaponPurchases then continue end
        
        pcall(function()
            local upgrades = GetUpgrades:InvokeServer()
            local minerals = GetMinerals:InvokeServer()
            
            if upgrades and not upgrades.IsMaxWeapon and minerals >= upgrades.NextWeapon.Price then
                PurchaseWeaponUpgrade:FireServer()
                State.WeaponPurchases += 1
            end
        end)
    end
end)

-- 3. AUTO EQUIP LOOP
task.spawn(function()
    while task.wait(1) do
        if not Config.AutoEquip then continue end
        local char = LocalPlayer.Character
        if not char then continue end
        
        if not char:FindFirstChildWhichIsA("Tool") then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                local tool = backpack:FindFirstChildWhichIsA("Tool")
                if tool then
                    tool.Parent = char
                end
            end
        end
    end
end)

print("Arena Script: Full Farm + Auto Play Again Loaded!")
