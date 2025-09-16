

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")


local InfiniteJumpEnabled = false


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Button = Instance.new("TextButton")
Button.Parent = ScreenGui
Button.Size = UDim2.new(0,140,0,50)
Button.Position = UDim2.new(0.05,0,0.85,0)
Button.Text = "Infinite Jump: OFF"
Button.BackgroundColor3 = Color3.fromRGB(50,50,50)
Button.TextColor3 = Color3.fromRGB(255,255,255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 18
Button.BorderSizePixel = 0
Button.AutoButtonColor = true

local UICorner = Instance.new("UICorner", Button)
UICorner.CornerRadius = UDim.new(0,12)


local function toggleJump()
    InfiniteJumpEnabled = not InfiniteJumpEnabled
    if InfiniteJumpEnabled then
        Button.Text = "Infinite Jump: ON"
        Button.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        Button.Text = "Infinite Jump: OFF"
        Button.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end

Button.MouseButton1Click:Connect(toggleJump)


UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)


player.CharacterAdded:Connect(function(newChar)
    char = newChar
    humanoid = char:WaitForChild("Humanoid")
end)


local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    Button.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Button.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
