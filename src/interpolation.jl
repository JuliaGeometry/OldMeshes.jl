# | interpolate Vertices from one  'Mesh' to another 'Mesh'
#
#   The algorithm works like that: 
#   1. For all vertices of 'to' look if they are inside a face of 'Mesh' 'from'
#   2. If they do interpolate elevation form face; if not keep the old
function interpolate(from::IndexedFaceSet,to::IndexedFaceSet) # :: IndexedFaceSet
    IndexedFaceSet(interpolate(from.vertices, to),from.faces)
end

# | Interpolate elevation of a set of xy-vertices from an 'IndexedFaceSet'
function interpolate(vs::Vector{Vertex}, m :: IndexedFaceSet) # :: Vector{Vertex}
    vsn = Vertex[]
    for v = from.vertices
        fc = filter(x -> contains(x,v)[face(f,to.nds) for f = to.faces])
        if length(fc) == 0
            push!(vsn,v)
        else    
            push!(vsn,interpolate(v,fc[1]))
        end 
    end
    vsn
end

# | Interpolate the elevation of 'Vertex' from a 'IndexedFace'
function interpolate(v::Vertex, f::Face) # :: Vertex
    interpolate(v, plane(f.v1, f.v2, f.v3))
end

# | Interpolate the elevation 
function interpolate(v::Vertex,p::Plane) # :: Vertex
    z = -((p.e1*v.e1 + p.e2*v.e2 + p.e4)/p.e3)
    Vertex(v.e1, v.e2, z)
end
export  interpolate

# | Checks if 'Vertex's xy-position lies inside a Face
#   Code from http://stackoverflow.com/questions/2049582/how-to-determine-a-point-in-a-triangle
function contains(f::Face, v::Vertex) #  :: Bool
    import Base.sign
    function sign(v1::Vertex,v2::Vertex,v3::Vertex)
        (v1.e1 - v3.e1) * (v2.e2 - v3.e2) - (v2.e1 - v3.e1) * (v1.e2 - v3.e2)
    end
    b1 = sign(v, f.v1, f.v2) < 0
    b2 = sign(v, f.v2, f.v3) < 0
    b3 = sign(v, f.v3, f.v1) < 0
    (b1 == b2) && (b2 == b3)
end

