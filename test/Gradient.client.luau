local Players = game:GetService('Players');
local ReplicatedStorage = game:GetService('ReplicatedStorage');

local SpringService = require(ReplicatedStorage.SpringService)

local Frame = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Frame2")

local tween = SpringService:Create(Frame.UIGradient, {
	smoothTime = 1,
	maxSpeed = math.huge,
	dt = 0.1,
}, {
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	}),
})

tween:Play()
