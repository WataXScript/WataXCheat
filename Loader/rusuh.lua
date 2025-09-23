

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")


local flying, rusuhOn = false, false
local flySpeed = 70
local rusuhDelay, lastRusuh = 0.001, 0
local moveVec = Vector3.zero
local invincible = false


local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "FlyRusuhUI"

local mainFrame = Instance.new("Frame", ScreenGui)
mainFrame.Size = UDim2.new(0,270,0,320)
mainFrame.Position = UDim2.new(0,50,0,100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.Active, mainFrame.Draggable = true, true

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "🚀 WataX"
title.Font, title.TextSize = Enum.Font.SourceSansBold, 18

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local function makeBtn(txt,pos)
local b = Instance.new("TextButton", mainFrame)
b.Size = UDim2.new(0.8,0,0,35)
b.Position = UDim2.new(0.1,0,0,pos)
b.Text, b.BackgroundColor3, b.TextColor3 = txt, Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
return b
end

local flyBtn = makeBtn("Fly: OFF",40)
local rusuhBtn = makeBtn("Rusuh: OFF",80)
local tpBtn = makeBtn("TP Random Player",120)


local function makeDirBtn(txt,posx,posy,color)
local b = Instance.new("TextButton", mainFrame)
b.Size = UDim2.new(0.25,0,0,40)
b.Position = UDim2.new(posx,0,0,posy)
b.Text, b.BackgroundColor3, b.TextColor3 = txt, color, Color3.fromRGB(255,255,255)
return b
end

local forwardBtn = makeDirBtn("↑",0.37,170,Color3.fromRGB(70,70,150))
local backBtn    = makeDirBtn("↓",0.37,220,Color3.fromRGB(70,70,150))
local leftBtn    = makeDirBtn("←",0.1,220,Color3.fromRGB(70,70,150))
local rightBtn   = makeDirBtn("→",0.65,220,Color3.fromRGB(70,70,150))


local sliderFrame = Instance.new("Frame", mainFrame)
sliderFrame.Size = UDim2.new(0.8,0,0,20)
sliderFrame.Position = UDim2.new(0.1,0,0,270)
sliderFrame.BackgroundColor3 = Color3.fromRGB(70,70,70)

local sliderFill = Instance.new("Frame", sliderFrame)
sliderFill.Size = UDim2.new(0.35,0,1,0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0,200,100)

local sliderLabel = Instance.new("TextLabel", mainFrame)
sliderLabel.Size = UDim2.new(1,0,0,20)
sliderLabel.Position = UDim2.new(0,0,0,295)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.fromRGB(255,255,255)
sliderLabel.Text = "Fly Speed: 70"


flyBtn.MouseButton1Click:Connect(function()
flying = not flying
flyBtn.Text = flying and "Fly: ON" or "Fly: OFF"
end)

rusuhBtn.MouseButton1Click:Connect(function()
rusuhOn = not rusuhOn
rusuhBtn.Text = rusuhOn and "Rusuh: ON" or "Rusuh: OFF"
end)

tpBtn.MouseButton1Click:Connect(function()
local targets = {}
for _,plr in ipairs(Players:GetPlayers()) do
if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
table.insert(targets,plr)
end
end
if #targets > 0 then
local target = targets[math.random(1,#targets)]
HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,2,0)
end
end)


local function bindHold(btn,onHold,onRelease)
btn.MouseButton1Down:Connect(onHold)
btn.MouseButton1Up:Connect(onRelease)
end
bindHold(forwardBtn,function() moveVec=Vector3.new(0,0,-1) end,function() moveVec=Vector3.zero end)
bindHold(backBtn,function() moveVec=Vector3.new(0,0,1) end,function() moveVec=Vector3.zero end)
bindHold(leftBtn,function() moveVec=Vector3.new(-1,0,0) end,function() moveVec=Vector3.zero end)
bindHold(rightBtn,function() moveVec=Vector3.new(1,0,0) end,function() moveVec=Vector3.zero end)


local dragging = false
sliderFrame.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then dragging=true end end)
sliderFrame.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)

RunService.RenderStepped:Connect(function()
if dragging then
local touch = UIS:GetMouseLocation().X
local rel = math.clamp((touch-sliderFrame.AbsolutePosition.X)/sliderFrame.AbsoluteSize.X,0,1)
sliderFill.Size = UDim2.new(rel,0,1,0)
flySpeed = math.floor(20 + rel*500)
sliderLabel.Text = "Fly Speed: "..flySpeed
end
end)


local function rusuhNearby()
local now = tick()
if now - lastRusuh < rusuhDelay then return end
lastRusuh = now

local nearest, dist  
for _,plr in ipairs(Players:GetPlayers()) do  
	if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then  
		local d = (plr.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude  
		if d <= 50 and (not dist or d < dist) then  
			nearest, dist = plr.Character.HumanoidRootPart, d  
		end  
	end  
end  

if nearest then  
	local dir = (nearest.Position - HumanoidRootPart.Position).Unit  
	HumanoidRootPart.Velocity = dir * 450 + Vector3.new(3,1,2)  
	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)  
end

end


local function antiDamage()
if Humanoid and Humanoid.Parent then
pcall(function()
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
if Humanoid.Health < Humanoid.MaxHealth then
Humanoid.Health = Humanoid.MaxHealth
end
end)
end
end

Humanoid.StateChanged:Connect(function(_,new)
if rusuhOn or invincible then antiDamage() end
end)

local Lines = {}
function CreateLine(plr)
if plr == LocalPlayer then return end
local line = Drawing.new("Line")
line.Color = Color3.fromRGB(255,50,50)
line.Thickness = 5
line.Transparency = 1
Lines[plr] = line
end
function RemoveLine(plr)
if Lines[plr] then Lines[plr]:Remove() Lines[plr]=nil end
end
for _,plr in ipairs(Players:GetPlayers()) do
if plr ~= LocalPlayer then
CreateLine(plr)
end
end
Players.PlayerAdded:Connect(CreateLine)
Players.PlayerRemoving:Connect(RemoveLine)

RunService.RenderStepped:Connect(function()
for plr,line in pairs(Lines) do
if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and HumanoidRootPart then
local screenPos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
if onScreen then
local myPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
line.From = myPos
line.To = Vector2.new(screenPos.X, screenPos.Y)
line.Visible = true
else
line.Visible = false
end
else
line.Visible = false
end
end
end)


RunService.Heartbeat:Connect(function()

if flying and HumanoidRootPart then
local camCF = Camera.CFrame
local dir = camCF:VectorToWorldSpace(moveVec)
if dir.Magnitude > 0 then
HumanoidRootPart.Velocity = dir.Unit * flySpeed
else
HumanoidRootPart.Velocity = Vector3.zero
end
end


if rusuhOn then  
	rusuhNearby()  
	antiDamage()  
end

end)


flyBtn.MouseButton1Click:Connect(function()
invincible = not invincible
end)
