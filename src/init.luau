local tweenService = game:GetService('TweenService');
local runService = game:GetService('RunService');

local Types = require(script.types)

local SpringService = {}
SpringService.__index = SpringService

local function AdjustProperty(object, property, value, options, velocitys, properties)
	-- Fetch target and current value
	local Type = typeof(value)
	local Current = Types[Type].ConvertFrom(object[property])
	local Target = Types[Type].ConvertFrom(value)

	-- Compute new value
	local newValue, newVelocity =
		tweenService:SmoothDamp(Current, Target, velocitys[property], options.smoothTime, options.maxSpeed, options.dt)

	-- Appply
	velocitys[property] = newVelocity
	object[property] = Types[Type].ConvertTo(newValue)

	-- Check if this is resolved
	if object[property] == value then
		properties[property] = nil
	end
end
local function AdjustMultivariableProperty(object, property, value, options, velocitys, properties)
	-- Fetch target and current value
	local Type = typeof(value)
	local Current = Types[Type].ConvertFrom(object[property])
	local Target = Types[Type].ConvertFrom(value)

	-- Compute new value
	local resolved = true
	local newValues = {}
	for v = 1, #velocitys[property] do
		local newValue, newVelocity = tweenService:SmoothDamp(
			Current[v],
			Target[v],
			velocitys[property][v],
			options.smoothTime,
			options.maxSpeed,
			options.dt
		)
		velocitys[property][v] = newVelocity

		newValues[v] = newValue
	end

	-- Apply
	object[property] = Types[Type].ConvertTo(newValues)

	if object[property] ~= value then
		resolved = false
	end

	-- Check if this is resolved
	if resolved then
		properties[property] = nil
	end
end

-- API
function SpringService:Create(object, options, properties)
	local velocitys = {}
	for property, value in properties do
		if not Types[typeof(value)] then
			error(`SpringService: Type {typeof(value)} is not supported`)
		end
		velocitys[property] = Types[typeof(value)].InitialVelocity
	end

	local event
	event = runService.Heartbeat:Connect(function()
		for property, value in properties do
			if typeof(velocitys[property]) == "table" then -- Multivariable
				AdjustMultivariableProperty(object, property, value, options, velocitys, properties)
			else -- Single variable
				AdjustProperty(object, property, value, options, velocitys, properties)
			end
		end
	end)

	return event
end

return SpringService
