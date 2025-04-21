local tweenService = game:GetService('TweenService');
local runService = game:GetService('RunService');

local Types = require(script.types)

local SpringService = {}
SpringService.__index = SpringService

-- Types
type Options = {
	smoothTime: number,
	maxSpeed: number,
	dt: number,
	stepType: Enum.RenderPriority?,
}
type Tween = {
	Event: RBXScriptConnection,
	Stop: () -> (),
	Resume: () -> (),
	Play: () -> (),
}
type SpringService = {
	Create: (object: Instance, options: Options, properties: { [string]: any }) -> Tween,
}

-- Functions
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
function SpringService:Create(object: Instance, options: Options, properties: { [string]: any }): Tween
	local velocitys = {}
	local initalProperties = {}
	for property, value in properties do
		if not Types[typeof(value)] then
			error(`SpringService: Type {typeof(value)} is not supported`)
		end
		velocitys[property] = Types[typeof(value)].InitialVelocity
		initalProperties[property] = object[property]
	end

	-- Create event
	local event
	local active = false
	event = runService[options.stepType or "Stepped"]:Connect(function()
		if not active then
			return
		end

		for property, value in properties do
			if typeof(velocitys[property]) == "table" then -- Multivariable
				AdjustMultivariableProperty(object, property, value, options, velocitys, properties)
			else -- Single variable
				AdjustProperty(object, property, value, options, velocitys, properties)
			end
		end
	end)

	return {
		Event = event,
		Destroy = function() -- Clean up
			event:Disconnect()
		end,
		Resume = function() -- Play tween from current position
			active = true
		end,
		Stop = function() -- Stop tween
			active = false
		end,
		Play = function() -- Play from start
			for property, _ in properties do
				object[property] = initalProperties[property]
			end
			active = true
		end,
	}
end

return SpringService
