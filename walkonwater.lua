local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- สร้างแผ่นรองเท้า (Platform)
local waterPlatform = Instance.new("Part")
waterPlatform.Name = "WaterWalkPlatform"
waterPlatform.Size = Vector3.new(10, 1, 10)
waterPlatform.Transparency = 1 -- ล่องหน
waterPlatform.Anchored = true
waterPlatform.CanCollide = true
waterPlatform.Parent = workspace

print("🌊 Water Walk Loaded! You can now walk on the ocean.")

runService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        -- ตรวจสอบว่ามีน้ำอยู่ข้างล่างหรือไม่ (ใน King Legacy น้ำมักจะอยู่ที่ระดับ Y = 0 ถึง 20)
        -- สคริปต์นี้จะเปิดการทำงานเมื่อตัวละครอยู่ใกล้ระดับน้ำ
        if root.Position.Y < 25 and root.Position.Y > -5 then
            waterPlatform.CFrame = CFrame.new(root.Position.X, 0.5, root.Position.Z) -- ล็อคแผ่นไว้ที่ระดับผิวน้ำ
            waterPlatform.CanCollide = true
        else
            -- ถ้าอยู่บนเกาะหรือบินสูง ให้ปิดการชนกันเพื่อไม่ให้ขวางทาง
            waterPlatform.CanCollide = false
            waterPlatform.CFrame = CFrame.new(0, -500, 0)
        end
    end
end)

-- ป้องกันสคริปต์ค้างเวลาตาย
player.CharacterAdded:Connect(function(newChar)
    waterPlatform.CanCollide = false
end)
