

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local hrp = LocalPlayer.Character and LocalPlayer.Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
	hrp = char:WaitForChild("HumanoidRootPart")
end)

local coords = {
	Vector3.new(599.142517,266.544098,518.947937), 
	Vector3.new(-23426.833984,6348.779785,-6916.956543) 
}

local looping = false

local function tpLoop()
	task.spawn(function()
		local i = 1
		while looping do
			if hrp then
				hrp.CFrame = CFrame.new(coords[i])
				i = i + 1
				if i > #coords then i = 1 end
			end
			task.wait(0.1) 
		end
	end)
end

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local StartBtn = Instance.new("TextButton")
local StopBtn = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

Frame.Size = UDim2.new(0, 120, 0, 70)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BorderSizePixel = 2
Frame.Active = true
Frame.Draggable = true -- bikin bisa digeser
Frame.Parent = ScreenGui

StartBtn.Size = UDim2.new(0, 100, 0, 25)
StartBtn.Position = UDim2.new(0, 10, 0, 10)
StartBtn.Text = "▶ Start"
StartBtn.BackgroundColor3 = Color3.fromRGB(50,200,50)
StartBtn.TextColor3 = Color3.new(1,1,1)
StartBtn.Parent = Frame

StopBtn.Size = UDim2.new(0, 100, 0, 25)
StopBtn.Position = UDim2.new(0, 10, 0, 40)
StopBtn.Text = "⏹ Stop"
StopBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
StopBtn.TextColor3 = Color3.new(1,1,1)
StopBtn.Parent = Frame

StartBtn.MouseButton1Click:Connect(function()
	if not looping then
		looping = true
		tpLoop()
	end
end)

StopBtn.MouseButton1Click:Connect(function()
	looping = false
end)