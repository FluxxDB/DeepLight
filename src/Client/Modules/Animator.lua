-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Variables
local Assets = ReplicatedStorage.Assets
local Stances = Assets.Stances

-- Animator Class
local Animator = {}
Animator.__index = Animator

function Animator.new(Character)
	if not Character or not Character.Parent then return end

	local Humanoid = Character:WaitForChild("Humanoid")
	if not Humanoid or Humanoid.Health == 0 then return end

	local Stance = Character:WaitForChild("Stance")
	if not Stance then return end

	local self = setmetatable({
		Character	= Character;
		Humanoid	= Humanoid;
		HRP			= Humanoid.RootPart;

		Stance		= Stance.Value;

		Animations = {}
	}, Animator)


	for _, Animation in ipairs(self.Stance:GetChildren()) do
		self:LoadAnimation(Animation)
	end

	return self
end

function Animator:Get(AnimationObject)
	local Animation = self.Animations[AnimationObject]
	if not Animation then return end

	return Animation
end

function Animator:Play(Animation)
	if Animation:IsA("Animation") then
		Animation = self:Get(Animation)
	end
	if Animation.IsPlaying then return end
	Animation:Play()
end

function Animator:Stop(Animation)
	if Animation:IsA("Animation") then
		Animation = self:Get(Animation)
	end
	if not Animation or not Animation.IsPlaying then return end
	Animation:Stop()
end

function Animator:StopAll()
	for _, AnimationTrack in ipairs(self.Humanoid:GetPlayingAnimationTracks()) do
		AnimationTrack:Stop()
	end
end

function Animator:LoadAnimation(Animation)
	if not Animation then return end
	if self.Animations[Animation] then return self.Animations[Animation] end
	local AnimationTrack = self.Humanoid:LoadAnimation(Animation)
	self.Animations[Animation] = AnimationTrack
	return AnimationTrack
end

function Animator:SetStance(NewStance)
	if self.Stance == NewStance then return end
	local OldStance = self.Stance
	self.Stance = NewStance

	for _, Animation in pairs(OldStance:GetChildren()) do
		self:Stop(Animation)
	end

	for _, Animation in ipairs(self.Stance:GetChildren()) do
		self:LoadAnimation(Animation)
	end
end

function Animator:UpdateMovement(OldState, NewState)
	if NewState == Enum.HumanoidStateType.Jumping then
		for _, Animation in pairs(self.Stance:GetChildren()) do
			self:Stop(Animation)
		end

		local Animation = self:LoadAnimation(self.Stance:FindFirstChild("Jump"))
		if not Animation.IsPlaying then
			Animation:Play(0.05, 1, 2)
		end
	end
end

function Animator:Update()
	local OnAir = self.Humanoid.FloorMaterial == Enum.Material.Air
	if OnAir then
		self:Stop(self.Stance:FindFirstChild("Walk"))
		self:Stop(self.Stance:FindFirstChild("Idle"))

		local Animation = self:LoadAnimation(self.Stance:FindFirstChild("Fall"))
		if not Animation.IsPlaying then
			Animation:Play(0.25, 1, 1)
		end
	else
		self:Stop(self.Stance:FindFirstChild("Fall"))

		local Velocity = self.HRP.CFrame:VectorToObjectSpace(Vector3.new(self.HRP.Velocity.X, 0, self.HRP.Velocity.Z))
		local Speed = Velocity.Magnitude

		if Speed < 1 then
			local Animation = self.Stance:FindFirstChild("Idle")
			local Walk = self.Stance:FindFirstChild("Walk")
			self:Stop(Walk)
			self:Play(Animation)
		else
			local Animation = self.Stance:FindFirstChild("Walk")
			local Idle = self.Stance:FindFirstChild("Idle")
			self:Stop(Idle)
			self:Play(Animation)
		end
	end
end

return Animator