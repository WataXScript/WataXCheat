-- LocalScript: TeleportSystem
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Buat ScreenGui
local teleportGui = Instance.new("ScreenGui")
teleportGui.Name = "TeleportGui"
teleportGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true

-- Corner Radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Shadow Effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)
shadow.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Teleport System"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- Content Area
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1

-- Add Coordinate Section
local addSection = Instance.new("Frame")
addSection.Name = "AddSection"
addSection.Size = UDim2.new(1, 0, 0, 120)
addSection.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
addSection.BorderSizePixel = 0

local sectionCorner = Instance.new("UICorner")
sectionCorner.CornerRadius = UDim.new(0, 8)
sectionCorner.Parent = addSection

local sectionTitle = Instance.new("TextLabel")
sectionTitle.Name = "SectionTitle"
sectionTitle.Size = UDim2.new(1, 0, 0, 30)
sectionTitle.BackgroundTransparency = 1
sectionTitle.Text = "Add New Coordinate"
sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
sectionTitle.TextSize = 14
sectionTitle.Font = Enum.Font.GothamBold

local nameInput = Instance.new("TextBox")
nameInput.Name = "NameInput"
nameInput.Size = UDim2.new(1, -20, 0, 30)
nameInput.Position = UDim2.new(0, 10, 0, 35)
nameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
nameInput.BorderSizePixel = 0
nameInput.PlaceholderText = "Coordinate Name"
nameInput.Text = ""
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.TextSize = 12
nameInput.Font = Enum.Font.Gotham
nameInput.ClearTextOnFocus = false

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = nameInput

local addButton = Instance.new("TextButton")
addButton.Name = "AddButton"
addButton.Size = UDim2.new(1, -20, 0, 35)
addButton.Position = UDim2.new(0, 10, 0, 75)
addButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
addButton.BorderSizePixel = 0
addButton.Text = "Add Coordinate"
addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addButton.TextSize = 14
addButton.Font = Enum.Font.GothamBold

local addButtonCorner = Instance.new("UICorner")
addButtonCorner.CornerRadius = UDim.new(0, 6)
addButtonCorner.Parent = addButton

-- List Section
local listSection = Instance.new("Frame")
listSection.Name = "ListSection"
listSection.Size = UDim2.new(1, 0, 1, -130)
listSection.Position = UDim2.new(0, 0, 0, 130)
listSection.BackgroundTransparency = 1

local listTitle = Instance.new("TextLabel")
listTitle.Name = "ListTitle"
listTitle.Size = UDim2.new(1, 0, 0, 30)
listTitle.BackgroundTransparency = 1
listTitle.Text = "Saved Coordinates"
listTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
listTitle.TextSize = 14
listTitle.Font = Enum.Font.GothamBold

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, -30)
scrollFrame.Position = UDim2.new(0, 0, 0, 30)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local listLayout = Instance.new("UIListLayout")
listLayout.Name = "ListLayout"
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollFrame

-- Parent semua elemen
titleBar.Parent = mainFrame
titleLabel.Parent = titleBar
closeButton.Parent = titleBar
contentFrame.Parent = mainFrame
addSection.Parent = contentFrame
sectionTitle.Parent = addSection
nameInput.Parent = addSection
addButton.Parent = addSection
listSection.Parent = contentFrame
listTitle.Parent = listSection
scrollFrame.Parent = listSection
mainFrame.Parent = teleportGui
teleportGui.Parent = playerGui

-- Variabel untuk drag
local dragging = false
local dragInput, dragStart, startPos

-- Fungsi untuk load coordinates dari file
local function loadCoordinates()
    local coordinates = {}
    
    -- Coba baca dari file (ini akan bekerja jika menggunakan DataStore atau file system)
    pcall(function()
        -- Untuk demo, kita simpan dalam bentuk table
        -- Di production, gunakan DataStore
        if isfile and isfile("tpwata.txt") then
            local success, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile("tpwata.txt"))
            end)
            if success then
                coordinates = data
            end
        end
    end)
    
    return coordinates
end

-- Fungsi untuk save coordinates ke file
local function saveCoordinates(coordinates)
    pcall(function()
        if writefile then
            writefile("tpwata.txt", game:GetService("HttpService"):JSONEncode(coordinates))
        end
    end)
end

-- Fungsi untuk update list
local function updateList()
    local coordinates = loadCoordinates()
    
    -- Clear existing list
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add coordinates to list
    local ySize = 0
    for name, coord in pairs(coordinates) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = name
        itemFrame.Size = UDim2.new(1, 0, 0, 50)
        itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        itemFrame.BorderSizePixel = 0
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 6)
        itemCorner.Parent = itemFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.6, -10, 1, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local tpButton = Instance.new("TextButton")
        tpButton.Name = "TPButton"
        tpButton.Size = UDim2.new(0.15, -5, 0, 30)
        tpButton.Position = UDim2.new(0.6, 5, 0.5, -15)
        tpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        tpButton.BorderSizePixel = 0
        tpButton.Text = "TP"
        tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpButton.TextSize = 12
        tpButton.Font = Enum.Font.GothamBold
        
        local tpCorner = Instance.new("UICorner")
        tpCorner.CornerRadius = UDim.new(0, 4)
        tpCorner.Parent = tpButton
        
        local delButton = Instance.new("TextButton")
        delButton.Name = "DelButton"
        delButton.Size = UDim2.new(0.15, -5, 0, 30)
        delButton.Position = UDim2.new(0.8, 5, 0.5, -15)
        delButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        delButton.BorderSizePixel = 0
        delButton.Text = "DEL"
        delButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        delButton.TextSize = 12
        delButton.Font = Enum.Font.GothamBold
        
        local delCorner = Instance.new("UICorner")
        delCorner.CornerRadius = UDim.new(0, 4)
        delCorner.Parent = delButton
        
        -- Parent item elements
        nameLabel.Parent = itemFrame
        tpButton.Parent = itemFrame
        delButton.Parent = itemFrame
        itemFrame.Parent = scrollFrame
        
        ySize = ySize + 58
        
        -- TP Button functionality
        tpButton.MouseButton1Click:Connect(function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(coord.x, coord.y, coord.z)
            end
        end)
        
        -- Delete Button functionality
        delButton.MouseButton1Click:Connect(function()
            local coordinates = loadCoordinates()
            coordinates[name] = nil
            saveCoordinates(coordinates)
            updateList()
        end)
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, ySize)
end

-- Add Coordinate functionality
addButton.MouseButton1Click:Connect(function()
    local coordName = nameInput.Text:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    
    if coordName == "" or coordName == "Coordinate Name" then
        return
    end
    
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        
        local coordinates = loadCoordinates()
        coordinates[coordName] = {
            x = position.X,
            y = position.Y,
            z = position.Z
        }
        
        saveCoordinates(coordinates)
        updateList()
        nameInput.Text = ""
    end
end)

-- Close Button functionality
closeButton.MouseButton1Click:Connect(function()
    teleportGui.Enabled = false
end)

-- Drag functionality
local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Initialize
updateList()

-- Toggle GUI dengan key (opsional)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then -- Ganti dengan key yang diinginkan
        teleportGui.Enabled = not teleportGui.Enabled
    end
end)
