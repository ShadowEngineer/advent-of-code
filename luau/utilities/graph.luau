--!strict
export type GraphKind = "Directed" | "Undirected"
export type Direction = "Incoming" | "Outgoing" | "Bidirectional"
export type Edge = {
	Direction: Direction,
	Weight: number?,
}
type GraphObj<T> = {
	Size: number,
	Kind: GraphKind,
	Vertices: { [T]: {
		Vertex: T,
		Edges: { [T]: Edge },
	} },
}
type GraphImpl = {
	__index: GraphImpl,
	__tostring: (self: Graph) -> string,
	__iter: (self: Graph) -> (),
	__len: (self: Graph) -> number,
	_assertEdgePossible: <T>(self: Graph, from: T, to: T) -> (),
	_assertEdgeExists: <T>(self: Graph, from: T, to: T) -> (),
	new: <T>(arg: { T }?) -> Graph,
	HasNode: <T>(self: Graph, vertex: T) -> boolean,
	CountEdges: <T>(self: Graph, vertex: T) -> number,
	AddNode: <T>(self: Graph, vertex: T) -> Graph,
	RemoveNode: <T>(self: Graph, vertex: T) -> Graph,
	ConnectNodesOneWay: <T>(self: Graph, from: T, to: T, weight: number?) -> Graph,
	ConnectNodesBothWays: <T>(self: Graph, from: T, to: T, weight: number?) -> Graph,
	RemoveConnectionOneWay: <T>(self: Graph, from: T, to: T) -> Graph,
	RemoveConnectionBothWays: <T>(self: Graph, from: T, to: T) -> Graph,
}
export type Graph = typeof(setmetatable({} :: GraphObj<any>, {} :: GraphImpl))

local Graph: GraphImpl = {} :: GraphImpl
Graph.__index = Graph

function Graph:__tostring(): string
	local vertexList = ""
	for item in self.Vertices do
		-- counting edges
		vertexList ..= `{item}<{self:CountEdges(item)}>, `
	end
	vertexList = vertexList:sub(1, -3) -- to remove the final ", "
	return `Graph<{self.Kind}, #{#self}, [{vertexList}]>`
end

function Graph:__iter()
	return next, self.Vertices
end

function Graph:__len()
	return self.Size
end

function Graph.new<T>(arg: { T }?): Graph
	local graphObject: GraphObj<T> = {
		Size = 0,
		Kind = "Undirected",
		Vertices = {},
	}
	local newGraph = setmetatable(graphObject, Graph)

	if arg and typeof(arg) == "table" then
		for _, vertex in arg do
			newGraph:AddNode(vertex)
		end
	end

	return newGraph
end

function Graph:HasNode<T>(vertex: T): boolean
	return self.Vertices[vertex] ~= nil
end

function Graph:CountEdges<T>(vertex: T): number
	local numberOfEdges = 0

	for _, edge in self.Vertices[vertex].Edges do
		if edge.Direction ~= "Incoming" then
			numberOfEdges += 1
		end
	end

	return numberOfEdges
end

function Graph:AddNode<T>(vertex: T): Graph
	if self:HasNode(vertex) then
		error(`vertex [{vertex}] already in graph`)
	end

	self.Vertices[vertex] = { Edges = {}, Vertex = vertex }
	self.Size += 1

	return self
end

function Graph:RemoveNode<T>(vertex: T): Graph
	if not self:HasNode(vertex) then
		error(`vertex [{vertex}] not in graph`)
	end

	for otherVertex in self.Vertices[vertex].Edges do
		self.Vertices[otherVertex] = nil
	end

	self.Vertices[vertex] = nil
	self.Size -= 1

	return self
end

function Graph:_assertEdgePossible<T>(from: T, to: T)
	assert(self:HasNode(from), `vertex from {from} must be in the graph`)
	assert(self:HasNode(to), `vertex to {to} must be in the graph`)
end

function Graph:_assertEdgeExists<T>(from: T, to: T)
	assert(self.Vertices[from].Edges[to] ~= nil, `edge from {from} to {to} must exist`)
	assert(self.Vertices[to].Edges[from] ~= nil, `edge from {to} to {from} must exist`)
end

function Graph:ConnectNodesOneWay<T>(from: T, to: T, weight: number?): Graph
	self:_assertEdgePossible(from, to)

	local toFromEdge = self.Vertices[to].Edges[from]

	-- if opposite connection exists
	-- explicit type because luau thinks this'll be (string | string | string)? otherwise smh
	local oppositeDirection: Direction? = if toFromEdge then toFromEdge.Direction else nil
	local oppositeWeight = if toFromEdge then toFromEdge.Weight else nil

	-- if a direction already exists from the other end, and that direction is outgoing or already bidirectional, set it to bidirectional
	self.Vertices[from].Edges[to] = {
		Direction = if oppositeDirection ~= "Incoming" then "Bidirectional" else "Outgoing",
		Weight = weight,
	}
	self.Vertices[to].Edges[from] = {
		Direction = if oppositeDirection ~= "Incoming" then "Bidirectional" else "Incoming",
		Weight = oppositeWeight,
	}

	if self.Kind == "Undirected" then
		self.Kind = "Directed"
	end

	return self
end

function Graph:ConnectNodesBothWays<T>(from: T, to: T, weight: number?): Graph
	self:_assertEdgePossible(from, to)

	self.Vertices[from].Edges[to] = { Direction = "Bidirectional", Weight = weight }
	self.Vertices[to].Edges[from] = { Direction = "Bidirectional", Weight = weight }

	return self
end

function Graph:RemoveConnectionOneWay<T>(from: T, to: T): Graph
	self:_assertEdgePossible(from, to)
	self:_assertEdgeExists(from, to)

	-- if connection is currently both ways, modify
	-- otherwise remove
	if
		self.Vertices[from].Edges[to].Direction == "Bidirectional"
		and self.Vertices[to].Edges[from].Direction == "Bidirectional"
	then
		self.Vertices[from].Edges[to] = { Direction = "Incoming" }
		self.Vertices[to].Edges[from].Direction = "Outgoing"
	else
		self.Vertices[from].Edges[to] = nil
		self.Vertices[to].Edges[from] = nil
	end

	return self
end

function Graph:RemoveConnectionBothWays<T>(from: T, to: T): Graph
	self:_assertEdgePossible(from, to)

	self.Vertices[from].Edges[to] = nil
	self.Vertices[to].Edges[from] = nil

	return self
end

return Graph
