-- Advanced Auto TP System with Quick Return & Auto Respawn
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Variables
local coordinates = {}
local originalPosition = nil
local isRunning = false
local currentIndex = 1
local cooldown = 1
local tpDuration = 1
local isMinimized = false
local autoRespawn = false
local autoLoop = true
local currentSlot = 1
local maxSlots = 5

-- Slot file names
local slotFileNames = {
    "tpwata1.txt",
    "tpwata2.txt", 
    "tpwata3.txt",
    "tpwata4.txt",
    "tpwata5.txt"
}

-- Simple file system check
local function isFileSystemAvailable()
    return pcall(function() 
        return readfile and writefile and delfile and isfile
    end)
end

-- Get filename for specific slot
local function getSlotFileName(slotNumber)
    return slotFileNames[slotNumber] or "autotp_slot_" .. slotNumber .. ".txt"
end

-- Convert Vector3 to table for JSON serialization
local function vector3ToTable(vec)
    return {X = vec.X, Y = vec.Y, Z = vec.Z}
end

-- Convert table back to Vector3
local function tableToVector3(tbl)
    return Vector3.new(tbl.X, tbl.Y, tbl.Z)
end

-- Save coordinates untuk slot tertentu
local function saveCoordinates()
    if not isFileSystemAvailable() then
        print("❌ File system not available")
        return false
    end
    
    -- Convert coordinates to serializable format
    local serializableCoords = {}
    for i, coord in ipairs(coordinates) do
        table.insert(serializableCoords, vector3ToTable(coord))
    end
    
    local dataToSave = {
        coordinates = serializableCoords,
        autoRespawn = autoRespawn,
        autoLoop = autoLoop,
        timestamp = os.time(),
        version = "1.0"
    }
    
    local fileName = getSlotFileName(currentSlot)
    
    local success, err = pcall(function()
        writefile(fileName, HttpService:JSONEncode(dataToSave))
    end)
    
    if success then
        print("✅ Saved slot " .. currentSlot .. " with " .. #coordinates .. " coordinates to " .. fileName)
        return true
    else
        print("❌ Failed to save slot " .. currentSlot .. ": " .. tostring(err))
        return false
    end
end

-- Load coordinates untuk slot tertentu
local function loadCoordinates()
    if not isFileSystemAvailable() then
        print("❌ File system not available")
        return false
    end
    
    local fileName = getSlotFileName(currentSlot)
    
    print("🔄 Attempting to load from: " .. fileName)
    
    -- Reset to defaults first
    coordinates = {}
    autoRespawn = false
    autoLoop = true
    
    local success, result = pcall(function()
        if isfile(fileName) then
            print("📁 File exists: " .. fileName)
            local content = readfile(fileName)
            print("📖 File content length: " .. string.len(content))
            return content
        else
            print("📝 File does not exist: " .. fileName)
            return nil
        end
    end)
    
    if success and result then
        print("📖 File read successfully, decoding...")
        local success2, decoded = pcall(function()
            return HttpService:JSONDecode(result)
        end)
        
        if success2 and decoded then
            print("✅ JSON decoded successfully")
            
            -- Load coordinates
            if decoded.coordinates and type(decoded.coordinates) == "table" then
                for i, coordData in ipairs(decoded.coordinates) do
                    if coordData.X and coordData.Y and coordData.Z then
                        table.insert(coordinates, tableToVector3(coordData))
                    end
                end
            end
            
            -- Load settings
            autoRespawn = decoded.autoRespawn or false
            autoLoop = decoded.autoLoop or true
            
            print("✅ Loaded slot " .. currentSlot .. " with " .. #coordinates .. " coordinates from " .. fileName)
            return true
        else
            print("❌ Failed to decode slot " .. currentSlot .. " data")
            print("❌ Error: " .. tostring(decoded))
            return false
        end
    else
        print("📝 No saved data for slot " .. currentSlot .. " (" .. fileName .. "), using defaults")
        return false
    end
end

-- Clear slot data
local function clearSlotData(slotNumber)
    if not isFileSystemAvailable() then return end
    
    local fileName = getSlotFileName(slotNumber)
    local success = pcall(function()
        if isfile(fileName) then
            delfile(fileName)
            print("🗑️ Cleared data for slot " .. slotNumber .. " (" .. fileName .. ")")
        end
    end)
end

-- Auto Respawn Function
local function autoRespawnCharacter()
    if autoRespawn and localPlayer.Character then
        print("🔄 Auto respawning character...")
        localPlayer.Character:BreakJoints()
        
        -- Wait for respawn
        localPlayer.CharacterAdded:Wait()
        wait(2)
        
        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            originalPosition = localPlayer.Character.HumanoidRootPart.Position
            print("✅ Respawn completed, new position saved")
        end
        return true
    end
    return false
end

-- Create Modern Horizontal UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoTPGUI"
screenGui.Parent = game.CoreGui

-- Main Container (Horizontal)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 180)
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
header.Size = UDim2.new(1, 0, 0, 30)
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
title.Text = "⚡ AUTO TELEPORT SYSTEM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 2
title.Parent = header

-- Control Buttons in Header
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -60, 0, 2)
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
closeBtn.Position = UDim2.new(1, -30, 0, 2)
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

-- Content Area (Horizontal Layout)
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -35)
content.Position = UDim2.new(0, 10, 0, 35)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- Left Panel - Controls
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 200, 1, 0)
leftPanel.BackgroundTransparency = 1
leftPanel.Parent = content

-- Status Card
local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, 0, 0, 50)
statusCard.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
statusCard.BorderSizePixel = 0

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusCard

local statusIcon = Instance.new("TextLabel")
statusIcon.Size = UDim2.new(0, 30, 0, 30)
statusIcon.Position = UDim2.new(0, 10, 0, 10)
statusIcon.Text = "⏹️"
statusIcon.TextColor3 = Color3.fromRGB(255, 100, 100)
statusIcon.BackgroundTransparency = 1
statusIcon.Font = Enum.Font.GothamBold
statusIcon.TextSize = 14
statusIcon.Parent = statusCard

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -50, 0, 18)
statusText.Position = UDim2.new(0, 45, 0, 8)
statusText.Text = "READY TO START"
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 11
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusCard

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, -50, 0, 15)
progressText.Position = UDim2.new(0, 45, 0, 25)
progressText.Text = "Press START to begin"
progressText.TextColor3 = Color3.fromRGB(200, 200, 200)
progressText.BackgroundTransparency = 1
progressText.Font = Enum.Font.Gotham
progressText.TextSize = 9
progressText.TextXAlignment = Enum.TextXAlignment.Left
progressText.Parent = statusCard

statusCard.Parent = leftPanel

-- Control Buttons Grid
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, 0, 0, 70)
buttonContainer.Position = UDim2.new(0, 0, 0, 55)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = leftPanel

local function createButton(text, color, position, size)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0.48, 0, 0, 30)
    button.Position = position
    button.Text = text
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.AutoButtonColor = true
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    return button
end

local startBtn = createButton("🚀 START", Color3.fromRGB(0, 180, 120), UDim2.new(0, 0, 0, 0))
local stopBtn = createButton("⏹️ STOP", Color3.fromRGB(220, 60, 60), UDim2.new(0.52, 0, 0, 0))
local addBtn = createButton("➕ ADD", Color3.fromRGB(80, 120, 200), UDim2.new(0, 0, 0, 35))
local clearBtn = createButton("🗑️ CLEAR", Color3.fromRGB(200, 120, 80), UDim2.new(0.52, 0, 0, 35))

startBtn.Parent = buttonContainer
stopBtn.Parent = buttonContainer
addBtn.Parent = buttonContainer
clearBtn.Parent = buttonContainer

-- Settings Panel
local settingsPanel = Instance.new("Frame")
settingsPanel.Size = UDim2.new(1, 0, 0, 40)
settingsPanel.Position = UDim2.new(0, 0, 0, 130)
settingsPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
settingsPanel.BorderSizePixel = 0

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 6)
settingsCorner.Parent = settingsPanel

local function createSetting(label, defaultValue, yPosition, isToggle)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 18)
    container.Position = UDim2.new(0, 5, 0, yPosition)
    container.BackgroundTransparency = 1
    container.Parent = settingsPanel
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 9
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    if isToggle then
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0.35, 0, 1, 0)
        toggleBtn.Position = UDim2.new(0.65, 0, 0, 0)
        toggleBtn.Text = defaultValue and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 50, 50)
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 9
        toggleBtn.BorderSizePixel = 0
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 4)
        toggleCorner.Parent = toggleBtn
        
        toggleBtn.Parent = container
        return toggleBtn
    else
        local textBox = Instance.new("TextBox")
        textBox.Size = UDim2.new(0.35, 0, 1, 0)
        textBox.Position = UDim2.new(0.65, 0, 0, 0)
        textBox.Text = tostring(defaultValue)
        textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 9
        textBox.BorderSizePixel = 0
        
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 4)
        boxCorner.Parent = textBox
        
        textBox.Parent = container
        return textBox
    end
end

local cooldownInput = createSetting("Cooldown:", 1, 2, false)
local durationInput = createSetting("Duration:", 0.01, 20, false)

settingsPanel.Parent = leftPanel

-- Right Panel - Coordinates & Slots
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0, 270, 1, 0)
rightPanel.Position = UDim2.new(0, 210, 0, 0)
rightPanel.BackgroundTransparency = 1
rightPanel.Parent = content

-- Slot Selector
local slotContainer = Instance.new("Frame")
slotContainer.Size = UDim2.new(1, 0, 0, 30)
slotContainer.BackgroundTransparency = 1
slotContainer.Parent = rightPanel

local slotTitle = Instance.new("TextLabel")
slotTitle.Size = UDim2.new(0, 60, 1, 0)
slotTitle.Position = UDim2.new(0, 0, 0, 0)
slotTitle.Text = "SLOT:"
slotTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
slotTitle.BackgroundTransparency = 1
slotTitle.Font = Enum.Font.GothamBold
slotTitle.TextSize = 11
slotTitle.TextXAlignment = Enum.TextXAlignment.Left
slotTitle.Parent = slotContainer

local function createSlotButton(slotNumber, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 30, 0, 25)
    button.Position = position
    button.Text = tostring(slotNumber)
    button.BackgroundColor3 = slotNumber == currentSlot and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(60, 60, 70)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.BorderSizePixel = 0
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        currentSlot = slotNumber
        updateSlotButtons()
        loadCoordinates()
        updateCoordinatesList()
        updateToggleButtons()
    end)
    
    return button
end

local slotButtons = {}
for i = 1, maxSlots do
    local button = createSlotButton(i, UDim2.new(0, 60 + (i-1)*35, 0, 0))
    button.Parent = slotContainer
    slotButtons[i] = button
end

-- Toggle Buttons Container
local toggleContainer = Instance.new("Frame")
toggleContainer.Size = UDim2.new(1, 0, 0, 40)
toggleContainer.Position = UDim2.new(0, 0, 0, 35)
toggleContainer.BackgroundTransparency = 1
toggleContainer.Parent = rightPanel

-- Auto Respawn Toggle
local respawnToggle = Instance.new("TextButton")
respawnToggle.Size = UDim2.new(0.48, 0, 0, 20)
respawnToggle.Position = UDim2.new(0, 0, 0, 0)
respawnToggle.Text = autoRespawn and "RESPAWN: ON" or "RESPAWN: OFF"
respawnToggle.BackgroundColor3 = autoRespawn and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 50, 50)
respawnToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
respawnToggle.Font = Enum.Font.GothamBold
respawnToggle.TextSize = 9
respawnToggle.BorderSizePixel = 0

local respawnCorner = Instance.new("UICorner")
respawnCorner.CornerRadius = UDim.new(0, 4)
respawnCorner.Parent = respawnToggle

-- Auto Loop Toggle
local loopToggle = Instance.new("TextButton")
loopToggle.Size = UDim2.new(0.48, 0, 0, 20)
loopToggle.Position = UDim2.new(0.52, 0, 0, 0)
loopToggle.Text = autoLoop and "LOOP: ON" or "LOOP: OFF"
loopToggle.BackgroundColor3 = autoLoop and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(120, 60, 120)
loopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
loopToggle.Font = Enum.Font.GothamBold
loopToggle.TextSize = 9
loopToggle.BorderSizePixel = 0

local loopCorner = Instance.new("UICorner")
loopCorner.CornerRadius = UDim.new(0, 4)
loopCorner.Parent = loopToggle

respawnToggle.Parent = toggleContainer
loopToggle.Parent = toggleContainer

-- File Name Display
local fileNameContainer = Instance.new("Frame")
fileNameContainer.Size = UDim2.new(1, 0, 0, 15)
fileNameContainer.Position = UDim2.new(0, 0, 0, 20)
fileNameContainer.BackgroundTransparency = 1
fileNameContainer.Parent = toggleContainer

local fileNameText = Instance.new("TextLabel")
fileNameText.Size = UDim2.new(1, 0, 1, 0)
fileNameText.Text = "File: " .. getSlotFileName(currentSlot)
fileNameText.TextColor3 = Color3.fromRGB(150, 150, 200)
fileNameText.BackgroundTransparency = 1
fileNameText.Font = Enum.Font.Gotham
fileNameText.TextSize = 8
fileNameText.TextXAlignment = Enum.TextXAlignment.Left
fileNameText.Parent = fileNameContainer

-- Coordinates List
local listContainer = Instance.new("Frame")
listContainer.Size = UDim2.new(1, 0, 1, -75)
listContainer.Position = UDim2.new(0, 0, 0, 75)
listContainer.BackgroundTransparency = 1
listContainer.Parent = rightPanel

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
function updateSlotButtons()
    for i, button in ipairs(slotButtons) do
        button.BackgroundColor3 = i == currentSlot and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(60, 60, 70)
    end
    fileNameText.Text = "File: " .. getSlotFileName(currentSlot)
end

function updateToggleButtons()
    respawnToggle.Text = autoRespawn and "RESPAWN: ON" or "RESPAWN: OFF"
    respawnToggle.BackgroundColor3 = autoRespawn and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 50, 50)
    
    loopToggle.Text = autoLoop and "LOOP: ON" or "LOOP: OFF"
    loopToggle.BackgroundColor3 = autoLoop and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(120, 60, 120)
end

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
    local itemHeight = 20
    
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
        deleteBtn.Position = UDim2.new(1, -20, 0, 2)
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
                if autoLoop or autoRespawn then
                    if autoRespawn then
                        progressText.Text = "Auto respawning..."
                        autoRespawnCharacter()
                    else
                        progressText.Text = "Restarting loop..."
                    end
                    currentIndex = 1
                    if autoRespawn then
                        wait(3)
                    end
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

-- Enhanced Draggable Functionality
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

-- Apply drag functionality
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

respawnToggle.MouseButton1Click:Connect(function()
    autoRespawn = not autoRespawn
    saveCoordinates()
    updateToggleButtons()
    
    if autoRespawn then
        progressText.Text = "Auto Respawn: ENABLED"
    else
        progressText.Text = "Auto Respawn: DISABLED"
    end
end)

loopToggle.MouseButton1Click:Connect(function()
    autoLoop = not autoLoop
    saveCoordinates()
    updateToggleButtons()
    
    if autoLoop then
        progressText.Text = "Auto Loop: ENABLED"
    else
        progressText.Text = "Auto Loop: DISABLED"
    end
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

-- Initialize dengan benar
local function initialize()
    print("🔄 Initializing Auto TP System...")
    print("📁 File System Available: " .. tostring(isFileSystemAvailable()))
    
    -- Load coordinates untuk slot pertama
    loadCoordinates()
    updateSlotButtons()
    updateCoordinatesList()
    updateToggleButtons()
    
    print("✅ Auto TP System Initialized!")
    print("• Current Slot: " .. currentSlot)
    print("• Current File: " .. getSlotFileName(currentSlot))
    print("• Coordinates Loaded: " .. #coordinates)
    print("• Auto Respawn: " .. tostring(autoRespawn))
    print("• Auto Loop: " .. tostring(autoLoop))
end

-- Jalankan inisialisasi
initialize()
