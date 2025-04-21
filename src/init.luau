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
	Instance: Instance,
	PlaybackState: Enum.PlaybackState,

	Stop: (Tween) -> (),
	Resume: (Tween) -> (),
	Play: (Tween) -> (),
	Destroy: (Tween) -> (),
	PlayYield: (Tween) -> (),
	ResumeYield: (Tween) -> (),
}
type SpringService = {
	Create: (object: Instance, options: Options, properties: { [string]: any }) -> Tween,
}

-- Global
_G.ActiveTweens = {}

-- Functions
local function Round(Value)
	if typeof(Value) == "number" then
		return math.floor(Value * 1000) / 1000
	elseif typeof(Value) == "Vector3" then
		return Vector3.new(
			math.floor(Value.X * 1000) / 1000,
			math.floor(Value.Y * 1000) / 1000,
			math.floor(Value.Z * 1000) / 1000
		)
	elseif typeof(Value) == "CFrame" then
		local cframeTable = table.pack(Value:GetComponents())
		for i, v in pairs(cframeTable) do
			cframeTable[i] = math.floor(v * 1000) / 1000
		end
		return CFrame.new(table.unpack(cframeTable))
	else
		error("Unroundable result")
	end
end
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
	object[property] = Types[Type].ConvertTo(Round(newValue))

	-- Check if this is resolved
	if object[property] == value then
		properties[property] = nil
	end
end
local function AdjustMultivariableProperty(object, property, value, options, velocitys, properties, additionalData)
	-- Fetch target and current value
	local Type = typeof(value)
	local Current = Types[Type].ConvertFrom(object[property], additionalData)
	local Target = Types[Type].ConvertFrom(value, additionalData)

	-- Compute new value
	local newValues = {}
	for v = 1, #velocitys[property] do
		local newValue, newVelocity = tweenService:SmoothDamp(
			Current[v],
			Target[v],
			velocitys[property][v],
			options.smoothTime or error("SmoothTime is required"),
			options.maxSpeed or math.huge,
			options.dt or error("dt is required")
		)
		velocitys[property][v] = newVelocity

		newValues[v] = Round(newValue)
	end

	-- Apply
	object[property] = Types[Type].ConvertTo(newValues, additionalData)

	if object[property] == value then
		properties[property] = nil
	end
end

-- API
function SpringService:Create(object: Instance, options: Options, properties: { [string]: any }): Tween
	-- Inialize
	local velocitys = {}
	local initalProperties = {}
	local additionalData = {}
	for property, value in properties do
		if not Types[typeof(value)] then
			error(`SpringService: Type {typeof(value)} is not supported`)
		end

		local Velocity = Types[typeof(value)].InitialVelocity
		if typeof(Velocity) == "function" then
			local newAdditionalData
			Velocity, newAdditionalData = Velocity(object[property], value)

			additionalData[property] = newAdditionalData
		end

		velocitys[property] = Velocity
		initalProperties[property] = object[property]
	end

	-- Create
	local Data: Tween = {
		Instance = object,
		Event = nil,
		PlaybackState = Enum.PlaybackState.Begin,
		Destroy = function(this) -- Clean up
			if this.Event == nil then
				return
			end

			this.Event:Disconnect()
			this.Event = nil
			this.PlaybackState = Enum.PlaybackState.Cancelled
		end,
		Resume = function(this) -- Play tween from current position
			this.PlaybackState = Enum.PlaybackState.Playing
		end,
		Stop = function(this) -- Stop tween
			this.PlaybackState = Enum.PlaybackState.Paused
		end,
		Play = function(this) -- Play from start
			for property, _ in properties do
				this.Instance[property] = initalProperties[property]
			end
			this.PlaybackState = Enum.PlaybackState.Playing
		end,
		PlayYield = function(this) -- Play and wait for completion
			this:Play()
			while this.PlaybackState == Enum.PlaybackState.Playing do
				task.wait()
			end
		end,
		ResumeYield = function(this) -- Resume and wait for completion
			this:Resume()
			while this.PlaybackState == Enum.PlaybackState.Playing do
				task.wait()
			end
		end,
	}

	-- Avoid tween stacking
	if _G.ActiveTweens[object] then
		_G.ActiveTweens[object]:Destroy()
	end
	_G.ActiveTweens[object] = Data

	-- Create event
	Data.Event = runService[options.stepType or "Stepped"]:Connect(function()
		if Data.PlaybackState ~= Enum.PlaybackState.Playing then
			return
		end

		-- Check if tween is resolved
		if next(properties) == nil then
			Data:Destroy()
			return
		end

		-- Run animations
		for property, value in properties do
			if typeof(velocitys[property]) == "table" then -- Multivariable
				AdjustMultivariableProperty(
					object,
					property,
					value,
					options,
					velocitys,
					properties,
					additionalData[property]
				)
			else -- Single variable
				AdjustProperty(object, property, value, options, velocitys, properties)
			end
		end
	end)

	return Data
end

return SpringService
