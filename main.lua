https://raw.githubusercontent.com/SpriteXz53/SPRXZII-HUB/refs/heads/main/walkonwater.lua

-- [[ SPRXZII ULTIMATE V10.1 - FIX MONSTER LIST (COUNT > 1) ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("SPRXZII - V10.1 FULL", "DarkTheme")
local lp = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

local Settings = {
    SelectedWeapon = "Melee",
    AutoFarm = false,
    AutoQuest = true, 
    AutoHakiT = false,
    FarmDistance = 8,
    FarmDirection = "Top",
    MeleeSkills = {Z = false, X = false, C = false, V = false, B = false, E = false},
    SwordSkills = {Z = false, X = false, C = false, V = false, B = false, E = false},
    FruitSkills = {Z = false, X = false, C = false, V = false, B = false, E = false},
}

local TargetName = ""
local CurrentTarget = nil

-- // ฟังก์ชันลบแรงเหวี่ยง // --
local function CleanVelocity()
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local v = lp.Character.HumanoidRootPart:FindFirstChild("XenoVelocity")
        if v then v:Destroy() end
    end
end

-- // ระบบถือของ // --
local function EquipWeapon()
    pcall(function()
        local char = lp.Character
        local backpack = lp.Backpack
        for _, v in pairs(backpack:GetChildren()) do
            if v:IsA("Tool") and (v.ToolTip == Settings.SelectedWeapon or v.Name:find(Settings.SelectedWeapon) or v.Name == Settings.SelectedWeapon) then
                char.Humanoid:EquipTool(v)
                break
            end
        end
    end)
end

local function PressT()
    if not Settings.AutoHakiT then return end
    pcall(function()
        if lp.Character and not lp.Character:FindFirstChild("HasBuso") then
            vim:SendKeyEvent(true, Enum.KeyCode.T, false, game)
            task.wait(0.05)
            vim:SendKeyEvent(false, Enum.KeyCode.T, false, game)
        end
    end)
end

-- // ระบบโจมตี // --
local function SecureAttack()
    if not Settings.AutoFarm or not CurrentTarget or CurrentTarget.Humanoid.Health <= 0 then return end
    pcall(function()
        local tool = lp.Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            game:GetService("ReplicatedStorage").Remotes.TrainingRemote:FireServer()
        end
    end)
end

local function QuestByTarget()
    if not Settings.AutoQuest or TargetName == "" then return end
    pcall(function()
        local qGui = lp.PlayerGui.MainGui:FindFirstChild("QuestGui")
        if qGui and not qGui.Visible then
            for _, v in pairs(game.Workspace.NPCs:GetChildren()) do
                if v:FindFirstChild("Quest") and v.Quest.Value == TargetName then
                    lp.Character.HumanoidRootPart.CFrame = v.PrimaryPart.CFrame * CFrame.new(0, 0, 2)
                    task.wait(0.4)
                    game:GetService("ReplicatedStorage").Remotes.Quest:FireServer(v.Name)
                    break
                end
            end
        end
    end)
end

-- // Main Loop // --
task.spawn(function()
    while true do
        task.wait()
        if Settings.AutoHakiT and tick() % 5 < 0.05 then PressT() end
        if Settings.AutoFarm then
            pcall(function()
                local char = lp.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local hrp = char.HumanoidRootPart
                
                if Settings.AutoQuest then QuestByTarget() end
                
                if TargetName ~= "" then
                    if not CurrentTarget or not CurrentTarget.Parent or CurrentTarget.Humanoid.Health <= 0 then
                        CurrentTarget = nil
                        for _, v in pairs(game.Workspace:GetDescendants()) do
                            if v.Name == TargetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                CurrentTarget = v 
                                break
                            end
                        end
                        if not CurrentTarget then 
                            CleanVelocity()
                            task.wait(1) 
                        end
                    end
                    
                    if CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart") then
                        local targetHrp = CurrentTarget.HumanoidRootPart
                        local bv = hrp:FindFirstChild("XenoVelocity") or Instance.new("BodyVelocity", hrp)
                        bv.Name = "XenoVelocity"
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Velocity = Vector3.new(0, 0, 0)
                        
                        local offset = (Settings.FarmDirection == "Top" and CFrame.new(0, Settings.FarmDistance, 0)) or (Settings.FarmDirection == "Bottom" and CFrame.new(0, -Settings.FarmDistance, 0)) or CFrame.new(0, 0, Settings.FarmDistance)
                        hrp.CFrame = CFrame.lookAt((targetHrp.CFrame * offset).Position, targetHrp.Position)
                        
                        SecureAttack()
                    end
                end
            end)
        else
            CleanVelocity()
        end
    end
end)

-- // Auto Skills // --
task.spawn(function()
    while true do
        task.wait(1.5)
        if Settings.AutoFarm and CurrentTarget and CurrentTarget.Humanoid.Health > 0 then
            local targetTable = (Settings.SelectedWeapon == "Melee" and Settings.MeleeSkills) or (Settings.SelectedWeapon == "Sword" and Settings.SwordSkills) or (Settings.SelectedWeapon == "Fruit" and Settings.FruitSkills)
            if targetTable then
                for key, enabled in pairs(targetTable) do
                    if enabled and Settings.AutoFarm and lp.Character:FindFirstChildOfClass("Tool") then
                        vim:SendKeyEvent(true, key, false, game)
                        task.wait(0.1)
                        vim:SendKeyEvent(false, key, false, game)
                    end
                end
            end
        end
    end
end)

-- // UI SECTION // --
local MainTab = Window:NewTab("Auto Farm")
local FarmSec = MainTab:NewSection("Farming")
FarmSec:NewToggle("START AUTO FARM", "เริ่มฟาร์ม", function(state) 
    Settings.AutoFarm = state
    if state then EquipWeapon() else CleanVelocity() end 
end)
FarmSec:NewToggle("Auto Quest", "รับเควส", function(state) Settings.AutoQuest = state end)

local SeaDrop = FarmSec:NewDropdown("Sea Events", "บอสทะเล", {}, function(v) TargetName = v CurrentTarget = nil end)
local BossDrop = FarmSec:NewDropdown("Bosses", "บอสเกาะ", {}, function(v) TargetName = v CurrentTarget = nil end)
local MobDrop = FarmSec:NewDropdown("Monsters", "มอนทั่วไป", {}, function(v) TargetName = v CurrentTarget = nil end)

FarmSec:NewButton("Refresh Lists", "อัปเดตรายชื่อ (Monsters > 1)", function()
    local s, b, m = {}, {}, {}
    local counts = {}
    local models = {}

    -- ขั้นตอน 1: นับจำนวน NPC ทั้งหมด
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(v) then
            local name = v.Name
            counts[name] = (counts[name] or 0) + 1
            if not models[name] then models[name] = v end
        end
    end

    -- ขั้นตอน 2: กรองลง Dropdown
    for name, count in pairs(counts) do
        local lowName = name:lower()
        local v = models[name]
        
        if lowName:find("sea") or lowName:find("hydra") or lowName:find("ghost ship") then
            table.insert(s, name)
        elseif v.Humanoid.MaxHealth >= 50000 or count == 1 then
            -- ถ้าเลือดเยอะ (บอส) หรือมีตัวเดียว (มินิบอส/NPC เควส) ให้ลงช่อง Boss
            table.insert(b, name)
        elseif count > 1 then
            -- ถ้ามีมากกว่า 1 ตัว ให้ถือว่าเป็น "มอนสเตอร์" สำหรับฟาร์ม
            table.insert(m, name)
        end
    end
    
    SeaDrop:Refresh(s) BossDrop:Refresh(b) MobDrop:Refresh(m)
end)

local SkillTab = Window:NewTab("Auto Skills")
local MeleeSec = SkillTab:NewSection("Melee")
for _, k in pairs({"Z", "X", "C", "V", "B", "E"}) do MeleeSec:NewToggle("Auto "..k, "ใช้ "..k, function(state) Settings.MeleeSkills[k] = state end) end
local SwordSec = SkillTab:NewSection("Sword")
for _, k in pairs({"Z", "X", "C", "V", "B", "E"}) do SwordSec:NewToggle("Auto "..k, "ใช้ "..k, function(state) Settings.SwordSkills[k] = state end) end
local FruitSec = SkillTab:NewSection("Fruit")
for _, k in pairs({"Z", "X", "C", "V", "B", "E"}) do FruitSec:NewToggle("Auto "..k, "ใช้ "..k, function(state) Settings.FruitSkills[k] = state end) end

local PlayerTab = Window:NewTab("Players")
local PlayerSec = PlayerTab:NewSection("Custom")
PlayerSec:NewToggle("Auto Buso", "เปิดฮาคิ (T)", function(state) Settings.AutoHakiT = state if state then PressT() end end)
PlayerSec:NewSlider("WalkSpeed", "ความเร็ว", 250, 16, function(s) pcall(function() lp.Character.Humanoid.WalkSpeed = s end) end)
PlayerSec:NewSlider("JumpPower", "กระโดด", 250, 50, function(s) pcall(function() lp.Character.Humanoid.JumpPower = s end) end)

local SetTab = Window:NewTab("Settings")
local SetSec = SetTab:NewSection("Config")
SetSec:NewDropdown("Weapon Select", "อาวุธ", {"Melee", "Sword", "Fruit"}, function(v) Settings.SelectedWeapon = v end)
SetSec:NewDropdown("Direction", "ตำแหน่ง", {"Top", "Bottom", "Behind"}, function(v) Settings.FarmDirection = v end)
SetSec:NewSlider("Distance", "ระยะ", 15, 5, function(s) Settings.FarmDistance = s end)

local Config = Window:NewTab("Config")
Config:NewSection("UI"):NewKeybind("Toggle GUI", "R-Ctrl", Enum.KeyCode.RightControl, function() Library:ToggleUI() end)

lp.CharacterAdded:Connect(function()
    task.wait(1.5)
    if Settings.AutoHakiT then PressT() end
    if Settings.AutoFarm then EquipWeapon() end
end)

Library:Notify("SPRXZII HUB", "Smart List Ready!", 3)
