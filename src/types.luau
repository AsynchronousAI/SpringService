type TypeHandler<A, B> = {
	InitialVelocity: A,
	ConvertTo: (A) -> B,
	ConvertFrom: (B) -> A,
}

return {
	-- Default
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

	-- Simple conversion
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

	-- Multivariable conversion
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
} :: { [string]: TypeHandler<any, any> }
