immutable Vertex
    x :: Float64
    y :: Float64
    z :: Float64
end
export Vertex

import Base.+, Base.-, Base.*, Base./
+(v1::Vertex,v2::Vertex) = Vertex(v1.x+v2.x,v1.y+v2.y,v1.z+v2.z)
-(v1::Vertex,v2::Vertex) = Vertex(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)
*(s::Float64,v::Vertex) = Vertex(s*v.x,s*v.y,s*v.z)
*(v::Vertex,s::Float64) = Vertex(v.x*s,v.y*s,v.z*s)
/(v::Vertex,s::Float64) = Vertex(v.x/s,v.y/s,v.z/s)

# Mesh as indexed face-set
# ========================
immutable IndexedFace
    v1 :: Int64
    v2 :: Int64
    v3 :: Int64
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

## Mesh as face-set
## ================
#immutable FaceSet
#    faces :: Vecoor
#end
