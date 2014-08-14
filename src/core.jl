using ImmutableArrays

export Vertex,
       Face,
       AbstractMesh,
       Mesh,
       vertices,
       faces,
       merge

typealias Vertex{T} Vector3{T}

immutable Face{T <: Real}
    v1 :: T
    v2 :: T
    v3 :: T
end

abstract AbstractMesh

type Mesh{VT <: Real, FT <: Integer} <: AbstractMesh
    vertices :: Vector{Vertex{VT}}
    faces :: Vector{Face{FT}}
    has_topology :: Bool
end
Mesh{VT <: Real, FT <: Integer}(vertices::Vector{Vertex{VT}}, faces::Vector{Face{FT}}, has_topology::Bool) = Mesh{VT, FT}(vertices, faces, has_topology)

Mesh(v,f) = Mesh(v,f, true)

vertices(m::Mesh) = m.vertices
faces(m::Mesh) = m.faces

# concatenates two meshes
function merge(m1::AbstractMesh, m2::AbstractMesh)
    v1 = vertices(m1)
    f1 = faces(m1)
    v2 = vertices(m2)
    f2 = faces(m2)
    nV = size(v1,1)
    nF = size(f2,1)
    newF2 = Face[ Face(f2[i].v1+nV, f2[i].v2+nV, f2[i].v3+nV) for i = 1:nF ]
    Mesh(append!(v1,v2),append!(f1,newF2))
end
