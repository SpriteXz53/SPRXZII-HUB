-- [[ SPRXZII ULTIMATE V10.1 - SMART EQUIP + AUTO SAVE ]] --
local HttpService = game:GetService("HttpService")
local FolderName = "SPRXZII_HUB"
local ConfigFile = FolderName.."/Config.json"

-- สร้างโฟลเดอร์สำหรับเก็บไฟล์ถ้ายังไม่มี
if not isfolder(FolderName) then makefolder(FolderName) end

-- // ตารางเก็บค่า Settings ทั้งหมด // --
_G.Settings = {
    SelectedWeapon = "Melee",
    AutoFarm = false,
    AutoQuest = true, 
    AutoHakiT = false,
    FarmDistance = 8,
    FarmDirection = "Top",
    MeleeSkills = {Z = false, X = false, C = false, V = false, B = false, E = false},
    SwordSkills = {Z = false, X = false},
    FruitSkills = {Z = false, X = false, C = false, V = false, B = false, E = false},
    WalkSpeed = 16,
    JumpPower = 50
}

-- // ฟังก์ชัน Save และ Load // --
local function SaveData()
    local json = HttpService:JSONEncode(_G.Settings)
    writefile(ConfigFile, json)
end

local function LoadData()
    if isfile(ConfigFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success then
            -- อัปเดตค่าจากไฟล์ลงใน _G.Settings
            for i, v in pairs(data) do
                if type(v) == "table" then
                    for k, val in pairs(v) do _G.Settings[i][k] = val end
                else
                    _G.Settings[i] = v
                end
            end
        end
    end
end

-- โหลดข้อมูลทันทีที่รันสคริปต์
LoadData()

-- // เริ่มต้น UI (โค้ดเดิมของคุณ) // --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("SPRXZII - V10.1 STABLE", "DarkTheme")
local lp = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local vim = game:GetService("VirtualInputManager")

-- // เชื่อมตัวแปรเดิมเข้ากับระบบ Save // --
local SelectedWeapon = _G.Settings.SelectedWeapon
local AutoFarm = _G.Settings.AutoFarm
local AutoQuest = _G.Settings.AutoQuest
local AutoHakiT = _G.Settings.AutoHakiT
local TargetName = ""
local FarmDistance = _G.Settings.FarmDistance
local FarmDirection = _G.Settings.FarmDirection
local CurrentTarget = nil

local MeleeSkills = _G.Settings.MeleeSkills
local SwordSkills = _G.Settings.SwordSkills
local FruitSkills = _G.Settings.FruitSkills

-- [ ฟังก์ชัน PressT, EquipWeapon, SecureAttack, QuestByTarget เหมือนเดิมทุกประการ ] --
local function PressT()
    if not AutoHakiT then return end
    pcall(function()
        if lp.Character and not lp.Character:FindFirstChild("HasBuso") then
            vim:SendKeyEvent(true, Enum.KeyCode.T, false, game)
            task.wait(0.05)
            vim:SendKeyEvent(false, Enum.KeyCode.T, false, game)
        end
    end)
end

local function EquipWeapon()
    if not AutoFarm then return end
    pcall(function()
        local char = lp.Character
        local backpack = lp:WaitForChild("Backpack")
        if char:FindFirstChildOfClass("Tool") then return end
        for _, v in pairs(backpack:GetChildren()) do
            if v:IsA("Tool") and (v.ToolTip == SelectedWeapon or v.Name:find(SelectedWeapon)) then
                char.Humanoid:EquipTool(v)
                break
            end
        end
    end)
end

lp.CharacterAdded:Connect(function()
    if AutoFarm then
        task.wait(0.5)
        EquipWeapon()
        task.wait(0.5)
        EquipWeapon()
    end
    if AutoHakiT then
        task.wait(0.5)
        PressT()
    end
end)

local function SecureAttack()
    if not AutoFarm or not CurrentTarget then return end
    pcall(function()
        local char = lp.Character
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            game:GetService("ReplicatedStorage").Remotes.TrainingRemote:FireServer()
        end
    end)
end

local function QuestByTarget()
    if not AutoQuest or TargetName == "" then return end
    pcall(function()
        local qGui = lp.PlayerGui.MainGui:FindFirstChild("QuestGui")
        if qGui and not qGui.Visible then
            for _, v in pairs(game.Workspace.NPCs:GetChildren()) do
                if v:FindFirstChild("Quest") and v.Quest.Value == TargetName then
                    lp.Character.HumanoidRootPart.CFrame = v.PrimaryPart.CFrame * CFrame.new(0, 0, 2)
                    task.wait(0.5)
                    game:GetService("ReplicatedStorage").Remotes.Quest:FireServer(v.Name)
                    task.wait(0.3)
                    break
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait()
        if AutoHakiT and tick() % 5 < 0.02 then PressT() end
        if AutoFarm then
            pcall(function()
                local char = lp.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local hrp = char.HumanoidRootPart
                if AutoQuest then QuestByTarget() end
                if TargetName ~= "" then
                    if not CurrentTarget or not CurrentTarget.Parent or CurrentTarget.Humanoid.Health <= 0 then
                        CurrentTarget = nil
                        for _, v in pairs(game.Workspace:GetDescendants()) do
                            if v.Name == TargetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                CurrentTarget = v break
                            end
                        end
                    end
                    if CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart") then
                        local targetHrp = CurrentTarget.HumanoidRootPart
                        local bv = hrp:FindFirstChild("XenoVelocity") or Instance.new("BodyVelocity", hrp)
                        bv.Name = "XenoVelocity"
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Velocity = Vector3.new(0, 0, 0)
                        local offset = (FarmDirection == "Top" and CFrame.new(0, FarmDistance, 0)) or (FarmDirection == "Bottom" and CFrame.new(0, -FarmDistance, 0)) or CFrame.new(0, 0, FarmDistance)
                        local goalCFrame = CFrame.lookAt((targetHrp.CFrame * offset).Position, targetHrp.Position)
                        if (hrp.Position - goalCFrame.Position).Magnitude > 0.1 then
                            hrp.CFrame = goalCFrame
                        end
                        SecureAttack()
                    end
                end
            end)
        else
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local v = lp.Character.HumanoidRootPart:FindFirstChild("XenoVelocity")
                if v then v:Destroy() end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1.5)
        if AutoFarm and CurrentTarget then
            local targetTable = (SelectedWeapon == "Melee" and MeleeSkills) or (SelectedWeapon == "Sword" and SwordSkills) or (SelectedWeapon == "Fruit" and FruitSkills)
            if targetTable then
                for key, enabled in pairs(targetTable) do
                    if enabled and AutoFarm and lp.Character:FindFirstChildOfClass("Tool") then
                        vim:SendKeyEvent(true, key, false, game)
                        task.wait(0.1)
                        vim:SendKeyEvent(false, key, false, game)
                    end
                end
            end
        end
    end
end)

-- // [[ UI ]] เพิ่มฟังก์ชัน SaveData() ในปุ่มต่างๆ // --
local MainTab = Window:NewTab("Auto Farm")
local FarmSec = MainTab:NewSection("Farming")
FarmSec:NewToggle("START AUTO FARM", "เริ่มฟาร์ม", function(state) 
    AutoFarm = state
    _G.Settings.AutoFarm = state
    SaveData() 
    if state then EquipWeapon() end 
end)
FarmSec:NewToggle("Auto Quest", "รับเควสตามตัวที่เลือก", function(state) 
    AutoQuest = state 
    _G.Settings.AutoQuest = state
    SaveData()
end)

local SeaDrop = FarmSec:NewDropdown("Sea Events", "บอสทะเล", {}, function(v) TargetName = v CurrentTarget = nil end)
local BossDrop = FarmSec:NewDropdown("Bosses", "บอส", {}, function(v) TargetName = v CurrentTarget = nil end)
local MobDrop = FarmSec:NewDropdown("Monsters", "มอนทั่วไป", {}, function(v) TargetName = v CurrentTarget = nil end)

FarmSec:NewButton("Refresh Lists", "อัปเดตรายชื่อมอน", function()
    local s, b, m = {}, {}, {}
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and not game.Players:GetPlayerFromCharacter(v) then
            local name = v.Name
            if name:lower():find("sea") or name:lower():find("hydra") then table.insert(s, name)
            elseif v.Humanoid.MaxHealth >= 50000 then table.insert(b, name)
            else table.insert(m, name) end
        end
    end
    SeaDrop:Refresh(s) BossDrop:Refresh(b) MobDrop:Refresh(m)
end)

local SkillTab = Window:NewTab("Auto Skills")
local MeleeSec = SkillTab:NewSection("Melee")
for _, k in pairs({"Z", "X", "C", "V", "B", "E"}) do 
    MeleeSec:NewToggle("Auto "..k, "ใช้ "..k, function(state) 
        MeleeSkills[k] = state 
        SaveData()
    end) 
end
local SwordSec = SkillTab:NewSection("Sword")
for _, k in pairs({"Z", "X"}) do 
    SwordSec:NewToggle("Auto "..k, "ใช้ "..k, function(state) 
        SwordSkills[k] = state 
        SaveData()
    end) 
end
local FruitSec = SkillTab:NewSection("Fruit")
for _, k in pairs({"Z", "X", "C", "V", "B", "E"}) do 
    FruitSec:NewToggle("Auto "..k, "ใช้ "..k, function(state) 
        FruitSkills[k] = state 
        SaveData()
    end) 
end

local PlayerTab = Window:NewTab("Players")
local PlayerSec = PlayerTab:NewSection("Player Customization")
PlayerSec:NewToggle("Auto Buso", "กดปุ่ม T เปิดฮาคิอัติโนมัติ", function(state) 
    AutoHakiT = state 
    _G.Settings.AutoHakiT = state
    SaveData()
    if state then PressT() end 
end)
PlayerSec:NewSlider("WalkSpeed", "ความเร็วเดิน", 200, 16, function(s) 
    pcall(function() lp.Character.Humanoid.WalkSpeed = s end) 
    _G.Settings.WalkSpeed = s
    SaveData()
end)
PlayerSec:NewSlider("JumpPower", "แรงกระโดด", 200, 50, function(s) 
    pcall(function() lp.Character.Humanoid.JumpPower = s end) 
    _G.Settings.JumpPower = s
    SaveData()
end)
PlayerSec:NewButton("Infinite Yield", "สคริปต์แอดมิน", function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end)

local SetTab = Window:NewTab("Settings")
local SetSec = SetTab:NewSection("Config")
SetSec:NewDropdown("Weapon Select", "อาวุธ", {"Melee", "Sword", "Fruit"}, function(v) 
    SelectedWeapon = v 
    _G.Settings.SelectedWeapon = v
    SaveData()
end)
SetSec:NewDropdown("Direction", "ตำแหน่งฟาร์ม", {"Top", "Bottom", "Behind"}, function(v) 
    FarmDirection = v 
    _G.Settings.FarmDirection = v
    SaveData()
end)
SetSec:NewSlider("Distance", "ระยะห่าง", 15, 5, function(s) 
    FarmDistance = s 
    _G.Settings.FarmDistance = s
    SaveData()
end)

local Config = Window:NewTab("Config")
Config:NewSection("UI"):NewKeybind("Toggle GUI", "R-Ctrl เพื่อปิด/เปิด", Enum.KeyCode.RightControl, function() Library:ToggleUI() end)

Library:Notify("SPRXZII HUB", "Settings Loaded & Auto-Save Active!", 3)
