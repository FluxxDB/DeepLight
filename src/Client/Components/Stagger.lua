-- Knit
local Knit = _G.Knit

-- Services
local Players = game:GetService("Players")
local Controllers = Knit.Controllers


-- Variables
local Player = Knit.Player


-- Metatable
local Stagger = {
    Tag = "Stagger";
}
Stagger.__index = Stagger

-- CONSTRUCTOR
function Stagger.new(Humanoid)    
    local self = setmetatable({
        Humanoid = Humanoid;
    }, Stagger)
    
    return self
end

-- OPTIONAL LIFECYCLE HOOKS
function Stagger:Init() --                     -> Called right after constructor
    local Object = self.Player
    if Object ~= Player then return end
end

--[[
function Stagger:Deinit() end --                   -> Called right before deconstructor
function Stagger:RenderUpdate(dt)  end --      -> Updates every render step
function Stagger:SteppedUpdate(dt)  end --     -> Updates every physics step
function Stagger:HeartbeatUpdate(dt)  end --   -> Updates every heartbeat
--]]

-- DESTRUCTOR
function Stagger:Destroy()
    local Object = self.Player
    if Object ~= Player then return end
end

return Stagger