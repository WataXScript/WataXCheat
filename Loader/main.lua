local player = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ==============================
local locations = {
    {"Glider", 114, 2266, 3898},
    {"Foto Puncak", 116, 2430, 3491},
}
-- ==============================

-- GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "MountAtinHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 280)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Header
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, -10, 0, 35)
header.Position = UDim2.new(0,5,0,5)
header.BackgroundColor3 = Color3.fromRGB(55,55,75)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.Text = "🏔️ WataX Menu"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 35, 1, 0)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.Text = "✖"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,70,70)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local logoBtn = Instance.new("TextButton", gui)
logoBtn.Size = UDim2.new(0, 50, 0, 50)
logoBtn.Position = UDim2.new(0, 50, 0, 50)
logoBtn.Text = "🏔️"
logoBtn.Visible = false
logoBtn.BackgroundColor3 = Color3.fromRGB(90,130,200)
logoBtn.TextColor3 = Color3.fromRGB(255,255,255)
logoBtn.Font = Enum.Font.GothamBold
logoBtn.TextScaled = true
Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(1, 0)

local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1, -10, 1, -50)
content.Position = UDim2.new(0,5,0,45)
content.BackgroundTransparency = 1

local contentLayout = Instance.new("UIListLayout", content)
contentLayout.Padding = UDim.new(0, 6)
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ================== MENU SYSTEM ==================
local currentMenu = "main"

local function clearContent()
    for _,v in pairs(content:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
end

local function createButton(txt,color,callback)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Text = txt
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(callback)
end

-- ================== MOUNT ATIN MENU ==================
function showMountAtinMenu()
    clearContent()
    title.Text = "🗺️ Mount Atin Menu"

    local scroll = Instance.new("ScrollingFrame", content)
    scroll.Size = UDim2.new(1, -20, 1, -100)
    scroll.BackgroundColor3 = Color3.fromRGB(55,55,75)
    scroll.BackgroundTransparency = 0.2
    scroll.CanvasSize = UDim2.new()
    scroll.BorderSizePixel = 0
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)

    local scrollLayout = Instance.new("UIListLayout", scroll)
    scrollLayout.Padding = UDim.new(0, 5)

    for _, loc in ipairs(locations) do
        local locBtn = Instance.new("TextButton", scroll)
        locBtn.Size = UDim2.new(1, -10, 0, 40)
        locBtn.Text = "📌 "..loc[1]
        locBtn.BackgroundColor3 = Color3.fromRGB(90, 130, 200)
        locBtn.TextColor3 = Color3.fromRGB(255,255,255)
        locBtn.Font = Enum.Font.GothamBold
        locBtn.TextScaled = true
        Instance.new("UICorner", locBtn).CornerRadius = UDim.new(0, 10)
        locBtn.MouseButton1Click:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(loc[2], loc[3], loc[4])
            end
        end)
    end

    scroll.CanvasSize = UDim2.new(0,0,0,#locations * 45)

    createButton("🔄 Rejoin Server", Color3.fromRGB(200,130,70), function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
    createButton("⬅️ Back", Color3.fromRGB(150,150,150), function()
        showMainMenu()
    end)
end

-- ================== FLY 3D FULL ==================
local hrp, humanoid
local flying, invincible, bodyVelocity = false, false, nil
local flySpeed = 100
local moveY = 0 -- naik/turun

-- Tombol naik/turun draggable
local function createDraggableButton(text, color, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,60,0,60)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    btn.Parent = gui

    local dragging, dragInput, dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    return btn
end

local upBtn = createDraggableButton("⬆️", Color3.fromRGB(90,130,200), UDim2.new(0.85,0,0.7,0))
local downBtn = createDraggableButton("⬇️", Color3.fromRGB(200,70,70), UDim2.new(0.85,0,0.8,0))

upBtn.MouseButton1Down:Connect(function() moveY = 1 end)
upBtn.MouseButton1Up:Connect(function() moveY = 0 end)
downBtn.MouseButton1Down:Connect(function() moveY = -1 end)
downBtn.MouseButton1Up:Connect(function() moveY = 0 end)

local function toggleFly()
    if not player.Character then return end
    hrp = player.Character:WaitForChild("HumanoidRootPart")
    humanoid = player.Character:WaitForChild("Humanoid")
    flying = not flying
    if flying then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        bodyVelocity.Parent = hrp
    else
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    end
end

local function toggleInvincible()
    if not player.Character then return end
    humanoid = player.Character:WaitForChild("Humanoid")
    invincible = not invincible
    if invincible then
        spawn(function()
            while invincible do
                if humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
                wait(0.05)
            end
        end)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    else
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
    end
end

-- Fly loop
RunService.RenderStepped:Connect(function()
    if flying and hrp and humanoid and bodyVelocity then
        local moveDir = humanoid.MoveDirection
        local moveVector = Vector3.new(moveDir.X, moveY, moveDir.Z)
        if moveVector.Magnitude > 0 then
            bodyVelocity.Velocity = moveVector.Unit * flySpeed
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end
end)

function showFlyMenu()
    clearContent()
    title.Text = "🕊️ Fly Menu"
    createButton("✈️ Toggle Fly", Color3.fromRGB(90,130,200), toggleFly)
    createButton("🛡️ Toggle Kebal", Color3.fromRGB(200,130,70), toggleInvincible)
    createButton("⬅️ Back", Color3.fromRGB(150,150,150), function()
        showMainMenu()
    end)
end

-- ================== MAIN MENU ==================
local function showMainMenu()
    clearContent()
    title.Text = "🏔️ WataX Menu"
    currentMenu = "main"
    createButton("🗺️ Mount Atin Menu", Color3.fromRGB(90,130,200), showMountAtinMenu)
    createButton("🕊️ Fly Menu", Color3.fromRGB(200,130,70), showFlyMenu)
end

-- ================== DRAGGING FRAME ==================
local dragging, dragInput, dragStart, startPos
frame.Active = true
frame.Draggable = false
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Close → Logo
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    logoBtn.Visible = true
    logoBtn.Position = frame.Position
end)
logoBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    logoBtn.Visible = false
end)

-- Start menu
showMainMenu()
