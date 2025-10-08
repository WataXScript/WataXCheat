local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local conns = {}
local potatoEnabled = false


local function makePotato(obj)
	if obj:IsA("BasePart") then
		obj.Material = Enum.Material.Plastic
		obj.Color = Color3.fromRGB(200,200,200)
		if obj:IsA("MeshPart") then
			obj.TextureID = ""
		end
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

	
	for _, sky in pairs(game.Lighting:GetChildren()) do
		if sky:IsA("Sky") then sky:Destroy() end
	end

	
	game.Lighting.GlobalShadows = false
	game.Lighting.FogEnd = 30
	game.Lighting.FogStart = 0
	game.Lighting.Brightness = 1
	game.Lighting.ClockTime = 12
	game.Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
	game.Lighting.Ambient = Color3.fromRGB(255,255,255)

	workspace.GlobalShadows = false
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level01
end


local function resetMode()
	for _, c in pairs(conns) do
		c:Disconnect()
	end
	conns = {}
	game.Lighting.FogEnd = 1000
	game.Lighting.GlobalShadows = true
	workspace.GlobalShadows = true
end



if not potatoEnabled then
	potatoEnabled = true
	potatoMode()
	warn("Potato mode ON (Super Low)")
else
	potatoEnabled = false
	resetMode()
	warn("Potato mode OFF")
end
