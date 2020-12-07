local PlayerData = {}
PlayerData.__index = PlayerData


function PlayerData.new(Player)
    local self = setmetatable({
        _Player = Player;

        Weapon = {
            Sequences   = nil;
            Tool        = nil;
        };

        Attack = {
            Index       = 1;
            Damage      = 0;
            Hits        = {};
            LastUpdate  = os.clock();
        };

        Keys = {};
    }, PlayerData)
    return self
end


function PlayerData:_LookForkey(KeyName)
    local Keys = self.Keys
    if next(Keys) == nil then return end
    local Key = Keys[KeyName]

    if Key and tick() >= (Key._Duration or math.huge) then
        return self:RemoveKey(KeyName)
    end

    return Key
end

function PlayerData:RemoveKey(KeyName)
    self.Keys[KeyName] = nil
end

function PlayerData:HasKey(KeyName)
    return self:_LookForkey(KeyName)
end

function PlayerData:SetKey(KeyName, Duration)
    local start = tick()
    local Keys = self.Keys
    local Key = Keys[KeyName]

    if not Key then
        Key = {}
        Keys[KeyName] = Key
    end

    if Duration then
        Key._Duration = start + Duration
    end
end

return PlayerData