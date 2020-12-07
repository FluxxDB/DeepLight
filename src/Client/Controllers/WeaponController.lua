local Knit = _G.Knit

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService("RunService")
local CharacterController
local PlayerController
local CombatService

-- Require Modules
local Util = Knit.Util
local Thread = require(Util.Thread)
local RaycastHitbox = require(ReplicatedStorage.Assets.RaycastHitboxV3)

-- Variables
local Player = Knit.Player
local Assets = ReplicatedStorage.Assets
local Sequences = Assets.Sequences
local Stances = Assets.Stances
local LastUpdate = os.time()
local Index = 1

local WeaponController = Knit.CreateController { Name = "WeaponController" }


function WeaponController:KnitStart()
    CharacterController = Knit.Controllers.CharacterController
    PlayerController = Knit.Controllers.PlayerController
    CombatService = Knit.GetService("CombatService")

    Player.CharacterAdded:Connect(function(Character)
        local Activated
        Character.ChildAdded:Connect(function(Tool)
            if not Tool:IsA("Tool") or not Tool:FindFirstChild("Model") then return end
            local Model = Tool:FindFirstChild("Model").Value
            local Weapon = Character:FindFirstChild("Items"):WaitForChild(Model.Name, 1)
            local Animator = CharacterController.Animators[Character]
            Animator:SetStance(Stances:FindFirstChild(Model.Name))

            local Hitbox = RaycastHitbox:Initialize(Weapon, {Character})
            --Hitbox:LinkAttachments(Weapon:FindFirstChild("Link1"), Weapon:FindFirstChild("Link2"))
            Hitbox:DebugMode(RunService:IsStudio())

            Activated = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                if GameProcessed or Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

                if PlayerController.HasKey("Attacking") then return end
                PlayerController.SetKey("Attacking")
                Tool:Activate()

                local WeaponSequences = Sequences:FindFirstChild(Model.Name)
                if not WeaponSequences then warn"No Weapon Sequence Found." return end

                local AnimationObject = WeaponSequences:FindFirstChild(tostring(Index))
                if not AnimationObject then warn"No Animation Object Found." return end

                local Cooldown = AnimationObject.Cooldown.Value
                local Length = AnimationObject.Length.Value
                if os.clock() - LastUpdate > 0.5 + Length then
                    Index = 1
                    AnimationObject = WeaponSequences:FindFirstChild(tostring(Index))
                    Cooldown = AnimationObject.Cooldown.Value
                    Length = AnimationObject.Length.Value
                end

                local Track = Animator:LoadAnimation(AnimationObject)
                Animator:Play(Track)
                LastUpdate = os.clock()

                local HitboxStart = Track:GetMarkerReachedSignal("HitboxStart"):Connect(function()
                    Hitbox:HitStart()
                end)

                Track.Stopped:Connect(function()
                    Hitbox:HitStop()
                    Track:Destroy()
                end)

                Hitbox.OnHit:Connect(function(Hit, Humanoid)
                    CombatService.CombatRemote:Fire(Humanoid)
                end)

                if WeaponSequences:FindFirstChild(tostring(Index + 1)) then
                    Index = Index + 1
                else
                    Index = 1
                end

                Thread.Delay(Cooldown + Length, function()
                    PlayerController.RemoveKey("Attacking")
                    HitboxStart:Disconnect()
                end)
            end)
        end)

        Character.ChildRemoved:Connect(function(Tool)
            if not Tool:IsA("Tool") or not Tool:FindFirstChild("Model") then return end
            local Model = Tool:FindFirstChild("Model").Value
            local Weapon = Character:FindFirstChild("Items"):FindFirstChild(Model.Name)
            local Animator = CharacterController.Animators[Character]
            RaycastHitbox:Deinitialize(Weapon)
            Animator:StopAll()
            Animator:SetStance(Stances:FindFirstChild("Default"))
            Activated:Disconnect()
            Index = 1
        end)
    end)
end


function WeaponController:KnitInit()

end


return WeaponController