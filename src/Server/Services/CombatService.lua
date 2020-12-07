local Knit = _G.Knit

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerProfiles

-- Require Modules
local Util = Knit.Util
local RemoteEvent = require(Util.Remote.RemoteEvent)
local Thread = require(Util.Thread)

-- Variables
local Assets = ReplicatedStorage:FindFirstChild("Assets")
local Sequences = Assets.Sequences

local CombatService = Knit.CreateService {
    Name = "CombatService";
    Client = {
        CombatRemote = RemoteEvent.new();
    };
}

local Client = CombatService.Client


function CombatService:KnitStart()
    PlayerProfiles = Knit.Services.PlayerService.PlayerProfiles

    
    Client.CombatRemote:Connect(function(Player, Humanoid)
        local PlayerProfile = PlayerProfiles[Player]
        if not PlayerProfile or not PlayerProfile.Weapon.Tool or not PlayerProfile:HasKey("Attacking") then return end

        if not Humanoid or not Humanoid:IsA("Humanoid") then return end

        local AttackerCharacter = Player.Character
        if not AttackerCharacter then return end

        local AttackerHumanoid = AttackerCharacter:FindFirstChild("Humanoid")
        if not AttackerHumanoid or AttackerHumanoid.Health <= 0 then return end

        local AttackerRootPart = AttackerHumanoid.Parent:FindFirstChild("HumanoidRootPart")
        if not AttackerRootPart then return end

        local HumanoidRootPart = Humanoid.Parent:FindFirstChild("HumanoidRootPart")
        if not HumanoidRootPart then return end

        if (AttackerHumanoid.RootPart.Position - HumanoidRootPart.Position).Magnitude > 7 then return end
        
        Humanoid:TakeDamage(PlayerProfile.Attack.Damage)
        print(PlayerProfile.Attack.Damage)
    end)


end


return CombatService