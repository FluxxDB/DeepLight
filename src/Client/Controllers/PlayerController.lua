local Knit = _G.Knit

-- Services
local CharacterService
local PlayerService

-- Variables
local Player = Knit.Player
local Keys = {}

local PlayerController = Knit.CreateController {
    Name = "PlayerController";
    Keys = Keys;
}

-- Functions
local function LookForkey(KeyName)
    if next(Keys) == nil then return end
    local Key = Keys[KeyName]

    if Key and tick() >= (Key._Duration or math.huge) then
        return PlayerController.RemoveKey(KeyName)
    end

    return Key
end

function PlayerController.RemoveKey(KeyName)
    if Keys[KeyName] then
        Keys[KeyName] = nil
    end
end

function PlayerController.HasKey(KeyName)
    return LookForkey(KeyName)
end

function PlayerController.SetKey(KeyName, Duration)
    local start = tick()
    local Key = Keys[KeyName]

    if not Key then
        Key = {}
        Keys[KeyName] = Key
    end

    if Duration then
        Key._Duration = start + Duration
    end
end


function PlayerController:KnitStart()
    CharacterService = Knit.GetService("CharacterService")
    PlayerService = Knit.GetService("PlayerService")
    PlayerService.Ready:Connect(function()
        if not Player.Character then
            CharacterService.Spawn:Fire()
        end
    end)

    PlayerService.Ready:Fire()
end

return PlayerController