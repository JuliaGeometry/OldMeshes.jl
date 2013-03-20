immutable Vertex
    x :: FloatingPoint
    y :: FloatingPoint
    z :: FloatingPoint
end
export Vertex

import Base.+, Base.-, Base.*, Base./
+(v1::Vertex,v2::Vertex) = Vertex(v1.x+v2.x,v1.y+v2.y,v1.z+v2.z)
-(v1::Vertex,v2::Vertex) = Vertex(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)
*(s::FloatingPoint,v::Vertex) = Vertex(s*v.x,s*v.y,s*v.z)
*(v::Vertex,s::FloatingPoint) = Vertex(v.x*s,v.y*s,v.z*s)
/(v::Vertex,s::FloatingPoint) = Vertex(v.x/s,v.y/s,v.z/s)

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

# | concatenates two @IndexedFaceSet@s
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
        push!(vertices,Vertex(v1.x, v1.y, v2.z - v2.z))
    end
    IndexedFaceSet(vertices, m1.faces)
end
export diff
# Mesh in face-set representation
# ===============================
immutable Face
    vertices :: Vector{Vector}
end
immutable FaceSet
    faces :: Vector{Face}
end

# Mesh in half-edge (he) set representation
# =========================================
immutable HalfEdge
    n           :: Int
    vetexRef    :: Int
    faceRef     :: Int
    edgeRefNext :: Int
    edgeRefPrev :: Int
    edgeRefOp   :: Int
end
immutable HeVertex
    n       :: Int
    coord   :: Vertex
    edgeRef :: Int
end

immutable HeFace
   n       :: Int
   edgeRef :: Int 
end
