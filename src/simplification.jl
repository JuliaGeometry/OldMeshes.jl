# Mesh simplification via edge collapse. 
#
# The implementation follows for the most part the algorithm
# described in:
#
#   Garland, Michael, and Paul S. Heckbert. "Surface 
#   simplification using quadric error metrics." 
#   Proceedings of the 24th annual conference on Computer 
#   graphics and interactive techniques. 
#   ACM Press/Addison-Wesley Publishing Co., 1997.
#
# The principal ways in which the implementation deviates are:
#  1. Only edges, and not vertex pairs in general, are
#     collapsible. We require that simplification preserves
#     topology.
#  2. Collapse is only performed on edges that are incident on 
#     interior vertices. Boundaries are not simplified. This
#     allows for a variety of simplifications in the logic of 
#     collapse.

###########################################################
#
# CollapsibleMesh
#
# A data structure representing a triangular mesh that
# admits edge collapse.
#
immutable HalfEdge
    source   :: Int64 # vertex index at the root of the half-edge
    next     :: Int64 # the next edge in this (oriented) face
    opposite :: Int64 # the other edge in the adjoining face (if not on bdy)
end

type CollapsibleMesh
    vPositions :: Vector{Vertex}
    vEdges     :: Vector{Int64}
    edges      :: Vector{HalfEdge}
end

# vertex accessors
edge(cm,v) = cm.vEdges[v]
position(cm,v) = cm.vPositions[v]

# edge accessors
source(cm,e) = cm.edges[e].source
next(cm,e) = cm.edges[e].next
opposite(cm,e) = cm.edges[e].opposite

# derived accessors
target(cm,e) = source(cm,next(cm,e))
previous(cm,e) = next(cm,next(cm,e))
clockwise(cm,e) = next(cm,opposite(cm,e))

# clockwise edge iterator
macro forEachEdge(cm,e,body)
    quote
        ee = e
        while true
            $body
            e = clockwise(cm,e)
            if e == ee; break; end
        end
    end
end

# predicates
isDeletedEdge(cm,e) = next(cm,e) == 0
isDeletedVertex(cm,v) = edge(cm,v) == 0
isBoundaryEdge(cm,e) = opposite(cm,e) == 0
function isBoundaryVertex(cm,v)
    e = edge(cm,v)
    @forEachEdge cm e if isBoundaryEdge(cm,e); return true; end
    false
end
function isCollapsibleEdge(cm,e)

    # assert edge and vertices aren't deleted
    @assert !isDeletedEdge(cm,e)
    src = source(cm,e)
    tgt = target(cm,e)
    @assert !isDeletedVertex(cm,src)
    @assert ! isDeletedVertex(cm,tgt)

    # check for boundary
    if isBoundaryEdge(cm,e); return false; end
    if isBoundaryVertex(cm,src); return false; end
    if isBoundaryVertex(cm,tgt); return false; end

    # check for topological conditions
    #
    # We only allow collapse if exactly two vertices are
    # connected by an edge to both the source and target vertex.

    srcNbrs = IntSet()
    se = edge(cm,src)
    @forEach cm se add!(srcNbrs,target(cm,se))

    tgtNbrs = IntSet()
    te = edge(cm,tgt)
    @forEach cm te add!(tgtNbrs,target(cm,te))

    if length(intersect(srcNbrs,tgtNbrs)) != 2; return false; end

    # if there are 4 nbrs, we're a tetrahedron: don't collapse
    if length(union(srcNbrs,tgtNbrs)) <= 4; return false; end

    true
end

# edge collapse
function collapse(cm::CollapsibleMesh, e::Int64, pos::Vertex)
    
    # bail if the edge is not collapsible
    if !isCollapsible(cm,e); return; end

    # id the relevant edges, vertices
    # 
    #          tgt
    #          +
    #         /|\
    #        / | \
    #    eno/  |  \opo
    #      /en | op\
    #     /    |    \
    # vl +    e|o    + vr
    #     \    |    /
    #      \ep | on/
    #    epo\  |  /ono
    #        \ | /
    #         \|/
    #          +
    #          src
    #
    en = next(cm,e)
    eno = opposite(cm,en)
    ep = previous(cm,e)
    epo = opposite(cm,ep)
    o = opposite(cm,e)
    on = next(cm,o)
    ono = opposite(cm,on)
    op = previous(cm,o)
    opo = opposite(cm,op)
    src = source(cm,e)
    tgt = source(cm,o)
    vl = source(cm,ep)
    vr = source(cm,op)

    # fix up the edge opposites for the edges that remain
    cm.edges[epo].opposite = eno;
    cm.edges[eno].opposite = epo;
    cm.edges[opo].opposite = ono;
    cm.edges[ono].opposite = opo;

    # ensure all the edges emanating from the source vertex
    # now emanate from the target vertex
    @forEachEdge cm e begin
        cm.edges[e].source = tgt
    end

    # ensure the three remaining vertices point to edges that remain
    cm.vEdges[tgt] = opo
    cm.vEdges[vl] = eno
    cm.vEdges[vr] = ono

    # update the remaining vertex position
    cm.vPositions[target(cm,e)] = pos;

    # delete the vertex and edges
    cm.vEdges[src] = 0
    cm.edges[ep].next = 0
    cm.edges[en].next = 0
    cm.edges[e].next = 0
    cm.edges[op].next = 0
    cm.edges[on].next = 0
    cm.edges[o].next = 0
end

###########################################################
#
# conversion between a vanilla mesh and a collapsible mesh
#

# construction from a vanilla mesh
function CollapsibleMesh(m::Mesh)
    vts = mesh.vertices
    fcs = mesh.faces

    nVts = length(vts)
    nFcs = length(fcs)

    # make edge, vEdge lists &
    # build edge dictionary
    vs = Array(Int64,nVts)
    es = Array(HalfEdge,3*nFcs)
    edgeDict = Dict{(Int64,Int64),Int64}()
    for i = 1:nFcs
        fc = fcs[i]

        # set vertex edges
        vs[fc.v1] = 3*i-2
        vs[fc.v2] = 3*i-1
        vs[fc.v3] = 3*i

        # set sources
        es[3*i-2].source = fc.v1
        es[3*i-1].source = fc.v2
        es[3*i].source   = fc.v3

        # set nexts
        es[3*i-2].next = 3*i-1
        es[3*i-1].next = 3*i
        es[3*i].next   = 3*i-2

        # add edges to dictionary
        edgeDict[(fc.v1,fc.v2)] = 3*i-2
        edgeDict[(fc.v2,fc.v3)] = 3*i-1
        edgeDict[(fc.v3,fc.v1)] = 3*i
    end

    # fix up opposites
    for i = 1:3*nFcs
        src = es[i].source
        tgt = es[es[i].next].source
        es[i].opposite = get(edgeDict,(tgt,src),0)
    end

    CollapsibleMesh(vts,vs,es)
end

# conversion to a vanilla mesh
function Mesh(cm::CollapsibleMesh)

    # collect vertex indices
    nVold = length(cm.vEdges)
    vs = IntSet()
    for v = 1:nVold
        if !isDeletedVertex(cm,v)
            add!(vs,v)
        end
    end

    # get vertex positions, create reverse map
    nV = length(vs)
    vts = Array(Vertex,nV)
    invV = zeros(Int64,nVold)
    ix = 1
    for v = vs
        vts[ix] = position(cm,v)
        invV[v] = ix
        ix += 1
    end

    # collect faces
    fcs = Array(Face,0)
    nE = length(cm.edges)
    for e = 1:3:nE
        if !isDeletedEdge(cm,e)
            # make and push face
            v1 = invV[source(cm,e)]
            v2 = invV[source(cm,e+1)]
            v3 = invV[source(cm,e+2)]
            push!(fcs,Face(v1,v2,v3))
        end
    end

    Mesh(vts,fcs)
end

##########################################################
#
# mesh simplification based on vertex quadric error
#

# Given three vertices, determines coefficients of the
# corresponding plane equation
function plane(v1::Vertex,v2::Vertex,v3::Vertex)
    e1 = v1-v2
    e2 = v3-v2
    p = zeros(4)
    p[1] = e1.y*e2.z-e1.z*e2.y
    p[2] = e1.z*e2.x-e1.x*e2.z
    p[3] = e1.x*e2.y-e1.y*e2.x
    p /= sqrt(dot(p,p)) # normalize
    p[4] = -(p[1]*v2.x+p[2]*v2.y+p[3]*v2.z)
    p
end

# determines an error quadric associated with the given vertex
function quadric(cm::CollapsibleMesh, v::Int64)
    q = zeros(4,4)
    if !isBoundaryVertex(cm,v)
        e = edge(cm,v)
        @forEachEdge cm e begin
            # determine the plane associated with the current face
            v1 = position(cm,source(cm,e))
            v2 = position(cm,source(cm,next(cm,e)))
            v3 = position(cm,source(cm,previous(cm,e)))
            p = plane(v1,v2,v3)

            # accumulate the outer product
            for i = 1:4, j = 1:4
                q[i,j] += p[i]*p[j]
            end
        end
    end
    q
end

# helper type for edge heap
immutable HeapNode
    cost :: Float64
    edge :: Int64
end
<(hn1::HeapNode,hn2::HeapNode) = hn1.cost < hn2.cost
using DataStructures


function simplify(msh::Mesh,eps::Float64)
    
end
