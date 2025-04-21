local ReplicatedStorage = game:GetService('ReplicatedStorage');

local SpringService = require(ReplicatedStorage.SpringService)

local tween = SpringService:Create(workspace:WaitForChild("Part"), {
	smoothTime = 10,
	maxSpeed = math.huge,
	dt = 0.1,
}, {
	Position = Vector3.new(20, 5, -30),
	Color = Color3.fromRGB(255, 0, 0),
})

tween:Play()
