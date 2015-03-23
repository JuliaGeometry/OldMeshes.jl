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
export simplify

type HalfEdge
    source   :: Int # vertex index at the root of the half-edge
    next     :: Int # the next edge in this (oriented) face
    opposite :: Int # the other edge in the adjoining face (if not on bdy)
    HalfEdge(s,n,o) = new(s,n,o)
end

type CollapsibleMesh
    vPositions :: Vector{Vertex}
    vEdges     :: Vector{Int}
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
        ee = $(esc(e))
        println($(esc(e)))
        while true
            $(esc(body))
            $(esc(e)) = clockwise($(esc(cm)),$(esc(e)))
            if $(esc(e)) == ee
                break
            end
        end
    end
end

# predicates
isDeletedEdge(cm,e) = next(cm,e) == 0
isDeletedVertex(cm,v) = edge(cm,v) == 0
isBoundaryEdge(cm,e) = opposite(cm,e) == 0

function isBoundaryVertex(cm,v)
    e = edge(cm,v)
    @forEachEdge cm e begin
        if isBoundaryEdge(cm,e)
            return true
        end
    end
    false
end

function isCollapsibleEdge(cm,e)

    # assert edge and vertices aren't deleted
    @assert !isDeletedEdge(cm,e)
    src = source(cm,e)
    tgt = target(cm,e)
    @assert !isDeletedVertex(cm,src)
    @assert !isDeletedVertex(cm,tgt)

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
    @forEachEdge cm se add!(srcNbrs,target(cm,se))

    tgtNbrs = IntSet()
    te = edge(cm,tgt)
    @forEachEdge cm te add!(tgtNbrs,target(cm,te))

    if length(intersect(srcNbrs,tgtNbrs)) != 2; return false; end

    # if there are 4 nbrs, we're a tetrahedron: don't collapse
    if length(union(srcNbrs,tgtNbrs)) <= 4; return false; end

    true
end

# edge collapse
function collapse!(cm::CollapsibleMesh, e::Int, pos::Vertex)
        
    if !isCollapsibleEdge(cm,e) return false end

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

    # check that the new vertex position doesn't cause an inversion. 
    function causesInversion(e)
        v0 = source(cm,e)
        v1 = target(cm,e)
        v2 = target(cm,next(cm,e))
        p0 = position(cm,v0)
        p1 = position(cm,v1)
        p2 = position(cm,v2)
        n1 = unit(cross(p1-p0,p2-p0))
        n2 = unit(cross(p1-pos,p2-pos))
        dot(n1,n2) <= 0
    end

    # circle source vertex
    ee = e
    p0 = position(cm,src)
    @forEachEdge cm ee begin
        if ee != e && ee != on
            if causesInversion(ee)
                return false
            end
        end
    end

    # circle target vertex
    ee = o
    @forEachEdge cm o begin
        if ee != o && ee != en
            if causesInversion(ee)
                return false
            end
        end
    end

    # now perform the actual collapse...

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

    return true
end

###########################################################
#
# conversion between a vanilla mesh and a collapsible mesh
#

# construction from a vanilla mesh
function CollapsibleMesh(m::Mesh)
    vts = m.vertices
    fcs = m.faces

    nVts = length(vts)
    nFcs = length(fcs)

    # make edge, vEdge lists &
    # build edge dictionary
    vs = Array(Int,nVts)
    es = Array(HalfEdge,3*nFcs)
    edgeDict = Dict{(Int,Int),Int}()
    for i = 1:nFcs
        fc = fcs[i]

        # set vertex edges
        vs[fc.v1] = 3*i-2
        vs[fc.v2] = 3*i-1
        vs[fc.v3] = 3*i

        # set sources
        es[3*i-2] = HalfEdge(fc.v1,0,0)
        es[3*i-1] = HalfEdge(fc.v2,0,0)
        es[3*i]   = HalfEdge(fc.v3,0,0)

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
    invV = zeros(Int,nVold)
    ix = 1
    for v = vs
        vts[ix] = position(cm,v)
        invV[v] = ix
        ix += 1
    end

    # collect faces
    fcs = Array(Face{Int},0)
    nE = length(cm.edges)
    for e = 1:3:nE
        if !isDeletedEdge(cm,e)
            # make and push face
            v1 = invV[source(cm,e)]
            v2 = invV[source(cm,e+1)]
            v3 = invV[source(cm,e+2)]
            push!(fcs,Face{Int}(v1,v2,v3))
        end
    end

    Mesh(vts,fcs)
end

##########################################################
#
# mesh simplification based on vertex quadric error
#

typealias Plane Vector4{Float64}

# Given three vertices, determines coefficients of the
# corresponding plane equation
function plane(v1::Vertex,v2::Vertex,v3::Vertex)
    n = unit(cross(v1-v2,v3-v2))
    d = dot(n,v2)
    p = Plane(n.e1,n.e2,n.e3,-d)
end

# determines an error quadric associated with the given vertex
typealias Quadric Matrix4x4{Float64}
function quadric(cm::CollapsibleMesh, v::Int)
    q = zero(Quadric)
    if !isBoundaryVertex(cm,v)
        e = edge(cm,v)
        @forEachEdge cm e begin
            # determine the plane associated with the current face
            v1 = position(cm,source(cm,e))
            v2 = position(cm,source(cm,next(cm,e)))
            v3 = position(cm,source(cm,previous(cm,e)))
            p = plane(v1,v2,v3)

            # accumulate the outer product
            q += column(p)*row(p)
        end
    end
    q
end

function edgeCost(cm,qs,e)
    p1 = position(cm,source(cm,e))
    p2 = position(cm,target(cm,e))
    p  = 0.5*(p1+p2)
    hp = Plane(p.e1,p.e2,p.e3,1.0)
    c = hp*(qs[source(cm,e)]+qs[target(cm,e)])*hp
    (c,p)
end

# helper type for edge heap
immutable HeapNode
    cost     :: Float64
    edge     :: Int
    position :: Vertex
    HeapNode(c,e,p) = new(c,e,p)
end
<(hn1::HeapNode,hn2::HeapNode) = hn1.cost < hn2.cost
using DataStructures

function simplify(msh::Mesh,eps::Float64)
    # to a collapsible mesh
    cm = CollapsibleMesh(msh)

    # calculate the initial vertex quadrics
    nV = length(cm.vPositions)
    qs = Array(Quadric,nV)
    for v = 1:nV
        qs[v] = quadric(cm,v)
    end

    # initialize the edge heap
    h = mutable_binary_minheap(HeapNode)
    nE = length(cm.edges)
    ks = zeros(Int,nE) # keys into the heap

    # a convenience closure : recalculate the cost
    # of the edge and update the heap
    function updateCost(e)
        if isCollapsibleEdge(cm,e)
            (c,p) = edgeCost(cm,qs,e)
            if c <= eps
                hn = HeapNode(c,e,p)
                if ks[e] != 0
                    update!(h, ks[e], hn)
                else
                    ks[e] = push!(h, hn)
                end
            end
        end
    end

    # add all the appropriate edges to the heap
    for e = 1:nE
        updateCost(e)
    end

    # simplify
    while top(h).cost <= eps
        hn = pop!(h)
        e = hn.edge
        p = hn.position

        src = source(cm,e)
        tgt = target(cm,e)

        if collapse!(cm,e,p)
            # update the quadric
            qs[tgt] += qs[src]

            # update neighbor edges in the heap
            e = edge(cm,v)
            @forEachEdge cm e begin
                updateCost(e)
                updateCost(next(cm,e))
                updateCost(previous(cm,e))
                if !isBoundaryEdge(cm,next(cm,e))
                    updateCost(opposite(cm,next(cm,e)))
                end
            end
        end
    end
    
    # from a collapsible mesh
    Mesh(cm)
end

