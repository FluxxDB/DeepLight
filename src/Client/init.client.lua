local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Knit"))

local ControllersToLoad = {
    "PlayerController";
    "CharacterController";
    "WeaponController";
}

for _, Name in ipairs(ControllersToLoad) do
    local Module = script.Controllers:WaitForChild(Name, 5)

    if Module then
        require(Module)
    end
end

local Components = script:WaitForChild("Components", 5)
if Components then
    require(Knit.Util.Component).Auto(Components)
end

ReplicatedStorage:WaitForChild("Loaded", 60)

Knit.Start():andThen(function()
    print("[Knit Client]: Started")
end):catch(function(err)
    warn("[Knit Client]: Failed to initialize")
    warn(tostring(err))
end)