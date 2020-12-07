local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Knit"))

local ServicesToLoad = {
    "CharacterService";
    "PlayerService";
    "WeaponService";
    "CombatService";
}

for _, Name in ipairs(ServicesToLoad) do
    local Module = script.Services:FindFirstChild(Name)

    if Module then
        require(Module)
    end
end

local Components = script:FindFirstChild("Components")
if Components then
    require(Knit.Util.Component).Auto(Components)
end

Knit.Start():andThen(function()
    print("[Knit Server]: Started")
    
    local Loaded = Instance.new("BoolValue")
    Loaded.Name = "Loaded"
    Loaded.Parent = ReplicatedStorage
end):catch(function(err)
    warn("[Knit Server]: Failed to initialize")
    warn(tostring(err))
end)