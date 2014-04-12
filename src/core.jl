using ImmutableArrays

typealias Vertex Vector3{Float64}

immutable Face
    v1 :: Int64
    v2 :: Int64
    v3 :: Int64
end

abstract AbstractMesh

type Mesh <: AbstractMesh
    vertices :: Vector{Vertex}
    faces :: Vector{Face}
end

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

function area(v1::Vertex, v2::Vertex, v3::Vertex)
    # by Heron's formula (wikipedia)
    a = Base.norm(v2-v1)
    b = Base.norm(v3-v2)
    c = Base.norm(v1-v3)
    s = (a+b+c)/2
    T = sqrt(s*(s-a)*(s-b)*(s-c))
end

function clean(mesh::Mesh)
    # return a "clean" version of the mesh,
    #   by removing all faces with zero area
    #   and removing duplicate vertices
    faces = Face[]
    vertices = Vertex[]
    n = length(mesh.faces)
    for i=1:n
        fi = mesh.faces[i]
        v1 = mesh.vertices[fi.v1]
        v2 = mesh.vertices[fi.v2]
        v3 = mesh.vertices[fi.v3]

        # skip any faces with zero area
        if area(v1,v2,v3)==0
            continue
        end

        iv1 = findfirst(vertices, v1)
        if iv1==0
            push!(vertices, v1)
            iv1 = length(vertices)
        end
        iv2 = findfirst(vertices, v2)
        if iv2==0
            push!(vertices, v2)
            iv2 = length(vertices)
        end
        iv3 = findfirst(vertices, v3)
        if iv3==0
            push!(vertices, v3)
            iv3 = length(vertices)
        end
        push!(faces, Face(iv1,iv2,iv3))
    end
    cleaned_mesh = Mesh(vertices, faces)
    return cleaned_mesh
end

export Vertex, Face, AbstrctMesh, Mesh, vertices, faces, merge, clean
