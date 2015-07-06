export Vertex,
       Face,
       AbstractMesh,
       Mesh,
       vertices,
       faces,
       Face3,
       Point2,
       Point3


typealias Vertex Vector3{Float64}

immutable Face3{T, Id}
    v1::T
    v2::T
    v3::T
end

Face3{T}(v::AbstractArray{T}) = Face3{T,1}(v[1], v[2], v[3])
Face3{T}(x::T,y::T,z::T) = Face3{T,1}(x,y,z)

@inline function Base.getindex(f::Face3, i)
    i == 1 ? f.v1 : i == 2 ? f.v2 : f.v3
end


typealias Point3 Vector3

typealias Point2 Vector2

typealias Vertex Point3{Float64}

abstract AbstractMesh{V, F}

type Mesh{V, F} <: AbstractMesh{V, F}
    vertices::Vector{V}
    faces::Vector{F}
end

vertices(m::Mesh) = m.vertices
faces(m::Mesh) = m.faces

Base.isempty(m::Mesh) = isempty(m.vertices) && isempty(m.faces)

# concatenates two meshes
function Base.merge{V, F}(m1::AbstractMesh{V, F}, m2::AbstractMesh{V, F})
    v1 = vertices(m1)
    f1 = faces(m1)
    v2 = vertices(m2)
    f2 = faces(m2)
    nV = size(v1,1)
    nF = size(f2,1)
    newF2 = F[ F(f2[i][1]+nV, f2[i][2]+nV, f2[i][3]+nV) for i = 1:nF ]
    Mesh(append!(v1,v2),append!(f1,newF2))
end

function Base.convert(::Type{Mesh{Point3{Int},Face3{Int,0}}}, mesh::Mesh{Point3{Float64}, Face3{Int,0}}, scale=1)
    Mesh{Point3{Int},Face3{Int,0}}(Point3{Int}[Point3{Int}(round(Int,v[1]*scale),
                                                           round(Int,v[2]*scale),
                                                           round(Int,v[3]*scale))
                                                          for v in mesh.vertices], copy(mesh.faces))
end
