

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local function getHRP()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

local HRP = getHRP()
LocalPlayer.CharacterAdded:Connect(function(char)
	HRP = char:WaitForChild("HumanoidRootPart")
end)


local FPS = 30
local INTERVAL = 1 / FPS
local MAX_SECONDS = 60
local MAX_FRAMES = MAX_SECONDS * FPS
local PLAYBACK_SPEED = 2 -- 1 = normal, 2 = 2x cepat


local recording = {}
local recordingConn = nil
local recordingPaused = false
local accum = 0

local isPlaying = false
local previewDone = false
local previewStartIndex = nil
local previewTargetIndex = nil
local chosenSec = 3


local function startRecording()
	if recordingConn then recordingConn:Disconnect() end
	accum = 0
	recordingConn = RunService.Heartbeat:Connect(function(dt)
		if recordingPaused or not HRP then return end
		accum += dt
		while accum >= INTERVAL do
			table.insert(recording, HRP.CFrame)
			if #recording > MAX_FRAMES then
				table.remove(recording, 1)
			end
			accum -= INTERVAL
		end
	end)
end

local function pauseRecording() recordingPaused = true end
local function resumeRecording() recordingPaused = false end
startRecording()


local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
blur.Enabled = false

local color = Instance.new("ColorCorrectionEffect", Lighting)
color.Enabled = false
color.TintColor = Color3.fromRGB(150, 200, 255)

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local overlay = Instance.new("TextLabel", gui)
overlay.Size = UDim2.new(1,0,1,0)
overlay.BackgroundTransparency = 1
overlay.Text = "<< REWINDING... >>"
overlay.TextColor3 = Color3.fromRGB(200,220,255)
overlay.Font = Enum.Font.SourceSansBold
overlay.TextSize = 42
overlay.Visible = false

local function startFX()
	blur.Enabled = true
	color.Enabled = true
	overlay.Visible = true
	TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()
end

local function stopFX()
	TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
	task.delay(0.6, function()
		blur.Enabled = false
		color.Enabled = false
		overlay.Visible = false
	end)
end


local function playFrames(startIdx, endIdx, forward, onDone)
	if isPlaying then return end
	isPlaying = true
	local step = forward and 1 or -1
	local i = startIdx
	local t = 0
	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		if not isPlaying or not HRP then
			conn:Disconnect()
			isPlaying = false
			if onDone then pcall(onDone) end
			return
		end
		local cur = recording[i]
		local nxt = recording[i + step]
		if not cur or not nxt then
			conn:Disconnect()
			isPlaying = false
			if onDone then pcall(onDone) end
			return
		end
		t = t + dt * FPS * PLAYBACK_SPEED
		if t > 1 then t = 1 end
		local pos = cur.Position:Lerp(nxt.Position, t)
		local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = nxt:GetComponents()
		HRP.CFrame = CFrame.new(pos.X,pos.Y,pos.Z,r00,r01,r02,r10,r11,r12,r20,r21,r22)
		if t >= 1 then
			t = 0
			i = i + step
			if (step == 1 and i >= endIdx) or (step == -1 and i <= endIdx) then
				if recording[endIdx] then HRP.CFrame = recording[endIdx] end
				conn:Disconnect()
				isPlaying = false
				if onDone then pcall(onDone) end
			end
		end
	end)
end

-- UI
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 110, 0, 40)
openBtn.Position = UDim2.new(0, 10, 0, 200)
openBtn.Text = "🔄 Rollback Menu"
openBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
openBtn.TextColor3 = Color3.new(1, 1, 1)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 260)
frame.Position = UDim2.new(0.5, -140, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
frame.Visible = false

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.Text = "🔄 Rollback Menu"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

for i = 1, 10 do
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0, 48, 0, 34)
	btn.Position = UDim2.new(0, ((i - 1) % 5) * 56 + 10, 0, math.floor((i - 1) / 5) * 42 + 46)
	btn.Text = tostring(i) .. "s"
	btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.MouseButton1Click:Connect(function()
		chosenSec = i
		for _,child in ipairs(frame:GetChildren()) do
			if child:IsA("TextButton") and child.Text:match("^%d+s") then
				child.BackgroundColor3 = (child.Text == tostring(i).."s") and Color3.fromRGB(90,140,90) or Color3.fromRGB(60,60,60)
			end
		end
	end)
end

local previewBtn = Instance.new("TextButton", frame)
previewBtn.Size = UDim2.new(0.45, -6, 0, 40)
previewBtn.Position = UDim2.new(0, 10, 0, 140)
previewBtn.Text = "▶️ Preview"
previewBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
previewBtn.TextColor3 = Color3.new(1,1,1)

local rollbackBtn = Instance.new("TextButton", frame)
rollbackBtn.Size = UDim2.new(0.45, -6, 0, 40)
rollbackBtn.Position = UDim2.new(0.5, 6, 0, 140)
rollbackBtn.Text = "⏪ Rollback"
rollbackBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
rollbackBtn.TextColor3 = Color3.new(1,1,1)

local cancelBtn = Instance.new("TextButton", frame)
cancelBtn.Size = UDim2.new(0.9, 0, 0, 40)
cancelBtn.Position = UDim2.new(0.05, 0, 0, 192)
cancelBtn.Text = "❌ Cancel"
cancelBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
cancelBtn.TextColor3 = Color3.new(1,1,1)

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1, -20, 0, 26)
info.Position = UDim2.new(0, 10, 0, 234)
info.BackgroundTransparency = 1
info.Text = "Status: idle"
info.TextColor3 = Color3.new(1,1,1)
info.TextXAlignment = Enum.TextXAlignment.Left

local function hasEnoughFrames(sec)
	return #recording > sec * FPS
end

openBtn.MouseButton1Click:Connect(function()
	if frame.Visible then
		frame.Visible = false
		recordingPaused = false
		info.Text = "Status: idle"
	else
		frame.Visible = true
		recordingPaused = true
		previewDone = false
		previewStartIndex, previewTargetIndex = nil,nil
		info.Text = "Status: UI open (paused)"
	end
end)

previewBtn.MouseButton1Click:Connect(function()
	if isPlaying then return end
	if not hasEnoughFrames(chosenSec) then
		info.Text = "Status: gak cukup rekaman"
		return
	end
	local startIdx = #recording
	local frames = math.min(#recording - 1, chosenSec * FPS)
	local targetIdx = math.max(1, startIdx - frames)
	previewStartIndex, previewTargetIndex = startIdx, targetIdx
	previewDone = false
	info.Text = "Status: previewing..."
	startFX()
	playFrames(startIdx, targetIdx, false, function()
		stopFX()
		previewDone = true
		info.Text = "Status: preview done"
	end)
end)

rollbackBtn.MouseButton1Click:Connect(function()
	if isPlaying then return end
	if previewDone and previewTargetIndex then
		frame.Visible = false
		recordingPaused = false
		previewDone = false
		info.Text = "Status: idle"
		return
	end
	if not hasEnoughFrames(chosenSec) then
		frame.Visible = false
		recordingPaused = false
		info.Text = "Status: idle"
		return
	end
	local startIdx = #recording
	local frames = math.min(#recording - 1, chosenSec * FPS)
	local targetIdx = math.max(1, startIdx - frames)
	info.Text = "Status: rolling back..."
	startFX()
	playFrames(startIdx, targetIdx, false, function()
		stopFX()
		frame.Visible = false
		recordingPaused = false
		info.Text = "Status: idle"
	end)
end)

cancelBtn.MouseButton1Click:Connect(function()
	if isPlaying then return end
	if previewDone and previewTargetIndex and previewStartIndex then
		info.Text = "Status: returning..."
		startFX()
		playFrames(previewTargetIndex, previewStartIndex, true, function()
			stopFX()
			if recording[previewStartIndex] then HRP.CFrame = recording[previewStartIndex] end
			previewDone = false
			frame.Visible = false
			recordingPaused = false
			info.Text = "Status: idle"
		end)
	else
		frame.Visible = false
		recordingPaused = false
		info.Text = "Status: idle"
	end
end)