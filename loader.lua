-- [[ SPRXZII - PROFESSIONAL LOADER ]] --
local FolderName = "SPRXZII_HUB"
local KeyFile = FolderName.."/Key.txt"

-- สร้างโฟลเดอร์ถ้ายังไม่มี
if not isfolder(FolderName) then makefolder(FolderName) end

local Config = {
    AdminKey = "sprxzii",
    KeyLink = "https://work.ink/xxxx/xxxx",
    -- แก้ไขตรงนี้: ให้ใส่เฉพาะ URL ของไฟล์ Raw เท่านั้น
    MainScriptUrl = "https://raw.githubusercontent.com/SpriteXz53/SPRXZII-HUB/main/main.lua"
}

local function LoadMain()
    -- แก้ไขตรงนี้: ใช้ pcall เพื่อป้องกันสคริปต์ Error แล้วเงียบไป
    local success, err = pcall(function()
        loadstring(game:HttpGet(Config.MainScriptUrl))()
    end)
    if not success then
        warn("SPRXZII Error: " .. tostring(err))
    end
end

-- ตรวจสอบคีย์เดิม (Auto Login)
if isfile(KeyFile) then
    local saved = readfile(KeyFile)
    if saved == Config.AdminKey then
        print("SPRXZII: License Verified.")
        LoadMain()
        return
    end
end

-- ถ้าไม่มีคีย์ให้แสดง UI Key
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("SPRXZII HUB - KEY SYSTEM", "DarkTheme")
local Tab = Window:NewTab("Verification")
local Sec = Tab:NewSection("Please Enter Your Key")

Sec:NewTextBox("Key", "Enter key here...", function(val)
    if val == Config.AdminKey then
        -- ถ้าเป็นคีย์ Admin ให้รันสคริปต์เลย โดย "ไม่ใช้" writefile (ตามที่พี่ต้องการ)
        Library:Notify("Admin Access", "Welcome back, Admin!", 3)
        task.wait(1)
        
        -- ลบ GUI ระบบคีย์ทิ้งก่อนรันสคริปต์หลัก
        for i,v in pairs(game.CoreGui:GetChildren()) do
            if v:IsA("ScreenGui") and (v.Name == "SPRXZII HUB - KEY SYSTEM" or v:FindFirstChild("Main")) then 
                v:Destroy() 
            end
        end
        
        LoadMain()
    else
        Library:Notify("Error", "Invalid key!", 3)
    end
end)

Sec:NewButton("Get Key (Work.ink)", "Copy to clipboard", function()
    setclipboard(Config.KeyLink)
    Library:Notify("Copied!", "Link copied to clipboard", 3)
end)
