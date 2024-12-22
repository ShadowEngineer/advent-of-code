--!strict
export type Vector2D<T> = { x: T, y: T }
export type Vector3D<T> = { x: T, y: T, z: T }
export type Direction = "North" | "NorthEast" | "East" | "SouthEast" | "South" | "SouthWest" | "West" | "NorthWest"

export type Vector2D_N = Vector2D<number>
export type Vector3D_N = Vector3D<number>
export type AnyNumericalVector = Vector2D_N | Vector3D_N

local Vector = {}

function Vector.getVectorFromDirection(direction: Direction): Vector2D<number>
	local mapping: { [Direction]: Vector2D<number> } = {
		North = { x = 0, y = -1 },
		NorthEast = { x = 1, y = -1 },
		East = { x = 1, y = 0 },
		SouthEast = { x = 1, y = 1 },
		South = { x = 0, y = 1 },
		SouthWest = { x = -1, y = 1 },
		West = { x = -1, y = 0 },
		NorthWest = { x = -1, y = -1 },
	}

	local result = mapping[direction]
	assert(result, `{direction}, wrong direction lol?`)
	return result
end

function Vector.getDestination(from: Vector2D<number>, direction: Direction, distance: number): Vector2D<number>
	if direction == "North" then
		return { x = from.x, y = from.y - distance }
	elseif direction == "NorthEast" then
		return { x = from.x + distance, y = from.y - distance }
	elseif direction == "East" then
		return { x = from.x + distance, y = from.y }
	elseif direction == "SouthEast" then
		return { x = from.x + distance, y = from.y + distance }
	elseif direction == "South" then
		return { x = from.x, y = from.y + distance }
	elseif direction == "SouthWest" then
		return { x = from.x - distance, y = from.y + distance }
	elseif direction == "West" then
		return { x = from.x - distance, y = from.y }
	elseif direction == "NorthWest" then
		return { x = from.x - distance, y = from.y - distance }
	end

	error(`{direction}, wrong direction lol?`)
end

function Vector.add2D(a: Vector2D_N, b: Vector2D_N): Vector2D_N
	return { x = a.x + b.x, y = a.y + b.y }
end

function Vector.add3D(a: Vector3D_N, b: Vector3D_N): Vector3D_N
	return { x = a.x + b.x, y = a.y + b.y, z = a.z + b.z }
end

return Vector
