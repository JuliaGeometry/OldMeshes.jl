export Vertex,
       Face,
       AbstractMesh,
       Mesh,
       vertices,
       faces,
       merge

typealias Vertex Vector3{Float64}

immutable Face{T}
    v1::T
    v2::T
    v3::T
end

Face(v::AbstractArray) = Face(v[1], v[2], v[3])


abstract AbstractMesh

type Mesh{F} <: AbstractMesh
    vertices :: Vector{Vertex}
    faces :: Vector{F}
    has_topology :: Bool
end

Mesh(v,f) = Mesh(v,f, true)
Mesh() = Mesh(Vertex[], Face[], true)

vertices(m::Mesh) = m.vertices
faces(m::Mesh) = m.faces

Base.isempty(m::Mesh) = isempty(m.vertices) && isempty(m.faces)

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
