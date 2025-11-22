-- Advanced Auto TP System with Quick Return
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variables
local coordinates = {}
local originalPosition = nil
local isRunning = false
local currentIndex = 1
local cooldown = 5
local tpDuration = 0.01
local isMinimized = false

-- Load saved coordinates
local function loadCoordinates()
    local success, result = pcall(function()
        return readfile("auto_tp_coordinates.txt")
    end)
    
    if success and result then
        local loadedCoords = {}
        for line in result:gmatch("[^\r\n]+") do
            local x, y, z = line:match("([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
            if x and y and z then
                table.insert(loadedCoords, Vector3.new(tonumber(x), tonumber(y), tonumber(z)))
            end
        end
        coordinates = loadedCoords
        print("✅ Loaded " .. #coordinates .. " coordinates from file")
    else
        -- Default coordinates jika file tidak ada
        coordinates = {
            Vector3.new(100, 50, 100),
            Vector3.new(200, 50, 150),
            Vector3.new(150, 50, 200),
            Vector3.new(300, 50, 100),
            Vector3.new(250, 50, 250)
        }
        print("📝 Using default coordinates")
    end
end

-- Save coordinates to file
local function saveCoordinates()
    local coordStrings = {}
    for _, coord in ipairs(coordinates) do
        table.insert(coordStrings, string.format("%.2f,%.2f,%.2f", coord.X, coord.Y, coord.Z))
    end
    
    local success, err = pcall(function()
        writefile("auto_tp_coordinates.txt", table.concat(coordStrings, "\n"))
    end)
    
    if success then
        print("💾 Saved " .. #coordinates .. " coordinates to file")
    else
        warn("❌ Failed to save coordinates: " .. tostring(err))
    end
end

-- Create Modern Compact UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoTPGUI"
screenGui.Parent = game.CoreGui

-- Main Container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 380)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true

-- Corner Radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Drop Shadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)
shadow.Parent = mainFrame

mainFrame.Parent = screenGui

-- Minimized Version (Icon)
local minimizedFrame = Instance.new("Frame")
minimizedFrame.Size = UDim2.new(0, 50, 0, 50)
minimizedFrame.Position = UDim2.new(0, 20, 0, 20)
minimizedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
minimizedFrame.BackgroundTransparency = 0.1
minimizedFrame.BorderSizePixel = 0
minimizedFrame.Visible = false

local minimizedCorner = Instance.new("UICorner")
minimizedCorner.CornerRadius = UDim.new(0, 8)
minimizedCorner.Parent = minimizedFrame

local minimizedShadow = Instance.new("ImageLabel")
minimizedShadow.Size = UDim2.new(1, 10, 1, 10)
minimizedShadow.Position = UDim2.new(0, -5, 0, -5)
minimizedShadow.BackgroundTransparency = 1
minimizedShadow.Image = "rbxassetid://5554236805"
minimizedShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
minimizedShadow.ImageTransparency = 0.8
minimizedShadow.ScaleType = Enum.ScaleType.Slice
minimizedShadow.SliceCenter = Rect.new(23, 23, 277, 277)
minimizedShadow.Parent = minimizedFrame

local minimizedIcon = Instance.new("TextButton")
minimizedIcon.Size = UDim2.new(1, 0, 1, 0)
minimizedIcon.Text = "⚡"
minimizedIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizedIcon.BackgroundTransparency = 1
minimizedIcon.Font = Enum.Font.GothamBold
minimizedIcon.TextSize = 20
minimizedIcon.Parent = minimizedFrame

minimizedFrame.Parent = screenGui

-- Header (Draggable Area)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
header.BorderSizePixel = 0
header.ZIndex = 2

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "⚡ AUTO TELEPORT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 2
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -80, 0, 12)
subtitle.Position = UDim2.new(0, 15, 0, 18)
subtitle.Text = "Quick Return System"
subtitle.TextColor3 = Color3.fromRGB(200, 200, 255)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 9
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 2
subtitle.Parent = header

-- Control Buttons in Header
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -60, 0, 5)
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 14
minimizeBtn.BorderSizePixel = 0
minimizeBtn.ZIndex = 2

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 2

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

minimizeBtn.Parent = header
closeBtn.Parent = header
header.Parent = mainFrame

-- Content Area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -45)
content.Position = UDim2.new(0, 10, 0, 40)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- Status Card
local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, 0, 0, 60)
statusCard.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
statusCard.BorderSizePixel = 0

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusCard

local statusIcon = Instance.new("TextLabel")
statusIcon.Size = UDim2.new(0, 30, 0, 30)
statusIcon.Position = UDim2.new(0, 10, 0, 15)
statusIcon.Text = "⏹️"
statusIcon.TextColor3 = Color3.fromRGB(255, 100, 100)
statusIcon.BackgroundTransparency = 1
statusIcon.Font = Enum.Font.GothamBold
statusIcon.TextSize = 16
statusIcon.Parent = statusCard

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -50, 0, 20)
statusText.Position = UDim2.new(0, 45, 0, 12)
statusText.Text = "READY TO START"
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 13
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusCard

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, -50, 0, 15)
progressText.Position = UDim2.new(0, 45, 0, 32)
progressText.Text = "Press START to begin"
progressText.TextColor3 = Color3.fromRGB(200, 200, 200)
progressText.BackgroundTransparency = 1
progressText.Font = Enum.Font.Gotham
progressText.TextSize = 10
progressText.TextXAlignment = Enum.TextXAlignment.Left
progressText.Parent = statusCard

statusCard.Parent = content

-- Control Buttons
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, 0, 0, 80)
buttonContainer.Position = UDim2.new(0, 0, 0, 70)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = content

local function createButton(text, color, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.48, 0, 0, 35)
    button.Position = position
    button.Text = text
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.AutoButtonColor = true
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    return button
end

local startBtn = createButton("🚀 START", Color3.fromRGB(0, 180, 120), UDim2.new(0, 0, 0, 0))
local stopBtn = createButton("⏹️ STOP", Color3.fromRGB(220, 60, 60), UDim2.new(0.52, 0, 0, 0))
local addBtn = createButton("➕ ADD", Color3.fromRGB(80, 120, 200), UDim2.new(0, 0, 0, 40))
local clearBtn = createButton("🗑️ CLEAR", Color3.fromRGB(200, 120, 80), UDim2.new(0.52, 0, 0, 40))

startBtn.Parent = buttonContainer
stopBtn.Parent = buttonContainer
addBtn.Parent = buttonContainer
clearBtn.Parent = buttonContainer

-- Settings Panel
local settingsPanel = Instance.new("Frame")
settingsPanel.Size = UDim2.new(1, 0, 0, 80)
settingsPanel.Position = UDim2.new(0, 0, 0, 160)
settingsPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
settingsPanel.BorderSizePixel = 0

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 6)
settingsCorner.Parent = settingsPanel

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, -20, 0, 20)
settingsTitle.Position = UDim2.new(0, 10, 0, 0)
settingsTitle.Text = "SETTINGS"
settingsTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 12
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsPanel

local function createSetting(label, defaultValue, yPosition)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 20)
    container.Position = UDim2.new(0, 10, 0, yPosition)
    container.BackgroundTransparency = 1
    container.Parent = settingsPanel
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 10
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.35, 0, 1, 0)
    textBox.Position = UDim2.new(0.65, 0, 0, 0)
    textBox.Text = tostring(defaultValue)
    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 10
    textBox.BorderSizePixel = 0
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = textBox
    
    textBox.Parent = container
    return textBox
end

local cooldownInput = createSetting("Cooldown:", 1, 25)
local durationInput = createSetting("Duration:", 0.01, 45)
local loopToggle = createSetting("Loop:", "true", 65)

settingsPanel.Parent = content

-- Coordinates List
local listContainer = Instance.new("Frame")
listContainer.Size = UDim2.new(1, 0, 1, -250)
listContainer.Position = UDim2.new(0, 0, 0, 250)
listContainer.BackgroundTransparency = 1
listContainer.Parent = content

local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, 0, 0, 20)
listTitle.Position = UDim2.new(0, 0, 0, 0)
listTitle.Text = "COORDINATES (" .. #coordinates .. ")"
listTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
listTitle.BackgroundTransparency = 1
listTitle.Font = Enum.Font.GothamBold
listTitle.TextSize = 11
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.Parent = listContainer

local coordinatesFrame = Instance.new("ScrollingFrame")
coordinatesFrame.Size = UDim2.new(1, 0, 1, -25)
coordinatesFrame.Position = UDim2.new(0, 0, 0, 20)
coordinatesFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
coordinatesFrame.BorderSizePixel = 0
coordinatesFrame.ScrollBarThickness = 3
coordinatesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
coordinatesFrame.ScrollingDirection = Enum.ScrollingDirection.Y

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 6)
listCorner.Parent = coordinatesFrame

coordinatesFrame.Parent = listContainer

-- Functions
function saveOriginalPosition()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        originalPosition = localPlayer.Character.HumanoidRootPart.Position
        print("Original position saved: " .. tostring(originalPosition))
        return true
    end
    return false
end

function quickTeleport(targetCoord)
    if not originalPosition then
        if not saveOriginalPosition() then
            return false
        end
    end
    
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local hrp = character.HumanoidRootPart
    
    -- TP ke target
    hrp.CFrame = CFrame.new(targetCoord)
    
    -- Tunggu sebentar sesuai duration
    wait(tonumber(durationInput.Text) or 0.01)
    
    -- Kembali ke posisi awal
    hrp.CFrame = CFrame.new(originalPosition)
    
    return true
end

function updateCoordinatesList()
    coordinatesFrame:ClearAllChildren()
    
    local yOffset = 0
    local itemHeight = 22
    
    for i, coord in ipairs(coordinates) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, -6, 0, itemHeight)
        itemFrame.Position = UDim2.new(0, 3, 0, yOffset)
        itemFrame.BackgroundColor3 = i == currentIndex and Color3.fromRGB(70, 70, 90) or Color3.fromRGB(55, 55, 65)
        itemFrame.BorderSizePixel = 0
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 3)
        itemCorner.Parent = itemFrame
        
        local indexLabel = Instance.new("TextLabel")
        indexLabel.Size = UDim2.new(0, 20, 1, 0)
        indexLabel.Position = UDim2.new(0, 3, 0, 0)
        indexLabel.Text = i .. "."
        indexLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        indexLabel.BackgroundTransparency = 1
        indexLabel.Font = Enum.Font.GothamBold
        indexLabel.TextSize = 9
        indexLabel.TextXAlignment = Enum.TextXAlignment.Left
        indexLabel.Parent = itemFrame
        
        local coordLabel = Instance.new("TextLabel")
        coordLabel.Size = UDim2.new(0.7, -25, 1, 0)
        coordLabel.Position = UDim2.new(0, 20, 0, 0)
        coordLabel.Text = string.format("X:%.0f Y:%.0f Z:%.0f", coord.X, coord.Y, coord.Z)
        coordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        coordLabel.BackgroundTransparency = 1
        coordLabel.Font = Enum.Font.Gotham
        coordLabel.TextSize = 9
        coordLabel.TextXAlignment = Enum.TextXAlignment.Left
        coordLabel.Parent = itemFrame
        
        local deleteBtn = Instance.new("TextButton")
        deleteBtn.Size = UDim2.new(0, 16, 0, 16)
        deleteBtn.Position = UDim2.new(1, -20, 0, 3)
        deleteBtn.Text = "×"
        deleteBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        deleteBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
        deleteBtn.Font = Enum.Font.GothamBold
        deleteBtn.TextSize = 12
        deleteBtn.BorderSizePixel = 0
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 3)
        btnCorner.Parent = deleteBtn
        
        deleteBtn.MouseButton1Click:Connect(function()
            table.remove(coordinates, i)
            updateCoordinatesList()
            saveCoordinates()
        end)
        
        deleteBtn.Parent = itemFrame
        itemFrame.Parent = coordinatesFrame
        yOffset = yOffset + itemHeight + 2
    end
    
    coordinatesFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    listTitle.Text = "COORDINATES (" .. #coordinates .. ")"
end

function startAutoTP()
    if isRunning then return end
    
    if #coordinates == 0 then
        statusText.Text = "NO COORDINATES"
        statusIcon.Text = "❌"
        progressText.Text = "Add coordinates first!"
        return
    end
    
    if not saveOriginalPosition() then
        statusText.Text = "ERROR: No Character"
        statusIcon.Text = "❌"
        return
    end
    
    isRunning = true
    currentIndex = 1
    cooldown = tonumber(cooldownInput.Text) or 1
    tpDuration = tonumber(durationInput.Text) or 0.01
    
    statusText.Text = "TELEPORTING..."
    statusIcon.Text = "🚀"
    statusCard.BackgroundColor3 = Color3.fromRGB(60, 80, 50)
    
    spawn(function()
        while isRunning do
            if currentIndex > #coordinates then
                if loopToggle.Text:lower() == "true" then
                    currentIndex = 1
                else
                    stopAutoTP()
                    break
                end
            end
            
            local currentCoord = coordinates[currentIndex]
            progressText.Text = string.format("Progress: %d/%d", currentIndex, #coordinates)
            
            if quickTeleport(currentCoord) then
                currentIndex = currentIndex + 1
                updateCoordinatesList()
            else
                progressText.Text = "Failed to teleport!"
                wait(1)
            end
            
            wait(cooldown)
        end
    end)
end

function stopAutoTP()
    isRunning = false
    statusText.Text = "STOPPED"
    statusIcon.Text = "⏹️"
    statusCard.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    progressText.Text = "Ready to start"
end

function addCurrentPosition()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = localPlayer.Character.HumanoidRootPart.Position
        table.insert(coordinates, pos)
        updateCoordinatesList()
        saveCoordinates()
        progressText.Text = "Added current position!"
    else
        progressText.Text = "No character found!"
    end
end

function toggleMinimize()
    isMinimized = not isMinimized
    
    if isMinimized then
        mainFrame.Visible = false
        minimizedFrame.Visible = true
        minimizedFrame.Position = mainFrame.Position
    else
        mainFrame.Visible = true
        minimizedFrame.Visible = false
    end
end

-- Enhanced Draggable Functionality (Doesn't affect camera)
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end

local function onInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end

local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = isMinimized and minimizedFrame.Position or mainFrame.Position
        
        -- Capture input to prevent camera movement
        local contextActionService = game:GetService("ContextActionService")
        contextActionService:BindAction("DisableCamera", function() return Enum.ContextActionResult.Sink end, false, Enum.UserInputType.MouseMovement)
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                contextActionService:UnbindAction("DisableCamera")
            end
        end)
    end
end

local function handleDrag(input)
    if dragging and (input == dragInput) then
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        
        if isMinimized then
            minimizedFrame.Position = newPosition
        else
            mainFrame.Position = newPosition
        end
    end
end

-- Apply drag functionality to both frames
header.InputBegan:Connect(startDrag)
header.InputChanged:Connect(updateInput)

minimizedFrame.InputBegan:Connect(startDrag)
minimizedFrame.InputChanged:Connect(updateInput)

UserInputService.InputChanged:Connect(handleDrag)
UserInputService.InputEnded:Connect(onInputEnded)

-- Event Handlers
startBtn.MouseButton1Click:Connect(startAutoTP)
stopBtn.MouseButton1Click:Connect(stopAutoTP)
addBtn.MouseButton1Click:Connect(addCurrentPosition)

clearBtn.MouseButton1Click:Connect(function()
    coordinates = {}
    currentIndex = 1
    updateCoordinatesList()
    saveCoordinates()
    progressText.Text = "All coordinates cleared!"
end)

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)
minimizedIcon.MouseButton1Click:Connect(toggleMinimize)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Close with ESC
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape then
        if isMinimized then
            toggleMinimize()
        else
            screenGui:Destroy()
        end
    end
end)

-- Initialize
loadCoordinates()
updateCoordinatesList()

print("🎯 Auto TP System Loaded!")
print("• Press START to begin quick teleport")
print("• ESC to close GUI or minimize")
print("• Drag header to move window")
print("• Coordinates are automatically saved")
