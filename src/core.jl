using Geometry

immutable Face
    v1 :: Int64
    v2 :: Int64
    v3 :: Int64
end
export Face

type Mesh
    vertices :: Vector{Point3d}
    faces :: Vector{Face}
end
export Mesh

# concatenates two meshes
function merge(m1::Mesh, m2::Mesh)
    v1 = copy(m1.vertices)
    f1 = copy(m1.faces)
    nV = size(v1,1)
    f2 = m2.faces
    nF = size(f2,1)
    newF2 = Face[ Face(f2[i].v1+nV, f2[i].v2+nV, f2[i].v3+nV) for i = 1:nF ]
    Mesh(append!(v1,m2.vertices),append!(f1,newF2))
end
export merge
