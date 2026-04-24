-- [[ SPRXZII - PROFESSIONAL LOADER ]] --
local FolderName = "SPRXZII_HUB"
local KeyFile = FolderName.."/Key.txt"

-- สร้างโฟลเดอร์ถ้ายังไม่มี
if not isfolder(FolderName) then makefolder(FolderName) end

local Config = {
    AdminKey = "sprxzii",
    KeyLink = "https://work.ink/xxxx/xxxx",
    MainScriptUrl = "https://raw.githubusercontent.com/USER/REPO/main/main.lua"
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
        writefile(KeyFile, val) -- เซฟคีย์ลงโฟลเดอร์
        Library:Notify("Success", "Correct key! Loading...", 3)
        task.wait(1)
        for i,v in pairs(game.CoreGui:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name == "SPRXZII HUB - KEY SYSTEM" then v:Destroy() end
        end
        LoadMain()
    else
        Library:Notify("Error", "Invalid key!", 3)
    end
end)

Sec:NewButton("Get Key (Work.ink)", "Copy to clipboard", function()
    setclipboard(Config.KeyLink)
end)
