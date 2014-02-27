# HalfEdgeMesh : a mesh type for which edges can be collapsed and inserted.
#
type HalfEdge
    src :: VertexId
    nxt :: VertexId
    opp :: EdgeId
end

type HalfEdgeMesh
    halfEdges   :: Vector{HalfEdge}
    positions   :: Vector{Vertex}
    vertexEdges :: Vector{EdgeId}
end
