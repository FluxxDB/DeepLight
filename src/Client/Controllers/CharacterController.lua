local Knit = _G.Knit

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterService

-- Variables
local Camera = workspace.CurrentCamera
local AnimatorClass = require(Knit.Modules.Animator)
local Animators = {}

local CharacterController = Knit.CreateController { 
    Name = "CharacterController";
    Animators = Animators;
}


function CharacterController:KnitStart()
    CharacterService = Knit.GetService("CharacterService")

    CharacterService.Spawn:Connect(function(Character)
        local Animator = AnimatorClass.new(Character)
        Animators[Character] = Animator
        Animator.Humanoid.Died:Connect(function()
            Animators[Character] = nil
        end)

        Animator.Humanoid.StateChanged:Connect(function(OldState, NewState)
            Animator:UpdateMovement(OldState, NewState)
        end)

        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = Character.Humanoid

        while wait(1/14) do
            Animator:Update()
        end
    end)
end


function CharacterController:KnitInit()

end


return CharacterController