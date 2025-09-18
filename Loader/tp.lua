

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local hrp = player.Character and player.Character:WaitForChild("HumanoidRootPart")


local folderPath = "tpwata/"
if not isfolder(folderPath) then
    makefolder(folderPath)
end


local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "WataX_Teleport"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 340, 0, 260)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 5, 0, 0)
title.Text = "🌍 WataX Teleport"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 16

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 3)
closeBtn.Text = "✖"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
closeBtn.BorderSizePixel = 0
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local saveBox = Instance.new("TextBox", frame)
saveBox.Size = UDim2.new(0.65, -10, 0, 30)
saveBox.Position = UDim2.new(0, 5, 0, 40)
saveBox.PlaceholderText = "Nama Lokasi..."
saveBox.Text = ""
saveBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
saveBox.TextColor3 = Color3.fromRGB(255,255,255)
saveBox.BorderSizePixel = 0

local saveBtn = Instance.new("TextButton", frame)
saveBtn.Size = UDim2.new(0.35, -10, 0, 30)
saveBtn.Position = UDim2.new(0.65, 5, 0, 40)
saveBtn.Text = "💾 Save"
saveBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
saveBtn.BorderSizePixel = 0

local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(1, -10, 1, -80)
listFrame.Position = UDim2.new(0, 5, 0, 80)
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.ScrollBarThickness = 4
listFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
listFrame.BorderSizePixel = 0

local UIList = Instance.new("UIListLayout", listFrame)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0,5)


local function saveLocation(name)
    if not hrp then return end
    local pos = hrp.Position
    local path = folderPath..name..".txt"
    writefile(path, string.format("%f,%f,%f", pos.X, pos.Y, pos.Z))
end


local function loadLocations()
    for _,v in pairs(listFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    local files = listfiles(folderPath)
    for _,f in ipairs(files) do
        if f:match("%.txt$") then
            local fname = f:match("([^/]+)%.txt$")
            
            local item = Instance.new("Frame", listFrame)
            item.Size = UDim2.new(1, -5, 0, 30)
            item.BackgroundColor3 = Color3.fromRGB(40,40,40)
            item.BorderSizePixel = 0

            local lbl = Instance.new("TextLabel", item)
            lbl.Size = UDim2.new(0.45, 0, 1, 0)
            lbl.Text = "📍 "..fname
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(255,255,255)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local tpBtn = Instance.new("TextButton", item)
            tpBtn.Size = UDim2.new(0.25, -5, 1, 0)
            tpBtn.Position = UDim2.new(0.45, 5, 0, 0)
            tpBtn.Text = "🚀 TP"
            tpBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
            tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
            tpBtn.BorderSizePixel = 0

            local delBtn = Instance.new("TextButton", item)
            delBtn.Size = UDim2.new(0.25, -5, 1, 0)
            delBtn.Position = UDim2.new(0.70, 5, 0, 0)
            delBtn.Text = "🗑 Del"
            delBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
            delBtn.TextColor3 = Color3.fromRGB(255,255,255)
            delBtn.BorderSizePixel = 0

            tpBtn.MouseButton1Click:Connect(function()
                local data = readfile(f)
                local x,y,z = string.match(data, "([^,]+),([^,]+),([^,]+)")
                if x and y and z and hrp then
                    hrp.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
                end
            end)

            delBtn.MouseButton1Click:Connect(function()
                delfile(f)
                loadLocations()
            end)
        end
    end
    listFrame.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y + 10)
end


saveBtn.MouseButton1Click:Connect(function()
    local name = saveBox.Text:gsub("%s+", "_")
    if name ~= "" then
        saveLocation(name)
        loadLocations()
        saveBox.Text = ""
    end
end)

-- Init
loadLocations()