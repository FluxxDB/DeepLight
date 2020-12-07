local Knit = _G.Knit

-- Services
local Players = game:GetService("Players")

-- Require Modules
local Util = Knit.Util
local Modules = Knit.Modules
local PlayerData = require(Modules.PlayerData)
local RemoteEvent = require(Util.Remote.RemoteEvent)

local PlayerService = Knit.CreateService {
    Name = "PlayerService";
    PlayerProfiles = {};
    Client = {
        Ready = RemoteEvent.new();
    };
}

local Client = PlayerService.Client
local PlayerProfiles = PlayerService.PlayerProfiles

function PlayerService:KnitStart()
    Client.Ready:Connect(function(Player)
        local PlayerProfile = PlayerData.new(Player)
        PlayerProfiles[Player] = PlayerProfile

        Client.Ready:Fire(Player, PlayerProfile)
    end)
end


function PlayerService:KnitInit()
    Players.PlayerRemoving:Connect(function(Player)
        PlayerProfiles[Player] = nil
    end)
end


return PlayerService