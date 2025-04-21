local Players = game:GetService('Players');
local ReplicatedStorage = game:GetService('ReplicatedStorage');

local SpringService = require(ReplicatedStorage.SpringService)

local Frame = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Frame")

local tween = SpringService:Create(Frame, {
	smoothTime = 1,
	maxSpeed = math.huge,
	dt = 0.1,
}, {
	Position = UDim2.new(1, 0, 0.5, 0),
	BackgroundColor3 = Color3.fromRGB(255, 0, 0),
})

tween:Play()
