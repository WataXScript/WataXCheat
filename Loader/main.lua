local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local flying, flySpeed = false, 150
local hrp, humanoid, bodyVelocity
local moveY = 0


local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "WataXFly"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 250)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(45,45,60)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)


local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, -10, 0, 35)
header.Position = UDim2.new(0,5,0,5)
header.BackgroundColor3 = Color3.fromRGB(55,55,75)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.Text = "✈️ WataX Fly"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold


local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 35, 1, 0)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.Text = "➖"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,130,70)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local logoBtn = Instance.new("TextButton", screenGui)
logoBtn.Size = UDim2.new(0, 50, 0, 50)
logoBtn.Position = UDim2.new(0, 50, 0, 50)
logoBtn.Text = "✈️"
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

local invincible = false
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


local function showFlyMenu()
    for _,v in pairs(content:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
    title.Text = "✈️ Fly Menu"

    createButton("✈️ Toggle Fly", Color3.fromRGB(90,130,200), toggleFly)
    createButton("🛡️ Toggle Kebal", Color3.fromRGB(200,130,70), toggleInvincible)

    createButton("🌐 Join Discord", Color3.fromRGB(114,137,218), function()
        local link = "https://discord.gg/tfNqRQsqHK" 
        setclipboard(link)
        pcall(function()
            game:GetService("GuiService"):OpenBrowserWindow(link)
        end)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Discord",
            Text = "Link Discord dicopy ke clipboard!"
        })
    end)
end


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


closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    logoBtn.Visible = true
    logoBtn.Position = frame.Position
end)
logoBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    logoBtn.Visible = false
end)


local function createDraggableButton(text, color, pos, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,60,0,60)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    btn.Parent = parent

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

local upBtn = createDraggableButton("⬆️", Color3.fromRGB(90,130,200), UDim2.new(0.85,0,0.7,0), screenGui)
local downBtn = createDraggableButton("⬇️", Color3.fromRGB(200,70,70), UDim2.new(0.85,0,0.8,0), screenGui)

upBtn.MouseButton1Down:Connect(function() moveY = 1 end)
upBtn.MouseButton1Up:Connect(function() moveY = 0 end)
downBtn.MouseButton1Down:Connect(function() moveY = -1 end)
downBtn.MouseButton1Up:Connect(function() moveY = 0 end)


showFlyMenu()
