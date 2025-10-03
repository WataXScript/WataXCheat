

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer


local function click(btn)
    if not btn then return end
    for _,c in ipairs(getconnections(btn.MouseButton1Click)) do
        c:Fire()
    end
end

local function findButtonByText(root, txt)
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("TextButton") and v.Text == txt then
            return v
        end
    end
    return nil
end


local function getButtons()
    local gui1 = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("WataX_AnimUI").Frame
    local gui2 = CoreGui:WaitForChild("WataXReplay").Frame

    local bypassOff = findButtonByText(gui1, "BYPASS: OFF")
    local bypassOn  = findButtonByText(gui1, "BYPASS: ON")
    local startBtn  = findButtonByText(gui2, "Start To End")
    local stopBtn   = findButtonByText(gui2, "Stop")

    return bypassOff, bypassOn, startBtn, stopBtn
end


if CoreGui:FindFirstChild("AFKGui") then
    CoreGui.AFKGui:Destroy()
end

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "AFKGui"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0.5, -125, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.Text = "AFK Auto Respawn"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 200, 0, 30)
input.Position = UDim2.new(0.5, -100, 0, 40)
input.PlaceholderText = "Detik Respawn"
input.Text = ""
input.ClearTextOnFocus = false

local startBtn = Instance.new("TextButton", frame)
startBtn.Size = UDim2.new(0, 200, 0, 30)
startBtn.Position = UDim2.new(0.5, -100, 0, 80)
startBtn.Text = "Start AFK"


local running = false

startBtn.MouseButton1Click:Connect(function()
    if running then
        running = false
        startBtn.Text = "Start AFK"
        return
    end
    running = true
    startBtn.Text = "Stop AFK"

    task.spawn(function()
        while running do
            local dur = tonumber(input.Text) or 10

            local bypassOff, bypassOn, startBtnUI, stopBtnUI = getButtons()

            
            click(startBtnUI)
            click(bypassOff)
            print("[AFK] Start To End + BYPASS: OFF diklik")

            
            task.wait(dur)

            
            click(stopBtnUI)
            click(bypassOn)
            print("[AFK] Stop + BYPASS: ON diklik")

            
            task.wait(0.5) 
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
                print("[AFK] Respawn triggered")
            end

            
            LocalPlayer.CharacterAdded:Wait()
            task.wait(1) 
            local _, bypassOnAgain = getButtons()
            click(bypassOnAgain)
            print("[AFK] BYPASS: ON diklik lagi setelah respawn")

        
            task.wait(5)
        end
    end)
end)
