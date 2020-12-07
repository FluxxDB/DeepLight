local Knit = _G.Knit

-- Services
local ServerStorage = game:GetService("ServerStorage")
local PlayerProfiles

-- Require Modules
local Util = Knit.Util
local RemoteEvent = require(Util.Remote.RemoteEvent)
local Signal = require(Util.Signal)

-- Variables
local Entities = workspace:FindFirstChild("Entities")
local Characters = Entities:FindFirstChild("Characters")
local EntityStorage = ServerStorage.Entities
local Map = workspace.Map
local Spawns = {}

local CharacterService = Knit.CreateService {
    Name = "CharacterService";
	CharacterAdded = Signal.new();
    Client = {
		Spawn = RemoteEvent.new();
	};
}

local CharacterAdded = CharacterService.CharacterAdded
local Spawn = CharacterService.Client.Spawn

function CharacterService:SpawnCharacter(Player)
	local PlayerProfile = PlayerProfiles[Player]
	if not PlayerProfile or PlayerProfile:HasKey("Respawn") then return end

	local Character = Player.Character
	if Character then 
		local Humanoid = Character:WaitForChild("Humanoid", 1.5)
		if Humanoid and Humanoid.Health > 0 then return end
	end

	Character = EntityStorage.R6:Clone()
	Character.Name = Player.Name

	local Humanoid = Character:WaitForChild("Humanoid")
	local SpawnLocation = Spawns[math.random(1, #Spawns)].CFrame * CFrame.new(0, 3.5, 0)
	Humanoid.RootPart.CFrame = SpawnLocation

	Humanoid.Died:Connect(function()
		PlayerProfile:SetKey("Respawn", 5)
	end)

	Character.Parent = Characters
    Player.Character = Character
	CharacterAdded:Fire(Player, Character)
	Spawn:Fire(Player, Character)
end

function CharacterService:KnitStart()
	PlayerProfiles = Knit.Services.PlayerService.PlayerProfiles

	Spawn:Connect(function(Player)
		CharacterService:SpawnCharacter(Player)
	end)
end


function CharacterService:KnitInit()
    for Index, SpawnLocation in ipairs(Map.Spawns:GetChildren()) do
	    Spawns[Index] = SpawnLocation
    end
end


return CharacterService