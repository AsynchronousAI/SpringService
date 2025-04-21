local Players = game:GetService('Players');
local ReplicatedStorage = game:GetService('ReplicatedStorage');

local SpringService = require(ReplicatedStorage.SpringService)

local Frame = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Frame2")

local tween = SpringService:Create(Frame.UIGradient, {
	smoothTime = 10,
	maxSpeed = 1,
	dt = 0.1,
}, {
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	}),
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 128)),
	}),
})

tween:Play()
