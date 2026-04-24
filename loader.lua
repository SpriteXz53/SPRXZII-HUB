-- [[ SPRXZII - PROFESSIONAL LOADER ]] --
local FolderName = "SPRXZII_HUB"
local KeyFile = FolderName.."/Key.txt"

-- สร้างโฟลเดอร์ถ้ายังไม่มี
if not isfolder(FolderName) then makefolder(FolderName) end

local Config = {
    AdminKey = "sprxzii",
    KeyLink = "https://work.ink/xxxx/xxxx",
    MainScriptUrl = "loadstring(game:HttpGet(https://raw.githubusercontent.com/SpriteXz53/SPRXZII-HUB/refs/heads/main/main.lua))()"
}

local function LoadMain()
    loadstring(game:HttpGet(Config.MainScriptUrl))()
end

-- ตรวจสอบคีย์เดิม (Auto Login)
if isfile(KeyFile) and readfile(KeyFile) == Config.AdminKey then
    print("SPRXZII: License Verified.")
    LoadMain()
    return
end

-- ถ้าไม่มีคีย์ให้แสดง UI Key
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("SPRXZII HUB - KEY SYSTEM", "DarkTheme")
local Tab = Window:NewTab("Verification")
local Sec = Tab:NewSection("Please Enter Your Key")

Sec:NewTextBox("Key", "Enter key here...", function(val)
    if val == Config.AdminKey then
        -- ถ้าเป็นคีย์ Admin ให้รันสคริปต์เลย โดย "ไม่ใช้" writefile
        Library:Notify("Admin Access", "Welcome back, Admin!", 3)
        task.wait(1)
        
        -- ปิด UI ระบบคีย์
        for i,v in pairs(game.CoreGui:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name == "SPRXZII HUB - KEY SYSTEM" then v:Destroy() end
        end
        
        LoadMain()
    elseif val == "คีย์ทั่วไป" then -- สมมติว่าคุณมีระบบคีย์ทั่วไปในอนาคต
        -- ถ้าเป็นคีย์ทั่วไปค่อยสั่ง writefile(KeyFile, val)
        writefile(KeyFile, val)
        LoadMain()
    else
        Library:Notify("Error", "Invalid key!", 3)
    end
end)

Sec:NewButton("Get Key (Work.ink)", "Copy to clipboard", function()
    setclipboard(Config.KeyLink)
end)
