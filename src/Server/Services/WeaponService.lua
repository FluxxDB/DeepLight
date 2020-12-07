local Knit = _G.Knit

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenSerivce = game:GetService("TweenService")
local CharacterService, PlayerProfiles

-- Require Modules
local Util = Knit.Util
local Thread = require(Util.Thread)

-- Variables
local Effects = workspace.Effects
local Assets = ReplicatedStorage.Assets
local Sequences = Assets.Sequences

local WeaponService = Knit.CreateService {
    Name = "WeaponService";
    Client = {};
}

-- Functions
local function JointAttachments(attach1, attach2)
	local Joint = Instance.new("Motor6D")
	Joint.Part0 = attach1.Parent
	Joint.Part1 = attach2.Parent
	Joint.C0 = attach1.CFrame
	Joint.C1 = attach2.CFrame
	Joint.Parent = attach2.Parent
	return Joint
end

function WeaponService:KnitStart()
    CharacterService = Knit.Services.CharacterService
    PlayerProfiles = Knit.Services.PlayerService.PlayerProfiles

    CharacterService.CharacterAdded:Connect(function(Player, Character)
        Character.ChildAdded:Connect(function(Tool)
            if not Tool:IsA("Tool") or not Tool:FindFirstChild("Model") then return end
            local PlayerProfile = PlayerProfiles[Player]
            if not PlayerProfile then
                Tool.Parent = Player.Backpack
                return
            end
			PlayerProfile.Weapon.Tool = Tool

			local Sequence = Sequences:FindFirstChild(Tool.Model.Value.Name)
			PlayerProfile.Weapon.Sequences = Sequence

			Tool.Activated:Connect(function()
				if PlayerProfile:HasKey(Tool.Name .. "Activation") or PlayerProfile:HasKey("Attacking") then return end
				PlayerProfile:SetKey(Tool.Name .. "Activation", 0.1)
                PlayerProfile:SetKey("Attacking")

				local AttackObject = PlayerProfile.Attack
                local AnimationObject = Sequence:FindFirstChild(tostring(AttackObject.Index))
                if not AnimationObject then warn"No Animation Object Found." return end

                local Cooldown = AnimationObject.Cooldown.Value
                local Length = AnimationObject.Length.Value
                if os.clock() - AttackObject.LastUpdate > 0.5 + Length then
                    AttackObject.Index = 1
                    AnimationObject = Sequence:FindFirstChild(tostring(AttackObject.Index))
                    Cooldown = AnimationObject.Cooldown.Value
                    Length = AnimationObject.Length.Value
				end

				AttackObject.Damage = AnimationObject.Damage.Value
				AttackObject.LastUpdate = os.clock()

				if Sequence:FindFirstChild(tostring(AttackObject.Index + 1)) then
                    AttackObject.Index = AttackObject.Index + 1
                else
                    AttackObject.Index = 1
                end

				Thread.Delay(Cooldown + Length, function()
                    PlayerProfile:RemoveKey("Attacking")
                end)
			end)

			local Model = Tool.Model.Value
			local Grips = {}
			for _, Attachment in ipairs(Model:GetChildren()) do
				local Limb = Attachment:FindFirstChild("Limb")
				if Limb then
					Grips[Attachment.Name] = Limb.Value
				end
			end
			for Grip, Limb in pairs(Grips) do
				local Weapon = Model:Clone()
				Weapon.Parent = Character.Items
				JointAttachments(Character:FindFirstChild(Limb):FindFirstChild(Grip), Weapon:FindFirstChild(Grip))


				for _, Part in ipairs(Weapon:GetDescendants()) do
					if Part:IsA("Part") or Part:IsA("MeshPart") then
						local Goal = {}
						Goal.Transparency = 0
						local Tween = TweenSerivce:Create(Part, TweenInfo.new(0.3), Goal)
						Tween:Play()
					end
				end
				if Weapon:IsA("Part") or Weapon:IsA("MeshPart") then
					local Goal = {}
					Goal.Transparency = 0
					local Tween = TweenSerivce:Create(Weapon, TweenInfo.new(0.3), Goal)
					Tween:Play()
				end

				local EquipSound = Weapon:FindFirstChild("Equip")
				if not EquipSound then warn("Equip Sound Not Found") return end
				EquipSound:Play()
			end
		end)

		Character.ChildRemoved:Connect(function(Tool)
            if not Tool:IsA("Tool") or not Tool:FindFirstChild("Model") then return end
            local PlayerProfile = PlayerProfiles[Player]
            if not PlayerProfile then
                Tool.Parent = Player.Backpack
                return
            end
			PlayerProfile.Weapon.Tool = nil
			PlayerProfile.Weapon.Sequences = nil

			local Model = Tool.Model.Value
			for _, Weapon in ipairs(Character.Items:GetChildren()) do
				if Weapon.Name == Model.Name then
					local Joint = Weapon:FindFirstChildOfClass("Motor6D")
					Joint:Destroy()
					Weapon.Anchored = true
					Weapon.Parent = Effects
					Weapon.Transparency = 1

					for _, Part in ipairs(Weapon:GetChildren()) do
						if Part:IsA("Part") or Part:IsA("MeshPart") then
							Part.Transparency = 1
						end
					end

					local DestroySound = Weapon:FindFirstChild("Destroy")
					if DestroySound then
						DestroySound:Play()
					end

					local Break = Weapon:FindFirstChild("Break", true)
					Break:Emit(Break.Rate)

					delay(2, function()
						Weapon:Destroy()
					end)
				end
            end
        end)
    end)
end


function WeaponService:KnitInit()

end


return WeaponService