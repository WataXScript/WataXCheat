
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")


local gui = Instance.new("ScreenGui")
gui.Name = "AFKGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0,120,0,50)
btn.Position = UDim2.new(0.7,0,0.1,0)
btn.Text = "START AFK"
btn.Active = true
btn.Draggable = true
btn.BackgroundColor3 = Color3.fromRGB(50,200,50)
btn.Parent = gui

local AFKMode = false
local running = false


local function findStartButton()
    local parents = {game.CoreGui, playerGui}
    for _, parent in ipairs(parents) do
        if parent then
            for _, v in pairs(parent:GetDescendants()) do
                if v:IsA("TextButton") and v.Text and v.Text:lower() == "start to end" then
                    return v
                end
            end
        end
    end
    return nil
end


local function findBypassButton(state)
    local parents = {game.CoreGui, playerGui}
    for _, parent in ipairs(parents) do
        if parent then
            for _, v in pairs(parent:GetDescendants()) do
                if v:IsA("TextButton") and v.Text and v.Text:upper() == "BYPASS: " .. state then
                    return v
                end
            end
        end
    end
    return nil
end


local VirtualInputManager
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)


local function clickButton(btnObj)
    if not btnObj then return false end
    local ok = false

    
    if type(getconnections) == "function" then
        pcall(function()
            for _, conn in pairs(getconnections(btnObj.MouseButton1Click)) do
                if conn.Function then
                    conn.Function()
                    ok = true
                end
            end
        end)
        if ok then
            print("🔘 clickButton: used getconnections() ->", btnObj.Text)
            return true
        end
    end

    
    pcall(function()
        if btnObj.Activate then
            btnObj:Activate()
            ok = true
        end
    end)
    if ok then
        print("🔘 clickButton: used :Activate() ->", btnObj.Text)
        return true
    end

    
    if VirtualInputManager then
        pcall(function()
            local absPos = btnObj.AbsolutePosition
            local absSize = btnObj.AbsoluteSize
            local x = absPos.X + absSize.X/2
            local y = absPos.Y + absSize.Y/2
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            ok = true
        end)
        if ok then
            print("🔘 clickButton: used VirtualInputManager ->", btnObj.Text)
            return true
        end
    end

    
    pcall(function()
        if btnObj.MouseButton1Click then
            btnObj.MouseButton1Click:Fire()
            ok = true
        end
    end)
    if ok then
        print("🔘 clickButton: used :Fire() ->", btnObj.Text)
        return true
    end

    print("❌ clickButton: FAILED to click ->", btnObj.Text)
    return false
end


local function respawnPlayer()
    -- 1) LoadCharacter
    local ok, err = pcall(function() player:LoadCharacter() end)
    if ok then
        print("⤴ Respawn: LoadCharacter() succeeded")
        return true
    end

    
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local success = pcall(function() humanoid.Health = 0 end)
            if success then
                print("⤴ Respawn: humanoid.Health = 0")
                return true
            end
        end
    end

    
    if char then
        local success2 = pcall(function() char:BreakJoints() end)
        if success2 then
            print("⤴ Respawn: BreakJoints() called")
            return true
        end
    end

    warn("⤴ Respawn: all methods failed")
    return false
end


local function runAFK()
    while AFKMode do
        if not running then
            running = true

            local startBtn = findStartButton()
            if not startBtn then
                warn("Start To End button not found. Retry in 3s.")
                running = false
                for i = 1, 3 do
                    if not AFKMode then break end
                    task.wait(1)
                end
                continue
            end

            
            clickButton(startBtn)

            
            local stillTime, missingTime, lastPos = 0, 0, nil
            while AFKMode do
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if hrp then
                    missingTime = 0
                    local currentPos = hrp.Position
                    if lastPos and (currentPos - lastPos).Magnitude < 0.1 then
                        stillTime = stillTime + 1
                    else
                        stillTime = 0
                    end
                    lastPos = currentPos
                else
                    missingTime = missingTime + 1
                end

                if stillTime >= 5 or missingTime >= 5 then
                    print("✅ Replay dianggap selesai")
                    break
                end
                task.wait(1)
            end

            if not AFKMode then
                running = false
                break
            end

            
            local bypassOn = findBypassButton("ON")
            if bypassOn then clickButton(bypassOn) end

            
            respawnPlayer()

            
            for i = 1, 20 do
                if not AFKMode then break end
                task.wait(1)
            end

            
            local bypassOff = findBypassButton("OFF")
            if bypassOff then clickButton(bypassOff) end

            
            local startBtn2 = findStartButton()
            if startBtn2 then clickButton(startBtn2) end

            running = false
        else
            task.wait(1)
        end
    end
    running = false
end


btn.MouseButton1Click:Connect(function()
    AFKMode = not AFKMode
    btn.Text = AFKMode and "STOP AFK" or "START AFK"

    if AFKMode then
        task.spawn(runAFK)
    else
        running = false
    end
end)
