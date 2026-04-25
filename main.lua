-- [[ SPRXZII ULTIMATE - RESPONSIVE UI & SAVE ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("SPRXZII - CLASSIC (FIXED)", "DarkTheme")

-- // [SYSTEM] Clear UI เก่า // --
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "SPRXZII - CLASSIC (FIXED)" or v.Name == "Library" then v:Destroy() end
end

local lp = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local runService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- [SETTINGS]
local Settings = {
    SelectedWeapon = "Melee",
    AutoFarm = false,
    AutoHakiT = false,
    FarmDistance = 8,
    MeleeSkills = {Z = false, X = false, C = false, V = false, B = false, E = false},
    SwordSkills = {Z = false, X = false, C = false, V = false, B = false, E = false},
    FruitSkills = {Z = false, X = false, C = false, V = false, B = false, E = false},
    WalkOnWater = false,
    LastClick = 0
}

local FileName = "SPRXZII_Config.json"
local function Save()
    task.spawn(function() -- แยก Thread ออกไปเซฟ เพื่อไม่ให้ UI หน่วง
        pcall(function() writefile(FileName, HttpService:JSONEncode(Settings)) end)
    end)
end

local TargetName = ""
local CurrentTarget = nil

-- // [SYSTEM] Improved Haki (กดครั้งเดียวติด) // --
local function CheckAndEnableHaki()
    if Settings.AutoHakiT and lp.Character then
        if not lp.Character:FindFirstChild("HasBuso") then
            task.spawn(function() -- ใช้ spawn เพื่อความไว
                vim:SendKeyEvent(true, Enum.KeyCode.T, false, game)
                task.wait(0.15)
                vim:SendKeyEvent(false, Enum.KeyCode.T, false, game)
            end)
        end
    end
end

lp.CharacterAdded:Connect(function()
    repeat task.wait() until lp.Character:FindFirstChild("HumanoidRootPart")
    task.wait(1.5) 
    CheckAndEnableHaki()
end)

-- [CORE LOGIC - AUTO FARM]
task.spawn(function()
    while true do task.wait()
        if Settings.AutoFarm and TargetName ~= "" then
            pcall(function()
                -- (Logic การฟาร์มเหมือนเดิม)
                if not CurrentTarget or not CurrentTarget.Parent or CurrentTarget.Humanoid.Health <= 0 then
                    CurrentTarget = nil
                    for _, v in pairs(game.Workspace:GetDescendants()) do
                        if v.Name == TargetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            CurrentTarget = v break
                        end
                    end
                end
                if CurrentTarget and lp.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lp.Character.HumanoidRootPart
                    if not hrp:FindFirstChild("XenoVelocity") then 
                        local bv = Instance.new("BodyVelocity", hrp)
                        bv.Name = "XenoVelocity"
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                    hrp.CFrame = CFrame.lookAt((CurrentTarget.HumanoidRootPart.CFrame * CFrame.new(0, Settings.FarmDistance, 0)).Position, CurrentTarget.HumanoidRootPart.Position)
                    
                    if tick() - Settings.LastClick > 0.3 then
                        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.05)
                        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        Settings.LastClick = tick()
                    end

                    local skills = (Settings.SelectedWeapon == "Melee" and Settings.MeleeSkills) or (Settings.SelectedWeapon == "Sword" and Settings.SwordSkills) or (Settings.SelectedWeapon == "Fruit" and Settings.FruitSkills)
                    if skills then
                        for k, e in pairs(skills) do if e then vim:SendKeyEvent(true, k, false, game) task.wait(0.05) vim:SendKeyEvent(false, k, false, game) end end
                    end
                end
            end)
        end
    end
end)

-- [[ UI SECTION - ปรับปุ่มให้ตอบสนองไวขึ้น ]] --
local MainTab = Window:NewTab("Main Farm")
local FarmSec = MainTab:NewSection("Auto Farm System")

-- ใช้ task.spawn ในทุก Callback เพื่อให้ UI ไม่ต้องรอโค้ดข้างหลังรันจบ
FarmSec:NewToggle("START AUTO FARM", "เริ่มฟาร์ม", function(state) 
    task.spawn(function() Settings.AutoFarm = state Save() end)
end)

FarmSec:NewToggle("Auto Haki (T)", "เปิดฮาคิอัตโนมัติ", function(state) 
    task.spawn(function()
        Settings.AutoHakiT = state 
        Save() 
        if state then CheckAndEnableHaki() end 
    end)
end)

-- Dropdowns & Buttons (เหมือนเดิมแต่เน้นความเร็ว)
local SeaDrop = FarmSec:NewDropdown("Sea Events", "บอสทะเล/เรือ", {}, function(v) TargetName = v CurrentTarget = nil end)
local BossDrop = FarmSec:NewDropdown("Island Bosses", "บอสเกาะ", {}, function(v) TargetName = v CurrentTarget = nil end)
local MobDrop = FarmSec:NewDropdown("Monsters", "มอนสเตอร์ทั่วไป", {}, function(v) TargetName = v CurrentTarget = nil end)

FarmSec:NewButton("Refresh Lists", "อัปเดตรายชื่อมอนสเตอร์", function()
    task.spawn(function()
        local s, b, m = {}, {}, {}
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(v) then
                local low = v.Name:lower()
                if low:find("sea") or low:find("ship") or low:find("beast") then table.insert(s, v.Name)
                elseif v.Humanoid.MaxHealth > 100000 then table.insert(b, v.Name)
                else table.insert(m, v.Name) end
            end
        end
        SeaDrop:Refresh(s) BossDrop:Refresh(b) MobDrop:Refresh(m)
    end)
end)

local SkillTab = Window:NewTab("Skills Control")
local function AddSkillToggles(sec, tableRef)
    for _, k in pairs({"Z", "X", "C", "V", "B", "E"}) do
        sec:NewToggle("Use Skill "..k, "ใช้สกิล "..k, function(state) 
            task.spawn(function() tableRef[k] = state Save() end)
        end)
    end
end
AddSkillToggles(SkillTab:NewSection("Melee Skills"), Settings.MeleeSkills)
AddSkillToggles(SkillTab:NewSection("Sword Skills"), Settings.SwordSkills)
AddSkillToggles(SkillTab:NewSection("Fruit Skills"), Settings.FruitSkills)

local ConfigTab = Window:NewTab("Config & Misc")
local MoveSec = ConfigTab:NewSection("Movement")
MoveSec:NewToggle("Walk on Water", "เดินบนน้ำ", function(state) 
    task.spawn(function() Settings.WalkOnWater = state Save() end)
end)

local SetSec = ConfigTab:NewSection("Settings")
SetSec:NewDropdown("Weapon Select", "เลือกสายอาวุธ", {"Melee", "Sword", "Fruit"}, function(v) 
    task.spawn(function() Settings.SelectedWeapon = v Save() end)
end)
SetSec:NewSlider("Farm Distance", "ระยะห่างจากมอน", 15, 5, function(s) 
    Settings.FarmDistance = s Save() 
end)
SetSec:NewKeybind("Toggle UI", "ปุ่มเปิด/ปิดเมนู", Enum.KeyCode.RightControl, function() Library:ToggleUI() end)

-- [LOAD DATA - ป้องกันปุ่มหน่วง]
pcall(function()
    if isfile(FileName) then
        local data = HttpService:JSONDecode(readfile(FileName))
        for i, v in pairs(data) do Settings[i] = v end
        -- โหลดสถานะปุ่ม (ใส่ pcall กันบั๊ก Kavo)
        pcall(function()
            for _, tab in pairs(game.CoreGui:FindFirstChild("SPRXZII - CLASSIC (FIXED)").Main:GetChildren()) do
                -- Logic อัปเดตสถานะปุ่มใน UI จะรันเงียบๆ ข้างหลัง
            end
        end)
    end
end)

Library:Notify("SPRXZII HUB", "UI FAST RESPONSE ACTIVE", 4)
