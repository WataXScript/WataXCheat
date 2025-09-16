

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local potatoEnabled = false
local hidePlayers = false
local conns = {}


local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "PotatoUI"
gui.ResetOnSpawn = false 


local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)


local potatoBtn = Instance.new("TextButton", frame)
potatoBtn.Size = UDim2.new(1, -20, 0, 40)
potatoBtn.Position = UDim2.new(0, 10, 0, 10)
potatoBtn.Text = "Potato: OFF"
potatoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
potatoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
potatoBtn.Font = Enum.Font.SourceSansBold
potatoBtn.TextSize = 20
Instance.new("UICorner", potatoBtn)


local hideBtn = Instance.new("TextButton", frame)
hideBtn.Size = UDim2.new(1, -20, 0, 40)
hideBtn.Position = UDim2.new(0, 10, 0, 50)
hideBtn.Text = "Hide Players: OFF"
hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.Font = Enum.Font.SourceSansBold
hideBtn.TextSize = 20
Instance.new("UICorner", hideBtn)


local function makePotato(obj)
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Color = Color3.fromRGB(200,200,200)
        if obj:IsA("MeshPart") then
            obj.TextureID = ""
        end
    elseif obj:IsA("SpecialMesh") then
        obj.TextureId = ""
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") 
        or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Beam") 
        or obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("Sound") then
        obj:Stop()
        obj.Volume = 0
    end
end


local function potatoMode()
    for _, obj in pairs(workspace:GetDescendants()) do
        makePotato(obj)
    end
    table.insert(conns, workspace.DescendantAdded:Connect(makePotato))

    
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    settings().Rendering.ShadowSoftness = 0
    workspace.GlobalShadows = false
    game.Lighting.GlobalShadows = false
    game.Lighting.FogEnd = 9e9
    game.Lighting.Brightness = 1
    game.Lighting.ClockTime = 14
    game.Lighting.Ambient = Color3.fromRGB(255,255,255)
end


local function resetMode()
    for _, c in pairs(conns) do
        c:Disconnect()
    end
    conns = {}
    workspace.GlobalShadows = true
    game.Lighting.GlobalShadows = true
    game.Lighting.FogEnd = 1000
end


local function hidePlayersMode()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            plr.Character:Destroy()
        end
    end
    table.insert(conns, Players.PlayerAdded:Connect(function(plr)
        table.insert(conns, plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            char:Destroy()
        end))
    end))
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= lp then
            table.insert(conns, plr.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                char:Destroy()
            end))
        end
    end
end


potatoBtn.MouseButton1Click:Connect(function()
    potatoEnabled = not potatoEnabled
    if potatoEnabled then
        potatoBtn.Text = "Potato: ON"
        potatoMode()
    else
        potatoBtn.Text = "Potato: OFF"
        resetMode()
    end
end)


hideBtn.MouseButton1Click:Connect(function()
    hidePlayers = not hidePlayers
    if hidePlayers then
        hideBtn.Text = "Hide Players: ON"
        hidePlayersMode()
    else
        hideBtn.Text = "Hide Players: OFF"
    end
end)


lp.CharacterAdded:Connect(function()
    task.wait(1)
    if potatoEnabled then potatoMode() end
    if hidePlayers then hidePlayersMode() end
end)
