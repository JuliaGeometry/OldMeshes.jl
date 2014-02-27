using ImmutableArrays

################################################################################
#
# basic types
#
################################################################################

# IDs are ints
typealias VertexId Int
typealias FaceId   Int
typealias EdgeId   Int

# faces are triples of vertex IDs
#
# the ID order encodes the face orientation
typealias Face Vector3{VertexId}

# the vertex position type
typealias Vertex Vector3{Float64}

# a (directed) edge
typealias Edge Vector2{VertexId}

import Base.next, Base.done

# face vertex iterator
immutable FcVrtItorSt
    f  :: Face
    ix :: Int
    b  :: Bool
end
vertices(f::FcVrtItorSt) = FcVrtItorSt(f,1,false)
next(st::FcVrtItorSt) = (st.f[st.ix], FcVrtItorSt(st.f,st.ix%3+1,true))
done(st::FcVrtItorSt) = st.b && st.v != 1

# face edge iterator
immutable FcEdgItorSt
    f  :: Face
    ix :: Int
    b  :: Bool
end
edges(f::FcEdgItorSt) = FcEdgItorSt(f,1,false)
next(st::FcEdgItorSt) =
    (Edge(st.f[st.ix],st.f[st.ix%3+1]), FcEdgItorSt(st.f,st.ix%3+1,true))
done(st::FcEdgItorSt) = st.b && st.v != 1


# AbstractMesh : base mesh type
#
# Every subtype, am, of AbstractMesh should implement:
#
#  - faces(::am) -> iterable collection of faces
#  - vertices(::am) -> iterable collection of vertex IDs. 
#  - position(::am,::VertexId) -> Vertex
#
abstract AbstractMesh

# Mesh : the basic mesh type in which faces and vertex positions are
# stored in a vector
#
type Mesh <: AbstractMesh
    faces     :: Vector{Face}
    positions :: Vector{Vertex}
end

faces(m::Mesh) = m.faces
vertices(m::Mesh) = 1:length(m.positions)
position(m::Mesh,ix::VertexId) = m.positions[ix]


################################################################################
#
# basic operations
#
################################################################################

# test for orientation of mesh
function isOriented(tm::TopologicalMesh)
   es = Set{Edge}()
    for f in faces(tm)
        for e in edges(f)
            if in(e,es)
                return false
            else
                push!(es,e)
            end
        end
    end
end


# Every AbstactMesh should be able to convert itself to Mesh
mesh(m::Mesh) = m

# concatenates two meshes
function merge(am1::Mesh, am2::Mesh)
    m1 = mesh(am1)
    m2 = mesh(am2)
    v1 = m1.vertices
    f1 = m1.faces
    v2 = m2.vertices
    f2 = m2.faces
    nV = size(v1,1)
    nF = size(f2,1)
    newF2 = Face[ Face(f2[i].v1+nV, f2[i].v2+nV, f2[i].v3+nV) for i = 1:nF ]
    Mesh(append!(v1,v2),append!(f1,newF2))
end

export Vertex, Face, TopologicalMesh, Mesh, vertices, faces, merge
