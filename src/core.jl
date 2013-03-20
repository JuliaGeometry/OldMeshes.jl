immutable Vector3d
    x :: FloatingPoint
    y :: FloatingPoint
    z :: FloatingPoint
end
export Vector3d
typealias Vertex Vector3d
export Vertex

import Base.+, Base.-, Base.*, Base./
+(v1::Vector3d,v2::Vector3d) = Vector3d(v1.x+v2.x,v1.y+v2.y,v1.z+v2.z)
-(v1::Vector3d,v2::Vector3d) = Vector3d(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)
*(s::FloatingPoint,v::Vector3d) = Vector3d(s*v.x,s*v.y,s*v.z)
*(v::Vector3d,s::FloatingPoint) = Vector3d(v.x*s,v.y*s,v.z*s)
/(v::Vector3d,s::FloatingPoint) = Vector3d(v.x/s,v.y/s,v.z/s)
import Base.convert
convert(::Type{FloatingPoint},x::Vector3d) = [x.x,x.y,x.z]
export convert

# Mesh in indexed face-set-representation
# =======================================
immutable IndexedFace
    v1 :: Int
    v2 :: Int
    v3 :: Int
end
export IndexedFace

type IndexedFaceSet
    vertices :: Vector{Vertex}
    faces    :: Vector{IndexedFace}
end
export IndexedFaceSet

# | Concatenate two @IndexedFaceSet@s
function merge(m1::IndexedFaceSet, m2::IndexedFaceSet)
    v1 = copy(m1.vertices)
    f1 = copy(m1.faces)
    nV = size(v1,1)
    f2 = m2.faces
    nF = size(f2,1)
    newF2 = IndexedFace[ IndexedFace(f2[i].v1+nV, f2[i].v2+nV, f2[i].v3+nV) for i = 1:nF ]
    IndexedFaceSet(append!(v1,m2.vertices),append!(f1,newF2))
end
export merge

# | Difference between two meshes as new mesh ; currently they could
# | only differ in vertex-z values
# |
# | TODO : Implement difference between arbitrary surfaces
function diff(m1::IndexedFaceSet,m2::IndexedFaceSet)
    vertices = Vertex[]
    for i = 1:length(m1.vertices)
        v1 = m1.vertices[i]
        v2 = m2.vertices[i]
        push!(vertices,Vertex(v1.x, v1.y, v2.z - v1.z))
    end
    IndexedFaceSet(vertices, m1.faces)
end
export diff


# Mesh in face-set representation
# ===============================
immutable Face
    v1 :: Vertex
    v2 :: Vertex
    v3 :: Vertex
end
export Face

immutable FaceSet
    faces :: Vector{Face}
end
export FaceSet

import Base.convert
convert(::Type{FaceSet},x::IndexedFaceSet) = 
    FaceSet(Face[Face(x.vertices[f.v1], x.vertices[f.v2], x.vertices[f.v3]) for f = x.faces])
export convert

import Base.cross
function cross(x::Vector3d, y::Vector3d)
    c = cross(convert(FloatingPoint, x), convert(FloatingPoint,y))
    Vector3d(c[1],c[2],c[3])
end
export cross

function normal(f::Face)
    a = (f.v2 - f.v1)
    b = (f.v3 - f.v2)
    cross(a,b)
end
export normal
