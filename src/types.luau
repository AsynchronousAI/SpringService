-- Types
type TypeHandler<A, B> = {
	InitialVelocity: A,
	ConvertTo: (A, any) -> B,
	ConvertFrom: (B, any) -> A,
}

-- Function
local function evalNumberSequence(sequence: NumberSequence, time: number)
	-- If time is 0 or 1, return the first or last value respectively
	if time == 0 then
		return sequence.Keypoints[1].Value
	elseif time == 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	-- Otherwise, step through each sequential pair of keypoints
	for i = 1, #sequence.Keypoints - 1 do
		local currKeypoint = sequence.Keypoints[i]
		local nextKeypoint = sequence.Keypoints[i + 1]
		if time >= currKeypoint.Time and time < nextKeypoint.Time then
			-- Calculate how far alpha lies between the points
			local alpha = (time - currKeypoint.Time) / (nextKeypoint.Time - currKeypoint.Time)
			-- Return the value between the points using alpha
			return currKeypoint.Value + (nextKeypoint.Value - currKeypoint.Value) * alpha
		end
	end
end
local function evalColorSequence(sequence: ColorSequence, time: number)
	-- If time is 0 or 1, return the first or last value respectively
	if time == 0 then
		return sequence.Keypoints[1].Value
	elseif time == 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	-- Otherwise, step through each sequential pair of keypoints
	for i = 1, #sequence.Keypoints - 1 do
		local thisKeypoint = sequence.Keypoints[i]
		local nextKeypoint = sequence.Keypoints[i + 1]
		if time >= thisKeypoint.Time and time < nextKeypoint.Time then
			-- Calculate how far alpha lies between the points
			local alpha = (time - thisKeypoint.Time) / (nextKeypoint.Time - thisKeypoint.Time)
			-- Evaluate the real value between the points using alpha
			return Color3.new(
				(nextKeypoint.Value.R - thisKeypoint.Value.R) * alpha + thisKeypoint.Value.R,
				(nextKeypoint.Value.G - thisKeypoint.Value.G) * alpha + thisKeypoint.Value.G,
				(nextKeypoint.Value.B - thisKeypoint.Value.B) * alpha + thisKeypoint.Value.B
			)
		end
	end
end

-- Return
return {
	--# Default
	["number"] = {
		InitialVelocity = 0,
		ConvertTo = function(value)
			return value
		end,
		ConvertFrom = function(value)
			return value
		end,
	},
	["Vector3"] = {
		InitialVelocity = Vector3.zero,
		ConvertTo = function(value)
			return value
		end,
		ConvertFrom = function(value)
			return value
		end,
	},
	["CFrame"] = {
		InitialVelocity = CFrame.new(Vector3.zero),
		ConvertTo = function(value)
			return value
		end,
		ConvertFrom = function(value)
			return value
		end,
	},

	--# Simple conversion
	["Color3"] = {
		InitialVelocity = Vector3.zero,
		ConvertTo = function(value)
			return Color3.new(value.X, value.Y, value.Z)
		end,
		ConvertFrom = function(value)
			return Vector3.new(value.R, value.G, value.B)
		end,
	},
	["Vector2"] = {
		InitialVelocity = Vector3.zero,
		ConvertTo = function(value)
			return Vector2.new(value.X, value.Y)
		end,
		ConvertFrom = function(value)
			return Vector3.new(value.X, value.Y, 0)
		end,
	},
	["UDim"] = {
		InitialVelocity = Vector3.zero,
		ConvertTo = function(value)
			return UDim.new(value.X, value.Y)
		end,
		ConvertFrom = function(value)
			return Vector3.new(value.Scale, value.Offset, 0)
		end,
	},
	["Vector2int16"] = {
		InitialVelocity = Vector3.zero,
		ConvertTo = function(value)
			return Vector2int16.new(value.X, value.Y)
		end,
		ConvertFrom = function(value)
			return Vector3.new(value.X, value.Y, 0)
		end,
	},
	["Vector3int16"] = {
		InitialVelocity = Vector3.zero,
		ConvertTo = function(value)
			return Vector3int16.new(value.X, value.Y, value.Z)
		end,
		ConvertFrom = function(value)
			return Vector3.new(value.X, value.Y, value.Z)
		end,
	},

	--# Multivariable conversion
	["UDim2"] = {
		InitialVelocity = { Vector3.zero, Vector3.zero },
		ConvertTo = function(values)
			return UDim2.new(values[1].X, values[2].X, values[1].Y, values[2].Y)
		end,
		ConvertFrom = function(value)
			return { Vector3.new(value.X.Scale, value.Y.Scale, 0), Vector3.new(value.X.Offset, value.Y.Offset, 0) }
		end,
	},
	["Rect"] = {
		InitialVelocity = { Vector3.zero, Vector3.zero },
		ConvertTo = function(values)
			return Rect.new(values[1].X, values[1].Y, values[2].X, values[2].Y)
		end,
		ConvertFrom = function(value)
			return { Vector3.new(value.Min.X, value.Min.Y, 0), Vector3.new(value.Max.X, value.Max.Y, 0) }
		end,
	},

	--# Functions
	["NumberSequence"] = {
		InitialVelocity = function(A, B)
			-- Collect all times we will tween off
			local allTimes = {}
			for _, keypoint in A.Keypoints do
				table.insert(allTimes, keypoint.Time)
			end
			for _, keypoint in B.Keypoints do
				table.insert(allTimes, keypoint.Time)
			end

			-- Remove duplicates
			local uniqueTimes = {}
			for _, time in ipairs(allTimes) do
				if not table.find(uniqueTimes, time) then
					table.insert(uniqueTimes, time)
				end
			end

			-- Turn into a table of velocities
			local velocities = {}
			local times = {}
			for _, time in ipairs(uniqueTimes) do
				table.insert(velocities, 0)
				table.insert(times, time)
			end

			return velocities, times
		end,

		ConvertTo = function(sequence, times)
			local keypoints = {}
			for index, time in times do
				table.insert(keypoints, NumberSequenceKeypoint.new(time, sequence[index]))
			end

			return NumberSequence.new(keypoints)
		end,

		ConvertFrom = function(sequence, times)
			local keypoints = {}
			for _, time in times do
				local keypoint = evalNumberSequence(sequence, time)
				table.insert(keypoints, keypoint)
			end

			return keypoints
		end,
	},
	["ColorSequence"] = {
		InitialVelocity = function(A, B)
			-- Collect all times we will tween off
			local allTimes = {}
			for _, keypoint in A.Keypoints do
				table.insert(allTimes, keypoint.Time)
			end
			for _, keypoint in B.Keypoints do
				table.insert(allTimes, keypoint.Time)
			end

			-- Remove duplicates
			local uniqueTimes = {}
			for _, time in ipairs(allTimes) do
				if not table.find(uniqueTimes, time) then
					table.insert(uniqueTimes, time)
				end
			end

			-- Turn into a table of velocities
			local velocities = {}
			local times = {}
			for _, time in ipairs(uniqueTimes) do
				table.insert(velocities, Vector3.new(0, 0, 0))
				table.insert(times, time)
			end

			return velocities, times
		end,

		ConvertTo = function(sequence, times)
			local keypoints = {}
			for index, time in times do
				local keypoint = sequence[index]
				local asColor = Color3.new(keypoint.X, keypoint.Y, keypoint.Z)
				table.insert(keypoints, ColorSequenceKeypoint.new(time, asColor))
			end

			return ColorSequence.new(keypoints)
		end,

		ConvertFrom = function(sequence, times)
			local keypoints = {}
			for _, time in times do
				local keypoint = evalColorSequence(sequence, time)
				table.insert(keypoints, Vector3.new(keypoint.R, keypoint.G, keypoint.B))
			end

			return keypoints
		end,
	},
} :: { [string]: TypeHandler<any, any> }
