# | interpolate Vertices from one  @Mesh@ to another @Mesh@
#
#   The algorithm works like that: 
#   1. For all vertices of @to@ look if they are inside a face of @Mesh@ @from@
#   2. If they do interpolate elevation form face; if not keep the old
function interpolate(from::FaceSet,to::FaceSet) # -> FaceSet
end

# | Interpolate the elevation of @Vertex@ from a @IndexedFace@
function interpolate(v::Vertex, f::Face) # -> Vertex
    interpolate(v, plane(f.v1, f.v2, f.v3))
end

using ImmutableArrays
typealias Vec3d Vector3{Float64}

# | A Plane is represented as normal with point
type Plane
    n  :: Vec3d
    p  :: Vertex
end

# | Interpolate the elevation 
function interpolate(v::Vertex,p::Plane) # -> Vertex
    z = ((p.n.e1*(v.e1 - p.p.e1) + p.n.e2*(v.e2 - p.p.e2))/p.n.e3) + p.p.e3
    Vertex(v1[1], v2[2], z)
end

import Base.sign
function sign(v1::Vertex,v2::Vertex,v3::Vertex)
    (v1.e1 - v3.e1) * (v2.e2 - v3.e2) - (v2.e1 - v3.e1) * (v1.e2 - v3.e2)
end

# | Checks if @Vertex@'s xy-position lies inside a Face
# Code from http://stackoverflow.com/questions/2049582/how-to-determine-a-point-in-a-triangle
function contains(f::IndexedFace, v::Vertex) #  -> Bool
    b1 = sign(v, f.v1, f.v2) < 0
    b2 = sign(v, f.v2, f.v3) < 0
    b3 = sign(v, f.v3, f.v1) < 0
    (b1 == b2) && (b2 == b3)
end

